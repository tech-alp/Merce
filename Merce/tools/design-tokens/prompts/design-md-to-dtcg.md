# DESIGN.md to DTCG Token Candidate Prompt

Use this prompt with an AI agent when converting an `awesome-design-md` `DESIGN.md` reference into reviewed Merce DTCG token source candidates.

```text
You are converting a public design-system DESIGN.md reference into Merce DTCG token source candidates.

Input:
- One DESIGN.md file from VoltAgent/awesome-design-md.
- The existing Merce token source layout under tools/design-tokens/tokens/.

Output:
- DTCG JSON source candidate snippets only.
- Use $value, $type, and optional $description.
- Prefer shallow Merce semantic targets: palette.semantic.*, spacing.*, radius.*, and typography.*.
- Preserve explicit token references to core tokens where the design intent maps cleanly.

Rules:
- Do not write final files under generated/themes/.
- AI output must not write final files under generated/themes/.
- Do not produce canonical Merce manifest JSON.
- Do not invent runtime API names outside the current Merce manifest sections.
- Keep brand fixture changes isolated under tools/design-tokens/tokens/themes/<theme>/.
- Return assumptions and uncertain mappings separately from the JSON snippets.
```
