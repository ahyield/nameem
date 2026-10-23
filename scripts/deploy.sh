#!/bin/bash -e

cd "$(dirname "$0")/.."

set -a
. .env.production
set +a

# Progress for the Claude Code status line: "<step> <total> <status> <started_epoch> <label>"
PROGRESS_FILE=tmp/deploy-progress
STEPS=(
  "Build and push app image"
  "Ensure kamal-proxy is running"
  "Detect stale containers"
  "Start container"
  "Prune old containers and images"
  "Releasing the deploy lock"
)
STARTED=$(date +%s)
step=0
label="Starting"

mkdir -p tmp
progress() { echo "$step ${#STEPS[@]} $1 $STARTED $label" > "$PROGRESS_FILE"; }
progress running

set +e
kamal deploy -d production 2>&1 | while IFS= read -r line; do
  printf '%s\n' "$line"
  for i in "${!STEPS[@]}"; do
    if [[ "$line" == "${STEPS[$i]}"* ]]; then
      step=$((i + 1))
      label="${STEPS[$i]}"
      progress running
    fi
  done
  # The build is most of the deploy, so show Docker's own stage progress, e.g. "(build 3/6)"
  if [ "$step" -eq 1 ]; then
    if [[ "$line" =~ \[([a-z0-9-]+)\ +([0-9]+/[0-9]+)\] ]]; then
      label="${STEPS[0]} (${BASH_REMATCH[1]} ${BASH_REMATCH[2]})"
      progress running
    elif [[ "$line" == *"exporting to image"* ]]; then
      label="${STEPS[0]} (pushing)"
      progress running
    fi
  fi
done
status=${PIPESTATUS[0]}
set -e

# The loop ran in a subshell, so read back the last step it reached
read -r step _ _ _ label < "$PROGRESS_FILE"
if [ "$status" -eq 0 ]; then
  step=${#STEPS[@]}
  progress done
else
  progress failed
fi
exit "$status"
