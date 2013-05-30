#!/bin/bash
VLAN=115
IP="192.168.${VLAN}.1"
ROUT="192.168.${VLAN}.2"

sudo vconfig add eth1 $VLAN
sudo ip addr add ${IP}/24 dev eth1.$VLAN
sudo ip link set up dev eth1.$VLAN
sudo ip route add 192.168.0.0/16 via $ROUT
sudo ip route add 172.16.0.0/12 via $ROUT
sudo ip route add 10.0.0.0/8 via $ROUT
