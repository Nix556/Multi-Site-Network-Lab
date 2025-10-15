! ==========================
! Router RT01 - Odense
! ==========================

conf t

! --- Hostname og domæne ---
hostname RT01
ip domain-name odense.local

! --- Brugere til SSH ---
username admin privilege 15 secret cisco
crypto key generate rsa modulus 2048
ip ssh version 2


! --- LAN SUBINTERFACES ---
interface GigabitEthernet0/0.100
 description LAN
 ip address 10.47.100.1 255.255.255.0
 ip nat inside
 no shutdown
 exit

interface GigabitEthernet0/0.10
 description VLAN 10 - Klient Odense
 encapsulation dot1Q 10
 ip address 10.10.10.1 255.255.255.0
 ip nat inside
 ip ospf 1 area 0
 exit

interface GigabitEthernet0/0.20
 description VLAN 20 - Server Odense
 encapsulation dot1Q 20
 ip address 10.10.20.1 255.255.255.0
 ip nat inside
 ip ospf 1 area 0
 exit

interface GigabitEthernet0/0.30
 description VLAN 30 - Printer Odense
 encapsulation dot1Q 30
 ip address 10.10.30.1 255.255.255.0
 ip nat inside
 ip ospf 1 area 0
 exit

interface GigabitEthernet0/0.99
 description VLAN 99 - Management Odense
 encapsulation dot1Q 99
 ip address 10.10.99.1 255.255.255.0
 ip nat inside
 ip ospf 1 area 0
 exit

! --- WAN LINKS ---
interface Serial0/0/0
 description Odense - Nyborg
 ip address 172.16.1.1 255.255.255.252
 ip ospf 1 area 0
 exit

interface Serial0/0/1
 description Odense - Svendborg
 ip address 172.16.2.1 255.255.255.252
 ip ospf 1 area 0
 exit


! --- WAN / Internet uplink ---
interface GigabitEthernet0/1
 description WAN uplink / ISP
 ip address 10.47.0.2 255.255.255.240
 ip nat outside
 no shutdown
 exit

! Opret ACL for alle interne subnets (Odense + Nyborg + Svendborg)
access-list 10 permit 10.10.10.0 0.0.0.255
access-list 10 permit 10.10.20.0 0.0.0.255
access-list 10 permit 10.10.30.0 0.0.0.255
access-list 10 permit 10.10.99.0 0.0.0.255
access-list 10 permit 10.20.10.0 0.0.0.255
access-list 10 permit 10.20.99.0 0.0.0.255
access-list 10 permit 10.30.10.0 0.0.0.255
access-list 10 permit 10.30.99.0 0.0.0.255
access-list 10 permit 10.47.100.0 0.0.0.255

! --- NAT overload (PAT) for Internet adgang ---
ip nat inside source list 10 interface GigabitEthernet0/1 overload

! --- Default route (til ISP / upstream hvis relevant) ---
ip route 0.0.0.0 0.0.0.0 dhcp

! --- OSPF ---
router ospf 1
 router-id 1.1.1.1
 network 10.47.100.0 0.0.0.255 area 0
 network 10.10.10.0 0.0.0.255 area 0
 network 10.10.20.0 0.0.0.255 area 0
 network 10.10.30.0 0.0.0.255 area 0
 network 10.10.99.0 0.0.0.255 area 0
 network 172.16.1.0 0.0.0.3 area 0
 network 172.16.2.0 0.0.0.3 area 0
 passive-interface GigabitEthernet0/0.10
 passive-interface GigabitEthernet0/0.20
 passive-interface GigabitEthernet0/0.30
 passive-interface GigabitEthernet0/0.99
 exit

! --- VTY / SSH adgang ---
line vty 0 4
 transport input ssh
 login local
 exec-timeout 10
 logging synchronous
 exit

service password-encryption
end
write memory
