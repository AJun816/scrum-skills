# 初始化与缓存指南

本文件说明 Scrum Skills 当前真实可用的初始化入口、落盘产物和缓存边界。

## 1. 初始化入口

项目级 Harness 不是“首次对话自动生成”，而是显式由安装后的 `setup.sh` 或仓库内的 `harness-init.sh` 创建。

推荐入口：

```bash
sh ~/.claude/skills/hooks/setup.sh --project-root=/path/to/repo
sh ~/.codex/skills/hooks/setup.sh --project-root=/path/to/repo
```

底层等价入口：

```bash
sh skills/harness/bin/harness-init.sh --project-root=/path/to/repo
```

说明：

- `sh install.sh` 只完成用户级安装；不会把 `.harness/` 直接写进你的业务仓库
- `~/.claude` 目标会额外部署 `.claude/settings.json`
- `~/.codex` 与其他自定义目标默认只部署技能组，不伪装成 Claude 配置目录
- `setup.sh --skip-repo-map` 只跳过 `repo-map.md` 生成，不影响 `.harness/`、`PROJECT_CONFIG.md`、`.cache/.project-info.json` 与 `repo-index.json`

## 2. 初始化时会生成什么

执行 `setup.sh --project-root=...` 后，当前实现会落盘这些事实源：

```text
.harness/
├── README.md
├── project-profile.json
├── architecture/
│   ├── contract.yaml
│   └── dependency-rules.yaml
├── rules/
│   ├── backend.yaml
│   ├── frontend.yaml
│   └── tests.yaml
├── git-hooks/
│   ├── pre-commit
│   ├── commit-msg
│   └── pre-push
├── bin/
│   ├── harness-init.sh
│   ├── harness-check.sh
│   ├── harness-fix.sh
│   ├── harness-gate.sh
│   ├── harness-worktree.sh
│   ├── harness-checkpoint.sh
│   ├── harness-repo-map.sh
│   ├── harness-repo-index.sh
│   └── harness-selfcheck.sh
├── state/
│   ├── drift-baseline.json
│   └── last-report.json
└── overrides/
    └── README.md
```

同时还会生成：

- `PROJECT_CONFIG.md`
- `.cache/.project-info.json`
- `.cache/shared/repo-map.md`
- `.cache/shared/repo-index.json`

如果目标仓库是 Git 仓库，初始化还会把 `core.hooksPath` 指向 `.harness/git-hooks`。

## 3. 检测与推断逻辑

`harness-init.sh` 会基于仓库实际文件推断：

- 项目名称
- 后端技术栈
- 前端技术栈
- 数据库
- 构建工具
- 架构风格
- 顶层模块列表

这些推断结果会同时写入：

- `PROJECT_CONFIG.md`
- `.cache/.project-info.json`
- `.harness/project-profile.json`
- `.cache/shared/repo-index.json`

仓库地图 `repo-map.md` 保留给人类和技能快速阅读；`repo-index.json` 提供结构化文件/模块索引，供 runtime、Harness 和后续工具链消费。

## 4. 缓存目录结构

当前仓库约定的共享缓存结构如下：

```text
.cache/
├── .project-info.json
└── shared/
    ├── repo-map.md
    ├── repo-index.json
    ├── workflow-state.json
    ├── workflow-runs.jsonl
    ├── workflow-runtime/
    ├── requirements/
    ├── architecture/
    ├── api-design/
    ├── test-reports/
    ├── ui-review/
    └── code-review/
```

说明：

- `workflow-state.json` 与 `workflow-runs.jsonl` 由 `skills/runtime/bin/workflow.sh` 维护
- `repo-map.md` 与 `repo-index.json` 由 Harness 维护
- 各技能自己的工作缓存仍可放在 `.cache/<skill-name>/`

## 5. `.project-info.json` 当前结构

当前实现写入的是 `2.0` 版结构，至少包含：

```json
{
  "project_name": "项目名称",
  "project_root": "/abs/path/to/repo",
  "initialized": true,
  "initialized_at": "2026-04-05T00:00:00Z",
  "last_used": "2026-04-05T00:00:00Z",
  "config_version": "2.0",
  "cache_version": "2.0",
  "architecture_style": "layered",
  "tech_stack": {
    "backend": "Node.js",
    "frontend": "React",
    "database": "PostgreSQL",
    "build_tool": "pnpm"
  },
  "modules": ["src", "docs", "skills"]
}
```

字段值取决于仓库实际探测结果；文档中的值只是结构示例。

## 6. 刷新与验证

推荐使用脚本刷新，而不是直接删除缓存目录：

```bash
sh .harness/bin/harness-init.sh --project-root=. --refresh
sh .harness/bin/harness-repo-map.sh --project-root=.
sh .harness/bin/harness-repo-index.sh --project-root=.
sh .harness/bin/harness-selfcheck.sh
```

如果只想清理共享事实源，可以删除目标文件后重新运行相应脚本；不要假设技能会在对话开始时自动重建全部项目级 Harness。
