# Lan TUI Agent Makefile

ZIG ?= zig
BUILD_DIR = zig-out/bin
TARGET = $(BUILD_DIR)/lan

.PHONY: all build run test smoke clean install fmt

all: build

build:
	$(ZIG) build

run: build
	$(ZIG) build run

test:
	$(ZIG) build test

smoke: build
	./scripts/smoke.sh

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
