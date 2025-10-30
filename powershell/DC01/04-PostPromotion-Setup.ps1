<#
.SYNOPSIS
    Post-promotion setup of DC01 after it becomes the Domain Controller.
#>

Write-Host "=== DC01: Post-promotion configuration ===" -ForegroundColor Cyan

# ------------------------------
# 1. DHCP CONFIGURATION
# ------------------------------
$ipAddress = "10.10.20.10"
Add-DhcpServerInDC -DnsName "DC01.torbenbyg.local" -IpAddress $ipAddress

# Odense
Add-DhcpServerv4Scope -Name "Odense" -StartRange 10.10.10.100 -EndRange 10.10.10.200 -SubnetMask 255.255.255.0
Set-DhcpServerv4OptionValue -ScopeId 10.10.10.0 -Router 10.10.10.1 -DnsServer $ipAddress

# Nyborg
Add-DhcpServerv4Scope -Name "Nyborg" -StartRange 10.20.10.100 -EndRange 10.20.10.200 -SubnetMask 255.255.255.0
Set-DhcpServerv4OptionValue -ScopeId 10.20.10.0 -Router 10.20.10.1 -DnsServer $ipAddress

# Svendborg
Add-DhcpServerv4Scope -Name "Svendborg" -StartRange 10.30.10.100 -EndRange 10.30.10.200 -SubnetMask 255.255.255.0
Set-DhcpServerv4OptionValue -ScopeId 10.30.10.0 -Router 10.30.10.1 -DnsServer $ipAddress

Start-Service DHCPServer
Get-DhcpServerv4Scope

# ------------------------------
# 2. CREATE FOLDER STRUCTURE
# ------------------------------
$OUlist = "ingeniør","tømmer","murer","elektriker","lærling","sekretær","leder"
$driveLetter = "F"
foreach ($ou in $OUlist) { New-Item -Path "$driveLetter:\$ou" -ItemType Directory -Force }

# ------------------------------
# 3. CREATE ORGANIZATIONAL UNITS
# ------------------------------
foreach ($ou in $OUlist) { New-ADOrganizationalUnit -Name $ou -Path "DC=torbenbyg,DC=local" }

# ------------------------------
# 4. CREATE USERS
# ------------------------------
$usersPerOU = 6
foreach ($ou in $OUlist) {
    for ($i=1; $i -le $usersPerOU; $i++) {
        $username = "$ou$i"
        $password = ConvertTo-SecureString "Bruger123!" -AsPlainText -Force
        New-ADUser -Name $username -SamAccountName $username -AccountPassword $password `
            -Path "OU=$ou,DC=torbenbyg,DC=local" -Enabled $true
    }
}

# ------------------------------
# 5. CREATE GROUPS AND ADD USERS
# ------------------------------
foreach ($ou in $OUlist) {
    $globalGroup = "GG_$ou"
    $localGroup = "LG_$ou"

    New-ADGroup -Name $globalGroup -GroupScope Global -Path "OU=$ou,DC=torbenbyg,DC=local"
    New-ADGroup -Name $localGroup -GroupScope DomainLocal -Path "OU=$ou,DC=torbenbyg,DC=local"

    $users = Get-ADUser -Filter * -SearchBase "OU=$ou,DC=torbenbyg,DC=local"
    foreach ($user in $users) { Add-ADGroupMember -Identity $globalGroup -Members $user.SamAccountName }
    Add-ADGroupMember -Identity $localGroup -Members $globalGroup
}

# ------------------------------
# 6. FOLDER PERMISSIONS
# ------------------------------
foreach ($ou in $OUlist) {
    $folderPath = "$driveLetter:\$ou"
    $localGroup = "LG_$ou"
    $acl = Get-Acl $folderPath
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("$localGroup","FullControl","ContainerInherit,ObjectInherit","None","Allow")
    $acl.SetAccessRule($rule)
    Set-Acl $folderPath $acl
}

# ------------------------------
# 7. SMB SHARES
# ------------------------------
foreach ($ou in $OUlist) {
    $folderPath = "$driveLetter:\$ou"
    $shareName = $ou
    $localGroup = "torbenbyg\LG_$ou"

    if (Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue) { Remove-SmbShare -Name $shareName -Force }
    New-SmbShare -Name $shareName -Path $folderPath -FullAccess $localGroup
    icacls $folderPath /inheritance:r
    icacls $folderPath /grant "${localGroup}:(OI)(CI)F"
}

# ------------------------------
# 8. PASSWORD POLICY
# ------------------------------
Set-ADDefaultDomainPasswordPolicy -Identity "torbenbyg.local" -MinPasswordLength 10
Set-ADDefaultDomainPasswordPolicy -Identity "torbenbyg.local" -ComplexityEnabled $true
Set-ADDefaultDomainPasswordPolicy -Identity "torbenbyg.local" -MaxPasswordAge (New-TimeSpan -Days 27)

# ------------------------------
# 9. GPO: Hide Last Logged-In User
# ------------------------------
Import-Module GroupPolicy
$gpo = New-GPO -Name "HideLastUserName" -Comment "Hide last user on login screen"
Set-GPRegistryValue -Name $gpo.DisplayName `
    -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -ValueName "DontDisplayLastUserName" -Type DWord -Value 1
New-GPLink -Name $gpo.DisplayName -Target "DC=torbenbyg,DC=local"

# ------------------------------
# 10. CREATE ADMIN & OPERATOR ACCOUNTS
# ------------------------------
$operatorPassword = ConvertTo-SecureString "Server1234!" -AsPlainText -Force
$adminPassword    = ConvertTo-SecureString "Admin12345!" -AsPlainText -Force

New-ADUser -Name "ServerOP" -SamAccountName "ServerOP" -AccountPassword $operatorPassword -Enabled $true -Path "CN=Users,DC=torbenbyg,DC=local"
New-ADUser -Name "Admin-J" -SamAccountName "Admin-J" -AccountPassword $adminPassword -Enabled $true -Path "CN=Users,DC=torbenbyg,DC=local"

Add-ADGroupMember -Identity "Domain Admins" -Members "Admin-J"
Add-ADGroupMember -Identity "Server Operators" -Members "ServerOP"

# ------------------------------
# 11. DELEGATE OU SUPERUSERS
# ------------------------------
Import-Module ActiveDirectory
foreach ($ou in $OUlist) {
    $ouDN = "OU=$ou,DC=torbenbyg,DC=local"
    $superUser = Get-ADUser -Filter * -SearchBase $ouDN | Select-Object -First 1
    if ($superUser) {
        $userSam = "torbenbyg\" + $superUser.SamAccountName
        dsacls $ouDN /G "$userSam:RPWP" | Out-Null
        dsacls $ouDN /G "$userSam:CCDC" | Out-Null
        Write-Host "Delegated rights to $($superUser.SamAccountName) in $ou." -ForegroundColor Green
    }
}

Write-Host "DC01 setup complete!" -ForegroundColor Green
