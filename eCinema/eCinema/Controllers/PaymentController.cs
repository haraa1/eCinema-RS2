using CinemaApp.Domain.Entities;
using eCinema.Models.DTOs.Payments;
using eCinema.Models.DTOs.SeatTypes;
using eCinema.Models.SearchObjects;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stripe;
using eCinema.Models;
using Microsoft.Extensions.Options;

namespace eCinema.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PaymentController : BaseCRUDController<PaymentDto, PaymentSearchObject, PaymentInsertDto, PaymentUpdateDto>
    {
        private readonly IPaymentService _service;
        private readonly StripeClient _stripe;
        private readonly StripeSettings _settings;
        public PaymentController(
            ILogger<BaseController<PaymentDto, PaymentSearchObject>> logger,
            IPaymentService service, IOptions<StripeSettings> opt)
            : base(logger, service)
        {
            _service = service;
            _settings = opt.Value;
        }
        [AllowAnonymous]
        [HttpPost("intent/{bookingId:int}")]
        public async Task<ActionResult> CreateIntent(int bookingId)
        {
            (PaymentDto payment, string clientSecret) =
                await _service.CreateIntentAsync(bookingId);

            return Ok(new
            {
                payment,
                clientSecret,
                publishableKey = _settings.PublishableKey
            });
        }

        [AllowAnonymous]
        [HttpPost("webhook")]
        public async Task<IActionResult> Webhook()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            var sigHeader = Request.Headers["Stripe-Signature"].FirstOrDefault();
            try
            {
                var stripeEvent = EventUtility.ConstructEvent(json, sigHeader, _settings.WebhookSecret);
                await _service.HandleWebhookAsync(stripeEvent);
                return Ok();
            }
            catch (StripeException ex)
            {
                return BadRequest();
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Internal server error processing webhook");
            }
        }





    }
}
