using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models
{
    public class StripeSettings
    {
        public string SecretKey { get; init; } = default!;
        public string PublishableKey { get; init; } = default!;
        public string WebhookSecret { get; init; } = default!;
    }
}
