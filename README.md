### Managing dotfiles

```
$ mkrc .$DOTFILE # Add new dotfile and create symlink
$ lsrc           # List all linked dotfiles
$ rcup -v        # Update all dotfile symlinks
```

### Coding agents (OpenCode, Cursor, Claude)

Canonical copies live under this repo; `rcup` symlinks them into `~/.config` / `~/.cursor`.

| Path in dotfiles | Installed as |
|------------------|--------------|
| `config/opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` |
| `config/opencode/skills/workmux/` | `~/.config/opencode/skills/workmux/` |
| `cursor/rules/workmux.mdc` | `~/.cursor/rules/workmux.mdc` |

After each `rcup`, **`hooks/post-up/50-agent-cross-links`** runs and also sets:

- `~/.claude/skills/workmux` → same directory as OpenCode’s workmux skill (single source).
- If `~/.codex` exists: `~/.codex/AGENTS.md` → `config/opencode/AGENTS.md`.

**Note:** `~/.claude/CLAUDE.md` is not replaced here (e.g. oh-my-claudecode). Extend that file locally or symlink only if you manage it entirely in dotfiles.

**First-time / conflicts:** if a target is a real directory or file, back it up then re-run `rcup -f` for those paths only if you intend to replace it with the symlink from dotfiles.
