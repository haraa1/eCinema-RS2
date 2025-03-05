using Microsoft.EntityFrameworkCore;
using eCinema.Models;
using eCinema.Services;
using eCinema.Models.Mappings;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddTransient<IMovieService, MovieService>();
builder.Services.AddTransient<ICinemaService,CinemaService>();

// Add services to the container.
builder.Services.AddDbContext<eCinemaDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddAutoMapper(typeof(MovieProfile));
builder.Services.AddAutoMapper(typeof(CinemaProfile));

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
