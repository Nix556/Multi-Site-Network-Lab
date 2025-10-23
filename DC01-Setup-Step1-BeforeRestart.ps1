<#
.SYNOPSIS
    Forbereder DC01 før Domain Controller-promotion.
#>

Write-Host "=== DC01: Netværk og forberedelse ===" -ForegroundColor Cyan

# ------------------------------
# 1. NETVÆRKSOPSÆTNING
# ------------------------------
$interface = "Ethernet"
$ipAddress = "10.10.20.10"
$prefixLength = 24
$gateway = "10.10.20.1"
$dnsServers = @("10.10.20.10","1.1.1.1")

New-NetIPAddress -InterfaceAlias $interface -IPAddress $ipAddress -PrefixLength $prefixLength -DefaultGateway $gateway
Set-DnsClientServerAddress -InterfaceAlias $interface -ServerAddresses $dnsServers
Disable-NetAdapterBinding -Name $interface -ComponentID ms_tcpip6

# ------------------------------
# 2. OPRET EKSTRA PARTITION F:
# ------------------------------
$diskNumber = 1
$driveLetter = "F"

try {
    Initialize-Disk -Number $diskNumber -PartitionStyle GPT -ErrorAction Stop
    $part = New-Partition -DiskNumber $diskNumber -UseMaximumSize -AssignDriveLetter
    Format-Volume -Partition $part -FileSystem NTFS -NewFileSystemLabel "UserData" -Confirm:$false
    Set-Partition -PartitionNumber $part.PartitionNumber -DiskNumber $diskNumber -NewDriveLetter $driveLetter
    Write-Host "Partition F: oprettet." -ForegroundColor Green
}
catch {
    Write-Host "Partition findes muligvis allerede. Springer over..." -ForegroundColor Yellow
}

# ------------------------------
# 3. INSTALLER SERVERROLLER
# ------------------------------
Install-WindowsFeature -Name AD-Domain-Services, DNS, FS-FileServer, DHCP -IncludeManagementTools

Write-Host "Forberedelse færdig – genstart nu, og kør derefter Step2 (Promote)." -ForegroundColor Yellow
Restart-Computer -Force
