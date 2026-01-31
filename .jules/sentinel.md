## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-24 - Template Injection in HAML/Slim Generators
**Vulnerability:** HAML and Slim generators blindly outputted static content containing Ruby interpolation syntax `#{...}` or starting with special characters (like `-`), leading to arbitrary code execution when the generated template was rendered.
**Learning:** Template engines often support "inline" interpolation or logic even in text mode. Simply generating text is insufficient; one must ensure the text is treated as a string literal in the target format (e.g., using `inspect` for attributes, escaping `#{` to `\#{` for text content, and prefixing special lines with `\`).
**Prevention:** Use safer constructs like Ruby string literals (`inspect`) for attribute generation instead of manual quoting. Explicitly escape interpolation markers and special start-of-line characters in text content.
