## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-24 - Template Injection in ERB, HAML, and Slim Generators
**Vulnerability:** ERB generator did not escape `<%` tags, and HAML/Slim generators did not escape `#{}` interpolation in static content and attributes, allowing Server-Side Template Injection (SSTI). HAML and Slim also lacked multiline content safety, allowing tag injection via newlines.
**Learning:** Static content in template engines must be strictly treated as text. Any sequence that triggers code execution (like `<%`, `#{`, or newlines in indentation-based languages) must be escaped or structured safely.
**Prevention:** Use dedicated escaping helpers (`escape_ruby_interpolation`, `escape_erb_tags`) for all static content. For indentation-based languages (HAML/Slim), handle multiline content by splitting lines and applying proper indentation or line prefixes (like `|`).
