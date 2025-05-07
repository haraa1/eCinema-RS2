using eCinema.Models.Entities;
using System;

namespace CinemaApp.Domain.Entities
{
    public class Payment
    {
        public int Id { get; set; }
        public int BookingId { get; set; }
        public Booking Booking { get; set; }

        public long Amount { get; set; }
        public string Currency { get; set; } = "bam";

        public string StripePaymentIntentId { get; set; }
        public string StripeChargeId { get; set; }

        public PaymentStatus Status { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? SucceededAt { get; set; }
        public DateTime? FailedAt { get; set; }
        public DateTime? RefundedAt { get; set; }
    }

    public enum PaymentStatus
    {
        Pending = 0,
        Succeeded = 1,
        Failed = 2,
        Refunded = 3
    }

}
