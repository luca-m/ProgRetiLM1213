#!/bin/bash
VLAN=115
IP="192.168.${VLAN}.1"
ROUT="192.168.${VLAN}.2"

sudo vconfig add eth1 $VLAN
sudo vconfig add eth1 114
sudo ip addr add ${IP}/24 dev eth1.$VLAN
sudo ip addr add 192.168.114.1/24 dev eth1.114
sudo ip link set up dev eth1.$VLAN
sudo ip link set up dev eth1.114
