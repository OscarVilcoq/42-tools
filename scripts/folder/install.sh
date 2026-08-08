#!/usr/bin/env bash
if [ -n "$OV_42_TOOLS_REVIEWS_PATH" ]; then
    mkdir -p "$OV_42_TOOLS_REVIEWS_PATH"
    echo "Dossier créé : $OV_42_TOOLS_REVIEWS_PATH"
else
    echo "Erreur : OV_42_TOOLS_REVIEWS_PATH non définie."
    exit 1
fi