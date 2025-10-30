# (Svendeprøve IT-supporter)  

## Overview

This project demonstrates the setup and configuration of a multi-site corporate network with VLANs, OSPF routing, NAT, and Active Directory on virtual servers. The goal is to simulate a realistic corporate environment where multiple departments are connected via WAN links, with users and servers organized by department and function.

**Sites:** Odense (primary, Internet-connected), Nyborg, Svendborg

**Note:** Routers and switches are **physical hardware**, while Domain Controllers are virtualized.

---

## Network Design

### VLAN & IP Plan

| Site      | VLAN | Subnet        | Device/Role | IP Address | Notes                        |
|----------|------|---------------|------------|-----------|-------------------------------|
| Odense   | 10   | 10.10.10.0/24 | RT01       | 10.10.10.1 | Client subnet                 |
| Odense   | 20   | 10.10.20.0/24 | RT01       | 10.10.20.1 | Server subnet                 |
| Odense   | 30   | 10.10.30.0/24 | RT01       | 10.10.30.1 | Printer subnet                |
| Odense   | 99   | 10.10.99.0/24 | RT01       | 10.10.99.1 | Management subnet             |
| Nyborg   | 10   | 10.20.10.0/24 | RT02       | 10.20.10.1 | Client subnet                 |
| Nyborg   | 99   | 10.20.99.0/24 | RT02       | 10.20.99.1 | Management subnet             |
| Svendborg| 10   | 10.30.10.0/24 | RT03       | 10.30.10.1 | Client subnet                 |
| Svendborg| 99   | 10.30.99.0/24 | RT03       | 10.30.99.1 | Management subnet             |
| WAN Links| -    | 172.16.x.0/30 | RT01 ↔ RT02/03 | see notes | Point-to-point site connections |

### Devices & Roles

| Device  | Role                           | Notes                       |
|---------|--------------------------------|-----------------------------|
| RT01    | NAT, OSPF, Router-on-a-Stick   | Internet via WAN DHCP       |
| RT02    | OSPF, default route to RT01    | No direct Internet          |
| RT03    | OSPF, default route to RT01    | No direct Internet          |
| SW01-03 | VLAN config, trunk to respective router | Switches per site (physical hardware) |
| Proxmox | Hosts virtual DCs (DC01, DC02), AD, DNS, DHCP | Odense site |

---

## Testing & Verification

### Switch & Router Commands

```bash
# Switch
show vlan brief
show interfaces status
show interfaces trunk

# Router
show ip interface brief
ping <IP>
show ip ospf neighbor
show ip route ospf
show ip nat translations
ping 8.8.8.8
traceroute 8.8.8.8
```

### SSH Access
```bash
ssh admin@<switch_IP>
show run | include username
show ip ssh
```

### WAN Connectivity
```bash
ping <remote site IP>
show cdp neighbors
```

---

## Domain Controllers Setup (PowerShell)

### DC01 – Primary DC

```powershell
# Static IP & DNS
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.10.20.10 -PrefixLength 24 -DefaultGateway 10.10.20.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.10.20.10,1.1.1.1

# Disable IPv6
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6

# Install roles
Install-WindowsFeature -Name AD-Domain-Services, DNS, FS-FileServer, DHCP -IncludeManagementTools
```

**Promote as Domain Controller:**
```powershell
$DomainName = "torbenbyg.local"
$DSRMPassword = ConvertTo-SecureString "torbenDSRM!2025" -AsPlainText -Force

Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword $DSRMPassword -InstallDNS -Force:$true
```

### DC02 – Secondary DC / Failover

```powershell
# Static IP & DNS
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.10.20.11 -PrefixLength 24 -DefaultGateway 10.10.20.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.10.20.10,1.1.1.1

# Install roles
Install-WindowsFeature -Name AD-Domain-Services, DNS, DHCP -IncludeManagementTools

# Promote as additional DC
Install-ADDSDomainController -DomainName $DomainName -Credential (Get-Credential) -InstallDNS -ReplicationSourceDC DC01.torbenbyg.local -Force:$true
```

**Verify replication & DHCP failover:**
```powershell
repadmin /replsummary
Get-ADDomainController -Filter *
Get-DhcpServerv4Failover
```

---

## Usage Instructions 🛠️

1. **Setup Physical Devices:**
   - Connect and power on physical routers (RT01-03) and switches (SW01-03).
   - Configure VLANs, trunk/access ports, and IP addressing according to the network design.

2. **Configure WAN Links:**
   - Connect point-to-point WAN links between sites.
   - Verify connectivity with `ping` and `show cdp neighbors`.

3. **Domain Controllers:**
   - Deploy virtual DC01 and DC02 in Proxmox.
   - Run DC01 scripts sequentially: rename, pre-promotion setup, promote, post-promotion setup.
   - Run DC02 scripts sequentially: rename & network setup, join domain, promote as additional DC, configure DHCP failover.

4. **Verification:**
   - Test VLAN connectivity with ping.
   - Verify OSPF routing between sites.
   - Confirm DHCP scopes and failover between DC01 and DC02.
   - Check Active Directory replication.

---

## Notes 📝

- VLANs separate clients, servers, printers, and management traffic.
- WAN links simulate inter-site connectivity.
- Routers and switches are physical; DCs run in virtual environment (Proxmox).
- All commands and scripts provided should be executed in the specified ord
