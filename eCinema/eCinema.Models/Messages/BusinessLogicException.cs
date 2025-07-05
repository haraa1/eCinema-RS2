using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCinema.Models.Messages
{
    public class BusinessLogicException : Exception
    {
        public BusinessLogicException(string message) : base(message) { }
        public BusinessLogicException(string message, Exception innerException) : base(message, innerException) { }
    }

    public class InvalidDiscountCodeException : BusinessLogicException
    {
        public InvalidDiscountCodeException(string message) : base(message) { }
    }
}
