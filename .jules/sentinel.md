## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-24 - ERB Tag Injection in Static Content
**Vulnerability:** The ERB generator outputted static content directly without escaping ERB tags (`<% `), allowing arbitrary code execution if the source content contained text looking like ERB tags.
**Learning:** Even when generating "text-based" templates like ERB, the template engine's control characters must be escaped in static content. For ERB, `<% ` must be escaped to `<%% `.
**Prevention:** Implement strict escaping for all control sequences of the target template language in static text nodes.
