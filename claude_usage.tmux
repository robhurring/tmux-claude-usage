#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/scripts/helpers.sh"

# Make claude-usage-tee available on PATH for use in ~/.claude/settings.json
tmux set-environment -g PATH "$CURRENT_DIR/bin:$PATH"

# Interpolation: format strings → script commands
five_h_percent="#($CURRENT_DIR/scripts/5h_percent.sh)"
seven_d_percent="#($CURRENT_DIR/scripts/7d_percent.sh)"
cost="#($CURRENT_DIR/scripts/cost.sh)"
model="#($CURRENT_DIR/scripts/model.sh)"
usage="#($CURRENT_DIR/scripts/usage.sh)"
cache_age="#($CURRENT_DIR/scripts/cache_age.sh)"

five_h_percent_interpolation="\\#{claude_5h_percent}"
seven_d_percent_interpolation="\\#{claude_7d_percent}"
cost_interpolation="\\#{claude_cost}"
model_interpolation="\\#{claude_model}"
usage_interpolation="\\#{claude_usage}"
cache_age_interpolation="\\#{claude_cache_age}"

do_interpolation() {
  local output="$1"
  output="${output/$five_h_percent_interpolation/$five_h_percent}"
  output="${output/$seven_d_percent_interpolation/$seven_d_percent}"
  output="${output/$cost_interpolation/$cost}"
  output="${output/$model_interpolation/$model}"
  output="${output/$usage_interpolation/$usage}"
  output="${output/$cache_age_interpolation/$cache_age}"
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
