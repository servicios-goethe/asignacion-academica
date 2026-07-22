namespace AsignacionAcademica.Api.Tests;

public sealed class HealthResponseTests
{
    [Fact]
    public void Health_response_has_a_stable_service_contract()
    {
        var timestamp = DateTimeOffset.UtcNow;
        var response = new HealthResponse("ok", "asignacion-academica-api", "0.1.0", timestamp);

        Assert.Equal("ok", response.Status);
        Assert.Equal("asignacion-academica-api", response.Service);
        Assert.Equal("0.1.0", response.Version);
        Assert.Equal(timestamp, response.TimestampUtc);
    }
}
