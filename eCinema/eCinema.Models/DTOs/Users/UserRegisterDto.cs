using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.Users
{
    public class UserRegisterDto
    {
        [Required, StringLength(50)]
        public string FullName { get; set; } = null!;
        [Required, StringLength(50)]
        public string UserName { get; set; } = null!;

        [Required, EmailAddress]
        public string Email { get; set; } = null!;

        [Required, MinLength(6)]
        public string Password { get; set; } = null!;

        [Compare(nameof(Password))]
        public string ConfirmPassword { get; set; } = null!;

        public string? PhoneNumber { get; set; }
    }
}
