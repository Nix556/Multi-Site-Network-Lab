! ==========================
! Router RT02 - Nyborg
! ==========================

conf t

! --- Hostname og domæne ---
hostname RT02
ip domain-name nyborg.local

! --- Brugere til SSH ---
username admin privilege 15 secret cisco
crypto key generate rsa modulus 2048
ip ssh version 2

! --- LAN SUBINTERFACES ---
interface GigabitEthernet0/0.10
 description VLAN 10 - Klient Nyborg
 encapsulation dot1Q 10
 ip address 10.20.10.1 255.255.255.0
 ip ospf 1 area 0
 exit

interface GigabitEthernet0/0.99
 description VLAN 99 - Management Nyborg
 encapsulation dot1Q 99
 ip address 10.20.99.1 255.255.255.0
 ip ospf 1 area 0
 exit

! --- WAN LINK Odense - Nyborg ---
interface Serial0/0/0
 description Nyborg - Odense
 ip address 172.16.1.2 255.255.255.252
 ip ospf 1 area 0
 exit

! --- Default route til Odense ---
ip route 0.0.0.0 0.0.0.0 172.16.1.1

! --- OSPF ---
router ospf 1
 router-id 2.2.2.2
 network 10.20.10.0 0.0.0.255 area 0
 network 10.20.99.0 0.0.0.255 area 0
 network 172.16.1.0 0.0.0.3 area 0
 passive-interface GigabitEthernet0/0.10
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