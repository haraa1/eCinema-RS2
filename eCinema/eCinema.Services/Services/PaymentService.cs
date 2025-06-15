using AutoMapper;
using eCinema.Models.DTOs.SeatTypes;
using eCinema.Models.Entities;
using eCinema.Models.SearchObjects;
using eCinema.Models;
using eCinema.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using eCinema.Models.DTOs.Payments;
using CinemaApp.Domain.Entities;
using Stripe;
using EasyNetQ.Logging;
using Microsoft.Extensions.Options;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;

namespace eCinema.Services.Services
{
    public class PaymentService : BaseCRUDService<PaymentDto, Payment, PaymentSearchObject, PaymentInsertDto, PaymentUpdateDto>, IPaymentService
    {
        private readonly StripeClient _stripe;
        private readonly eCinemaDbContext _context;
        private readonly StripeSettings _settings;
        public PaymentService(eCinemaDbContext context, IMapper mapper, StripeClient stripe, IOptions<StripeSettings> opt) : base(context, mapper)
        {
            _context = context;
            _stripe = stripe;
            _settings = opt.Value;

        }

        public override IQueryable<Payment> AddFilter(
            IQueryable<Payment> query,
            PaymentSearchObject search = null)
        {
            var filtered = base.AddFilter(query, search);

            if (search?.PaymentStatus != null)
            {
                filtered = filtered.Where(p => p.Status == search.PaymentStatus.Value);
            }

            return filtered;
        }

        public async Task<(PaymentDto payment, string clientSecret)> CreateIntentAsync(int bookingId)
        {
            Booking booking = await _context.Bookings
                                        .Include(b => b.Tickets)
                                        .Include(b => b.BookingConcessions)
                                            .ThenInclude(bc => bc.Concession)
                                        .Include(b => b.AppliedDiscount) 
                                        .SingleOrDefaultAsync(b => b.Id == bookingId);

            if (booking == null)
            {
                throw new KeyNotFoundException($"Booking with ID {bookingId} not found.");
            }

            decimal subtotalAmountBam = booking.Tickets.Sum(t => t.Price);

            if (booking.BookingConcessions != null && booking.BookingConcessions.Any())
            {
                foreach (var bc in booking.BookingConcessions)
                {
                    if (bc.Concession == null)
                    {
                        var concession = await _context.Concessions.FindAsync(bc.ConcessionId);
                        if (concession == null)
                        {
                            throw new Exception($"Concession with ID {bc.ConcessionId} not found for booking concession.");
                        }
                        subtotalAmountBam += bc.Quantity * concession.Price;
                    }
                    else
                    {
                        subtotalAmountBam += bc.Quantity * bc.Concession.Price;
                    }
                }
            }


            decimal finalAmountBam = subtotalAmountBam;

            if (booking.AppliedDiscount != null && booking.AppliedDiscount.DiscountPercentage > 0)
            {
                decimal discountValue = subtotalAmountBam * (booking.AppliedDiscount.DiscountPercentage / 100.0m);
                finalAmountBam = subtotalAmountBam - discountValue;

                if (finalAmountBam < 0)
                {
                    finalAmountBam = 0;
                }
            }

            long amountFening = (long)Math.Round(finalAmountBam * 100m, MidpointRounding.AwayFromZero);

            if (amountFening < 50 && amountFening > 0)
            {

            }
            else if (amountFening == 0 && subtotalAmountBam > 0)
            {
                var zeroAmountPaymentEntity = new Payment
                {
                    BookingId = bookingId,
                    Amount = 0,
                    Currency = "bam",
                    StripePaymentIntentId = $"MANUAL_ZERO_AMOUNT_{Guid.NewGuid()}",
                    Status = PaymentStatus.Succeeded,
                    CreatedAt = DateTime.UtcNow,
                    SucceededAt = DateTime.UtcNow
                };
                _context.Payment.Add(zeroAmountPaymentEntity);
                await _context.SaveChangesAsync();
                var zeroAmountDto = _mapper.Map<PaymentDto>(zeroAmountPaymentEntity);
                return (zeroAmountDto, null);
            }


            var intentService = new PaymentIntentService(_stripe);
            PaymentIntent intent = await intentService.CreateAsync(new PaymentIntentCreateOptions
            {
                Amount = amountFening,
                Currency = "bam",
                AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
                {
                    Enabled = true
                },
                Metadata = new Dictionary<string, string>
                {
                    { "BookingId", bookingId.ToString() },
                    { "OriginalAmountBAM", subtotalAmountBam.ToString("F2") },
                    { "DiscountApplied", booking.AppliedDiscount?.Code ?? "None" },
                    { "DiscountPercentage", booking.AppliedDiscount?.DiscountPercentage.ToString("F2") ?? "0" }
                }
            });

            var paymentEntity = new Payment
            {
                BookingId = bookingId,
                Amount = amountFening,
                Currency = "bam",
                StripePaymentIntentId = intent.Id,
                Status = PaymentStatus.Pending,
                CreatedAt = DateTime.UtcNow
            };

            _context.Payment.Add(paymentEntity);
            await _context.SaveChangesAsync();

            var dto = _mapper.Map<PaymentDto>(paymentEntity);
            return (dto, intent.ClientSecret);
        }

        public async Task HandleWebhookAsync(Event ev)
        {
            switch (ev.Type)
            {
                case "payment_intent.succeeded":
                    var succeeded = ev.Data.Object as PaymentIntent;
                    await UpdateStatusAsync(
                        succeeded!.Id,
                        PaymentStatus.Succeeded,
                        succeeded.Created);
                    break;

                case "payment_intent.payment_failed":
                    var failed = ev.Data.Object as PaymentIntent;
                    await UpdateStatusAsync(
                        failed!.Id,
                        PaymentStatus.Failed,
                        failed.Created);
                    break;

                case "charge.refunded":
                    var charge = ev.Data.Object as Charge;
                    if (charge?.PaymentIntentId is not null)
                        await UpdateStatusAsync(
                            charge.PaymentIntentId,
                            PaymentStatus.Refunded,
                            charge.Created);
                    break;
            }
        }


        private async Task UpdateStatusAsync(
            string intentId,
            PaymentStatus newStatus,
            DateTime? stripeTime = null)
        {
            var payment = await _context.Payment
                          .SingleOrDefaultAsync(p => p.StripePaymentIntentId == intentId);

            if (payment == null)
            {
                return;
            }
            payment.Status = newStatus;

            DateTime when = stripeTime ?? DateTime.UtcNow;

            switch (newStatus)
            {
                case PaymentStatus.Succeeded: payment.SucceededAt = when; break;
                case PaymentStatus.Failed: payment.FailedAt = when; break;
                case PaymentStatus.Refunded: payment.RefundedAt = when; break;
            }

            await _context.SaveChangesAsync();
        }
    }
}