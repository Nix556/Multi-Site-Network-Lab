! ==========================
! Switch SW03 - Svendborg
! ==========================

conf t

hostname SW03
ip domain-name svendborg.local

! --- Brugere til SSH ---
username admin privilege 15 secret cisco

! --- Generer nye RSA-nøgler ---
crypto key generate rsa modulus 2048
ip ssh version 2

! --- VLANs ---
vlan 10
 name Klient
vlan 99
 name Management
 exit

! --- Trunk-port til router RT03 ---
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan 10,99
 exit

! --- Access-porte for klienter VLAN 10 ---
interface range GigabitEthernet0/2 - 10
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
 exit

! --- Management interface VLAN 99 ---
interface vlan 99
 ip address 10.30.99.2 255.255.255.0
 no shutdown

ip default-gateway 10.30.99.1

! --- VTY linjer ---
line vty 0 4
 transport input ssh
 login local
 exec-timeout 10
 logging synchronous
 exit

service password-encryption
no ip http server
no ip http secure-server
end
write memory