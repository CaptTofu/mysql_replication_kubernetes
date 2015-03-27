#!/bin/bash

sed "s/SERVER_ID/${RANDOM}/g" /tmp/my.cnf.tmpl > /etc/mysql/my.cnf
