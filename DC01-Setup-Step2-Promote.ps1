<#
.SYNOPSIS
    Promoverer DC01 til primær Domain Controller (ny forest).
#>

Write-Host "=== DC01: Domain Controller-promotion ===" -ForegroundColor Cyan

$DomainName = "torbenbyg.local"

# Bed om DSRM-kode på en sikker måde
$DSRMPassword = Read-Host "Indtast DSRM-adgangskode" -AsSecureString

Install-ADDSForest `
    -DomainName $DomainName `
    -SafeModeAdministratorPassword $DSRMPassword `
    -InstallDNS `
    -Force:$true

Write-Host "Promotion fuldført. Serveren genstarter automatisk..." -ForegroundColor Yellow
