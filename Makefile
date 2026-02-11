# Lan TUI Agent Makefile

ZIG ?= zig
BUILD_DIR = zig-out/bin
TARGET = $(BUILD_DIR)/lan

.PHONY: all build run test smoke smoke-online regression protocol-observability r4-skill-regression r5-routing-regression clean install fmt

all: build

build:
	$(ZIG) build -Dversion=0.1.0 -Dcommit=$$(git rev-parse --short HEAD 2>/dev/null || echo dev) -Dbuild-time=$$(date -u +%Y-%m-%dT%H:%M:%SZ)

run: build
	$(ZIG) build run

test:
	$(ZIG) build test

smoke: build
	./scripts/smoke.sh

smoke-online: build
	./scripts/smoke-online.sh

regression: build
	./scripts/test-regression-suite.sh

protocol-observability: build
	./scripts/parse-tool-log-sample.sh
	./scripts/test-tool-protocol-structure.sh
	./scripts/check-tool-protocol-compat.sh

r4-skill-regression: build
	./scripts/test-r4-skill-suite.sh

r5-routing-regression: build
	./scripts/test-r5-routing-suite.sh

clean:
	rm -rf .zig-cache zig-out

fmt:
	$(ZIG) fmt src/

install:
	$(ZIG) build --release=safe
	@echo "Binary at: $(TARGET)"

dev:
	$(ZIG) build run -- --dev

# Quick commands
check:
	$(ZIG) build check 2>/dev/null || $(ZIG) fmt --check src/

# Install Zig if not present
setup-mac:
	brew install zig

setup-ubuntu:
	snap install zig --classic
