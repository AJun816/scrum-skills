# Changelog

## 2026-03-27

### Cross-Agent Harness Hardening

- 修复 `skills/hooks/setup.sh` 的目录识别逻辑：
  - 不再只把 `~/.claude/skills` 视为 embedded 模式
  - 现可正确识别 repo / `~/.claude` / `~/.codex` / 自定义 target 等安装布局
- `sh skills/hooks/setup.sh --default` 在仓库调试模式下，会同时为 `.claude/skills/` 与 `.codex/skills/` 准备本地联调链接。
- `install.sh` / `install.ps1` 增加跨 Agent 说明：
  - 自动识别 `.codex`
  - 仅对 `~/.claude` 部署 `settings.json`
  - 对 Codex 与其他 target 保持 skill-only 安装，不伪装成 Claude 配置目录
- 安装器不再把工作区里的 `skills/.cache/` 和 `.DS_Store` 一起打包到目标目录。
- 新增外部技能包迁移规范：`skills/config/extension-pack-guidelines.md`
- 新增 gstack 中文命令目录：`skills/gstack/COMMANDS.zh-CN.md`
- README、`skills/README.md`、`AGENTS.md`、`harness-playbook.md` 同步补齐：
  - 核心技能组零额外环境说明
  - Claude / Codex 安装差异
  - 迁移技能中文入口与依赖边界

### Documentation Clarification

- README 文档补充文档导航，明确 `README.md`、`skills/README.md`、`AGENTS.md` 与 Harness 配置文档的分工。
- 安装说明补充 shell 安装器与 Windows PowerShell 原生安装器的差异：
  - `sh install.sh` 会自动执行 `skills/hooks/setup.sh --default --skip-repo-map`
  - `install.bat` / `install.ps1` 会复制 `skills/`，并在目标为 `~/.claude` 时同步 `settings.json`，但不会自动执行 `setup.sh`
- README / `skills/README.md` 进一步补充 `install.sh` 的安装目标自动识别规则，以及仓库维护者直接运行 `sh skills/hooks/setup.sh --default` 的本地调试路径。
- 文档明确 `gstack` 以 vendored 形式集成，默认复制但不会自动运行 `gstack/setup`。
- `skills/README.md` 补齐安装后默认状态、Windows 手动 setup 前提，以及 `skills/config/` 目录下的 Harness 相关文件。
- 清理 README 中残留的本机绝对路径链接，并将本地 `.codex/` 协作目录加入忽略规则，避免误提交环境产物。

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
