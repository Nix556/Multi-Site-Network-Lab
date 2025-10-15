! --- Trunk-port til router RT01 ---
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30,99
 exit

! --- Access-porte for klienter VLAN 10 ---
interface range GigabitEthernet0/2 - 10
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
 exit

! --- Access-porte for servere VLAN 20 ---
interface range GigabitEthernet0/11 - 12
 switchport mode access
 switchport access vlan 20
 spanning-tree portfast
 exit

! --- Access-porte for printere VLAN 30 ---
interface range GigabitEthernet0/13 - 14
 switchport mode access
 switchport access vlan 30
 spanning-tree portfast
 exit