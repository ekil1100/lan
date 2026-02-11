# Creating Custom Skills

## Overview

A skill is a directory containing a `manifest.json` and an entry point. Lan validates the manifest on install and copies the skill into its managed directory.

## Manifest Format

Create `manifest.json` in your skill directory:

```json
{
  "name": "my-skill",
  "version": "0.1.0",
  "entry": "main.sh",
  "tools": ["exec", "read_file"],
  "permissions": ["read", "write"]
}
```

### Required Fields

| Field | Type | Description |
|---|---|---|
| `name` | string | Unique skill identifier (alphanumeric + hyphens) |
| `version` | string | Semantic version (e.g., `0.1.0`) |
| `entry` | string | Entry point filename (must exist in skill dir) |
| `tools` | string[] | Tools this skill requires access to |
| `permissions` | string[] | Permission scopes (`read`, `write`, `exec`, `net`) |

## Entry Point

The entry point can be any executable (shell script, binary, etc.). It receives arguments from the agent runtime.

## Lifecycle

```bash
# Install from local directory
lan skill add ./path/to/my-skill

# List installed skills
lan skill list

# Update from local directory
lan skill update ./path/to/my-skill

# Remove by name
lan skill remove my-skill
```

## Example

See `skills/hello-world/` for a complete working example.

## Validation

Lan validates on install:
- `manifest.json` must parse as valid JSON
- All required fields must be present and non-empty
- `entry` file must exist in the skill directory
- `version` must match semver pattern
