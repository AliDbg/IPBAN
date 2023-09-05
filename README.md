## IPBAN

- Restrict server input and output to IP countries.
- Support TCP and UDP.
- Support IPv4 and IPv6.
- Support Multi-Port
- Support Multi-Country
- Persistent settings after reboot
- Automatic IP update every two days
- Support for Debian and Ubuntu (v22, tested)

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
**Arguments**
>
> **-io:** **INPUT** or **OUTPUT**
>
> **-geoip:** Country	Alpha-2 code
>
> **-limit:**  **Accept** (allow IPs) **DROP** (good to input, DoS protection, block, no answer, timeout) **REJECT** (block + no timeout for client)

[![Stargazers over time](https://starchart.cc/AliDbg/IPBAN.svg)](https://starchart.cc/AliDbg/IPBAN)
