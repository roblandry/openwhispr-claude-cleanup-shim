#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
service_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
service_name="openwhispr-claude-cleanup-shim.service"
claude_bin="${CLAUDE_BIN:-$HOME/.local/bin/claude}"

mkdir -p "$service_dir"

REPO_DIR="$repo_dir" CLAUDE_BIN="$claude_bin" python3 - "$repo_dir/openwhispr-claude-cleanup-shim.service" "$service_dir/$service_name" <<'PY'
import os
import sys
from pathlib import Path

template = Path(sys.argv[1]).read_text(encoding="utf-8")
service = (
    template
    .replace("__REPO_DIR__", os.environ["REPO_DIR"])
    .replace("__CLAUDE_BIN__", os.environ["CLAUDE_BIN"])
)
Path(sys.argv[2]).write_text(service, encoding="utf-8")
PY

systemctl --user daemon-reload
systemctl --user enable --now "$service_name"
systemctl --user status "$service_name" --no-pager
