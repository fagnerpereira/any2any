## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-24 - ERB Server-Side Template Injection (SSTI)
**Vulnerability:** The ERB generator did not escape `<%` tags in static content, allowing malicious input to inject executable Ruby code into the generated template.
**Learning:** Even when generating "text-based" templates like ERB, the template engine's delimiters (`<%`, `<%=`, etc.) are control characters that must be escaped to treat content as data, not code.
**Prevention:** Explicitly escape template delimiters (e.g., convert `<%` to `<%%` in ERB) in all static content paths during generation.
