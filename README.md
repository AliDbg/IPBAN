## IPBAN (Limiting IP countries with iptables+xt_geoip)

- Full IP Range
- Support IPv4-v6
- Support Multi-Country
- Support all protocols and ports
- Support INPUT/OUTPUT Server
- Persistent settings/rules after reboot
- Remove duplicate iptables rules
- Automatic IP update every day
- Support Ubuntu≥20 Debian≥11 CentOS≥8
## 

**Install [Add rules]**
```
bash <(wget -qO- raw.githubusercontent.com/AliDbg/IPBAN/main/ipban.sh) -add OUTPUT -geoip CN,IR -limit DROP
```

**Unistall IPBAN [Restore previous iptables settings]**
```
bash <(wget -qO- raw.githubusercontent.com/AliDbg/IPBAN/main/ipban.sh) -remove y
```

## 
#### Install Arguments
>
> **-add** **INPUT** or **OUTPUT** or **FORWARD**
>
> **-geoip** Country Alpha-2 code
>
> **-limit**  **DROP**(Reject) or **ACCEPT**(Allow)
>
> **-icmp no/yes** (Deny ping your server)

#### Useful commands
> iptables -F && ip6tables -F ## Reset iptables rules
> 
> systemctl enable firewalld ufw ## Enable firewall
> 
> iptables-save > rules.txt ## Backup iptables
> 
> iptables-restore < rules.txt ## Restore iptables
> 
> iptables -nvL # Show iptables rule
>
> ping x.x.x.x # Ping ip and domain

#### Tools
> SSH Client: https://github.com/nirui/sshwifty
>
> Checker: https://check-host.net
