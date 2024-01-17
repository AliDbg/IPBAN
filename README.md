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
**Backup IPtables/Disable ufw**
```
iptables-save  > backup-rules-ipv4.txt;ip6tables-save > backup-rules-ipv6.txt;\
systemctl stop firewalld ufw 2>/dev/null && systemctl disable firewalld ufw 2>/dev/null
```
  
**Install/Add Rules**
```
bash <(wget -qO- cdn.jsdelivr.net/gh/AliDbg/IPBAN/ipban.sh) -add OUTPUT -geoip CN,IR -limit DROP
```

**Reset Rules**
```
bash <(wget -qO- cdn.jsdelivr.net/gh/AliDbg/IPBAN/ipban.sh) -reset y
```

**Remove IPBAN**
```
bash <(wget -qO- cdn.jsdelivr.net/gh/AliDbg/IPBAN/ipban.sh) -remove y
```

**Ping IP/Domain for testing**
```
ping x.x.x.x
ping example.com
```


## 
#### Arguments
>
> **-add** **INPUT** or **OUTPUT** or **FORWARD**
>
> **-geoip** Country Alpha-2 code
>
> **-limit**  **DROP**(Reject) or **ACCEPT**(Allow)
>
> **-icmp no/yes** (Disable/Enable ICMP Protocol for deny ping)


#### Tools
> SSH Client: https://github.com/nirui/sshwifty
>
> Checker: https://check-host.net
