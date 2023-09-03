#!/bin/bash

workdir=$(mktemp -d)
cd ${workdir}
/usr/libexec/xtables-addons/xt_geoip_dl
/usr/libexec/xtables-addons/xt_geoip_build -s
cd && rm -rf ${workdir}
modprobe xt_geoip
lsmod | grep ^xt_geoip
iptables -m geoip -h && ip6tables -m geoip -h

systemctl restart iptables.service ip6tables.service

clear && echo "IPBAN Updated!" 