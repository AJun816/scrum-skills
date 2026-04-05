# Hooks / 钩子

Claude Code hooks plus repository-local Harness git hooks.
Claude Code 钩子 + 仓库级 Harness Git hooks。

## Auto-Active / 自动生效

Claude hooks are configured in `.claude/settings.json`.
Run `sh install.sh` once after clone, then Claude-side hooks become active automatically when the target is `~/.claude`.
For Codex or custom targets, `setup.sh` only prepares user config and project Harness artifacts.
For any repository, run `sh <target>/skills/hooks/setup.sh --project-root=/path/to/repo` to generate `.harness/git-hooks`, `.cache/shared/repo-map.md`, and `.cache/shared/repo-index.json`.

Claude 侧钩子配置在 `.claude/settings.json` 中。
克隆仓库后先执行一次 `sh install.sh`，若安装目标为 `~/.claude`，随后 Claude 侧钩子即可自动生效。
对于 Codex 或自定义目标，`setup.sh` 只负责用户配置和项目级 Harness 产物，不会伪装成 Claude 配置目录。
任意仓库再执行一次 `setup.sh --project-root=...`，即可生成 `.harness/git-hooks`、`.cache/shared/repo-map.md` 与 `.cache/shared/repo-index.json`。

## What Hooks Do / 钩子功能

| Hook | Event | Action |
|------|-------|--------|
| pre-bash.sh | PreToolUse:Bash | Enforce `✅[Reviewed]` prefix on every git commit |
| pre-file-write.sh | PreToolUse:Write/Edit | Block code files >800 lines, warn >600 lines |
| post-file-write.sh | PostToolUse:Write/Edit | Code quality report (see below) |
| commit-msg.sh | git commit-msg | Fallback validator for `✅[Reviewed]` prefix |
| `.harness/git-hooks/pre-commit` | git pre-commit | Run project harness-check on staged files |
| `.harness/git-hooks/commit-msg` | git commit-msg | Enforce `✅[Reviewed]` and audited override |
| `.harness/git-hooks/pre-push` | git pre-push | Block direct push to protected branches + run full harness-check |

`pre-bash` is always active after install. Project-level git gates are installed by `setup.sh --project-root=...` via `core.hooksPath = .harness/git-hooks`.

## Commit Format / 提交格式

Every commit **must** start with `✅[Reviewed]` prefix. `[skip-review]` is removed.
每次提交**必须**以 `✅[Reviewed]` 开头。`[skip-review]` 已移除。

```
✅[Reviewed] feat: implement user login
✅[Reviewed] fix: fix payment bug
```

Git log effect / Git日志效果：
```
✅[Reviewed] feat: 实现用户登录功能     ← reviewed, safe
✅[Reviewed] fix: 修复支付失败问题      ← reviewed, safe
feat: 紧急修复                          ← blocked, cannot commit
```

## Code Quality Checks / 代码质量检查

`post-file-write.sh` runs after every file write/edit and reports:

| Check | Threshold | Level |
|-------|-----------|-------|
| File size / 文件行数 | >800 lines: error, >600: warn | ❌ / ⚠️ |
| Function length / 方法行数 | >50 lines | ⚠️ |
| Nesting depth / 嵌套深度 | >6: error, >4: warn | ❌ / ⚠️ |
| console.log | any occurrence | ⚠️ |
| TODO/FIXME/HACK | any occurrence | ⚠️ |
| Linter (auto-detect) | eslint / ruff / flake8 / go vet | 🔍 |

Linter auto-detection: if the project has eslint, ruff, flake8, or go installed, the hook runs it automatically.

## Optional Setup / 可选配置

Run setup script to customize nickname and initialize repository harness:
运行配置脚本自定义昵称并初始化仓库 Harness：

```bash
sh ~/.claude/skills/hooks/setup.sh
sh ~/.claude/skills/hooks/setup.sh --project-root=/path/to/repo
# 如果你安装到自定义目录，请把 ~/.claude 替换为你的安装目录
```

## Overrides / 豁免

如果必须临时绕过某条规则，不再允许使用 `[skip-review]`。
必须在 `.harness/overrides/ADR-xxx.yaml` 中登记审计信息，并在提交信息中写入 `[imperial-override:ADR-xxx]`。
