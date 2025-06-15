using System;
using System.IO;
using EasyNetQ;
using EasyNetQ.Serialization.SystemTextJson;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using DotNetEnv;
using eCinema.Subscriber;

public class Program
{
    public static async Task Main(string[] args)
    {
        Env.TraversePath().Load();

        await Host.CreateDefaultBuilder(args)
            .ConfigureAppConfiguration((ctx, cfg) =>
            {
                cfg.Sources.Clear();
                cfg.AddEnvironmentVariables();
            })
            .ConfigureLogging(logging =>
            {
                logging.ClearProviders();
                logging.AddConsole();
                logging.SetMinimumLevel(LogLevel.Debug);
            })
            .ConfigureServices((ctx, services) =>
            {
                var smtpSection = ctx.Configuration.GetSection("Smtp");
                var smtpConfig = smtpSection.Get<SmtpOptions>()
                                  ?? throw new InvalidOperationException("Missing [Smtp] section in configuration.");

                if (string.IsNullOrWhiteSpace(smtpConfig.Host))
                    throw new ArgumentException("SMTP Host is not set. Make sure you have 'Smtp__Host' in your .env.", nameof(smtpConfig.Host));
                if (smtpConfig.Port == 0)
                    throw new ArgumentException("SMTP Port is not set. Make sure you have 'Smtp__Port' in your .env.", nameof(smtpConfig.Port));
                if (string.IsNullOrWhiteSpace(smtpConfig.User) ||
                    string.IsNullOrWhiteSpace(smtpConfig.Pass))
                    throw new ArgumentException("SMTP User or Pass is missing. Make sure you have 'Smtp__User' and 'Smtp__Pass' in your .env.", "Smtp__User/Smtp__Pass");

                services.Configure<SmtpOptions>(smtpSection);
                services.Configure<EmailOptions>(ctx.Configuration.GetSection("Email"));

                var rabbitHost = ctx.Configuration["Rabbit:Host"] ?? "localhost";
                services.AddSingleton<IBus>(_ =>
                    RabbitHutch.CreateBus($"host={rabbitHost}", cfg => cfg.EnableSystemTextJson())
                );

                services.AddHostedService<EmailSubscriber>();
            })
            .RunConsoleAsync();
    }
}
