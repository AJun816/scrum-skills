# 技能分组定义

**定义技能的分组方式，支持三省六部映射和场景预设。**

---

## 按三省六部分组

### 皇上（最高决策层）

| 技能 | 角色 | 职责 |
|---|---|---|
| `0-emperor` | 👑 皇上 | 下旨、决策、御批 |
| `0-taizi` | 🤴 太子 | 消息分拣、旨意整理、传旨 |

### 三省（流程控制层）

| 省 | 技能 | 职责 |
|---|---|---|
| 中书省 | `0-zhongshu-province` | 接旨、规划、拆解子任务 |
| 门下省 | `0-menxia-province` | 审核、封驳、质量门禁 |
| 尚书省 | `0-shangshu-province` | 派发、协调、汇总回奏 |

### 六部（执行层）

| 部 | 技能 | 职责 |
|---|---|---|
| 户部 | `1-business-expert` | 数据、业务分析 |
| 礼部 | `2-product-manager` | 文档、需求规范 |
| 工部 | `3-system-architect` | 架构、基建设计 |
| 兵部 | `4-backend-dev`, `4-frontend-dev`, `4-frontend-design`, `4-nielsen-ui-design` | 工程实现 |
| 刑部 | `5-webapp-testing` | 测试、合规 |
| 吏部 | `5-devops-engineer` | 运维、部署 |

### 编排层

| 技能 | 角色 | 职责 |
|---|---|---|
| `0-workflow-runner` | 🔄 工作流编排器 | 自动驱动全流程，派发 Agent 子进程，跟踪状态 |

### 独立角色

| 分类 | 技能 | 说明 |
|---|---|---|
| 协调 | `0-scrum-master`, `6-bug-handler` | 敏捷模式专用 |
| 工具 | `7-skill-creator` | 技能管理 |
| 门禁 | `8-code-reviewer` | 敏捷模式代码审查 |

---

## 按场景预设分组

### Web 全栈开发

```
2-product-manager → 3-system-architect → 4-backend-dev + 4-frontend-dev + 4-frontend-design → 5-webapp-testing → 8-code-reviewer
```

### API 开发

```
2-product-manager → 3-system-architect → 4-backend-dev → 5-webapp-testing → 8-code-reviewer
```

### Bug 修复

```
6-bug-handler → 4-backend-dev 或 4-frontend-dev → 8-code-reviewer
```

### 前端专项

```
2-product-manager → 4-nielsen-ui-design → 4-frontend-design → 4-frontend-dev → 5-webapp-testing
```

---

## 三省六部模式完整流转

```
👑 皇上（用户下旨）
    ↓
🤴 太子 分拣（闲聊直接回 / 正式旨意传旨）
    ↓
📜 中书省 接旨
    ├→ 调用 /2-product-manager 产出需求文档
    ├→ 调用 /3-system-architect 产出架构设计
    ↓
📜 中书省 提审 → 🔍 门下省 审核（阶段1: 需求 + 阶段2: 架构）
    ↓                    ↓
  封驳 ← 修改意见      准奏
  (回中书省修改)          ↓
                    📜 中书省 → 📮 尚书省 派发
                        ├→ /4-backend-dev (Agent 子进程)
                        ├→ /4-frontend-dev (Agent 子进程)
                        ├→ /5-devops-engineer (Agent 子进程)
                        ↓
                    📮 尚书省 汇总 → 🔍 门下省 审核（阶段3: 代码）
                        ↓                    ↓
                      封驳 ← 修改意见      准奏
                      (回尚书省重派)          ↓
                                        📜 中书省 回奏（最终报告）
                                            ↓
                                        👑 皇上 御览
                                            ↓
                                        git commit ✅[Reviewed]
```

## 敏捷团队模式流转（保留不变）

```
Scrum Master → PM/Architect/Designer 并行规划 → Dev/DevOps 并行执行 → Code Review → 提交
```
