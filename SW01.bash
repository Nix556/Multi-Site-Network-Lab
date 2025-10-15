! ==========================
! Switch SW01 - Odense
! ==========================

conf t

hostname SW01
ip domain-name odense.local

! --- VLANs ---
vlan 10
 name Klient
vlan 20
 name Server
vlan 30
 name Printer
vlan 99
 name Management
 exit

! --- Trunk-port til router RT01 ---
interface GigabitEthernet1/0/1
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30,99
 exit

! --- Access-porte for klienter VLAN 10 ---
interface range GigabitEthernet1/0/2 - 10
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
 exit

! --- Access-porte for servere VLAN 20 ---
interface range GigabitEthernet1/0/11 - 12
 switchport mode access
 switchport access vlan 20
 spanning-tree portfast
 exit

! --- Access-porte for printere VLAN 30 ---
interface range GigabitEthernet1/0/13 - 14
 switchport mode access
 switchport access vlan 30
 spanning-tree portfast
 exit

 ! --- Access-porte for management VLAN 99 ---
interface range GigabitEthernet1/0/15 - 16
 switchport mode access
 switchport access vlan 99
 spanning-tree portfast
 exit

! --- Management interface VLAN 99 ---
interface vlan 99
 ip address 10.10.99.2 255.255.255.0
 no shutdown

ip default-gateway 10.10.99.1

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
