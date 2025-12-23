## 2024-12-23 - Phlex Generator Code Injection
**Vulnerability:** The Phlex generator failed to escape `#{` in string literals, allowing code injection via template content.
**Learning:** When generating executable code (like Phlex Ruby files) from user content, standard string escaping (quotes/backslashes) is insufficient; language-specific interpolation syntax must also be neutralized.
**Prevention:** Explicitly escape `#{` as `\#{` in all generated Ruby string literals, and ensure backslashes are escaped first to prevent bypasses.
