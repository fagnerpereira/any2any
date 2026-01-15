## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-24 - ERB Template Injection via Static Content
**Vulnerability:** The ERB generator did not escape the opening tag `<%` in static content. This allowed an attacker to inject arbitrary Ruby code if they could control the static text of a template being converted to ERB.
**Learning:** Even "static" content in a generated template can be executable if it contains the target language's code delimiters. Generators must treat all text content as potentially dangerous and escape delimiters.
**Prevention:** In the ERB generator, `generate_static_content` now escapes `<%` to `<%%`. This ensures that `<%` is treated as literal text in the output.
