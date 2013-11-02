#Openstack

FROM ubuntu
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

#Prevent daemon start during install
RUN	echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && \
	mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server && \
	mkdir /var/run/sshd && \
	echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat

#Others
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vlan bridge-utils python python-pip python-software-properties software-properties-common python-keyring

#MySQL
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server python-mysqldb && \
    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf

#RabbitMQ
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y rabbitmq-server

#For Openstack
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-cloud-keyring && \
	echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/havana main" >> /etc/apt/sources.list.d/openstack.list &&\
    apt-get update

#Keystone
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y keystone && \
    sed -i -e 's/# admin_token = ADMIN/admin_token = ADMIN/' \
        -e "s#^connection.*#connection = mysql://keystone@localhost/keystone#" \
        /etc/keystone/keystone.conf

#Quantum
#RUN apt-get install -y quantum-server 
#RUN apt-get install -y quantum-plugin-linuxbridge 
#RUN apt-get install -y quantum-plugin-linuxbridge-agent 
#RUN apt-get install -y dnsmasq-base
#RUN apt-get install -y dnsmasq 
#RUN apt-get install -y quantum-dhcp-agent 
#RUN apt-get install -y quantum-l3-agent

#Nova Controller
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nova-novncproxy novnc nova-api nova-ajax-console-proxy nova-cert \
    	nova-conductor nova-consoleauth nova-doc nova-scheduler python-novaclient \
    	nova-network && \
    sed -i -e "s#^admin_tenant_name =.*#admin_tenant_name = service#" \
    	-e "s#^admin_user =.*#admin_user = nova#" \
    	-e "s#^admin_password =.*#admin_password = nova#" \
    	/etc/nova/api-paste.ini

#Glance
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y glance && \
    sed -i -e "s#^sql_connection.*#sql_connection = mysql://glance@localhost/glance#" \
    	-e "s#^admin_tenant_name =.*#admin_tenant_name = service#" \
    	-e "s#^admin_user =.*#admin_user = glance#" \
    	-e "s#^admin_password =.*#admin_password = glance#" \
    	-e "s|^\#config_file.*|config_file = /etc/glance/glance-api-paste.ini|" \
    	-e "s|^\#flavor.*|flavor = keystone|" \
        -e "2 i container_formats = ami,ari,aki,bare,ovf,docker" \
    	/etc/glance/glance-api.conf && \
    sed -i -e "s#^sql_connection.*#sql_connection = mysql://glance@localhost/glance#" \
    	-e "s#^admin_tenant_name =.*#admin_tenant_name = service#" \
    	-e "s#^admin_user =.*#admin_user = glance#" \
    	-e "s#^admin_password =.*#admin_password = glance#" \
    	-e "s|^\#config_file.*|config_file = /etc/glance/glance-registry-paste.ini|" \
    	-e "s|^\#flavor.*|flavor = keystone|" \
    	/etc/glance/glance-registry.conf  && \
    echo "[pipeline:glance-registry-keystone]\npipeline = authtoken context registryapp" >> /etc/glance/glance-registry-paste.ini

#Cinder
#RUN apt-get -y install cinder-api cinder-scheduler cinder-volume open-iscsi python-cinderclient tgt && \
#    sed -i -e "s#^admin_tenant_name =.*#admin_tenant_name = service#" \
#    	-e "s#^admin_user =.*#admin_user = cinder#" \
#    	-e "s#^admin_password =.*#admin_password = cinder#" \
#    	/etc/cinder/api-paste.ini && \
# 	echo 'sql_connection = mysql://cinder@localhost/cinder\nrabbit_host = localhost' >> /etc/cinder/cinder.conf 

#Dashboard
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y memcached python-memcache libapache2-mod-wsgi openstack-dashboard && \
    apt-get remove -y --purge openstack-dashboard-ubuntu-theme && \
    echo "SESSION_ENGINE = 'django.contrib.sessions.backends.cache'" >> /etc/openstack-dashboard/local_settings.py

#Nova Compute Node
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nova-compute && \
    sed -i -e "s|^compute_driver=.*|compute_driver=docker.DockerDriver|" /etc/nova/nova-compute.conf

#Docker
RUN DEBIAN_FRONTEND=noninteractive apt-get install -qqy iptables ca-certificates lxc && \
    wget -O /usr/local/bin/docker https://get.docker.io/builds/Linux/x86_64/docker-latest && \
    chmod +x /usr/local/bin/docker
VOLUME /var/lib/docker

#todo move up later
#Neutron
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y neutron-server neutron-dhcp-agent neutron-plugin-openvswitch neutron-l3-agent
RUN echo "net.ipv4.ip_forward=1\nnet.ipv4.conf.all.rp_filter=0\nnet.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf
RUN sed -i -e "s#^admin_tenant_name =.*#admin_tenant_name = service#" \
    	-e "s#^admin_user =.*#admin_user = neutron#" \
       	-e "s#^admin_password =.*#admin_password = neutron#" \
        -e "s#^connection.*#connection = mysql://neutron@localhost/neutron#" \
 	/etc/neutron/neutron.conf && \
    sed -i -e "s|.*auth_token.*|paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory\nauth_host = localhost\nauth_uri=http://localhost:5000\nadmin_tenant_name = service\nadmin_user = neutron\nadmin_password = neutron|" \
 	    /etc/neutron/api-paste.ini

#Heat
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y heat-api heat-api-cfn heat-engine
RUN mkdir /etc/heat/environment.d && \
    sed -i -e "s|^sql_connection.*||" \
           -e "s|^#sql_connection.*|sql_connection = mysql://heat@localhost/heat|" \
        /etc/heat/heat.conf && \
    sed -i -e "s|.*auth_token.*|paste.filter_factory = heat.common.auth_token:filter_factory\nauth_host = localhost\nauth_port = 35357\nauth_protocol = http\nadmin_tenant_name = service\nadmin_user = heat\nadmin_password = heat|" \
        /etc/heat/api-paste.ini

RUN git clone https://github.com/dotcloud/openstack-heat-docker.git && \
    pip install -r openstack-heat-docker/requirements.txt && \
    mkdir /usr/lib/heat && \
    ln -sf $(cd openstack-heat-docker/plugin; pwd) /usr/lib/heat/docker


#Config files
ADD ./ /docker-openstack
RUN cd /docker-openstack && \
    chmod +x *.sh && \
    mv /etc/nova/nova.conf /etc/nova/nova.conf.saved && \
    cp nova.conf /etc/nova/nova.conf && \
    cp supervisord-openstack.conf /etc/supervisor/conf.d/supervisord-openstack.conf


#Init MySql
RUN mysqld & keystone-all & apachectl start & sleep 3 && \
    mysql < /docker-openstack/mysql.ddl && \
    keystone-manage db_sync && \
    /docker-openstack/sample_data.sh && \
    nova-manage db sync && \
    glance-manage db_sync && \
    heat-manage db_sync && \
    mysqladmin shutdown

#ENV
ENV OS_USERNAME admin
ENV OS_TENANT_NAME demo
ENV OS_PASSWORD secrete
ENV OS_AUTH_URL http://localhost:35357/v2.0

EXPOSE 22 80




