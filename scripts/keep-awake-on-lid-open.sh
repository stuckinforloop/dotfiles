#!/usr/bin/env bash
set -euo pipefail

# Prevent sleep while this script is running.
#
# Notes:
# - This keeps the Mac awake only while the lid is open and this process is alive.
# - macOS may still lock the screen based on separate security settings.
# - Stop it with Ctrl-C, or run it under launchd as a LaunchAgent.

exec /usr/bin/caffeinate -dimsu
