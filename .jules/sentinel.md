## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2025-05-20 - Code Injection in HAML Generator
**Vulnerability:** The HAML generator treated multiline static text as raw HAML lines, and inline text as safe. Lines starting with `-` were interpreted as Ruby code, lines starting with `:` invoked filters (e.g., `:javascript`), and text containing `#{...}` executed Ruby interpolation, all leading to potential command execution.
**Learning:** HAML is whitespace-sensitive and interprets the first character of a line to determine its type. Furthermore, HAML performs Ruby interpolation in plain text nodes by default. Indentation alone is insufficient; special characters (`%`, `#`, `=`, `-`, `~`, `/`, `.`, `!`, `:`, `\`, `&`) must be escaped at the start of lines, and interpolation sequences (`#{`) must be escaped anywhere in the text.
**Prevention:** When generating HAML, every line of static text must be inspected. If a line starts with a special character, it must be escaped (e.g., with `\`). Additionally, all instances of `#{` must be escaped to `\#{` to prevent unwanted interpolation.
