using KeySift;
using Xunit;

namespace KeySift.Tests;

public sealed class EnvComparerTests
{
    [Fact]
    public void Compare_reports_sorted_key_statuses_without_secret_values()
    {
        var baseline = EnvDocument.Parse("Z_SHARED=same\nAPI_TOKEN=old\nCACHE_URL=redis-a\n", "baseline.env");
        var candidate = EnvDocument.Parse("Z_SHARED=same\nAPI_TOKEN=new\nNEW_FLAG=enabled\n", "candidate.env");

        var result = EnvComparer.Compare(baseline, candidate);

        Assert.Equal(
            new[]
            {
                new EnvDifference("API_TOKEN", EnvDifferenceKind.Changed),
                new EnvDifference("CACHE_URL", EnvDifferenceKind.MissingFromCandidate),
                new EnvDifference("NEW_FLAG", EnvDifferenceKind.MissingFromBaseline),
            },
            result.Differences);
        Assert.Equal(1, result.MatchingCount);
        Assert.DoesNotContain("old", result.ToString());
        Assert.DoesNotContain("new", result.ToString());
    }

    [Fact]
    public void Compare_ignores_keys_matching_case_sensitive_globs()
    {
        var baseline = EnvDocument.Parse(
            "SECRET_TOKEN=old\nLOCAL1ONLY=old\nVISIBLE=old\n",
            "baseline.env");
        var candidate = EnvDocument.Parse(
            "SECRET_TOKEN=new\nLOCAL1ONLY=new\nVISIBLE=new\n",
            "candidate.env");

        var result = EnvComparer.Compare(
            baseline,
            candidate,
            new[] { "SECRET_*", "LOCAL?ONLY" });

        Assert.Equal(
            new[] { new EnvDifference("VISIBLE", EnvDifferenceKind.Changed) },
            result.Differences);
        Assert.Equal(2, result.IgnoredCount);
    }
}
