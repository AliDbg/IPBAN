#!/bin/bash
# v1.3.2 github.com/AliDbg/IPBAN 
# Linux Debian11-12 - Ubuntu20-22
#################################
#bash ./ipban.sh -install yes -io OUTPUT -geoip CN,IR,CU,VN -limit DROP -noicmp yes
#bash ./ipban.sh -add yes -io INPUT -geoip CN -limit DROP
#bash ./ipban.sh -reset yes
#bash ./ipban.sh -remove yes
##################################
#
#var
IO="x"
GEOIP="CN,IR,CU,VN,ZW,BY"
LIMIT="x"
INSTALL="n"
RESET="n"
REMOVE="n"
ADD="n"
NOICMP="x"
release=""
systemPackage=""
CHECK_OS(){
	[[ $EUID -ne 0 ]] && echo "not root!" && exit 0
	if [[ -f /etc/redhat-release ]];then
		release="centos"
		systemPackage="yum"
	elif cat /etc/issue | grep -q -E -i "debian";then
		release="debian"
		systemPackage="apt"
	elif cat /etc/issue | grep -q -E -i "ubuntu";then
		release="ubuntu"
		systemPackage="apt"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat";then
		release="centos"
		systemPackage="yum"
	elif cat /proc/version | grep -q -E -i "debian";then
		release="debian"
		systemPackage="apt"
	elif cat /proc/version | grep -q -E -i "ubuntu";then
		release="ubuntu"
		systemPackage="apt"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat";then
		release="centos"
		 systemPackage="yum"
	fi
}

# get arguments
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

iptables_restart(){
	service iptables restart && service ip6tables restart
	systemctl restart netfilter-persistent.service
	sleep 1
}

iptables_reset_rules(){
	iptables -F && iptables -X && iptables -Z && ip6tables -F && ip6tables -X && ip6tables -Z 
}

iptables_save_restart(){
	iptables-save > /etc/iptables/rules.v4 && ip6tables-save > /etc/iptables/rules.v6
	iptables_restart
}

uninstall_ipban(){
	crontab -l | grep -v "ipban-update.sh" | crontab -
	systemctl stop netfilter-persistent.service && systemctl disable netfilter-persistent.service
	iptables_reset_rules
	rm /etc/iptables/rules.v4 && rm /etc/iptables/rules.v6
	iptables-save
	rm -rf /usr/share/ipban/
	success "Uninstalled IPBAN!"
}

download_build_dbip (){
mkdir -p /usr/share/ipban/ && chmod a+rwx /usr/share/ipban/
cat > "/usr/share/ipban/download-build-dbip.sh" << EOF
#!/bin/bash
	## Thanks to kibazen_cn
	rm -rf /usr/share/xt_geoip/tmp/ && mkdir -p /usr/share/xt_geoip/tmp/ && chmod a+rwx /usr/share/xt_geoip/tmp/
	
 	# Download db-ip lite
	timestamp=\$(date "+%Y-%m")
	dbipcsv="/usr/share/xt_geoip/tmp/dbip-country-lite.csv.gz"
	wget "https://download.db-ip.com/free/dbip-country-lite-\${timestamp}.csv.gz" -O "\${dbipcsv}"
	gzip -d -q -f "\${dbipcsv}"

	# Download legacy csv
	wget "https://mailfud.org/geoip-legacy/GeoIP-legacy.csv.gz" -O /usr/share/xt_geoip/tmp/GeoIP-legacy.csv.gz &> /dev/null
	if [[ "\$?" != 0 ]]; then
		wget -q "https://legacy-geoip-csv.ufficyo.com/Legacy-MaxMind-GeoIP-database.tar.gz" -O - | tar -xvzf - -C /usr/share/xt_geoip/tmp/
	else
		gzip -d -q -f "/usr/share/xt_geoip/tmp/GeoIP-legacy.csv.gz"
	fi
	
	cat /usr/share/xt_geoip/tmp/GeoIP-legacy.csv | tr -d '"' | cut -d, -f1,2,5 > /usr/share/xt_geoip/tmp/GeoIP-legacy-processed.csv
	rm /usr/share/xt_geoip/tmp/GeoIP-legacy.csv

	# Combine all csv and remove duplicates 
	cd /usr/share/xt_geoip/tmp/ && cat *.csv > geoip.csv 
	sort -u geoip.csv -o /usr/share/xt_geoip/dbip-country-lite.csv
	rm -rf /usr/share/xt_geoip/tmp/
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
	service iptables restart && service ip6tables restart
	systemctl restart netfilter-persistent.service
	clear && echo "Updated IPBAN!" 
EOF
chmod +x "/usr/share/ipban/ipban-update.sh"
}


iptables_rules(){

	if [[ ${NOICMP} == *"y"* ]]; then
		iptables -A INPUT -p icmp -j DROP
		ip6tables -A INPUT -p icmp -j DROP
	fi	
	
	if [[ ${IO} == *"I"* ]]; then
		iptables -A INPUT -m geoip --src-cc "${GEOIP}" -j "${LIMIT}"
		ip6tables -A INPUT -m geoip --src-cc "${GEOIP}" -j "${LIMIT}"
	fi
	
	if [[ ${IO} == *"O"* ]]; then
		iptables  -A OUTPUT -m geoip -p tcp -m multiport --dports 0:39999 --dst-cc "${GEOIP}" -j "${LIMIT}"
		ip6tables -A OUTPUT -m geoip -p tcp -m multiport --dports 0:39999 --dst-cc "${GEOIP}" -j "${LIMIT}"
		iptables  -A OUTPUT -m geoip -p udp -m multiport --dports 0:39999 --dst-cc "${GEOIP}" -j "${LIMIT}"
		ip6tables -A OUTPUT -m geoip -p udp -m multiport --dports 0:39999 --dst-cc "${GEOIP}" -j "${LIMIT}"		
	fi
		
	if [[ ${IO} == *"F"* ]]; then
		iptables -A FORWARD -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
		ip6tables -A FORWARD -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
	fi
}

install_ipban(){
	CHECK_OS
	$systemPackage -y update
	$systemPackage -y install curl unzip gzip tar perl xtables-addons-common xtables-addons-dkms libtext-csv-xs-perl libmoosex-types-netaddr-ip-perl iptables-persistent libnet-cidr-lite-perl
	if [[ "${release}" == "debian" ]]; then
		$systemPackage -y install module-assistant xtables-addons-source
		module-assistant prepare
		module-assistant -f auto-install xtables-addons-source
	fi	
	rm -rf /usr/share/xt_geoip/ && mkdir -p /usr/share/xt_geoip/ && chmod a+rwx /usr/share/xt_geoip/
	modprobe x_tables && modprobe xt_geoip
	chmod +x /usr/lib/xtables-addons/xt_geoip_build
	chmod +x /usr/libexec/xtables-addons/xt_geoip_dl
	iptables_restart
	crontab -l | grep -v "ipban-update.sh" | crontab -
	(crontab -l 2>/dev/null; echo "0 3 */2 * * /usr/share/ipban/ipban-update.sh") | crontab -
	download_build_dbip
	create_update_sh && bash "/usr/share/ipban/ipban-update.sh"	
	iptables_reset_rules
	iptables_rules
	systemctl enable netfilter-persistent.service
	iptables_save_restart
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
