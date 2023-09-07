#!/bin/bash
set -e
IO="x"
GEOIP="CN,IR,CU,VN,ZW,BY"
LIMIT="x"
INSTALL="n"
RESET="n"
REMOVE="n"
ADD="n"
NOICMP="x"

while [ "$#" -gt 0 ]; do
  case "$1" in
    -add) ADD="$2"; shift 2;;
    -reset) RESET="$2"; shift 2;;
    -remove) REMOVE="$2"; shift 2;;
    -install) INSTALL="$2"; shift 2;;
	-noicmp) NOICMP="$2"; shift 2;;
    -geoip) GEOIP="$2"; shift 2;;
    -limit) LIMIT="$2"; shift 2;;
    -io) IO="$2"; shift 2;;
    *) shift 1;;
  esac
done

success() {
	Green="\033[1;32m"
	Font="\033[0m"
	clear
	iptables -vnL
	echo -e "${Green}[+]${Font} $*"
	exit 0
}
iptables_reset_rules(){
	iptables -F && iptables -X && iptables -Z && ip6tables -F && ip6tables -X && ip6tables -Z 
}

iptables_save_restart(){
	iptables-save > /etc/iptables/rules.v4 && ip6tables-save > /etc/iptables/rules.v6
	systemctl restart iptables.service ip6tables.service
}

iptables_restore_restart(){
	iptables-restore < /usr/share/ipban/old_rules.v4 && ip6tables-restore < /usr/share/ipban/old_rules.v6 && 
	systemctl restart iptables.service ip6tables.service
}

uninstall_ipban(){
	crontab -l | grep -v "ipban-update.sh" | crontab -
	systemctl stop netfilter-persistent.service && systemctl disable netfilter-persistent.service
	iptables_reset_rules
	iptables_restore_restart
	rm -rf /usr/share/ipban/
	success "Uninstalled IPBAN!"
}

create_update_sh(){
mkdir -p /usr/share/ipban/ && chmod a+rwx /usr/share/ipban/
cat > "/usr/share/ipban/ipban-update.sh" << EOF
#!/bin/bash
workdir=\$(mktemp -d)
cd "\${workdir}"
/usr/libexec/xtables-addons/xt_geoip_dl
/usr/libexec/xtables-addons/xt_geoip_build -s
cd && rm -rf "\${workdir}"
modprobe x_tables
modprobe xt_geoip
lsmod | grep ^xt_geoip
lsmod | grep ^x_tables
iptables -m geoip -h && ip6tables -m geoip -h
systemctl restart iptables.service ip6tables.service
clear && echo "Updated IPBAN!" 
EOF
chmod +x "/usr/share/ipban/ipban-update.sh"
}

iptables_rules(){

	if [[ ${NOICMP} == *"y"* ]]; then
		iptables -A INPUT -p icmp -j DROP
		ip6tables -A INPUT -p icmp -j DROP
	fi	
	
	if [[ ${IO} == *"I"* && ${LIMIT} == *"A"* ]]; then
		iptables -A INPUT -p tcp -m multiport --dports 0:9999 -m geoip ! --src-cc "${GEOIP}" -j DROP
		ip6tables -A INPUT -p tcp -m multiport --dports 0:9999 -m geoip ! --src-cc "${GEOIP}" -j DROP
		
		iptables -A INPUT -p udp -m multiport --dports 0:9999 -m geoip ! --src-cc "${GEOIP}" -j DROP
		ip6tables -A INPUT -p udp -m multiport --dports 0:9999 -m geoip ! --src-cc "${GEOIP}" -j DROP
	fi
	
	
	if [[ ${IO} == *"I"* && ${LIMIT} == *"D"* ]]; then
		iptables -A INPUT -p tcp -m multiport --dports 0:9999 -m geoip --src-cc "${GEOIP}" -j "${LIMIT}"
		ip6tables -A INPUT -p tcp -m multiport --dports 0:9999 -m geoip --src-cc "${GEOIP}" -j "${LIMIT}"
		
		iptables -A INPUT -p udp -m multiport --dports 0:9999 -m geoip --src-cc "${GEOIP}" -j "${LIMIT}"
		ip6tables -A INPUT -p udp -m multiport --dports 0:9999 -m geoip --src-cc "${GEOIP}" -j "${LIMIT}"
	fi
	
	
	if [[ ${IO} == *"O"* ]]; then
		iptables -A OUTPUT -p tcp -m multiport --dports 0:9999 -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
		ip6tables -A OUTPUT -p tcp -m multiport --dports 0:9999 -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
		
		iptables -A OUTPUT -p udp -m multiport --dports 0:9999 -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
		ip6tables -A OUTPUT -p udp -m multiport --dports 0:9999 -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
	fi
		
	if [[ ${IO} == *"F"* ]]; then
		iptables -A FORWARD -p tcp -m multiport --dports 0:9999 -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
		ip6tables -A FORWARD -p tcp -m multiport --dports 0:9999 -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
		
		iptables -A FORWARD -p udp -m multiport --dports 0:9999 -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
		ip6tables -A FORWARD -p udp -m multiport --dports 0:9999 -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
	fi
}

install_ipban(){
	apt -y update && apt -y upgrade
	apt -y install curl unzip perl xtables-addons-common xtables-addons-dkms libtext-csv-xs-perl libmoosex-types-netaddr-ip-perl iptables-persistent && apt -y autoremove
	mkdir -p /usr/share/xt_geoip/ && chmod a+rwx /usr/share/xt_geoip/
	create_update_sh
	crontab -l | grep -v "ipban-update.sh" | crontab -
	(crontab -l 2>/dev/null; echo "0 3 */2 * * /usr/share/ipban/ipban-update.sh") | crontab -
	bash "/usr/share/ipban/ipban-update.sh"
	iptables-save > /usr/share/ipban/old_rules.v4 && ip6tables-save > /usr/share/ipban/old_rules.v6
	iptables_reset_rules
	iptables_rules
	systemctl enable netfilter-persistent.service && iptables_save_restart
	success "Installed IPBAN!"
}

add_ipban(){
	iptables_rules
	iptables_save_restart
	success "Added Rules!"
}

reset_iptables(){
	iptables_reset_rules
	iptables_save_restart
	success "Resetted IPTABLES!"
}

if [[ ${RESET} == *"y"* ]]; then
	reset_iptables
fi

if [[ ${ADD} == *"y"* ]]; then
	add_ipban
fi

if [[ ${REMOVE} == *"y"* ]]; then
	uninstall_ipban
fi

if [[ ${INSTALL} == *"y"* ]]; then
	install_ipban
fi
