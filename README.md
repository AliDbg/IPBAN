# IPBAN

- Restrict server input and output to IP countries.
- Support TCP and UDP.
- Support IPv4 and IPv6.
- Support Multi-Port
- Support Multi-Country
- Remaining settings after reboot
- Automatic IP update every 2 days
- Support to Debian and Ubuntu (v22, tested)

**Install**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban-installer.sh) -install 1 -io OUTPUT -geoip CN,IR,CU,VN,ZW,BY -limit REJECT
```

**Reset Rules**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban-installer.sh) -reset 1
```

**Add Rules**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban-installer.sh) -add 1 -io INPUT -geoip CN,IR -limit ACCEPT
```

**Remove IPBAN**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban-installer.sh) -remove 1
```


> **-limit Note:**  **ACCEPT** (Allow IPs) **DROP** (good to INPUT, DoS Protection, no answer+timeout) **REJECT** (no timeout for client)


[![Stargazers over time](https://starchart.cc/AliDbg/IPBAN.svg)](https://starchart.cc/AliDbg/IPBAN)
