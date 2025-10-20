! ==========================
! Switch SW02 - Nyborg
! ==========================

conf t

! --- Hostname og domæne ---
hostname SW02
ip domain-name nyborg.local

! --- Brugere til SSH ---
username admin privilege 15 secret cisco

! --- Generer RSA-nøgler ---
crypto key generate rsa modulus 2048
ip ssh version 2

! ==========================
! VLANs
! ==========================
vlan 10
 name Klient
 exit
vlan 99
 name Management
 exit

! ==========================
! Trunk-port til router RT02
! ==========================
interface GigabitEthernet1/0/1
 switchport mode trunk
 switchport trunk allowed vlan 10,99
 exit

! ==========================
! Access-porte for VLAN 10 - Klienter
! ==========================
interface range GigabitEthernet1/0/2 - 10
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
 exit

! ==========================
! Management interface VLAN 99
! ==========================
interface vlan 99
 ip address 10.20.99.2 255.255.255.0
 no shutdown
 exit

ip default-gateway 10.20.99.1

! ==========================
! VTY / SSH adgang
! ==========================
line vty 0 4
 transport input ssh
 login local
 exec-timeout 10
 logging synchronous
 exit

! ==========================
! Generelle services
! ==========================
service password-encryption
no ip http server
no ip http secure-server

end
write memory
