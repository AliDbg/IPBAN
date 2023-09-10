## IPBAN (Limiting IP countries with iptables+xt_geoip)

- Full IP Range
- Support IPv4-v6
- Support Multi-Port
- Support Multi-Country
- Support INPUT/OUTPUT Server
- Persistent settings after reboot
- Automatic IP update every two days
- Support Debian v10-12, Ubuntu v20-22
## 
>Upgrade and reboot your server! ```apt update && apt -y upgrade && sleep 3 && reboot```
  
**Install**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban.sh) -install yes -io OUTPUT -geoip CN,IR,CU,VN,ZW,BY -limit DROP -noicmp yes
```


**Add Rules**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban.sh) -add yes -io INPUT -geoip CN -limit DROP
```

**Reset Rules**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban.sh) -reset yes
```

**Remove IPBAN**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban.sh) -remove yes
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
> **-noicmp yes** (Disable ICMP Protocol for deny ping)


#### Tools
> SSH Client: https://github.com/nirui/sshwifty https://sshwifty-demo.nirui.org/
>
> Checker: https://check-host.net
