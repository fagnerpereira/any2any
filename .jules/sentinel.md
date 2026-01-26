## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-24 - Template Injection in ERB, HAML, and Slim Generators
**Vulnerability:** ERB, HAML, and Slim generators allowed injection of arbitrary code via unescaped static content (`<%` in ERB, `#{` in HAML/Slim).
**Learning:** Template generators must not blindly trust "static content" from IR. Even if the content is "text", it may contain characters that the target format interprets as code (tags, interpolation).
**Prevention:** Explicitly escape format-specific control characters in static text and attributes. For ERB: escape `<%`. For HAML/Slim/Ruby: escape `\` and `#{`.
