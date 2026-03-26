# Hooks / 钩子

Claude Code hooks for code quality enforcement.
代码质量管控的 Claude Code 钩子。

## Auto-Active / 自动生效

Hooks are configured in `.claude/settings.json` (committed to git).
Run `sh install.sh` once after clone, then hooks become active automatically.

钩子配置在 `.claude/settings.json` 中（已提交到 git）。
克隆仓库后先执行一次 `sh install.sh`，随后钩子即可自动生效。

## What Hooks Do / 钩子功能

| Hook | Event | Action |
|------|-------|--------|
| pre-bash.sh | PreToolUse:Bash | Enforce `✅[Reviewed]` prefix on every git commit |
| pre-file-write.sh | PreToolUse:Write/Edit | Block code files >800 lines, warn >600 lines |
| post-file-write.sh | PostToolUse:Write/Edit | Code quality report (see below) |
| commit-msg.sh | git commit-msg | Enforce `✅[Reviewed]` prefix (git hook layer) |

`pre-bash` is always active after install. `commit-msg` is optional per repository (install via `setup.sh --project-root=...`).

## Commit Format / 提交格式

Every commit **must** start with `✅[Reviewed]` prefix. No bypass, no exceptions.
每次提交**必须**以 `✅[Reviewed]` 开头，无例外。

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

Run setup script to customize nickname and install git commit-msg hook:
运行配置脚本自定义昵称和安装 git commit-msg hook：

```bash
sh ~/.claude/skills/hooks/setup.sh
sh ~/.claude/skills/hooks/setup.sh --project-root=/path/to/repo
# 如果你安装到自定义目录，请把 ~/.claude 替换为你的安装目录
```

## Skip Review / 跳过审查

Add `[skip-review]` to commit message to bypass the review prefix check.
在提交信息中添加 `[skip-review]` 可跳过审查前缀检查。
