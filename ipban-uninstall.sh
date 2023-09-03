#!/bin/bash

rm "${HOME}/ipban-update.sh"
crontab -l | grep -v "ipban-update.sh" | crontab -
systemctl stop netfilter-persistent.service
systemctl disable netfilter-persistent.service
iptables -F && iptables -X && iptables -Z && ip6tables -F && ip6tables -X && ip6tables -Z 
iptables-save > /etc/iptables/rules.v4 && ip6tables-save > /etc/iptables/rules.v6
systemctl restart iptables ip6tables
clear && echo "IPBAN Uninstalled!" 
