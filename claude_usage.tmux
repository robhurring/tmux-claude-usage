#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/scripts/helpers.sh"

FIELD="$CURRENT_DIR/scripts/field.sh"
AGE="$CURRENT_DIR/scripts/cache_age.sh"
EXCEEDS_200K="$CURRENT_DIR/scripts/exceeds_200k.sh"

# Interpolation: format strings → script commands
# format: field.sh <jq_path> [format]
# Uses a function instead of associative arrays for bash 3 compatibility.
_interpolation_args() {
  case "$1" in
    # rate limits
    claude_5h_percent)       echo ".rate_limits.five_hour.used_percentage percent" ;;
    claude_5h_color)         echo ".rate_limits.five_hour.used_percentage color_percent" ;;
    claude_7d_percent)       echo ".rate_limits.seven_day.used_percentage percent" ;;
    claude_7d_color)         echo ".rate_limits.seven_day.used_percentage color_percent" ;;
    # cost
    claude_cost)             echo ".cost.total_cost_usd cost" ;;
    claude_lines_added)      echo ".cost.total_lines_added" ;;
    claude_lines_removed)    echo ".cost.total_lines_removed" ;;
    # context
    claude_context_percent)  echo ".context_window.used_percentage percent" ;;
    claude_context_color)    echo ".context_window.used_percentage color_percent" ;;
    claude_context_remaining) echo ".context_window.remaining_percentage percent" ;;
    # session
    claude_model)            echo ".model.display_name" ;;
    claude_model_id)         echo ".model.id" ;;
    claude_version)          echo ".version" ;;
    claude_cwd)              echo ".cwd" ;;
    claude_project)          echo ".workspace.project_dir" ;;
    *)                       return 1 ;;
  esac
}

INTERPOLATION_TOKENS="claude_5h_percent claude_5h_color claude_7d_percent claude_7d_color claude_cost claude_lines_added claude_lines_removed claude_context_percent claude_context_color claude_context_remaining claude_model claude_model_id claude_version claude_cwd claude_project"

do_interpolation() {
  local output="$1"

  for token in $INTERPOLATION_TOKENS; do
    local args
    args=$(_interpolation_args "$token")
    output="${output//\#\{$token\}/#($FIELD $args)}"
  done

  # Special scripts (not simple field lookups)
  output="${output//\#\{claude_cache_age\}/#($AGE)}"
  output="${output//\#\{claude_exceeds_200k\}/#($EXCEEDS_200K)}"

  echo "$output"
}

update_tmux_option() {
  local option="$1"
  local option_value
  option_value="$(get_tmux_option "$option")"
  local new_option_value
  new_option_value="$(do_interpolation "$option_value")"
  set_tmux_option "$option" "$new_option_value"
}

main() {
  update_tmux_option "status-right"
  update_tmux_option "status-left"
}

main
