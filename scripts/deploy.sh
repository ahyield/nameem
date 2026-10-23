#!/bin/bash -e

cd "$(dirname "$0")/.."

set -a
. .env.production
set +a

kamal deploy -d production
