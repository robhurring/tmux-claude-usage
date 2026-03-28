#!/usr/bin/env bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

cache_file=$(_claude_cache_file)

# If cache is stale or missing, output nothing (or configured no-data string)
if _claude_cache_is_stale "$cache_file"; then
  get_tmux_option "@claude_usage_no_data" ""
  exit 0
fi

# Read all fields
icon=$(get_tmux_option "@claude_usage_icon" "")
model=$(_claude_read_field '.model.display_name')
five_h=$(_claude_read_field '.rate_limits.five_hour.used_percentage')
seven_d=$(_claude_read_field '.rate_limits.seven_day.used_percentage')
cost=$(_claude_read_field '.cost.total_cost_usd')

# Format values
five_h=$(_claude_format_percent "$five_h")
seven_d=$(_claude_format_percent "$seven_d")
cost=$(_claude_format_cost "$cost")

# If we got nothing useful, bail
if [ -z "$model" ] && [ -z "$five_h" ] && [ -z "$seven_d" ]; then
  get_tmux_option "@claude_usage_no_data" ""
  exit 0
fi

# Template substitution
format=$(get_tmux_option "@claude_usage_format" "%icon%%model% 5h:%5h% 7d:%7d%")
output="${format//%icon%/$icon}"
output="${output//%model%/$model}"
output="${output//%5h%/$five_h}"
output="${output//%7d%/$seven_d}"
output="${output//%cost%/$cost}"

echo "$output"
