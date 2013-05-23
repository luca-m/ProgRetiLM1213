sudo sysctl -w net.ipv4.ip_forward=1

net=$(( 100 + $1))

sudo vconfig add eth1 $1
sudo vconfig add eth1 $net

sudo ifconfig eth1.$1 up
sudo ifconfig eth1.$net up

sudo ifconfig eth1.$1 172.16.$1.5/30
sudo ifconfig eth1.$net 192.168.$net.2/24

sudo ifconfig eth0 172.16.$1.2/30

sudo ifconfig lo:1 inet 172.30.$1.1 netmask 255.255.255.255 up

sudo ip addr add 172.30.$1.1/32 dev lo

sudo /etc/init.d/zebra start
sudo /etc/init.d/ospfd start
