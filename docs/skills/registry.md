# Skill Registry Design

## Overview

Central registry for Lan skills — a JSON-based index that enables discovery and remote installation.

## Registry Format

```json
{
  "version": "1.0.0",
  "updated_at": "2026-02-12T14:00:00Z",
  "skills": [
    {
      "name": "hello-world",
      "version": "0.1.0",
      "description": "A minimal example skill",
      "author": "lan-team",
      "url": "https://github.com/ekil1100/lan-skills/tree/main/hello-world",
      "download_url": "https://github.com/ekil1100/lan-skills/releases/download/v0.1.0/hello-world-0.1.0.tar.gz",
      "sha256": "abc123...",
      "tools": ["exec"],
      "permissions": ["read"],
      "tags": ["example", "demo"]
    }
  ]
}
```

## Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Skill identifier (unique) |
| `version` | Yes | Semver version |
| `description` | Yes | Short description |
| `author` | Yes | Author or org name |
| `url` | Yes | Source repository URL |
| `download_url` | Yes | Direct download URL |
| `sha256` | Yes | Checksum for verification |
| `tools` | Yes | Required tools |
| `permissions` | Yes | Required permissions |
| `tags` | No | Search tags |

## Commands

### Search skills
```bash
lan skill search <keyword>
```

Searches registry index by name/description/tags. Returns matching skills as JSON.

### Install from registry
```bash
lan skill install <name>
```

1. Fetches registry index
2. Finds skill by name
3. Downloads from `download_url`
4. Verifies SHA256
5. Installs to `~/.config/lan/skills/`

## Registry Sources

Default: `https://lan.dev/skills/index.json`

Custom (via config):
```json
{
  "skill_registry": {
    "url": "https://my-registry.example.com/index.json",
    "verify_checksums": true
  }
}
```

## Local Cache

Registry index cached at `~/.cache/lan/skill-registry.json` with TTL of 1 hour.
