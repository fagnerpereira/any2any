## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-10-23 - SSTI in ERB Generator
**Vulnerability:** The ERB generator failed to escape ERB tags (`<%`) in static content, allowing malicious templates to inject arbitrary Ruby code into generated ERB files.
**Learning:** Static content in IR must be escaped according to the *target* format's rules. For ERB, this means escaping `<%` even in "plain text" sections, as the ERB engine processes the entire file.
**Prevention:** Implement `escape_erb_tags` (escaping `<%` to `<%%`) and ensure `generate_static_content` uses it. Verify all generators escape their specific control characters in static text.
