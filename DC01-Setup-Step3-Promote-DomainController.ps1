<#
.SYNOPSIS
    Promover DC01 til Primary Domain Controller
#>

$DomainName = "torbenbyg.local"
$DSRMPassword = Read-Host "Indtast DSRM-adgangskode" -AsSecureString

Install-ADDSForest `
    -DomainName $DomainName `
    -SafeModeAdministratorPassword $DSRMPassword `
    -InstallDNS `
    -Force:$true

Write-Host "Promotion fuldført – genstart nu!" -ForegroundColor Yellow
Restart-Computer
