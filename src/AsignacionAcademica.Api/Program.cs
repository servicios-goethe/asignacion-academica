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

var app = builder.Build();

app.UseHttpsRedirection();
app.UseCors("Frontend");
app.UseDefaultFiles();
app.UseStaticFiles();

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

public partial class Program;
