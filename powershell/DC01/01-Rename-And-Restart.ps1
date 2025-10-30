<#
.SYNOPSIS
    Renames the server to DC01 and restarts.
#>

$NewName = "DC01"

Write-Host "Changing server name to $NewName ..." -ForegroundColor Cyan
Rename-Computer -NewName $NewName -Force

Write-Host "Restarting to apply new server name..." -ForegroundColor Yellow
Restart-Computer
