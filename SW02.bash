! ==========================
! Switch SW02 - Nyborg
! ==========================

conf t

hostname SW02
ip domain-name nyborg.local

! --- VLANs ---
vlan 10
 name Klient
 exit
vlan 99
 name Management
 exit

! --- Trunk-port til router RT02 ---
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
 ip address 10.20.99.2 255.255.255.0
 no shutdown
 exit

ip default-gateway 10.20.99.1

! --- SSH brugere ---
username admin privilege 15 secret cisco
crypto key generate rsa modulus 2048
ip ssh version 2

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
