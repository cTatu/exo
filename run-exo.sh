#!/usr/bin/env bash
# run-exo.sh — Download, set up, and launch exo
#
# Usage:
#   bash run-exo.sh [exo args...]
#
# On first run this script installs uv, clones the repo, and builds the
# dashboard. Subsequent runs just launch exo directly.

set -euo pipefail

REPO_URL="https://github.com/cTatu/exo"
INSTALL_DIR="${EXO_DIR:-$HOME/.exo}"

# ── uv ────────────────────────────────────────────────────────────────────────
if ! command -v uv &>/dev/null; then
  echo "==> Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  # Add uv to PATH for the rest of this script
  export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
fi

# ── repo ──────────────────────────────────────────────────────────────────────
if [ ! -d "$INSTALL_DIR/.git" ]; then
  echo "==> Cloning exo into $INSTALL_DIR..."
  git clone "$REPO_URL" "$INSTALL_DIR"
else
  echo "==> Updating exo..."
  git -C "$INSTALL_DIR" pull --ff-only
fi

cd "$INSTALL_DIR"

# ── dashboard ─────────────────────────────────────────────────────────────────
if [ ! -d "dashboard/build" ]; then
  echo "==> Building dashboard (one-time setup)..."
  if ! command -v node &>/dev/null; then
    echo "Error: Node.js is required to build the dashboard."
    echo "Install it from https://nodejs.org or with: brew install node"
    exit 1
  fi
  cd dashboard && npm install && npm run build && cd ..
fi

# ── launch ────────────────────────────────────────────────────────────────────
echo "==> Starting exo (dashboard at http://localhost:52415)"
exec uv run exo "$@"
