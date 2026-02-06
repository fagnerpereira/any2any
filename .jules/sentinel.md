## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-27 - Tag Injection in HAML Generator
**Vulnerability:** The HAML generator failed to escape special characters (`%`, `#`, `.`, etc.) at the beginning of static content lines, allowing for tag injection and structure manipulation.
**Learning:** HAML interprets lines starting with specific characters as tags or commands. Untrusted text content must be inspected for these starting characters and escaped. Additionally, simple inline optimization of static content can break if the content spans multiple lines, leading to incorrect structure.
**Prevention:** Always escape lines starting with HAML special characters in static content using `\`. Disable inline content optimizations for multiline strings to ensure proper indentation.
## 2024-05-24 - Tag Injection in HAML Generator
**Vulnerability:** The HAML generator treated lines starting with special characters (like `%`, `.`, `#`, `=`, `-`) in static content as tags or commands, allowing injection if user input controlled the content.
**Learning:** HAML's whitespace-sensitive syntax means that any line starting with a special character is interpreted as code. Static content must be escaped if it starts with these characters.
**Prevention:** Escape lines starting with HAML special characters using a backslash `\` in the generator. Ensure multiline content is properly indented and escaped line-by-line.
## 2024-05-24 - Template Injection in Slim Generator
**Vulnerability:** The Slim generator failed to escape Ruby interpolation sequences `#{` in static content and attributes, and did not properly handle multiline static content.
**Learning:** Slim treats `#{}` within text and attributes as Ruby code to be interpolated. Unescaped input allows arbitrary code execution. Additionally, unindented newlines in static content can introduce new tags (structural injection).
**Prevention:** Always escape backslashes `\` to `\\` and interpolation sequences `#{` to `\#{` (in that order) in all static content and attributes generated for Slim. Ensure multiline static content is split and each line is strictly prefixed with the pipe character `|` and proper indentation.
