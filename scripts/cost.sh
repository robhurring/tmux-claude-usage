#!/usr/bin/env bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

val=$(_claude_read_field '.cost.total_cost_usd')
_claude_format_cost "$val"
