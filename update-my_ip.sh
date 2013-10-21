#Need to update nova.conf to set my_ip to eth0
addr=`ifconfig eth0 | grep 'inet addr:'| cut -d: -f2 | awk '{ print $1}'`
sed -i -e "s|my_ip=.*|my_ip=${addr}|" /etc/nova/nova.conf
grep my_ip= /etc/nova/nova.conf