#!/bin/bash
# This script links the staged files in the current branch.
# It uses `ollama` to lint the files.

if [ -f ~./ai-core.sh ]; then
  source ./ai-core.sh
else
  source ~/bin/ai-core
fi

lint_files() {
  local promptCodeStandards=$(read_config "prompts.codeStandards")
  local outputStaged=$(read_config "output.staged")
  local outputPrompt=$(read_config "output.prompt")
  local model=$(read_config "models.code")
  local stagedFiles=$(git diff --name-only --cached)
  local ignorePatterns=$(read_config "ignorePatterns")

  # Lint each file
  for file in $stagedFiles; do
    local fileExt=$(echo "${file##*/}" | grep -o "\..*")
    if [[ $ignorePatterns == *"$fileExt"* ]]; then
      log "Ignoring $file"
      continue
    fi

    log "Linting $file"
    local fileContent=$(cat <"$file")
    local srcExt=$(echo "$fileExt" | awk -F'.' '{print $NF}')
    local prompt=""
    local filePrompt=$(read_config "prompts.bestPractices[\"$fileExt\"]")
    if [ -z "$filePrompt" ]; then
      filePrompt=""
    fi

    # add the code standards prompt
    prompt=$(echo -e "$prompt\n\n$promptCodeStandards\n\n")

    # add the file prompt
    prompt=$(echo -e "$prompt\n$filePrompt\n\n")

    # add details header
    prompt=$(echo -e "$prompt\n\n**Details:**\n\n")

    # add ticket details
    prompt=$(echo -e "$prompt\n\nTicket #$(read_config "ticket.id"): $(read_config "ticket.title"). $(read_config "ticket.description")\n\n")

    # add the code block
    prompt=$(echo -e "$prompt\n\n**Code:** \n\n\`\`\`$srcExt\n\n$fileContent\n\n\`\`\`\n\n")

    echo -e "\n\n# Lint prompt\n$prompt\n\n" >>"$outputPrompt"
    local suggestions=$(ollama run "$model" "$prompt")
    echo -e "# Lint ${file}\n\n" >>"$outputStaged"
    echo -e "$suggestions \n\n" >>"$outputStaged"
  done

  log "Files linted"
}

init
lint_files

log "Done 🚀"
exit 0
