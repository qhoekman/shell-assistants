#!/bin/bash
# This script reviews the commits in the current branch.
# It uses `ollama` to review the files.

if [ -f ~./ai-core.sh ]; then
  source ./ai-core.sh
else
  source ~/bin/ai-core.sh
fi

review_commits() {
  git fetch origin
  local targetBranch="origin/$(read_config "targetBranch")"
  local outputPrompt=$(read_config "output.prompt")
  local outputReview=$(read_config "output.review")
  local model=$(read_config "models.code")
  local prompt=""
  local commits=$(git log "$targetBranch..HEAD" --oneline)
  local diff=$(git diff "$targetBranch..HEAD")
  local promptReview=$(read_config "prompts.review")

  # if commits is empty, exit
  if [ -z "$commits" ]; then
    log "No commits to review"
    return
  fi

  log "Reviewing commits.."

  # add commit review prompt
  prompt=$(echo -e "$prompt\n\n$promptReview\n\n")

  # add details header
  prompt=$(echo -e "$prompt\n\n**Details:**\n\n")

  # add extra details
  prompt=$(echo -e "$prompt\n\nTicket #$(read_config "ticket.id"): $(read_config "ticket.title"). $(read_config "ticket.description")\n\n")

  # add the commits to the prompt
  prompt=$(echo -e "$prompt\n\nCommits:\n\n$commits\n\n")

  # add the diff to the prompt
  prompt=$(echo -e "$prompt\n\nDiff:\n\n$diff\n\n")

  echo -e "# Commits prompt\n$prompt" >"$outputPrompt"
  local suggestions=$(ollama run "$model" "$prompt")
  echo -e "$suggestions" >"$outputReview"

  log "Commits review"
}

#################################################################

init
review_commits
log "Done 🚀"
exit 0
