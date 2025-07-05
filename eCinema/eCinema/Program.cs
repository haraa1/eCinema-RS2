using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.OpenApi.Models;
using Microsoft.AspNetCore.Authentication;
using DotNetEnv;
using EasyNetQ;
using Stripe;

using eCinema.Models;
using eCinema.Models.Mappings;
using eCinema.Services.Services;
using eCinema.Services.Interfaces;
using eCinema.Services.Recommendations;
using eCinema.Data.Seeding;
using eCinema.Authentication;
using eCinema.Filters;
using eCinema;

var projectRoot = AppContext.BaseDirectory;

Env.Load();


var builder = WebApplication.CreateBuilder(args);
builder.Configuration.AddEnvironmentVariables();

builder.Services.AddTransient<IMovieService, MovieService>();
builder.Services.AddTransient<ICinemaService, CinemaService>();
builder.Services.AddTransient<IActorService, ActorService>();
builder.Services.AddTransient<IGenreService, GenreService>();
builder.Services.AddTransient<ICinemaHallService, CinemaHallService>();
builder.Services.AddTransient<IConcessionService, ConcessionService>();
builder.Services.AddTransient<ISeatService, SeatService>();
builder.Services.AddTransient<ISeatTypeService, SeatTypeService>();
builder.Services.AddTransient<IShowtimeService, ShowtimeService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IRoleService, RoleService>();
builder.Services.AddTransient<ITicketService, TicketService>();
builder.Services.AddTransient<ITicketTypeService, TicketTypeService>();
builder.Services.AddTransient<IBookingService, BookingService>();
builder.Services.AddTransient<IBookingConcessionsService, BookingConcessionsService>();
builder.Services.AddTransient<IPaymentService, PaymentService>();
builder.Services.AddTransient<IDiscountService, eCinema.Services.Services.DiscountService>();
builder.Services.AddScoped<IRecommendationService, RecommendationService>();
builder.Services.AddHttpContextAccessor();

var rabbitHost = builder.Configuration["Rabbit:Host"] ?? "localhost";
builder.Services.AddSingleton<IBus>(_ =>
    RabbitHutch.CreateBus($"host={rabbitHost}", cfg => cfg.EnableSystemTextJson()));


builder.Services.AddDbContext<eCinemaDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddAutoMapper(typeof(MovieProfile));
builder.Services.AddAutoMapper(typeof(CinemaProfile));
builder.Services.AddAutoMapper(typeof(UserProfile));
builder.Services.AddAutoMapper(typeof(ShowtimeProfile));
builder.Services.AddAutoMapper(typeof(TicketTypeProfile));
builder.Services.AddAutoMapper(typeof(BookingProfile));
builder.Services.AddAutoMapper(typeof(TicketProfile));
builder.Services.AddAutoMapper(typeof(PaymentProfile));
builder.Services.AddAutoMapper(typeof(BookingConcessionsProfile));

builder.Services.Configure<StripeSettings>(builder.Configuration.GetSection("Stripe"));

var stripeConfig = builder.Configuration.GetSection("Stripe").Get<StripeSettings>()
                    ?? throw new InvalidOperationException("Stripe configuration section is missing.");

if (string.IsNullOrWhiteSpace(stripeConfig.SecretKey))
    throw new ArgumentException("Stripe SecretKey is not set. Make sure you have 'Stripe__SecretKey' in your environment.", nameof(stripeConfig.SecretKey));

if (string.IsNullOrWhiteSpace(stripeConfig.PublishableKey) ||
    string.IsNullOrWhiteSpace(stripeConfig.WebhookSecret))
{
    throw new ArgumentException("Missing Stripe PublishableKey or WebhookSecret in configuration.");
}

builder.Services.AddSingleton<StripeClient>(_ => new StripeClient(stripeConfig.SecretKey));
builder.Services.AddControllers(opts =>
    opts.Filters.Add<BadInputToBadRequestFilter>());
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("basicAuth", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http,
        Scheme = "basic"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                { Type = ReferenceType.SecurityScheme, Id = "basicAuth" }
            },
            Array.Empty<string>()
        }
    });
});
builder.Services.AddAuthentication("BasicAuthentication")
       .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>(
           "BasicAuthentication", null);



var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "eCinema API V1");

    c.RoutePrefix = string.Empty;
});
app.UseMiddleware<ExceptionHandlingMiddleware>();

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var dbContext = services.GetRequiredService<eCinemaDbContext>();
        var webHostEnvironment = services.GetRequiredService<IWebHostEnvironment>();
        string webRootPath = webHostEnvironment.WebRootPath;

        await dbContext.Database.MigrateAsync();
        await DataSeeder.SeedAsync(dbContext, webRootPath);
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred during database seeding.");
    }
}

app.Run();
