#!/bin/sh
# push finished output to the GitHub stash. pipe through:  sh scripts/push_stash.sh "msg"
set -e
cd "$(dirname "$0")/.." || exit 1
git add -A
git commit -m "${1:-stash update}" --allow-empty
git push origin main 2>&1 | tail -5