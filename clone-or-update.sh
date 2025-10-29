#!/usr/bin/env bash
# /opt/project/clone-or-update.sh
# Clones the repo if missing; otherwise fetches and fast-forwards to the target branch.
# Customize these values or export them via /etc/default/project-clone
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/example-org/example-repo.git}"
TARGET_DIR="${TARGET_DIR:-/opt/project/app}"
BRANCH="${BRANCH:-main}"
RUN_AS_USER="${RUN_AS_USER:-ubuntu}"

log() { echo "[$(date -Is)] $*"; }

# Ensure target parent exists
mkdir -p "$(dirname "$TARGET_DIR")"

if [ ! -d "$TARGET_DIR/.git" ]; then
  log "Cloning $REPO_URL into $TARGET_DIR ..."
  git clone --branch "$BRANCH" --depth=1 "$REPO_URL" "$TARGET_DIR"
else
  log "Updating existing repo in $TARGET_DIR ..."
  pushd "$TARGET_DIR" >/dev/null
  # Make sure we are on the desired branch
  git fetch origin "$BRANCH"
  current_branch="$(git rev-parse --abbrev-ref HEAD)"
  if [ "$current_branch" != "$BRANCH" ]; then
    git checkout "$BRANCH"
  fi
  git reset --hard "origin/$BRANCH"
  popd >/dev/null
fi

# Optional: set ownership to the runtime user
chown -R "$RUN_AS_USER":"$RUN_AS_USER" "$TARGET_DIR"

log "Done."
