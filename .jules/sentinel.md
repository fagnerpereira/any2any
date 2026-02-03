## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2026-02-03 - ERB Injection in Static Content
**Vulnerability:** The ERB generator failed to escape `<%` tags in static content, allowing code injection.
**Learning:** Even text-based template formats like ERB are vulnerable to injection if the delimiters are not escaped in static text nodes.
**Prevention:** Always escape format-specific delimiters in static content during code generation.
