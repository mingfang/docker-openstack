#Openstack

FROM ubuntu
 
RUN	echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list.d/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list.d/sources.list && \
    echo 'deb http://get.docker.io/ubuntu docker main' > /etc/apt/sources.list.d/docker.list && \
    apt-get update

#Prevent daemon start during install
RUN	echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d

#Supervisord
RUN apt-get install -y supervisor && \
	mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN apt-get install -y openssh-server && \
	mkdir /var/run/sshd && \
	echo 'root:root' |chpasswd

#Utilities
RUN apt-get install -y vim less ntp net-tools inetutils-ping curl git

#For Grizzly
RUN apt-get install -y ubuntu-cloud-keyring && \
	echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/grizzly main" >> /etc/apt/sources.list.d/grizzly.list &&\
    apt-get update

#Others
RUN apt-get install -y vlan bridge-utils python-software-properties software-properties-common python-keyring

#MySQL
RUN apt-get install -y mysql-server python-mysqldb && \
    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf

#RabbitMQ
RUN apt-get install -y rabbitmq-server
#RabbitMQ needs this to listen to localhost only
ENV RABBITMQ_NODENAME rabbit@localhost
ENV RABBITMQ_NODE_IP_ADDRESS 127.0.0.1
ENV ERL_EPMD_ADDRESS 127.0.0.1

#Keystone
RUN apt-get install -y keystone && \
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
RUN apt-get install -y nova-novncproxy novnc nova-api nova-ajax-console-proxy nova-cert \
    	nova-conductor nova-consoleauth nova-doc nova-scheduler nova-network \
    	memcached libapache2-mod-wsgi openstack-dashboard && \
    sed -i -e "s#^admin_tenant_name =.*#admin_tenant_name = service#" \
    	-e "s#^admin_user =.*#admin_user = nova#" \
    	-e "s#^admin_password =.*#admin_password = nova#" \
    	/etc/nova/api-paste.ini

#Glance
RUN apt-get install -y glance && \
    sed -i -e "s#^sql_connection.*#sql_connection = mysql://glance@localhost/glance#" \
    	-e "s#^admin_tenant_name =.*#admin_tenant_name = service#" \
    	-e "s#^admin_user =.*#admin_user = glance#" \
    	-e "s#^admin_password =.*#admin_password = glance#" \
    	-e "s|^\#config_file.*|config_file = /etc/glance/glance-api-paste.ini|" \
    	-e "s|^\#flavor.*|flavor = keystone|" \
    	/etc/glance/glance-api.conf && \
    sed -i -e "s#^sql_connection.*#sql_connection = mysql://glance@localhost/glance#" \
    	-e "s#^admin_tenant_name =.*#admin_tenant_name = service#" \
    	-e "s#^admin_user =.*#admin_user = glance#" \
    	-e "s#^admin_password =.*#admin_password = glance#" \
    	-e "s|^\#config_file.*|config_file = /etc/glance/glance-registry-paste.ini|" \
    	-e "s|^\#flavor.*|flavor = keystone|" \
    	/etc/glance/glance-registry.conf  && \
    echo "[pipeline:glance-registry-keystone]\npipeline = authtoken context registryapp" >> /etc/glance/glance-registry-paste.ini

#Docker in Docker, not working yet
#RUN apt-get install -y iptables ca-certificates && \
#	apt-get install -y --force-yes docker
RUN git clone https://github.com/mingfang/openstack-docker.git && \
    cd /openstack-docker && sh setup_on_rcbops-openstack.sh



#Cinder
#RUN apt-get -y install cinder-api cinder-scheduler cinder-volume open-iscsi python-cinderclient tgt && \
#    sed -i -e "s#^admin_tenant_name =.*#admin_tenant_name = service#" \
#    	-e "s#^admin_user =.*#admin_user = cinder#" \
#    	-e "s#^admin_password =.*#admin_password = cinder#" \
#    	/etc/cinder/api-paste.ini && \
# 	echo 'sql_connection = mysql://cinder@localhost/cinder\nrabbit_host = localhost' >> /etc/cinder/cinder.conf 


#Config files
ADD ./nova.conf /etc/nova/nova.conf
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#Init MySql
ADD ./mysql.ddl mysql.ddl
ADD ./sample_data.sh sample_data.sh
RUN mysqld & keystone-all & sleep 3 && \
    mysql < mysql.ddl && \
    keystone-manage db_sync && \
    bash sample_data.sh && \
    nova-manage db sync && \
    glance-manage db_sync && \
    mysqladmin shutdown

#ENV
ENV OS_USERNAME admin
ENV OS_TENANT_NAME demo
ENV OS_PASSWORD secrete
ENV OS_AUTH_URL http://localhost:35357/v2.0

#ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_RUN_USER nova
ENV APACHE_RUN_GROUP nova
EXPOSE 22 80


