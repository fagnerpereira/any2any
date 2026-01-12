## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-24 - Template Injection in ERB Generator
**Vulnerability:** The ERB generator outputted static content as raw text. If the content contained ERB tags (`<% ... %>`), they would be executed as Ruby code when the generated template was rendered (Server-Side Template Injection).
**Learning:** When converting to a template format that mixes text and code (like ERB), "static text" must be escaped if it resembles the format's code delimiters.
**Prevention:** In ERB generation, always replace `<%` with `<%%` in static content to ensure it is treated as a string literal.
