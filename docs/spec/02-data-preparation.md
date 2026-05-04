# Step 2: 数据准备

## 目标

准备食物营养数据库，合并全球和中国食物数据。

## 前置条件

- 完成 [01-init-project.md](01-init-project.md)

## 任务清单

### 2.1 下载源数据

**全球食物数据 (caltrack-data)**:
```bash
# 下载 foods.json
curl -o data/foods_global.json https://raw.githubusercontent.com/suyogshejal2004/caltrack-data/main/foods.json
```

**中国食物数据 (cn-food-mcp)**:
```bash
# 下载 CSV 文件
curl -o /tmp/cn_food.csv https://raw.githubusercontent.com/ruffood/cn-food-mcp/main/data2026.csv

# 转换为 JSON 格式
# 需要编写转换脚本
```

### 2.2 编写转换脚本

创建 `scripts/convert_cn_food.js`:

```javascript
// 将中国食物 CSV 转换为标准 JSON 格式
const fs = require('fs');
const csv = fs.readFileSync('/tmp/cn_food.csv', 'utf-8');
// ... 转换逻辑
fs.writeFileSync('data/foods_china.json', JSON.stringify(result, null, 2));
```

### 2.3 合并数据库

创建合并脚本 `scripts/merge_foods.js`:

```javascript
const global = require('../data/foods_global.json');
const china = require('../data/foods_china.json');
const merged = {
  version: 1,
  foods: [...global.foods, ...china.foods]
};
fs.writeFileSync('data/foods_merged.json', JSON.stringify(merged, null, 2));
```

### 2.4 数据验证

- [ ] 全球食物数据下载成功
- [ ] 中国食物数据下载并转换成功
- [ ] 合并数据无重复 ID
- [ ] 数据格式符合 SPEC.md 定义

## 数据映射规则

### CSV 列映射

| CSV 列名 | JSON 字段 | 说明 |
|----------|-----------|------|
| 食物（每100克） | name | 食物名称 |
| 能量（kal） | nutrition_per_100g.calories | 热量 |
| 蛋白质（克） | nutrition_per_100g.protein | 蛋白质 |
| 糖类（克） | nutrition_per_100g.carbs | 碳水 |
| 脂肪（克） | nutrition_per_100g.fat | 脂肪 |
| 纤维（克） | nutrition_per_100g.fiber | 纤维 |

### ID 生成规则

```
全球食物: food_{name_en_lower}
中国食物: food_cn_{name_pinyin}
```

## 预期结果

```
data/
├── foods_global.json    # ~100 种食物
├── foods_china.json    # ~1751 种中国食物
└── foods_merged.json   # 合并后 ~1850+ 种食物
```

## 验证标准

- [ ] `foods_merged.json` 文件存在
- [ ] 包含 > 1800 种食物
- [ ] JSON 格式有效
- [ ] 所有食物有唯一 ID

## 下一步

完成本步骤后，继续 [03-skill-definition.md](03-skill-definition.md)。