# Lan Roadmap（v1）

> 目标：做一个更快、更好、更方便的 Zig Agent CLI/TUI，Skill 原生可扩展。

## R1 — 基线稳定（进行中）
**目标：构建稳定、仓库卫生、CI 基线。**

### 里程碑
- [x] Git remote 清理（移除 URL 中 token）
- [x] main 跟踪 origin/main
- [x] 新增 CI（build + test）
- [ ] Zig 0.15 迁移完成并本地 `zig build` 通过
- [ ] 基础 smoke test 脚本

### 当前状态
- 状态：🟡 进行中
- 阻塞：Zig 0.15 API 兼容迁移（ArrayList / IO writer 等）

---

## R2 — CLI/TUI 可用性（待开始）
**目标：输入输出顺手，布局清晰，错误可解释。**

### 里程碑
- [ ] 多行编辑 / 历史回溯 / 快捷键帮助
- [ ] 输出流式稳定化（中断/重试/断线）
- [ ] 工具调用过程可视化
- [ ] 状态栏统一与错误分级

---

## R3 — Tool Runtime v1（待开始）
**目标：工具调用可靠、可控、可审计。**

### 里程碑
- [ ] Tool 协议（输入/输出/错误码）
- [ ] 超时/取消/重试/并发策略
- [ ] 内置工具标准化：read/write/list/exec
- [ ] 结构化日志 + 脱敏

---

## R4 — Skill Runtime v1（待开始）
**目标：Skill 成为一等公民。**

### 里程碑
- [ ] Skill manifest 规范
- [ ] `lan skill add/remove/list/update`
- [ ] 自动安装依赖 + 权限与隔离
- [ ] 3~5 个官方示例 Skill

---

## R5 — 多模型编排（待开始）
**目标：在效率和质量上超越同类。**

### 里程碑
- [ ] Provider 统一抽象层
- [ ] Router（速度/质量策略 + fallback）
- [ ] 会话压缩与记忆窗口控制

---

## R6 — 发布与生态（持续）
- [ ] macOS / Linux 分发
- [ ] 安装与升级机制
- [ ] 文档站与对标 benchmark

---

## 更新规则
- Roadmap 只记录方向、里程碑与阶段状态
- 任务级执行细节在 `docs/TASKS.md`
- 开发过程中实时更新（完成即勾选、阻塞即标注）
