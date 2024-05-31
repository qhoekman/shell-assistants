#!/bin/bash
# This script initializes the AI tool.

source ./ai-core.sh

fetch_defaults() {
  log "Fetching default values..."
  curl https://raw.githubusercontent.com/qhoekman/shell-assistants/main/.ai.yaml --create-dirs -o .ai.yaml
}

fetch_defaults
log "Done 🚀"
