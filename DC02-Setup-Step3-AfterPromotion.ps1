<#
.SYNOPSIS
    Promoverer DC02 som Additional Domain Controller og konfigurerer DHCP-failover.
#>

Write-Host "=== Trin 3: Installerer roller og promoverer DC02 ===" -ForegroundColor Cyan

$DomainName = "torbenbyg.local"
$ReplicationSource = "DC01.torbenbyg.local"
$DSRMPassword = Read-Host "Indtast DSRM-adgangskode" -AsSecureString

# Installer nødvendige roller
Install-WindowsFeature -Name AD-Domain-Services, DNS, DHCP -IncludeManagementTools

# Promover DC02
Install-ADDSDomainController `
    -DomainName $DomainName `
    -ReplicationSourceDC $ReplicationSource `
    -InstallDNS:$true `
    -Credential (Get-Credential) `
    -SafeModeAdministratorPassword $DSRMPassword `
    -Force:$true

Write-Host "Promotion udført. Serveren genstarter automatisk efter AD DS installation..." -ForegroundColor Yellow
