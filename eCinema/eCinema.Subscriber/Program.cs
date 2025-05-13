using System;
using EasyNetQ;
using EasyNetQ.Serialization.SystemTextJson;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using eCinema.Subscriber;

await Host.CreateDefaultBuilder(args)
    .ConfigureAppConfiguration((ctx, cfg) =>
    {
        cfg.SetBasePath(AppContext.BaseDirectory)
           .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
           .AddEnvironmentVariables();
    })
    .ConfigureLogging(logging =>
    {
        logging.ClearProviders();
        logging.AddConsole();
        logging.SetMinimumLevel(LogLevel.Debug);
    })
    .ConfigureServices((ctx, services) =>
    {
        services.Configure<SmtpOptions>(ctx.Configuration.GetSection("Smtp"));
        services.Configure<EmailOptions>(ctx.Configuration.GetSection("Email"));

        var rabbitHost = ctx.Configuration["Rabbit:Host"] ?? "localhost";
        services.AddSingleton<IBus>(_ =>
            RabbitHutch.CreateBus(
                $"host={rabbitHost}",
                cfg => cfg.EnableSystemTextJson()
            )
        );

        services.AddHostedService<EmailSubscriber>();
    })
    .RunConsoleAsync();
