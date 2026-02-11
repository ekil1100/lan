# hello-world Skill

A minimal example skill for Lan, demonstrating the skill manifest and entry point convention.

## Structure

```
hello-world/
├── manifest.json   # Skill metadata (name, version, entry, tools, permissions)
├── main.sh         # Entry point script
└── README.md       # This file
```

## Install

```bash
lan skill add ./skills/hello-world
```

## Verify

```bash
lan skill list
```

## Uninstall

```bash
lan skill remove hello-world
```
