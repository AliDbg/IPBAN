## IPBAN (Limiting IP countries with iptables)

- Restrict server input and output to IP countries.
- Support TCP and UDP Protocols
- Support IPv4 and IPv6
- Support Multi-Port
- Support Multi-Country
- Persistent settings after reboot
- Automatic IP update every two days
- Support Ubuntu Linux v20-22
> ! Upgrade and reboot your server! Then install ipban!
  
**Install**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban.sh) -install yes -io OUTPUT -geoip CN,IR,CU,VN,ZW,BY -limit DROP -noicmp yes
```


**Add Rules**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban.sh) -add yes -io INPUT -geoip CN,RU -limit DROP
```

**Reset Rules**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban.sh) -reset yes
```

**Remove IPBAN**
```
bash <(wget -qO- https://raw.githubusercontent.com/AliDbg/IPBAN/main/ipban.sh) -remove yes
```
**Arguments**
>
> **-io** **INPUT** or **OUTPUT** or **FORWARD**
>
> **-geoip** Country	Alpha-2 code
>
> **-limit**  **DROP**(Reject) or **ACCEPT**(Allow)
>
> **-noicmp yes** (Disable ICMP Protocol for deny ping)


## Tools
> SSH Client: https://github.com/nirui/sshwifty https://sshwifty-demo.nirui.org/
>
> Checker: https://check-host.net


[![Stargazers over time](https://starchart.cc/AliDbg/IPBAN.svg)](https://starchart.cc/AliDbg/IPBAN)
