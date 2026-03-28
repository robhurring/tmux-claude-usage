#!/usr/bin/env bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

cache_file=$(_claude_cache_file)
[ ! -f "$cache_file" ] && exit 0

now=$(date +%s)
if stat -f %m "$cache_file" >/dev/null 2>&1; then
  file_mtime=$(stat -f %m "$cache_file")
else
  file_mtime=$(stat -c %Y "$cache_file")
fi

age=$((now - file_mtime))

if [ "$age" -ge 86400 ]; then
  awk "BEGIN { printf \"%.0fd\", $age / 86400 }"
elif [ "$age" -ge 3600 ]; then
  awk "BEGIN { printf \"%.0fh\", $age / 3600 }"
elif [ "$age" -ge 60 ]; then
  awk "BEGIN { printf \"%.0fm\", $age / 60 }"
else
  echo "${age}s"
fi
