#Need to update nova.conf to set my_ip to eth0
addr=`ifconfig eth0 | grep 'inet addr:'| cut -d: -f2 | awk '{ print $1}'`
sed -i -e "s|my_ip=.*|my_ip=${addr}|" /etc/nova/nova.conf
grep my_ip= /etc/nova/nova.conf

#Setup docker0 bridge
ip link add docker0 type bridge
ip addr add 172.30.1.1/20 dev docker0
ip link set docker0 up

ip addr ls