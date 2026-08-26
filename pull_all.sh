#!/usr/bin/env bash

echo "Updating repositories..."
echo

REPOS=(
    "./Receiving-Service"
    "./Auth-Service"
    "./API-Gateway"
    "./receiving-serivce-ui"
)

for REPO in "${REPOS[@]}"; do
    echo "[$REPO]"

    if [ ! -d "$REPO/.git" ]; then
        echo "Error: repository not found. Run clone.sh first."
        echo
        continue
    fi

    git -C "$REPO" pull

    if [ $? -ne 0 ]; then
        echo "Error: failed to update $REPO"
    fi

    echo
done

echo "Repository update completed."

read