<#
.SYNOPSIS
    Opsætning af DC02 før promotion til sekundær DC
.DESCRIPTION
    DC02 skal fungere som failover for AD, DNS og DHCP
#>

# ------------------------------
# 1. NETVÆRKSOPSÆTNING
# ------------------------------
$interface = "Ethernet"
$ipAddress = "10.10.20.11"    # DC02 IP
$prefixLength = 24
$gateway = "10.10.20.1"
$dnsServers = @("10.10.20.10","1.1.1.1") # peger på DC01 primært

New-NetIPAddress -InterfaceAlias $interface -IPAddress $ipAddress -PrefixLength $prefixLength -DefaultGateway $gateway
Set-DnsClientServerAddress -InterfaceAlias $interface -ServerAddresses $dnsServers
Disable-NetAdapterBinding -Name $interface -ComponentID ms_tcpip6

# ------------------------------
# 2. INSTALLER SERVERROLLER
# ------------------------------
Install-WindowsFeature -Name AD-Domain-Services, DNS, DHCP -IncludeManagementTools

# ------------------------------
# 3. PROMOVER DC SOM ADDITIONAL DC
# ------------------------------
$DomainName = "torbenbyg.local"
$DC01 = "DC01.torbenbyg.local"  # primær DC

Install-ADDSDomainController `
    -DomainName $DomainName `
    -Credential (Get-Credential) `
    -InstallDNS `
    -ReplicationSourceDC $DC01 `
    -Force:$true

Write-Host "Genstart serveren nu for at fuldføre promotion som sekundær DC!" -ForegroundColor Yellow
