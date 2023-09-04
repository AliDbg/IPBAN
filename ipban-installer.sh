#!/bin/bash

IO="OUTPUT"
GEOIP="CN,IR,CU,VN,ZW,BY"
LIMIT="DROP"

success() {
	Green="\033[32m"
	Font="\033[0m"
	echo -e "${Green}[+]${Font} $*"
}

uninstall_ipban(){
	rm "${HOME}/ipban-update.sh"
	crontab -l | grep -v "ipban-update.sh" | crontab -
	systemctl stop netfilter-persistent.service && systemctl disable netfilter-persistent.service
	iptables -F && iptables -X && iptables -Z && ip6tables -F && ip6tables -X && ip6tables -Z 
	iptables-save > /etc/iptables/rules.v4 && ip6tables-save > /etc/iptables/rules.v6
	systemctl restart iptables.service ip6tables.service
	clear && success "Uninstalled IPBAN!" && exit 0
}

install_ipban(){
	apt update && apt -y upgrade

	apt -y install curl unzip perl xtables-addons-common xtables-addons-dkms libtext-csv-xs-perl libmoosex-types-netaddr-ip-perl iptables-persistent 

	mkdir /usr/share/xt_geoip/ && chmod +x /usr/share/xt_geoip/

	wget -P ${HOME} -N --no-check-certificate "https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban-update.sh"

	crontab -l | grep -v "ipban-update.sh" | crontab -
	(crontab -l 2>/dev/null; echo "0 3 */2 * * ${HOME}/ipban-update.sh") | crontab -
	chmod +x "${HOME}/ipban-update.sh" && bash "${HOME}/ipban-update.sh"

	iptables -F && iptables -X && iptables -Z && ip6tables -F && ip6tables -X && ip6tables -Z 

	iptables -A ${IO} -m geoip -p tcp  -m multiport --dports 0:9999 --dst-cc ${GEOIP} -j ${LIMIT}
	ip6tables -A ${IO} -m geoip -p tcp -m multiport --dports 0:9999 --dst-cc ${GEOIP} -j ${LIMIT}
	iptables -A ${IO} -m geoip -p udp  -m multiport --dports 0:9999 --dst-cc ${GEOIP} -j ${LIMIT}
	ip6tables -A ${IO} -m geoip -p udp -m multiport --dports 0:9999 --dst-cc ${GEOIP} -j ${LIMIT}

	iptables-save > /etc/iptables/rules.v4 && ip6tables-save > /etc/iptables/rules.v6

	systemctl enable netfilter-persistent.service && systemctl restart iptables.service ip6tables.service
	clear && success "Installed IPBAN!" && exit 0
}

resetIPtables(){
	iptables -F && iptables -X && iptables -Z && ip6tables -F && ip6tables -X && ip6tables -Z 
	iptables-save > /etc/iptables/rules.v4 && ip6tables-save > /etc/iptables/rules.v6
	systemctl restart iptables.service ip6tables.service
	clear && success "Resetted IPTABLES!" && exit 0
}
#######get params#########
while [[ $# > 0 ]];do
    key="$1"
    case $key in
		resetIPtables)
		resetIPtables
		;;
	install)
		install_ipban
		;;
	remove)
		uninstall_ipban
		;;
	'--geoip')
		if [[ -z "$2" ]]; then
          echo "error: Enter GEOIP"
          exit 1
        fi
		GEOIP="$2"
		shift
		;;
	'--io')
		if [[ -z "$2" ]]; then
          echo "error: Enter INPUT or OUTPUT!?"
          exit 1
        fi
		IO="$2"
		shift
		;;
	'--limit')
		if [[ -z "$2" ]]; then
          echo "error: Enter DROP or ACCEPT!?"
          exit 1
        fi
		LIMIT="$2"
		shift
		;;
        *)
         # unknown option
        ;;
    esac
    shift
done