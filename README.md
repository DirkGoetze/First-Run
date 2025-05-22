# PROXMOX Tool's - Ersteinrichtung VM/LXC

## Allgemeine Informationen
Dieses Skript automatisiert die Ersteinrichtung und Härtung von Linux- Servern. Es richtet sich speziell an die Nutzer von Proxmox-VMs/LXC, ist aber auch für Debian-Systeme geeignet.

Ziel ist ein sicherer, wartbarer und sofort produktiver Serverbetrieb nach Abschluss der Erstinstallation und ausführung diese Skriptes.

## Voraussetzungen
Das Skript muss mit Root-Rechten ausgeführt werden. Sollte dies nicht der Fall sein und ein User das Skript ohne ausreichende Rechte ausführt, wird eine Fehlermeldung ausgegeben. Die Software 'dialog' 
muss installiert sein (wird jedoch bei Bedarf automatisch nach installiert).

## Funktionsumfang
* Systemaktualisierung und automatisierte Updates per Cronjob einrichten.
* Installation empfohlener Softwarepakete über eine Auswahlmaske.
* Anpassung des Tastaturlayouts und der Systemzeitzone.
* Anlegen eines administrativen Benutzers mit sicheren Einstellungen.
* Vergabe und Änderung des Hostnamens für IPv4 und IPv6.
* Absicherung des SSH-Logins (z.B. Public-Key, Timeout, Nutzerbeschränkung).
* Einrichtung und Konfiguration einer Firewall mit Portauswahl.
* Schutz des Logins (CLI/SSH) durch Fail2ban.
* Aktivierung von DDoS-, IP-Spoofing- und ARP-Spoofing-Schutzmechanismen.
* Anpassung des Bash-Prompts für Benutzer (farbig, informativ).

## Anleitung: Skript herunterladen und ausführen (ohne git)

1. **Öffne ein Terminal** auf deinem Linux-System.

2. **Wechsle in das gewünschte Verzeichnis** (z. B. ins Home-Verzeichnis):
   ```bash
   cd ~
   ```

3. **Lade das Skript als ZIP-Datei von GitHub herunter:**  
   Ersetze `<USER>` und `<REPOSITORY>` durch die passenden Namen.
   ```bash
   wget https://github.com/<USER>/<REPOSITORY>/archive/refs/heads/main.zip
   ```

4. **Entpacke die ZIP-Datei:**
   ```bash
   unzip main.zip
   ```

   *Falls das Programm `unzip` nicht installiert ist, kannst du es nachinstallieren:*
   ```bash
   sudo apt update && sudo apt install unzip
   ```

5. **Wechsle in das entpackte Verzeichnis:**
   ```bash
   cd <REPOSITORY>-main
   ```

6. **Mache das Skript ausführbar:**
   ```bash
   chmod +x first-run.sh
   ```

7. **Starte das Skript mit Root-Rechten:**
   ```bash
   sudo ./first-run.sh
   ```

**Hinweis:**  
Das Skript benötigt Root-Rechte.  
Folge den Anweisungen im Dialog-Menü, um die Einrichtung abzuschließen.