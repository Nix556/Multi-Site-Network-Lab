<#
.SYNOPSIS
    Opsætning af DC01 før promotion til Domain Controller
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
# 2. OPRETTE EKSTRA PARTITION F:
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

# ------------------------------
# 4. PROMOVER DC
# ------------------------------
$DomainName = "torbenbyg.local"
$DSRMPassword = ConvertTo-SecureString "torbenDSRM!2025" -AsPlainText -Force

Install-ADDSForest `
    -DomainName $DomainName `
    -SafeModeAdministratorPassword $DSRMPassword `
    -InstallDNS `
    -Force:$true

# ------------------------------
# GENSTART PÅKRÆVET EFTER DC PROMOTION
# ------------------------------
Write-Host "Genstart serveren nu for at fuldføre promotion til Domain Controller!" -ForegroundColor Yellow
