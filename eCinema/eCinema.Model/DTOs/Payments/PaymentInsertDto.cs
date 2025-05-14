using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.Payments
{
    public class PaymentInsertDto
    {
        public int BookingId { get; set; }
        public long Amount { get; set; }
        public string Currency { get; set; }
        public string StripePaymentIntentId { get; set; }
    }
}
