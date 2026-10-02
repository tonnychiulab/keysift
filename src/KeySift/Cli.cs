using System.Text;
using System.Text.Json;

namespace KeySift;

public static class Cli
{
    private const string Usage = "" +
        "Usage: keysift [options] <baseline.env> <candidate.env>\n" +
        "\n" +
        "Options:\n" +
        "  --format <text|json>  Output format (default: text)\n" +
        "  --ignore <glob>       Ignore matching keys; repeatable (* and ? supported)\n" +
        "  --help, -h            Show help\n" +
        "  --version             Show version";

    public static async Task<int> RunAsync(
        string[] args,
        TextWriter output,
        TextWriter error,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(args);
        ArgumentNullException.ThrowIfNull(output);
        ArgumentNullException.ThrowIfNull(error);

        if (!CliOptions.TryParse(args, out var options, out var optionError))
        {
            await error.WriteLineAsync($"keysift: {optionError}");
            await error.WriteLineAsync("Try 'keysift --help' for usage.");
            return 2;
        }

        if (options!.ShowHelp)
        {
            await output.WriteLineAsync(Usage);
            return 0;
        }

        if (options.ShowVersion)
        {
            var version = typeof(Cli).Assembly.GetName().Version!;
            await output.WriteLineAsync($"keysift {version.Major}.{version.Minor}.{version.Build}");
            return 0;
        }

        try
        {
            var baselineContent = await File.ReadAllTextAsync(options.BaselinePath!, cancellationToken);
            var candidateContent = await File.ReadAllTextAsync(options.CandidatePath!, cancellationToken);
            var baseline = EnvDocument.Parse(baselineContent, options.BaselinePath!);
            var candidate = EnvDocument.Parse(candidateContent, options.CandidatePath!);
            var result = EnvComparer.Compare(baseline, candidate, options.IgnoredPatterns);

            if (options.Format == OutputFormat.Json)
            {
                await WriteJsonAsync(output, result);
            }
            else
            {
                await WriteTextAsync(output, result);
            }

            return result.Differences.Count == 0 ? 0 : 1;
        }
        catch (EnvParseException exception)
        {
            await error.WriteLineAsync($"keysift: {exception.Message}");
            return 2;
        }
        catch (IOException exception)
        {
            await error.WriteLineAsync($"keysift: {exception.Message}");
            return 2;
        }
        catch (UnauthorizedAccessException exception)
        {
            await error.WriteLineAsync($"keysift: {exception.Message}");
            return 2;
        }
    }

    private static async Task WriteTextAsync(TextWriter output, EnvComparisonResult result)
    {
        foreach (var difference in result.Differences)
        {
            await output.WriteLineAsync(
                $"{ToTextLabel(difference.Kind).PadRight(22)} {difference.Key}");
        }

        await output.WriteLineAsync();
        await output.WriteLineAsync(
            $"{result.Differences.Count} difference(s), " +
            $"{result.MatchingCount} matching, {result.IgnoredCount} ignored");
    }

    private static async Task WriteJsonAsync(TextWriter output, EnvComparisonResult result)
    {
        using var stream = new MemoryStream();
        using (var writer = new Utf8JsonWriter(stream, new JsonWriterOptions { Indented = true }))
        {
            writer.WriteStartObject();
            writer.WriteStartArray("differences");
            foreach (var difference in result.Differences)
            {
                writer.WriteStartObject();
                writer.WriteString("key", difference.Key);
                writer.WriteString("status", ToJsonLabel(difference.Kind));
                writer.WriteEndObject();
            }

            writer.WriteEndArray();
            writer.WriteStartObject("summary");
            writer.WriteNumber("differences", result.Differences.Count);
            writer.WriteNumber("matching", result.MatchingCount);
            writer.WriteNumber("ignored", result.IgnoredCount);
            writer.WriteEndObject();
            writer.WriteEndObject();
        }

        await output.WriteLineAsync(Encoding.UTF8.GetString(stream.GetBuffer(), 0, checked((int)stream.Length)));
    }

    private static string ToTextLabel(EnvDifferenceKind kind) => kind switch
    {
        EnvDifferenceKind.Changed => "CHANGED",
        EnvDifferenceKind.MissingFromBaseline => "MISSING_FROM_BASELINE",
        EnvDifferenceKind.MissingFromCandidate => "MISSING_FROM_CANDIDATE",
        _ => throw new ArgumentOutOfRangeException(nameof(kind), kind, null),
    };

    private static string ToJsonLabel(EnvDifferenceKind kind) => kind switch
    {
        EnvDifferenceKind.Changed => "changed",
        EnvDifferenceKind.MissingFromBaseline => "missing_from_baseline",
        EnvDifferenceKind.MissingFromCandidate => "missing_from_candidate",
        _ => throw new ArgumentOutOfRangeException(nameof(kind), kind, null),
    };

    private enum OutputFormat
    {
        Text,
        Json,
    }

    private sealed class CliOptions
    {
        private CliOptions()
        {
        }

        public string? BaselinePath { get; private set; }

        public string? CandidatePath { get; private set; }

        public OutputFormat Format { get; private set; }

        public List<string> IgnoredPatterns { get; } = new();

        public bool ShowHelp { get; private set; }

        public bool ShowVersion { get; private set; }

        public static bool TryParse(string[] args, out CliOptions? options, out string? error)
        {
            options = new CliOptions();
            error = null;
            var paths = new List<string>(capacity: 2);
            var parseOptions = true;

            for (var index = 0; index < args.Length; index++)
            {
                var argument = args[index];
                if (parseOptions && argument == "--")
                {
                    parseOptions = false;
                }
                else if (parseOptions && argument is "--help" or "-h")
                {
                    options.ShowHelp = true;
                }
                else if (parseOptions && argument == "--version")
                {
                    options.ShowVersion = true;
                }
                else if (parseOptions && argument == "--format")
                {
                    if (!TryTakeValue(args, ref index, "--format", out var value, out error))
                    {
                        options = null;
                        return false;
                    }

                    if (value == "text")
                    {
                        options.Format = OutputFormat.Text;
                    }
                    else if (value == "json")
                    {
                        options.Format = OutputFormat.Json;
                    }
                    else
                    {
                        error = "--format must be 'text' or 'json'.";
                        options = null;
                        return false;
                    }
                }
                else if (parseOptions && argument == "--ignore")
                {
                    if (!TryTakeValue(args, ref index, "--ignore", out var value, out error))
                    {
                        options = null;
                        return false;
                    }

                    if (value!.Length == 0)
                    {
                        error = "--ignore cannot be empty.";
                        options = null;
                        return false;
                    }

                    options.IgnoredPatterns.Add(value);
                }
                else if (parseOptions && argument.Length > 0 && argument[0] == '-')
                {
                    error = $"unknown option '{argument}'.";
                    options = null;
                    return false;
                }
                else
                {
                    paths.Add(argument);
                }
            }

            if (options.ShowHelp || options.ShowVersion)
            {
                return true;
            }

            if (paths.Count != 2)
            {
                error = "exactly two .env paths are required.";
                options = null;
                return false;
            }

            options.BaselinePath = paths[0];
            options.CandidatePath = paths[1];
            return true;
        }

        private static bool TryTakeValue(
            string[] args,
            ref int index,
            string option,
            out string? value,
            out string? error)
        {
            if (index + 1 >= args.Length)
            {
                value = null;
                error = $"{option} requires a value.";
                return false;
            }

            value = args[++index];
            error = null;
            return true;
        }
    }
}
