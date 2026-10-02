using KeySift;
using Xunit;

namespace KeySift.Tests;

public sealed class EnvDocumentTests
{
    [Fact]
    public void Parse_supports_export_comments_and_quoted_values()
    {
        const string source =
            "# deployment settings\n" +
            "export API_URL=\"https://example.com/#v1\"\n" +
            "PLAIN=value # deployment override\n" +
            "SINGLE='literal # value'\n" +
            "EMPTY=\n";

        var document = EnvDocument.Parse(source, "sample.env");

        Assert.Equal("https://example.com/#v1", document.Entries["API_URL"].Value);
        Assert.Equal("value", document.Entries["PLAIN"].Value);
        Assert.Equal("literal # value", document.Entries["SINGLE"].Value);
        Assert.Equal(string.Empty, document.Entries["EMPTY"].Value);
    }


    [Fact]
    public void Parse_handles_double_quote_escapes_and_trailing_comments()
    {
        const string source =
            "DOUBLE=\"line\\n\\\"quoted\\\"\\\\tail\" # ignored\n" +
            "SINGLE='keep\\nraw' # ignored\n";

        var document = EnvDocument.Parse(source, "quoted.env");

        Assert.Equal("line\n\"quoted\"\\tail", document.Entries["DOUBLE"].Value);
        Assert.Equal("keep\\nraw", document.Entries["SINGLE"].Value);
    }
    [Theory]
    [InlineData("MISSING_SEPARATOR")]
    [InlineData("1INVALID=value")]
    [InlineData("KEY=\"unterminated")]
    [InlineData("KEY=first\nKEY=second")]
    public void Parse_rejects_ambiguous_or_invalid_input(string source)
    {
        var error = Assert.Throws<EnvParseException>(
            () => EnvDocument.Parse(source, "broken.env"));

        Assert.StartsWith("broken.env:", error.Message);
        Assert.DoesNotContain("second", error.Message);
    }
}
