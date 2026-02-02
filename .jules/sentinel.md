## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-24 - Server-Side Template Injection in ERB Generator
**Vulnerability:** The ERB generator blindly outputted static content without escaping ERB tags `<%`, allowing an attacker to inject arbitrary Ruby code if they could control the content of the source template.
**Learning:** When converting between template formats, static text in the source format must remain static text in the target format. Any characters that have special meaning in the target format (like `<%` in ERB) must be escaped.
**Prevention:** Implement strict escaping for all target language control characters in the generator's text output methods. For ERB, this means converting `<%` to `<%%`.
