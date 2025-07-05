using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc;

namespace eCinema.Filters
{
    public sealed class BadInputToBadRequestFilter : IExceptionFilter
    {
        public void OnException(ExceptionContext ctx)
        {
            if (ctx.Exception is ArgumentException ex)
            {
                ctx.Result = new BadRequestObjectResult(new { message = ex.Message });
                ctx.ExceptionHandled = true;
            }
        }
    }
}
