## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-24 - ERB Server-Side Template Injection
**Vulnerability:** `ErbGenerator` outputted `StaticContent` nodes raw, allowing attackers to inject ERB tags (`<% ... %>`) into the generated template if the input text contained them.
**Learning:** When generating templates from an IR, static text content must be escaped according to the target template language's rules to prevent it from being interpreted as code.
**Prevention:** In ERB generators, escape `<%` to `<%%` in all static content to ensure it renders as literal text.
