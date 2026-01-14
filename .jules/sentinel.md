## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-24 - Template Injection in ERB Generator
**Vulnerability:** The ERB generator outputted static content as-is, allowing `<%` sequences to be interpreted as ERB tags, leading to potential code injection.
**Learning:** Even in text-based template formats like ERB, specific character sequences act as control structures. Unlike HTML where `<` needs escaping, ERB specifically requires escaping `<%` to `<%%` to be treated as literals.
**Prevention:** Always escape the start delimiter of the template language in static content. For ERB, ensure `<%` is converted to `<%%`.
