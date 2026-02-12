#!/usr/bin/env bash
# Skill cache management
# Handles local caching of downloaded skills

set -euo pipefail

CACHE_DIR="${HOME}/.cache/lan/skills"
CACHE_TTL_DAYS=7

mkdir -p "$CACHE_DIR"

action="${1:-help}"

case "$action" in
  list)
    echo "[skill-cache] Cached skills:"
    find "$CACHE_DIR" -name "*.tar.gz" -exec ls -lh {} \; 2>/dev/null || echo "  (empty)"
    ;;
  
  get)
    skill_name="${2:-}"
    version="${3:-latest}"
    if [[ -z "$skill_name" ]]; then
      echo "[skill-cache] FAIL reason=missing_skill_name"
      exit 1
    fi
    
    cache_file="$CACHE_DIR/${skill_name}-${version}.tar.gz"
    if [[ -f "$cache_file" ]]; then
      # Check if cache is fresh
      if [[ $(find "$cache_file" -mtime -$CACHE_TTL_DAYS 2>/dev/null) ]]; then
        echo "[skill-cache] HIT file=$cache_file"
        echo "$cache_file"
        exit 0
      else
        echo "[skill-cache] EXPIRED file=$cache_file"
        rm -f "$cache_file"
      fi
    fi
    echo "[skill-cache] MISS skill=$skill_name version=$version"
    exit 1
    ;;
  
  put)
    skill_name="${2:-}"
    version="${3:-latest}"
    source_file="${4:-}"
    
    if [[ -z "$skill_name" || -z "$source_file" ]]; then
      echo "[skill-cache] FAIL reason=missing_args"
      exit 1
    fi
    
    cache_file="$CACHE_DIR/${skill_name}-${version}.tar.gz"
    cp "$source_file" "$cache_file"
    echo "[skill-cache] STORED file=$cache_file"
    ;;
  
  clean)
    echo "[skill-cache] Cleaning expired entries (>${CACHE_TTL_DAYS} days)..."
    find "$CACHE_DIR" -name "*.tar.gz" -mtime +$CACHE_TTL_DAYS -delete
    echo "[skill-cache] CLEANED"
    ;;
  
  help|*)
    echo "Usage: skill-cache.sh <action> [args]"
    echo ""
    echo "Actions:"
    echo "  list              List cached skills"
    echo "  get <name> [ver]  Get cached file path (or exit 1 if miss)"
    echo "  put <name> <ver> <file>  Store file in cache"
    echo "  clean             Remove expired cache entries"
    ;;
esac