#!/usr/bin/env bash
# tmux-claude-usage helpers
# Shared utilities for cache reading, JSON parsing, formatting, and tmux options.

# --- Tmux option helpers (standard TPM pattern) ---

get_tmux_option() {
  local option="$1"
  local default_value="$2"
  local option_value
  option_value=$(tmux show-option -gqv "$option" 2>/dev/null)
  if [ -n "$option_value" ]; then
    echo "$option_value"
  else
    echo "$default_value"
  fi
}

set_tmux_option() {
  tmux set-option -g "$1" "$2"
}

# --- Cache file resolution ---
# Resolves to the plugin's own .cache/ directory by default.
# Override with $CLAUDE_USAGE_CACHE if needed.

PLUGIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

_claude_cache_file() {
  echo "${CLAUDE_USAGE_CACHE:-$PLUGIN_DIR/claude-usage.json}"
}

# --- JSON parser detection ---
# Prefers jq, falls back to python3. Caches result.

_CLAUDE_JSON_CMD=""

_claude_json_cmd() {
  if [ -n "$_CLAUDE_JSON_CMD" ]; then
    echo "$_CLAUDE_JSON_CMD"
    return
  fi

  if command -v jq >/dev/null 2>&1; then
    _CLAUDE_JSON_CMD="jq"
  elif command -v python3 >/dev/null 2>&1; then
    _CLAUDE_JSON_CMD="python3"
  fi

  echo "$_CLAUDE_JSON_CMD"
}

# Extract a field from JSON using jq expression.
# Usage: _claude_json_extract '.rate_limits.five_hour.used_percentage' < file.json
_claude_json_extract() {
  local expr="$1"
  local cmd
  cmd=$(_claude_json_cmd)

  case "$cmd" in
    jq)
      jq -r "($expr) | if . == null then empty elif . == false then \"false\" elif . == true then \"true\" else tostring end" 2>/dev/null
      ;;
    python3)
      python3 -c "
import json, sys, functools, operator
try:
    data = json.load(sys.stdin)
    # Convert jq-style path like '.a.b.c' to key list ['a','b','c']
    keys = [k for k in '${expr}'.split('.') if k]
    val = functools.reduce(operator.getitem, keys, data)
    if val is not None:
        print(val)
except (KeyError, TypeError, IndexError, json.JSONDecodeError):
    pass
" 2>/dev/null
      ;;
    *)
      return 1
      ;;
  esac
}

# --- Cache reading ---

# Read a field from the cached JSON.
# Returns empty string if file missing or parse fails.
_claude_read_field() {
  local expr="$1"
  local cache_file
  cache_file=$(_claude_cache_file)

  [ ! -f "$cache_file" ] && return

  _claude_json_extract "$expr" < "$cache_file"
}

# --- Formatting ---

_claude_format_percent() {
  local val="$1"
  [ -z "$val" ] && return
  printf '%.0f' "$val"
}

_claude_format_color_percent() {
  local val="$1"
  [ -z "$val" ] && return

  local threshold_mid threshold_high color_low color_mid color_high
  threshold_mid=$(get_tmux_option "@claude_usage_threshold_mid" "50")
  threshold_high=$(get_tmux_option "@claude_usage_threshold_high" "80")
  color_low=$(get_tmux_option "@claude_usage_color_low" "colour2")
  color_mid=$(get_tmux_option "@claude_usage_color_mid" "colour3")
  color_high=$(get_tmux_option "@claude_usage_color_high" "colour1")

  local int_val color
  int_val=$(printf '%.0f' "$val")

  if [ "$int_val" -ge "$threshold_high" ] 2>/dev/null; then
    color="$color_high"
  elif [ "$int_val" -ge "$threshold_mid" ] 2>/dev/null; then
    color="$color_mid"
  else
    color="$color_low"
  fi

  printf '#[fg=%s]' "$color"
}

_claude_format_cost() {
  local val="$1"
  [ -z "$val" ] && return
  printf '$%.2f' "$val"
}

_claude_format_tokens() {
  local val="$1"
  [ -z "$val" ] && return

  if [ "$val" -ge 1000000 ] 2>/dev/null; then
    awk "BEGIN { printf \"%.1fM\", $val / 1000000 }"
  elif [ "$val" -ge 1000 ] 2>/dev/null; then
    awk "BEGIN { printf \"%.1fK\", $val / 1000 }"
  else
    echo "$val"
  fi
}
