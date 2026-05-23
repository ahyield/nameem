#!/bin/bash -e

set -a
. .env.production
set +a

kamal app -d production exec -i "bin/rails c"
