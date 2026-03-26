# gstack Integration

本目录以 vendored 方式集成自 `garrytan/gstack`，保留其原始目录结构、`setup`、浏览器运行时和技能模板。

## 为什么不平铺迁移

gstack 不是纯 Markdown 技能包。它包含：

- `setup` 安装流程
- `bun run build` / `gen:skill-docs` 生成逻辑
- `browse` 浏览器运行时与 Playwright/Chromium 依赖
- `review` / `qa` / `ship` 等技能所需的运行时资源

如果直接把 28 个技能目录平铺进当前仓库根级 `skills/`，路径约定和运行时都会失效。

## 启用方式

在你的项目里复制完本仓库后执行：

```bash
cd your-project/.claude/skills/gstack
./setup
```

前提：

- `bun >= 1.0`
- 首次 setup 允许安装 Playwright/Chromium

## 说明

- 当前仓库只是把 gstack 源码整合进来，便于统一分发和后续同步。
- 这一步不会自动替你安装 `bun`，也不会在本仓库内替你执行 gstack 的完整 setup。
- 如果你只需要迁移技能组而不需要其浏览器/发布运行时，可以暂时只保留本目录源码，不执行 setup。
