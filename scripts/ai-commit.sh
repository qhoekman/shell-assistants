#!/bin/bash
# This script prepares a commit message.

source ./ai-core.sh

prepare_commit_message() {
  local outputCommit=$(read_config "output.commit")
  local outputPrompt=$(read_config "output.prompt")
  local model=$(read_config "models.commit")
  local prompt=""
  local promptCommitMessage=$(read_config "prompts.commitMessage")

  log "Preparing commit message..."

  # add commit message prompt
  prompt=$(echo -e "$prompt\n\n$promptCommitMessage\n\n")

  # add details header
  prompt=$(echo -e "$prompt\n\n**Details:**\n\n")

  # add extra details
  prompt=$(echo -e "$prompt\n\nTicket #$(read_config "ticket.id"): $(read_config "ticket.title"). $(read_config "ticket.description")\n\n")

  echo -e "# Commit prompt\n$prompt" >"$outputPrompt"
  local suggestions=$(ollama run "$model" "$prompt")
  echo -e "$suggestions" >"$outputCommit"

  log "Commit message prepared"
}

init
prepare_commit_message

log "Done 🚀"
exit 0
