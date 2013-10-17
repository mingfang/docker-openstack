#!/usr/bin/env bash

#Install sample image
curl -O http://cdn.download.cirros-cloud.net/0.3.1/cirros-0.3.1-x86_64-disk.img
glance image-create --name="CirrOS 0.3.1" --disk-format=qcow2 --container-format=bare --is-public=true < cirros-0.3.1-x86_64-disk.img
rm cirros-0.3.1-x86_64-disk.img

glance image-list
