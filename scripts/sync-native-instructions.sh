#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

TARGET_KEY="$1"
MAP_FILE="${2:-config/repo-map.json}"
CENTRAL_ROOT="${3:-$PWD}"
TARGET_ROOT="${4:-$PWD}"

SRC_GLOBAL="$CENTRAL_ROOT/instructions/global"
SRC_PROFILES="$CENTRAL_ROOT/instructions/profiles"
SRC_REPO="$CENTRAL_ROOT/instructions/repos/$TARGET_KEY"

DEST_BASE="$TARGET_ROOT/.github/instructions"
DEST_SHARED="$DEST_BASE/shared"
DEST_REPO="$DEST_BASE/repo"

mkdir -p "$DEST_SHARED" "$DEST_REPO"
rm -rf "$DEST_SHARED"/* "$DEST_REPO"/*

copy_instructions() {
  local src_dir="$1"
  local dest_dir="$2"
  local files=("$src_dir"/*.instructions.md)
  if (( ${#files[@]} )); then
    cp "${files[@]}" "$dest_dir"/
  fi
}

copy_instructions "$SRC_GLOBAL" "$DEST_SHARED"

profiles=$(jq -r --arg k "$TARGET_KEY" '.targets[] | select(.key==$k) | .profiles[]?' "$MAP_FILE")
for p in $profiles; do
  if [[ ! -d "$SRC_PROFILES/$p" ]]; then
    echo "Profile not found: $p" >&2
    exit 1
  fi
  copy_instructions "$SRC_PROFILES/$p" "$DEST_SHARED"
done

if [[ -d "$SRC_REPO" ]]; then
  copy_instructions "$SRC_REPO" "$DEST_REPO"
fi

cp "$SRC_GLOBAL/copilot-instructions.md" "$TARGET_ROOT/.github/copilot-instructions.md"