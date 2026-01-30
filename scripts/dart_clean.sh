#!/usr/bin/env bash
set -euo pipefail
BIN_DIR=/mnt/d/flutter/bin
source "$BIN_DIR/internal/shared.sh"
shared::execute "$@"
