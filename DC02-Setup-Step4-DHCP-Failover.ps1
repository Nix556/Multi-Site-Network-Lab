<#
.SYNOPSIS
    Opsætter DHCP failover 50/50 mellem DC01 og DC02.
#>

Write-Host "=== Trin 4: Opsætter DHCP-failover ===" -ForegroundColor Cyan

$PartnerServer = "DC01.torbenbyg.local"
$ScopeID = "10.10.10.0"       # Dit klient-VLAN
$FailoverName = "DC01-DC02-FO"
$SharedSecret = "SuperHemmeligtPassword123!"

# Autoriser DHCP-server i AD
Add-DhcpServerInDC -DnsName "DC02.torbenbyg.local" -IpAddress 10.10.20.11

# Opsæt failover (50/50 load balance)
Add-DhcpServerv4Failover `
    -Name $FailoverName `
    -PartnerServer $PartnerServer `
    -ScopeId $ScopeID `
    -SharedSecret $SharedSecret `
    -Mode LoadBalance `
    -LoadBalancePercent 50 `
    -AutoStateTransition $true `
    -MaxClientLeadTime 1:00:00

Write-Host "DHCP-failover sat op mellem DC01 og DC02!" -ForegroundColor Green
