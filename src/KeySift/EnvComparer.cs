namespace KeySift;

public enum EnvDifferenceKind
{
    Changed,
    MissingFromBaseline,
    MissingFromCandidate,
}

public sealed record EnvDifference(string Key, EnvDifferenceKind Kind);

public sealed class EnvComparisonResult
{
    internal EnvComparisonResult(
        IReadOnlyList<EnvDifference> differences,
        int matchingCount,
        int ignoredCount)
    {
        Differences = differences;
        MatchingCount = matchingCount;
        IgnoredCount = ignoredCount;
    }

    public IReadOnlyList<EnvDifference> Differences { get; }

    public int MatchingCount { get; }

    public int IgnoredCount { get; }
}

public static class EnvComparer
{
    public static EnvComparisonResult Compare(
        EnvDocument baseline,
        EnvDocument candidate,
        IReadOnlyList<string>? ignoredPatterns = null)
    {
        ArgumentNullException.ThrowIfNull(baseline);
        ArgumentNullException.ThrowIfNull(candidate);

        var keys = new HashSet<string>(baseline.Entries.Keys, StringComparer.Ordinal);
        keys.UnionWith(candidate.Entries.Keys);

        var orderedKeys = keys.ToArray();
        Array.Sort(orderedKeys, StringComparer.Ordinal);

        var differences = new List<EnvDifference>();
        var matchingCount = 0;
        var ignoredCount = 0;
        foreach (var key in orderedKeys)
        {
            if (IsIgnored(key, ignoredPatterns))
            {
                ignoredCount++;
                continue;
            }

            var inBaseline = baseline.Entries.TryGetValue(key, out var baselineEntry);
            var inCandidate = candidate.Entries.TryGetValue(key, out var candidateEntry);

            if (!inBaseline)
            {
                differences.Add(new EnvDifference(key, EnvDifferenceKind.MissingFromBaseline));
            }
            else if (!inCandidate)
            {
                differences.Add(new EnvDifference(key, EnvDifferenceKind.MissingFromCandidate));
            }
            else if (!string.Equals(baselineEntry!.Value, candidateEntry!.Value, StringComparison.Ordinal))
            {
                differences.Add(new EnvDifference(key, EnvDifferenceKind.Changed));
            }
            else
            {
                matchingCount++;
            }
        }

        return new EnvComparisonResult(differences, matchingCount, ignoredCount);
    }

    private static bool IsIgnored(string key, IReadOnlyList<string>? patterns)
    {
        if (patterns is null)
        {
            return false;
        }

        foreach (var pattern in patterns)
        {
            if (GlobMatches(pattern.AsSpan(), key.AsSpan()))
            {
                return true;
            }
        }

        return false;
    }

    private static bool GlobMatches(ReadOnlySpan<char> pattern, ReadOnlySpan<char> value)
    {
        var patternIndex = 0;
        var valueIndex = 0;
        var starIndex = -1;
        var retryValueIndex = -1;

        while (valueIndex < value.Length)
        {
            if (patternIndex < pattern.Length &&
                (pattern[patternIndex] == '?' || pattern[patternIndex] == value[valueIndex]))
            {
                patternIndex++;
                valueIndex++;
            }
            else if (patternIndex < pattern.Length && pattern[patternIndex] == '*')
            {
                starIndex = patternIndex++;
                retryValueIndex = valueIndex;
            }
            else if (starIndex >= 0)
            {
                patternIndex = starIndex + 1;
                valueIndex = ++retryValueIndex;
            }
            else
            {
                return false;
            }
        }

        while (patternIndex < pattern.Length && pattern[patternIndex] == '*')
        {
            patternIndex++;
        }

        return patternIndex == pattern.Length;
    }
}
