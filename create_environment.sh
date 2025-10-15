#!/usr/bin/env bash
# create_environment.sh
# the shell file creates submission_reminder_{YourName} environment,
# copies provided files into appropriate subdirectories,
# creates startup.sh and makes all .sh files executable.

set -euo pipefail

read -r -p "Enter your username: " USERNAME
if [[ -z "$USERNAME" ]]; then
  echo "Name cannot be empty. Exiting."
  exit 1
fi

APP_DIR="submission_alert_${USERNAME}"
echo "Making app directory: $APP_DIR"

# structure for directory
mkdir -p "$APP_DIR"/{config,scripts,data,reports,assets}

#required provided files (expected in current working dir where you run this script)
PROVIDED_CONFIG="config.env"
PROVIDED_REMINDER="reminder.sh"
PROVIDED_FUNCTIONS="functions.sh"
PROVIDED_SUBMISSIONS="submissions.txt"
PROVIDED_IMAGE="image.png"


missing=0
for f in "$PROVIDED_CONFIG" "$PROVIDED_REMINDER" "$PROVIDED_FUNCTIONS" "$PROVIDED_SUBMISSIONS" "$PROVIDED_IMAGE"; do
  if [ ! -f "$f" ]; then
    echo "Error: required file '$f' not found in $(pwd). Please place it here or edit the script."
    missing=1
  fi
done
if [ "$missing" -ne 0 ]; then
  echo "One or more required files missing. Aborting."
  exit 2
fi

# Copy provided files to app folders
cp "$PROVIDED_CONFIG" "$APP_DIR/config/config.env"
cp "$PROVIDED_REMINDER" "$APP_DIR/scripts/reminder.sh"
cp "$PROVIDED_FUNCTIONS" "$APP_DIR/scripts/functions.sh"
cp "$PROVIDED_SUBMISSIONS" "$APP_DIR/data/submissions.txt"
cp "$PROVIDED_IMAGE" "$APP_DIR/assets/image.png"

# Create startup.sh inside scripts/ (this is the one you must implement)
cat > "$APP_DIR/scripts/startup.sh" <<'EOF'
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

EOF

# Ensure new files are executable
chmod +x "$APP_DIR"/scripts/*.sh

# Append at least 5 new student records to data/submissions.txt
# We attempt to follow the existing submissions.txt format.
# Detect delimiter/format by reading the first non-empty line.
first_line=$(awk 'NF{print; exit}' "$APP_DIR/data/submissions.txt")
echo "Detected sample line: $first_line"

# Provide 5 sample student records to append (adjust format if required).
# Example format assumed: firstname lastname,id,assignment,status,deadline (comma separated)
# If your supplied submissions.txt uses a different delimiter, you should edit or replace below accordingly.
cat >> "$APP_DIR/data/submissions.txt" <<'EOSS'

# >>> Additional sample entries added by create_environment.sh
Yai Majak,y.majak,Assignment1,not_submitted,2025-10-10
Victoria Athou,v.athou,Assignment1,submitted,2025-10-08
Atem Anyier,a.anyier,Assignment1,not_submitted,2025-10-11
Akoi Garang,a.garang,Assignment1,not_submitted,2025-10-12
NBA Youngboy,n.youngboy,Assignment1,submitted,2025-10-07
EOSS

# Make sure final files are executable
chmod +x "$APP_DIR/scripts/"*.sh || true

echo "Environment created at: $APP_DIR"
echo "To test: cd $APP_DIR && ./scripts/startup.sh"
