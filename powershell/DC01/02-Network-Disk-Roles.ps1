<#
.SYNOPSIS
    Configures network, prepares disk, and installs roles before domain promotion.
#>

# ------------------------------
# 1. NETWORK CONFIGURATION
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
# 2. CREATE DATA PARTITION F:
# ------------------------------
$diskNumber = 1
$driveLetter = "F"

Initialize-Disk -Number $diskNumber -PartitionStyle GPT
$part = New-Partition -DiskNumber $diskNumber -UseMaximumSize -AssignDriveLetter
Format-Volume -Partition $part -FileSystem NTFS -NewFileSystemLabel "UserData" -Confirm:$false
Set-Partition -PartitionNumber $part.PartitionNumber -DiskNumber $diskNumber -NewDriveLetter $driveLetter

# ------------------------------
# 3. INSTALL SERVER ROLES
# ------------------------------
Install-WindowsFeature -Name AD-Domain-Services, DNS, FS-FileServer, DHCP -IncludeManagementTools

Write-Host "Setup complete — restart before domain promotion." -ForegroundColor Yellow
Restart-Computer
