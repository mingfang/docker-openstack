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
This part is a workaround caused by the Docker in Docker voodoo.  I don't a solution so the workaround is to use a ssh tunnel.
1. Using another terminal, `vagrant ssh` into your VM again.  
2. Then `sudo su` to become root.
3. `docker ps` to find out what port 22 is mapped to.  It should be 49Something.
4. Create a ssh tunnel into the container `ssh localhost -p 49204 -N -L 0.0.0.0:49888:localhost:80 -vv`. Note replace `49204` with your port.
5. Point your browser to `http://localhost:49888/horizon`
6. You will now be able to launch Docker containers inside OpenStack!
