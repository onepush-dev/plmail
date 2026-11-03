#!/bin/sh
# Railway wrapper: plMail's all-in-one web server serves plain HTTP on :80.
# Railway runs healthchecks against the injected $PORT, so also listen there
# when it differs. An explicit SERVER_NAME in the service Variables still wins.
set -e
if [ -z "${SERVER_NAME:-}" ]; then
	if [ -n "${PORT:-}" ] && [ "$PORT" != "80" ]; then
		export SERVER_NAME=":80, :${PORT}"
	else
		export SERVER_NAME=":80"
	fi
fi
exec docker-entrypoint "$@"
