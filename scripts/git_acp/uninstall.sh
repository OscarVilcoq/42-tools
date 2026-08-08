#!/usr/bin/env bash
git config --global --unset alias.acp 2>/dev/null || true
rm -f "$HOME/.local/bin/git-acp"
echo "Alias 'git acp' désinstallé."