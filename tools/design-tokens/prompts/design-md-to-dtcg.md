# DESIGN.md to DTCG Token Candidate Prompt

Use this prompt with an AI agent when converting an `awesome-design-md` `DESIGN.md` reference into reviewed Merce DTCG token source candidates.

```text
You are converting a public design-system DESIGN.md reference into Merce DTCG token source candidates.

Input:
- One DESIGN.md file from VoltAgent/awesome-design-md.
- The existing Merce token source layout under tools/design-tokens/tokens/.

Output:
- DTCG JSON source candidate snippets only.
- Optional Merce font asset metadata candidates when the DESIGN.md explicitly provides licensed font files.
- Use $value, $type, and optional $description.
- Prefer current Merce source targets: color.palette.*, color.text.*, color.background.*, color.border.*, color.action.*, color.status.*, color.surface.*, spacing.*, radius.*, and typography.*.
- Preserve explicit token references to core tokens where the design intent maps cleanly.

Rules:
- Do not write final files under generated/themes/.
- AI output must not write final files under generated/themes/.
- Do not produce canonical Merce manifest JSON.
- Do not invent runtime API names outside the current Merce manifest sections.
- Do not assume DTCG mandates group names such as color, palette, or typography; these are Merce source/runtime taxonomy names.
- Do not rely on group names to imply token type. Every token must have explicit or inherited $type.
- Do not treat a font family name as evidence that a font file is licensed or available at runtime.
- Do not emit CSS font stacks into typography.* runtime fields; use one Qt-loadable family name and put licensed font files in separate asset metadata.
- If font files are explicit and licensed, return a separate Merce font asset metadata candidate; do not encode font files as generic typography tokens.
- Keep brand fixture changes isolated under tools/design-tokens/tokens/themes/<theme>/.
- Return assumptions and uncertain mappings separately from the JSON snippets.
```
