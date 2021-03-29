#!/usr/bin/env bash
source "$(dirname $0)/_lib.sh"

echo "${_group}Waiting for Sentry to start ..."
# Start the whole setup, except nginx and relay.
$dc up -d --remove-orphans $($dc config --services | grep -v -E '^(nginx|relay)$')
$dc exec -T nginx service nginx reload

docker run --rm --network="${COMPOSE_PROJECT_NAME}_default" alpine ash \
  -c 'while [[ "$(wget -T 1 -q -O- http://web:9000/_health/)" != "ok" ]]; do sleep 0.5; done'

# Make sure everything is up. This should only touch relay and nginx
$dc up -d
echo "${_endgroup}"