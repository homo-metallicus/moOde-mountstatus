#!/bin/bash

SQLDB=/var/local/www/db/moode-sqlite3.db

LAST_ID=$(sqlite3 ${SQLDB} "SELECT id FROM cfg_system ORDER BY id DESC LIMIT 1;")
ID=$(($LAST_ID+1))
sqlite3 ${SQLDB} "INSERT INTO cfg_system VALUES ('"${ID}"','mount_status', '0');" && echo "OK" || echo "error"

exit 0
