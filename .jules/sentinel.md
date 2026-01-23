## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2026-01-23 - Fix ERB Tag Injection in Static Content
**Vulnerability:** The ERB generator was outputting static text content raw. If the static text contained `<%` (e.g. from user input that was properly escaped in the source format), it would be interpreted as an ERB tag in the generated output, leading to arbitrary code execution when the template is rendered.
**Learning:** Even "static" content in an Intermediate Representation must be escaped when converting to a format that has executable delimiters like `<%`. Generators must not assume that "static content" is safe for the target format without escaping.
**Prevention:** In all generators, identify the control characters (like `<%` in ERB, `#{}` in Ruby interpolation) and escape them in static content generation methods.
