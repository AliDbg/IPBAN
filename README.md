## IPBAN (Limiting IP countries with iptables+xt_geoip)

- Full IP Range
- Support IPv4-v6
- Support Multi-Country
- Support all protocols and ports
- Support INPUT/OUTPUT Server
- Persistent settings after reboot
- Automatic IP update every day
- Support Debian v11-12, Ubuntu v20-22
## 
> ```iptables-save > backup-rules.txt```
  
**Install**
```
bash <(wget -qO- cdn.jsdelivr.net/gh/AliDbg/IPBAN/ipban.sh) -install yes -io OUTPUT -geoip CN,IR -limit DROP
```


**Add Rules**
```
bash <(wget -qO- cdn.jsdelivr.net/gh/AliDbg/IPBAN/ipban.sh) -add yes -io INPUT -geoip CN,RU -limit DROP
```

**Reset Rules**
```
bash <(wget -qO- cdn.jsdelivr.net/gh/AliDbg/IPBAN/ipban.sh) -reset yes
```

**Remove IPBAN**
```
bash <(wget -qO- cdn.jsdelivr.net/gh/AliDbg/IPBAN/ipban.sh) -remove yes
```
## 
#### Arguments
>
> **-io** **INPUT** or **OUTPUT** or **FORWARD**
>
> **-geoip** Country	Alpha-2 code
>
> **-limit**  **DROP**(Reject) or **ACCEPT**(Allow)
>
> **-icmp no/yes** (Disable/Enable ICMP Protocol for deny ping)


#### Tools
> SSH Client: https://github.com/nirui/sshwifty
>
> Checker: https://check-host.net
