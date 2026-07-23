using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.Google;

var builder = WebApplication.CreateBuilder(args);

var allowedOrigins = builder.Configuration
    .GetSection("Frontend:AllowedOrigins")
    .Get<string[]>() ?? ["http://localhost:5173"];

builder.Services.AddCors(options =>
{
    options.AddPolicy("Frontend", policy =>
    {
        policy.WithOrigins(allowedOrigins)
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = CookieAuthenticationDefaults.AuthenticationScheme;
    options.DefaultSignInScheme = CookieAuthenticationDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = GoogleDefaults.AuthenticationScheme;
})
.AddCookie(options =>
{
    options.Cookie.Name = "asigacad.auth";
    options.Cookie.HttpOnly = true;
    options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    options.Cookie.SameSite = SameSiteMode.Lax;
    options.LoginPath = "/auth/login";
    options.AccessDeniedPath = "/auth/denied";
})
.AddGoogle(options =>
{
    options.ClientId = builder.Configuration["Authentication:Google:ClientId"] ?? string.Empty;
    options.ClientSecret = builder.Configuration["Authentication:Google:ClientSecret"] ?? string.Empty;
    options.CallbackPath = "/auth/google-callback";
    options.SaveTokens = false;
    options.Scope.Add("openid");
    options.Scope.Add("profile");
    options.Scope.Add("email");
    options.Events.OnCreatingTicket = context =>
    {
        var email = context.Principal?.FindFirstValue(ClaimTypes.Email)
            ?? context.Principal?.FindFirstValue("email");
        var allowedDomain = context.HttpContext.RequestServices
            .GetRequiredService<IConfiguration>()["Authentication:AllowedDomain"] ?? "goethe.edu.ar";

        if (string.IsNullOrWhiteSpace(email)
            || !email.EndsWith($"@{allowedDomain}", StringComparison.OrdinalIgnoreCase))
        {
            context.Fail("Only institutional accounts are allowed.");
        }

        return Task.CompletedTask;
    };
});

var app = builder.Build();

app.UseHttpsRedirection();
app.UseCors("Frontend");
app.UseAuthentication();
app.UseAuthorization();
app.UseDefaultFiles();
app.UseStaticFiles();

app.MapGet("/auth/login", (HttpContext httpContext) =>
{
    var returnUrl = httpContext.Request.Query["returnUrl"].ToString();
    if (string.IsNullOrWhiteSpace(returnUrl) || !returnUrl.StartsWith('/'))
    {
        returnUrl = "/";
    }

    return Results.Challenge(
        new AuthenticationProperties { RedirectUri = returnUrl },
        [GoogleDefaults.AuthenticationScheme]);
});

app.MapGet("/auth/me", (ClaimsPrincipal user) =>
{
    if (user.Identity?.IsAuthenticated != true)
    {
        return Results.Unauthorized();
    }

    return Results.Ok(new AuthenticatedUserResponse(
        user.FindFirstValue(ClaimTypes.Email) ?? string.Empty,
        user.FindFirstValue(ClaimTypes.GivenName) ?? string.Empty,
        user.FindFirstValue(ClaimTypes.Surname) ?? string.Empty));
});

app.MapPost("/auth/logout", async (HttpContext httpContext) =>
{
    await httpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
    return Results.NoContent();
});

app.MapGet("/healthz", (IConfiguration configuration) =>
{
    var version = configuration["Application:Version"] ?? "0.1.0";

    return Results.Ok(new HealthResponse(
        "ok",
        "asignacion-academica-api",
        version,
        DateTimeOffset.UtcNow));
});

app.MapGet("/api/config", (IConfiguration configuration, IWebHostEnvironment environment) =>
{
    return Results.Ok(new AppConfigResponse(
        configuration["Application:Name"] ?? "Asignacion Academica",
        configuration["Application:Version"] ?? "0.1.0",
        environment.EnvironmentName,
        ["google-sso", "availability", "academic-structure", "untis-export"]));
});

app.MapFallbackToFile("index.html");

app.Run();

public sealed record HealthResponse(
    string Status,
    string Service,
    string Version,
    DateTimeOffset TimestampUtc);

public sealed record AppConfigResponse(
    string ApplicationName,
    string Version,
    string Environment,
    string[] PlannedCapabilities);

public sealed record AuthenticatedUserResponse(
    string Email,
    string GivenName,
    string Surname);

public partial class Program;
