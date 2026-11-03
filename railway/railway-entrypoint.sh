#!/bin/sh
# Railway wrapper around plMail's own entrypoint (docker-entrypoint).
#  1. The all-in-one web server serves plain HTTP on :80. Railway runs healthchecks
#     against the injected $PORT, so also listen there when it differs. An explicit
#     SERVER_NAME in the service Variables still wins.
#  2. First admin without an open /install page: when ADMIN_PASSWORD is set and no
#     user exists yet, create the admin (ADMIN_EMAIL, default admin@plmail.local)
#     with plMail's own headless `app:setup` as soon as the app is healthy. Once any
#     user exists this is a no-op, so changing the password in plMail is safe.
set -e

if [ -z "${SERVER_NAME:-}" ]; then
	if [ -n "${PORT:-}" ] && [ "$PORT" != "80" ]; then
		export SERVER_NAME=":80, :${PORT}"
	else
		export SERVER_NAME=":80"
	fi
fi

if [ "${1:-}" = 'frankenphp' ] && [ -n "${ADMIN_PASSWORD:-}" ]; then
	(
		i=0
		until curl -fsS -o /dev/null http://127.0.0.1:80/healthz 2>/dev/null; do
			i=$((i + 1)); [ "$i" -ge 300 ] && { echo 'railway: app not healthy after 10 min; skipped admin bootstrap' >&2; exit 0; }
			sleep 2
		done
		if APP_DEV_USER_EMAIL="${ADMIN_EMAIL:-admin@plmail.local}" APP_DEV_USER_PASSWORD="$ADMIN_PASSWORD" \
			php bin/console app:setup --no-interaction >/tmp/railway-admin-bootstrap.log 2>&1; then
			if grep -q 'users already existing' /tmp/railway-admin-bootstrap.log; then
				echo 'railway: admin bootstrap skipped, users already exist'
			else
				echo "railway: created the first admin ${ADMIN_EMAIL:-admin@plmail.local} (password = ADMIN_PASSWORD variable)"
			fi
		else
			echo 'railway: admin bootstrap failed; open /install to create the first admin' >&2
			tail -n 5 /tmp/railway-admin-bootstrap.log >&2 || true
		fi
		rm -f /tmp/railway-admin-bootstrap.log
	) &
fi

exec docker-entrypoint "$@"
