# Beta 候选验收报告模板（人话版）

> 用途：每次产出 Beta 候选包后，按这个模板快速给出“能不能试用”的结论。
> 口径对齐：
> - `docs/beta-checklist.md`（映射 `docs/release/beta-entry-checklist.md`）
> - `./scripts/verify-beta-candidate.sh`（一键验证入口）

---

## 1) 候选信息

- 版本：`<vX.Y.Z-beta.N>`
- 提交：`<commit-sha>`
- 构建时间：`<YYYY-MM-DD HH:mm TZ>`
- 产物路径：`<artifact.tar.gz>`
- 验收人：`<name>`

---

## 2) 验收命令（原样贴）

```bash
# 一键验证（聚合 verify + preflight + install）
./scripts/verify-beta-candidate.sh <artifact.tar.gz> [target-dir]

# Beta 清单执行器
./scripts/check-beta-readiness.sh
```

可选补充：

```bash
./scripts/test-post-install-health.sh
```

---

## 3) 通过项（PASS）

- [ ] verify-package 通过（checksum + manifest）
- [ ] preflight 通过（环境/路径/权限/sha 工具）
- [ ] install 通过（可安装并可执行）
- [ ] beta checklist 关键项通过
- [ ] post-install health 通过（版本可读/核心命令可执行/依赖可用）

证据（日志/路径）：
- `<paste command output / CI link / local log path>`

---

## 4) 失败项（FAIL）

- 失败项 1：`<item>`
  - 现象：`<what happened>`
  - 证据：`<log snippet/path>`
  - next-step：`<action from script output>`

- 失败项 2：`<item>`
  - 现象：`<what happened>`
  - 证据：`<log snippet/path>`
  - next-step：`<action from script output>`

---

## 5) next-step（汇总）

1. `<next action 1>`
2. `<next action 2>`
3. `<next action 3>`

---

## 6) 是否可试用（结论）

- [ ] 可试用（Beta 候选可发给试用者）
- [ ] 暂不可试用（需先修复失败项）

结论说明（1-3 句）：
`<human-readable conclusion>`

---

## 7) 回写任务状态（建议）

- 若可试用：更新 `docs/TASKS.md` 对应阶段为 ready-for-beta-trial
- 若不可试用：把失败项拆成原子任务，并指定唯一 NEXT
