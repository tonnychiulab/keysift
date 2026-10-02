using System.Text.Json;
using KeySift;
using Xunit;

namespace KeySift.Tests;

public sealed class CliTests
{
    [Fact]
    public async Task RunAsync_reports_drift_without_printing_values()
    {
        var directory = Path.Combine(Path.GetTempPath(), $"keysift-tests-{Guid.NewGuid():N}");
        Directory.CreateDirectory(directory);
        try
        {
            var baselinePath = Path.Combine(directory, "baseline.env");
            var candidatePath = Path.Combine(directory, "candidate.env");
            await File.WriteAllTextAsync(baselinePath, "API_TOKEN=old-secret\nOLD_KEY=gone\n");
            await File.WriteAllTextAsync(candidatePath, "API_TOKEN=new-secret\nNEW_KEY=added\n");
            using var output = new StringWriter();
            using var error = new StringWriter();

            var exitCode = await Cli.RunAsync(
                new[] { baselinePath, candidatePath },
                output,
                error);

            Assert.Equal(1, exitCode);
            Assert.Contains("CHANGED                API_TOKEN", output.ToString());
            Assert.Contains("MISSING_FROM_CANDIDATE OLD_KEY", output.ToString());
            Assert.Contains("MISSING_FROM_BASELINE  NEW_KEY", output.ToString());
            Assert.Contains("3 difference(s), 0 matching, 0 ignored", output.ToString());
            Assert.DoesNotContain("old-secret", output.ToString());
            Assert.DoesNotContain("new-secret", output.ToString());
            Assert.Equal(string.Empty, error.ToString());
        }
        finally
        {
            Directory.Delete(directory, recursive: true);
        }
    }

    [Fact]
    public async Task RunAsync_can_emit_json_and_apply_ignore_patterns()
    {
        var directory = Path.Combine(Path.GetTempPath(), $"keysift-tests-{Guid.NewGuid():N}");
        Directory.CreateDirectory(directory);
        try
        {
            var baselinePath = Path.Combine(directory, "baseline.env");
            var candidatePath = Path.Combine(directory, "candidate.env");
            await File.WriteAllTextAsync(baselinePath, "SECRET_TOKEN=old-secret\nVISIBLE=old\n");
            await File.WriteAllTextAsync(candidatePath, "SECRET_TOKEN=new-secret\nVISIBLE=new\n");
            using var output = new StringWriter();
            using var error = new StringWriter();

            var exitCode = await Cli.RunAsync(
                new[] { "--format", "json", "--ignore", "SECRET_*", baselinePath, candidatePath },
                output,
                error);

            Assert.Equal(1, exitCode);
            using var json = JsonDocument.Parse(output.ToString());
            var differences = json.RootElement.GetProperty("differences");
            Assert.Equal(1, differences.GetArrayLength());
            Assert.Equal("VISIBLE", differences[0].GetProperty("key").GetString());
            Assert.Equal("changed", differences[0].GetProperty("status").GetString());
            Assert.Equal(1, json.RootElement.GetProperty("summary").GetProperty("ignored").GetInt32());
            Assert.DoesNotContain("old-secret", output.ToString());
            Assert.DoesNotContain("new-secret", output.ToString());
            Assert.Equal(string.Empty, error.ToString());
        }
        finally
        {
            Directory.Delete(directory, recursive: true);
        }
    }

    [Fact]
    public async Task RunAsync_returns_input_error_without_printing_duplicate_values()
    {
        var directory = Path.Combine(Path.GetTempPath(), $"keysift-tests-{Guid.NewGuid():N}");
        Directory.CreateDirectory(directory);
        try
        {
            var baselinePath = Path.Combine(directory, "baseline.env");
            var candidatePath = Path.Combine(directory, "candidate.env");
            await File.WriteAllTextAsync(baselinePath, "TOKEN=first-secret\nTOKEN=second-secret\n");
            await File.WriteAllTextAsync(candidatePath, "TOKEN=candidate-secret\n");
            using var output = new StringWriter();
            using var error = new StringWriter();

            var exitCode = await Cli.RunAsync(
                new[] { baselinePath, candidatePath },
                output,
                error);

            Assert.Equal(2, exitCode);
            Assert.Equal(string.Empty, output.ToString());
            Assert.Contains("baseline.env:2: duplicate variable 'TOKEN'.", error.ToString());
            Assert.DoesNotContain("first-secret", error.ToString());
            Assert.DoesNotContain("second-secret", error.ToString());
        }
        finally
        {
            Directory.Delete(directory, recursive: true);
        }
    }
}
