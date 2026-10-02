using System.Collections.ObjectModel;
using System.Text;

namespace KeySift;

public sealed record EnvEntry(string Key, string Value, int LineNumber);

public sealed class EnvParseException : FormatException
{
    public EnvParseException(string sourceName, int lineNumber, string reason)
        : base($"{sourceName}:{lineNumber}: {reason}")
    {
        SourceName = sourceName;
        LineNumber = lineNumber;
    }

    public string SourceName { get; }

    public int LineNumber { get; }
}

public sealed class EnvDocument
{
    private EnvDocument(Dictionary<string, EnvEntry> entries)
    {
        Entries = new ReadOnlyDictionary<string, EnvEntry>(entries);
    }

    public IReadOnlyDictionary<string, EnvEntry> Entries { get; }

    public static EnvDocument Parse(string content, string sourceName)
    {
        ArgumentNullException.ThrowIfNull(content);
        if (string.IsNullOrWhiteSpace(sourceName))
        {
            throw new ArgumentException("A source name is required.", nameof(sourceName));
        }

        var entries = new Dictionary<string, EnvEntry>(StringComparer.Ordinal);
        using var reader = new StringReader(content);

        var lineNumber = 0;
        while (reader.ReadLine() is { } line)
        {
            lineNumber++;
            var candidate = line.Trim();
            if (candidate.Length == 0 || candidate[0] == '#')
            {
                continue;
            }

            if (candidate.StartsWith("export ", StringComparison.Ordinal))
            {
                candidate = candidate[7..].TrimStart();
            }

            var separator = candidate.IndexOf('=');
            if (separator < 1)
            {
                throw new EnvParseException(sourceName, lineNumber, "expected KEY=VALUE.");
            }

            var key = candidate[..separator].Trim();
            if (!IsPortableKey(key))
            {
                throw new EnvParseException(sourceName, lineNumber, "invalid variable name.");
            }

            if (entries.ContainsKey(key))
            {
                throw new EnvParseException(sourceName, lineNumber, $"duplicate variable '{key}'.");
            }

            var value = ParseValue(candidate[(separator + 1)..], sourceName, lineNumber);
            entries.Add(key, new EnvEntry(key, value, lineNumber));
        }

        return new EnvDocument(entries);
    }

    private static bool IsPortableKey(string key)
    {
        if (key.Length == 0 || (key[0] != '_' && !IsAsciiLetter(key[0])))
        {
            return false;
        }

        for (var index = 1; index < key.Length; index++)
        {
            if (key[index] != '_' && !IsAsciiLetter(key[index]) && !IsAsciiDigit(key[index]))
            {
                return false;
            }
        }

        return true;
    }

    private static bool IsAsciiLetter(char value) =>
        value is >= 'A' and <= 'Z' or >= 'a' and <= 'z';

    private static bool IsAsciiDigit(char value) => value is >= '0' and <= '9';

    private static string ParseValue(string source, string sourceName, int lineNumber)
    {
        var value = source.Trim();
        if (value.Length > 0 && (value[0] == '\'' || value[0] == '"'))
        {
            var quote = value[0];
            var closingQuote = FindClosingQuote(value, quote);
            if (closingQuote < 0)
            {
                throw new EnvParseException(sourceName, lineNumber, "unterminated quoted value.");
            }

            var trailing = value[(closingQuote + 1)..].TrimStart();
            if (trailing.Length > 0 && trailing[0] != '#')
            {
                throw new EnvParseException(
                    sourceName,
                    lineNumber,
                    "unexpected characters after quoted value.");
            }

            var quotedValue = value.AsSpan(1, closingQuote - 1);
            return quote == '"' ? DecodeDoubleQuoted(quotedValue) : quotedValue.ToString();
        }

        for (var index = 1; index < value.Length; index++)
        {
            if (value[index] == '#' && char.IsWhiteSpace(value[index - 1]))
            {
                return value[..index].TrimEnd();
            }
        }

        return value;
    }

    private static int FindClosingQuote(string value, char quote)
    {
        for (var index = 1; index < value.Length; index++)
        {
            if (quote == '"' && value[index] == '\\' && index + 1 < value.Length)
            {
                index++;
            }
            else if (value[index] == quote)
            {
                return index;
            }
        }

        return -1;
    }

    private static string DecodeDoubleQuoted(ReadOnlySpan<char> value)
    {
        var escape = value.IndexOf('\\');
        if (escape < 0)
        {
            return value.ToString();
        }

        var decoded = new StringBuilder(value.Length);
        decoded.Append(value[..escape]);
        for (var index = escape; index < value.Length; index++)
        {
            if (value[index] != '\\' || index + 1 >= value.Length)
            {
                decoded.Append(value[index]);
                continue;
            }

            var escaped = value[++index];
            switch (escaped)
            {
                case 'n':
                    decoded.Append('\n');
                    break;
                case 'r':
                    decoded.Append('\r');
                    break;
                case 't':
                    decoded.Append('\t');
                    break;
                case '"':
                    decoded.Append('"');
                    break;
                case '\\':
                    decoded.Append('\\');
                    break;
                default:
                    decoded.Append('\\');
                    decoded.Append(escaped);
                    break;
            }
        }

        return decoded.ToString();
    }
}
