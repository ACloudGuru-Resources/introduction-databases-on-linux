#!/bin/bash

if ! test -f "/home/cloud_user/bin/setup_complete.txt"; then
    touch /home/cloud_user/bin/setup_complete.txt
    systemctl stop mssql-server
    export MSSQL_SA_PASSWORD=$(date +%s | sha256sum | base64 | head -c 32)
    echo $MSSQL_SA_PASSWORD > /home/cloud_user/database_passwd.txt
    /opt/mssql/bin/mssql-conf -n set-sa-password
    sleep 120
    systemctl start mssql-server
    /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $MSSQL_SA_PASSWORD -Q 'CREATE DATABASE demo'
    curl -O -L https://github.com/linuxacademy/content-intro-to-databases-on-linux/raw/master/demo.sql
    /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $MSSQL_SA_PASSWORD -d demo -i demo.sql
    rm demo.sql
fi

if ! $(systemctl is-active --quiet mssql-server)
then
  systemctl start mssql-server
fi