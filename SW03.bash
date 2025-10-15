! ==========================
! Switch SW03 - Svendborg
! ==========================

conf t

hostname SW03
ip domain-name svendborg.local

! --- VLANs ---
vlan 10
 name Klient
vlan 99
 name Management

! --- Management interface VLAN 99 ---
interface vlan 99
 ip address 10.30.99.2 255.255.255.0
 no shutdown

ip default-gateway 10.30.99.1

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