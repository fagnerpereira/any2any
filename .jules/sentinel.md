## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-24 - Tag Injection in HAML Generator
**Vulnerability:** The HAML generator treated lines starting with special characters (like `%`, `.`, `#`, `=`, `-`) in static content as tags or commands, allowing injection if user input controlled the content.
**Learning:** HAML's whitespace-sensitive syntax means that any line starting with a special character is interpreted as code. Static content must be escaped if it starts with these characters.
**Prevention:** Escape lines starting with HAML special characters using a backslash `\` in the generator. Ensure multiline content is properly indented and escaped line-by-line.
