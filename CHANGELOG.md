# Changelog

## 2026-04-05

### Eval And Observability

- 新增行为级 eval 子系统：`skills/evals/`
  - `eval-list.sh`
  - `eval-run.sh`
  - `eval-compare.sh`
  - `eval-selfcheck.sh`
  - 内置 case 与项目级 `.harness/evals/*.case.env` 扩展机制
- 新增 `skills/runtime/bin/workflow-report.sh`
  - 聚合 `workflow-state.json`、step 元数据与 `workflow-runs.jsonl`
  - 输出 `.cache/shared/workflow-report.json` 与 `.cache/shared/workflow-report.md`
- npm CLI 新增：
  - `skills eval <list|run|compare|selfcheck>`
  - `skills workflow report`
  - `skills eval report`
  - `skills report`
- 新增平台侧审计：
  - `skills/harness/bin/harness-platform-audit.sh`
  - `skills harness platform-audit`
  - `skills/config/gitee-ruleset-checklist.md`
- 新增 Harness 运行报表：
  - `skills/harness/bin/harness-report.sh`
  - `skills harness report`
  - `.harness/state/harness-runs.jsonl`
- 新增统一总览报表：
  - `skills/runtime/bin/skills-report.sh`
  - `.cache/shared/skills-report.json`
  - `--recent=N` 最近活动窗口
- 新增 Pack Registry 运行报表：
  - `skills/registry/bin/pack-report.sh`
  - `skills pack report`
  - 目标宿主 `.cache/shared/pack-runs.jsonl`
- `package.json`、CLI 测试与自检链路同步接入 eval / workflow / pack / top-level report

### Documentation Sync

- README、`skills/README.md`、`AGENTS.md` 同步到当前实现状态：
  - 明确 `skills` 是可选 npm CLI 包装层，主安装路径仍然是 `sh install.sh`
  - 补齐 `repo-map.md`、`repo-index.json`、runtime/registry 自检与项目级 Harness 初始化产物
  - 去掉把 runtime/registry 写成“第一阶段/第二阶段计划”的过时描述
- 重写 `docs/architecture-v3.md`，改为当前 V3 实现说明：
  - Host-Native 定位
  - Harness / Runtime / Knowledge Plane / Pack Registry 的已落地模块边界
  - 不引入 Studio 作为主线模块的设计结论
- 更新 `skills/runtime/README.md`、`skills/registry/README.md`、`skills/hooks/README.md`
- 更新 `skills/config/init-guide.md`、`skills/config/workflow-guide.md`、`skills/config/harness-playbook.md`
- 更新 `skills/0-workflow-runner/SKILL.md` 中对 runtime 与共享事实源的描述

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
