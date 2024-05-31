#!/bin/bash
# This script initializes the AI tool.

if [ -f ~./ai-core.sh ]; then
  source ./ai-core.sh
else
  source ~/bin/ai-core
fi

fetch_defaults() {
  log "Fetching default values..."
  curl https://raw.githubusercontent.com/qhoekman/shell-assistants/main/.ai.yaml --create-dirs -o .ai.yaml
}

fetch_defaults
log "Done 🚀"
