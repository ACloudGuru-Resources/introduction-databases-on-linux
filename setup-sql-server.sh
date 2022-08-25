#!/bin/bash

if ! test -f "/home/cloud_user/database_passwd.txt"; then
    systemctl stop mssql-server
    export MSSQL_SA_PASSWORD=$(date +%s | sha256sum | base64 | head -c 32)
    echo $MSSQL_SA_PASSWORD > /home/cloud_user/database_passwd.txt
    /opt/mssql/bin/mssql-conf -n set-sa-password
    systemctl start mssql-server
    /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $MSSQL_SA_PASSWORD -Q 'CREATE DATABASE demo'
    curl -O -L https://github.com/linuxacademy/content-intro-to-databases-on-linux/raw/master/demo.sql
    /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $MSSQL_SA_PASSWORD -d demo -i demo.sql
    rm demo.sql
fi