#!/bin/bash
# ===========================
#  create_environment.sh
#  Self-contained submission-ready version
# ===========================

echo "Enter your name:"
read name

app_dir="submission_alert_${name}"
echo "Making app directory: $app_dir"
mkdir -p "$app_dir/scripts"

# ----- create config.env -----
cat <<EOF > "$app_dir/config.env"
ASSIGNMENT="Linux assignment"
STUDENT="$name"
EOF

# ----- create functions.sh -----
cat <<'EOF' > "$app_dir/scripts/functions.sh"
remind() {
    echo "Remember to complete your $ASSIGNMENT!"
}
EOF

# ----- create reminder.sh -----
cat <<'EOF' > "$app_dir/scripts/reminder.sh"
#!/bin/bash
source ../config.env
source ./functions.sh
remind
EOF
chmod +x "$app_dir/scripts/reminder.sh"

# ----- create startup.sh -----
cat <<'EOF' > "$app_dir/scripts/startup.sh"
#!/bin/bash
source ../config.env
source ./reminder.sh
EOF
chmod +x "$app_dir/scripts/startup.sh"

echo "Environment created successfully in $app_dir"
