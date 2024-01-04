## IPBAN (Limiting IP countries with iptables+xt_geoip)

- Full IP Range
- Support IPv4-v6
- Support Multi-Country
- Support all protocols and ports
- Support INPUT/OUTPUT Server
- Persistent settings after reboot
- Automatic IP update every day
- Support Debian≥11 Ubuntu≥20
## 
> ```iptables-save > backup-rules.txt```
  
**Add Rules**
```
bash <(wget -qO- raw.githubusercontent.com/AliDbg/IPBAN/main/ipban.sh) -add OUTPUT -geoip CN,IR -limit DROP
```

**Reset Rules**
```
bash <(wget -qO- cdn.jsdelivr.net/gh/AliDbg/IPBAN/ipban.sh) -reset y
```

**Remove IPBAN**
```
bash <(wget -qO- cdn.jsdelivr.net/gh/AliDbg/IPBAN/ipban.sh) -remove y
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
