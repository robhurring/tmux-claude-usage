#!/usr/bin/env bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

val=$(_claude_read_field '.exceeds_200k_tokens')

if [ "$val" = "true" ]; then
  get_tmux_option "@claude_usage_over_200k" "200k+"
else
  get_tmux_option "@claude_usage_under_200k" ""
fi
