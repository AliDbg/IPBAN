## IPBAN (Limiting IP countries with iptables)

- Restrict server input and output to IP countries.
- Support All Protocols and Ports.
- Support IPv4 and IPv6.
- Support Multi-Country
- Persistent settings after reboot
- Automatic IP update every two days
- Support for Debian and Ubuntu (v22, tested)

**Install**
```
bash <(wget -qO- https://cdn.jsdelivr.net/gh/AliDbg/IPBAN@main/ipban.sh) -install yes -io OUTPUT -geoip CN,IR,CU,VN,ZW,BY -limit DROP -noicmp yes
```


**Add Rules**
```
bash <(wget -qO- https://cdn.jsdelivr.net/gh/AliDbg/IPBAN@main/ipban.sh) -add yes -io INPUT -geoip CN,RU -limit DROP
# or ↓
bash <(wget -qO- https://cdn.jsdelivr.net/gh/AliDbg/IPBAN@main/ipban.sh) -add yes -io INPUT -geoip IR -limit ACCEPT
```

**Reset Rules**
```
bash <(wget -qO- https://cdn.jsdelivr.net/gh/AliDbg/IPBAN@main/ipban.sh) -reset yes
```

**Remove IPBAN**
```
bash <(wget -qO- https://cdn.jsdelivr.net/gh/AliDbg/IPBAN@main/ipban.sh) -remove yes
```
**Arguments**
>
> **-io** **INPUT** or **OUTPUT** or **FORWARD**
>
> **-geoip** Country	Alpha-2 code
>
> **-limit**  **DROP**(Reject) or **ACCEPT**(Allow)
>
> **-noicmp 1** (Disable ICMP Protocol for deny ping)


[![Stargazers over time](https://starchart.cc/AliDbg/IPBAN.svg)](https://starchart.cc/AliDbg/IPBAN)
