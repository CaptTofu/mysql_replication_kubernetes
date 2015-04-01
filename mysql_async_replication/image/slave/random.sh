#!/bin/bash

hostname=`hostname`
sed "s/SERVER_ID/${RANDOM}/g;s/HOSTNAME/${hostname}/g" /tmp/my.cnf.tmpl > /etc/mysql/my.cnf
