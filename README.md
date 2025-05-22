Allgemeine Informationen:
 Dieses Skript automatisiert die Ersteinrichtung und Härtung von Linux-
 Servern. Es richtet sich speziell an die Nutzer von Proxmox-VMs/LXC, 
 ist aber auch für Debian-Systeme geeignet.
 Ziel ist ein sicherer, wartbarer und sofort produktiver Serverbetrieb nach 
 Abschluss.

Voraussetzungen: 
 Das Skript muss mit Root-Rechten ausgeführt werden. Die Software 'dialog' 
 muss installiert sein (wird bei Bedarf automatisch nach installiert).

Funktionsumfang:
 - Systemaktualisierung und automatisierte Updates per Cronjob einrichten.
 - Installation empfohlener Softwarepakete über eine Auswahlmaske.
 - Anpassung des Tastaturlayouts und der Systemzeitzone.
 - Anlegen eines administrativen Benutzers mit sicheren Einstellungen.
 - Vergabe und Änderung des Hostnamens für IPv4 und IPv6.
 - Absicherung des SSH-Logins (z.B. Public-Key, Timeout, Nutzerbeschränkung).
 - Einrichtung und Konfiguration einer Firewall mit Portauswahl.
 - Schutz des Logins (CLI/SSH) durch Fail2ban.
 - Aktivierung von DDoS-, IP-Spoofing- und ARP-Spoofing-Schutzmechanismen.
 - Anpassung des Bash-Prompts für Benutzer (farbig, informativ).