#!/bin/bash

IP="172.30.115.1/32"
sudo ip addr add ${IP} dev lo

VLAN=115
IP="192.168.$VLAN.1/25"
sudo vconfig add eth1 $VLAN
sudo ip addr add ${IP} dev eth1.$VLAN
sudo ip link set up dev eth1.$VLAN

VLAN=1151
IP="192.168.115.193/26"
sudo vconfig add eth1 $VLAN
sudo ip addr add ${IP} dev eth1.$VLAN
sudo ip link set up dev eth1.$VLAN

VLAN=1152
IP="192.168.115.129/26"
sudo vconfig add eth1 $VLAN
sudo ip addr add ${IP} dev eth1.$VLAN
sudo ip link set up dev eth1.$VLAN

sudo sysctl -w net.ipv4.ip_forward=1
