#!/bin/bash

addr=`ifconfig eth0 | grep 'inet addr:'| cut -d: -f2 | awk '{ print $1}'`
docker run -p 5042:5000 \
        -e SETTINGS_FLAVOR=openstack \
        -e OS_USERNAME=admin \
        -e OS_PASSWORD=secrete \
        -e OS_TENANT_NAME=demo \
        -e OS_GLANCE_URL="http://${addr}:9292" \
        -e OS_AUTH_URL="http://${addr}:35357/v2.0" \
        samalba/docker-registry ./docker-registry/run.sh