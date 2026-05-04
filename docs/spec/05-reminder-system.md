# Step 5: 提醒系统

## 目标

实现定时提醒功能，通过 QClaw/OpenClaw 的 Cron 系统实现微信/QQ 消息推送。

## 前置条件

- 完成 [04-user-interaction.md](04-user-interaction.md)
- QClaw/OpenClaw Gateway 正常运行
- 微信/QQ 已绑定

## 任务清单

### 5.1 理解 OpenClaw Cron 系统

**Cron 命令结构**:
```bash
openclaw cron add \
  --name "<task-name>" \
  --cron "<cron-expression>" \
  --message "<message-content>" \
  --channel "<channel-id>"
```

**Cron 表达式格式**:
```
分 时 日 月 周
│ │ │ │ │
│ │ │ │ └── 星期几 (0-6, 0=周日)
│ │ │ └──── 月份 (1-12)
│ │ └────── 日期 (1-31)
│ └──────── 小时 (0-23)
└────────── 分钟 (0-59)
```

**示例**:
- `30 7 * * *` - 每天 7:30
- `0 12 * * *` - 每天 12:00
- `30 19 * * 1-5` - 周一到周五 19:30

### 5.2 默认提醒时间配置

| 提醒类型 | 默认时间 | Cron 表达式 |
|----------|----------|-------------|
| 晨起打卡 | 07:30 | `30 7 * * *` |
| 午餐提醒 | 12:00 | `0 12 * * *` |
| 晚餐提醒 | 18:00 | `0 18 * * *` |
| 运动提醒 | 19:30 | `30 19 * * *` |

### 5.3 提醒消息模板

**创建 `data/prompts/reminder_messages.md`**:

```markdown
# Reminder Messages Templates

## 晨起打卡提醒

### gentle (温柔)
亲爱的，早上好！☀️ 新的一天开始啦～
记得称一下体重并记录哦，每一点进步都值得被记录！

### strict (严厉)
起床！立刻去称体重并记录！
不要找借口，减肥需要自律！

### funny (幽默)
早起的鸟儿有虫吃，早起的你在减肥路上冲冲冲！🦞
快去称体重，不然我要开始念叨了～

---

## 午餐提醒

### gentle (温柔)
中午啦～该吃饭了！🍜
记得拍照记录哦，我在这里等你～

### strict (严厉)
午饭时间！拍张照记录！
别想偷偷多吃！

### funny (幽默)
饭点到了！快去吃饭，顺便拍个照让我看看你吃了啥～
（虽然我只是个 AI，但也想云吃一顿）

---

## 晚餐提醒

### gentle (温柔)
晚上好！今天辛苦了 🌙
记得拍张晚餐照片记录一下～

### strict (严厉)
晚饭时间！拍照记录！控制热量！

### funny (幽默)
晚饭时间到！拍个照吧～
再不记录，我就要以为你今天只喝西北风了 😄

---

## 运动提醒

### gentle (温柔)
运动时间到啦！💪
动起来，让身体更健康～今天也要加油哦！

### strict (严厉)
运动时间！立刻去运动！
不许偷懒！快点！

### funny (幽默)
运动时间！再不运动就要变成小龙虾了！🦞
（虽然小龙虾也很好吃...但还是要运动！）

---

## 进度周报

### template
📊 本周减肥进度报告

📈 体重变化：{{weight_change}} kg
🏃 运动天数：{{exercise_days}} 天
🔥 平均热量：{{avg_calories}} kcal/天

{{#if on_track}}
✅ 表现优秀！继续保持！
{{else}}
⚠️ 加油！下周要更努力哦！
{{/if}}

下周目标：坚持记录，控制饮食，多多运动！
```

### 5.4 创建提醒设置脚本

**创建 `scripts/setup_reminders.sh`**:

```bash
#!/bin/bash

# Easy Slim Skill - Reminder Setup Script
# 此脚本用于配置定时提醒任务

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🦞 Easy Slim Skill - 提醒设置"

# 检查 openclaw 命令是否存在
if ! command -v openclaw &> /dev/null; then
    echo -e "${RED}错误: 未找到 openclaw 命令${NC}"
    echo "请确保已安装 OpenClaw 并将其添加到 PATH"
    exit 1
fi

# 检查 Gateway 状态
echo "检查 Gateway 状态..."
if ! openclaw gateway status &> /dev/null; then
    echo -e "${YELLOW}警告: Gateway 未运行${NC}"
    echo "请先启动 Gateway: openclaw gateway"
    exit 1
fi

# 读取用户配置
PROFILE_FILE="data/profile.json"
if [ ! -f "$PROFILE_FILE" ]; then
    echo -e "${YELLOW}提示: 未找到用户配置，使用默认提醒时间${NC}"
    MORNING="30 7"
    LUNCH="0 12"
    DINNER="0 18"
    EXERCISE="30 19"
else
    # 解析用户配置中的提醒时间
    # 需要 jq 工具
    if command -v jq &> /dev/null; then
        MORNING=$(jq -r '.reminder_times.morning // "07:30"' "$PROFILE_FILE" | sed 's/:/ /')
        LUNCH=$(jq -r '.reminder_times.lunch // "12:00"' "$PROFILE_FILE" | sed 's/:/ /')
        DINNER=$(jq -r '.reminder_times.dinner // "18:00"' "$PROFILE_FILE" | sed 's/:/ /')
        EXERCISE=$(jq -r '.reminder_times.exercise // "19:30"' "$PROFILE_FILE" | sed 's/:/ /')
    fi
fi

# 创建提醒任务
echo "创建提醒任务..."

# 晨起打卡
openclaw cron add \
    --name "easy-slim-morning" \
    --cron "$MARNING * * *" \
    --message "type=reminder&time=morning" \
    --skill "easy-slim"

# 午餐提醒
openclaw cron add \
    --name "easy-slim-lunch" \
    --cron "$LUNCH * * *" \
    --message "type=reminder&time=lunch" \
    --skill "easy-slim"

# 晚餐提醒
openclaw cron add \
    --name "easy-slim-dinner" \
    --cron "$DINNER * * *" \
    --message "type=reminder&time=dinner" \
    --skill "easy-slim"

# 运动提醒
openclaw cron add \
    --name "easy-slim-exercise" \
    --cron "$EXERCISE * * *" \
    --message "type=reminder&time=exercise" \
    --skill "easy-slim"

echo -e "${GREEN}✅ 提醒设置完成！${NC}"
echo ""
echo "当前提醒时间："
echo "  晨起打卡: $MORNINGING"
echo "  午餐提醒: $LUNCH"
echo "  晚餐提醒: $DINNER"
echo "  运动提醒: $EXERCISE"
echo ""
echo "查看所有任务: openclaw cron list"
```

### 5.5 SKILL.md 中的提醒处理逻辑

```markdown
## Workflow: 处理定时提醒

当收到 Cron 任务触发时：

1. 解析消息参数获取提醒类型 (morning/lunch/dinner/exercise)
2. 读取用户配置获取提醒语气 (gentle/strict/funny)
3. 从 `data/prompts/reminder_messages.md` 加载对应模板
4. 填充模板中的变量（如有）
5. 返回提醒消息到用户微信/QQ
```

### 5.6 用户自定义提醒时间

**通过对话修改**:

```markdown
## Workflow: 修改提醒时间

用户: 把运动提醒改到晚上8点

1. 解析用户意图：修改提醒时间
2. 提取参数：类型=exercise，新时间=20:00
3. 更新 `data/profile.json` 中的 `reminder_times.exercise`
4. 删除旧的 Cron 任务：`openclaw cron delete --name easy-slim-exercise`
5. 创建新的 Cron 任务：`openclaw cron add --name easy-slim-exercise --cron "0 20 * * *"`
6. 返回确认消息
```

## 验证标准

- [ ] Cron 任务创建成功
- [ ] 提醒消息正确发送到微信/QQ
- [ ] 提醒语气可配置
- [ ] 时间可自定义修改

## 测试方法

```bash
# 手动触发提醒测试
openclaw cron run --name easy-slim-morning

# 查看任务运行历史
openclaw cron runs --name easy-slim-morning
```

## 下一步

完成本步骤后，继续 [06-testing.md](06-testing.md)。