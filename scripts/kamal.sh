#!/bin/bash -e

# Runs any kamal command with the production secrets loaded, e.g.
#   scripts/kamal.sh proxy reboot -d production
#   scripts/kamal.sh app logs -f -d production
# With no arguments, opens a production Rails console.

cd "$(dirname "$0")/.."

set -a
. .env.production
set +a

if [ $# -eq 0 ]; then
  exec kamal app -d production exec -i "bin/rails c"
else
  exec kamal "$@"
fi
