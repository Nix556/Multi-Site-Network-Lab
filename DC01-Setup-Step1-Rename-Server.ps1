<#
.SYNOPSIS
    Omdøber serveren til DC01 og genstarter
#>

$NewName = "DC01"

Write-Host "Ændrer servernavn til $NewName ..." -ForegroundColor Cyan
Rename-Computer -NewName $NewName -Force

Write-Host "Genstarter nu for at anvende nyt servernavn." -ForegroundColor Yellow
Restart-Computer
