sudo iptables -t mangle -A FORWARD -p tcp --dport 3001 -j DSCP --set-dscp 12
sudo iptables -t mangle -A FORWARD -p tcp --dport 3002 -j DSCP --set-dscp 20
sudo iptables -t mangle -A FORWARD -p tcp --dport 3010 -j DSCP --set-dscp 36

