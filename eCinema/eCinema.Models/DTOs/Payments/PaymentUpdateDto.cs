using CinemaApp.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.Payments
{
    public class PaymentUpdateDto
    {
        public PaymentStatus Status { get; set; }
    }
}
