# 技能元数据规范

**定义每个技能 SKILL.md 头部 YAML frontmatter 的标准格式。**

---

## Frontmatter 标准格式

```yaml
---
name: skill-id                    # 技能唯一标识（与目录名一致）
version: 1.0.0                    # 语义化版本号（semver）
description: 技能描述              # 一句话描述
group: execution                  # 技能分组（见下方预定义值）
province: bingbu                  # 三省六部映射（见下方预定义值）
mode: [agile, imperial]           # 适用模式：agile | imperial | both
author: scrum-skills-team         # 作者/团队
tags: [backend, api, coding]      # 标签列表
requires_aider: true              # 是否需要 aider 执行编码
dependencies: [3-system-architect] # 依赖的其他技能
---
```

## 字段说明

### group（技能分组）

| 值 | 说明 | 示例技能 |
|---|---|---|
| `emperor` | 皇上（最高决策层） | 0-emperor |
| `planning` | 规划层（三省） | 0-zhongshu-province |
| `review` | 审核层（三省） | 0-menxia-province |
| `dispatch` | 派发层（三省） | 0-shangshu-province |
| `execution` | 执行层（六部） | 4-backend-dev, 4-frontend-dev |
| `coordination` | 协调层 | 0-scrum-master, 6-bug-handler |
| `utility` | 工具层 | 7-skill-creator |

### province（三省六部映射）

| 值 | 对应 | 说明 |
|---|---|---|
| `emperor` | 皇上 | 最高决策，下旨 |
| `taizi` | 太子 | 消息分拣，传旨 |
| `zhongshu` | 中书省 | 规划、拆解 |
| `menxia` | 门下省 | 审核、封驳 |
| `shangshu` | 尚书省 | 派发、协调 |
| `hubu` | 户部 | 数据、业务 |
| `libu` | 礼部 | 文档、规范 |
| `bingbu` | 兵部 | 工程实现 |
| `xingbu` | 刑部 | 测试、合规 |
| `gongbu` | 工部 | 架构、基建 |
| `libu_hr` | 吏部 | 运维、部署 |
| `none` | 无映射 | 敏捷模式专用技能 |

### mode（适用模式）

| 值 | 说明 |
|---|---|
| `agile` | 仅敏捷团队模式 |
| `imperial` | 仅三省六部模式 |
| `[agile, imperial]` | 两种模式都适用 |

## 校验规则

技能创建/更新时（`7-skill-creator` 负责校验）：

1. YAML frontmatter 必须存在且格式正确
2. `name` 必须与目录名一致
3. `version` 必须符合 semver（如 `1.0.0`、`1.2.3`）
4. `group` 必须是预定义值之一
5. `province` 必须是预定义值之一
6. `mode` 必须包含至少一个有效值
7. SKILL.md 行数 400-800 之间
8. 必须包含：职责、工作流程、质量标准、协作模式 四个章节
9. `references/` 目录至少有 1 个参考文件

## 技能来源追踪

远程技能需额外包含 `.source.json`：

```json
{
  "name": "skill_name",
  "sourceUrl": "https://github.com/...",
  "version": "1.0.0",
  "checksum": "sha256:abc123...",
  "addedAt": "2026-03-15T00:00:00Z",
  "lastUpdated": "2026-03-15T00:00:00Z"
}
```
