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

#### Start OpenStack services
1. Once in the Docker container, cd into the `docker-openstack` directory.
2. Run `update-my_ip.sh` to setup nova.conf correctly.
3. Use `supervisord&` to launch all the services. 

#### Docker in Docker
You now have Docker running inside Docker.  
The `docker ps` command will show that the Docker Registry is running in a container too.
Run the `install-ubuntu-image.sh` script to pull the `ubuntu` image into your local Registry.

#### Using Horizon
1. Point your browser to `http://localhost:49802/horizon`
2. You will now be able to launch Docker containers inside OpenStack!

Special thanks to Jérôme Petazzoni for helping me with a previous DNS/Networking problem.
Find out more from his blog entry here http://jpetazzo.github.io/2013/10/16/configure-docker-bridge-network/
