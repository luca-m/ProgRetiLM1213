#!/bin/bash
VLAN=116
IP1="192.168.${VLAN}.1"
IP2="192.168.${VLAN}.129"
IP3="192.168.${VLAN}.193"
IP_UAWEI="10.16.15.1"

sudo vconfig add eth1 $VLAN

sudo ip addr add ${IP1}/25 dev eth1.$VLAN
sudo ip addr add ${IP2}/26 dev eth1.$VLAN
sudo ip addr add ${IP3}/26 dev eth1.$VLAN

# zebra ospf id
sudo ip addr add 172.30.${VLAN}.1/32 dev lo

sudo ip addr add ${IP_UAWEI}/30 dev eth0

sudo ip link set up dev eth1.$VLAN

sudo /etc/init.d/zebra start
sudo /etc/init.d/ospfd start

