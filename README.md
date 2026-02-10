# lan - TUI Agent in Zig

A terminal UI agent inspired by OpenCode and Claude Code.

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

### 3. Build & Run

```bash
cd /Users/like/.openclaw/workspace/lan
zig build
./zig-out/bin/lan
```

## UI Preview

```
┌────────────────────────────────────────────────────────┐
│  🤖 Lan Agent v0.3                                      │
├────────────────────────────────────────────────────────┤
│  Streaming: ON  Tools: ON  Model: kimi-k2-0711-preview │
├────────────────────────────────────────────────────────┤
│ Commands                                               │
│   /help    Show this help                              │
│   /clear   Clear conversation                          │
│   ...                                                  │
├────────────────────────────────────────────────────────┤

▸ Hello, can you help me?
◆ Hello! I'd be happy to help you with anything you need.
  Just let me know what you'd like to work on!

▸ 
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

## License
MIT
