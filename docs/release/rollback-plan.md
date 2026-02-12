# Release Rollback Plan

> 当 release 失败时的应急响应方案。

## 触发条件

以下情况需要启动回滚：
- CI workflow 失败且无法快速修复
- 发布的 artifact 损坏或无法安装
- 发现严重安全漏洞需要撤回 release

## 回滚步骤

### 1. 评估失败程度

| 情况 | 严重程度 | 行动 |
|------|----------|------|
| 单个平台 artifact 缺失 | P2 | 补充构建该 platform，无需回滚 |
| checksum 不匹配 | P1 | 删除错误 checksum，重新上传 |
| 所有 artifact 损坏 | P0 | **执行完整回滚** |
| 安装后崩溃 | P0 | **执行完整回滚** |

### 2. 完整回滚流程

```bash
#!/bin/bash
# 回滚 v0.1.0-beta release

VERSION="v0.1.0-beta"
REPO="ekil1100/lan"

# Step 1: 删除 GitHub Release
echo "Deleting GitHub Release $VERSION..."
gh release delete "$VERSION" --repo "$REPO" --yes

# Step 2: 删除本地和远程 tag
echo "Deleting tag $VERSION..."
git push --delete origin "$VERSION" 2>/dev/null || true
git tag -d "$VERSION" 2>/dev/null || true

# Step 3: 通知用户
echo "Rollback complete. Users should uninstall the broken version:"
echo "  rm ~/.local/bin/lan"
echo ""
echo "Previous stable version can be installed with:"
echo "  ./scripts/verify-install.sh v0.0.9  # or last known good version"
```

### 3. 用户通知模板

**GitHub Discussion / Issue:**

```markdown
## 🚨 Release v0.1.0-beta Rolled Back

**原因**: [简要说明，如 "Critical bug causing data loss"]

**影响**: 已安装 v0.1.0-beta 的用户

**操作步骤**:
1. 立即卸载: `rm ~/.local/bin/lan`
2. 回退到稳定版: `./scripts/verify-install.sh v0.0.9`
3. 等待修复后的新版本通知

**预计修复时间**: [时间]

**跟踪 Issue**: #XXX
```

### 4. 修复后重新发布

```bash
# 修复代码后创建补丁版本

# 方法 A: 使用新 tag（推荐）
git tag -a "v0.1.0-beta.1" -m "Hotfix for v0.1.0-beta"
git push origin v0.1.0-beta.1

# 方法 B: 重新使用原 tag（仅当无人下载时）
# 注意: GitHub 不建议重复使用已删除的 tag
git tag -a "v0.1.0-beta" -m "Re-release with fixes"
git push origin v0.1.0-beta --force
```

## 预防措施

1. **发布前验证**（必须）
   ```bash
   ./scripts/diagnose-release.sh
   ./scripts/verify-linux.sh
   make full-regression
   ```

2. **金丝雀发布**（可选）
   - 先发布 pre-release，让 beta 用户测试
   - 24 小时无问题后转为正式 release

3. **监控指标**
   - 发布后 1 小时内检查安装成功率
   - 监控 GitHub Issues 新增数量

## 责任人

| 角色 | 职责 | 联系 |
|------|------|------|
| Release Owner | 决策是否回滚 | @like |
| CI Owner | 诊断 workflow 问题 | @like |
| Comms Owner | 用户通知 | @like |

## 历史记录

| 日期 | 版本 | 事件 | 处理结果 |
|------|------|------|----------|
| - | - | 暂无回滚记录 | - |

---

*Last updated: 2026-02-12*
