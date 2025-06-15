using CinemaApp.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.Payments
{
    public class PaymentDto
    {
        public int Id { get; set; }
        public int BookingId { get; set; }
        public long Amount { get; set; }
        public string Currency { get; set; }
        public string StripePaymentIntentId { get; set; }
        public string StripeChargeId { get; set; }
        public PaymentStatus Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? SucceededAt { get; set; }
        public DateTime? FailedAt { get; set; }
        public DateTime? RefundedAt { get; set; }
    }
}
