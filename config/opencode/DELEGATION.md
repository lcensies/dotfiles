# Delegation

Subagents (`task` tool) are on. Use them — default is delegate, not do-it-inline.

## Delegate by default

| Situation | Agent |
|---|---|
| Search spans 2+ modules, or file location unknown | `explore` |
| Several independent search angles | several `explore`, one message, parallel |
| Diff/branch needs review before merge | `reviewer` |
| Feature needs end-to-end verification | `blackbox-tester` |
| PR + ticket + branch chains, multi-command ops | `operator` |
| Threat model, detection, security tooling | `cybersecurity-expert` |
| Independent chunks of unrelated work | several `general`, parallel |

Rule of thumb: if answering costs more than ~3 exploratory tool calls, or its
output is transcripts/dumps you would only skim, it belongs in a subagent.
Context you never read is context you should never have loaded.

## Do NOT delegate

Known file path, one grep, one command, single edit, anything the user asked
you personally to do, or work depending on state only you hold. Delegation
overhead beats the task there.

## Dispatching

- Prompt is self-contained: goal, scope (paths/branch/spec), and exactly what
  to return. Subagent sees none of this conversation.
- Say the thoroughness: quick / medium / very thorough.
- Say read-only vs write. `explore` and `reviewer` never write.
- Independent tasks → one message, multiple `task` calls. Never serialize them.
- Never redo delegated work yourself. Trust the report or dispatch a follow-up
  with `task_id`.
- Subagent output is invisible to the user — summarize the result yourself.
