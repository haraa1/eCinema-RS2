using System.Threading;
using System.Threading.Tasks;
using EasyNetQ;
using eCinema.Models.Messages;
using MailKit.Net.Smtp;
using MimeKit;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using eCinema.Subscriber;
using MailKit.Security;

public sealed class EmailSubscriber : BackgroundService
{
    private readonly IBus _bus;
    private readonly ILogger<EmailSubscriber> _log;
    private readonly SmtpOptions _smtp;
    private readonly EmailOptions _email;

    public EmailSubscriber(IBus bus,
    IOptions<SmtpOptions> smtpOpt,
    IOptions<EmailOptions> emailOpt,
    ILogger<EmailSubscriber> log)
    {
        _bus = bus;
        _smtp = smtpOpt.Value;
        _email = emailOpt.Value;
        _log = log;

        _log.LogInformation(
        "🔍 SMTP Config Loaded → Host={Host}, Port={Port}, User={User}, StartTLS={StartTls}, Pass={Pass}",
        _smtp.Host,
        _smtp.Port,
        _smtp.User ?? "<no-user>",
        _smtp.UseStartTls,
        _smtp.Pass
    );
    }



    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _log.LogInformation("Email worker listening for UserRegistered messages…");

        await _bus.PubSub.SubscribeAsync<UserRegisteredMessage>(
            "email-svc",
            SendWelcomeMail,
            cfg => {  },
            stoppingToken
        );
    }

    private async Task SendWelcomeMail(UserRegisteredMessage msg, CancellationToken ct)
    {
        _log.LogInformation("→ Preparing to send mail to {Email}", msg.Email);

        _log.LogInformation("Parsing 'From' address: '{FromAddress}' with Subject: '{Subject}'", _email.From, _email.Subject);

        var mime = new MimeMessage();
        mime.From.Add(MailboxAddress.Parse(_email.From));
        mime.To.Add(MailboxAddress.Parse(msg.Email));
        mime.Subject = _email.Subject;
        mime.Body = new TextPart("plain")
        {
            Text = $"Zdravo {msg.UserName},\n\nHvala što ste se registrovali na eCinema! Vaš korisnički račun je uspješno kreiran." +
                   $" Uživajte u pretraživanju i rezervaciji svojih omiljenih filmova." +
                   $"\n\nSrdačan pozdrav,\neCinema tim"
        };

        using var timeoutCts = new CancellationTokenSource(TimeSpan.FromSeconds(30));
        using var linkedCts = CancellationTokenSource.CreateLinkedTokenSource(ct, timeoutCts.Token);

        try
        {
            using var smtp = new SmtpClient();
            var option = _smtp.UseStartTls
                ? SecureSocketOptions.StartTls
                : SecureSocketOptions.None;

            _log.LogInformation("Attempting to connect to SMTP host {Host}:{Port}...", _smtp.Host, _smtp.Port);
            await smtp.ConnectAsync(_smtp.Host, _smtp.Port, option, linkedCts.Token);
            _log.LogInformation("SMTP connection established. Authenticating...");

            if (!string.IsNullOrWhiteSpace(_smtp.User))
            {
                await smtp.AuthenticateAsync(_smtp.User, _smtp.Pass, linkedCts.Token);
                _log.LogInformation("SMTP authentication successful.");
            }

            _log.LogInformation("Sending message...");
            await smtp.SendAsync(mime, linkedCts.Token);
            _log.LogInformation("Message sent. Disconnecting...");
            await smtp.DisconnectAsync(true, linkedCts.Token);

            _log.LogInformation("✅ Mail sent successfully to {Email}", msg.Email);
        }
        catch (OperationCanceledException) when (timeoutCts.IsCancellationRequested)
        {
        }
        catch (Exception ex)
        {
        }
    }



}
