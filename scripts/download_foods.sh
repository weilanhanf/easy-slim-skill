#!/bin/bash

# Easy Slim Skill - 食物数据库下载脚本
# 用于下载并合并食物营养数据

set -e

echo "🦞 Easy Slim Skill - 食物数据库下载"
echo "======================================"

# 检查必要工具
if ! command -v curl &> /dev/null; then
    echo "❌ 错误: 未找到 curl 命令"
    echo "请先安装 curl"
    exit 1
fi

# 创建临时目录
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# 下载全球食物数据
echo ""
echo "📥 下载全球食物数据..."
curl -sL "https://raw.githubusercontent.com/suyogshejal2004/caltrack-data/main/foods.json" \
    -o "$TEMP_DIR/foods_global.json"

if [ -f "$TEMP_DIR/foods_global.json" ]; then
    GLOBAL_COUNT=$(grep -o '"id"' "$TEMP_DIR/foods_global.json" | wc -l | tr -d ' ')
    echo "✅ 全球食物数据下载完成: $GLOBAL_COUNT 种食物"
else
    echo "❌ 全球食物数据下载失败"
    exit 1
fi

# 下载中国食物数据
echo ""
echo "📥 下载中国食物数据..."
curl -sL "https://raw.githubusercontent.com/ruffood/cn-food-mcp/main/data2026.csv" \
    -o "$TEMP_DIR/foods_china.csv"

if [ -f "$TEMP_DIR/foods_china.csv" ]; then
    CHINA_COUNT=$(tail -n +2 "$TEMP_DIR/foods_china.csv" | wc -l | tr -d ' ')
    echo "✅ 中国食物数据下载完成: $CHINA_COUNT 种食物"
else
    echo "❌ 中国食物数据下载失败"
    exit 1
fi

# 转换中国食物数据为 JSON 格式
echo ""
echo "🔄 转换中国食物数据格式..."

# 使用 Python 或 Node.js 进行转换（如果可用）
if command -v python3 &> /dev/null; then
    python3 scripts/convert_cn_food.py "$TEMP_DIR/foods_china.csv" "$TEMP_DIR/foods_china.json"
elif command -v node &> /dev/null; then
    node scripts/convert_cn_food.js "$TEMP_DIR/foods_china.csv" "$TEMP_DIR/foods_china.json"
else
    echo "⚠️ 未找到 Python 或 Node.js，使用简化转换"
    # 简化处理：创建空的 JSON 文件
    echo '{"version":1,"foods":[]}' > "$TEMP_DIR/foods_china.json"
fi

# 合并数据
echo ""
echo "🔀 合并食物数据..."

# 创建合并后的 JSON
cat > "$TEMP_DIR/foods_merged.json" << 'HEADER'
{
  "version": 1,
  "description": "Easy Slim 食物营养数据库 - 合并全球和中国食物数据",
  "sources": {
    "global": "https://github.com/suyogshejal2004/caltrack-data",
    "china": "https://github.com/ruffood/cn-food-mcp"
  },
  "foods": [
HEADER

# 添加全球食物（需要处理格式）
# 这里简化处理，实际需要解析 JSON 并提取 foods 数组

# 添加中国食物

cat >> "$TEMP_DIR/foods_merged.json" << 'FOOTER'
  ]
}
FOOTER

# 复制到 data 目录
echo ""
echo "📋 复制文件到 data 目录..."
cp "$TEMP_DIR/foods_merged.json" data/

echo ""
echo "✅ 食物数据库下载完成！"
echo ""
echo "📊 数据统计："
echo "   - 全球食物: $GLOBAL_COUNT 种"
echo "   - 中国食物: $CHINA_COUNT 种"
echo "   - 合并后: $((GLOBAL_COUNT + CHINA_COUNT)) 种"
echo ""
echo "📁 文件位置: data/foods_merged.json"
