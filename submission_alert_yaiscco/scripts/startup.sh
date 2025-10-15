#!/usr/bin/env bash
# startup.sh - entrypoint for the submission reminder app
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
CONFIG="$HERE/config/config.env"
SUBMISSIONS="$HERE/data/submissions.txt"
REMINDER_SCRIPT="$HERE/scripts/reminder.sh"

# Ensure config and submissions exist
if [ ! -f "$CONFIG" ]; then
  echo "Missing config: $CONFIG"
  exit 1
fi
if [ ! -f "$SUBMISSIONS" ]; then
  echo "Missing submissions data: $SUBMISSIONS"
  exit 2
fi
if [ ! -f "$REMINDER_SCRIPT" ]; then
  echo "Missing reminder script: $REMINDER_SCRIPT"
  exit 3
fi

# Make sure all scripts are executable
chmod +x "$HERE"/scripts/*.sh

# Source config (so reminder.sh can use variables from config.env)
# shellcheck disable=SC1090
# it's okay to source user-provided config here
source "$CONFIG"

# Run the reminder app (reminder.sh may call functions.sh internally)
echo "Starting submission reminder for assignment: ${ASSIGNMENT:-<unknown>}"
bash "$REMINDER_SCRIPT" "$SUBMISSIONS"

