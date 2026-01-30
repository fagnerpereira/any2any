## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-24 - Template Injection in ERB/HAML/Slim Generators
**Vulnerability:** Static content in ERB (`<%`), HAML (`#{`), and Slim (`#{`) was output raw, allowing attackers to inject code via template control characters.
**Learning:** "Static content" nodes in an IR must be actively escaped for the target format's control characters, not just HTML characters. Converting text to a template format is a form of compilation that requires syntax-aware escaping.
**Prevention:** Implement format-specific escaping helpers (e.g., `escape_erb_tags`, `escape_ruby_interpolation`) and apply them to all static text nodes during generation.
