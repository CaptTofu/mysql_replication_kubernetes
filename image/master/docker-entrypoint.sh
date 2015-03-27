#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
	set -- mysqld "$@"
fi

if [ "$1" = 'mysqld' ]; then
	# read DATADIR from the MySQL config
	DATADIR="$("$@" --verbose --help 2>/dev/null | awk '$1 == "datadir" { print $2; exit }')"
	
	if [ ! -d "$DATADIR/mysql" ]; then
		if [ -z "$MYSQL_ROOT_PASSWORD" -a -z "$MYSQL_ALLOW_EMPTY_PASSWORD" ]; then
			echo >&2 'error: database is uninitialized and MYSQL_ROOT_PASSWORD not set'
			echo >&2 '  Did you forget to add -e MYSQL_ROOT_PASSWORD=... ?'
			exit 1
		fi
                if [ -z "$MYSQL_REPLICATION_PASSWORD" ]; then
                        echo >&2 'error: database is uninitialized and MYSQL_REPLICATION_PASSWORD not set'
                        echo >&2 '  Did you forget to add -e MYSQL_REPLICATION_PASSWORD=... ?'
                        exit 1
                fi

                echo 'Initializing database'
                mysqld --initialize-insecure=on --datadir="$DATADIR"
                echo 'Database initialized'
		
		# These statements _must_ be on individual lines, and _must_ end with
		# semicolons (no line breaks or comments are permitted).
		# TODO proper SQL escaping on ALL the things D:
		
		tempSqlFile='/tmp/mysql-first-time.sql'
		cat > "$tempSqlFile" <<-EOSQL
			DELETE FROM mysql.user ;
			CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
			GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
			DROP DATABASE IF EXISTS test ;
		EOSQL
		
		if [ "$MYSQL_DATABASE" ]; then
			echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" >> "$tempSqlFile"
		fi
		
		if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
			echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" >> "$tempSqlFile"
			
			if [ "$MYSQL_DATABASE" ]; then
				echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%' ;" >> "$tempSqlFile"
			fi
		fi
 
		echo "GRANT REPLICATION SLAVE, REPLICATION CLIENT on *.* TO 'repl'@'10.100.%' IDENTIFIED BY '$MYSQL_REPLICATION_PASSWORD';" >> "$tempSqlFile"
		echo "GRANT REPLICATION SLAVE, REPLICATION CLIENT on *.* TO 'repl'@'10.244.%' IDENTIFIED BY '$MYSQL_REPLICATION_PASSWORD';" >> "$tempSqlFile"
		echo "GRANT REPLICATION SLAVE, REPLICATION CLIENT on *.* TO 'repl'@'172.17.%' IDENTIFIED BY '$MYSQL_REPLICATION_PASSWORD';" >> "$tempSqlFile"
		
		echo 'FLUSH PRIVILEGES ;' >> "$tempSqlFile"
		
		set -- "$@" --init-file="$tempSqlFile"
	fi
	
	chown -R mysql:mysql "$DATADIR"
fi

exec "$@"
