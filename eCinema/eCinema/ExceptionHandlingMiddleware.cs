using eCinema.Models.Messages;
using System.Net;
using System.Text.Json;

namespace eCinema
{
    public class ExceptionHandlingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionHandlingMiddleware> _logger;

        public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An unhandled exception occurred");
                await HandleExceptionAsync(context, ex);
            }
        }

        private static async Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            var response = context.Response;
            response.ContentType = "application/json";

            var errorResponse = new
            {
                message = exception.Message,
                statusCode = GetStatusCode(exception),
                timestamp = DateTime.UtcNow
            };

            response.StatusCode = errorResponse.statusCode;

            var jsonResponse = JsonSerializer.Serialize(errorResponse);
            await response.WriteAsync(jsonResponse);
        }

        private static int GetStatusCode(Exception exception)
        {
            return exception switch
            {
                ArgumentException => (int)HttpStatusCode.BadRequest,
                InvalidDiscountCodeException => (int)HttpStatusCode.BadRequest,  // Add your custom exception
                BusinessLogicException => (int)HttpStatusCode.BadRequest,        // Add your custom exception
                UnauthorizedAccessException => (int)HttpStatusCode.Unauthorized,
                KeyNotFoundException => (int)HttpStatusCode.NotFound,
                _ => (int)HttpStatusCode.InternalServerError
            };
        }
    }
}
