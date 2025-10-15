# Skole Netværkslaboratorium

## VLAN & IP Plan

| Site       | VLAN | Subnet           | Enhed/Role           | IP-adresse       | Kommentar                             |
|------------|------|-----------------|--------------------|----------------|---------------------------------------|
| Odense     | 10   | 10.10.10.0/24   | RT01 Gi0/0.10      | 10.10.10.1     | Klient subnet                          |
| Odense     | 20   | 10.10.20.0/24   | RT01 Gi0/0.20      | 10.10.20.1     | Server subnet                          |
| Odense     | 30   | 10.10.30.0/24   | RT01 Gi0/0.30      | 10.10.30.1     | Printer subnet                         |
| Odense     | 99   | 10.10.99.0/24   | RT01 Gi0/0.99      | 10.10.99.1     | Management subnet                      |
| Nyborg     | 10   | 10.20.10.0/24   | RT02 Gi0/0.10      | 10.20.10.1     | Klient subnet                          |
| Nyborg     | 99   | 10.20.99.0/24   | RT02 Gi0/0.99      | 10.20.99.1     | Management subnet                      |
| Svendborg  | 10   | 10.30.10.0/24   | RT03 Gi0/0.10      | 10.30.10.1     | Klient subnet                          |
| Svendborg  | 99   | 10.30.99.0/24   | RT03 Gi0/0.99      | 10.30.99.1     | Management subnet                      |
| Odense     | WAN  | 172.16.1.0/30   | RT01 ↔ RT02        | 172.16.1.1     | Point-to-point link Odense↔Nyborg     |
| Odense     | WAN  | 172.16.2.0/30   | RT01 ↔ RT03        | 172.16.2.1     | Point-to-point link Odense↔Svendborg |

---

## Router & Switch Roller

| Enhed        | Rolle                                       | Kommentar |
|--------------|--------------------------------------------|-----------|
| RT01         | NAT, OSPF, router-on-a-stick for VLAN      | Internet adgang via WAN DHCP |
| RT02         | OSPF, default route til RT01               | Ingen direkte Internet |
| RT03         | OSPF, default route til RT01               | Ingen direkte Internet |
| SW01         | VLAN konfiguration, trunk til RT01         | Odense site |
| SW02         | VLAN konfiguration, trunk til RT02         | Nyborg site |
| SW03         | VLAN konfiguration, trunk til RT03         | Svendborg site |
| ESXi Server  | Virtuelle servere DC1 & DC2, AD, DNS etc. | Odense site |

---
