#!/bin/bash -e

cd "$(dirname "$0")/.."

set -a
. .env.production
set +a

kamal app -d production exec -i "bin/rails c"
