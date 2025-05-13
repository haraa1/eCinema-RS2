using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Messages
{
    public record UserRegisteredMessage(int UserId, string Email, string UserName, DateTime RegisteredAtUtc);
}
