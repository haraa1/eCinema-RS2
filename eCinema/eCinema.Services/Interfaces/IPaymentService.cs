using eCinema.Models.DTOs.Payments;
using eCinema.Models.DTOs.SeatTypes;
using eCinema.Models.SearchObjects;
using Stripe;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Services.Interfaces
{
    public interface IPaymentService : ICRUDService<PaymentDto, BaseSearchObject, PaymentInsertDto, PaymentUpdateDto>
    {
        Task<(PaymentDto payment, string clientSecret)> CreateIntentAsync(int bookingId);
        Task HandleWebhookAsync(Event stripeEvent);
    }
}
