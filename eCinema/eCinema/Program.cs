using Microsoft.EntityFrameworkCore;
using eCinema.Models;
using eCinema.Models.Mappings;
using eCinema.Services.Services;
using eCinema.Services.Interfaces;
using Microsoft.AspNetCore.Authentication;
using Microsoft.OpenApi.Models;
using eCinema.Authentication;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddTransient<IMovieService, MovieService>();
builder.Services.AddTransient<ICinemaService,CinemaService>();
builder.Services.AddTransient<IActorService, ActorService>();
builder.Services.AddTransient<IGenreService, GenreService>();
builder.Services.AddTransient<ICinemaHallService, CinemaHallService>();
builder.Services.AddTransient<IConcessionService, ConcessionService>();
builder.Services.AddTransient<ISeatService, SeatService>();
builder.Services.AddTransient<ISeatTypeService, SeatTypeService>();
builder.Services.AddTransient<IShowtimeService, ShowtimeService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IRoleService, RoleService>();


// Add services to the container.
builder.Services.AddDbContext<eCinemaDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddAutoMapper(typeof(MovieProfile));
builder.Services.AddAutoMapper(typeof(CinemaProfile));
builder.Services.AddAutoMapper(typeof(UserProfile));
builder.Services.AddAutoMapper(typeof(ShowtimeProfile));


builder.Services.AddControllers();

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("basicAuth", new Microsoft.OpenApi.Models.OpenApiSecurityScheme()
    {
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "basic"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference{Type = ReferenceType.SecurityScheme, Id = "basicAuth"}
            },
            new string[]{}
    } });

});
builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseCors("AllowFlutterApps"); // Enable CORS with the defined policy

app.UseAuthorization();

app.MapControllers();

app.Run();
