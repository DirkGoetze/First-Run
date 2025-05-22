# Erste Schritte nach der Installation eines neuen LXC-Containers

## Einleitung

Nach der Installation eines neuen LXC-Containers ist es wichtig, das System sicher, aktuell und produktiv zu konfigurieren. In diesem Kapitel werden alle notwendigen Aufgaben beschrieben, die Sie **manuell** durchführen sollten, um Ihren Container optimal einzurichten und abzusichern.

---

## Aufgabe 1: Systemupdate durchführen

Alle Systempakete auf den neuesten Stand bringen.

Führen Sie diesen Schritt immer direkt nach der Installation durch. So stellen Sie sicher, dass Ihr System alle aktuellen Fehlerbehebungen und Sicherheitsupdates erhält.

Nach der Installation einer VM/Containers aus einem Image sind die enthaltenen Programme und Bibliotheken oft nicht mehr auf dem neuesten Stand. Es können Sicherheitslücken oder Fehler enthalten sein, die inzwischen behoben wurden. Durch ein Update werden diese Schwachstellen geschlossen.

Aktuelle Pakete schützen Ihr System vor bekannten Angriffen und Problemen. Angreifer nutzen oft bekannte Sicherheitslücken in veralteter Software aus. Mit regelmäßigen Updates minimieren Sie dieses Risiko und sorgen dafür, dass Ihr Container stabil und sicher läuft.

**Vorgehen:**
1. Melden Sie sich als root an.
2. Führen Sie folgende Befehle aus:
   ```bash
   apt update
   apt upgrade -y
   apt autoremove -y
   ```

**Erklärung der Befehle:**

- `apt update`  
  Dieser Befehl aktualisiert die Paketlisten Ihres Systems. Das bedeutet, Ihr System fragt alle konfigurierten Paketquellen ab und lädt die neuesten Informationen über verfügbare Pakete und deren Versionen herunter. Es werden dabei noch keine Pakete installiert oder verändert.

- `apt upgrade -y`  
  Mit diesem Befehl werden alle installierten Pakete, für die es eine neuere Version gibt, auf den aktuellen Stand gebracht. Die Option `-y` sorgt dafür, dass alle Rückfragen automatisch mit „Ja“ beantwortet werden, sodass der Vorgang ohne weitere Bestätigung abläuft.

- `apt autoremove -y`  
  Nach Updates bleiben manchmal Pakete zurück, die nicht mehr benötigt werden (z.B. alte Bibliotheken). Mit diesem Befehl werden solche überflüssigen Pakete automatisch entfernt. Auch hier sorgt `-y` für eine automatische Bestätigung.

Durch die Ausführung dieser drei Befehle stellen Sie sicher, dass Ihr System aktuell ist und keine unnötigen Altlasten mit sich trägt.

---

## Aufgabe 2: Automatische Updates einrichten

Das System soll sich regelmäßig selbstständig aktualisieren.

Richten Sie automatische Updates ein, damit Ihr Container immer auf dem neuesten Stand bleibt – auch wenn Sie einmal vergessen, manuell Updates durchzuführen.

Im Alltag wird das regelmäßige Einspielen von Updates oft vergessen oder aufgeschoben. Automatische Updates sorgen dafür, dass wichtige Sicherheitslücken und Fehler zeitnah geschlossen werden, ohne dass Sie selbst daran denken müssen.

Durch automatische Updates werden Sicherheitslücken schnell behoben, bevor Angreifer sie ausnutzen können. So bleibt Ihr System dauerhaft geschützt und stabil, auch wenn Sie sich nicht ständig um die Wartung kümmern.

**Vorgehen:**
1. Öffnen Sie die Crontab des root-Benutzers:
   ```bash
   crontab -e
   ```
2. Fügen Sie eine Zeile wie diese hinzu (z.B. jeden Sonntag um 3 Uhr):
   ```
   0 3 * * 0 apt update && apt upgrade -y && apt autoremove -y
   ```

**Erklärung der Befehle und Einstellungen:**

- `crontab -e`  
  Mit diesem Befehl öffnen Sie den Crontab-Editor für den aktuellen Benutzer (hier: root). In der Crontab können Sie zeitgesteuerte Aufgaben (Cronjobs) eintragen, die automatisch zu festgelegten Zeiten ausgeführt werden.

- `0 3 * * 0`  
  Dies ist die Zeitangabe für den Cronjob. Sie bedeutet:
  - `0` Minute 0
  - `3` Stunde 3 (also 3 Uhr nachts)
  - `*` an jedem Tag des Monats
  - `*` in jedem Monat
  - `0` am Sonntag (0 steht für Sonntag)
  Somit wird der Befehl jeden Sonntag um 3:00 Uhr ausgeführt.

- `apt update && apt upgrade -y && apt autoremove -y`  
  Diese Befehle werden nacheinander ausgeführt:
  - `apt update` aktualisiert die Paketlisten.
  - `apt upgrade -y` installiert alle verfügbaren Updates ohne Rückfrage.
  - `apt autoremove -y` entfernt nicht mehr benötigte Pakete automatisch.

Durch das Eintragen dieser Zeile in die Crontab wird Ihr System regelmäßig automatisch aktualisiert und bleibt so stets auf dem neuesten Stand.

---

## Aufgabe 3: Empfohlene Software installieren

Es gibt zahlreiche hilfreiche Tools für die Administration die einem die Arbeit erleichern können. In dieser Aufgabe installieren Sie die am meisten empfohlen Tools für die Nutzung in einer VM/Container.

Installieren Sie immer direkt nach der Grundinstallation wichtige Programme wie `sudo`, `curl`, `nmap`, `htop` und `net-tools`. Diese Werkzeuge erleichtern die Verwaltung und Überwachung Ihres Containers erheblich.

Viele Basis-Images enthalten nur die nötigste Software. Für die tägliche Administration und Fehleranalyse benötigen Sie jedoch zusätzliche Werkzeuge. Mit diesen Tools können Sie z.B. Prozesse überwachen, Netzwerkeinstellungen prüfen oder komfortabel als Administrator arbeiten.

Mit Programmen wie `sudo` können Sie gezielt Rechte vergeben und müssen nicht ständig als root arbeiten, was das Risiko von Fehlbedienungen und Sicherheitslücken verringert. Tools wie `nmap` und `net-tools` helfen, das Netzwerk zu überwachen und ungewollte Verbindungen frühzeitig zu erkennen.

**Vorgehen:**
1. Installieren Sie die gewünschten Pakete, z.B.:
   ```bash
   apt install sudo curl nmap htop net-tools
   ```

**Erklärung der Befehle und Einstellungen:**

- `apt install sudo`  
  Installiert das Programm `sudo`, mit dem normale Benutzer gezielt administrative Befehle ausführen können, ohne sich als root anzumelden.

- `apt install curl`  
  Installiert das Tool `curl`, mit dem Sie Daten von oder zu einem Server übertragen können – z.B. zum Testen von Webdiensten oder zum Herunterladen von Dateien.

- `apt install nmap`  
  Installiert `nmap`, ein Werkzeug zur Analyse und Überprüfung von Netzwerken und offenen Ports. Damit können Sie Ihr System auf unerwünschte offene Dienste prüfen.

- `apt install htop`  
  Installiert `htop`, einen komfortablen, farbigen Prozessmanager, mit dem Sie laufende Prozesse und die Systemauslastung übersichtlich anzeigen lassen können.

- `apt install net-tools`  
  Installiert klassische Netzwerk-Tools wie `ifconfig` und `netstat`, die für viele Netzwerkdiagnosen nützlich sind.

Alle genannten Programme können Sie in einem Schritt installieren:
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
