#!/bin/sh
# Applies the database setup. Needs PGHOST, PGUSER, PGDATABASE, PGPASSWORD,
# AUTHENTICATOR_PASSWORD and INITIAL_ADMIN_PIN in the environment.
set -e
case "$INITIAL_ADMIN_PIN" in
  [0-9][0-9][0-9][0-9]) ;;
  *) echo "ERROR: INITIAL_ADMIN_PIN must be exactly 4 digits (edit the app YAML)"; exit 1 ;;
esac
case "${RESET_ADMIN_PIN:-}" in
  ""|[0-9][0-9][0-9][0-9]) ;;
  *) echo "ERROR: RESET_ADMIN_PIN must be exactly 4 digits, or removed"; exit 1 ;;
esac
psql -v ON_ERROR_STOP=1 -q -v auth_pw="$AUTHENTICATOR_PASSWORD" -f /db/01-roles.sql
psql -v ON_ERROR_STOP=1 -q -f /db/02-schema.sql
psql -v ON_ERROR_STOP=1 -q -v admin_pin="$INITIAL_ADMIN_PIN" -f /db/03-seed.sql
psql -v ON_ERROR_STOP=1 -q -v reset_pin="${RESET_ADMIN_PIN:-}" -v reset_name="${RESET_ADMIN_NAME:-Russell Ralph}" -f /db/04-admin-pin-reset.sql
echo "Database ready"
