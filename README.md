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
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban-installer.sh) -install 1 -io OUTPUT -geoip CN,IR,CU,VN,ZW,BY -limit DROP -noicmp 1
```


**Add Rules**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban-installer.sh) -add 1 -io INPUT -geoip IR -limit ACCEPT
```

**Reset Rules**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban-installer.sh) -reset 1
```

**Remove IPBAN**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban-installer.sh) -remove 1
```
**Arguments**
>
> **-io** **INPUT** or **OUTPUT**
>
> **-geoip** Country	Alpha-2 code
>
> **-limit**  **ACCEPT** (allow IPs) **DROP** (block, no answer)
>
> **-noicmp** 1 > Disable ICMP Protocol for deny ping


[![Stargazers over time](https://starchart.cc/AliDbg/IPBAN.svg)](https://starchart.cc/AliDbg/IPBAN)
