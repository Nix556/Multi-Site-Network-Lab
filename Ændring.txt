! ==========================
! Router RT01 - Odense
! ==========================
conf t

! --- Hostname og domæne ---
hostname RT01
ip domain-name odense.local

! --- SSH login ---
username admin privilege 15 secret cisco
crypto key generate rsa modulus 2048
ip ssh version 2

! ==========================
! WAN Interface
! ==========================
interface GigabitEthernet0/0
 description WAN uplink / ISP
 ip address dhcp
 ip nat outside
 no shutdown
 exit

! ==========================
! VLAN Subinterfaces (LAN)
! ==========================
interface GigabitEthernet0/1.10
 description VLAN 10 - Klient Odense
 encapsulation dot1Q 10
 ip address 10.10.10.1 255.255.255.0
 ip nat inside
 exit

interface GigabitEthernet0/1.20
 description VLAN 20 - Server Odense
 encapsulation dot1Q 20
 ip address 10.10.20.1 255.255.255.0
 ip nat inside
 exit

interface GigabitEthernet0/1.30
 description VLAN 30 - Printer Odense
 encapsulation dot1Q 30
 ip address 10.10.30.1 255.255.255.0
 ip nat inside
 exit

interface GigabitEthernet0/1.99
 description VLAN 99 - Management Odense
 encapsulation dot1Q 99
 ip address 10.10.99.1 255.255.255.0
 ip nat inside
 exit

! ==========================
! WAN-links mellem sites
! ==========================
interface Serial0/0/0
 description Odense - Nyborg
 ip address 172.16.1.1 255.255.255.252
 no shutdown
 ip ospf 1 area 0
 exit

interface Serial0/0/1
 description Odense - Svendborg
 ip address 172.16.2.1 255.255.255.252
 no shutdown
 ip ospf 1 area 0
 exit

! ==========================
! NAT ACL
! ==========================
ip access-list extended NAT-LIST
 remark Tillad interne netværk til internettet
 permit ip 10.0.0.0 0.255.255.255 any
 exit

! ==========================
! NAT Overload
! ==========================
ip nat inside source list NAT-LIST interface GigabitEthernet0/0 overload

! ==========================
! Standard route
! ==========================
ip route 0.0.0.0 0.0.0.0 dhcp

! ==========================
! OSPF Routing
! ==========================
router ospf 1
 router-id 1.1.1.1
 network 10.10.10.0 0.0.0.255 area 0
 network 10.10.20.0 0.0.0.255 area 0
 network 10.10.30.0 0.0.0.255 area 0
 network 10.10.99.0 0.0.0.255 area 0
 network 172.16.1.0 0.0.0.3 area 0
 network 172.16.2.0 0.0.0.3 area 0
 passive-interface GigabitEthernet0/1.10
 passive-interface GigabitEthernet0/1.20
 passive-interface GigabitEthernet0/1.30
 passive-interface GigabitEthernet0/1.99
 exit

! ==========================
! SSH-adgang
! ==========================
line vty 0 4
 login local
 transport input ssh
 exec-timeout 10
 logging synchronous
 exit

! ==========================
! Kryptering
! ==========================
service password-encryption

end
write memory
