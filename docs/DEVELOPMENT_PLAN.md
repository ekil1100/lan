# Lan 开发计划（详细版 v1）

> 目标：构建一个 Zig 实现的高性能 Agent CLI/TUI，具备原生 Skill 生态与可扩展架构。

## 0. 成功定义（Definition of Success）

### 产品成功指标（MVP）
- 新用户 10 分钟内完成：安装 → 配置模型 → 首次工具调用 → 保存会话
- 常见任务（读文件、写文件、执行命令）成功率 > 95%
- 首 token 输出延迟（本地工具链路除外）≤ 1.5s（目标，取决于模型端）
- 崩溃率 < 1% / 1000 次会话

### 工程成功指标
- 核心模块有单元测试 + 回归测试
- 关键路径有结构化日志与耗时指标
- Build 在指定 Zig 版本可稳定通过

---

## 1. 总体架构

```text
lan (CLI/TUI)
├─ core/
│  ├─ session manager
│  ├─ message pipeline (streaming)
│  ├─ tool runtime
│  ├─ skill runtime
│  └─ config/state store
├─ providers/
│  ├─ openai-compatible
│  ├─ anthropic
│  └─ moonshot/kimi
├─ ui/
│  ├─ layout
│  ├─ input editor
│  ├─ render (markdown/code)
│  └─ command palette
└─ platform/
   ├─ fs
   ├─ process
   ├─ network
   └─ telemetry
```

---

## 2. 路线图（按阶段）

## Phase 1 — 基线稳定（1~2 周）
**目标：先把“可持续开发底座”打稳。**

### 任务
1. **版本与构建修复**
   - 确认项目 Zig 目标版本（建议在 README 与 CI 固化）
   - 修复 `build.zig.zon` 与当前 Zig 语法兼容问题
   - 增加 `make build / make test / make run` 一致入口

2. **仓库卫生**
   - 清理 remote 中带 token 的 URL（改为无凭据 URL）
   - 补充 `.editorconfig`、`CONTRIBUTING.md`、`LICENSE`
   - 配置基础 CI（build + test + lint）

3. **核心链路冒烟测试**
   - 启动 → 发消息 → 流式返回 → 调用工具 → 保存历史
   - 固化为脚本化 smoke test

### 交付物
- 可重复构建文档
- CI 绿灯
- 一个可稳定演示的二进制

---

## Phase 2 — CLI/TUI 体验成型（2~3 周）
**目标：让交互“顺手”。**

### 任务
1. **输入体验**
   - 多行编辑、历史回溯、快捷键帮助
   - 命令系统（`/help /model /tools /skills /config /quit`）统一

2. **输出体验**
   - 流式输出稳定化（中断、重试、断线恢复）
   - Markdown + 代码块渲染增强
   - 工具调用过程可视化（开始/进行中/完成/失败）

3. **布局优化**
   - 状态栏信息统一：模型、温度、工具开关、token 用量（可选）
   - 错误提示分级（用户错误 / 网络错误 / 提供商错误）

### 交付物
- v0.2 TUI 交互标准
- 可用的快捷键与命令参考

---

## Phase 3 — Tool Runtime 标准化（2 周）
**目标：工具调用可靠、可控、可审计。**

### 任务
1. **统一工具协议**
   - 输入 schema、输出 schema、错误码约定
   - 超时、取消、重试、并发策略

2. **内置工具集（MVP）**
   - `read_file`, `write_file`, `list_dir`, `exec`
   - 统一权限确认策略（尤其 exec）

3. **安全与日志**
   - 工具调用结构化日志（时间、参数摘要、耗时、退出码）
   - 敏感参数脱敏

### 交付物
- Tool Runtime v1
- 工具开发文档（如何新增一个工具）

---

## Phase 4 — Skill 原生系统（3~4 周）
**目标：Skill 成为核心竞争力。**

### 任务
1. **Skill Manifest 设计**
   - 名称、版本、依赖、权限、入口命令、平台约束
   - 签名/校验（至少 checksum）

2. **Skill 安装与运行**
   - `lan skill add/remove/list/update`
   - 依赖自动安装（可确认）
   - 隔离执行（工作目录、环境变量白名单）

3. **Skill 市场雏形**
   - 本地索引 + 远程 registry（可后续）
   - 评分维度：安全、稳定、性能、维护活跃度

### 交付物
- Skill Runtime v1
- 3~5 个官方示例 Skill

---

## Phase 5 — 多模型编排与高级能力（2~3 周）
**目标：做出“比同类更好”的效率优势。**

### 任务
1. **Provider 抽象统一**
   - OpenAI-compatible + Anthropic + Kimi 统一接口
   - 模型能力探测（函数调用/视觉/长上下文）

2. **策略层（Router）**
   - 按任务类型选择模型（速度优先 / 质量优先）
   - 故障自动切换 fallback

3. **会话能力增强**
   - 上下文压缩、摘要、可控记忆窗口
   - 可选本地向量检索（后续可插拔）

### 交付物
- Provider Abstraction v1
- 路由策略可配置

---

## Phase 6 — 发布与生态（持续）

### 任务
- 多平台分发（macOS/Linux）
- 安装脚本与升级机制
- 文档站（快速开始 + 架构 + Skill 开发）
- Demo 与 benchmark 对比（vs 同类工具）

---

## 3. 技术债清单（当前优先）
1. `build.zig.zon` 与 Zig 版本兼容问题（阻断）
2. Git remote 凭据泄露风险（高优）
3. 分支 upstream 未设置（影响协作）
4. 缺少 CI 基线（影响迭代稳定性）

---

## 4. 质量保障策略

### 测试分层
- Unit：核心数据结构/解析器/协议
- Integration：provider 调用、tool runtime
- E2E：CLI/TUI 主流程冒烟

### 发布门禁
- 构建通过
- 测试通过
- 无高危安全告警
- 关键性能指标未回退

---

## 5. 里程碑建议（可调整）
- **M1（第 2 周）**：构建稳定 + CI + 基础演示
- **M2（第 5 周）**：TUI 可用性达标 + Tool Runtime v1
- **M3（第 9 周）**：Skill Runtime v1 + 示例生态
- **M4（第 12 周）**：多模型路由 + 首个公开 beta

---

## 6. 接下来 7 天执行清单（立刻可做）

1. 修复构建兼容（Zig 版本锁定 + build.zig.zon 修复）
2. 清理 Git remote 中的 token 并轮换密钥
3. 配置 CI（至少 build + smoke）
4. 统一命令面板与快捷键（形成 v0.2 规范）
5. 设计 Tool Runtime 错误码与日志格式
6. 起草 Skill Manifest（v0 草案）
7. 输出一次对标评审（OpenCode / Pi / Claude Code / Codex）

---

## 7. 对标原则（学习并超越）
- 学 OpenCode：工作流效率与工程一致性
- 学 Pi：极简交互与低认知负担
- 学 Claude Code：长任务稳定性与代码上下文能力
- 学 Codex：工具调用质量与可控推理

**超越路径：**
- 在速度（启动/流式/工具）上做硬指标领先
- 在 Skill 原生化上做差异化护城河
- 在 TUI 交互连贯性上提供“无摩擦”体验

---

## 8. 风险与缓解
- Zig 生态变化快 → 锁版本 + 定期升级窗口
- 多 provider 差异大 → 统一适配层 + contract tests
- Skill 安全边界复杂 → 默认最小权限 + 审计日志 + 手动确认
- 功能膨胀 → 以“默认可用”原则持续裁剪

---

## 9. 文档约定
- 该计划每两周更新一次
- 每次更新必须记录：完成项、偏差、下阶段调整
- 决策变更写入 `AGENT.md`（原则）与本计划（执行）
