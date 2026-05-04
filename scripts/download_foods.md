# 下载食物数据库说明

食物数据库包含两部分：
1. 全球食物数据（约100种）
2. 中国食物数据（约1751种）

## 自动下载（需要网络）

运行以下脚本：

```bash
# Linux/macOS
chmod +x scripts/download_foods.sh
./scripts/download_foods.sh

# Windows (PowerShell)
.\scripts\download_foods.ps1
```

## 手动下载

如果自动下载失败，可以手动下载：

### 步骤1：下载全球食物数据

1. 访问：https://github.com/suyogshejal2004/caltrack-data
2. 下载 `foods.json` 文件
3. 重命名为 `foods_global.json` 放到 `data/` 目录

### 步骤2：下载中国食物数据

1. 访问：https://github.com/ruffood/cn-food-mcp
2. 下载 `data2026.csv` 文件
3. 使用转换脚本转为 JSON 格式

### 步骤3：合并数据

将两个数据源合并为 `data/foods_merged.json`

## 数据格式

食物数据应包含以下字段：

```json
{
  "version": 1,
  "foods": [
    {
      "id": "food_rice_white",
      "name": "白米饭",
      "name_en": "White Rice",
      "category": "carbs",
      "nutrition_per_100g": {
        "calories": 130,
        "protein": 2.4,
        "carbs": 28.2,
        "fat": 0.3
      },
      "source": "china"
    }
  ]
}
```

## 验证数据

下载完成后，检查：

```bash
# 检查文件是否存在
ls -la data/foods_merged.json

# 检查食物数量（应大于1800）
# Linux/macOS
cat data/foods_merged.json | grep -o '"id"' | wc -l

# Windows (PowerShell)
(Get-Content data/foods_merged.json | Select-String '"id"').Count
```
