## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-24 - Template Injection in Slim Generator
**Vulnerability:** The Slim generator failed to escape Ruby interpolation sequences `#{` in static content and attributes, and did not properly handle multiline static content.
**Learning:** Slim treats `#{}` within text and attributes as Ruby code to be interpolated. Unescaped input allows arbitrary code execution. Additionally, unindented newlines in static content can introduce new tags (structural injection).
**Prevention:** Always escape backslashes `\` to `\\` and interpolation sequences `#{` to `\#{` (in that order) in all static content and attributes generated for Slim. Ensure multiline static content is split and each line is strictly prefixed with the pipe character `|` and proper indentation.
