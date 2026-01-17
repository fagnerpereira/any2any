## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2025-01-17 - ERB Tag Injection in Static Content
**Vulnerability:** The ERB generator emitted static content verbatim without escaping `<%` tags. This allowed template injection where static text containing `<%` would be interpreted as code when the generated ERB was rendered.
**Learning:** Even "text" content in template languages can be dangerous if it matches the template engine's tag delimiters. ERB treats `<%` as code start, regardless of context.
**Prevention:** Always escape the opening tag sequence of the target template language in static content. For ERB, replace `<%` with `<%%`.
