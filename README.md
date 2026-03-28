# tmux-claude-usage

Tmux plugin that displays [Claude Code](https://claude.ai/code) usage statistics in your tmux status line.

Works by caching Claude Code's statusline JSON via a lightweight `tee` wrapper — no API keys, no polling, no disruption to your existing statusline script.

## Requirements

- [tmux](https://github.com/tmux/tmux)
- [TPM](https://github.com/tmux-plugins/tpm)
- [Claude Code](https://claude.ai/code)
- `jq` or `python3` (for JSON parsing)

## Installation

### 1. Install the plugin

Add to your `.tmux.conf`:

```tmux
set -g @plugin 'robhurring/tmux-claude-usage'
```

Press `prefix + I` to install.

### 2. Configure Claude Code statusline

In `~/.claude/settings.json`, wrap your existing statusline command with `claude-cache-usage`:

**If you have an existing statusline script:**

```json
{
  "statusLine": {
    "type": "command",
    "command": "$TMUX_PLUGIN_MANAGER_PATH/tmux-claude-usage/bin/claude-cache-usage your-existing-statusline-script"
  }
}
```

**If you don't have a statusline script:**

```json
{
  "statusLine": {
    "type": "command",
    "command": "$TMUX_PLUGIN_MANAGER_PATH/tmux-claude-usage/bin/claude-cache-usage"
  }
}
```

`claude-cache-usage` transparently caches the JSON and pipes it through to your command. Your existing script receives the exact same stdin — nothing changes.

### 3. Add format strings to your status bar

```tmux
set -g status-right '#{claude_usage} | %H:%M'
```

## Format Strings

| Token | Example | Description |
|-------|---------|-------------|
| `#{claude_5h_percent}` | `24%` | 5-hour rolling window usage |
| `#{claude_7d_percent}` | `41%` | 7-day rolling window usage |
| `#{claude_cost}` | `$1.23` | Session cost in USD |
| `#{claude_model}` | `Opus` | Current model name |
| `#{claude_usage}` | `Opus 5h:24% 7d:41%` | Combined format (configurable) |
| `#{claude_cache_age}` | `4m` | Time since last cache update |

## Configuration

All options are set via tmux `set -g`:

```tmux
# Icon prefix (e.g., nerdfont claude icon)
set -g @claude_usage_icon "☍ "

# Template for #{claude_usage} — available placeholders:
# %icon%, %model%, %5h%, %7d%, %cost%
set -g @claude_usage_format "%icon%%model% 5h:%5h% 7d:%7d%"

# What to show when there's no cached data (default: empty/hidden)
set -g @claude_usage_no_data ""

# Seconds before cache is considered stale (default: 600)
set -g @claude_usage_stale_seconds "600"
```

### Cache Location

By default the cache lives at `<plugin-dir>/claude-usage.json`. Override with `$CLAUDE_USAGE_CACHE`:

```bash
export CLAUDE_USAGE_CACHE="$HOME/claude-usage.json"
```

## How It Works

```
Claude Code → statusline JSON on stdin
  → claude-cache-usage → tee to cache file
    → pipe through to your statusline script (unchanged)

tmux status bar
  → #{claude_5h_percent} etc.
  → plugin scripts read cached JSON via jq/python3
```

The cache is refreshed automatically whenever Claude Code updates its statusline (after each assistant response). No periodic polling needed.

## Rate Limits

The 5-hour and 7-day usage percentages are available for Claude Pro/Max subscribers. They reflect your rolling rate limit utilization as reported by Claude Code.

## License

[MIT](LICENSE)
