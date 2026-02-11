# Lan Beta 公告模板

---

## 🎉 Lan v0.1.0-beta 正式发布

**Lan** 是一个用 Zig 构建的 Agent CLI/TUI，目标是比现有方案更快、更轻、Skill 原生可扩展。

经过 13 轮迭代（R1-R13），我们完成了从零到 Beta 的全链路：核心交互、工具运行时、Skill 框架、Provider 路由、打包/安装/升级/回滚、运维支持、以及完整的 Beta 验收与试用管线。

---

### 📦 安装

```bash
# 下载最新 release 包
curl -fsSL https://github.com/ekil1100/lan/releases/download/v0.1.0-beta/lan-v0.1.0-beta-$(uname -s | tr A-Z a-z)-$(uname -m).tar.gz -o lan.tar.gz

# 安装
./scripts/install.sh lan.tar.gz ~/.local/bin

# 验证
lan --version
./scripts/post-install-health.sh ~/.local/bin/lan
```

---

### ✨ 亮点

- **Zig 0.15 原生构建** — 启动快，体积小
- **流式对话** — SSE 增量输出，打字机体验
- **Skill 一等公民** — `lan skill list/add/update/remove`
- **Provider 路由** — fallback 链 + speed/quality 模式
- **完整发布链路** — 打包 → 安装 → 升级 → 回滚 → 验证，全程脚本化
- **离线运维** — preflight 预检、support bundle、排障手册

---

### ⚠️ 已知限制

- 仅验证 macOS arm64，其他平台欢迎反馈
- 在线对话需自备 OpenAI 兼容 API key
- Skill 生态尚未建立（框架已就绪）
- TUI 模式下 `--help` 不可用（设计限制）

---

### 📝 反馈渠道

- **GitHub Issues**: https://github.com/ekil1100/lan/issues
- **反馈模板**: 请使用 `docs/release/beta-feedback-template.md`
- **试用指南**: 参见 `docs/release/beta-trial-runbook.md`

---

### 📋 完整变更记录

参见 [CHANGELOG.md](./CHANGELOG.md)

---

_感谢参与 Beta 试用！每一条反馈都有价值。_
