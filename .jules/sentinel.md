## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-24 - SSTI in ERB Generator
**Vulnerability:** The ERB generator outputted static content directly without escaping ERB tags (`<%`), allowing for Server-Side Template Injection (SSTI) if the input contained literal text looking like ERB tags.
**Learning:** When generating template files like ERB, static text must be escaped to prevent it from being interpreted as code by the template engine. In ERB, `<%` must be escaped as `<%%`.
**Prevention:** Ensure that all static text output by generators is properly escaped for the target format's syntax, specifically neutralizing tag delimiters.
