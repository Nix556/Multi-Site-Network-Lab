<#
.SYNOPSIS
    Installs required roles and promotes DC02 as an additional Domain Controller.
#>

Write-Host "=== Step 3: Installing roles and promoting DC02 ===" -ForegroundColor Cyan

$DomainName = "torbenbyg.local"
$ReplicationSource = "DC01.torbenbyg.local"
$DSRMPassword = Read-Host "Enter DSRM password" -AsSecureString

# Install required roles
Install-WindowsFeature -Name AD-Domain-Services, DNS, DHCP -IncludeManagementTools

# Promote DC02 as Additional Domain Controller
Install-ADDSDomainController `
    -DomainName $DomainName `
    -ReplicationSourceDC $ReplicationSource `
    -InstallDNS:$true `
    -Credential (Get-Credential) `
    -SafeModeAdministratorPassword $DSRMPassword `
    -Force:$true

Write-Host "Promotion complete. The server will restart automatically after AD DS installation..." -ForegroundColor Yellow
