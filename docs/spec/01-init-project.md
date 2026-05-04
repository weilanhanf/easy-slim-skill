# Step 1: 项目初始化

## 目标

创建项目基础结构，配置开发环境。

## 任务清单

### 1.1 目录结构

- [x] 创建 `data/` 目录
- [x] 创建 `data/prompts/` 目录
- [x] 创建 `data/logs/` 目录
- [x] 创建 `docs/` 目录
- [x] 创建 `docs/spec/` 目录
- [x] 创建 `test_data/` 目录

### 1.2 基础文件

- [x] 创建 `README.md`
- [x] 创建 `.gitignore`
- [x] 创建 `docs/AGENTS.md`
- [x] 创建 `docs/CONFIGURATION.md`
- [x] 创建 `docs/SPEC.md`

### 1.3 Git 初始化

```bash
git init
git add .
git commit -m "feat: 项目初始化"
```

## 验证标准

- [ ] 所有目录创建成功
- [ ] 所有文件创建成功
- [ ] `.gitignore` 配置正确
- [ ] Git 仓库初始化成功

## 下一步

完成本步骤后，继续 [02-data-preparation.md](02-data-preparation.md)。