#!/bin/bash
# update.sh: Pull and restart Docker Compose stacks, then notify Uptime Kuma.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

KUMA_URL="https://your-uptime-kuma.example.com/api/push/REPLACE_WITH_YOUR_TOKEN"

# Add your Compose stack directories here, one per line.
APPS=(
    "/home/<user>/apps/paperless-ngx"
    "/home/<user>/apps/it-tools"
    # "/home/<user>/apps/another-stack"
)

echo "Pruning unused Docker resources..."
docker system prune -f
docker image prune -af
echo "Docker cleanup complete."

FAILED=0

for APP in "${APPS[@]}"; do
    echo "Updating: $APP..."
    cd "$APP" || { echo "ERROR: Could not cd into $APP" >&2; FAILED=1; continue; }

    if docker compose pull && docker compose up -d; then
        echo "OK: $APP updated successfully"
    else
        echo "FAIL: $APP had errors" >&2
        FAILED=1
    fi
done

if [ "$FAILED" -eq 0 ]; then
    "$SCRIPT_DIR/notify_kuma.sh" up "All stacks updated successfully" "$KUMA_URL"
else
    "$SCRIPT_DIR/notify_kuma.sh" down "One or more stacks failed to update" "$KUMA_URL"
fi
