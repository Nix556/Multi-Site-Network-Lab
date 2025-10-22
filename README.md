# (Svendeprøve IT-supporter)

## Beskrivelse

Dette projekt handler om at opsætning og konfiguration et komplet multi-site firma-netværk med VLANs, OSPF-routing, NAT og Active Directory på virtuelle servere. Formålet er at simulere et realistisk firmamiljø, hvor flere afdelinger er forbundet via WAN-links, og hvor brugere og servere er organiseret efter afdeling og funktion.  

Projektet er opdelt i tre sites: **Odense**, **Nyborg** og **Svendborg**. Odense fungerer som primært site med Internet-adgang, mens de andre sites forbindes via point-to-point WAN-links.  

---

## VLAN & IP Plan

| Site       | VLAN | Subnet           | Enhed/Role           | IP-adresse       | Kommentar                             |
|------------|------|-----------------|--------------------|----------------|---------------------------------------|
| Odense     | 10   | 10.10.10.0/24   | RT01 Gi0/0.10      | 10.10.10.1     | Klient subnet                          |
| Odense     | 20   | 10.10.20.0/24   | RT01 Gi0/0.20      | 10.10.20.1     | Server subnet                          |
| Odense     | 30   | 10.10.30.0/24   | RT01 Gi0/0.30      | 10.10.30.1     | Printer subnet                         |
| Odense     | 99   | 10.10.99.0/24   | RT01 Gi0/0.99      | 10.10.99.1     | Management subnet                      |
| Nyborg     | 10   | 10.20.10.0/24   | RT02 Gi0/0.10      | 10.20.10.1     | Klient subnet                          |
| Nyborg     | 99   | 10.20.99.0/24   | RT02 Gi0/0.99      | 10.20.99.1     | Management subnet                      |
| Svendborg  | 10   | 10.30.10.0/24   | RT03 Gi0/0.10      | 10.30.10.1     | Klient subnet                          |
| Svendborg  | 99   | 10.30.99.0/24   | RT03 Gi0/0.99      | 10.30.99.1     | Management subnet                      |
| Odense     | WAN  | 172.16.1.0/30   | RT01 ↔ RT02        | 172.16.1.1     | Point-to-point link Odense↔Nyborg     |
| Odense     | WAN  | 172.16.2.0/30   | RT01 ↔ RT03        | 172.16.2.1     | Point-to-point link Odense↔Svendborg |

---

## Router & Switch Roller

| Enhed        | Rolle                                       | Kommentar |
|--------------|--------------------------------------------|-----------|
| RT01         | NAT, OSPF, router-on-a-stick for VLAN      | Internet adgang via WAN DHCP |
| RT02         | OSPF, default route til RT01               | Ingen direkte Internet |
| RT03         | OSPF, default route til RT01               | Ingen direkte Internet |
| SW01         | VLAN konfiguration, trunk til RT01         | Odense site |
| SW02         | VLAN konfiguration, trunk til RT02         | Nyborg site |
| SW03         | VLAN konfiguration, trunk til RT03         | Svendborg site |
| Proxmox Server  | Virtuelle servere DC1 & DC2, AD, DNS etc. | Odense site |

---

## Portplan
### Odense (SW01)
| Port         | VLAN | Beskrivelse                   | Kommentar                             |
|-------------|------|--------------------------------|---------------------------------------|
| Gi1/0/1     | Trunk | Til RT01 Gi0/1 (Router-on-a-Stick) | Tillader VLAN 10,20,30,99             |
| Gi1/0/2-10  | 10   | Klient-PC’er                  | VLAN 10 – Klient                       |
| Gi1/0/11-12 | 20   | Servere                        | VLAN 20 – Server                        |
| Gi1/0/13-14 | 30   | Printere                       | VLAN 30 – Printer                        |
| VLAN 99     | 99   | Management                     | IP: 10.10.99.2 / Gateway: 10.10.99.1  |

### Nyborg (SW02)
| Port        | VLAN | Beskrivelse                | Kommentar                             |
|------------|------|----------------------------|---------------------------------------|
| Gi0/1      | Trunk | Til RT02 Gi0/0 (Router)   | Tillader VLAN 10,99                    |
| Gi0/2-10   | 10   | Klient-PC’er               | VLAN 10 – Klient                       |
| VLAN 99    | 99   | Management                 | IP: 10.20.99.2 / Gateway: 10.20.99.1 |

### Svendborg (SW03)
| Port        | VLAN | Beskrivelse                | Kommentar                             |
|------------|------|----------------------------|---------------------------------------|
| Gi0/1      | Trunk | Til RT03 Gi0/0 (Router)   | Tillader VLAN 10,99                    |
| Gi0/2-10   | 10   | Klient-PC’er               | VLAN 10 – Klient                       |
| VLAN 99    | 99   | Management                 | IP: 10.30.99.2 / Gateway: 10.30.99.1 |

---

## Test & Verifikation

Her er de vigtigste kommandoer til at tjekke, om netværket fungerer korrekt.

### VLAN og interface status

**På switch:**
```bash
show vlan brief          # Tjek at VLANs er oprettet
show interfaces status   # Tjek at porte er oppe og tilknyttet de rigtige VLANs
show interfaces trunk    # Tjek trunk-porte og hvilke VLANs der går igennem
```

**På router**
```bash
show ip interface brief  # Tjek at subinterfaces og IP-adresser er oppe
ping <IP-adresse>        # Ping interne IP'er på VLAN/subnet for at teste forbindelse

show ip ospf neighbor    # Tjek at OSPF naboer er oppe
show ip route ospf       # Tjek hvilke ruter OSPF har lært

show ip nat translations    # Tjek aktive NAT-oversættelser
ping 8.8.8.8                # Tjek internetforbindelse
traceroute 8.8.8.8          # Spor ruten ud til internettet
```

**SSH-adgang**
```bash
ssh admin@<switch_IP>      # Tjek SSH-login til switch
show run | include username    # Tjek eksisterende brugere
show ip ssh                    # Tjek SSH-status
```

**VLAN-forbindelse mellem sites**
```bash
ping <IP-adresse på anden site>   # Test WAN-links
show cdp neighbors              # Tjek hvilke enheder der er fysisk koblet
```

---

## Domain Controller Opsætning med PowerShell

Dette projekt bruger PowerShell-scripts til at opsætte **AD DS, DNS og DHCP** på de virtuelle servere DC01 og DC02. DC01 er primær Domain Controller, mens DC02 fungerer som sekundær/failover DC for AD, DNS og DHCP.

### DC01 – Primær Domain Controller

**Første skridt – netværk og serverroller**
```powershell
# Tildel statisk IP og DNS
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.10.20.10 -PrefixLength 24 -DefaultGateway 10.10.20.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.10.20.10,1.1.1.1

# Slå IPv6 fra
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6

# Installer AD DS, DNS, DHCP og File Server roller
Install-WindowsFeature -Name AD-Domain-Services, DNS, FS-FileServer, DHCP -IncludeManagementTools
```

**Promover serveren til Domain Controller**
```
$DomainName = "torbenbyg.local"
$DSRMPassword = ConvertTo-SecureString "torbenDSRM!2025" -AsPlainText -Force

Install-ADDSForest `
    -DomainName $DomainName `
    -SafeModeAdministratorPassword $DSRMPassword `
    -InstallDNS `
    -Force:$true
```

**Opsæt DHCP scopes og option values**
```
Add-DhcpServerInDC -DnsName "DC01.torbenbyg.local" -IpAddress 10.10.20.10 

# Opret scopes for Odense, Nyborg og Svendborg
Add-DhcpServerv4Scope -Name "Odense" -StartRange 10.10.10.100 -EndRange 10.10.10.200 -SubnetMask 255.255.255.0
Set-DhcpServerv4OptionValue -ScopeId 10.10.10.0 -Router 10.10.10.1 -DnsServer 10.10.20.10
# Gentag for Nyborg og Svendborg scopes
```

**Opret OU’er, brugere og grupper**
```
$OUlist = "ingeniør","tømmer","murer","elektriker","lærling","sekretær","leder"

# Opret OU’er
foreach ($ou in $OUlist) {
    New-ADOrganizationalUnit -Name $ou -Path "DC=torbenbyg,DC=local"
}

# Opret fiktive brugere og grupper
# Se fuldt script i 'DC01-Setup.ps1'
```

### DC02 – Sekundær Domain Controller / Failover
**Før genstart – netværk og roller**
```
# Tildel statisk IP og DNS (peger på DC01)
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.10.20.11 -PrefixLength 24 -DefaultGateway 10.10.20.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.10.20.10,1.1.1.1

# Installer AD DS, DNS og DHCP
Install-WindowsFeature -Name AD-Domain-Services, DNS, DHCP -IncludeManagementTools
```

**Promover som additional DC**
```
$DomainName = "torbenbyg.local"
$DC01 = "DC01.torbenbyg.local"

Install-ADDSDomainController `
    -DomainName $DomainName `
    -Credential (Get-Credential) `
    -InstallDNS `
    -ReplicationSourceDC $DC01 `
    -Force:$true
```

**Efter genstart – kontrol og DHCP failover**
```
# Bekræft AD og DNS replikation
repadmin /replsummary
Get-ADDomainController -Filter *

# Opsæt DHCP failover med DC01
$PartnerServer = "DC01"
$LocalDHCPServer = $env:COMPUTERNAME

Add-DhcpServerv4Failover -Name "DHCP-Failover" `
    -PartnerServer $PartnerServer `
    -Mode LoadBalance `
    -LoadBalancePercent 50 `
    -ScopeId 10.10.10.0,10.20.10.0,10.30.10.0 `
    -Force

# Bekræft failover
Get-DhcpServerv4Failover
```

### Kørsel af scripts
DC01: Kør DC01-BeforeRestart.ps1, genstart, og kør evt. DC01-AfterRestart.ps1.
DC02: Kør DC02-BeforeRestart.ps1, genstart, og kør DC02-AfterRestart.ps1.
Verificér replication, DNS og DHCP med kommandoer som:
```
repadmin /replsummary
Get-DhcpServerv4Failover
```
