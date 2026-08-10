#!/usr/bin/env bash
git config --global --unset alias.retry 2>/dev/null || true
rm -f "$HOME/.local/bin/git-retry"
echo "Alias 'git retry' désinstallé."