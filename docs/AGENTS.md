# AGENTS.md - 开发者指南

本文档为 Easy Slim Skill 的开发指南，定义开发规范、工作流程和技术约束。

## 项目概述

**项目名称**: Easy Slim Skill
**项目类型**: QClaw/OpenClaw 技能（Skill）
**主要功能**: 减肥助手，支持食物热量识别、定时提醒、进度追踪

## 开发环境

### 必需软件

| 软件 | 版本要求 | 用途 |
|------|----------|------|
| Node.js | 22.x 或 24.x（推荐） | 运行时环境 |
| QClaw | 最新版 | 腾讯 AI 助手（测试环境） |
| OpenClaw | 最新版 | 开源 AI 助手（开发环境） |
| Git | 2.x | 版本控制 |

### 推荐工具

- VS Code 或其他 IDE
- Postman（API 测试）
- ImageMagick（图片处理测试）

## 技术架构

```
┌─────────────────────────────────────────────────────────┐
│                     用户交互层                           │
│  (微信/QQ 消息 ←→ QClaw Gateway ←→ OpenClaw Agent)      │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    SKILL.md 技能层                        │
│  - 触发词识别                                            │
│  - 工作流定义                                            │
│  - 响应模板                                              │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    数据处理层                            │
│  - 图片识别（多模态模型）                                 │
│  - 热量计算（本地数据库匹配）                              │
│  - 进度追踪（本地 JSON 存储）                             │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    数据存储层                            │
│  - data/foods_merged.json (食物数据库)                   │
│  - data/profile.json (用户档案)                          │
│  - data/logs/ (每日记录)                                 │
└─────────────────────────────────────────────────────────┘
```

## 开发规范

### 代码风格

- 使用 Markdown 编写 SKILL.md
- JSON 文件使用 2 空格缩进
- 注释简洁明了，只解释"为什么"

### 文件命名

| 类型 | 命名规则 | 示例 |
|------|----------|------|
| 技能文件 | 大写 SKILL.md | `SKILL.md` |
| 文档文件 | 大写 .md | `README.md`, `AGENTS.md` |
| 数据文件 | 小写 + 下划线 | `foods_merged.json` |
| 日志文件 | 日期格式 | `2026-05-04.json` |

### Git 提交规范

使用 Conventional Commits：

```
feat: 添加食物图片识别功能
fix: 修复热量计算错误
docs: 更新配置文档
test: 添加单元测试
chore: 更新依赖
```

## 开发工作流

### 1. 功能开发流程

```bash
# 1. 创建功能分支
git checkout -b feature/food-recognition

# 2. 按照 docs/spec/ 中的步骤开发

# 3. 本地测试
# 将技能加载到 QClaw 进行测试

# 4. 提交代码
git add .
git commit -m "feat: 添加食物图片识别功能"

# 5. 推送分支
git push origin feature/food-recognition

# 6. 创建 Pull Request
```

### 2. 测试流程

1. **单元测试**: 测试数据处理逻辑
2. **集成测试**: 测试 SKILL.md 工作流
3. **端到端测试**: 通过 QClaw 微信消息测试

### 3. 测试数据管理

⚠️ **重要**: 测试数据存放在 `test_data/` 目录，**不上传到 Git**

```
test_data/
├── sample_images/          # 测试用食物图片（私人数据）
│   ├── rice_bowl.jpg
│   └── kung_pao_chicken.jpg
└── sample_profiles/        # 测试用用户档案（私人数据）
    └── test_user.json
```

使用 `.gitignore` 排除：
```gitignore
test_data/
test_data/**
```

## 技能开发详解

### SKILL.md 结构

```markdown
---
name: easy-slim
description: "减肥助手技能描述"
metadata:
  openclaw:
    emoji: "🦞"
    wake_word: "胖虎"
    triggers:
      - "胖虎"
      - "你好胖虎"
      - "嗨胖虎"
    image_trigger: true
---

# Easy Slim - 减肥助手技能
```

### 技能触发机制

本技能使用**唤醒词机制**，用户必须先说"胖虎"才能触发。

| 触发方式 | 说明 |
|----------|------|
| 唤醒词触发 | 用户消息包含"胖虎"激活技能 |
| 唤醒+图片 | 用户说"胖虎"并发送图片触发食物识别 |
| 定时触发 | Cron 任务定时激活 |
| 手动调用 | 用户明确请求 |

## 数据库管理

### 食物数据库结构

```json
{
  "id": "food_rice_white",
  "name": "白米饭",
  "name_en": "White Rice (Boiled)",
  "category": "carbs",
  "emoji": "🍚",
  "nutrition_per_100g": {
    "calories": 130,
    "protein": 2.4,
    "carbs": 28.2,
    "fat": 0.3
  },
  "default_serving": {
    "name": "1碗",
    "grams": 150
  },
  "source": "china" | "global"
}
```

### 用户数据结构

**profile.json**
```json
{
  "height": 170,
  "weight": 70,
  "age": 30,
  "gender": "male",
  "target_weight": 65,
  "target_weeks": 12,
  "reminder_style": "gentle",
  "created_at": "2026-05-04T10:00:00Z"
}
```

**logs/2026-05-04.json**
```json
{
  "date": "2026-05-04",
  "meals": [
    {
      "time": "12:30",
      "type": "lunch",
      "foods": [
        { "name": "白米饭", "grams": 150, "calories": 195 },
        { "name": "红烧肉", "grams": 100, "calories": 350 }
      ],
      "total_calories": 545
    }
  ],
  "exercise": [
    { "time": "19:30", "type": "running", "duration_min": 30, "calories_burned": 250 }
  ],
  "summary": {
    "total_intake": 1500,
    "total_burned": 250,
    "net_calories": 1250
  }
}
```

## 错误处理

### 图片识别失败

返回友好提示：
```
抱歉，无法识别这张图片中的食物。请尝试：
1. 重新拍照，确保图片清晰
2. 手动告诉我食物名称，如："米饭 150g，红烧肉 100g"
3. 检查多模态模型配置
```

### 数据库无匹配

当食物不在数据库时：
```
数据库中暂无此食物的精确热量数据。
请手动输入热量，或使用近似食物估算：
- 您输入：炒面
- 建议：炒面（约160kcal/100g），请确认份量
```

## 发布检查清单

- [ ] 所有测试通过
- [ ] 文档更新完整
- [ ] 敏感数据已排除
- [ ] `.gitignore` 配置正确
- [ ] README 安装说明准确
- [ ] 示例数据完整

## 参考资源

- [OpenClaw 文档](https://docs.openclaw.ai)
- [SKILL.md 格式规范](https://docs.openclaw.ai/tools/skills)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [caltrack-data](https://github.com/suyogshejal2004/caltrack-data)
- [cn-food-mcp](https://github.com/ruffood/cn-food-mcp)