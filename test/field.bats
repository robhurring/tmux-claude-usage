#!/usr/bin/env bats

setup() {
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." && pwd )"
  FIXTURE="$DIR/test/fixtures/sample.json"
  export CLAUDE_USAGE_CACHE="$BATS_TEST_TMPDIR/claude-usage.json"
  cp "$FIXTURE" "$CLAUDE_USAGE_CACHE"
}

# --- field.sh ---

@test "field: reads model display name" {
  run bash "$DIR/scripts/field.sh" .model.display_name
  [ "$status" -eq 0 ]
  [ "$output" = "Opus 4.6 (1M context)" ]
}

@test "field: reads model id" {
  run bash "$DIR/scripts/field.sh" .model.id
  [ "$status" -eq 0 ]
  [ "$output" = "claude-opus-4-6[1m]" ]
}

@test "field: formats percent" {
  run bash "$DIR/scripts/field.sh" .rate_limits.five_hour.used_percentage percent
  [ "$status" -eq 0 ]
  [ "$output" = "24%" ]
}

@test "field: formats 7d percent" {
  run bash "$DIR/scripts/field.sh" .rate_limits.seven_day.used_percentage percent
  [ "$status" -eq 0 ]
  [ "$output" = "41%" ]
}

@test "field: formats cost" {
  run bash "$DIR/scripts/field.sh" .cost.total_cost_usd cost
  [ "$status" -eq 0 ]
  [ "$output" = "\$1.23" ]
}

@test "field: reads boolean false" {
  run bash "$DIR/scripts/field.sh" .exceeds_200k_tokens
  [ "$status" -eq 0 ]
  [ "$output" = "false" ]
}

@test "field: reads version" {
  run bash "$DIR/scripts/field.sh" .version
  [ "$status" -eq 0 ]
  [ "$output" = "2.1.86" ]
}

@test "field: reads cwd" {
  run bash "$DIR/scripts/field.sh" .cwd
  [ "$status" -eq 0 ]
  [ "$output" = "/Users/test/project" ]
}

@test "field: reads context percent" {
  run bash "$DIR/scripts/field.sh" .context_window.used_percentage percent
  [ "$status" -eq 0 ]
  [ "$output" = "15%" ]
}

@test "field: reads lines added as raw" {
  run bash "$DIR/scripts/field.sh" .cost.total_lines_added
  [ "$status" -eq 0 ]
  [ "$output" = "42" ]
}

@test "field: missing field returns empty" {
  run bash "$DIR/scripts/field.sh" .nonexistent.field
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "field: missing cache file returns empty" {
  rm "$CLAUDE_USAGE_CACHE"
  run bash "$DIR/scripts/field.sh" .model.display_name
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
