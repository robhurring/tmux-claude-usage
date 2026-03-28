#!/usr/bin/env bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

val=$(_claude_read_field '.rate_limits.five_hour.used_percentage')
_claude_format_percent "$val"
