#!/usr/bin/env bash
git config --global --unset alias.c 2>/dev/null || true
rm -f "$HOME/.local/bin/git-c"
echo "Alias 'git c' désinstallé."