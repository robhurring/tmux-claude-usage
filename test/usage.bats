#!/usr/bin/env bats

setup() {
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." && pwd )"
  FIXTURE="$DIR/test/fixtures/sample.json"
  export CLAUDE_USAGE_CACHE="$BATS_TEST_TMPDIR/claude-usage.json"
  cp "$FIXTURE" "$CLAUDE_USAGE_CACHE"
}

@test "usage: outputs combined format" {
  run bash "$DIR/scripts/usage.sh"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Opus 4.6 (1M context)" ]]
  [[ "$output" =~ "5h:24%" ]]
  [[ "$output" =~ "7d:41%" ]]
}

@test "usage: missing cache returns empty" {
  rm "$CLAUDE_USAGE_CACHE"
  run bash "$DIR/scripts/usage.sh"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
