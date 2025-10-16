! ==========================
! Router RT01 - Odense
! ==========================

conf t

! --- Hostname og domæne ---
hostname RT01
ip domain-name odense.local

! --- Brugere til SSH ---
username admin privilege 15 secret cisco

! --- Generer RSA-nøgler til SSH ---
crypto key generate rsa modulus 2048
ip ssh version 2

! ==========================
! WAN Interface
! ==========================
interface GigabitEthernet0/0
 description WAN uplink / ISP
 ip address 10.47.0.2 255.255.255.240
 ip nat outside
 no shutdown
 exit

! ==========================
! LAN Interface
! ==========================
interface GigabitEthernet0/1
 description LAN Odense
 ip address 10.47.69.1 255.255.255.0
 ip nat inside
 no shutdown
 exit

! --- VLAN Subinterfaces ---
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
 deny ip 10.47.0.0 0.0.0.255 any
 permit ip 10.47.0.0 0.0.0.255 10.47.0.2 255.255.255.240
 permit ip 10.0.0.0 0.255.255.255 any
 exit

! ==========================
! NAT Overload
! ==========================
ip nat inside source list NAT-LIST interface GigabitEthernet0/0 overload

! ==========================
! Default route
! ==========================
ip route 0.0.0.0 0.0.0.0 10.47.0.1

! ==========================
! OSPF Routing
! ==========================
router ospf 1
 router-id 1.1.1.1
 network 10.47.0.0 0.0.255.255 area 0
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
! SSH Adgang
! ==========================
line vty 0 4
 transport input ssh
 login local
 exec-timeout 10
 logging synchronous
 exit

! ==========================
! Port Forwarding / NAT
! ==========================
! Proxmox Web
ip nat inside source static tcp 10.10.20.5 8006 interface GigabitEthernet0/0 8006
! Proxmox SSH
ip nat inside source static tcp 10.10.20.5 22 interface GigabitEthernet0/0 2222
! Router 1 (SSH)
ip nat inside source static tcp 10.10.99.1 22 interface GigabitEthernet0/0 2221
! Router 2 (SSH)
ip nat inside source static tcp 10.20.99.1 22 interface GigabitEthernet0/0 2223
! Router 3 (SSH)
ip nat inside source static tcp 10.30.99.1 22 interface GigabitEthernet0/0 2224
! Switch 1 (SSH)
ip nat inside source static tcp 10.10.99.2 22 interface GigabitEthernet0/0 2225
! Switch 2 (SSH)
ip nat inside source static tcp 10.20.99.2 22 interface GigabitEthernet0/0 2226
! Switch 3 (SSH)
ip nat inside source static tcp 10.30.99.2 22 interface GigabitEthernet0/0 2227

! ==========================
! Service Password Encryption
! ==========================
service password-encryption

end
write memory
