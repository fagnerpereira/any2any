## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-27 - Tag Injection in HAML Generator
**Vulnerability:** The HAML generator failed to escape special characters (`%`, `#`, `.`, etc.) at the beginning of static content lines, allowing for tag injection and structure manipulation.
**Learning:** HAML interprets lines starting with specific characters as tags or commands. Untrusted text content must be inspected for these starting characters and escaped. Additionally, simple inline optimization of static content can break if the content spans multiple lines, leading to incorrect structure.
**Prevention:** Always escape lines starting with HAML special characters in static content using `\`. Disable inline content optimizations for multiline strings to ensure proper indentation.
