#!/bin/bash
# v5.1.0 github.com/AliDbg/IPBAN ######### Ubuntu≥20 Debian≥11 CentOS≥8
#bash ./ipban.sh -add OUTPUT -geoip CN,IR -limit DROP -icmp no
#bash ./ipban.sh -reset yes
#bash ./ipban.sh -remove yes
#########################################################################
[[ $EUID -ne 0 ]] && echo "Run as root!" && exit 1
GEOIP="CN,IR,RU";LIMIT="x";RESET="n";REMOVE="n";ADD="";ICMP="yes";

DISTRO="";OS_VER="";PM=$(type yum &>/dev/null && echo "yum" || echo "apt")
CHECKOS(){ 
	if [ -f /etc/os-release ]; then 
		DISTRO=$(cat /etc/os-release | grep -m 1 '^NAME=\|^ID=' | cut -f2 -d'"' | tr '[A-Z]' '[a-z]')	
		OS_VER=$(cat /etc/os-release | grep -m 1 '^VERSION=\|^VERSION_ID=' | cut -f2 -d'"' | grep -o '[0-9]*' | head -1)	
	elif hostnamectl | grep -q "Operating" ; then
		DISTRO=$(hostnamectl | awk '/Operating/ { print $3 }' | tr '[A-Z]' '[a-z]')
		OS_VER=$(hostnamectl | grep -m 1 "Operating" | cut -d: -f2 | grep -o '[0-9]*' | head -1)
	elif [ -f /etc/system-release ]; then 
		DISTRO=$(cat /etc/system-release | sed s/\ release.*// | tr '[A-Z]' '[a-z]')
		OS_VER=$(cat /etc/system-release | sed s/.*release\ // | sed s/\ .*// | grep -o '[0-9]*' | head -1)	
	elif [ "$PM" == "yum" ]; then 
		 DISTRO="centos";
	else DISTRO="debian";
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

_success() { echo -e "\e[1;42m $1 \e[0m";}
_error() { echo -e "\e[1;41m $1 \e[0m";}
_info() { echo -e "\e[1;44m $1 \e[0m";}
_warning() { echo -e "\e[1;43m $1 \e[0m";}

update_sysctl(){
	if [ -f "/etc/sysctl.conf" ] && [ ! -z "$1" ] && [ ! -z "$2" ]; then
		sed -i "/$1/d" /etc/sysctl.conf; echo "$1 = $2" | tee -a /etc/sysctl.conf
	fi
}

iptables_print() {
	#clear
	iptables -vnL | grep -m 1 "pkts"
	iptables -vnL | grep "geoip\|icmp";
	ip6tables -vnL | grep "geoip\|icmp";
}

iptables_clean_rules(){
	iptables -F;iptables -X;iptables -Z;ip6tables -F;ip6tables -X;ip6tables -Z 
}

iptables_save_rules(){
	iptables-save  | awk '/^COMMIT$/ { delete x; }; !x[$0]++' > /etc/iptables/rules.v4
	ip6tables-save | awk '/^COMMIT$/ { delete x; }; !x[$0]++' > /etc/iptables/rules.v6
	iptables-save  | awk '/^COMMIT$/ { delete x; }; !x[$0]++' > /etc/sysconfig/rules.v4
	ip6tables-save | awk '/^COMMIT$/ { delete x; }; !x[$0]++' > /etc/sysconfig/rules.v6
	iptables-save  | awk '/^COMMIT$/ { delete x; }; !x[$0]++' > /etc/sysconfig/iptables
	ip6tables-save | awk '/^COMMIT$/ { delete x; }; !x[$0]++' > /etc/sysconfig/ip6tables
	iptables-save  | awk '/^COMMIT$/ { delete x; }; !x[$0]++' > /etc/sysconfig/iptables-config
	ip6tables-save | awk '/^COMMIT$/ { delete x; }; !x[$0]++' > /etc/sysconfig/ip6tables-config
}

iptables_save(){
	mkdir -p /etc/iptables/ 
	mkdir -p /etc/sysconfig/
	iptables_save_rules
	iptables_clean_rules
	iptables-restore  < /etc/iptables/rules.v4 
	ip6tables-restore < /etc/iptables/rules.v6
	iptables_save_rules
}

uninstall_ipban(){
	crontab -l | grep -v "ipban\|iptables" | crontab -
	iptables_clean_rules
	rm -f "/etc/iptables/rules.v4" "/etc/iptables/rules.v6"
	rm -f "/etc/sysconfig/rules.v4" "/etc/sysconfig/rules.v6"
	rm -f "/etc/sysconfig/iptables" "/etc/sysconfig/ip6tables"
	rm -f "/etc/sysconfig/iptables-config" "/etc/sysconfig/ip6tables-config"
	iptables-restore < /usr/share/ipban/backup-rules-ipv4.txt
	ip6tables-restore < /usr/share/ipban/backup-rules-ipv6.txt
	iptables-save
	ip6tables-save
	rm -rf /usr/share/ipban/
	clear
	_success "IPBAN Uninstalled!" && exit 1
}

download_build_dbip (){
cat > "/usr/share/ipban/download-build-dbip.sh" << EOF
#!/bin/bash
	dtmp="/usr/share/xt_geoip/tmp/"
	rm -rf "\${dtmp}" && mkdir -p "\${dtmp}" && cd "\${dtmp}"
	timestamp=\$(date "+%Y-%m")
	curl -m 20 -fLO "https://download.db-ip.com/free/dbip-country-lite-\${timestamp}.csv.gz" &> /dev/null
	curl -m 20 -fLO "https://mailfud.org/geoip-legacy/GeoIP-legacy.csv.gz" -O &> /dev/null
	[[ "\$?" != 0 ]] &&	curl -m 20 -fLO "https://legacy-geoip-csv.ufficyo.com/Legacy-MaxMind-GeoIP-database.tar.gz" &> /dev/null
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
	[ -f /usr/libexec/xtables-addons/xt_geoip_build ] && /usr/libexec/xtables-addons/xt_geoip_build -s
	[ -f /usr/lib/xtables-addons/xt_geoip_build ] && /usr/lib/xtables-addons/xt_geoip_build -D /usr/share/xt_geoip/
	cd && rm -f /usr/share/xt_geoip/dbip-country-lite.csv
	\$( sysctl -p > /dev/null 2>&1; init 1; init 3 )
	echo
EOF
chmod +x "/usr/share/ipban/ipban-update.sh"
}

iptables_rules(){

	iptables  -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	iptables  -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	ip6tables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	
	if [[ ${ADD} == *"I"* ]]; then
		iptables  -A INPUT -m geoip --src-cc "${GEOIP}" -j "${LIMIT}"
		ip6tables -A INPUT -m geoip --src-cc "${GEOIP}" -j "${LIMIT}"
	fi
	
	if [[ ${ADD} == *"O"* ]]; then
		iptables  -A OUTPUT -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
		ip6tables -A OUTPUT -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
	fi
		
	if [[ ${ADD} == *"F"* ]]; then
		iptables  -A FORWARD -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
		ip6tables -A FORWARD -m geoip --dst-cc "${GEOIP}" -j "${LIMIT}"
	fi
	
	if [[ ${ICMP} == *"n"* ]]; then
		iptables -A INPUT -p icmp -j DROP
		ip6tables -A INPUT -p ipv6-icmp -j DROP
	fi	
}

sys_updt(){
	$PM -y update
	sysctl -p > /dev/null 2>&1; init 1; init 3
	centosV=$(type rpm &>/dev/null && rpm -E %centos)
	fedoraV=$(type rpm &>/dev/null && rpm -E %fedora)
	rhelV=$(type rpm &>/dev/null && rpm -E %rhel)

	if [[ ${centosV} == ?(-)+([0-9]) ]]; then 
		dnf -y install "https://download1.rpmfusion.org/free/el/rpmfusion-free-release-${centosV}.noarch.rpm"
		dnf -y install "https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-${centosV}.noarch.rpm"
	fi
	
	if [[ ${rhelV} == ?(-)+([0-9]) ]]; then 
		dnf -y install "https://download1.rpmfusion.org/free/el/rpmfusion-free-release-${rhelV}.noarch.rpm"
		dnf -y install "https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-${rhelV}.noarch.rpm"
	fi

	if [[ ${fedoraV} == ?(-)+([0-9]) ]]; then 
		dnf -y install "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedoraV}.noarch.rpm"
		dnf -y install "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedoraV}.noarch.rpm"
	fi
	  
	if [[ $PM == "apt" ]]; then
		apt -y install build-essential linux-headers-"$(uname -r)" 
		apt -y install curl gzip tar perl xtables-addons-common xtables-addons-dkms libtext-csv-xs-perl libmoosex-types-netaddr-ip-perl libnet-cidr-lite-perl iptables-persistent
	else
		yum -y install kernel-devel-"$(uname -r)" iptables iptables-devel iptables-services perl-Net-CIDR-Lite perl-Text-CSV_XS epel-release epel-next-release
		dnf repolist enabled
		dnf -y update
		dnf -y install xtables-addons akmod-xtables-addons
		dnf -y install perl-App-cpanminus
		cpanm Net::CIDR::Lite
		cpanm Text::CSV_XS
	fi

 	if ! lsmod | grep -q "x_tables\|xt_geoip" && [[ "${DISTRO}" == *"debian"* ]]; then
		printf 'y\n' | apt -y install module-assistant xtables-addons-source
		printf 'y\n' | module-assistant prepare
		printf 'y\n' | module-assistant -f auto-install xtables-addons-source
	fi	

	systemctl daemon-reload 2>/dev/null
  	systemctl enable iptables.service 2>/dev/null
	systemctl enable ip6tables.service 2>/dev/null
	systemctl enable netfilter-persistent.service 2>/dev/null
	systemctl enable cron.service 2>/dev/null
}

install_ipban(){
 	sed -i "/fs.file-max/d" /etc/sysctl.conf
	sysctl -p > /dev/null 2>&1; init 1; init 3
	mkdir -p /usr/share/ipban/ && chmod a+rwx /usr/share/ipban/
	iptables-save  > /usr/share/ipban/backup-rules-ipv4.txt
	ip6tables-save > /usr/share/ipban/backup-rules-ipv6.txt
 	systemctl stop firewalld ufw 2>/dev/null 
	systemctl disable firewalld ufw 2>/dev/null
	crontab -l | grep -v "ipban\|iptables" | crontab -
	rm -rf /usr/share/xt_geoip/ && mkdir -p /usr/share/xt_geoip/ && chmod a+rwx /usr/share/xt_geoip/
	chmod +x -f /usr/lib/xtables-addons/xt_geoip_build
	chmod +x -f /usr/libexec/xtables-addons/xt_geoip_build
	depmod	-a
	if ! lsmod | grep -q "x_tables\|xt_geoip"; then
		modprobe -rq x_tables
		modprobe -fq x_tables
		modprobe -rq xt_geoip
		modprobe -fq xt_geoip
	fi
	if lsmod | grep -q "x_tables\|xt_geoip"; then
		_info "Building xt_geoip data...."; 
	else
		_error "x_tables not installed!";	exit 1;		
	fi	
	(crontab -l 2>/dev/null; echo "$(shuf -i 1-59 -n 1) $(shuf -i 1-23 -n 1) * * * bash /usr/share/ipban/ipban-update.sh 2>/dev/null") | crontab -
	(crontab -l 2>/dev/null; echo "@reboot iptables -nvL | grep -q 'geoip' || iptables-restore < /etc/iptables/rules.v4 && ip6tables-restore < /etc/iptables/rules.v6 2>/dev/null") | crontab -
	download_build_dbip
	create_update_sh
	bash /usr/share/ipban/ipban-update.sh
	iptables_clean_rules
	iptables_rules
	_success "IPBAN Installed!"
}

add_ipban(){
	CHECKOS
	if [[ -d "/usr/share/ipban/" ]] && lsmod | grep -q "x_tables\|xt_geoip" ; then
		iptables_rules
	else
		sys_updt
		install_ipban
	fi
	iptables_save
	iptables_print
	_success "Rules Added!"
}

reset_iptables(){
	iptables_clean_rules
	iptables_save
	iptables_print
	_success "IPTABLES Resetted!"
}

if [[ -n ${ADD} ]]; then add_ipban; fi
if [[ ${RESET} == *"y"* ]]; then reset_iptables; fi
if [[ ${REMOVE} == *"y"* ]]; then uninstall_ipban; fi

## The End ##
