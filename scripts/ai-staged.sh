#!/bin/bash
# This script reviews the staged files in the current branch.
# It uses `ollama` to review the files.

if [ -f ~./ai-core.sh ]; then
  source ./ai-core.sh
else
  source ~/bin/ai-core.sh
fi

review_staged() {
  local stagedFiles=$(git diff --name-status --cached)
  local currentBranch=$(git rev-parse --abbrev-ref HEAD)
  local outputPrompt=$(read_config "output.prompt")
  local outputStaged=$(read_config "output.staged")
  local promptNamingConventions=$(read_config "prompts.namingConventions")
  local promptStaged=$(read_config "prompts.staged")
  local model=$(read_config "models.staged")
  local prompt=""

  log "Reviewing metadata.."

  # Clear the output files
  echo "" >"$outputStaged"

  # add staged prompt
  prompt=$(echo -e "$prompt\n\n$promptStaged\n\n")

  # add naming conventions prompt
  prompt=$(echo -e "$prompt\n\n$promptNamingConventions\n\n")

  # add details header
  prompt=$(echo -e "$prompt\n\n**Details:**\n\n")

  # add current branch to the prompt
  prompt=$(echo -e "$prompt\n\nCurrent Branch: $currentBranch\n\n")

  # add ticket details
  prompt=$(echo -e "$prompt\n\nTicket #$(read_config "ticket.id"): $(read_config "ticket.title"). $(read_config "ticket.description")\n\n")

  # has staged files
  if [ -n "$stagedFiles" ]; then
    # add staged files to the prompt
    prompt=$(echo -e "$prompt\n\nStaged Files:\n\n$stagedFiles\n\n")
  fi

  echo -e "\n\n# Staged prompt\n$prompt\n\n" >>"$outputPrompt"
  local suggestions=$(ollama run "$model" "$prompt")
  echo -e "# ${currentBranch}\n\n" >>"$outputStaged"
  echo -e "$suggestions\n\n" >>"$outputStaged"

  log "Metadata reviewed"
}

review_files() {
  local promptReview=$(read_config "prompts.review")
  local outputStaged=$(read_config "output.staged")
  local outputPrompt=$(read_config "output.prompt")
  local model=$(read_config "models.code")
  local stagedFiles=$(git diff --name-only --cached)
  local ignorePatterns=$(read_config "ignorePatterns")

  if [ -z "$stagedFiles" ]; then
    log "No staged files to review"
    return
  fi

  # Review each file
  for file in $stagedFiles; do
    local fileExt=$(echo "${file##*/}" | grep -o "\..*")
    if [[ $ignorePatterns == *"$fileExt"* ]]; then
      log "Ignoring $file"
      continue
    fi
    log "Reviewing $file"
    local fileContent=$(cat <"$file")
    local srcExt=$(echo "$fileExt" | awk -F'.' '{print $NF}')
    local prompt=""

    # add the review prompt
    prompt=$(echo -e "$prompt\n\n$promptReview\n\n")

    # add details header
    prompt=$(echo -e "$prompt\n\n**Details:**\n\n")

    # add ticket details
    prompt=$(echo -e "$prompt\n\nTicket #$(read_config "ticket.id"): $(read_config "ticket.title"). $(read_config "ticket.description")\n\n")

    # add the code block
    prompt=$(echo -e "$prompt\n\n**Code:** \n\n\`\`\`$srcExt\n\n$fileContent\n\n\`\`\`\n\n")

    echo -e "\n\n# Review prompt:\n$prompt\n\n" >>"$outputPrompt"
    local suggestions=$(ollama run "$model" "$prompt")
    echo -e "# Review ${file}\n\n" >>"$outputStaged"
    echo -e "$suggestions \n\n" >>"$outputStaged"
  done

  log "Files reviewed"
}
#################################################################

init
review_staged
review_commits
review_files
log "Done 🚀"
exit 0
