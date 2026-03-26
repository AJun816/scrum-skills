# Changelog

## 2026-03-26

### Harness Engineering 迭代优化

- 安装主路径统一为一键安装：`sh install.sh`（Windows 支持 `install.bat` + `install.ps1`）。
- 修复 hooks 路径一致性：安装时将 `settings.json` 中 hooks 路径写为安装目标绝对路径。
- `setup.sh` 增强：
  - 新增 `--project-root=PATH`，支持对指定仓库安装 `commit-msg` hook。
  - 新增 `--skip-repo-map`，避免全局安装场景误扫描。
  - 兼容 repo/embedded 两种目录布局。
- 文档更新：
  - 统一 setup 命令示例到安装后路径（默认 `~/.claude/...`）。
  - 明确 `pre-bash` 默认生效、`commit-msg` 为仓库级可选增强。
  - 增加 Harness 基线文档入口与参考索引。
- 新增 Harness 文档：
  - `AGENTS.md`
  - `skills/config/harness-playbook.md`
  - `skills/config/harness-references.md`
