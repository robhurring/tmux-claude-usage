#!/usr/bin/env bats

setup() {
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." && pwd )"
  FIXTURE="$DIR/test/fixtures/sample.json"
  export CLAUDE_USAGE_CACHE="$BATS_TEST_TMPDIR/claude-usage.json"
}

# --- claude-cache-usage ---

@test "tee: caches JSON and passes through" {
  run bash -c "cat '$FIXTURE' | '$DIR/bin/claude-cache-usage'"
  [ "$status" -eq 0 ]
  [ -f "$CLAUDE_USAGE_CACHE" ]
  # stdout should be the full JSON
  echo "$output" | grep -q '"display_name"'
}

@test "tee: caches JSON and pipes to downstream command" {
  run bash -c "cat '$FIXTURE' | '$DIR/bin/claude-cache-usage' cat"
  [ "$status" -eq 0 ]
  [ -f "$CLAUDE_USAGE_CACHE" ]
  echo "$output" | grep -q '"display_name"'
}

@test "tee: cached file matches input" {
  cat "$FIXTURE" | "$DIR/bin/claude-cache-usage" >/dev/null
  run diff <(jq -S . "$FIXTURE") <(jq -S . "$CLAUDE_USAGE_CACHE")
  [ "$status" -eq 0 ]
}

# --- cache_age.sh ---

@test "cache_age: reports age of fresh file" {
  cp "$FIXTURE" "$CLAUDE_USAGE_CACHE"
  run bash "$DIR/scripts/cache_age.sh"
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^[0-9]+s$ ]]
}

@test "cache_age: missing file returns empty" {
  run bash "$DIR/scripts/cache_age.sh"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
