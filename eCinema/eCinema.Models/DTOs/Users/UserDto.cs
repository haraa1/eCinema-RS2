using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.DTOs.Users
{
    public class UserDto
    {
        public int Id { get; set; }
        public string FullName { get; set; } = null!;
        public string UserName { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string? PhoneNumber { get; set; }
        public bool HasPicture { get; set; }
        public string? ProfilePicture { get; set; }
        public string? PreferredLanguage { get; set; }
        public bool Notify { get; set; }
        public List<string> Roles { get; set; } = new List<string>();
    }
}
