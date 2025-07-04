#!/bin/bash -e

set -a
. .env.production
set +a

kamal deploy -d production
