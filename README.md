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
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban-installer.sh) -install yes -io OUTPUT -geoip CN,IR,CU,VN,ZW,BY -limit DROP -noicmp y
```


**Add Rules**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban-installer.sh) -add yes -io INPUT -geoip IR -limit ACCEPT

# or ↓
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban-installer.sh) -add yes -io INPUT -geoip CN,RU,US -limit DROP
```

**Reset Rules**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban-installer.sh) -reset yes
```

**Remove IPBAN**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban-installer.sh) -remove yes
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
