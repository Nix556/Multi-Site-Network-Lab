<#
.SYNOPSIS
    Opsætning af netværk, disk og roller før promotion
#>

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
# 2. OPRET PARTITION F:
# ------------------------------
$diskNumber = 1
$driveLetter = "F"

Initialize-Disk -Number $diskNumber -PartitionStyle GPT
$part = New-Partition -DiskNumber $diskNumber -UseMaximumSize -AssignDriveLetter
Format-Volume -Partition $part -FileSystem NTFS -NewFileSystemLabel "UserData" -Confirm:$false
Set-Partition -PartitionNumber $part.PartitionNumber -DiskNumber $diskNumber -NewDriveLetter $driveLetter

# ------------------------------
# 3. INSTALLER SERVERROLLER
# ------------------------------
Install-WindowsFeature -Name AD-Domain-Services, DNS, FS-FileServer, DHCP -IncludeManagementTools

Write-Host "Færdig – genstart nu før promotion." -ForegroundColor Yellow
Restart-Computer
