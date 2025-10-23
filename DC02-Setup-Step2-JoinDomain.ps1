<#
.SYNOPSIS
    Tilslutter DC02 til domænet torbenbyg.local
#>

Write-Host "=== Trin 2: Tilslutter serveren til domænet ===" -ForegroundColor Cyan

$DomainName = "torbenbyg.local"

Add-Computer -DomainName $DomainName -Credential (Get-Credential) -Force -Restart
