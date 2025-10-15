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