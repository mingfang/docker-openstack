#Keystone
CREATE DATABASE keystone;
GRANT ALL ON keystone.* TO 'keystone'@'%';
GRANT ALL ON keystone.* TO 'keystone'@'localhost';

#Nova
CREATE DATABASE nova;
GRANT ALL ON nova.* TO 'nova'@'%';
GRANT ALL ON nova.* TO 'nova'@'localhost';

#Glance
CREATE DATABASE glance;
GRANT ALL ON glance.* TO 'glance'@'%';
GRANT ALL ON glance.* TO 'glance'@'localhost';

#Cinder
#CREATE DATABASE cinder;
#GRANT ALL ON cinder.* TO 'cinder'@'%';
#GRANT ALL ON cinder.* TO 'cinder'@'localhost';

#Neutron
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost';

#Heat
CREATE DATABASE heat;
GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'%';
GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'localhost';
