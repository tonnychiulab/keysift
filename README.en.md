# KeySift

[正體中文](README.md) · [English](README.en.md) · [日本語](README.ja.md)

KeySift is a command-line tool for safely detecting configuration drift between `.env` files. It prints variable names and difference statuses—**never values**—which makes it suitable for local checks, pre-deployment validation, and CI.

## Features

- Detects added, removed, and changed environment variables.
- Reveals key names only, never passwords, tokens, or other values.
- Provides human-readable text and stable JSON output.
- Supports repeatable, case-sensitive `*`/`?` glob ignore rules.
- Uses distinct exit codes for equality, drift, and input errors.
- Has no third-party runtime dependencies.

## Quick start

Requires the [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0).

```console
dotnet run --project src/KeySift -- .env.production .env.staging
```

Example output:

```text
CHANGED                API_TOKEN
MISSING_FROM_CANDIDATE LEGACY_ENDPOINT
MISSING_FROM_BASELINE  NEW_FEATURE_FLAG

3 difference(s), 8 matching, 0 ignored
```

### Install as a global tool

```console
dotnet pack src/KeySift -c Release -o artifacts
dotnet tool install --global --add-source ./artifacts KeySift.Tool
keysift .env.production .env.staging
```

## Usage

```text
Usage: keysift [options] <baseline.env> <candidate.env>

Options:
  --format <text|json>  Output format (default: text)
  --ignore <glob>       Ignore matching keys; repeatable (* and ? supported)
  --help, -h            Show help
  --version             Show version
```

Use `--` to stop option parsing when a path begins with `-`:

```console
keysift --ignore "LOCAL_*" --ignore "*_DEBUG" baseline.env candidate.env
keysift --format json baseline.env candidate.env > drift.json
keysift -- -baseline.env -candidate.env
```

Glob matching is case-sensitive. `*` matches any number of characters and `?` matches one character.

### Exit codes

| Code | Meaning |
|---:|---|
| `0` | Files match after ignores, or `--help`/`--version` was shown |
| `1` | Configuration drift was found |
| `2` | Command-line, file access, or `.env` syntax error |

### JSON format

```json
{
  "differences": [
    {
      "key": "API_TOKEN",
      "status": "changed"
    }
  ],
  "summary": {
    "differences": 1,
    "matching": 8,
    "ignored": 2
  }
}
```

`status` is `changed`, `missing_from_baseline`, or `missing_from_candidate`.

## Supported `.env` syntax

- Blank lines and comments beginning with `#`.
- `KEY=VALUE` and optional `export KEY=VALUE` forms.
- Portable key names: `[A-Za-z_][A-Za-z0-9_]*`.
- Unquoted, single-quoted, and double-quoted values.
- Trailing comments on unquoted values when preceded by whitespace.
- Comments after quoted values; `\n`, `\r`, `\t`, `\"`, and `\\` escapes inside double quotes.
- Duplicate keys, invalid key names, and unterminated quotes are rejected with exit code `2` to avoid ambiguous comparisons.

Comparison uses case-sensitive ordinal semantics. KeySift does not interpolate `$VARIABLE` references or read the current process environment.

## Security boundary

KeySift does not write values to standard output, standard error, or JSON. Error messages may include file paths, line numbers, and key names. Input contents must still be read into process memory, so protect source files, process memory, and CI workspaces. Never commit real `.env` files.

Report security issues privately as described in [SECURITY.md](SECURITY.md).

## Development

```console
dotnet restore KeySift.sln
dotnet build KeySift.sln -c Release --no-restore
dotnet test KeySift.sln -c Release --no-build
dotnet pack src/KeySift -c Release --no-build -o artifacts
```

## License

[MIT](LICENSE)
