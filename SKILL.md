---
name: easy-slim
description: "减肥助手技能：食物热量识别、定时提醒、进度追踪。支持拍照记录饮食、自动计算热量、生成减肥建议。"
metadata:
  openclaw:
    emoji: "🦞"
    wake_word: "胖虎"
    triggers:
      - "胖虎"
      - "你好胖虎"
      - "你好，胖虎"
      - "嗨胖虎"
      - "嗨，胖虎"
      - "哈喽胖虎"
      - "hello胖虎"
    image_trigger: true
    requires:
      files:
        - "data/foods_merged.json"
        - "data/prompts/gentle.md"
        - "data/prompts/strict.md"
        - "data/prompts/funny.md"
---

# Easy Slim - 减肥助手技能

一个帮助你追踪饮食、管理热量的智能减肥助手。支持拍照识别食物、自动计算热量、定时提醒。

---

## 目录

1. [触发条件](#触发条件)
2. [核心工作流](#核心工作流)
3. [图片识别详细流程](#图片识别详细流程)
4. [食物匹配逻辑](#食物匹配逻辑)
5. [热量计算逻辑](#热量计算逻辑)
6. [响应模板](#响应模板)
7. [错误处理](#错误处理)
8. [数据存储](#数据存储)

---

## 触发条件

### 唤醒词机制

**本技能使用"胖虎"作为唤醒词**。用户需要先说"胖虎"或"你好胖虎"来激活技能。

### 唤醒方式

用户可以通过以下方式唤醒胖虎：

| 唤醒词示例 | 说明 |
|-----------|------|
| "胖虎" | 直接叫名字 |
| "你好胖虎" | 打招呼 + 名字 |
| "你好，胖虎" | 带逗号分隔 |
| "嗨胖虎" | 嗨 + 名字 |
| "哈喽胖虎" | 哈喽 + 名字 |

### 触发规则

```
规则：消息必须包含"胖虎"才会触发本技能

✅ 会触发：
   - "胖虎，帮我看看这顿饭多少热量"
   - "你好胖虎，我今天吃了米饭和红烧肉"
   - "嗨胖虎，查看我的进度"
   - "胖虎 帮我制定减肥计划"
   - [发送图片] + "胖虎帮我识别"

❌ 不会触发：
   - "帮我看看这顿饭多少热量"（没有唤醒词）
   - "今天吃了米饭"（没有唤醒词）
   - "减肥计划"（没有唤醒词）
```

### 自动触发场景

| 场景 | 触发条件 | 执行操作 |
|------|----------|----------|
| 唤醒+图片 | 消息包含"胖虎" + 发送图片 | 触发食物识别流程 |
| 唤醒+初始化 | 消息包含"胖虎" + "减肥计划"/"开始减肥" | 检查用户状态，启动初始化 |
| 唤醒+记录 | 消息包含"胖虎" + "吃了"/"打卡"/"记录" | 记录饮食或运动 |
| 唤醒+查询 | 消息包含"胖虎" + "进度"/"查看"/"今天" | 返回进度报告 |
| 唤醒+设置 | 消息包含"胖虎" + "设置"/"修改"/"更换" | 进入设置模式 |

### 判断优先级

```
唤醒词检测 → 意图识别 → 执行对应工作流

Step 1: 检查消息是否包含"胖虎"
Step 2: 如果包含，提取用户意图
Step 3: 根据意图执行对应操作
Step 4: 如果只有唤醒词没有具体指令，返回帮助提示
```

### 纯唤醒响应

当用户只发送"胖虎"或"你好胖虎"时：

```
回复模板：
"🦞 胖虎在这里！有什么可以帮你的？

你可以：
📸 发送食物照片 → 我帮你计算热量
📝 告诉我你吃了什么 → 记录饮食
🏃 告诉我运动情况 → 记录运动
📊 发送「查看进度」→ 查看减肥情况
⚙️ 发送「设置提醒」→ 配置提醒时间

试试说：胖虎，我今天吃了米饭和红烧肉"
```

---

## 核心工作流

### Workflow 1: 用户初始化

**触发条件**: 用户首次使用或发送"开始减肥"

**执行步骤**:

```
Step 1: 检查用户档案
        读取 data/profile.json
        
        IF 文件不存在 THEN
            进入引导式问答模式
        ELSE
            返回欢迎回来消息
        END IF

Step 2: 引导式问答（新用户）

        问: "请告诉我你的身高是多少厘米？(范围: 100-250)"
        验证: 输入必须是 100-250 之间的数字
        存储: height = 用户输入
        
        问: "请告诉我你的体重是多少公斤？(范围: 30-300)"
        验证: 输入必须是 30-300 之间的数字
        存储: weight = 用户输入
        
        问: "请告诉我你的年龄？(范围: 10-120)"
        验证: 输入必须是 10-120 之间的数字
        存储: age = 用户输入
        
        问: "请选择你的性别：
             1. 男
             2. 女"
        验证: 输入必须是 1 或 2
        存储: gender = "male" 或 "female"
        
        问: "你的目标体重是多少公斤？"
        验证: 必须小于当前体重
        存储: target_weight = 用户输入
        
        问: "你计划用多少周达到目标？(建议 8-24 周)"
        验证: 建议 8-24 周，但不强制
        存储: target_weeks = 用户输入
        
        问: "请选择你喜欢的提醒语气：
             1. 温柔鼓励型 💗
             2. 严厉督促型 💪
             3. 幽默搞怪型 🦞"
        验证: 输入必须是 1、2 或 3
        存储: reminder_style = "gentle" / "strict" / "funny"

Step 3: 计算身体数据
        
        计算 BMR (基础代谢率):
        IF gender == "male" THEN
            bmr = 10 × weight + 6.25 × height - 5 × age + 5
        ELSE
            bmr = 10 × weight + 6.25 × height - 5 × age - 161
        END IF
        
        计算 TDEE (每日总消耗):
        activity_factor = 1.375  // 默认轻度活动
        tdee = bmr × activity_factor
        
        计算每日热量目标:
        weekly_loss = (weight - target_weight) / target_weeks
        calorie_deficit = weekly_loss × 1100  // 每周减1kg约需7700kcal缺口
        daily_target = tdee - calorie_deficit
        
        安全检查:
        IF gender == "male" AND daily_target < 1500 THEN
            daily_target = 1500
            提示: "热量目标已调整至安全最低值 1500kcal"
        ELSE IF gender == "female" AND daily_target < 1200 THEN
            daily_target = 1200
            提示: "热量目标已调整至安全最低值 1200kcal"
        END IF

Step 4: 生成减肥计划
        
        三餐配比:
        breakfast_ratio = 0.30  // 早餐 30%
        lunch_ratio = 0.40      // 午餐 40%
        dinner_ratio = 0.30    // 晚餐 30%
        
        各餐热量目标:
        breakfast_calories = daily_target × 0.30
        lunch_calories = daily_target × 0.40
        dinner_calories = daily_target × 0.30

Step 5: 保存用户数据
        
        写入 data/profile.json:
        {
            "height": height,
            "weight": weight,
            "age": age,
            "gender": gender,
            "target_weight": target_weight,
            "target_weeks": target_weeks,
            "bmr": bmr,
            "tdee": tdee,
            "daily_calorie_target": daily_target,
            "reminder_style": reminder_style,
            "reminder_times": {
                "morning": "07:30",
                "lunch": "12:00",
                "dinner": "18:00",
                "exercise": "19:30"
            },
            "created_at": "当前时间 ISO 8601",
            "updated_at": "当前时间 ISO 8601"
        }
        
        写入 data/plan.json:
        {
            "start_weight": weight,
            "target_weight": target_weight,
            "target_weeks": target_weeks,
            "daily_calorie_target": daily_target,
            "daily_protein_target": daily_target × 0.15 / 4,  // 15%热量来自蛋白质
            "daily_carbs_target": daily_target × 0.55 / 4,    // 55%热量来自碳水
            "daily_fat_target": daily_target × 0.30 / 9,     // 30%热量来自脂肪
            "meal_distribution": {
                "breakfast": { "calories": breakfast_calories, "ratio": 0.30 },
                "lunch": { "calories": lunch_calories, "ratio": 0.40 },
                "dinner": { "calories": dinner_calories, "ratio": 0.30 }
            },
            "exercise_recommendation": {
                "type": "有氧运动",
                "frequency": "每周 3-5 次",
                "duration": "每次 30-45 分钟"
            },
            "created_at": "当前时间 ISO 8601"
        }

Step 6: 返回初始化成功消息
        
        使用 [响应模板: 初始化成功](#响应模板-初始化成功)
```

---

## 图片识别详细流程

### Workflow 2: 食物图片识别

**触发条件**: 用户发送图片消息

**执行步骤**:

```
Step 1: 接收图片消息
        
        QClaw 接收到用户发送的图片
        图片格式: JPEG/PNG/WebP
        图片数据: Base64 编码 或 临时文件路径

Step 2: 调用多模态模型进行识别
        
        构造发送给模型的内容:
        
        === 发送给模型的内容开始 ===
        
        [图片数据]
        
        你是一位专业的食物营养识别专家。请仔细识别这张图片中的所有食物。

## 识别要求

1. **识别所有可见食物**
   - 不要遗漏任何食物
   - 包括主食、菜肴、饮品、调料等

2. **估算份量**
   - 根据餐具大小估算克数
   - 普通饭碗 ≈ 150g 米饭
   - 普通盘子 ≈ 200-300g 菜肴
   - 普通杯子 ≈ 250ml 饮品

3. **置信度评估**
   - 0.9+ : 非常确定
   - 0.7-0.9: 比较确定
   - 0.5-0.7: 不太确定
   - < 0.5 : 猜测

4. **图片质量评估**
   - good: 清晰，光线充足，食物可见
   - medium: 基本可识别，有一定模糊或遮挡
   - poor: 模糊、光线差、无法识别

## 返回格式

请严格返回以下 JSON 格式，不要添加任何解释：

```json
{
  "foods": [
    {
      "name": "食物中文名",
      "name_en": "English name",
      "estimated_grams": 数值,
      "confidence": 0.0-1.0,
      "category": "carbs|protein|vegetable|meat|seafood|dairy|fruit|beverage|snack|other"
    }
  ],
  "image_quality": "good|medium|poor",
  "meal_type": "breakfast|lunch|dinner|snack",
  "total_estimated_calories": 数值,
  "notes": "识别备注"
}
```

## 示例

如果图片是一碗米饭和一份红烧肉，返回：

```json
{
  "foods": [
    {
      "name": "白米饭",
      "name_en": "White Rice",
      "estimated_grams": 150,
      "confidence": 0.95,
      "category": "carbs"
    },
    {
      "name": "红烧肉",
      "name_en": "Braised Pork",
      "estimated_grams": 80,
      "confidence": 0.85,
      "category": "meat"
    }
  ],
  "image_quality": "good",
  "meal_type": "lunch",
  "total_estimated_calories": 475,
  "notes": "图片清晰，普通饭碗大小的米饭，小碟红烧肉"
}
```

现在请识别这张图片中的食物，只返回 JSON。
        
        === 发送给模型的内容结束 ===

Step 3: 接收模型返回
        
        模型返回纯文本 JSON 格式的识别结果
        
        示例返回（一碗米饭的情况）:
        
        ```json
        {
          "foods": [
            {
              "name": "白米饭",
              "name_en": "White Rice",
              "estimated_grams": 150,
              "confidence": 0.95,
              "category": "carbs"
            }
          ],
          "image_quality": "good",
          "meal_type": "lunch",
          "total_estimated_calories": 195,
          "notes": "普通饭碗的白米饭，图片清晰"
        }
        ```

Step 4: 解析识别结果
        
        解析 JSON:
        - 提取 foods 数组
        - 提取 image_quality
        - 提取 meal_type
        - 提取 notes
        
        错误处理:
        IF JSON 解析失败 THEN
            执行 [错误处理: JSON 解析失败](#错误处理-json-解析失败)
            终止流程
        END IF
        
        空结果处理:
        IF foods 数组为空 THEN
            执行 [错误处理: 未识别到食物](#错误处理-未识别到食物)
            终止流程
        END IF

Step 5: 检查图片质量
        
        IF image_quality == "poor" THEN
            发送警告消息:
            "⚠️ 图片质量较差，识别结果可能不准确。
             建议重新拍照，确保：
             - 光线充足
             - 食物清晰可见
             - 无遮挡
            
             如果确认使用当前结果，请回复「确认」"
            
            等待用户确认
        END IF

Step 6: 遍历食物列表进行匹配
        
        FOR EACH food IN foods DO
            执行 [食物匹配逻辑](#食物匹配逻辑)
            将匹配结果添加到 food.matched_data
        END FOR

Step 7: 计算热量
        
        执行 [热量计算逻辑](#热量计算逻辑)

Step 8: 生成用户报告
        
        使用 [响应模板: 食物识别成功](#响应模板-食物识别成功)

Step 9: 存储记录
        
        执行 [数据存储](#数据存储)
```

---

## 食物匹配逻辑

### 处理每个识别到的食物

```
输入: food 对象（来自模型识别结果）
输出: 匹配的食物数据库条目

Step 1: 加载食物数据库
        
        读取 data/foods_merged.json
        解析为 foods_array

Step 2: 精确匹配
        
        在 foods_array 中搜索:
        WHERE food.name == 数据库条目.name
        
        IF 找到精确匹配 THEN
            RETURN 匹配结果
            matched_type = "exact"
        END IF

Step 3: 拼音匹配（针对中国食物）
        
        将 food.name 转换为拼音
        在 foods_array 中搜索拼音匹配
        
        IF 找到拼音匹配 THEN
            RETURN 匹配结果
            matched_type = "pinyin"
        END IF

Step 4: 模糊匹配
        
        计算编辑距离:
        FOR EACH item IN foods_array DO
            distance = levenshtein(food.name, item.name)
            IF distance <= 2 THEN
                添加到候选列表
            END IF
        END FOR
        
        IF 候选列表不为空 THEN
            按相似度排序
            RETURN 最相似的候选
            matched_type = "fuzzy"
        END IF

Step 5: 分类匹配
        
        IF food.category 存在 THEN
            在 foods_array 中搜索同分类食物
            按热量排序
            RETURN 分类中的中位热量食物
            matched_type = "category"
        END IF

Step 6: 无匹配
        
        RETURN null
        matched_type = "none"
```

### 匹配结果结构

```json
{
  "input_name": "白米饭",
  "matched_name": "白米饭",
  "matched_type": "exact",
  "nutrition_per_100g": {
    "calories": 130,
    "protein": 2.4,
    "carbs": 28.2,
    "fat": 0.3
  },
  "confidence": 0.95
}
```

### 无匹配时的处理

```
IF matched_type == "none" THEN
    返回提示:
    
    "🤔 数据库暂无「{{food.name}}」的精确数据
    
    您可以选择：
    
    **相近食物替代**：
    {{列出相似分类的食物，前3个}}
    
    **手动输入**：
    告诉我这种食物的大概热量，格式：「{{food.name}} 200kcal」
    
    **跳过此项**：
    回复「跳过」不记录此食物"
END IF
```

---

## 热量计算逻辑

### 计算单个食物热量

```
输入: 
  - matched_data: 匹配的食物数据库条目
  - estimated_grams: 估算的克数

输出:
  - calculated_calories: 计算出的热量

计算公式:
calculated_calories = (estimated_grams / 100) × matched_data.nutrition_per_100g.calories

示例:
  - 白米饭: (150g / 100) × 130kcal = 195kcal
  - 红烧肉: (80g / 100) × 350kcal = 280kcal
```

### 计算整餐热量

```
total_meal_calories = SUM(food.calculated_calories FOR EACH food IN foods)

示例:
  - 白米饭: 195kcal
  - 红烧肉: 280kcal
  - 总计: 475kcal
```

### 计算今日汇总

```
Step 1: 读取今日日志
        
        日志文件: data/logs/2026-05-04.json
        
        IF 文件不存在 THEN
            创建新日志文件
            today_intake = 0
            today_burned = 0
        ELSE
            读取 today_intake = 已记录的总摄入
            读取 today_burned = 已记录的运动消耗
        END IF

Step 2: 更新今日数据
        
        new_intake = today_intake + total_meal_calories
        net_calories = new_intake - today_burned

Step 3: 计算剩余额度
        
        读取 data/profile.json 获取 daily_calorie_target
        remaining = daily_calorie_target - new_intake

Step 4: 判断状态
        
        IF remaining >= 200 THEN
            status = "on_track"
            status_text = "良好"
            status_emoji = "✅"
        ELSE IF remaining >= 0 THEN
            status = "warning"
            status_text = "注意"
            status_emoji = "⚠️"
        ELSE
            status = "over"
            status_text = "超标"
            status_emoji = "🔴"
        END IF
```

---

## 响应模板

### 响应模板: 初始化成功

```
🎉 减肥计划已生成！

📊 **你的身体数据**
| 指标 | 数值 |
|------|------|
| 身高 | {{height}} cm |
| 体重 | {{weight}} kg |
| BMI | {{bmi}} |
| BMR | {{bmr}} kcal/天 |
| TDEE | {{tdee}} kcal/天 |

🎯 **你的减肥目标**
| 项目 | 数值 |
|------|------|
| 目标体重 | {{target_weight}} kg |
| 计划周期 | {{target_weeks}} 周 |
| 每周减重 | {{weekly_loss}} kg |
| 每日热量目标 | {{daily_target}} kcal |

🍽️ **三餐建议配比**
| 餐次 | 热量 | 占比 |
|------|------|------|
| 早餐 | {{breakfast_cal}} kcal | 30% |
| 午餐 | {{lunch_cal}} kcal | 40% |
| 晚餐 | {{dinner_cal}} kcal | 30% |

⏰ **提醒时间已设置**
- 🌅 晨起打卡: {{morning_time}}
- 🍜 午餐提醒: {{lunch_time}}
- 🍚 晚餐提醒: {{dinner_time}}
- 🏃 运动提醒: {{exercise_time}}

💬 **提醒语气**: {{reminder_style_name}}

---

🚀 **开始使用**

现在你可以：
1. 📸 拍一张食物照片发给我，自动识别并记录
2. ✍️ 发送文字记录，如「今天中午吃了米饭一碗」
3. 🏃 记录运动，如「今天跑步30分钟」
4. 📊 随时发送「查看进度」了解减肥情况

准备好了吗？发送你的第一餐开始记录吧！ 💪
```

### 响应模板: 食物识别成功

```
🍽️ **已识别你的{{meal_type}}**

{{#each foods}}
| {{emoji}} {{name}} | {{grams}}g | {{calories}} kcal |
{{/each}}

---

📊 **今日汇总**
```
摄入进度：{{▓▓▓▓▓▓░░░░}} {{intake_percentage}}%

| 指标 | 数值 |
|------|------|
| 本餐摄入 | {{meal_calories}} kcal |
| 今日已摄入 | {{total_intake}} kcal |
| 剩余额度 | {{remaining}} kcal |
| 状态 | {{status_emoji}} {{status_text}} |
```

💡 **建议**

{{#if on_track}}
干得漂亮！这餐热量控制得很好 👍
{{#if remaining < 300}}
今天剩余额度不多了，晚餐建议清淡一些，可以选择蔬菜沙拉或清汤面。
{{else}}
继续保持，今天还有充足的额度可以安排哦～
{{/if}}
{{else}}
今日热量已超标 {{#if over_amount}}({{over_amount}} kcal){{/if}}。

建议：
- 晚餐尽量清淡，减少碳水摄入
- 可以增加30分钟运动消耗多余热量
- 明天注意控制早餐和午餐热量
{{/if}}
```

### 响应模板: 识别失败

```
😅 抱歉，无法识别这张图片中的食物

**可能的原因**：
- 📷 图片模糊或光线不足
- 🍽️ 食物被遮挡或不清晰
- 🥗 这种食物可能不在我的数据库中

**你可以这样做**：

**方式一：重新拍照**
确保图片清晰、光线充足、食物完整可见

**方式二：手动记录**
告诉我具体吃了什么，例如：
```
米饭一碗，红烧肉几块，青菜一份
```

**方式三：简化记录**
直接告诉我大概热量：
```
中午吃了约500卡
```

---

💡 **小技巧**
拍照时注意：
- ✅ 光线充足（自然光最佳）
- ✅ 食物完整在画面中
- ✅ 避免遮挡和阴影
```

### 响应模板: 需要确认

```
🤔 我看到可能是以下食物，请帮我确认：

{{#each foods}}
{{@index}}. {{name}}（约{{calories}} kcal）
{{/each}}

回复数字选择，或者告诉我具体是什么～

如果都不对，回复「其他」手动输入。
```

---

## 错误处理

### 错误处理: JSON 解析失败

```
场景: 模型返回的内容不是有效的 JSON 格式

处理步骤:
1. 记录原始返回内容到错误日志
2. 尝试提取 JSON 部分（使用正则表达式）
3. IF 仍无法解析 THEN
       发送提示消息：
       "数据处理出现异常，请稍后重试。
        如问题持续，请手动输入食物信息。"
   END IF
```

### 错误处理: 未识别到食物

```
场景: foods 数组为空

处理步骤:
1. 检查 image_quality 字段
2. IF image_quality == "poor" THEN
       发送提示：
       "图片质量较差，无法识别食物内容。
        请重新拍照，确保：
        • 光线充足
        • 食物清晰可见
        • 无遮挡和阴影"
   ELSE
       发送提示：
       "这张图片似乎没有食物呢 🤔
        如果这是一餐，请：
        • 重新拍照发送
        • 或手动告诉我吃了什么"
   END IF
```

### 错误处理: 食物不在数据库

```
场景: 食物匹配返回 null（matched_type == "none"）

处理步骤:
1. 尝试获取同分类食物列表
2. 发送提示：

"🤔 数据库暂无「{{food_name}}」的精确数据

**相近替代**：
{{#each similar_foods}}
• {{name}} - {{calories}} kcal/100g
{{/each}}

**你可以**：
1. 选择替代食物 - 回复食物名
2. 手动输入热量 - 回复「{{food_name}} XXX kcal」
3. 跳过此项 - 回复「跳过」"

3. 等待用户回复
4. 根据回复处理：
   - 选择替代: 使用替代食物数据
   - 手动输入: 使用用户提供的数值
   - 跳过: 不记录此食物
```

### 错误处理: 多模态模型不可用

```
场景: 模型调用失败（API 错误、网络问题等）

处理步骤:
1. 记录错误详情到日志
2. 发送提示：

"⚠️ 图片识别服务暂时不可用

可能的原因：
• 网络连接问题
• AI 服务繁忙

**临时解决方案**：
手动告诉我吃了什么，例如：
```
米饭一碗，西红柿炒蛋一份
```

稍后我会恢复图片识别功能。"

3. 接受用户手动输入的文字记录
```

---

## 数据存储

### 存储结构

```
data/
├── profile.json          # 用户档案
├── plan.json             # 减肥计划
├── foods_merged.json     # 食物数据库（只读）
├── prompts/              # 提醒语气模板（只读）
│   ├── gentle.md
│   ├── strict.md
│   └── funny.md
└── logs/                 # 每日记录
    ├── 2026-05-04.json
    ├── 2026-05-05.json
    └── ...
```

### 日志文件格式

```json
{
  "date": "2026-05-04",
  "meals": [
    {
      "id": "meal_001",
      "time": "12:30",
      "type": "lunch",
      "image_recognition": true,
      "foods": [
        {
          "name": "白米饭",
          "grams": 150,
          "calories": 195,
          "protein": 3.6,
          "carbs": 42.3,
          "fat": 0.45,
          "matched_type": "exact",
          "confidence": 0.95
        },
        {
          "name": "红烧肉",
          "grams": 80,
          "calories": 280,
          "protein": 12.8,
          "carbs": 5.6,
          "fat": 25.6,
          "matched_type": "exact",
          "confidence": 0.85
        }
      ],
      "total_calories": 475,
      "notes": ""
    }
  ],
  "exercises": [
    {
      "id": "ex_001",
      "time": "19:30",
      "type": "跑步",
      "duration_min": 30,
      "calories_burned": 250
    }
  ],
  "weight": 68.5,
  "summary": {
    "total_intake": 1500,
    "total_burned": 250,
    "net_calories": 1250,
    "protein_intake": 65,
    "carbs_intake": 180,
    "fat_intake": 50,
    "calorie_remaining": 300,
    "goal_status": "on_track"
  },
  "created_at": "2026-05-04T08:00:00Z",
  "updated_at": "2026-05-04T20:30:00Z"
}
```

### 写入日志流程

```
Step 1: 读取当日日志文件
        
        文件路径: data/logs/{{YYYY-MM-DD}}.json
        
        IF 文件不存在 THEN
            创建新日志:
            {
              "date": "{{YYYY-MM-DD}}",
              "meals": [],
              "exercises": [],
              "summary": {}
            }
        END IF

Step 2: 添加新记录
        
        添加到 meals 数组:
        {
          "id": "meal_{{timestamp}}",
          "time": "{{当前时间 HH:MM}}",
          "type": "{{meal_type}}",
          "image_recognition": true,
          "foods": [{{识别结果}}],
          "total_calories": {{本餐热量}},
          "notes": "{{notes}}"
        }

Step 3: 更新汇总
        
        重新计算 summary 字段

Step 4: 保存文件
        
        写入 data/logs/{{YYYY-MM-DD}}.json

Step 5: 更新 profile.json
        
        更新 updated_at 字段
```

---

## 附录

### 附录 A: 份量估算参考

| 餐具 | 估算克数 |
|------|----------|
| 小饭碗 | 100-150g |
| 大饭碗 | 150-200g |
| 小盘子 | 150-200g |
| 大盘子 | 250-350g |
| 小勺 | 10-15g |
| 大勺 | 20-30g |
| 普通杯子 | 200-250ml |
| 大杯 | 350-500ml |

### 附录 B: 常见食物热量参考

| 食物 | 热量/100g | 常见份量 |
|------|-----------|----------|
| 白米饭 | 130 kcal | 一碗 150g |
| 馒头 | 220 kcal | 一个 100g |
| 面条（煮） | 110 kcal | 一碗 200g |
| 猪肉 | 143 kcal | - |
| 鸡肉 | 167 kcal | - |
| 牛肉 | 125 kcal | - |
| 鸡蛋 | 144 kcal | 一个 50g |
| 豆腐 | 81 kcal | 一块 100g |
| 白菜 | 14 kcal | - |
| 番茄 | 15 kcal | 一个 150g |

### 附录 C: 运动热量消耗参考

| 运动 | kcal/30分钟（60kg体重） |
|------|-------------------------|
| 快走 | 150 |
| 慢跑 | 250 |
| 游泳 | 300 |
| 骑行 | 200 |
| 瑜伽 | 100 |
| 跳绳 | 300 |
| 力量训练 | 150 |
| 跳舞 | 180 |