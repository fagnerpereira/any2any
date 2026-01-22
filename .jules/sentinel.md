## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-24 - Template Injection in Slim Generator
**Vulnerability:** The Slim generator allowed Ruby code execution via interpolation (`#{...}`) in static content and attributes, and HTML injection via multiline static content.
**Learning:** In indentation-based template languages like Slim, newline characters in static content can break out of the text context and form new elements. Also, "static" text in Slim supports interpolation by default, requiring explicit escaping (`\#{`).
**Prevention:** Always escape interpolation sequences in static text (e.g. `#{` -> `\#{`). When generating text blocks in indentation-based languages, ensure every line is explicitly marked as text (e.g. using `|` prefix) or indented in a text block, and never inline multiline content.
