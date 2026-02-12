# lan - TUI Agent in Zig

[![Beta](https://img.shields.io/badge/status-beta-blue)](https://github.com/ekil1100/lan/releases)
[![CI](https://github.com/ekil1100/lan/actions/workflows/ci.yml/badge.svg)](https://github.com/ekil1100/lan/actions/workflows/ci.yml)

A terminal UI agent inspired by OpenCode and Claude Code. Now in **Beta v0.1.0** — feedback welcome!

## Design Inspiration

Lan draws strong inspiration from [badlogic/pi-mono](https://github.com/badlogic/pi-mono), and follows the same roadmap-level framing:

- **Adopt:** simple/efficient Linux philosophy, minimal core, sane defaults
- **Enhance:** native skills, streaming + tool loop integration, stronger engineering gates (TDD/BDD + smoke + CI)
- **Avoid:** user-hostile configuration complexity, unstable feature bloat, opaque black-box behavior

## Features

- ✅ Interactive chat TUI with beautiful box-drawing UI
- ✅ Multi-provider LLM support (Kimi, Anthropic, OpenAI)
- ✅ **Streaming responses** - See output as it's generated
- ✅ **Tool calling** - AI can read files, write files, execute commands, list directories
- ✅ Auto-saving conversation history
- ✅ **Syntax highlighting** - Code blocks highlighted with colors
- ✅ **Markdown rendering** - Bold, italic, inline code
- ✅ Command mode with visual feedback
- ✅ Multiline input support
- ✅ Config file (~/.config/lan/config.json)
- ✅ Retry logic for failed requests
- ✅ Terminal size detection

## Quick Start

### 1. Install Zig (pinned)

> Required version: **Zig 0.15.x** (current codebase target)

```bash
# verify
zig version
# should print 0.15.x
```


### 2. Configure API Key

**Environment Variable (recommended):**
```bash
export MOONSHOT_API_KEY="sk-xxx"
# or
export ANTHROPIC_API_KEY="sk-ant-xxx"
# or  
export OPENAI_API_KEY="sk-xxx"
```

**Config File:**
```bash
mkdir -p ~/.config/lan
cat > ~/.config/lan/config.json << 'EOF'
{
  "provider": "kimi",
  "model": "kimi-k2-0711-preview",
  "base_url": "https://api.moonshot.cn/v1",
  "api_key": "sk-xxx"
}
EOF
```

### 3. Install from Release (recommended — v0.1.0-beta)

```bash
# Download latest beta (v0.1.0-beta)
curl -fsSL https://github.com/ekil1100/lan/releases/download/v0.1.0-beta/lan-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m).tar.gz -o lan.tar.gz

# Install
./scripts/install.sh lan.tar.gz ~/.local/bin

# Verify
lan --version
```

Or use the install helper that auto-detects platform:
```bash
curl -fsSL https://github.com/ekil1100/lan/releases/download/v0.1.0-beta/install.sh | bash
```

### 3b. Build from Source

```bash
git clone https://github.com/ekil1100/lan.git && cd lan
zig build
./zig-out/bin/lan
```

## UI Preview

```text
╔══════════════════════════════════════╗
║  Lan Agent v0.3                      ║
╚══════════════════════════════════════╝

> /help
Commands:
  /help   Toggle this help
  /clear  Clear chat history (keeps system message)
  /exit   Exit Lan

> /clear
History cleared (system message kept).

> hello
[error:config] missing API key
next: set MOONSHOT_API_KEY / OPENAI_API_KEY / ANTHROPIC_API_KEY,
      or configure ~/.config/lan/config.json

> /exit
Thanks for using Lan! Goodbye!
```

## Available Tools

| Tool | Description |
|------|-------------|
| `read_file` | Read file contents |
| `write_file` | Write/create files |
| `exec` | Execute shell commands |
| `list_dir` | List directory contents with icons |

## Commands

| Command | Description |
|---------|-------------|
| `/help` | Toggle help panel |
| `/clear` | Clear conversation history |
| `/save` | Manually save history |
| `/load` | Load history from file |
| `/history` | Show message count |
| `/stream` | Toggle streaming mode |
| `/tools` | Toggle tools |
| `/exit` or `/quit` | Quit |

## Multiline Input

Type `"""` to enter multiline mode, then:
- **Ctrl+D** to send
- **Ctrl+C** to cancel

```
▸ """
... (multiline mode, Ctrl+D to send, Ctrl+C to cancel)
def hello():
    return "world"
(Ctrl+D)
◆ Here's a simple Python function...
```

## Files

| Path | Description |
|------|-------------|
| `~/.config/lan/config.json` | Configuration |
| `~/.config/lan/history.json` | Conversation history |

## Error Labels (Runtime)

Lan uses a unified error format in TUI:

- `[error:config] <summary>`
  - next: set API key env vars or configure `~/.config/lan/config.json`
- `[error:network] <summary>`
  - next: check network/proxy and `base_url` reachability, then retry
- `[error:provider] <summary>`
  - next: check provider/model availability and key permissions, then retry

## Tool Event Log Format (Machine-Parse)

Tool lifecycle logs are normalized to this fixed key order:

`tool_event phase=<start|end> ts=<unix> name=<tool_name> result=<running|success|fail> duration_ms=<number> summary=<token> next=<token-or-hint>`

Field notes:
- `phase`: start/end lifecycle stage
- `ts`: unix timestamp (seconds)
- `name`: tool call name
- `result`: running/success/fail
- `duration_ms`: elapsed time in milliseconds (0 at start)
- `summary`: short machine-friendly summary
- `next`: actionable follow-up hint or `-`

Parser demo:
```bash
./scripts/parse-tool-log-sample.sh
```

## Ops Troubleshooting

- 故障清单（install / upgrade / verify / preflight）：`docs/ops/troubleshooting.md`
- 文档与脚本 `next:` 输出按同一口径维护

## Beta Candidate One-Command Verify

```bash
./scripts/verify-beta-candidate.sh <artifact.tar.gz> [target-dir]
```

Example:
```bash
./scripts/verify-beta-candidate.sh dist/lan-0.1.0-macos-arm64.tar.gz "$HOME/.local/bin"
```

Output contract:
- success: `[beta-candidate-verify] PASS ...`
- fail: `[beta-candidate-verify] FAIL case=... ...` + `next: ...`

## Beta Candidate One-Command Acceptance

```bash
./scripts/run-beta-acceptance.sh <artifact.tar.gz> [target-dir] [report-out]
```

This entry chains:
- `check-beta-readiness`
- `verify-beta-candidate`
- `post-install-health`
- acceptance report template generation

Output contract:
- success: `[beta-acceptance] PASS ...`
- fail: `[beta-acceptance] FAIL case=... ...` + `next: ...`

Snapshot/report alignment (human + machine):
- Run `./scripts/snapshot-beta-acceptance.sh <artifact.tar.gz> [target-dir] [out-dir]`
- Outputs include `results.jsonl`, `summary.txt`, and `report-mapping.json`
- These map directly to `docs/release/beta-acceptance-report-template.md`

## Regression Entrypoints (Local + CI)

Unified commands:

```bash
make regression            # Full offline regression suite (used by CI)
make protocol-observability # Protocol + observability focused suite
```

Result interpretation:
- Success: exit code `0` and terminal line contains `PASS`
- Failure: non-zero exit code and terminal line contains `FAIL` (with reason/case)

Example (local):
```bash
make protocol-observability
# expected on success:
# [tool-log-parse] PASS
# [tool-protocol] PASS reason=structure-tests-passed
```

## Development

```bash
zig build              # Build
zig build run          # Build and run
zig build test         # Run tests
zig fmt src/           # Format code
```

## Project Structure

```
lan/
├── build.zig          # Build configuration
├── build.zig.zon      # Dependencies
├── src/
│   ├── main.zig       # Entry point
│   ├── tui.zig        # Beautiful terminal UI
│   ├── agent.zig      # Agent logic + tools
│   ├── llm.zig        # LLM clients + streaming
│   ├── tools.zig      # Tool definitions
│   └── config.zig     # Config file support
└── README.md
```

## Feedback

Lan is in **Beta** — your feedback shapes what comes next!

- **Bug reports**: [File an issue](https://github.com/ekil1100/lan/issues/new?template=bug_report.yml)
- **Feature requests**: [Suggest a feature](https://github.com/ekil1100/lan/issues/new?template=feature_request.yml)
- **Trial guide**: See [`docs/release/beta-trial-runbook.md`](docs/release/beta-trial-runbook.md)
- **Changelog**: See [`docs/release/CHANGELOG.md`](docs/release/CHANGELOG.md)

## License
MIT
