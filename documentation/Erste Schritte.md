# Erste Schritte nach der Installation eines neuen LXC-Containers

## Einleitung

Nach der Installation eines neuen LXC-Containers ist es wichtig, das System sicher, aktuell und produktiv zu konfigurieren. In diesem Kapitel werden alle notwendigen Aufgaben beschrieben, die Sie **manuell** durchführen sollten, um Ihren Container optimal einzurichten und abzusichern.

---

## Aufgabe 1: Systemupdate durchführen

**Ziel:**  
Alle Systempakete auf den neuesten Stand bringen.

**Vorgehen:**
1. Melden Sie sich als root an.
2. Führen Sie folgende Befehle aus:
   ```bash
   apt update
   apt upgrade -y
   apt autoremove -y
   ```

---

## Aufgabe 2: Automatische Updates einrichten

**Ziel:**  
Das System soll sich regelmäßig selbst aktualisieren.

**Vorgehen:**
1. Öffnen Sie die Crontab des root-Benutzers:
   ```bash
   crontab -e
   ```
2. Fügen Sie eine Zeile wie diese hinzu (z.B. jeden Sonntag um 3 Uhr):
   ```
   0 3 * * 0 apt update && apt upgrade -y && apt autoremove -y
   ```

---

## Aufgabe 3: Empfohlene Software installieren

**Ziel:**  
Hilfreiche Tools für die Administration installieren.

**Vorgehen:**
1. Installieren Sie die gewünschten Pakete, z.B.:
   ```bash
   apt install sudo curl nmap htop net-tools
   ```

---

## Aufgabe 4: Tastatur-Layout anpassen

**Ziel:**  
Das Tastatur-Layout auf Ihre Sprache/Herkunft einstellen.

**Vorgehen:**
1. Führen Sie aus:
   ```bash
   dpkg-reconfigure locales
   ```

---

## Aufgabe 5: Zeitzone und Zeitserver konfigurieren

**Ziel:**  
Die richtige Zeitzone setzen und Zeit-Synchronisation aktivieren.

**Vorgehen:**
1. Zeitzone setzen:
   ```bash
   timedatectl set-timezone Europe/Berlin
   ```
2. NTP installieren (optional):
   ```bash
   apt install ntp
   ```

---

## Aufgabe 6: Administrativen Benutzer anlegen

**Ziel:**  
Einen neuen Benutzer mit sudo-Rechten anlegen.

**Vorgehen:**
1. Benutzer anlegen:
   ```bash
   adduser <benutzername>
   ```
2. Zur Gruppe sudo hinzufügen:
   ```bash
   usermod -aG sudo <benutzername>
   ```

---

## Aufgabe 7: Hostname setzen

**Ziel:**  
Einen eindeutigen Hostnamen vergeben.

**Vorgehen:**
1. Hostname setzen:
   ```bash
   hostnamectl set-hostname <neuer-hostname>
   ```
2. In `/etc/hosts` die Zeile für die lokale IP anpassen:
   ```
   127.0.1.1   <neuer-hostname>
   ```

---

## Aufgabe 8: SSH-Login absichern

**Ziel:**  
SSH-Zugang härten (z.B. nur Schlüssel, root-Login verbieten).

**Vorgehen:**
1. SSH-Key für den Benutzer generieren:
   ```bash
   su - <benutzername>
   ssh-keygen -b 4096
   ```
2. Public-Key in `~/.ssh/authorized_keys` eintragen.
3. In `/etc/ssh/sshd_config` folgende Einstellungen setzen:
   ```
   PermitRootLogin without-password
   PasswordAuthentication no
   PubkeyAuthentication yes
   AllowUsers <benutzername>
   ```
4. SSH-Dienst neu starten:
   ```bash
   systemctl restart sshd
   ```

---

## Aufgabe 9: Firewall einrichten

**Ziel:**  
Nur benötigte Ports öffnen.

**Vorgehen:**
1. Firewall installieren:
   ```bash
   apt install ufw
   ```
2. Standardregeln setzen:
   ```bash
   ufw default deny incoming
   ufw default allow outgoing
   ```
3. Benötigte Ports öffnen, z.B.:
   ```bash
   ufw allow 22/tcp
   ufw allow 80/tcp
   ufw allow 443/tcp
   ```
4. Firewall aktivieren:
   ```bash
   ufw enable
   ```

---

## Aufgabe 10: Login absichern (Fail2ban)

**Ziel:**  
Schutz vor Brute-Force-Angriffen.

**Vorgehen:**
1. Fail2ban installieren:
   ```bash
   apt install fail2ban
   ```
2. Konfiguration anpassen, z.B. `/etc/fail2ban/jail.local`:
   ```
   [sshd]
   enabled = true
   maxretry = 3
   bantime = 6h
   findtime = 7d
   ```

---

## Aufgabe 11: DDoS-Schutz aktivieren

**Ziel:**  
Netzwerkregeln gegen DDoS-Angriffe setzen.

**Vorgehen:**
1. Diverse iptables-Regeln setzen (siehe [iptables DDoS Schutz](https://wiki.ubuntuusers.de/iptables/)).
2. Beispiel:
   ```bash
   iptables -A INPUT -p udp -m limit --limit 150/s -j ACCEPT
   iptables -A INPUT -p udp -j DROP
   # Weitere Regeln nach Bedarf
   ```

---

## Aufgabe 12: IP-Spoofing-Schutz aktivieren

**Ziel:**  
Reverse Path Filtering und Kernel-Optionen setzen.

**Vorgehen:**
1. In `/etc/sysctl.conf` folgende Zeilen ergänzen:
   ```
   net.ipv4.conf.all.rp_filter=1
   net.ipv4.conf.default.rp_filter=1
   net.ipv4.conf.all.accept_source_route=0
   net.ipv4.conf.default.accept_source_route=0
   net.ipv4.conf.all.accept_redirects=0
   net.ipv4.conf.default.accept_redirects=0
   net.ipv4.conf.all.send_redirects=0
   net.ipv4.conf.default.send_redirects=0
   ```
2. Einstellungen anwenden:
   ```bash
   sysctl -p
   ```

---

## Aufgabe 13: ARP-Spoofing-Schutz aktivieren

**Ziel:**  
Statische ARP-Einträge für wichtige Netzwerkgeräte setzen.

**Vorgehen:**
1. MAC-Adresse und IP der Netzwerkkarte ermitteln:
   ```bash
   ip link show
   ip addr show
   ```
2. Statischen ARP-Eintrag setzen:
   ```bash
   arp -i <interface> -s <ip> <mac>
   ```
3. Diesen Befehl in ein Skript wie `/etc/network/if-up.d/add-my-static-arp` eintragen und ausführbar machen.

---

## Aufgabe 14: Bash Prompt anpassen

**Ziel:**  
Einen farbigen, informativen Prompt für Benutzer einrichten.

**Vorgehen:**
1. Öffnen Sie die Datei `~/.bashrc` des jeweiligen Benutzers.
2. Fügen Sie einen farbigen Prompt-Block ein, z.B.:
   ```bash
   PS1='\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'
   ```

---

## Abschluss

Nach Durchführung aller Aufgaben ist Ihr LXC-Container sicher, aktuell und bereit für den produktiven Einsatz.  
Dokumentieren Sie alle Änderungen und bewahren Sie Ihre Konfigurationsdateien sorgfältig auf.
