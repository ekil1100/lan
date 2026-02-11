# Beta Go / No-Go 风险清单模板

> 用途：在每轮 Beta 试用汇总后，快速做 go/no-go 决策。
> 口径对齐：`scripts/summarize-beta-trial.sh`（pass_rate / failed_items / pending_items）。

---

## 1) 决策结论（必填）

- [ ] **GO**（允许继续扩大试用）
- [ ] **NO-GO**（暂停扩大试用，先收敛风险）

结论说明（1-3句）：
`<why>`

---

## 2) 判定条件（go/no-go gates）

### GO 条件（建议全部满足）
- `pass_rate >= 90%`
- `failed_items` 无 P0/P1
- `pending_items` 可在下一轮窗口内收敛
- 有明确回滚路径且演练通过

### NO-GO 触发条件（任一命中）
- 出现 P0 问题
- P1 未给出可执行缓解动作
- `failed_items` 持续增长
- 关键路径（安装/验证/回滚）无法稳定复现

---

## 3) 汇总输入（来自 trial summary）

- Summary JSON 路径：`<dist/beta-trial-summary/summary-*.json>`
- pass_rate：`<xx%>`
- failed_items：`<...>`
- pending_items：`<...>`
- next_step：`<...>`

---

## 4) 风险项清单（必须有 owner）

| Risk ID | Severity (P0/P1/P2/P3) | Risk Description | Owner | Mitigation Action | Due Time | Status |
|---|---|---|---|---|---|---|
| R-001 | P1 | <risk> | <owner> | <action> | <YYYY-MM-DD HH:mm TZ> | Open |
| R-002 | P2 | <risk> | <owner> | <action> | <YYYY-MM-DD HH:mm TZ> | In Progress |

字段要求：
- **Owner**：必须可追责（人名/角色）
- **Mitigation Action**：必须可执行（动词开头）
- **Due Time**：必须有明确时间

---

## 5) 决策后 next-step

1. `<step 1>`
2. `<step 2>`
3. `<step 3>`

---

## 6) 快速对齐检查

- 是否引用了最新 `summary-*.json`？
- 风险项是否都有 Owner + Mitigation + Due Time？
- GO/NO-GO 是否能被证据支撑？
