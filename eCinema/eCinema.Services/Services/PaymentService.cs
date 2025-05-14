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

namespace eCinema.Services.Services
{
    public class PaymentService : BaseCRUDService<PaymentDto, Payment, BaseSearchObject, PaymentInsertDto, PaymentUpdateDto>, IPaymentService
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

        public async Task<(PaymentDto payment, string clientSecret)> CreateIntentAsync(int bookingId)
        {
            Booking booking = await _context.Bookings
                                        .Include(b => b.Tickets)
                                        .Include(b => b.BookingConcessions)
                                            .ThenInclude(bc => bc.Concession)
                                        .SingleAsync(b => b.Id == bookingId);

            decimal amountBam = booking.Tickets.Sum(t => t.Price)
                              + booking.BookingConcessions.Sum(c => c.Quantity * c.Concession.Price);

            long amountFening = (long)Math.Round(amountBam * 100m, MidpointRounding.AwayFromZero);

            var intentService = new PaymentIntentService(_stripe);
            PaymentIntent intent = await intentService.CreateAsync(new PaymentIntentCreateOptions
            {
                Amount = amountFening,
                Currency = "bam",
                AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
                {
                    Enabled = true
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