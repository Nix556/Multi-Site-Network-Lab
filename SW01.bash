! ==========================
! Switch SW01 - Odense
! ==========================

conf t

! --- Hostname and domain ---
hostname SW01
ip domain-name odense.local

! --- SSH Users ---
username admin privilege 15 secret cisco

! --- Generate RSA keys ---
crypto key generate rsa modulus 2048
ip ssh version 2

! ==========================
! VLANs
! ==========================
vlan 10
 name Client
 exit
vlan 20
 name Server
 exit
vlan 30
 name Printer
 exit
vlan 99
 name Management
 exit

! ==========================
! Trunk port to router RT01
! ==========================
interface GigabitEthernet1/0/1
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30,99
 exit

! ==========================
! Access ports for VLAN 10 - Clients
! ==========================
interface range GigabitEthernet1/0/2 - 10
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
 exit

! ==========================
! Access ports for VLAN 20 - Servers
! ==========================
interface range GigabitEthernet1/0/11 - 12
 switchport mode access
 switchport access vlan 20
 spanning-tree portfast
 exit

! ==========================
! Access ports for VLAN 30 - Printers
! ==========================
interface range GigabitEthernet1/0/13 - 14
 switchport mode access
 switchport access vlan 30
 spanning-tree portfast
 exit

! ==========================
! Management interface VLAN 99
! ==========================
interface vlan 99
 ip address 10.10.99.2 255.255.255.0
 no shutdown
 exit

ip default-gateway 10.10.99.1

! ==========================
! VTY / SSH Access
! ==========================
line vty 0 4
 transport input ssh
 login local
 exec-timeout 10
 logging synchronous
 exit

! ==========================
! General services
! ==========================
service password-encryption
no ip http server
no ip http secure-server

end
write memory
