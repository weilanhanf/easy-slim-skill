# SPEC.md - 技术规格说明

本文档定义 Easy Slim Skill 的技术规格、数据结构、API 规范和约束条件。

## 版本信息

- **版本**: 1.0.0
- **更新日期**: 2026-05-04
- **兼容性**: QClaw 1.x, OpenClaw 1.x

---

## 1. 技能规格

### 1.1 基本信息定义

| 属性 | 值 |
|------|-----|
| name | `easy-slim` |
| description | 减肥助手技能：食物热量识别、定时提醒、进度追踪 |
| emoji | 🎯 |
| version | 1.0.0 |

### 1.2 触发条件

| 触发类型 | 触发词/条件 | 优先级 |
|----------|-------------|--------|
| 关键词 | 减肥、瘦身、饮食、打卡、记录、进度、运动 | 高 |
| 图片消息 | 用户发送图片 | 最高 |
| 定时触发 | Cron 任务 | 中 |
| 手动调用 | /easy-slim | 低 |

### 1.3 依赖项

| 依赖 | 类型 | 说明 |
|------|------|------|
| 多模态模型 | 外部 | 用于图片识别 |
| foods_merged.json | 本地文件 | 食物营养数据库 |
| OpenClaw Cron | 系统 | 定时任务 |

---

## 2. 数据结构规格

### 2.1 食物数据库 (foods_merged.json)

```typescript
interface FoodDatabase {
  version: number;
  foods: Food[];
}

interface Food {
  id: string;                    // 唯一标识，如 "food_rice_white"
  name: string;                  // 中文名称
  name_en?: string;              // 英文名称（可选）
  category: FoodCategory;        // 分类
  emoji?: string;                // 表情符号
  nutrition_per_100g: Nutrition; // 每100g营养成分
  default_serving?: Serving;     // 默认份量
  source: 'china' | 'global';    // 数据来源
  tags?: string[];               // 标签
  searchTerms?: string[];        // 搜索关键词
}

interface Nutrition {
  calories: number;     // 热量 (kcal)
  protein: number;      // 蛋白质 (g)
  carbs: number;        // 碳水化合物 (g)
  fat: number;          // 脂肪 (g)
  fiber?: number;       // 纤维 (g)
  sodium?: number;      // 钠 (mg)
  cholesterol?: number; // 胆固醇 (mg)
}

interface Serving {
  name: string;   // 份量名称，如 "1碗"
  grams: number;  // 对应克数
}

type FoodCategory = 
  | 'carbs'       // 主食
  | 'protein'     // 蛋白质
  | 'vegetable'   // 蔬菜
  | 'fruit'       // 水果
  | 'dairy'       // 乳制品
  | 'meat'        // 肉类
  | 'seafood'     // 海鲜
  | 'snack'       // 零食
  | 'beverage'    // 饮品
  | 'other';      // 其他
```

### 2.2 用户档案 (profile.json)

```typescript
interface UserProfile {
  // 基本信息
  height: number;           // 身高 (cm)
  weight: number;           // 当前体重 (kg)
  age: number;              // 年龄
  gender: 'male' | 'female';// 性别
  
  // 目标设定
  target_weight: number;    // 目标体重 (kg)
  target_weeks: number;     // 目标周期 (周)
  
  // 计算值（自动生成）
  bmr?: number;             // 基础代谢率
  tdee?: number;            // 每日总消耗
  daily_calorie_target?: number; // 每日热量目标
  
  // 配置
  reminder_style: ReminderStyle;  // 提醒语气
  reminder_times: ReminderTimes;  // 提醒时间
  
  // 元数据
  created_at: string;       // 创建时间 (ISO 8601)
  updated_at: string;       // 更新时间 (ISO 8601)
}

interface ReminderTimes {
  morning: string;    // 晨起提醒时间，如 "07:30"
  lunch: string;      // 午餐提醒时间
  dinner: string;     // 晚餐提醒时间
  exercise: string;   // 运动提醒时间
}

type ReminderStyle = 'gentle' | 'strict' | 'funny';
```

### 2.3 减肥计划 (plan.json)

```typescript
interface DietPlan {
  user_id?: string;         // 用户标识
  
  // 目标信息
  start_weight: number;     // 起始体重 (kg)
  target_weight: number;    // 目标体重 (kg)
  target_weeks: number;     // 计划周期 (周)
  
  // 每日目标
  daily_calorie_target: number;  // 每日热量目标 (kcal)
  daily_protein_target: number;  // 每日蛋白质目标 (g)
  daily_carbs_target: number;    // 每日碳水目标 (g)
  daily_fat_target: number;      // 每日脂肪目标 (g)
  
  // 建议三餐配比
  meal_distribution: {
    breakfast: number;  // 早餐占比，如 0.3 (30%)
    lunch: number;      // 午餐占比
    dinner: number;     // 晚餐占比
  };
  
  // 运动建议
  exercise_recommendation: {
    type: string;       // 运动类型
    frequency: string;  // 频率，如 "每周3次"
    duration: string;   // 时长，如 "每次30分钟"
  };
  
  // 元数据
  created_at: string;
  updated_at: string;
}
```

### 2.4 每日日志 (logs/YYYY-MM-DD.json)

```typescript
interface DailyLog {
  date: string;             // 日期，如 "2026-05-04"
  
  // 饮食记录
  meals: Meal[];
  
  // 运动记录
  exercises: Exercise[];
  
  // 体重记录
  weight?: number;          // 当日体重
  
  // 统计摘要
  summary: DailySummary;
  
  // 元数据
  created_at: string;
  updated_at: string;
}

interface Meal {
  id: string;               // 唯一标识
  time: string;             // 时间，如 "12:30"
  type: MealType;           // 餐次类型
  foods: FoodEntry[];       // 食物列表
  total_calories: number;   // 总热量
  image_path?: string;      // 图片路径（可选）
  notes?: string;           // 备注
}

interface FoodEntry {
  name: string;             // 食物名称
  grams: number;            // 份量 (g)
  calories: number;         // 热量 (kcal)
  protein?: number;
  carbs?: number;
  fat?: number;
  source: 'identified' | 'manual';  // 来源：识别或手动
}

interface Exercise {
  id: string;
  time: string;
  type: string;             // 运动类型
  duration_min: number;     // 时长 (分钟)
  calories_burned: number;  // 消耗热量
  notes?: string;
}

interface DailySummary {
  total_intake: number;     // 总摄入 (kcal)
  total_burned: number;     // 总消耗 (kcal)
  net_calories: number;     // 净热量
  protein_intake: number;
  carbs_intake: number;
  fat_intake: number;
  
  // 目标对比
  calorie_remaining: number; // 剩余热量额度
  goal_status: 'on_track' | 'over' | 'under';  // 目标状态
}

type MealType = 'breakfast' | 'lunch' | 'dinner' | 'snack';
```

---

## 3. 算法规格

### 3.1 BMR/TDEE 计算

**BMR (基础代谢率) - Mifflin-St Jeor 公式**:

```
男性: BMR = 10 × 体重(kg) + 6.25 × 身高(cm) - 5 × 年龄 + 5
女性: BMR = 10 × 体重(kg) + 6.25 × 身高(cm) - 5 × 年龄 - 161
```

**TDEE (每日总消耗)**:

```
TDEE = BMR × 活动系数

活动系数:
- 久坐（几乎不运动）: 1.2
- 轻度活动（每周运动1-3天）: 1.375
- 中度活动（每周运动3-5天）: 1.55
- 高度活动（每周运动6-7天）: 1.725
- 非常高度活动（体力劳动/每天训练）: 1.9
```

**默认假设**: 活动系数 = 1.375（轻度活动）

### 3.2 每日热量目标计算

```
目标: 每周减重 0.5-1kg（安全范围）

热量缺口 = 目标减重(kg/周) × 7700 kcal/kg ÷ 7 天
         ≈ 500-1000 kcal/天

每日热量目标 = TDEE - 热量缺口
```

**安全限制**:
- 男性每日不低于 1500 kcal
- 女性每日不低于 1200 kcal

### 3.3 食物匹配算法

```
输入: 图片识别结果（食物名称列表）
输出: 匹配的食物数据

步骤:
1. 预处理识别结果（去除修饰词、标准化）
2. 在 foods_merged.json 中搜索匹配
3. 使用模糊匹配（编辑距离 < 2）
4. 如果多个匹配，选择热量最接近的
5. 返回匹配结果或建议近似食物
```

---

## 4. 提醒语气规格

### 4.1 温柔型 (gentle)

```markdown
## 晨起提醒
亲爱的，早上好！☀️ 新的一天开始啦，记得记录今天的体重哦～

## 午餐提醒
中午啦～该吃饭了！记得拍照记录，我在这里等你哦 📸

## 晚餐提醒
晚上好！今天辛苦了，记得拍张晚餐照片记录一下～

## 运动提醒
亲爱的，运动时间到啦！动起来，让身体更健康～💪

## 进度鼓励
哇，你已经坚持了 {{days}} 天！减重 {{weight_loss}}kg，太棒了！继续加油～
```

### 4.2 严厉型 (strict)

```markdown
## 晨起提醒
起床了！立刻去称体重并记录！不要找借口！

## 午餐提醒
午饭时间！拍张照记录！别想偷偷多吃！

## 晚餐提醒
晚饭时间！拍照！记录！控制热量！

## 运动提醒
运动时间！现在就去！不许偷懒！快点！

## 进度警告
你已经坚持了 {{days}} 天，才减了 {{weight_loss}}kg？还不够！继续努力！
```

### 4.3 幽默型 (funny)

```markdown
## 晨起提醒
早起的鸟儿有虫吃，早起的你在减肥路上冲冲冲！🦞

## 午餐提醒
饭点到了！记得拍照，不然我看不到你吃了啥～ 
（虽然我看不到也能猜到，但还是想看照片）

## 晚餐提醒
晚饭时间！拍个照吧，我已经饥渴难耐...等你的照片了！

## 运动提醒
运动时间！再不运动就要变成小龙虾了！🦞 
（虽然小龙虾也很好吃...但还是要运动！）

## 进度调侃
{{days}} 天了！减了 {{weight_loss}}kg！
照这个速度...你很快就能变成一道闪电了！⚡
```

---

## 5. 错误处理规格

### 5.1 图片识别失败

**返回消息**:
```
抱歉，无法识别这张图片中的食物 😅

可能的原因：
1. 图片不够清晰
2. 食物被遮挡或光线不足
3. 这种食物可能不在我的数据库里

你可以：
1. 重新拍一张更清晰的照片
2. 手动告诉我吃了什么，比如："米饭 150g，红烧肉 100g"
3. 检查多模态模型是否配置正确
```

### 5.2 食物不在数据库

**返回消息**:
```
数据库中暂无「{{food_name}}」的精确热量数据 🤔

建议使用以下相近食物估算：
{{similar_foods}}

或者你可以：
1. 告诉我大概的热量值
2. 使用其他食物替代记录
```

### 5.3 数据解析失败

**返回消息**:
```
哎呀，数据处理出了点问题 😓

请重新尝试，或者手动输入信息。
如果问题持续，请检查数据文件是否完整。
```

---

## 6. 性能规格

| 指标 | 要求 |
|------|------|
| 图片识别响应时间 | < 10 秒 |
| 热量计算响应时间 | < 1 秒 |
| 数据库加载时间 | < 2 秒 |
| 支持的食物数量 | > 1800 种 |
| 日志文件大小限制 | 单文件 < 1MB |

---

## 7. 安全规格

### 7.1 数据安全

- 所有用户数据存储在本地
- 不上传任何敏感信息到云端
- `.gitignore` 排除所有用户数据

### 7.2 输入验证

- 身高范围：100-250 cm
- 体重范围：30-300 kg
- 年龄范围：10-120 岁
- 每日热量限制：1000-5000 kcal

### 7.3 错误边界

- 热量计算异常时返回安全默认值
- 无效输入时提示用户重新输入
- 不因错误而中断服务

---

## 8. 兼容性

### 8.1 平台兼容性

| 平台 | 支持状态 |
|------|----------|
| Windows | ✅ 支持 |
| macOS | ✅ 支持 |
| Linux | ✅ 支持 |

### 8.2 QClaw/OpenClaw 版本

| 版本 | 支持状态 |
|------|----------|
| QClaw 1.x | ✅ 支持 |
| OpenClaw 1.x | ✅ 支持 |
| OpenClaw < 1.0 | ❌ 不支持 |

---

## 附录

### A. 食物分类映射

```json
{
  "carbs": ["米饭", "面条", "馒头", "面包", "粥"],
  "protein": ["鸡蛋", "豆腐", "鸡肉", "牛肉", "鱼肉"],
  "vegetable": ["青菜", "白菜", "西红柿", "黄瓜"],
  "fruit": ["苹果", "香蕉", "橙子", "西瓜"],
  "meat": ["猪肉", "牛肉", "羊肉", "鸡肉", "鸭肉"],
  "seafood": ["鱼", "虾", "蟹", "贝类"],
  "beverage": ["牛奶", "豆浆", "果汁", "茶", "咖啡"]
}
```

### B. 运动热量消耗参考

```json
{
  "跑步": { "calories_per_30min": 250 },
  "游泳": { "calories_per_30min": 300 },
  "骑行": { "calories_per_30min": 200 },
  "瑜伽": { "calories_per_30min": 100 },
  "力量训练": { "calories_per_30min": 150 },
  "跳绳": { "calories_per_30min": 300 },
  "走路": { "calories_per_30min": 100 }
}
```