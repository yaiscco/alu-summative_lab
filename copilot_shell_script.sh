#!/usr/bin/env bash
# copilot_shell_script.sh
# Prompts for assignment name and updates config/config.env ASSIGNMENT value.

set -euo pipefail

# Find the config file (assumes you run this from the repo root)
read -r -p "Enter the new assignment name (no newlines): " NEW_ASSIGNMENT
if [[ -z "$NEW_ASSIGNMENT" ]]; then
  echo "Assignment name cannot be empty."
  exit 1
fi

# Locate config file (either in current dir or inside submission_reminder_* directory)
CONFIG_PATH=""

if [ -f "config/config.env" ]; then
  CONFIG_PATH="config/config.env"
else
  # Find the first submission_reminder_* directory
  APP_DIR=$(ls -d submission_reminder_* 2>/dev/null | head -n1 || true)
  if [ -n "$APP_DIR" ] && [ -f "$APP_DIR/config/config.env" ]; then
    CONFIG_PATH="$APP_DIR/config/config.env"
  fi
fi

if [ -z "$CONFIG_PATH" ]; then
  echo "Could not find config/config.env. Make sure you run this script from repo root or create the app first."
  exit 2
fi

echo "Updating ASSIGNMENT in $CONFIG_PATH to: $NEW_ASSIGNMENT"

# Replace the ASSIGNMENT=... line (works whether ASSIGNMENT is first, second, or any line).
# Uses awk to rewrite file safely across systems.
tmp="$(mktemp)"
awk -v new="$NEW_ASSIGNMENT" 'BEGIN{FS=OFS="="}
  /^ASSIGNMENT=/ { print $1"="new; next }
  { print }' "$CONFIG_PATH" > "$tmp" && mv "$tmp" "$CONFIG_PATH"

# If ASSIGNMENT line was not found, ensure it's appended
if ! grep -q '^ASSIGNMENT=' "$CONFIG_PATH"; then
  echo "ASSIGNMENT=$NEW_ASSIGNMENT" >> "$CONFIG_PATH"
fi

echo "Done. You can now run the app (e.g. ./submission_reminder_${USER:-yourname}/scripts/startup.sh) to check non-submissions for $NEW_ASSIGNMENT."
