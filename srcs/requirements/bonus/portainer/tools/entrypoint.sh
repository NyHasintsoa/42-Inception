#!/bin/bash

set -e

exec /opt/portainer/portainer \
    --data=/data \
    --bind=:9090 \
    --no-analytics