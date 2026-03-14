# 架构设计：Hello World API

**产出角色：** System Architect（规划层 Agent）
**任务：** 实现一个简单的 Hello World HTTP 接口，验证技能组 + aider 集成链路

---

## 接口设计

### GET /hello

**描述：** 返回 Hello World 问候语

**请求：**
- 方法：`GET`
- 路径：`/hello`
- 参数：`name`（可选 query 参数，默认 "World"）

**响应：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "greeting": "Hello, {name}!",
    "timestamp": "2026-03-14T10:00:00Z"
  }
}
```

---

## 技术实现方案

**语言/框架：** Python + Flask（轻量，适合测试）

**文件结构：**
```
test-hello-world/
├── app.py          # Flask 主入口 + 路由
├── requirements.txt # 依赖声明
└── test_app.py     # 单元测试
```

**实现要求：**
- 单文件 ≤ 800 行，方法 ≤ 50 行
- 统一响应结构（code/message/data）
- 支持 name 参数，默认值 "World"
- 包含 timestamp（ISO 8601 格式）
- 有单元测试覆盖正常/边界场景
