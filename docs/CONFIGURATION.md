# 配置指南 (Configuration Guide)

本文档详细说明 Easy Slim Skill 的配置方式，包括多模态模型配置、提醒配置、数据路径配置等。

## 目录

1. [多模态模型配置](#多模态模型配置)
2. [QClaw 配置](#qclaw-配置)
3. [OpenClaw 配置](#openclaw-配置)
4. [技能加载配置](#技能加载配置)
5. [提醒系统配置](#提醒系统配置)
6. [常见配置问题](#常见配置问题)

---

## 多模态模型配置

### 为什么需要配置多模态模型？

Easy Slim Skill 的核心功能是**食物图片识别**，这需要 AI 模型具备视觉理解能力。

QClaw/OpenClaw 本身**不内置模型**，而是调用您配置的第三方 AI 模型。

### 支持的多模态模型

| 模型 | 提供商 | 图片识别能力 | 推荐指数 |
|------|--------|--------------|----------|
| Claude 3.5/4.x | Anthropic | ⭐⭐⭐⭐⭐ | 强烈推荐 |
| GPT-4 Vision | OpenAI | ⭐⭐⭐⭐⭐ | 强烈推荐 |
| GPT-4o | OpenAI | ⭐⭐⭐⭐⭐ | 推荐 |
| 通义千问 VL | 阿里云 | ⭐⭐⭐⭐ | 推荐（国产） |
| Gemini Pro Vision | Google | ⭐⭐⭐⭐ | 推荐 |
| 智谱 GLM-4V | 智谱AI | ⭐⭐⭐⭐ | 推荐（国产） |

### 配置步骤

#### 方式一：通过 QClaw 设置界面配置

1. 打开 QClaw 应用
2. 进入 **设置** → **模型配置**
3. 选择支持多模态的模型（如 Claude、GPT-4V）
4. 配置 API Key 或 OAuth 认证
5. 确保 **图片模型** 设置正确：
   - 如果主模型支持图片，可使用主模型
   - 如果主模型不支持图片，需单独配置 `imageModel`

#### 方式二：通过 OpenClaw CLI 配置

```bash
# 查看当前模型配置
openclaw models list

# 设置主模型（支持多模态）
openclaw models set --primary anthropic/claude-sonnet-4-6

# 或单独设置图片模型
openclaw models set --image-model anthropic/claude-sonnet-4-6

# 添加模型别名
openclaw models alias add --name vision --model anthropic/claude-sonnet-4-6
```

#### 方式三：编辑配置文件

编辑 `~/.openclaw/agents/default/agent.json`：

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-sonnet-4-6"
      },
      "imageModel": {
        "primary": "anthropic/claude-sonnet-4-6"
      }
    }
  }
}
```

### API Key 配置

#### Anthropic (Claude)

```bash
# 方式一：环境变量
export ANTHROPIC_API_KEY="your-api-key"

# 方式二：OpenClaw 认证配置
openclaw auth add --provider anthropic --api-key "your-api-key"
```

#### OpenAI (GPT-4V)

```bash
# 方式一：环境变量
export OPENAI_API_KEY="your-api-key"

# 方式二：OpenClaw 认证配置
openclaw auth add --provider openai --api-key "your-api-key"
```

#### 阿里云 (通义千问 VL)

```bash
# 配置阿里云 API Key
export ALIBABA_API_KEY="your-api-key"

# OpenClaw 配置
openclaw auth add --provider alibaba --api-key "your-api-key"
```

---

## QClaw 配置

### 微信/QQ 绑定

QClaw 支持微信和 QQ 直连，实现消息推送。

#### 微信绑定步骤

1. 打开 QClaw 应用
2. 进入 **设置** → **渠道配置** → **微信**
3. 使用微信扫描二维码
4. 确认绑定成功

#### QQ 绑定步骤

1. 打开 QClaw 应用
2. 进入 **设置** → **渠道配置** → **QQ**
3. 使用 QQ 扫码或输入账号授权
4. 确认绑定成功

### 添加技能路径

在 QClaw 中添加技能目录：

1. 进入 **设置** → **技能管理**
2. 点击 **添加技能路径**
3. 选择 Easy Slim Skill 所在目录
4. 确认加载成功

---

## OpenClaw 配置

### Gateway 启动

```bash
# 启动 Gateway（后台运行）
openclaw gateway --port 18789

# 或使用守护进程
openclaw onboard --install-daemon
```

### 技能加载

```bash
# 添加技能
openclaw skills add --path /path/to/easy-slim-skill

# 查看已加载技能
openclaw skills list

# 验证技能加载
openclaw skills verify --name easy-slim
```

### 渠道配置

```bash
# 配置 Telegram（示例）
openclaw channels add telegram --token "your-bot-token"

# 配置 Discord（示例）
openclaw channels add discord --token "your-bot-token"

# 配置微信（通过 QClaw 更方便）
```

---

## 技能加载配置

### SKILL.md 位置

技能文件必须放在项目根目录：

```
easy-slim-skill/
├── SKILL.md          ← 必须在此位置
├── data/
├── docs/
└── README.md
```

### 技能元数据配置

SKILL.md 头部配置：

```yaml
---
name: easy-slim
description: "减肥助手技能：食物热量识别、定时提醒、进度追踪"
metadata:
  openclaw:
    emoji: "🎯"
    triggers:
      - "减肥"
      - "瘦身"
      - "饮食"
      - "打卡"
      - "记录"
      - "进度"
      - "运动"
    image_trigger: true    # 图片消息触发
    requires:
      bins: []
      files:
        - "data/foods_merged.json"
---
```

---

## 提醒系统配置

### 默认提醒时间

| 时间 | 提醒内容 |
|------|----------|
| 07:30 | 晨起打卡 |
| 12:00 | 午餐提醒 |
| 18:00 | 晚餐提醒 |
| 19:30 | 运动提醒 |

### 自定义提醒时间

通过对话设置：

```
设置提醒时间：
早上 7:00
午餐 11:30
晚餐 17:30
运动 20:00
```

### Cron 配置

```bash
# 查看当前定时任务
openclaw cron list

# 手动添加定时任务
openclaw cron add --name "easy-slim-morning" \
  --cron "30 7 * * *" \
  --message "早上好！记得打卡记录今日体重哦～"

# 删除定时任务
openclaw cron delete --id <task-id>
```

### 提醒语气配置

可选三种语气：

| 语气 | 示例 |
|------|------|
| **gentle**（温柔） | "亲爱的，该运动啦～加油！" |
| **strict**（严厉） | "快点去运动！别偷懒！" |
| **funny**（幽默） | "再不运动就要变成小龙虾了🦞" |

设置方式：
```
更换提醒语气为温柔
```

---

## 常见配置问题

### Q: 图片识别失败

**可能原因**:

1. 未配置多模态模型
2. API Key 无效或过期
3. 网络连接问题
4. 模型不支持中文食物识别

**解决方案**:

```bash
# 检查模型配置
openclaw models list

# 检查认证状态
openclaw auth status

# 测试模型连通性
openclaw models test --image test_data/sample_images/rice_bowl.jpg
```

### Q: 提醒消息不推送

**可能原因**:

1. Gateway 未运行
2. 微信/QQ 未绑定
3. Cron 任务未启用

**解决方案**:

```bash
# 检查 Gateway 状态
openclaw gateway status

# 检查渠道连接
openclaw channels status

# 检查 Cron 任务
openclaw cron list
openclaw cron runs --name "easy-slim-morning"
```

### Q: 技能未加载

**可能原因**:

1. SKILL.md 路径错误
2. SKILL.md 格式错误
3. 技能目录权限问题

**解决方案**:

```bash
# 验证技能文件
openclaw skills verify --path /path/to/easy-slim-skill

# 查看技能日志
openclaw skills logs --name easy-slim
```

### Q: 食物数据库加载失败

**可能原因**:

1. `foods_merged.json` 文件不存在
2. JSON 格式错误
3. 文件过大

**解决方案**:

```bash
# 检查文件是否存在
ls -la data/foods_merged.json

# 验证 JSON 格式
cat data/foods_merged.json | jq .

# 如果文件过大，考虑分片加载
```

---

## 配置检查清单

完成以下配置后，技能即可正常使用：

- [ ] 多模态模型已配置
- [ ] API Key 已设置
- [ ] 微信/QQ 已绑定（如需消息推送）
- [ ] Gateway 正常运行
- [ ] 技能已加载
- [ ] 食物数据库文件存在
- [ ] Cron 任务已配置（如需定时提醒）

## 下一步

配置完成后，参考 [README.md](../README.md) 开始使用技能。