#!/bin/bash

apt update && apt -y upgrade

apt -y install curl unzip perl xtables-addons-common xtables-addons-dkms libtext-csv-xs-perl libmoosex-types-netaddr-ip-perl iptables-persistent 

mkdir /usr/share/xt_geoip/ && chmod +x /usr/share/xt_geoip/

wget -P ${HOME} -N --no-check-certificate "https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban-update.sh"

crontab -l | grep -v "ipban-update.sh" | crontab -
(crontab -l 2>/dev/null; echo "0 3 */2 * * ${HOME}/ipban-update.sh") | crontab -
chmod +x "${HOME}/ipban-update.sh" && bash "${HOME}/ipban-update.sh"

iptables -F && iptables -X && iptables -Z && ip6tables -F && ip6tables -X && ip6tables -Z 

iptables -A OUTPUT -m geoip -p tcp  -m multiport --dports 0:9999 --dst-cc CN,IR,CU,VN,ZW,BY -j DROP
ip6tables -A OUTPUT -m geoip -p tcp -m multiport --dports 0:9999 --dst-cc CN,IR,CU,VN,ZW,BY -j DROP
iptables -A OUTPUT -m geoip -p udp  -m multiport --dports 0:9999 --dst-cc CN,IR,CU,VN,ZW,BY -j DROP
ip6tables -A OUTPUT -m geoip -p udp -m multiport --dports 0:9999 --dst-cc CN,IR,CU,VN,ZW,BY -j DROP

iptables-save > /etc/iptables/rules.v4 && ip6tables-save > /etc/iptables/rules.v6

systemctl enable netfilter-persistent.service && systemctl restart iptables.service ip6tables.service

clear && echo "IPBAN Done!" 