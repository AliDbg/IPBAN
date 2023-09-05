# IPBAN

- Limit server input/output to IP countries
- Support TCP,UDP
- Support IPv4, IPv6
- Support Multi Port
- Support Multi Country
- Persistent settings after reboot
- Automatic IP update every 2 days
- Support Debian, Ubuntu

**Install**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban-installer.sh) -install 1 -io OUTPUT -geoip CN,IR,CU,VN,ZW,BY -limit DROP
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

[![Stargazers over time](https://starchart.cc/AliDbg/IPBAN.svg)](https://starchart.cc/AliDbg/IPBAN)
