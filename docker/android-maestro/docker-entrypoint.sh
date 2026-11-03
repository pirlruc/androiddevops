#!/bin/sh
# Maestro dials 127.0.0.1:5037. On Docker Desktop that is not the host adb
# server. ADB_SERVER_SOCKET=tcp:host:port starts a relay on localhost.
set -eu
if [ -n "${ADB_SERVER_SOCKET:-}" ]; then
	java -cp /opt/adb-relay AdbRelay &
	sleep 0.5
fi
exec "$@"
