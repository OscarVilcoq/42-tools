#!/usr/bin/env bash
if [ -d "$OV_42_TOOLS_REVIEWS_PATH" ]; then
    rm -rf "$OV_42_TOOLS_REVIEWS_PATH"
    echo "Dossier $OV_42_TOOLS_REVIEWS_PATH supprimé."
fi