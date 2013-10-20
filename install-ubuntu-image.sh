#!/bin/bash

addr=`ifconfig eth0 | grep 'inet addr:'| cut -d: -f2 | awk '{ print $1}'`

docker pull ubuntu
docker tag ubuntu ${addr}:5042/ubuntu
docker push ${addr}:5042/ubuntu

glance image-list
