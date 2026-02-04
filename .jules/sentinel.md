## 2024-05-23 - Template Injection in Phlex Generator
**Vulnerability:** The Phlex generator failed to escape backslashes `\` and interpolation sequences `#{` in string literals.
**Learning:** Generating code (Ruby/Phlex) from templates requires treating the target language's syntax as dangerous. In Ruby, double-quoted strings allow interpolation and escape sequences, which must be neutralized when embedding untrusted text.
**Prevention:** When generating code, always use the target language's escaping mechanisms or strictly sanitize all metacharacters (quotes, backslashes, interpolation markers) in the correct order.

## 2024-05-24 - SSTI in ERB Generator
**Vulnerability:** The ERB generator outputted static content raw, allowing malicious ERB tags `<%` and `<%=` to be injected and executed when the generated template was rendered.
**Learning:** `StaticContent` in the IR represents text, but when generating ERB, text containing ERB delimiters must be escaped because ERB mixes code and text in the same stream.
**Prevention:** In ERB generators, escape `<%` to `<%%` in all static text nodes to prevent unintended code execution.
