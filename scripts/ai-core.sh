#!/bin/bash
# This script provides core functions for the AI scripts.

read_config() {
  local value=$(yq e ".$1" .ai.yaml)
  # if the value is empty, exit
  if [ -z "$value" ]; then
    log "Please provide a value for $1 in .ai.yaml, The config file needs to be compliant with the schema."
    exit 1
  fi
  echo -e "$value"
}

log() {
  echo -e "\033[1;35m==> \033[1;37m$1\033[0m\n"
}

init() {
  # ollama is installed
  if ! command -v ollama &>/dev/null; then
    log "ollama is not installed. Please install it using 'brew install ollama'"
    exit 1
  fi

  # yq is installed
  if ! command -v yq &>/dev/null; then
    log "yq is not installed. Please install it using 'brew install yq'"
    exit 1
  fi

  # create .ai folder if it doesn't exist
  if [ ! -d ".ai" ]; then
    mkdir .ai
  fi

  # if .ai.yaml doesn't exist, exit
  if [ ! -f ".ai.yaml" ]; then
    log "Please create a .ai.yaml file in the root of your project."
    exit 1
  fi
}
