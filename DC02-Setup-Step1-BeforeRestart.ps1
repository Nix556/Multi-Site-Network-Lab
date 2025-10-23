<#
.SYNOPSIS
    Omdøber DC02 og konfigurerer netværk.
#>

Write-Host "=== Trin 1: Navngiver server og opsætter netværk ===" -ForegroundColor Cyan

# Indstillinger
$NewName     = "DC02"
$Interface   = "Ethernet"
$IPAddress   = "10.10.20.11"
$Prefix      = 24
$Gateway     = "10.10.20.1"
$DnsServers  = @("10.10.20.10")

# Sæt IP-konfiguration (uden at fjerne eksisterende IP først)
New-NetIPAddress -InterfaceAlias $Interface -IPAddress $IPAddress -PrefixLength $Prefix -DefaultGateway $Gateway -ErrorAction SilentlyContinue
Set-DnsClientServerAddress -InterfaceAlias $Interface -ServerAddresses $DnsServers

# Deaktiver IPv6 (valgfrit)
Disable-NetAdapterBinding -Name $Interface -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue

# Omdøb maskinen
Rename-Computer -NewName $NewName -Force

Write-Host "Servernavn ændret til $NewName. Genstarter nu..." -ForegroundColor Yellow
Restart-Computer -Force
