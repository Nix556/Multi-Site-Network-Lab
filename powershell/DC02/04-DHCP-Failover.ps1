<#
.SYNOPSIS
    Configures DHCP failover between DC01 and DC02.
#>

Write-Host "=== Step 4: Configuring DHCP Failover ===" -ForegroundColor Cyan

$PartnerServer = "DC01.torbenbyg.local"
$ScopeID = "10.10.10.0"       # Client VLAN
$FailoverName = "DC01-DC02-FO"
$SharedSecret = "SuperSecretPassword123!"
$LocalIP = "10.10.20.11"

# Authorize DHCP server in Active Directory
Add-DhcpServerInDC -DnsName "DC02.torbenbyg.local" -IpAddress $LocalIP

# Configure failover (50/50 load balance)
Add-DhcpServerv4Failover `
    -Name $FailoverName `
    -PartnerServer $PartnerServer `
    -ScopeId $ScopeID `
    -SharedSecret $SharedSecret `
    -Mode LoadBalance `
    -LoadBalancePercent 50 `
    -AutoStateTransition $true `
    -MaxClientLeadTime 1:00:00

Write-Host "DHCP failover configured successfully between DC01 and DC02!" -ForegroundColor Green
