<#
.SYNOPSIS
    Opsætning af DC02 efter promotion
.DESCRIPTION
    Bekræfter replication og opsætter DHCP failover
#>

# ------------------------------
# 1. BEKRÆFT AD OG DNS REPLICATION
# ------------------------------
repadmin /replsummary
Get-ADDomainController -Filter *

# ------------------------------
# 2. OPSÆT DHCP FAILOVER
# ------------------------------
# Vi antager, at DHCP er installeret på DC02
# Failover med DC01 i LoadBalance mode 50/50
$PartnerServer = "DC01"
$LocalDHCPServer = $env:COMPUTERNAME

Add-DhcpServerv4Failover -Name "DHCP-Failover" `
    -PartnerServer $PartnerServer `
    -Mode LoadBalance `
    -LoadBalancePercent 50 `
    -ScopeId 10.10.10.0,10.20.10.0,10.30.10.0 `
    -Force

# ------------------------------
# 3. BEKRÆFT DHCP FAILOVER
# ------------------------------
Get-DhcpServerv4Failover
