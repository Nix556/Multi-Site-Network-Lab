! ==========================
! Router RT03 - Svendborg
! ==========================

conf t

! --- Hostname og domæne ---
hostname RT03
ip domain-name svendborg.local

! --- Brugere til SSH ---
username admin privilege 15 secret cisco
crypto key generate rsa modulus 2048
ip ssh version 2

! ==========================
! LAN Interface
! ==========================
interface GigabitEthernet0/0
 description LAN Svendborg
 no ip address
 no shutdown
 exit

! --- VLAN Subinterfaces ---
interface GigabitEthernet0/0.10
 description VLAN 10 - Klient Svendborg
 encapsulation dot1Q 10
 ip address 10.30.10.1 255.255.255.0
 ip helper-address 10.10.20.10
 ip ospf 1 area 0
 exit

interface GigabitEthernet0/0.99
 description VLAN 99 - Management Svendborg
 encapsulation dot1Q 99
 ip address 10.30.99.1 255.255.255.0
 ip ospf 1 area 0
 exit

! ==========================
! WAN Link Odense - Svendborg
! ==========================
interface Serial0/0/0
 description Svendborg - Odense
 ip address 172.16.2.2 255.255.255.252
 no shutdown
 ip ospf 1 area 0
 exit

! ==========================
! Default route
! ==========================
ip route 0.0.0.0 0.0.0.0 172.16.2.1

! ==========================
! OSPF Routing
! ==========================
router ospf 1
 router-id 3.3.3.3
 network 10.30.10.0 0.0.0.255 area 0
 network 10.30.99.0 0.0.0.255 area 0
 network 172.16.2.0 0.0.0.3 area 0
 passive-interface GigabitEthernet0/0.10
 passive-interface GigabitEthernet0/0.99
 exit

! ==========================
! VTY / SSH Adgang
! ==========================
line vty 0 4
 transport input ssh
 login local
 exec-timeout 10
 logging synchronous
 exit

! ==========================
! Service Password Encryption
! ==========================
service password-encryption

end
write memory
