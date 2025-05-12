using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.Users
{
    public class UserUpdateDto
    {
        public string? Email { get; set; }
        public string? Password { get; set; }
        public string? ConfirmPassword { get; set; }
        public string? PhoneNumber { get; set; }
        public string? PreferredLanguage { get; set; }
        public List<int>? RoleIds { get; set; }
    }
}
