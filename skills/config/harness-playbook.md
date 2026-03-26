# Harness Playbook

本文件将 Harness Engineering 方法转成 Scrum Skills 的可执行约束。

## 1. 核心原则（可执行版）

1. 仓库即事实源：规则、决策、进度必须落盘到仓库文件。
2. 地图优先：`AGENTS.md` 只做导航，不堆积巨型指令。
3. 机械化约束：能脚本化/Hook 化的规则，不只写文档。
4. 思考与执行分离：先计划，后实现，再验证。
5. 持久化记忆：会话状态写入文件，不依赖上下文窗口。
6. 熵管理常态化：定期清理文档漂移、重复代码和无效规则。

## 2. 标准执行序列

任何中大型任务必须按以下顺序推进：

1. Understand：读取目标模块与约束文件，确认范围。
2. Plan：输出结构化计划（任务拆分 + 风险 + 验收）。
3. Implement：按最小变更单元实施，避免 one-shot 大改。
4. Verify：执行脚本/测试/检查，验证完成标准。
5. Persist：更新文档和状态文件，保证可交接。

## 3. 上下文三层

- Tier 1（常驻）：
  - `AGENTS.md`
  - `README.md`
  - `skills/config/mandatory-rules.md`
- Tier 2（按需）：
  - 对应角色技能 `SKILL.md`
  - `skills/config/workflow-guide.md`
  - `skills/config/permission-matrix.md`
- Tier 3（查询式）：
  - `skills/config/*.md` 其他专项文档
  - `.cache/shared/repo-map.md`（存在时）
  - 历史变更和提交记录

## 4. 失败模式与防护

- 失败模式：一步到位大改导致失控  
  防护：拆分任务，单次只改一个责任单元。
- 失败模式：过早宣告完成  
  防护：必须通过验证脚本/检查项才可完成。
- 失败模式：只改代码不更新规则  
  防护：行为变化必须同步更新 `README` / `AGENTS.md` / 对应配置文档。
- 失败模式：上下文污染  
  防护：按需加载文档，超长对话先摘要再继续。

## 5. 合并门禁（Backpressure）

满足以下条件才允许合入：

1. 安装路径可复现（`sh install.sh`）。
2. 关键脚本幂等，不做破坏性清理。
3. 文档与脚本行为一致。
4. 质量钩子与规则不冲突。
