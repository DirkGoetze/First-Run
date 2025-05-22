# Erste Schritte nach der Installation eines neuen LXC-Containers

## Einleitung

Nach der Installation eines neuen LXC-Containers ist es wichtig, das System sicher, aktuell und produktiv zu konfigurieren. In diesem Kapitel werden alle notwendigen Aufgaben beschrieben, die Sie **manuell** durchführen sollten, um Ihren Container optimal einzurichten und abzusichern.

<!-- Inhaltsverzeichnis -->
## Inhaltsverzeichnis

- [Einleitung](#einleitung)
- [Aufgabe 1: Systemupdate durchführen](#aufgabe-1-systemupdate-durchführen)
- [Aufgabe 2: Automatische Updates einrichten](#aufgabe-2-automatische-updates-einrichten)
- [Aufgabe 3: Empfohlene Software installieren](#aufgabe-3-empfohlene-software-installieren)
- [Aufgabe 4: Tastatur-Layout anpassen](#aufgabe-4-tastatur-layout-anpassen)
- [Aufgabe 5: Zeitzone und Zeitserver konfigurieren](#aufgabe-5-zeitzone-und-zeitserver-konfigurieren)
- [Aufgabe 6: Administrativen Benutzer anlegen](#aufgabe-6-administrativen-benutzer-anlegen)
- [Aufgabe 7: Hostname setzen](#aufgabe-7-hostname-setzen)
- [Aufgabe 8: SSH-Login absichern](#aufgabe-8-ssh-login-absichern)
- [Aufgabe 9: Firewall einrichten](#aufgabe-9-firewall-einrichten)
- [Aufgabe 10: Login absichern (Fail2ban)](#aufgabe-10-login-absichern-fail2ban)
- [Aufgabe 11: CrowdSec nutzen](#aufgabe-11-crowdsec-nutzen)
- [Aufgabe 12: Zwei-Faktor-Authentifizierung (2FA) für SSH](#aufgabe-12-zwei-faktor-authentifizierung-2fa-für-ssh)
- [Aufgabe 13: DDoS-Schutz aktivieren](#aufgabe-13-ddos-schutz-aktivieren)
- [Aufgabe 14: IP-Spoofing-Schutz aktivieren](#aufgabe-14-ip-spoofing-schutz-aktivieren)
- [Aufgabe 15: ARP-Spoofing-Schutz aktivieren](#aufgabe-15-arp-spoofing-schutz-aktivieren)
- [Aufgabe 16: Automatische Überwachung und Alarmierung](#aufgabe-16-automatische-überwachung-und-alarmierung)
- [Aufgabe 17: Regelmäßige Backups](#aufgabe-17-regelmäßige-backups)
- [Aufgabe 18: Dateisystem- und Rechtehärtung](#aufgabe-18-dateisystem--und-rechtehärtung)
- [Aufgabe 19: Verwendung von sicheren Protokollen](#aufgabe-19-verwendung-von-sicheren-protokollen)
- [Aufgabe 20: Regelmäßige Überprüfung offener Ports](#aufgabe-20-regelmäßige-überprüfung-offener-ports)
- [Aufgabe 21: Bash Prompt anpassen](#aufgabe-21-bash-prompt-anpassen)
- [Abschluss](#abschluss)

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

Das Tastatur-Layout auf Ihre Sprache/Herkunft einstellen.

Passen Sie nach der Installation das Tastatur-Layout an Ihre Sprache und Ihr Land an. So stellen Sie sicher, dass alle Zeichen auf Ihrer Tastatur wie erwartet funktionieren und Sie komfortabel arbeiten können.

Gerade bei Servern und Containern, die aus internationalen Images erstellt werden, ist oft ein englisches oder anderes Standard-Layout eingestellt. Das führt dazu, dass Sonderzeichen, Umlaute oder wichtige Tasten wie Z und Y vertauscht sind. Das kann die Eingabe von Passwörtern, Befehlen oder Konfigurationsdateien erschweren und zu Fehlern führen.

Ein korrekt eingestelltes Tastatur-Layout hilft, Tippfehler bei Passwörtern und wichtigen Systembefehlen zu vermeiden. Das reduziert das Risiko, versehentlich falsche oder unsichere Einstellungen vorzunehmen. Außerdem wird verhindert, dass durch falsche Eingaben Sicherheitsmechanismen wie Fail2ban unnötig ausgelöst werden, weil Passwörter falsch eingegeben wurden.

Sie sollten das Tastatur-Layout und die Zeichencodierung (Locale) immer passend zu Ihrer Sprache und Ihrem Standort auswählen. Für deutschsprachige Nutzer empfiehlt es sich, mindestens folgende Layouts und Locales zu installieren:

- **de_DE.UTF-8** (Deutsch, Deutschland, UTF-8)
- **en_GB.UTF-8** (Englisch, Großbritannien, UTF-8)
- **en_US.UTF-8** (Englisch, USA, UTF-8)

- **UTF-8** ist der aktuelle Standard für die Zeichencodierung und unterstützt alle wichtigen Sonderzeichen, Umlaute und internationale Zeichen. Damit vermeiden Sie Probleme bei der Anzeige und Eingabe von Texten, insbesondere bei Umlauten und Sonderzeichen.
- **de_DE.UTF-8** sorgt dafür, dass alle deutschen Sonderzeichen (ä, ö, ü, ß) korrekt funktionieren und Datums-/Zeitangaben sowie Sortierungen nach deutschen Standards erfolgen.
- **en_GB.UTF-8** und **en_US.UTF-8** sind hilfreich, wenn Sie gelegentlich englische Software nutzen oder Skripte aus internationalen Quellen verwenden. Viele Programme und Fehlermeldungen sind auf Englisch, daher ist eine englische Locale oft praktisch.
- Die Auswahl mehrerer Layouts ermöglicht es Ihnen, flexibel zwischen verschiedenen Sprachen und Tastaturbelegungen zu wechseln, falls Sie z.B. mit internationalen Teams arbeiten oder englische Tastaturen verwenden.

**Empfehlung:**  
Installieren Sie alle drei oben genannten Locales und wählen Sie **de_DE.UTF-8** als Standard aus, wenn Sie hauptsächlich auf Deutsch arbeiten. So stellen Sie sicher, dass Ihr System optimal für deutschsprachige Nutzer eingerichtet ist, aber auch internationale Kompatibilität gewährleistet bleibt.

**So gehen Sie vor:**  
Beim Ausführen von  
```bash
dpkg-reconfigure locales
```
wählen Sie die gewünschten Locales (z.B. mit der Leertaste) aus und setzen Sie **de_DE.UTF-8** als Standard.  
Für das Tastatur-Layout empfiehlt sich bei deutschen Tastaturen die Auswahl von **"German" (de)**.

**Zusammengefasst:**  
Mit dieser Auswahl vermeiden Sie Darstellungsprobleme, Tippfehler und stellen sicher, dass Ihr System sowohl für deutschsprachige als auch internationale Anwendungen optimal funktioniert.

**Erklärung des Befehls:**

- `dpkg-reconfigure locales`  
  Mit diesem Befehl können Sie die Spracheinstellungen und das Tastatur-Layout Ihres Systems anpassen. Folgen Sie dem Dialog, um die gewünschte Sprache und das passende Layout auszuwählen. Nach Abschluss werden die Einstellungen übernommen und stehen sofort zur Verfügung.

---

## Aufgabe 5: Zeitzone und Zeitserver konfigurieren

Die richtige Zeitzone setzen und Zeit-Synchronisation aktivieren.

Stellen Sie nach der Installation immer die korrekte Zeitzone ein und sorgen Sie dafür, dass die Systemzeit automatisch mit einem Zeitserver synchronisiert wird. So vermeiden Sie Zeitabweichungen und stellen sicher, dass alle Protokolle und geplanten Aufgaben mit der richtigen Uhrzeit arbeiten.

Eine falsch eingestellte Zeitzone oder eine nicht synchronisierte Systemzeit kann zu Problemen bei der Protokollierung, bei zeitgesteuerten Aufgaben (Cronjobs) und bei der Fehlersuche führen. Besonders in Netzwerken mit mehreren Servern ist es wichtig, dass alle Systeme die gleiche Zeitbasis haben, damit Logdateien und Ereignisse korrekt zugeordnet werden können.

Eine korrekte und synchronisierte Systemzeit ist für die Sicherheit unerlässlich. Viele sicherheitsrelevante Prozesse, wie z.B. Authentifizierungen, Ablaufzeiten von Zertifikaten oder die Analyse von Angriffen in Logdateien, sind auf eine exakte Zeitangabe angewiesen. Zeitabweichungen können dazu führen, dass Angriffe nicht erkannt oder falsch interpretiert werden. Mit einer synchronisierten Zeitbasis erhöhen Sie die Nachvollziehbarkeit und Integrität Ihrer Systemprotokolle.

**Vorgehen:**
1. Zeitzone setzen:
   ```bash
   timedatectl set-timezone Europe/Berlin
   ```
2. NTP installieren (optional):
   ```bash
   apt install ntp
   ```

**Erklärung der Befehle:**

- `timedatectl set-timezone Europe/Berlin`  
  Mit diesem Befehl stellen Sie die Zeitzone Ihres Systems auf „Europe/Berlin“ ein. Sie können auch eine andere Zeitzone wählen, die zu Ihrem Standort passt. Die richtige Zeitzone sorgt dafür, dass alle Zeitangaben im System und in den Logdateien korrekt sind.

- `apt install ntp`  
  Mit diesem Befehl installieren Sie das Programm NTP (Network Time Protocol). NTP sorgt normalerweise dafür, dass Ihr System die Uhrzeit regelmäßig mit einem Zeitserver im Internet abgleicht und so immer die exakte Zeit verwendet. In vielen LXC-Containern ist dieser Dienst jedoch nicht notwendig oder funktioniert nicht wie gewohnt, da die Systemzeit automatisch vom Proxmox-Host übernommen wird. In den meisten Fällen reicht es daher aus, die Zeitzone korrekt einzustellen – die Zeit selbst wird automatisch synchronisiert.

---

## Aufgabe 6: Administrativen Benutzer anlegen

Einen neuen Benutzer mit sudo-Rechten anlegen.

Legen Sie nach der Installation immer einen eigenen administrativen Benutzer an, der über sudo-Rechte verfügt. So müssen Sie nicht dauerhaft als root arbeiten und können die Systemverwaltung sicherer gestalten.

Die Arbeit mit einem eigenen Benutzerkonto ist sicherer und übersichtlicher als die ständige Nutzung des root-Kontos. Mit sudo können Sie gezielt einzelne Befehle mit Administratorrechten ausführen, ohne sich komplett als root anzumelden. Das reduziert das Risiko von unbeabsichtigten Änderungen am System und erleichtert die Nachvollziehbarkeit von Aktionen.

Durch die Nutzung eines Benutzers mit sudo-Rechten statt des root-Kontos wird die Angriffsfläche für Schadsoftware und Angreifer verringert. Viele Angriffe zielen speziell auf das root-Konto ab. Mit sudo können Sie außerdem den Zugriff besser kontrollieren und protokollieren, da alle Aktionen mit erhöhten Rechten nachvollziehbar sind.

**Vorgehen:**
1. Benutzer anlegen:
   ```bash
   adduser <benutzername>
   ```
2. Passwort für den Benutzer setzen (falls nicht schon im ersten Schritt geschehen):
   ```bash
   passwd <benutzername>
   ```
   Sie werden zur Eingabe und Bestätigung des neuen Passworts aufgefordert.
3. Zur Gruppe 'sudo' hinzufügen:
   ```bash
   usermod -aG sudo <benutzername>
   ```

**Erklärung der Befehle:**

- `adduser <benutzername>`  
  Legt einen neuen Benutzer an und fragt interaktiv nach Passwort und weiteren Informationen wie vollständiger Name, Telefonnummer usw.

- `passwd <benutzername>`  
  Setzt oder ändert das Passwort für den angegebenen Benutzer. Dies ist nützlich, falls Sie das Passwort nachträglich ändern möchten.

- `usermod -aG sudo <benutzername>`  
  Fügt den neuen Benutzer zur Gruppe `sudo` hinzu. Mitglieder dieser Gruppe dürfen mit dem Befehl `sudo` administrative Aufgaben ausführen.

---

## Aufgabe 7: Hostname setzen

Einen eindeutigen Hostnamen vergeben.

Vergeben Sie nach der Installation immer einen eindeutigen und aussagekräftigen Hostnamen für Ihren Container. So behalten Sie auch bei mehreren Systemen stets den Überblick und vermeiden Verwechslungen, besonders in Netzwerken mit vielen Geräten.

Ein klarer Hostname hilft Ihnen und anderen Administratoren, das System schnell zu identifizieren – zum Beispiel bei der Anmeldung per SSH, in Monitoring-Tools oder bei der Fehlersuche. Ohne einen passenden Hostnamen kann es leicht zu Verwirrungen kommen, wenn mehrere Systeme denselben Standardnamen tragen oder nicht eindeutig benannt sind.

Ein eindeutiger Hostname trägt zur Sicherheit bei, weil er Manipulationen und Angriffe erschwert, die auf Verwechslungen oder gezielte Täuschung setzen. Außerdem erleichtert er die Protokollierung und Überwachung, da Sie in Logdateien und Netzwerkübersichten sofort erkennen, welches System gemeint ist. So können Sie schneller auf sicherheitsrelevante Ereignisse reagieren und Fehlerquellen gezielt eingrenzen.
  
**Vorgehen:**
1. Hostname setzen:
   ```bash
   hostnamectl set-hostname <neuer-hostname>
   ```
2. In `/etc/hosts` die Zeile für die lokale IP anpassen:
   ```
   127.0.1.1   <neuer-hostname>
   ```

**Erklärung der Befehle:**

- `hostnamectl set-hostname <neuer-hostname>`  
  Mit diesem Befehl setzen Sie den neuen Hostnamen für Ihr System. Der Hostname wird sofort übernommen und bleibt auch nach einem Neustart erhalten.

- Anpassung der Datei `/etc/hosts`:  
  In dieser Datei ordnen Sie die lokale IP-Adresse (meist `127.0.1.1`) dem neuen Hostnamen zu. Das ist wichtig, damit Programme und Dienste den Hostnamen korrekt auflösen können.  
  Beispiel:
  ```
  127.0.1.1   <neuer-hostname>
  ```


---

## Aufgabe 8: SSH-Login absichern

Den SSH-Zugang absichern, indem Sie die Anmeldung auf sichere Methoden beschränken und unnötige Risiken wie Passwort-Login oder root-Login vermeiden.

Es wird empfohlen, den SSH-Zugang so zu konfigurieren, dass sich nur bestimmte Benutzer mit einem SSH-Schlüssel anmelden dürfen. Die Anmeldung mit Passwort sollte deaktiviert und der direkte root-Login verboten werden. So schützen Sie Ihren Container vor unbefugtem Zugriff und automatisierten Angriffen.

Viele Angreifer versuchen, sich mit automatisierten Programmen per Passwort auf Server einzuloggen (Brute-Force-Angriffe). Wenn Sie die Anmeldung per Passwort abschalten und nur noch den Zugang mit einem privaten Schlüssel erlauben, wird ein Angriff deutlich erschwert. Der root-Login sollte deaktiviert werden, weil ein erfolgreicher Angriff auf root sofort vollen Zugriff auf das System ermöglicht.

Mit diesen Einstellungen verhindern Sie, dass Unbefugte durch einfaches Ausprobieren von Passwörtern Zugriff erhalten. Nur wer im Besitz des passenden privaten Schlüssels ist und als erlaubter Benutzer eingetragen wurde, kann sich anmelden. Das macht Ihr System deutlich sicherer und schützt vor den meisten automatisierten Angriffen auf SSH.

**Vorgehen (Beispiel):**

1. **SSH-Schlüssel für den Benutzer generieren:**
   ```bash
   su - max
   ssh-keygen -b 4096
   ```
   Folgen Sie dem Dialog und drücken Sie Enter, um den Schlüssel im Standardpfad zu speichern.

2. **Öffentlichen Schlüssel eintragen:**
   ```bash
   cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```
   Damit kann sich nur noch jemand mit dem passenden privaten Schlüssel anmelden.

3. **SSH-Konfiguration anpassen:**  
   Öffnen Sie `/etc/ssh/sshd_config` und setzen Sie folgende Werte:
   ```
   PermitRootLogin without-password
   PasswordAuthentication no
   PubkeyAuthentication yes
   AllowUsers max
   ```
   - `PermitRootLogin without-password`: Root-Login ist nur mit Schlüssel, nicht mit Passwort möglich.
   - `PasswordAuthentication no`: Anmeldung mit Passwort ist komplett deaktiviert.
   - `PubkeyAuthentication yes`: Anmeldung mit SSH-Schlüssel ist erlaubt.
   - `AllowUsers max`: Nur der Benutzer `max` darf sich per SSH anmelden.

4. **SSH-Dienst neu starten:**
   ```bash
   systemctl restart sshd
   ```

**Erklärung der Befehle:**

- `su - <benutzername>`  
  Wechselt zum gewünschten Benutzer, für den der SSH-Schlüssel erstellt werden soll.

- `ssh-keygen -b 4096`  
  Erstellt ein neues Schlüsselpaar (privat/öffentlich) mit einer Schlüssellänge von 4096 Bit.

- `cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys`  
  Fügt den öffentlichen Schlüssel zur Liste der erlaubten Schlüssel hinzu.

- `chmod 600 ~/.ssh/authorized_keys`  
  Setzt die richtigen Berechtigungen für die Datei, damit nur der Benutzer darauf zugreifen kann.

- Einstellungen in `/etc/ssh/sshd_config`  
  Hier werden die Zugriffsregeln für SSH gesetzt (siehe oben).

- `systemctl restart sshd`  
  Startet den SSH-Dienst neu, damit die Änderungen wirksam werden.

**SSH-Schlüssel auslesen:**  
Um den privaten Schlüssel anzuzeigen (z.B. um ihn auf einen anderen Rechner zu kopieren), können Sie folgenden Befehl nutzen:
```bash
cat ~/.ssh/id_rsa
```
**Achtung:** Der private Schlüssel ist geheim und darf niemals weitergegeben oder veröffentlicht werden!

**Zusätzliche Optionen für noch mehr Sicherheit:**

- **TimeOut:**  
  Sie können die SSH-Sitzung automatisch beenden lassen, wenn keine Aktivität erfolgt. Dazu in `/etc/ssh/sshd_config`:
  ```
  ClientAliveInterval 300
  ClientAliveCountMax 2
  ```
  Damit wird die Verbindung nach 10 Minuten Inaktivität getrennt.

- **AllowUsers:**  
  Mit `AllowUsers <benutzername>` können Sie den SSH-Zugang auf bestimmte Benutzer beschränken. Nur diese dürfen sich dann anmelden.

Mit diesen Maßnahmen ist Ihr SSH-Zugang optimal gegen die meisten Angriffsarten geschützt.

---

## Aufgabe 9: Firewall einrichten

Server kommunizieren über sogenannte Ports. Jeder offene Port ist eine potenzielle Schwachstelle, über die Angreifer ins System eindringen könnten. Viele Angriffe nutzen gezielt offene, aber nicht benötigte Ports aus. Mit einer Firewall können Sie gezielt steuern, welcher Datenverkehr erlaubt ist und welcher blockiert wird.

Ports sind wie Türen am Computer, über die Programme mit dem Internet oder anderen Geräten kommunizieren. Jeder Dienst (z.B. Webseiten, E-Mail, Fernzugriff) nutzt einen bestimmten Port. Wenn ein Port offen ist, kann von außen auf diesen Dienst zugegriffen werden. Mit einer Firewall können Sie steuern, welche dieser "Türen" offen oder geschlossen sind.

Es wird empfohlen, direkt nach der Installation eine Firewall zu aktivieren und nur die Ports zu öffnen, die für Ihre Anwendungen und Dienste wirklich notwendig sind. So verhindern Sie, dass ungenutzte oder unsichere Dienste von außen erreichbar sind.

Durch das Schließen aller nicht benötigten Ports und das gezielte Freigeben nur der wirklich notwendigen Dienste wird die Angriffsfläche Ihres Systems deutlich reduziert. So schützen Sie Ihren Container effektiv vor unbefugtem Zugriff und automatisierten Angriffen aus dem Internet.

**Vorgehen (Beispiel):**

1. **Firewall installieren:**
   ```bash
   apt install ufw
   ```
   Installiert das Programm UFW („Uncomplicated Firewall“), das die Verwaltung der Firewall-Regeln vereinfacht.

2. **Standardregeln setzen:**
   ```bash
   ufw default deny incoming
   ufw default allow outgoing
   ```
   Blockiert standardmäßig alle eingehenden Verbindungen und erlaubt alle ausgehenden Verbindungen.

3. **Benötigte Ports öffnen (Beispiele):**
   ```bash
   ufw allow 22/tcp    # SSH
   ufw allow 80/tcp    # HTTP (Webserver)
   ufw allow 443/tcp   # HTTPS (Webserver)
   ```
   Öffnet gezielt die Ports für Dienste, die von außen erreichbar sein sollen.

4. **Firewall aktivieren:**
   ```bash
   ufw enable
   ```
   Schaltet die Firewall scharf und aktiviert die Regeln.

**Erklärung der Befehle:**

- `apt install ufw`  
  Installiert die Firewall-Software UFW auf Ihrem System.

- `ufw default deny incoming`  
  Blockiert alle eingehenden Verbindungen, die nicht explizit erlaubt wurden.

- `ufw default allow outgoing`  
  Erlaubt alle ausgehenden Verbindungen vom System ins Internet.

- `ufw allow 22/tcp`  
  Öffnet den Port 22 für SSH-Verbindungen.

- `ufw allow 80/tcp`  
  Öffnet den Port 80 für HTTP (Webseiten).

- `ufw allow 443/tcp`  
  Öffnet den Port 443 für HTTPS (verschlüsselte Webseiten).

- `ufw enable`  
  Aktiviert die Firewall und setzt alle definierten Regeln in Kraft.

**Zusätzliche Optionen für noch mehr Sicherheit:**

- **Nur bestimmte IPs erlauben:**  
  Sie können Zugriffe auf bestimmte Ports auf einzelne IP-Adressen beschränken, z.B.:
  ```bash
  ufw allow from 192.168.1.100 to any port 22 proto tcp
  ```
  Nur die IP 192.168.1.100 darf sich per SSH verbinden.

- **Firewall-Status anzeigen:**  
  Mit
  ```bash
  ufw status verbose
  ```
  sehen Sie alle aktiven Regeln und können prüfen, ob alles wie gewünscht eingestellt ist.

- **Firewall beim Systemstart aktivieren:**  
  UFW ist nach der Aktivierung automatisch beim Systemstart aktiv. Sie können dies mit
  ```bash
  systemctl enable ufw
  ```
  sicherstellen.

- **Logging aktivieren:**  
  Um verdächtigen Traffic zu protokollieren:
  ```bash
  ufw logging on
  ```

Mit diesen zusätzlichen Einstellungen können Sie Ihre Firewall noch gezielter konfigurieren und Ihr System optimal absichern.

---

## Aufgabe 10: Login absichern (Fail2ban)

Den Login gegen Brute-Force-Angriffe absichern, indem wiederholt fehlgeschlagene Anmeldeversuche automatisch zur Sperrung der betreffenden IP-Adresse führen.

Es wird empfohlen, direkt nach der Einrichtung des Systems einen Schutz wie Fail2ban zu aktivieren. Fail2ban überwacht die Login-Versuche (z.B. per SSH) und sperrt automatisch IP-Adressen, von denen zu viele fehlgeschlagene Anmeldeversuche kommen. So schützen Sie Ihr System vor automatisierten Angriffen, bei denen Passwörter durch Ausprobieren erraten werden sollen.

Gerade Server, die aus dem Internet erreichbar sind, werden häufig Ziel von Brute-Force-Angriffen. Angreifer versuchen dabei, durch automatisiertes Ausprobieren von Passwörtern Zugriff zu erhalten. Ohne Schutzmechanismen könnten sie beliebig viele Versuche starten. Mit Fail2ban wird nach einer festgelegten Anzahl von Fehlversuchen die IP-Adresse für eine bestimmte Zeit gesperrt. Das macht solche Angriffe praktisch wirkungslos.

Durch die automatische Sperrung verdächtiger IP-Adressen wird Ihr System effektiv vor unbefugtem Zugriff geschützt. Angreifer werden ausgebremst und können nicht beliebig viele Passwörter ausprobieren. So bleibt Ihr System auch bei ständiger Erreichbarkeit im Internet sicherer.

**Vorgehen (Beispiel):**

1. **Fail2ban installieren:**
   ```bash
   apt install fail2ban
   ```
   Installiert das Schutzprogramm.

2. **Konfiguration anpassen:**  
   Öffnen Sie z.B. die Datei `/etc/fail2ban/jail.local` und fügen Sie folgende Einstellungen für den SSH-Dienst ein:
   ```
   [sshd]
   enabled = true
   maxretry = 3
   bantime = 6h
   findtime = 7d
   ```
   - `enabled = true`: Aktiviert den Schutz für SSH.
   - `maxretry = 3`: Nach 3 Fehlversuchen wird die IP gesperrt.
   - `bantime = 6h`: Die Sperre dauert 6 Stunden.
   - `findtime = 7d`: Die Fehlversuche werden über 7 Tage gezählt.

3. **Fail2ban neu starten, damit die Einstellungen aktiv werden:**
   ```bash
   systemctl restart fail2ban
   ```

**Erklärung der Befehle:**

- `apt install fail2ban`  
  Installiert das Programm Fail2ban, das Logdateien überwacht und bei zu vielen Fehlversuchen IP-Adressen sperrt.

- Konfiguration in `/etc/fail2ban/jail.local`  
  Hier legen Sie fest, wie viele Fehlversuche erlaubt sind, wie lange eine IP gesperrt wird und für welche Dienste der Schutz gilt.

- `systemctl restart fail2ban`  
  Startet den Dienst neu, damit die neuen Einstellungen übernommen werden.

**Zusätzliche Optionen für noch mehr Sicherheit:**

- **Benachrichtigung per E-Mail:**  
  Sie können Fail2ban so konfigurieren, dass Sie bei einer Sperrung eine E-Mail erhalten. Dazu die Option `action = %(action_mwl)s` in der Konfiguration setzen.

- **Whitelist für eigene IPs:**  
  Mit der Option `ignoreip = 127.0.0.1/8 ::1 <eigene-IP>` können Sie eigene oder vertrauenswürdige IPs von der Sperre ausnehmen.

- **Weitere Dienste schützen:**  
  Fail2ban kann nicht nur SSH, sondern auch andere Dienste wie Webserver, Mailserver oder FTP absichern. Dazu einfach weitere Abschnitte in der Konfiguration anlegen, z.B. `[apache-auth]`.

- **Sperrdauer und Fehlversuche anpassen:**  
  Sie können die Werte für `bantime` und `maxretry` individuell anpassen, um den Schutz noch strenger oder lockerer zu gestalten.

Mit diesen Einstellungen und Optionen machen Sie Ihr System deutlich widerstandsfähiger gegen automatisierte Angriffe und erhöhen die Sicherheit Ihrer Server-Logins spürbar.

---

## Aufgabe 11: CrowdSec nutzen

CrowdSec installieren und einrichten, um Ihr System aktiv vor Angriffen aus dem Internet zu schützen.

Es wird empfohlen, nach der Einrichtung des Systems CrowdSec zu installieren. CrowdSec ist ein modernes Open-Source-Sicherheitswerkzeug, das Angriffe wie Brute-Force, Port-Scans oder andere verdächtige Aktivitäten erkennt und automatisch abwehrt. Es nutzt dabei die Schwarmintelligenz vieler Nutzer: Erkennt ein CrowdSec-System einen Angreifer, werden dessen IP-Adressen mit der Community geteilt und können weltweit blockiert werden.

Viele Angriffe auf Server laufen automatisiert und betreffen oft viele Systeme gleichzeitig. Während klassische Tools wie Fail2ban nur lokal reagieren, bietet CrowdSec einen zusätzlichen Schutz durch die gemeinsame Auswertung von Angriffsmustern. So profitieren Sie von den Erfahrungen anderer Nutzer und können neue Bedrohungen schneller erkennen und abwehren.

Mit CrowdSec wird Ihr System nicht nur gegen bekannte Angriffe geschützt, sondern auch gegen neue, noch unbekannte Bedrohungen. Die automatische Blockierung verdächtiger IP-Adressen und die ständige Aktualisierung der Bedrohungsdatenbank machen Ihr System deutlich widerstandsfähiger gegen Angriffe aus dem Internet.

**Vorgehen (Beispiel):**

1. **CrowdSec installieren:**
   ```bash
   apt install crowdsec
   ```
   Installiert das Hauptprogramm.

2. **Firewall-Integration aktivieren (empfohlen):**
   ```bash
   apt install crowdsec-firewall-bouncer-iptables
   ```
   Damit kann CrowdSec Angreifer direkt über die Firewall blockieren.

3. **CrowdSec starten und Status prüfen:**
   ```bash
   systemctl enable --now crowdsec
   systemctl status crowdsec
   ```
   Aktiviert CrowdSec und prüft, ob der Dienst läuft.

4. **Web-Konsole (optional):**
   Sie können die CrowdSec-Konsole nutzen, um Angriffe und Statistiken zu überwachen:
   ```bash
   cscli dashboard setup
   ```
   Folgen Sie den Anweisungen im Terminal.

**Erklärung der Befehle:**

- `apt install crowdsec`  
  Installiert das Hauptprogramm CrowdSec, das Logdateien überwacht und Angriffe erkennt.

- `apt install crowdsec-firewall-bouncer-iptables`  
  Installiert das Modul, das erkannte Angreifer direkt über die Firewall blockiert.

- `systemctl enable --now crowdsec`  
  Startet CrowdSec und sorgt dafür, dass es beim Systemstart automatisch läuft.

- `systemctl status crowdsec`  
  Zeigt den aktuellen Status des CrowdSec-Dienstes an.

- `cscli dashboard setup`  
  Startet die Einrichtung der Web-Konsole zur Überwachung und Verwaltung von CrowdSec.

**Zusätzliche Optionen für noch mehr Sicherheit:**

- **Benachrichtigungen aktivieren:**  
  Sie können E-Mail-Benachrichtigungen oder Slack-Integrationen einrichten, um sofort über Angriffe informiert zu werden.

- **Weitere Bouncer installieren:**  
  Neben der Firewall-Integration gibt es Bouncer für NGINX, Apache, Cloudflare und andere Dienste, um Angreifer noch gezielter zu blockieren.

- **Eigene Regeln anlegen:**  
  Sie können eigene Erkennungsregeln (Parsers und Szenarien) definieren, um spezielle Angriffe auf Ihre Anwendungen zu erkennen.

- **Regelmäßige Updates:**  
  Halten Sie CrowdSec und die Szenarien aktuell, um immer gegen neue Angriffsmuster geschützt zu sein:
  ```bash
  cscli collections upgrade
  cscli scenarios upgrade
  ```

Mit diesen Maßnahmen machen Sie Ihr System fit gegen aktuelle und zukünftige Angriffe und profitieren von der weltweiten CrowdSec-Community.

## Aufgabe 12: Zwei-Faktor-Authentifizierung (2FA) für SSH

Die Zwei-Faktor-Authentifizierung (2FA) für den SSH-Zugang aktivieren, um den Zugriff auf den Server noch besser abzusichern.

Es wird empfohlen, den SSH-Zugang zusätzlich zur normalen Passwort- oder Schlüssel-Authentifizierung mit einer zweiten Sicherheitsstufe zu schützen. Mit 2FA müssen sich Nutzer nicht nur mit ihrem Passwort oder Schlüssel anmelden, sondern zusätzlich einen Einmal-Code eingeben, der z.B. auf dem Smartphone generiert wird.

Selbst wenn ein Angreifer das Passwort oder den SSH-Schlüssel eines Benutzers herausfindet, reicht das allein nicht mehr aus, um Zugriff auf den Server zu bekommen. Der zweite Faktor – meist ein zeitlich begrenzter Code – wird auf einem separaten Gerät erzeugt und ist nur kurz gültig. So wird das Risiko durch gestohlene Zugangsdaten deutlich reduziert.

Mit Zwei-Faktor-Authentifizierung machen Sie es Angreifern extrem schwer, sich unbefugt Zugang zu Ihrem System zu verschaffen. Selbst bei erfolgreichen Phishing-Angriffen oder Datenlecks bleibt der Server geschützt, weil der zweite Faktor fehlt. Damit erhöhen Sie die Sicherheit Ihres Servers erheblich, besonders wenn dieser aus dem Internet erreichbar ist.

**Vorgehen (Beispiel):**

1. **Google Authenticator installieren:**
   ```bash
   apt install libpam-google-authenticator
   ```
   Installiert das benötigte Paket für die Zwei-Faktor-Authentifizierung.

2. **Für den gewünschten Benutzer einrichten:**
   ```bash
   su - max
   google-authenticator
   ```
   Folgen Sie dem Dialog, scannen Sie den QR-Code mit einer Authenticator-App (z.B. Google Authenticator oder FreeOTP) und notieren Sie die angezeigten Notfallcodes.

3. **SSH-Konfiguration anpassen:**  
   Öffnen Sie die Datei `/etc/pam.d/sshd` und fügen Sie am Ende folgende Zeile ein:
   ```
   auth required pam_google_authenticator.so
   ```
   Öffnen Sie dann `/etc/ssh/sshd_config` und setzen Sie:
   ```
   ChallengeResponseAuthentication yes
   ```
   Starten Sie den SSH-Dienst neu:
   ```bash
   systemctl restart sshd
   ```

**Erklärung der Befehle:**

- `apt install libpam-google-authenticator`  
  Installiert das Programm, das die Zwei-Faktor-Authentifizierung für SSH ermöglicht.

- `google-authenticator`  
  Startet die Einrichtung für den aktuellen Benutzer. Es wird ein QR-Code angezeigt, den Sie mit einer App auf Ihrem Smartphone scannen. Danach erhalten Sie Einmal-Codes für die Anmeldung.

- Eintrag in `/etc/pam.d/sshd`  
  Aktiviert die Abfrage des zweiten Faktors bei der SSH-Anmeldung.

- Einstellung in `/etc/ssh/sshd_config`  
  Mit `ChallengeResponseAuthentication yes` erlauben Sie die Abfrage von Einmal-Codes.

- `systemctl restart sshd`  
  Startet den SSH-Dienst neu, damit die Änderungen wirksam werden.

**Zusätzliche Optionen für noch mehr Sicherheit:**

- **Backup-Codes sicher aufbewahren:**  
  Notieren Sie die Einmal-Notfallcodes, die bei der Einrichtung angezeigt werden, und bewahren Sie sie an einem sicheren Ort auf.

- **2FA für mehrere Benutzer einrichten:**  
  Wiederholen Sie die Einrichtung für alle Benutzer, die sich per SSH anmelden dürfen.

- **Hardware-Token nutzen:**  
  Alternativ können Sie mit `pam-u2f` auch einen USB-Sicherheitsschlüssel (z.B. YubiKey) als zweiten Faktor verwenden.

Mit diesen Maßnahmen ist Ihr SSH-Zugang optimal gegen unbefugte Zugriffe geschützt – selbst wenn ein Passwort oder Schlüssel in falsche Hände gerät.

---

## Aufgabe 13: DDoS-Schutz aktivieren

DDoS-Schutz aktivieren, um den Server vor massenhaften Anfragen und Verbindungsversuchen zu schützen.

Es wird empfohlen, direkt nach der Einrichtung des Systems spezielle Netzwerkregeln gegen DDoS-Angriffe (Distributed Denial of Service) zu setzen. So verhindern Sie, dass Ihr Server durch zu viele gleichzeitige Anfragen oder Verbindungsversuche überlastet und dadurch nicht mehr erreichbar wird.

DDoS-Angriffe sind eine häufige Methode, um Server gezielt lahmzulegen. Dabei senden viele Rechner gleichzeitig eine große Menge an Daten oder Verbindungsanfragen an Ihr System. Ohne Schutzmechanismen kann Ihr Server dadurch überlastet werden und Dienste stehen nicht mehr zur Verfügung. Mit gezielten Regeln können Sie solche Angriffe frühzeitig erkennen und abwehren.

Durch das Setzen von Limits für Verbindungen und das Blockieren verdächtiger oder ungewöhnlicher Netzwerkpakete wird Ihr System widerstandsfähiger gegen Überlastungsangriffe. So bleibt Ihr Server auch bei Angriffen aus dem Internet erreichbar und wichtige Dienste werden geschützt.

**Vorgehen (Beispiel):**

1. **iptables-Regeln setzen:**  
   Sie können mit iptables bestimmte Netzwerkregeln einrichten, die z.B. die Anzahl der Verbindungen pro Sekunde begrenzen:
   ```bash
   iptables -A INPUT -p udp -m limit --limit 150/s -j ACCEPT
   iptables -A INPUT -p udp -j DROP
   ```
   Damit werden maximal 150 UDP-Pakete pro Sekunde akzeptiert, alles darüber wird verworfen.

2. **Weitere Regeln nach Bedarf:**  
   Sie können zusätzliche Regeln für andere Protokolle oder Ports hinzufügen, um den Schutz weiter zu erhöhen.

**Erklärung der Befehle:**

- `iptables -A INPUT -p udp -m limit --limit 150/s -j ACCEPT`  
  Erlaubt maximal 150 UDP-Pakete pro Sekunde. Alles, was darüber hinausgeht, wird blockiert.

- `iptables -A INPUT -p udp -j DROP`  
  Verwirft alle weiteren UDP-Pakete, die das Limit überschreiten.

**Zusätzliche Optionen für noch mehr Sicherheit:**

- **Limits für andere Protokolle setzen:**  
  Sie können ähnliche Regeln auch für TCP oder bestimmte Ports anwenden, z.B.:
  ```bash
  iptables -A INPUT -p tcp --syn -m limit --limit 30/s -j ACCEPT
  iptables -A INPUT -p tcp --syn -j DROP
  ```

- **Ungültige oder verdächtige Pakete blockieren:**  
  Blockieren Sie Pakete mit ungewöhnlichen Flags oder von verdächtigen Quellen.

- **Kernel-Schutzmechanismen aktivieren:**  
  Aktivieren Sie zusätzliche Schutzfunktionen im Kernel, z.B. SYN-Cookies:
  ```bash
  sysctl -w net.ipv4.tcp_syncookies=1
  ```

- **Monitoring und Logging:**  
  Überwachen Sie die Netzwerkaktivität und protokollieren Sie verdächtige Zugriffe, um Angriffe frühzeitig zu erkennen.

Mit diesen Maßnahmen erhöhen Sie die Widerstandsfähigkeit Ihres Systems gegen DDoS-Angriffe und sorgen dafür, dass Ihr Server auch unter hoher Last erreichbar bleibt.

---

## Aufgabe 14: IP-Spoofing-Schutz aktivieren

IP-Spoofing-Schutz aktivieren, indem Sie Reverse Path Filtering und bestimmte Kernel-Optionen setzen.

Es wird empfohlen, den Schutz gegen IP-Spoofing direkt nach der Einrichtung des Systems zu aktivieren. So verhindern Sie, dass Angreifer gefälschte IP-Adressen nutzen, um sich unberechtigt Zugriff auf Ihr System zu verschaffen oder Angriffe zu verschleiern.

IP-Spoofing bezeichnet das Fälschen von IP-Adressen in Netzwerkpaketen. Angreifer können so ihre wahre Identität verbergen oder versuchen, Sicherheitsmechanismen zu umgehen. Ohne Schutzmaßnahmen könnten solche Pakete Ihr System erreichen und Schaden anrichten. Reverse Path Filtering prüft, ob eingehende Pakete tatsächlich von der richtigen Richtung kommen, und blockiert gefälschte Pakete.

Durch das Aktivieren von Reverse Path Filtering und das Setzen weiterer Kernel-Optionen wird Ihr System widerstandsfähiger gegen Angriffe, bei denen IP-Adressen gefälscht werden. So werden viele typische Angriffsversuche frühzeitig erkannt und blockiert, bevor sie Schaden anrichten können.

**Vorgehen (Beispiel):**

1. Öffnen Sie die Datei `/etc/sysctl.conf` und ergänzen Sie folgende Zeilen:
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
   Diese Einstellungen sorgen dafür, dass gefälschte Pakete erkannt und abgewiesen werden.

2. Übernehmen Sie die Einstellungen sofort mit:
   ```bash
   sysctl -p
   ```

**Erklärung der Befehle:**

- Einträge in `/etc/sysctl.conf`  
  Hier werden die Kernel-Optionen dauerhaft gesetzt.  
  - `rp_filter=1`: Aktiviert Reverse Path Filtering, prüft die Herkunft von Paketen.
  - `accept_source_route=0`: Verhindert, dass Pakete mit manipulierten Routen akzeptiert werden.
  - `accept_redirects=0` und `send_redirects=0`: Blockieren das Akzeptieren und Senden von Weiterleitungsanweisungen, die von Angreifern missbraucht werden könnten.

- `sysctl -p`  
  Übernimmt alle Einstellungen aus der Datei `/etc/sysctl.conf` sofort, ohne dass ein Neustart nötig ist.

**Zusätzliche Optionen für noch mehr Sicherheit:**

- **Weitere Kernel-Optionen setzen:**  
  Sie können zusätzliche Einstellungen wie `net.ipv4.conf.all.log_martians=1` aktivieren, um verdächtige Pakete zu protokollieren:
  ```bash
  echo "net.ipv4.conf.all.log_martians=1" >> /etc/sysctl.conf
  sysctl -p
  ```

- **Firewall-Regeln ergänzen:**  
  Ergänzen Sie Ihre Firewall-Regeln, um Pakete mit ungültigen oder privaten Quelladressen zu blockieren.

- **Regelmäßige Überprüfung:**  
  Kontrollieren Sie regelmäßig mit `sysctl -a | grep rp_filter`, ob die Einstellungen aktiv sind.

Mit diesen Maßnahmen schützen Sie Ihr System effektiv vor Angriffen, bei denen IP-Adressen gefälscht werden, und erhöhen die Netzwerksicherheit Ihres Containers deutlich.

---

## Aufgabe 15: ARP-Spoofing-Schutz aktivieren

Statischen ARP-Spoofing-Schutz aktivieren, indem Sie feste ARP-Einträge für wichtige Netzwerkgeräte setzen.

Es wird empfohlen, nach der Einrichtung des Systems statische ARP-Einträge für zentrale Netzwerkgeräte (wie Router oder wichtige Server) zu setzen. So verhindern Sie, dass Angreifer gefälschte ARP-Antworten ins Netzwerk senden und damit den Datenverkehr umleiten oder mitlesen können.

Beim sogenannten ARP-Spoofing geben sich Angreifer im lokalen Netzwerk als ein anderes Gerät aus, indem sie gefälschte ARP-Antworten verschicken. Dadurch kann der Datenverkehr umgeleitet, mitgelesen oder sogar manipuliert werden. Ohne Schutzmaßnahmen ist jedes Gerät im lokalen Netz potenziell angreifbar, da ARP standardmäßig keine Authentifizierung vorsieht.

Durch das Setzen statischer ARP-Einträge stellen Sie sicher, dass Ihr System nur mit den echten, bekannten Geräten im Netzwerk kommuniziert. Gefälschte ARP-Antworten werden ignoriert, und Angreifer können den Datenverkehr nicht mehr so einfach umleiten oder abfangen. Das erhöht die Sicherheit Ihres Containers oder Servers deutlich, besonders in gemeinsam genutzten Netzwerken.

**Vorgehen (Beispiel):**

1. **MAC-Adresse und IP der Netzwerkkarte ermitteln:**
   ```bash
   ip link show
   ip addr show
   ```
   Mit diesen Befehlen finden Sie heraus, wie Ihre Netzwerkkarte heißt (z.B. `eth0`) und welche IP- und MAC-Adresse sie hat.

2. **Statischen ARP-Eintrag setzen:**
   ```bash
   arp -i eth0 -s 192.168.1.1 aa:bb:cc:dd:ee:ff
   ```
   Dieser Befehl sorgt dafür, dass Ihr System die IP-Adresse `192.168.1.1` immer mit der MAC-Adresse `aa:bb:cc:dd:ee:ff` verknüpft – und keine anderen ARP-Antworten für diese IP akzeptiert.

3. **Automatisierung:**  
   Damit der Eintrag nach einem Neustart erhalten bleibt, tragen Sie den Befehl in ein Skript wie `/etc/network/if-up.d/add-my-static-arp` ein und machen es ausführbar:
   ```bash
   echo "arp -i eth0 -s 192.168.1.1 aa:bb:cc:dd:ee:ff" > /etc/network/if-up.d/add-my-static-arp
   chmod +x /etc/network/if-up.d/add-my-static-arp
   ```

**Erklärung der Befehle:**

- `ip link show`  
  Zeigt alle Netzwerkschnittstellen und deren MAC-Adressen an.

- `ip addr show`  
  Zeigt alle IP-Adressen der Netzwerkschnittstellen an.

- `arp -i <interface> -s <ip> <mac>`  
  Setzt einen statischen ARP-Eintrag für das angegebene Interface, die IP-Adresse und die zugehörige MAC-Adresse.

- Eintrag in `/etc/network/if-up.d/`  
  Skripte in diesem Verzeichnis werden automatisch beim Hochfahren des Netzwerks ausgeführt. So bleibt der Schutz auch nach einem Neustart aktiv.

**Zusätzliche Optionen für noch mehr Sicherheit:**

- **Mehrere statische ARP-Einträge:**  
  Sie können für alle wichtigen Geräte im Netzwerk (z.B. Gateway, DNS-Server) statische Einträge setzen.

- **ARP-Überwachung:**  
  Mit Tools wie `arpwatch` können Sie ungewöhnliche Änderungen in der ARP-Tabelle überwachen und sich benachrichtigen lassen.

- **Firewall-Regeln ergänzen:**  
  Ergänzen Sie Ihre Firewall-Regeln, um verdächtige ARP-Pakete zu blockieren oder zu protokollieren.

Mit diesen Maßnahmen machen Sie es Angreifern deutlich schwerer, den Netzwerkverkehr umzuleiten oder mitzulesen, und erhöhen die Sicherheit Ihres Systems im lokalen Netzwerk.

---

## Aufgabe 16: Automatische Überwachung und Alarmierung

Automatische Überwachung und Alarmierung einrichten, damit Angriffe oder Auffälligkeiten auf dem System frühzeitig erkannt werden.

Es wird empfohlen, nach der Einrichtung des Systems Tools wie `logwatch`, `rkhunter` oder ein zentrales Monitoring (z.B. mit Zabbix oder Prometheus) zu installieren. Diese Programme überwachen das System automatisch und informieren Sie, wenn ungewöhnliche Aktivitäten oder mögliche Angriffe erkannt werden.

Viele Angriffe oder Probleme bleiben oft unbemerkt, wenn sie nicht aktiv überwacht werden. Ohne Überwachung kann es passieren, dass Sie erst sehr spät von einem Angriff, einem Einbruch oder einem technischen Problem erfahren – oft erst, wenn bereits Schaden entstanden ist. Mit automatischer Überwachung werden Sie rechtzeitig gewarnt und können schnell reagieren.

Durch die automatische Analyse von Logdateien, Systemzustand und verdächtigen Aktivitäten werden Angriffe, Fehler oder Manipulationen frühzeitig erkannt. Alarmierungen per E-Mail oder im Monitoring-Dashboard helfen, sofort Maßnahmen zu ergreifen. So bleibt Ihr System sicher und Sie behalten jederzeit den Überblick.

**Vorgehen (Beispiel):**

1. **Logwatch installieren und konfigurieren:**
   ```bash
   apt install logwatch
   ```
   Logwatch analysiert täglich die Logdateien und schickt Ihnen eine Zusammenfassung per E-Mail.

2. **Rootkit Hunter installieren:**
   ```bash
   apt install rkhunter
   rkhunter --update
   rkhunter --check
   ```
   `rkhunter` prüft das System regelmäßig auf bekannte Rootkits und meldet verdächtige Funde.

3. **Zentrales Monitoring einrichten (optional):**
   - Installieren Sie einen Agenten wie `zabbix-agent` oder `node_exporter` und verbinden Sie Ihr System mit einer Monitoring-Lösung wie Zabbix oder Prometheus.
   - So können Sie viele Systeme zentral überwachen und erhalten bei Problemen sofort eine Benachrichtigung.

**Erklärung der Befehle:**

- `apt install logwatch`  
  Installiert das Tool Logwatch, das Logdateien auswertet und Berichte erstellt.

- `apt install rkhunter`  
  Installiert Rootkit Hunter, ein Programm zur Erkennung von Rootkits und verdächtigen Dateien.

- `rkhunter --update`  
  Aktualisiert die Datenbank von rkhunter auf den neuesten Stand.

- `rkhunter --check`  
  Startet eine Überprüfung des Systems auf Rootkits.

- **Monitoring-Agenten wie `zabbix-agent` oder `node_exporter`**  
  Diese Programme senden Systemdaten an eine zentrale Überwachungsplattform.

**Zusätzliche Optionen für noch mehr Sicherheit:**

- **E-Mail-Benachrichtigungen einrichten:**  
  Konfigurieren Sie Logwatch und rkhunter so, dass Sie Berichte und Warnungen per E-Mail erhalten.

- **Weitere Überwachungstools nutzen:**  
  Programme wie `fail2ban`, `auditd` oder `ossec` bieten zusätzliche Schutz- und Überwachungsfunktionen.

- **Regelmäßige Auswertung der Berichte:**  
  Prüfen Sie die Berichte regelmäßig und reagieren Sie auf Warnungen, um Probleme frühzeitig zu beheben.

Mit diesen Maßnahmen erkennen Sie Angriffe und Probleme frühzeitig und können Ihr System gezielt schützen und stabil betreiben.

---

## Aufgabe 17: Regelmäßige Backups

Ein automatisiertes Backup-Konzept (z.B. mit rsnapshot, borg, restic) schützt vor Datenverlust und Ransomware.

---

## Aufgabe 18: Dateisystem- und Rechtehärtung

Zusätzliche Maßnahmen wie das Setzen restriktiver Rechte auf sensible Dateien (chmod, chown), das Deaktivieren von nicht benötigten Systemdiensten und das Verwenden von AppArmor oder SELinux erhöhen die Sicherheit weiter.

---

## Aufgabe 19: Verwendung von sicheren Protokollen

Unsichere Dienste wie FTP, Telnet oder unverschlüsseltes HTTP sollten konsequent deaktiviert oder durch sichere Alternativen (SFTP, HTTPS) ersetzt werden.

---

## Aufgabe 20: Regelmäßige Überprüfung offener Ports

Mit Tools wie nmap oder netstat kann regelmäßig geprüft werden, ob nur die gewünschten Ports offen sind.

---

## Aufgabe 21: Bash Prompt anpassen

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
