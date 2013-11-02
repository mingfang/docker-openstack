docker-openstack
================

Run OpenStack Havana in a Docker container.
Includes Keystone, Nova Controller, Glance, Dashboard, MySQL, Apache, and RabbitMQ 

Nova-Compute is setup for provisioning Docker images only. 
Details here http://docs.openstack.org/trunk/config-reference/content/docker.html

#### Prepare Vagrant
If you're using the offical Docker Vagrantfile to run Docker then you must `export FORWARD_DOCKER_PORTS=1` to forward all ports in the 49xxx range.

#### Start OpenStack container
After building the image using the `build` script, use `shell` script to launch OpenStack inside Docker.

#### Start OpenStack Services
Run ```supervisord&``` to start all OpenStack Services.

#### Docker in Docker
You now have Docker running inside Docker.  
The `docker ps` command will show that the Docker Registry is running in a container too.
Run the `install-ubuntu-image.sh` script to pull the `ubuntu` image into your local Registry.

#### Using Horizon
1. Point your browser to `http://localhost:49802/horizon`
2. You will now be able to launch Docker containers inside OpenStack!

#### Heat
Heat has been configured with the additional Docker plugin as described here. https://github.com/dotcloud/openstack-heat-docker

That means Heat can create stacks directly with Docker instead of Nova.  I'm still getting some errors with the wordpress example.


Special thanks to Jérôme Petazzoni for helping me with a previous DNS/Networking problem.
Find out more from his blog entry here http://jpetazzo.github.io/2013/10/16/configure-docker-bridge-network/
