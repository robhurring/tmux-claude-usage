#!/usr/bin/env bash
# Generic field reader: extracts a value from the cached JSON.
# Usage: field.sh <jq_path> [format]
# Formats: percent, cost, tokens, raw (default)
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

expr="$1"
format="${2:-raw}"

val=$(_claude_read_field "$expr")
[ -z "$val" ] && exit 0

case "$format" in
  percent) _claude_format_percent "$val" ;;
  cost)    _claude_format_cost "$val" ;;
  tokens)  _claude_format_tokens "$val" ;;
  *)       echo "$val" ;;
esac
