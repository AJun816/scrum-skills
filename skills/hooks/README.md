# Hooks / 钩子

Claude Code hooks that enforce coding standards automatically.
自动强制执行代码规范的 Claude Code 钩子。

## Auto-Active / 自动生效

Hooks are configured in `.claude/settings.json` (committed to git).
When you clone this repo and open it in Claude Code, hooks are **automatically active** — no setup needed.

钩子配置在 `.claude/settings.json` 中（已提交到 git）。
克隆仓库后用 Claude Code 打开，钩子**自动生效**，无需手动配置。

## What Hooks Do / 钩子功能

| Hook | Event | Action |
|------|-------|--------|
| pre-bash.sh | PreToolUse:Bash | Block dangerous commands, check review mark on git commit |
| pre-file-write.sh | PreToolUse:Write/Edit | Block files >800 lines, scan for secrets |
| post-file-write.sh | PostToolUse:Write/Edit | Warn on code smells (console.log, TODO) |
| commit-msg.sh | git commit-msg | Require `Reviewed-by: 8-code-reviewer` in commit messages |

## Optional Setup / 可选配置

Run setup script to customize nickname and install git commit-msg hook:
运行配置脚本自定义昵称和安装 git commit-msg hook：

```bash
sh .claude/skills/hooks/setup.sh
```

## Skip Review / 跳过审查

Add `[skip-review]` to commit message to bypass review mark check.
在提交信息中添加 `[skip-review]` 可跳过审查标记检查。
