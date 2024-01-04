#!/bin/bash
# v4.0 github.com/AliDbg/IPBAN ######### Linux Debian>11 Ubuntu>20
#bash ./ipban.sh -add OUTPUT -geoip CN,IR -limit DROP -icmp no
#bash ./ipban.sh -reset yes
#bash ./ipban.sh -remove yes
##################################################################
GEOIP="CN,IR,CU,VN,ZW,BY";LIMIT="x";RESET="n";REMOVE="n";ADD="";ICMP="yes";release="";Src=""
CHECK_OS(){
	[[ $EUID -ne 0 ]] && echo "Run as root!" && exit 1
	if [[ -f /etc/redhat-release ]]; then Src="yum";release="centos";
	elif grep -Eqi "debian" /etc/issue; then Src="apt";release="debian";
	elif grep -Eqi "ubuntu" /etc/issue; then Src="apt";release="ubuntu";
	elif grep -Eqi "centos|red hat|redhat" /etc/issue; then Src="yum";release="centos";
	elif grep -Eqi "debian|raspbian" /proc/version; then Src="apt";release="debian";
	elif grep -Eqi "ubuntu" /proc/version; then Src="apt";release="ubuntu";
	elif grep -Eqi "centos|red hat|redhat" /proc/version; then Src="yum";release="centos";
	fi
}
# get arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    -add) ADD="$2"; shift 2;;
    -reset) RESET="$2"; shift 2;;
    -remove) REMOVE="$2"; shift 2;;
    -icmp) ICMP="$2"; shift 2;;
    -geoip) GEOIP="$2"; shift 2;;
    -limit) LIMIT="$2"; shift 2;;
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
iptables_restart(){
	printf "\n\n" | sysctl -p && systemctl restart systemd-networkd.service iptables.service ip6tables.service netfilter-persistent.service
	sleep 1
}
iptables_reset_rules(){
	iptables -F && iptables -X && iptables -Z && ip6tables -F && ip6tables -X && ip6tables -Z 
}
iptables_save_restart(){
	iptables-save | awk '!x[$0]++' > /etc/iptables/rules.v4
	ip6tables-save | awk '!x[$0]++' > /etc/iptables/rules.v6
	iptables_restart
}
uninstall_ipban(){
	crontab -l | grep -v "ipban-update.sh" | crontab -
	systemctl stop netfilter-persistent.service && systemctl disable netfilter-persistent.service
	iptables_reset_rules
	rm /etc/iptables/rules.v4 && rm /etc/iptables/rules.v6
	iptables-save
	rm -rf /usr/share/ipban/
	success "IPBAN Uninstalled!"
}

download_build_dbip (){
	mkdir -p /usr/share/ipban/ && chmod a+rwx /usr/share/ipban/
cat > "/usr/share/ipban/download-build-dbip.sh" << EOF
#!/bin/bash
	dtmp="/usr/share/xt_geoip/tmp/"
	rm -rf "\${dtmp}" && mkdir -p "\${dtmp}" && cd "\${dtmp}"
	# Download dbipLite Full
	timestamp=\$(date "+%Y-%m")
	curl -m 9 -fLO "https://download.db-ip.com/free/dbip-country-lite-\${timestamp}.csv.gz" &> /dev/null
	curl -m 9 -fLO "https://mailfud.org/geoip-legacy/GeoIP-legacy.csv.gz" -O &> /dev/null
	if [[ "\$?" != 0 ]]; then
	curl -m 9 -fLO "https://legacy-geoip-csv.ufficyo.com/Legacy-MaxMind-GeoIP-database.tar.gz" &> /dev/null
	fi		
	# Combine all csv and remove duplicates 
	gzip -dfq *.gz
	find . -name "*.tar" -exec tar xvf {} \;
	find . -name "*.tar.gz" -exec tar xvzf {} \;
	cat "\${dtmp}GeoIP-legacy.csv" | tr -d '"' | cut -d, -f1,2,5 > "\${dtmp}GeoIP-legacy-processed.csv"
	rm "\${dtmp}GeoIP-legacy.csv"
	cat *.csv > geoip.csv 
	sort -u geoip.csv -o "/usr/share/xt_geoip/dbip-country-lite.csv"
	rm -rf "\${dtmp}"
EOF
	chmod +x "/usr/share/ipban/download-build-dbip.sh"
}

create_update_sh(){
mkdir -p /usr/share/ipban/ && chmod a+rwx /usr/share/ipban/
cat > "/usr/share/ipban/ipban-update.sh" << EOF
#!/bin/bash
	/usr/share/ipban/download-build-dbip.sh
	cd /usr/share/xt_geoip/
	/usr/libexec/xtables-addons/xt_geoip_build -s
	/usr/lib/xtables-addons/xt_geoip_build -D /usr/share/xt_geoip/
	cd && rm /usr/share/xt_geoip/dbip-country-lite.csv
	printf "\n\n" | sysctl -p && systemctl restart systemd-networkd.service iptables.service ip6tables.service
 	sleep 1 && clear && echo "Updated IPBAN!" 
EOF
chmod +x "/usr/share/ipban/ipban-update.sh"
}

iptables_rules(){
	iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	ip6tables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	
	if [[ ${ICMP} == *"n"* ]]; then
		iptables -A INPUT -p icmp -j DROP
		ip6tables -A INPUT -p icmp -j DROP
	fi	
	
	if [[ ${ADD} == *"I"* ]]; then
		iptables -A INPUT -m geoip --src-cc "${GEOIP}" -j "${LIMIT}"
		ip6tables -A INPUT -m geoip --src-cc "${GEOIP}" -j "${LIMIT}"
	fi
	
	if [[ ${ADD} == *"O"* ]]; then
		iptables  -A OUTPUT -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
		ip6tables -A OUTPUT -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
	fi
		
	if [[ ${ADD} == *"F"* ]]; then
		iptables -A FORWARD -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
		ip6tables -A FORWARD -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
	fi
}

install_ipban(){
	$Src -y update
	$Src -y install build-essential linux-headers-"$(uname -r)"
	$Src -y install curl gzip tar perl xtables-addons-common xtables-addons-dkms libtext-csv-xs-perl libmoosex-types-netaddr-ip-perl libnet-cidr-lite-perl iptables-persistent
	if [[ "${release}" == "debian" ]]; then
		printf 'y\n' | $Src -y install module-assistant xtables-addons-source
		printf 'y\n' | module-assistant prepare
		printf 'y\n' | module-assistant -f auto-install xtables-addons-source
	fi	
	rm -rf /usr/share/xt_geoip/ && mkdir -p /usr/share/xt_geoip/ && chmod a+rwx /usr/share/xt_geoip/
 	modprobe x_tables && modprobe xt_geoip
	if lsmod | grep -q "x_tables\|xt_geoip"; then echo "x_tables Installed!"; fi
	chmod +x -f /usr/lib/xtables-addons/xt_geoip_build
	chmod +x -f /usr/libexec/xtables-addons/xt_geoip_dl
	crontab -l | grep -v "ipban-update.sh" | crontab -
	(crontab -l 2>/dev/null; echo "$(shuf -i 1-59 -n 1) $(shuf -i 1-23 -n 1) * * * bash /usr/share/ipban/ipban-update.sh >/dev/null 2>&1") | crontab -
	download_build_dbip
	create_update_sh && bash "/usr/share/ipban/ipban-update.sh"	
	iptables_reset_rules
	iptables_rules
	systemctl enable netfilter-persistent.service && systemctl enable cron && ufw disable
	success "IPBAN Installed!"
}

add_ipban(){
	CHECK_OS
	if [[ -d "/usr/share/ipban/" ]] && lsmod | grep -q "x_tables\|xt_geoip" ; then
		iptables_rules
	else
		install_ipban
	fi
	iptables_save_restart
	success "Rules Added!"
}

reset_iptables(){
	iptables_reset_rules
	iptables_save_restart
	success "IPTABLES Resetted!"
}
if [[ -n ${ADD} ]]; then add_ipban; fi
if [[ ${RESET} == *"y"* ]]; then reset_iptables; fi
if [[ ${REMOVE} == *"y"* ]]; then uninstall_ipban; fi
#### END.
