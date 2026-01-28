## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-24 - Server-Side Template Injection in ERB Generator
**Vulnerability:** The ERB generator outputted `StaticContent` nodes raw, allowing input text containing `<%` to be interpreted as ERB tags during rendering.
**Learning:** Template generators must escape the target template language's control sequences (like `<%` in ERB) in text nodes, just as HTML generators must escape `<` and `&`.
**Prevention:** In `ErbGenerator#generate_static_content`, explicitly escape `<%` to `<%%` to ensure text is treated as literals.
