# Step 3: 技能定义

## 目标

编写 SKILL.md 文件，定义技能的触发条件、工作流程和响应模板。

## 前置条件

- 完成 [02-data-preparation.md](02-data-preparation.md)
- 数据库文件 `data/foods_merged.json` 存在

## 任务清单

### 3.1 创建 SKILL.md 骨架

```markdown
---
name: easy-slim
description: "减肥助手技能：食物热量识别、定时提醒、进度追踪"
metadata:
  openclaw:
    emoji: "🦞"
    wake_word: "胖虎"
    triggers:
      - "胖虎"
      - "你好胖虎"
      - "嗨胖虎"
      - "哈喽胖虎"
    image_trigger: true
    requires:
      files:
        - "data/foods_merged.json"
---
```

### 3.2 定义触发规则

**唤醒词机制**:
```markdown
## 触发条件

本技能使用"胖虎"作为唤醒词。用户必须先说"胖虎"才能激活技能。

✅ **会触发：**
- "胖虎，帮我看看这顿饭多少热量"
- "你好胖虎，我今天吃了米饭和红烧肉"
- [发送图片] + "胖虎帮我识别"

❌ **不会触发：**
- "帮我看看这顿饭"（没有唤醒词）
- "今天吃了米饭"（没有唤醒词）
```
- 用户想更新个人信息
```

**When NOT to Use 部分**:
```markdown
## When NOT to Use

❌ **DON'T use this skill when:**

- 用户发送非食物图片（人物、风景等）
- 用户询问与减肥无关的健康问题（建议就医）
- 用户发送语音消息（转为文字后再处理）
```

### 3.3 定义工作流程

**初始化流程**:
```markdown
## Workflow: 初始化减肥计划

1. 检查用户档案是否存在 (`data/profile.json`)
2. 如果不存在，启动引导式问答：
   - 询问身高 (100-250cm)
   - 询问体重 (30-300kg)
   - 询问年龄 (10-120岁)
   - 询问性别 (男/女)
   - 询问目标体重
   - 询问计划周期 (周)
   - 询问提醒语气偏好
3. 计算 BMR 和 TDEE
4. 生成每日热量目标
5. 保存到 `data/profile.json` 和 `data/plan.json`
```

**图片识别流程**:
```markdown
## Workflow: 食物图片识别

1. 接收用户发送的图片
2. 调用多模态模型识别食物内容
3. 解析识别结果，提取食物名称和估算份量
4. 在 `data/foods_merged.json` 中搜索匹配
5. 计算热量和营养成分
6. 对比今日目标，给出建议
7. 记录到 `data/logs/YYYY-MM-DD.json`
8. 返回结果给用户
```

### 3.4 定义响应模板

**识别成功响应**:
```markdown
## Response: 食物识别成功

🍽️ **本次饮食记录**

| 食物 | 份量 | 热量 |
|------|------|------|
{{#each foods}}
| {{name}} | {{grams}}g | {{calories}}kcal |
{{/each}}

📊 **今日汇总**
- 已摄入：{{total_intake}} kcal
- 剩余额度：{{remaining}} kcal
- 状态：{{status}} {{status_emoji}}

💡 **建议**：{{suggestion}}
```

**识别失败响应**:
```markdown
## Response: 图片识别失败

抱歉，无法识别这张图片中的食物 😅

可能的原因：
1. 图片不够清晰
2. 食物被遮挡或光线不足

你可以：
1. 重新拍一张更清晰的照片
2. 手动告诉我吃了什么，如："米饭 150g，红烧肉 100g"
```

### 3.5 定义错误处理

```markdown
## Error Handling

### 图片识别失败
- 返回友好提示
- 提供手动输入选项
- 检查多模态模型配置

### 食物不在数据库
- 模糊匹配相近食物
- 提供估算选项
- 允许手动输入热量

### 数据处理异常
- 记录错误日志
- 返回通用错误提示
- 不中断服务
```

## SKILL.md 完整结构

```
SKILL.md
├── Frontmatter (元数据)
├── Title (标题)
├── When to Use (使用场景)
├── When NOT to Use (禁用场景)
├── Workflows (工作流)
│   ├── 初始化流程
│   ├── 图片识别流程
│   ├── 运动记录流程
│   ├── 进度查询流程
│   └── 设置修改流程
├── Response Templates (响应模板)
│   ├── 识别成功
│   ├── 识别失败
│   ├── 进度报告
│   └── 提醒消息
├── Error Handling (错误处理)
└── Notes (注意事项)
```

## 验证标准

- [ ] SKILL.md 文件创建成功
- [ ] 元数据格式正确
- [ ] 唤醒词"胖虎"配置正确
- [ ] 工作流定义清晰
- [ ] 响应模板格式正确

## 下一步

完成本步骤后，继续 [04-user-interaction.md](04-user-interaction.md)。