#! /bin/bash
# ---------------------------------------------------------------------------
# Allgemeine Informationen:
# Dieses Skript automatisiert die Ersteinrichtung und Härtung von Linux-
# Servern. Es richtet sich speziell an die Nutzer von Proxmox-VMs/LXC, 
# ist aber auch für Debian-Systeme geeignet.
# Ziel ist ein sicherer, wartbarer und sofort produktiver Serverbetrieb nach 
# Abschluss.
#
# Voraussetzungen: 
# Das Skript muss mit Root-Rechten ausgeführt werden. Die Software 'dialog' 
# muss installiert sein (wird bei Bedarf automatisch nach installiert).
#
# Funktionsumfang:
# - Systemaktualisierung und automatisierte Updates per Cronjob einrichten.
# - Installation empfohlener Softwarepakete über eine Auswahlmaske.
# - Anpassung des Tastaturlayouts und der Systemzeitzone.
# - Anlegen eines administrativen Benutzers mit sicheren Einstellungen.
# - Vergabe und Änderung des Hostnamens für IPv4 und IPv6.
# - Absicherung des SSH-Logins (z.B. Public-Key, Timeout, Nutzerbeschränkung).
# - Einrichtung und Konfiguration einer Firewall mit Portauswahl.
# - Schutz des Logins (CLI/SSH) durch Fail2ban.
# - Aktivierung von DDoS-, IP-Spoofing- und ARP-Spoofing-Schutzmechanismen.
# - Anpassung des Bash-Prompts für Benutzer (farbig, informativ).
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Globale Konstanten
# ---------------------------------------------------------------------------
# Text Konstanten: Anwendungstitel
APP_TITLE="PROXMOX Tool's - Ersteinrichtung VM/LXC"
GAUGE_TITLE="< Fortschritt >"
ERR_TITLE="< Fehler >"
YES_LABEL="OK"
CANCEL_LABEL="Abbrechen"

# Text Konstanten: Fenstertitel
txTITLE_00="< Schritt "

# Text Konstanten: Fehlertexte ----------------------------------------------
txERR_0000="Script mit 'root' Rechten gestartet"
txERR_0001="FEHLER: Nicht ausreichende Benutzerrechte"
txERR_0002="Versuchen Sie das Script erneut mit 'root' Rechten auszuführen (sudo)"
txERR_0003="FEHLER: Fehlende Software, 'dialog' wird benötigt"
txERR_0004="Das fehlende Software Pakete wurden nach installiert. Starten Sie das Script neu"

# Text Konstanten: Hinweistexte ---------------------------------------------
txSTP_0001="\nJetzt ausfuehren?"
txSTP_0002="\nHinweis: Mit den 'Pfeiltasten' Zeile hoch/runter, mit 'Leertaste' an/aus und mit 'Tab' weiter gehen."
txSTP_0003="\nHinweis: Mit 'Tab' selektieren, 'Pfeil auf/ab' ändern oder im Feld direkt eingeben."
txSTP_0004="\nHinweis: Nur Buchstaben, keine Leer- oder Sonderzeichen!"
txSTP_0005="\nHinweis: Nur Buchstaben und Ziffern, keine Leer- oder Sonderzeichen!"

# Text Konstanten: Logtexte -------------------------------------------------
txLOG_0001="Paket '"
txLOG_0002="' bereits installiert"
txLOG_0003="' installiert" 
txLOG_0004="' nicht installiert" 

# Schritttexte
# Step 1: Update System -----------------------------------------------------
txTITLE_01=" - System aktualisieren >"
txSTP_0101="\nPaketquellen und Paketlisten sind wichtig um das System sicher und stabil zu halten.\n\nEine Aktualisierung jetzt vornehmen?\n"
txLOG_0100="Abbruch - System nicht aktualisiert"
txLOG_0101="Paketquellen aktualisiert"
txLOG_0102="Fehler - Paketquellen nicht aktualisiert"
txLOG_0103="System aktualisiert"
txLOG_0104="Fehler - System nicht aktualisiert"
txLOG_0105="Nicht mehr benötigte Pakete gelöscht"
txLOG_0106="Fehler - Nicht mehr benötigte Pakete nicht gelöscht"

# Step 2: Automatisches Update einrichten -----------------------------------
txTITLE_02=" - Automatische Updates >"
txSTP_0201="\nServer Systeme laufen meist 24/7. Um das System automatisch aktuell zu halten, kann das Programm einen 'cronjob' zur Aktualisierung des System anlegen.\n"
txPART0201="\nAn welchem Wochentag soll das automatische Update starten?\n" 
txPART0202="\nUm welche Uhrzeit soll das automatische Update gestartet werden?\n" 
txLOG_0200="Abbruch - Automatisches Update nicht eingerichtet"
txLOG_0202="Fehler - Cron Job konnte nicht eingerichtet werden"
txLOG_0203="Abbruch - Cron Job Einrichtung durch Nutzer abgebrochen oder Cron Job bereits vorhanden"
txLOG_0204="Abbruch - Cron Job Einrichtung durch Nutzer abgebrochen"

# Step 3: Empfohlene Software Pakete installieren ---------------------------
txTITLE_03=" - Empfohlen Software >"
txSTP_0301="\nUm die Bedienung zu erleichtern, wird empfohlen, einige Softwarepakete zu installieren.\nBitte ankreuzen, welche Software verwendet werden soll.\n"
txPART0301="Empfohlene Software installieren"
txPART0302="Installiere '"
txPART0303="' ..."
txPART0304="Software Installation abgeschlossen"
txLOG_0300="Abbruch - Empfohlen Software nicht installiert"

# Step 4: Tastatuslayout anpassen -------------------------------------------
txTITLE_04=" - Spracheinstellung >"
txSTP_0401="\nDas Tastatur Layout ist wichtig. Nichts ist schlimmer, als ein Backslash oder einen Doppelpunkt auf der Tastatur zu suchen.\n"
txLOG_0400="Abbruch - Tastatur Layout nicht geändert"
txLOG_0401="Aktivierte Locales:"
txLOG_0402="Aktuelle System-Locale:"
txLOG_0403="Fehler - Tastatur Layout nicht geändert"

# Step 5: Zeitzone/Time Server einrichten -----------------------------------
txTITLE_05=" - Zeitzone/Synchronisation >"
txSTP_0501="\nServerdienste sind meistens zeitkritisch. Es ist also wichtig, das der Server immer die richtige Zeit kennt.\nSie können die Zeitzone anpassen und den 'ntp' Dienst installieren?\n"
txPART0502="Einstellungen vornehmen ..."
txPART0503="Zeitzone auf '"
txPART0504="' setzen ..."
txPART0505="Installiere '"
txPART0506="' ..."
txPART0507="Einstellungen vorgenommen!"
txLOG_0500="Abbruch - Zeitzone nicht geändert"
txLOG_0501="Zeitzone auf '"
txLOG_0502="' gesetzt"
txLOG_0503="Fehler - Zeitzone nicht geändert" 

# Step 6: Adminstrativer Benutzer anlegen -----------------------------------
txTITLE_06=" - Administrativer Benutzer >"
txSTP_0601="\nEs wird nicht empfohlen, als 'root' auf einem System zu arbeiten. Sollte noch kein administativer User angelegt worden sein, legen Sie jetzt einen an.\n"
txSTP_0602="\nAktuell gibt es auf dem System die folgenden User:\n"
txPART0601="\nGeben Sie einen Benutzernamen, ein Passwort und den vollständigen Namen des Nutzer an!\n"
txPART0602="\nAlle Felder muessen ausgefuellt werden!\n"
txPART0603="Lege Benutzer '"
txPART0604="' an ..."
txPART0605="Setze Passwort von Benutzer '"
txPART0606="' ..."
txPART0607="Füge Benutzer '"
txPART0608="' zur Gruppe sudo hinzu ..."
txPART0609="Benutzer '"
txPART0610="' angelegt und der Gruppe 'sudo' zugeordnet."
txERR_0600="Abbruch - Nicht alle Felder ausgefüllt"
txERR_0601="\n\Z1Fehler!\nBenutzer mit dem Benutzernamen '"
txERR_0602="' konnte nicht angelegt werden!\Zn\n"
txERR_0603="\n\Z1Fehler!\nDas Passwort für den Benutzer "
txERR_0604=" konnte nicht gesetzt werden\Zn\n"
txERR_0605="\n\Z1Fehler!\nDer Benutzer "
txERR_0606=" konnte nicht der Gruppe 'sudo' zugordnet werden\Zn\n"
txLOG_0601="Fehler - Nutzer konnte nicht angelegt werden"
txLOG_0602="Fehler - Passwort konnte nicht gesetzt werden"
txLOG_0603="Fehler - Nutzer konnte nicht der Gruppe 'sudo' hinzugefügt werden"
txLOG_0604="Benutzer '"
txLOG_0605="' erfolgreich angelegt und der Gruppe 'sudo' zugeordnet."
txLOG_0606="Abbruch - Dialog Dateneingabe abgebrochen"

# Step 7: SSH Login absichern -----------------------------------------------
txTITLE_07=" - SSH Login absichern >"
txSTP_0701="\nUm eine 'ssh' Verbindung abzusichern, kann ein 'root' Login unterbunden, eine Authentifizierung mit 'pulic key' statt Username/Passwort gefordert und die Sitzung automatisch beendet werden.\n"
txSTP_0702="\nWelche dieser Absicherungen wollen Sie vornehmen?\n"
txSTP_0703="\nWelcher Nutzer soll einen Zugang per 'ssh' eingerichtet bekommen!\n"
txPART0701="Anmelden als '%s' ..."
txPART0702="Rechte kontrolieren von Ordner "
txPART0703="Ordner anlegen "
txPART0704="Neuen ssh key generieren ..."
txPART0705="Es existiert schon ein ssh key. Verwende diesen ..."
txPART0706="Schlüssel veröffentlichen ..."
txPART0707="ssh Konfiguration sichern ..."
txPART0708="ssh Konfiguration für Login mit shhkey anpassen ..."
txPART0709="Schlüssel erfolgreich angelegt ..."
txPART0710="Sitzung automatisch abbrechen einrichten ..."
txPART0711="Sitzung automatisch abbrechen angelegt ..."
txPART0712="Zugang nur für User '"
txPART0713="' erlauben ..."
txPART0714="Zugang nur für User '" 
txPART0715="' eingerichtet ..."
txPART0716="Service 'ssh' wird neu gestartet ..."
txLOG_0700="Abbruch - 'ssh' Zugang nicht abgesichert"
txLOG_0701="Abbruch - Dialog SSH-User Auswahl abgebrochen"

# Step 8: Firewall einrichten -----------------------------------------------
txTITLE_08=" - Firewall installieren/aktivieren >"
txSTP_0801="\nServer kommunizieren per UDP- oder TCP-Protokoll und Ports. Ungenutzte offene Ports sind oft eine Ursache für unsichere Syteme. Eine Firewall ist daher wichtig, um den Server abzusichern.\n"
txSTP_0802="\nDie Firewall jetzt aktivieren und je nach angebotenen Service, Auswahl der erreichbaren Ports.\n"
txPART0801="Firewall installieren/einrichten ..."
txPART0802="Firewall installieren ..."
txPART0803="Alle einghenden Verbindungen blockieren ..."
txPART0804="Alle ausgehenden Verbindungen erlauben ..."
txPART0805="Konfiguriere Port '"
txPART0806="' ..."
txPART0807="Firewall bei Systemstart automatisch starten ..."
txPART0808="Geänderte Firewall Einstellungen neu laden ..."
txPART0809="Firewall erfolgreich aktiviert!"
txLOG_0800="Abbruch - Firewall nicht installiert/einrgerichtet"
txLOG_0801="\nDie Firewall wurde auf diesem System erfolgreich aktiviert!"
txLOG_0802="\nFolgende Ports geöffnet:"

# Step 9: Login absichern ---------------------------------------------------
txTITLE_09=" - Login absichern >"
txSTP_0901="\nUm Ihr System abzusichern, kann jeder wiederholt fehlgeschlagene Anmeldeversuche automatisch zur Sperrung der betreffenden IP-Adresse fuehren.\n\nDiese Schutzfunktion jetzt aktivieren?\n"
txPART0901="Einstellungen vornehmen ..."
txPART0902="Login '"
txPART0903="' absichern ..."
txPART0904="Login abgesichert!"
txLOG_0900="Abbruch - Login nicht abgesichert"
txLOG_0901="Fail2ban: Einrichtung Jail '"
txLOG_0902="' erfolgreich eingerichtet"
txLOG_0903="' fehlgeschlagen"

# Step 10: Hostname vergeben ------------------------------------------------
txTITLE_10=" - Hostname vergeben >"
txSTP_1001="\nEin Hostname sollte eingerichtet werden, weil er den Rechner im Netzwerk eindeutig identifiziert.\n\nDas erleichtert die Verwaltung, das Auffinden und die Kommunikation zwischen den Rechnern.\n\nEin sinnvoller Hostname verbessert Struktur, Zuordnung und Sicherheit – besonders in Netzwerken mit mehreren Systemen.\n"
txPART1001="\nAktuell sind folgende Hostnamen auf dem System eingerichtet:\n---------------------------- IPv4 ----------------------------"
txPART1002="\nNetzwerkkarte: "
txPART1003="\nHostname(n)..: "
txPART1004="\n---------------------------- IPv6 ----------------------------"
txPART1005="\n\nFür welche Adresse soll ein Hostname festgelegt werden?\n"
txPART1006="Bitte die neuen Hostnamen eingeben:"
txPART1007="Hostname(IPv4):"
txPART1008="Hostname(IPv6):"
txPART1009="Hostname Change - Prozess wurde gestartet ..."
txPART1010="Schritt 1/2: Hostname IPv4 setzen ..."
txPART1011="Schritt 1/2: Hostname IPv4 erfolgreich gesetzt ..."
txPART1012="Schritt 2/2: Hostname IPv6 setzen ..."
txPART1013="Schritt 2/2: Hostname IPv6 erfolgreich gesetzt ..."
txPART1014="Hostnamen (IPv4 und IPv6) erfolgreich gesetzt ..."
txLOG_1000="Abbruch - Hostname nicht geändert"
txLOG_1001="Hostname (IPv4) geändert von "
txLOG_1002="Hostname (IPv6) geändert von "
txLOG_1003=" zu "

# Step 11: DDoS-Schutz aktivieren -----------------------------------------
txTITLE_11=" - DDoS-Schutz aktivieren >"
txSTP_1101="\nDDoS-Angriffe (Distributed Denial of Service) legen Server durch massenhafte Anfragen oder Verbindungsversuche lahm.\n\nDurch die folgenden Einstellungen wird Ihr System wirksam gegen typische DDoS-Angriffe auf Netzwerkebene abgesichert.\n\n- Paket- und Verbindungs-Limits\n- Schutz vor Verbindungsfluten (Floods)\n- Blockieren verdächtiger Pakete\n- Aktivierung von Kernel-Schutzmechanismen\n\nDDoS-Schutz jetzt aktivieren?\n"
txPART1100="DDoS-Schutz wird aktiviert..."
txPART1101="Ungültige Verbindungen verwerfen..."
txPART1102="Neue TCP-Verbindungen ohne SYN-Flag verwerfen..."
txPART1103="TCP mit ungewöhnlicher MSS verwerfen..."
txPART1104="Illegale TCP-Flags verwerfen..."
txPART1105="Verdächtige TCP-Flags verwerfen..."
txPART1106="Fragmentierte Pakete verwerfen..."
txPART1107="UDP Flood-Limit setzen..."
txPART1108="DNS UDP nur für bestehende Verbindungen erlauben..."
txPART1109="Flood-Schutz für SSH, HTTP, HTTPS..."
txPART1110="Kernel-Schutzmechanismen aktivieren..."
txPART1111="DDoS-Schutz abgeschlossen."
txLOG_1100="Abbruch - DDoS-Schutz nicht aktiviert"
txLOG_1101="DDoS: INVALID Pakete verworfen"
txLOG_1102="DDoS: TCP ohne SYN verworfen"
txLOG_1103="DDoS: TCP ungewöhnliche MSS verworfen"
txLOG_1104="DDoS: Illegale TCP-Flags verworfen"
txLOG_1105="DDoS: Verdächtige TCP-Flags verworfen"
txLOG_1106="DDoS: Fragmentierte Pakete verworfen"
txLOG_1107="DDoS: UDP Flood-Limit gesetzt"
txLOG_1108="DDoS: DNS UDP nur für bestehende Verbindungen"
txLOG_1109="DDoS: Flood-Schutz für SSH/HTTP/HTTPS gesetzt"
txLOG_1110="DDoS: Kernel-Schutzmechanismen aktiviert"

# Step 12: IP-Spoofing-Schutz aktivieren ------------------------------------
txTITLE_12=" - IP-Spoofing-Schutz aktivieren >"
txSTP_1201="\nIP Spoofing bezeichnet das Fälschen von IP-Adressen, um sich unberechtigt Zugriff auf ein System zu verschaffen oder Angriffe zu verschleiern.\n\nMit den folgenden Einstellungen wird Ihr System gegen typische IP-Spoofing-Angriffe auf Netzwerkebene geschützt:\n\n- Aktivierung von Reverse Path Filtering\n- Blockieren von Paketen mit ungültigen Quelladressen\n- Stärkung der Kernel-Netzwerkoptionen\n\nIP-Spoofing-Schutz jetzt aktivieren?\n"
txPART1200="IP-Spoofing-Schutz wird aktiviert..."
txPART1201="Reverse Path Filtering aktivieren..."
txPART1202="Pakete mit ungültigen Quelladressen blockieren..."
txPART1203="Kernel-Netzwerkoptionen für Spoofing-Schutz setzen..."
txPART1204="IP-Spoofing-Schutz abgeschlossen."
txLOG_1200="Abbruch - IP-Spoofing-Schutz nicht aktiviert"
txLOG_1201="IP-Spoofing: Reverse Path Filtering aktiviert"
txLOG_1202="IP-Spoofing: Pakete mit ungültigen Quelladressen geblockt"
txLOG_1203="IP-Spoofing: Kernel-Netzwerkoptionen gesetzt"

# Step 13: ARP-Spoofing-Schutz aktivieren -----------------------------------
txTITLE_13=" - ARP-Spoofing-Schutz aktivieren >"
txSTP_1301="\nARP Spoofing ist ein Angriff, bei dem gefälschte ARP-Antworten ins Netzwerk gesendet werden, um den Datenverkehr umzuleiten oder mitzulesen.\n\nDurch das Setzen statischer ARP-Einträge für wichtige Netzwerkkomponenten kann dieser Angriff erschwert werden.\n\nMöchten Sie jetzt einen statischen ARP-Eintrag für Ihre Netzwerkkarte einrichten?\n"
txPART1301="ARP-Spoofing-Schutz wird aktiviert..."
txPART1302="Netzwerkinformationen werden ermittelt..."
txPART1303="Statischen ARP-Eintrag vorbereiten..."
txPART1304="Skript für statischen ARP-Eintrag wird erstellt..."
txPART1305="Skript ausführbar machen..."
txPART1306="ARP-Spoofing-Schutz abgeschlossen."
txLOG_1301="Abbruch - ARP-Spoofing-Schutz nicht aktiviert"
txLOG_1302="ARP-Spoofing: Netzwerkinformationen ermittelt"
txLOG_1303="ARP-Spoofing: ARP-Skript vorbereitet"
txLOG_1304="ARP-Spoofing: Skript erstellt"
txLOG_1305="ARP-Spoofing: Skript ausführbar gemacht"

# Step 14: Prompt anpassen --------------------------------------------------
txTITLE_14=" - Bash Prompt anpassen >" 
txSTP_1401="\nEin ansprechender und informativer Bash-Prompt kann die Arbeit am Server erleichtern.\n\nMöchten Sie den Prompt für alle Benutzer anpassen?\n"
txPART1403="Prompt-Konfiguration wird systemweit in /etc/bash.bashrc eingetragen (ersetzen)..."
txPART1404="Prompt-Konfiguration wird für neue User in /etc/skel/.bashrc eingetragen (ersetzen)..."
txPART1405="Prompt-Anpassung systemweit abgeschlossen."

txLOG_1401="Abbruch - Prompt-Anpassung nicht durchgeführt"
txLOG_1402="Prompt-Anpassung: Backup der /etc/bash.bashrc erstellt"
txLOG_1403="Prompt-Anpassung: Prompt-Konfiguration systemweit ersetzt"
txLOG_1404="Prompt-Anpassung: Prompt-Konfiguration für neue User ersetzt"

# Vorgaben
# Farbe fuer die Ausgabe einstellen
COLOR_ERR="\033[1;31m" # Fehler  (rot)
COLOR_SUC="\033[1;32m" # Erfolg  (grün)
COLOR_TIP="\033[1;33m" # Hinweis (gelb)
COLOR_RES="\033[0;39m" #normal
# Konfigurations Defaults
TIMEZONE="Europe/Berlin" # Zeitzone

# ===========================================================================
# Hilfsfunktionen
# ===========================================================================
LOG() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zur Erzeugung eines einfachen log mit Rotation und Komprimierung
    # -----------------------------------------------------------------------
    local LOG_PATH

    # Automatische Ermittlung des Log-Verzeichnisses ------------------------
    if [ -d "/var/log" ]; then
        LOG_PATH="/var/log"
    elif [ -d "/tmp" ]; then
        LOG_PATH="/tmp"
    else
        LOG_PATH="."
    fi

    local LOG_FILE="${LOG_PATH}/$(date "+%Y-%m-%d")_$(basename "$0" .sh).log"
    local MAX_ROTATE=5

    # Nur rotieren, wenn KEIN Text übergeben wird (LOG INIT) ----------------
    if [ -z "$1" ]; then
        # Logrotation und Komprimierung -------------------------------------
        # 1. Älteste Logdatei löschen ---------------------------------------
        if [ -f "${LOG_FILE}.${MAX_ROTATE}.gz" ]; then
            rm -f "${LOG_FILE}.${MAX_ROTATE}.gz"
        fi
        # .4.gz -> .5.gz, .3.gz -> .4.gz, ..., .2.gz -> .3.gz ---------------
        for ((i=MAX_ROTATE-1; i>=2; i--)); do
            if [ -f "${LOG_FILE}.${i}.gz" ]; then
                mv "${LOG_FILE}.${i}.gz" "${LOG_FILE}.$((i+1)).gz"
            fi
        done
        # .1 -> .2.gz (komprimieren) ----------------------------------------
        if [ -f "${LOG_FILE}.1" ]; then
            gzip -c "${LOG_FILE}.1" > "${LOG_FILE}.2.gz"
            rm -f "${LOG_FILE}.1"
        fi
        # Aktive Logdatei -> .1 (rotieren) ----------------------------------
        if [ -f "${LOG_FILE}" ]; then
            mv "${LOG_FILE}" "${LOG_FILE}.1"
        fi
        # Neue leere Logdatei anlegen, falls nicht vorhanden ----------------
        if [ ! -f "${LOG_FILE}" ]; then
            touch "${LOG_FILE}" || return 1
        fi
        # Logdatei mit aktuellem Datum und Skriptnamen anlegen --------------
        echo "" >> "${LOG_FILE}"
    else
        # Nur Eintrag schreiben, keine Rotation -----------------------------
        if [ ! -f "${LOG_FILE}" ]; then
            touch "${LOG_FILE}" || return 1
        fi
        echo "$(date "+%Y-%m-%d %H:%M:%S") $1" >> "${LOG_FILE}"
    fi
}
CheckIsInstalled() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion prüft ob das übergebene Software Paket installiert ist
    # -----------------------------------------------------------------------
    # Parameter prüfen ------------------------------------------------------
    if [ -z "$1" ]; then return 2; fi                        # Kein Parameter
    # Installationsstatus prüfen --------------------------------------------
    local chkPackage=$(dpkg -l $1 2>/dev/null | grep 'ii' -A0 | tail -n1 | awk '{print $1}') 
    # Paket installiert ? ---------------------------------------------------
    if [ "$chkPackage" != "ii" ]; then return 1; fi       # nicht installiert
    # Paket ist installiert -------------------------------------------------
    return 0                                   # Software bereits installiert
}
InstallApp() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zur Installation eines Software Paketes
    # -----------------------------------------------------------------------
    # Parameter prüfen ------------------------------------------------------
    if [ -z "$1" ]; then return 1; fi         # Kein Parameter
    # Installationsstatus prüfen --------------------------------------------
    CheckIsInstalled "$1"
    if [ $? -eq 0 ]; then 
        LOG "${txLOG_0001}$1${txLOG_0002}"; return 0    # bereits installiert
    else 
        # Software installieren ---------------------------------------------
        apt update >/dev/null 2>&1
        apt install -y "$1" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            LOG "${txLOG_0001}$1${txLOG_0003}"; return 0            # Erfolg
        else
            LOG "${txLOG_0001}$1${txLOG_0004}"; return 1            # Fehler
        fi
    fi
}
CheckPrepared() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zur Prüfung ob das Script ausgeführt werden kann 
    # -----------------------------------------------------------------------
    # LOG Eintrag erstellen -------------------------------------------------
    LOG ""
    LOG "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< START >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    # Hat der aktuelle User root Rechte -------------------------------------
    if [ "$EUID" -ne 0 ]; then
        # Meldung ausgeben --------------------------------------------------
        echo -e "${COLOR_ERR}${txERR_0001}${COLOR_RES}"
        echo -e "${COLOR_TIP}${txERR_0002}${COLOR_RES}"
        LOG "${txERR_0001}" 
        # Script beenden ----------------------------------------------------
        return 1
    else
        # Log Eintrag der Prüfung -------------------------------------------
        LOG "${txERR_0000}"
    fi
    # Installation von benötigter Software prüfen ---------------------------
    CheckIsInstalled 'dialog'
    if [ $? -eq 1 ]; then
        apt install -y dialog >/dev/null 2>&1
        echo -e "${COLOR_ERR}${txERR_0003}${COLOR_RES}" 
        echo -e "${COLOR_TIP}${txERR_0004}${COLOR_RES}"
        LOG "${txERR_0003}" 
        # Script beenden ----------------------------------------------------
        return 2
    fi 
    return 0
}
CheckCronJobExists() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zur Prüfung, ob ein bestimmter Cronjob bereits existiert
    # -----------------------------------------------------------------------
    # Parameter prüfen ------------------------------------------------------
    if [ -z "$1" ]; then return 2; fi                        # Kein Parameter
    # $1 = Suchmuster (z.B. "apt update") -----------------------------------
    crontab -l 2>/dev/null | grep -q "$1"
    if [ $? -ne 0 ]; then return 1; fi                  # Job existiert nicht
    # Job existiert ---------------------------------------------------------
    return 0                                          # Job existiert bereits
}
DayOfWeekToStr() {
    # Parameter prüfen ------------------------------------------------------
    if [ -z "$1" ]; then return 1; fi                        # Kein Parameter
    # Wochentag als Text aufbereiten ----------------------------------------
    case "$1" in
        1)  echo "Montag" ;;
        2)  echo "Dienstag" ;;
        3)  echo "Mittwoch" ;;
        4)  echo "Donnerstag" ;;
        5)  echo "Freitag" ;;
        6)  echo "Samstag" ;;
        7)  echo "Sonntag" ;;
    esac
    return 0
}
CheckTimeZone() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zur Prüfung, ob die Zeitzone bereits gesetzt ist
    # -----------------------------------------------------------------------
    # Parameter prüfen ------------------------------------------------------
    if [ -z "$1" ]; then return 2; fi                        # Kein Parameter
    # Einstellungsdatei gefunden --------------------------------------------
    if [ ! -f "/etc/timezone" ]; then return 3; fi                     # nein
    # Aktuelle Zeitzone identisch zu übergebener Zeitzone -------------------
    if [ "$(cat /etc/timezone 2>/dev/null | tr '[:upper:]' '[:lower:]')" = "$(echo $1 | tr '[:upper:]' '[:lower:]')" ]; then
        return 0                                       # Zone bereits gesetzt
    else
        return 1                                       # Zone nicht gesetzt
    fi
}
GetUserList() {
    # -----------------------------------------------------------------------
    # Gibt eine Liste aller regulären Benutzer (UID >= 1000) mit Home-Verzeichnis zurück
    # Optional: root kann mit ausgegeben werden, wenn $1="withroot" übergeben wird
    # Ergebnis: Zeilenweise Ausgabe "username:home"
    # -----------------------------------------------------------------------
    local include_root="$1"
    awk -F: -v root="$include_root" '($3 >= 1000 && $6 ~ /^\//) || (root=="withroot" && $1=="root") {print $1":"$6}' /etc/passwd
}
SetStrLower() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion wandelt einen String gemäß den Konventionen um
    # -----------------------------------------------------------------------
    # Parameter prüfen ------------------------------------------------------
    if [ -z "$1" ]; then return 1; fi           # Kein Parameter
    # String umwandeln ------------------------------------------------------
    echo "$1" | \
        tr '[:upper:]' '[:lower:]' | \
        tr --delete '[:blank:]' | \
        tr --delete '[,;.:\-_#\+\*\~!\"§$%&\/\(\{\}\[\]\)\=?`´]' | \
        sed 's/Ä/ae/g' | sed 's/ä/ae/g' | \
        sed 's/Ö/oe/g' | sed 's/ö/oe/g' | \
        sed 's/Ü/ue/g' | sed 's/ü/ue/g' | \
        sed 's/ß/ss/g' 
    return 0
}
SetSshConfigItem() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zur Prüfung ein Konfirugationseintrag bereits gesetzt 
    # Parameter: $1 = Schlüssel (z.B. PermitRootLogin) 
    # .......... $2 = Sollwert (z.B. without-password)
    # -----------------------------------------------------------------------
    # Parameter prüfen ------------------------------------------------------    
    if [ -z "$2" ]; then SshConfigItem=3; return 3; fi # Kein Key 
    if [ -z "$1" ]; then SshConfigItem=2; return 2; fi # Kein Schlüssel 
    # Parameter übernehmen --------------------------------------------------
    local key="$1"
    local value="$2"
    local file="/etc/ssh/sshd_config"
    # Zeile mit Schlüssel suchen (ggf. mit oder ohne # davor) ---------------
    line=$(grep -En '^\s*#?\s*'"$key" "$file" | head -n1)
    if [ -n "$line" ]; then
        lineno=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        # Prüfen, ob Kommentar (#) davor steht (max. 2 Zeichen vor Schlüssel)
        if [[ "$content" =~ ^[[:space:]]*# ]]; then
            # Wert extrahieren ----------------------------------------------
            found_value=$(echo "$content" | sed -E 's/^.*'"$key"'[[:space:]]*//')
            if [ "$found_value" != "$value" ]; then
                # Alten Wert als Kommentar davor speichern ------------------
                sed -i "$((lineno))i# changed by first-run: $content" "$file"
                # Kommentar entfernen und Wert setzen -----------------------
                sed -i "${lineno}s/.*/$key $value/" "$file"
                SshConfigItem=0; return 0 # Wert gesetzt
            else
                # Alten Wert als Kommentar davor speichern ------------------
                sed -i "$((lineno))i# changed by first-run: $content" "$file"
                # Kommentar entfernen und Wert aktivieren -------------------
                sed -i "${lineno}s/.*/$key $value/" "$file"
                SshConfigItem=0; return 0 # Wert gesetzt
            fi
        else
            # Kein Kommentar, Wert extrahieren ------------------------------
            found_value=$(echo "$content" | sed -E 's/^.*'"$key"'[[:space:]]*//')
            if [ "$found_value" != "$value" ]; then
                sed -i "$((lineno))i# changed by first-run: $content" "$file"
                sed -i "${lineno}s/.*/$key $value/" "$file"
                SshConfigItem=0; return 0 # Wert gesetzt
            fi
        fi
    else
        # Schlüssel nicht gefunden, einfach anhängen ------------------------
        echo "# -- add by first-run.sh --" >> "$file"
        echo "$key $value" >> "$file"
        SshConfigItem=0; return 0 # Wert gesetzt
    fi
}
GetServiceByPort() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zur ermmittlung des Dienstes zu einer Portnummer
    # Parameter: $1 = Portnummer (z.B. 22 oder 443/tcp)
    # -----------------------------------------------------------------------
    # Parameter prüfen ------------------------------------------------------    
    if [ -z "$1" ]; then ServiceByPort=1; return 1; fi       # Kein Parameter 
    # Parameter übernehmen --------------------------------------------------
    local port="$1"
    # Prüfen ob Portnummer mit /tcp oder /udp angegeben ist -----------------
    if [[ "$port" == */* ]]; then
        proto=$(echo "$port" | awk -F/ '{print $2}')
        portnum=$(echo "$port" | awk -F/ '{print $1}')
    else
        proto="tcp"
        portnum="$port"
    fi
    # Dienstnamen aus /etc/services ermitteln --------------------------------
    local service=$(grep -E "^.+[[:space:]]+$portnum/$proto" /etc/services | awk '{print $1}' | head -n1)
    if [ -z "$service" ]; then
        echo "unbekannt"
    else
        echo "$service"
    fi
}
SetFail2banJail() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zum erzeugen einer Jail Konfiguration für Fail2ban
    # Parameter: $1 = Dienst (z.B. sshd) 
    # .......... $2 = Konfiguration
    # -----------------------------------------------------------------------
    # Parameter prüfen ------------------------------------------------------    
    if [ -z "$1" ]; then return 2; fi                           # Kein Dienst
    if [ -z "$2" ]; then return 3; fi                   # Keine Konfiguration
    # Parameter übernehmen --------------------------------------------------
    local servicename="$1"
    local values="$2"
    # Fail2ban installieren, falls nicht vorhanden --------------------------
    InstallApp "fail2ban"
    # Jail-Konfiguration für SSH anlegen ------------------------------------
    cat << EOF > /etc/fail2ban/jail.d/${servicename}.local
[${servicename}]
${values}
EOF
    # Leerzeichen entfernen -------------------------------------------------
    sed -i 's/    //g' /etc/fail2ban/jail.d/${servicename}.local
    # Fail2ban neu starten --------------------------------------------------
    systemctl restart fail2ban
    # Status prüfen, ob fail2ban wieder aktiv ist ---------------------------
    systemctl is-active --quiet fail2ban
    # Fehlercode zurückgeben ------------------------------------------------
    return $?
}
SetFail2banCli () {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zum erzeugen einer Jail Konfiguration für login
    # -----------------------------------------------------------------------
    SetFail2banJail "pam-generic" \
        "enabled = true
        banaction = iptables
        backend = systemd
        maxretry = 3
        bantime = 6h
        findtime = 7d
        ignoreip = 127.0.0.1/8 ::1"
}
SetFail2banSsh() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zum erzeugen einer Jail Konfiguration für sshd
    # -----------------------------------------------------------------------
    SetFail2banJail "sshd" \
        "enabled = true
        filter = sshd
        banaction = iptables
        backend = systemd
        maxretry = 3
        bantime = 6h
        findtime = 7d
        ignoreip = 127.0.0.1/8 ::1"
    return $?
}
GetNetworkInterface() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zum Auslesen der aktuell aktiven Netzwerkkarte
    # -----------------------------------------------------------------------
    # als erstes mit der alten Funktion versuchen ---------------------------
    local active_iface=$(route -n | grep ^0.0.0.0 | awk '{print $8}')
    if [ -z "$active_iface" ]; then
        # wenn es nicht funktioniert, dann die neue Funktion versuchen ------
        active_iface=$(ip route | grep default | awk '{print $5}')
    fi
    # wenn die Netzwerkkarte immer noch leer ist, dann Fehlermeldung --------
    if [ -z "$active_iface" ]; then echo ""; return 1; fi      # Keine 
    # wenn die Netzwerkkarte gefunden wurde, dann den Namen zurückgeben
    echo "$active_iface"; return 0    
}
GetActiveIPv4Address() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zum Auslesen der aktuellen IPv4 Adresse
    # -----------------------------------------------------------------------
    # Name der aktiven Netzwerkkarte ermitteln
    local iface=$(GetNetworkInterface)
    # IP-Adresse dieser Netzwerkkarte auslesen
    local ip=$(ip -4 addr show "$iface" | awk '/inet / {print $2}' | cut -d/ -f1)
    echo "$ip"
}
GetActiveIPv6Address() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zum Auslesen der aktuellen IPv6 Adresse
    # -----------------------------------------------------------------------
    # Name der aktiven Netzwerkkarte ermitteln
    local iface=$(GetNetworkInterface)
    # IPv6-Adresse dieser Netzwerkkarte auslesen (global, nicht link-local)
    local ip=$(ip -6 addr show "$iface" | awk '/inet6 [2-3a-fA-F]/ {print $2}' | cut -d/ -f1 | head -n1)
    echo "$ip"
}
GetHostnames() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zum Auslesen des Hostnamen
    # Parameter: IP-Adresse (optional)
    # Unterscheidet zwischen IPv4 und IPv6
    # -----------------------------------------------------------------------
    # Parameter überprüfen --------------------------------------------------
    local ip="$1"
    # Rückgabewert aufbereiten ---------------------------------------------
    if [ -z "$ip" ]; then
        # Kein Parameter: aktuellen Hostnamen zurückgeben ------------------
        echo "$(hostname)"
    else
        # Hostname zur IP-Adresse ermitteln (reverse lookup) ---------------
        # Prüfen ob IPv6 (enthält ':')
        if [[ "$ip" == *:* ]]; then
            # IPv6: Suche nach exakter Übereinstimmung in /etc/hosts
            local host=$(awk -v searchip="$ip" '$1 == searchip {for(i=2;i<=NF;i++) printf "%s,", $i}' /etc/hosts | sed 's/,$//')
        else
            # IPv4: Suche nach exakter Übereinstimmung in /etc/hosts
            local host=$(awk -v searchip="$ip" '$1 == searchip {for(i=2;i<=NF;i++) printf "%s,", $i}' /etc/hosts | sed 's/,$//')
        fi
        # Alle Hostnamen aus /etc/hosts zur IP-Adresse ausgeben
        if [ -n "$host" ]; then
            echo "$host"
        else
            echo "$(hostname)"
        fi
    fi
}
SetHostnameIPv4() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zum Setzen des Hostnamens für IPv4
    # Erwartet: $1 = Hostname (ggf. kommasepariert), $2 = IP-Adresse
    # -----------------------------------------------------------------------
    # Parameter überprüfen --------------------------------------------------
    if [ -z "$1" ]; then return 1; fi           # Kein Hostname
    if [ -z "$2" ]; then return 2; fi           # Keine IP-Adresse
    # Parameter übernehmen --------------------------------------------------
    local newhostname=$(echo "$1" | tr ',' ' ')
    local ip="$2"
    # Nur den ersten Hostnamen als System-Hostname setzen -------------------
    local mainhostname=$(echo "$newhostname" | awk '{print $1}')
    local oldHostname="$(GetHostnames "$ip")"
    hostnamectl set-hostname "$mainhostname"
    # /etc/hosts für IPv4 anpassen ------------------------------------------
    sed -i "/$ip/d" /etc/hosts
    echo "$ip    $newhostname" >> /etc/hosts
    LOG "${txLOG_1001}${oldHostname}${txLOG_1003}${newhostname}"
}
SetHostnameIPv6() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zum Setzen des Hostnamens für IPv6
    # Erwartet: $1 = Hostname (ggf. kommasepariert), $2 = IP-Adresse
    # -----------------------------------------------------------------------
    # Parameter überprüfen --------------------------------------------------
    if [ -z "$1" ]; then return 1; fi           # Kein Hostname
    if [ -z "$2" ]; then return 2; fi           # Keine IP-Adresse
    # Parameter übernehmen --------------------------------------------------
    local newhostname=$(echo "$1" | tr ',' ' ')
    local ip="$2"
    # Nur den ersten Hostnamen als System-Hostname setzen -------------------
    local oldHostname="$(GetHostnames "$ip")"
    # /etc/hosts für IPv6 anpassen ------------------------------------------
    sed -i "/$ip/d" /etc/hosts
    echo "$ip    $newhostname" >> /etc/hosts
    LOG "${txLOG_1002}${oldHostname}${txLOG_1003}${newhostname}"
}
GetActiveMacAddress() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zum Auslesen der aktuellen MAC-Adresse
    # -----------------------------------------------------------------------
    # Name der aktiven Netzwerkkarte ermitteln
    local iface=$(GetNetworkInterface)
    # MAC-Adresse dieser Netzwerkkarte auslesen
    local mac=$(ip link show "$iface" | awk '/link\/ether/ {print $2}')
    echo "$mac"
}

# ===========================================================================
# Änderungen
# ===========================================================================
# Funktionen die Änderungen am System vornehmen
SetSystemUpDate() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zur Paket Aktualisierung
    # -----------------------------------------------------------------------
    # Bildschirm löschen ----------------------------------------------------
    clear
    # Paketlisten aktualisieren ---------------------------------------------
    apt update
    if [ $? = 0 ]; then LOG "${txLOG_0101}"; else LOG "${txLOG_0102}"; fi
    sleep 2
    # Pakete updaten --------------------------------------------------------
    apt upgrade -y 
    if [ $? = 0 ]; then LOG "${txLOG_0103}"; else LOG "${txLOG_0104}"; fi
    sleep 2
    # Nicht mehr benötigte Pakete löschen -----------------------------------
    apt autoremove -y
    if [ $? = 0 ]; then LOG "${txLOG_0105}"; else LOG "${txLOG_0106}"; fi
    sleep 2
}
SetAutoUpdate() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion um Paket Update als Cronjob einzurichten
    # -----------------------------------------------------------------------
    # Dialog zum Wochentag anzeigen -----------------------------------------
    DayOfWeek=$(dialog --output-fd 1 \
        --backtitle "${APP_TITLE}" \
        --title "${txTITLE_00}${StepID}${txTITLE_02}" \
        --yes-label "${YES_LABEL}" \
        --cancel-label "${CANCEL_LABEL}" \
        --radiolist "${txPART0201}${txSTP_0002}" \
        19 62 7 \
        "1" "Montag" on \
        "2" "Dienstag" off \
        "3" "Mittwoch" off \
        "4" "Donnerstag" off \
        "5" "Freitag" off \
        "6" "Samstag" off \
        "7" "Sonntag" on 
    )
    # Antwort speichern, Dialog bereinigen ----------------------------------
    antwort=$?
    dialog --clear
    # Dialog auswerten ------------------------------------------------------
    if [ $antwort -eq 0 ]; then
        # Dialog zur Uhrzeit anzeigen ---------------------------------------
        TimeOfUpdate=$(dialog --output-fd 1 \
            --backtitle "${APP_TITLE}" \
            --title "${txTITLE_00}${StepID}${txTITLE_02}" \
            --yes-label "${YES_LABEL}" \
            --cancel-label "${CANCEL_LABEL}" \
            --timebox "${txPART0202}${txSTP_0003}" \
            8 62
        )
        # Antwort speichern, Dialog bereinigen ------------------------------
        antwort=$?
        dialog --clear
        # Dialog auswerten --------------------------------------------------
        if [ $antwort -eq 0 ]; then
            CheckCronJobExists "apt update"
            if [ $? -ne 0 ]; then
                # Schreiben in temporäre Datei ----------------------------------
                local TMP_FILE=$(mktemp /tmp/newmycron.XXXXXX)
                crontab -l > ${TMP_FILE}
                # Neuen Eintrag anfügen -----------------------------------------
                echo " " >> ${TMP_FILE}
                echo "# --- BEGIN FirstRun ---" >> ${TMP_FILE}
                echo "# System Updates jeden ${DayOfWeekToStr "$DayOfWeek"} um $(echo $TimeOfUpdate | awk -F: '{print $1}'):$(echo $TimeOfUpdate | awk -F: '{print $2}') Uhr ausführen" >> ${TMP_FILE}
                echo "$(echo $TimeOfUpdate | awk -F: '{print $2}') $(echo $TimeOfUpdate | awk -F: '{print $1}') * * ${DayOfWeek} apt update && apt upgrade -y && apt autoremove -y" >> ${TMP_FILE}
                echo "# --- END FirstRun ---" >> ${TMP_FILE}
                # Neuen Cronjob installieren ------------------------------------
                crontab ${TMP_FILE}
                rm ${TMP_FILE}
                # LOG Eintrag erstellen -----------------------------------------
                if [ $? = 0 ]; then
                    LOG "System Updates jeden ${DayOfWeekTxt} um $(echo $TimeOfUpdate | awk -F: '{print $1}'):$(echo $TimeOfUpdate | awk -F: '{print $2}') Uhr ausführen"
                else 
                    LOG "${txLOG_0202}"
                fi
                # Bildschirm löschen ----------------------------------------
                clear
                return 0 # return-code 0 : Schritt ausgeführt
            else
                clear
                LOG "${txLOG_0203}"
                return 1
            fi
        else
            # Bildschirm löschen ----------------------------------------
            clear
            LOG "${txLOG_0203}"
            # Schritt beenden -------------------------------------------
            return 1 # return-code 1 : Schritt abgebrochen
        fi
    else
        # Bildschirm löschen --------------------------------------------
        clear
        LOG "${txLOG_0204}"
        # Schritt beenden -----------------------------------------------
        return 1 # return-code 1 : Schritt abgebrochen
    fi
}
SetRecommendedSoftware() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zur Installation der empfohlenen Software
    # -----------------------------------------------------------------------
    # Parameter prüfen ------------------------------------------------------
    if [ -z "$1" ]; then return 1; fi                        # Kein Parameter
    # Analyse der übergebenen Parameter und bestimmen der Schrittweite ------
    local i=1
    local Param=$1
    local SteplvWidth=$(expr 90 / $(echo "$Param" | wc -w))
    # Dialog vorbereiten ----------------------------------------------------
    local DIALOG=dialog
    (
    echo "1"   ; sleep 1
    for var in $Param
    do
        echo "XXX" ; sleep 1 && echo "${txPART0302}${var}${txPART0303}"; echo "XXX"
        cnt=$(expr ${SteplvWidth} \* ${i}); echo "$cnt";
        InstallApp "${var}"
        i=$(expr $i + 1)
    done
    sleep 1
    echo "XXX" ; echo "${txPART0304}"; echo "XXX"
    echo "100" ; sleep 2
    ) |
    $DIALOG --backtitle "${APP_TITLE}" --title "${GAUGE_TITLE}" --gauge "${txPART0301}" 6 62
    $DIALOG --clear
    # Bildschirm löschen ----------------------------------------------------
    clear
    return 0 # return-code 0 : Schritt ausgeführt
}
SetKeyboardLayout() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zum setzen des Tastatur Layouts
    # -----------------------------------------------------------------------
    # Tastatuslayout einstellen ---------------------------------------------
    dpkg-reconfigure locales
    # LOG Eintrag erstellen -------------------------------------------------
    if [ $? = 0 ]; then
        # LOG Aktivierte Locales --------------------------------------------
        LOG "${txLOG_0401} $(grep -v '^#' /etc/locale.gen | grep -v '^$')"
        # LOG Aktuelle System-Locale ----------------------------------------
        LOG "${txLOG_0402} $(cat /etc/default/locale)"
        return 0                                            # Locales gesetzt
    else 
        LOG "${txLOG_0403}"
        return 1                               # Fehler bei der Konfiguration
    fi
}
SetTimeZone() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zum Anpassen der Zeitzone und Installation ntp-Server
    # -----------------------------------------------------------------------
    # Parameter prüfen ------------------------------------------------------
    if [ -z "$1" ]; then return 1; fi                        # Kein Parameter
    # Analyse der übergebenen Parameter und bestimmen der Schrittweite ------
    i=1
    Param=$1
    SteplvWidth=$(expr 90 / $(echo "$Param" | wc -w))
    # Dialog vorbereiten ----------------------------------------------------
    local DIALOG=dialog
    (
    echo "1"   ; sleep 1
    for var in $*
    do
        cnt=$(expr ${SteplvWidth} \* ${i})  
        case "$var" in
            Zeitzone)   echo "XXX"; sleep 1; echo "${txPART0503}${TIMEZONE}${txPART0504}"
                        echo "XXX"; echo "$cnt"; CheckTimeZone "${TIMEZONE}"
                        if [ $? -eq 1 ]; then 
                            echo $TIMEZONE > /etc/timezone
                            LOG "${txLOG_0501}${TIMEZONE}${txLOG_0502}"
                        else
                            LOG "${txLOG_0503} (${TIMEZONE})"
                        fi
                        sleep 1 ;;
            ntp)        echo "XXX"; sleep 1; echo "${txPART0505}${var}${txPART0506}"
                        echo "XXX"; echo "$cnt"; InstallApp "${var}"
                        sleep 1 ;;
        esac
        i=$(expr $i + 1)
    done
    echo "XXX" ; echo "${txPART0507}"; echo "XXX"
    echo "100" ; sleep 1
    ) |
    $DIALOG --backtitle "${APP_TITLE}" --title "${GAUGE_TITLE}" --gauge "${txPART0502}" 6 62
    $DIALOG --clear
    # Bildschirm löschen ----------------------------------------------------
    clear
    return 0 # return-code 0 : Schritt ausgeführt
}
SetAdminUser() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zum Anlegen eines neuen Users mit Fortschrittsbalken
    # -----------------------------------------------------------------------
    # Benutzername, Passwort und Vollständigen Namen abfragen ---------------
    USER_INPUTS=$(dialog --output-fd 1 \
        --backtitle "${APP_TITLE}" \
        --title "${txTITLE_00}${StepID}${txTITLE_06}" \
        --yes-label "${YES_LABEL}" \
        --cancel-label "${CANCEL_LABEL}" \
        --form "${txPART0601}${txSTP_0004}" \
        17 62 5 \
        "Benutzername:" 1 1 "" 1 20 32 0 \
        "Passwort:"     3 1 "" 3 20 32 0 \
        "Vollständiger Name:" 5 1 "" 5 20 32 0
    )
    # Rückgabewert des Dialogs abfragen -------------------------------------
    local antwort=$?
    dialog --clear

    if [ $antwort -eq 0 ]; then
        # Eingaben in Variablen speichern -----------------------------------
        USER_NAME=$(echo "$USER_INPUTS" | sed -n 1p)
        USER_PASS=$(echo "$USER_INPUTS" | sed -n 2p)
        USER_COMM=$(echo "$USER_INPUTS" | sed -n 3p)

        # Prüfen, ob alle Felder ausgefüllt wurden --------------------------
        if [ -z "$USER_NAME" ] || [ -z "$USER_PASS" ] || [ -z "$USER_COMM" ]; then
            dialog --backtitle "${APP_TITLE}" --colors \
                --title "${ERR_TITLE}" \
                --msgbox "${txPART0602}" 8 50
            LOG "${txERR_0600}"
            dialog --clear
            clear
            return 5
        fi

        # Fortschrittsdialog starten ----------------------------------------
        (
            # User anlegen --------------------------------------------------
            echo "10"; sleep 1
            echo "XXX"; echo "${txPART0603}${USER_COMM}${txPART0604}"; echo "XXX"
            USER_NAME=$(SetStrLower "$USER_NAME")
            useradd -c "${USER_COMM} (Superuser)" -m -G users -s /bin/bash $USER_NAME >/dev/null 2>&1
            if [ "$?" -ne "0" ]; then
                echo "XXX"; echo "${txERR_0601}${USER_NAME}${txERR_0602}"; echo "XXX"
                LOG "${txLOG_0601}"; sleep 2; exit 1
            fi
            # Passwort vergeben ---------------------------------------------
            echo "50"; sleep 1
            echo "XXX"; echo "${txPART0605}${USER_COMM}${txPART0606}"; echo "XXX"
            echo $USER_NAME:$USER_PASS | chpasswd >/dev/null 2>&1
            if [ "$?" -ne "0" ]; then
                echo "XXX"; echo "${txERR_0603}${USER_NAME}${txERR_0604}"; echo "XXX"
                LOG "${txLOG_0602}"; sleep 2; exit 2
            fi
            # User zu SUDO hinzufügen ---------------------------------------
            echo "80"; sleep 1
            echo "XXX"; echo "${txPART0607}${USER_COMM}${txPART0608}"; echo "XXX"
            usermod -aG sudo $USER_NAME >/dev/null 2>&1
            if [ "$?" -ne "0" ]; then
                echo "XXX"; echo "${txERR_0605}${USER_NAME}${txERR_0606}"; echo "XXX"
                LOG "${txLOG_0603}"; sleep 2; exit 3
            fi
            # Abschlussmeldung ----------------------------------------------
            echo "100"; sleep 1
            echo "XXX"; echo "${txPART0609}$USER_COMM${txPART0610}"; echo "XXX"
            sleep 2
        ) | dialog --backtitle "${APP_TITLE}" --title "${GAUGE_TITLE}" --gauge "${txPART0603}${USER_COMM}${txPART0604}" 6 72
        LOG "${txLOG_0604}${USER_NAME}${txLOG_0605}"

        # Abschlussmeldung entfernt, nur noch Fortschrittsdialog
        dialog --clear
        clear
        return 0
    else
        # Abbruchmeldung ----------------------------------------------------
        LOG "${txLOG_0606}"
        # Bildschirm löschen ------------------------------------------------
        dialog --clear
        clear
        return 4 # return-code 4 : Schritt abgebrochen
    fi
}
ShowAndCopySshPrivateKey() {
    # Parameter: $1 = User
    local SSH_DIR="/home/$1/.ssh"
    local KEYFILE="${SSH_DIR}/id_rsa"
    local txSSHKEY1401="Der private SSH-Schlüssel wird angezeigt. Sie können ihn in die Zwischenablage kopieren.\n\nAchtung: Der private Schlüssel ist geheim und darf nicht weitergegeben werden!"
    local txSSHKEY1402="In Zwischenablage kopieren"
    local txSSHKEY1403="Abbrechen"
    local txSSHKEY1404="Schlüssel wurde in die Zwischenablage kopiert."
    local txSSHKEY1405="Fehler beim Kopieren in die Zwischenablage!"

    if [ ! -f "$KEYFILE" ]; then
        dialog --msgbox "Kein privater Schlüssel gefunden!" 8 50
        return 1
    fi

    TMPKEY=$(mktemp)
    cat "$KEYFILE" > "$TMPKEY"

    while true; do
        dialog --backtitle "${APP_TITLE}" \
            --title "SSH Private Key anzeigen" \
            --extra-button --extra-label "$txSSHKEY1402" \
            --ok-label "$txSSHKEY1403" \
            --textbox "$TMPKEY" 20 70

        rc=$?
        if [ $rc -eq 3 ]; then
            # Extra-Button gedrückt: Kopieren in Zwischenablage
            if command -v xclip >/dev/null 2>&1; then
                xclip -selection clipboard < "$KEYFILE"
                dialog --msgbox "$txSSHKEY1404" 7 50
            elif command -v wl-copy >/dev/null 2>&1; then
                wl-copy < "$KEYFILE"
                dialog --msgbox "$txSSHKEY1404" 7 50
            else
                dialog --msgbox "$txSSHKEY1405\nInstallieren Sie xclip oder wl-clipboard!" 8 60
            fi
        else
            break
        fi
    done

    rm -f "$TMPKEY"
}
SetSshLogin() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zum Einrichten des ssh Login für übergebenen Nutzer
    # -----------------------------------------------------------------------
    # Parameter prüfen ------------------------------------------------------
    if [ -z "$1" ]; then return 1; fi                             # Kein User
    # Parameter prüfen ------------------------------------------------------
    if [ -z "$2" ]; then return 2; fi                        # Keine Optionen
    # Analyse der übergebenen Parameter und bestimmen der Schrittweite ------
    START_DIR=$(pwd)
    HOME_DIR=/home/$1
    SSH_DIR=${HOME_DIR}/.ssh
    SSH_KEYFILE=${SSH_DIR}/id_rsa
    # mit dem übergebenen User anmelden, Einrichtung starten ----------------
    # Fortschrittsdialog vorbereiten und Änderungen vornehmen ---------------
    DIALOG=dialog 
    (
        echo "10"   ; sleep 1
        for var in $2; do
            case "$var" in
                KeyFile)
                    # Benutzer-Rechte Home Ordner korrigieren
                    echo "XXX" ; sleep 1 && echo "${txPART0702}'${HOME_DIR}' ..."; echo "XXX"
                    echo "20"  ; chmod 755 "${HOME_DIR}/"
                    # SSH-Ordner anlegen
                    echo "XXX" ; sleep 1 && echo "${txPART0703}'${SSH_DIR}' ..."; echo "XXX"
                    echo "40"  ; if [ ! -d "${SSH_DIR}" ]; then sudo -u $1 mkdir ${SSH_DIR}; fi
                    # SSH-Key File generieren
                    echo "XXX" ; sleep 1 && echo "${txPART0704}"; echo "XXX"
                    echo "50"  ; if [ ! -e "${SSH_KEYFILE}" ]; then sudo -u $1 ssh-keygen -b 4096 -f ${SSH_KEYFILE} -N ""; else echo "${txPART0705}"; fi
                    # Schlüssel veröffentlichen
                    echo "XXX" ; sleep 1 && echo "${txPART0706}"; echo "XXX"
                    echo "60" ; sudo -u $1 cat "${SSH_DIR}/id_rsa.pub" >> "${SSH_DIR}/authorized_keys"
                    # ssh Konfiguration anpassen
                    echo "XXX" ; sleep 1 && echo "${txPART0708}"; echo "XXX"
                    echo "65" ; 
                    # Login für root ohne Passwort
                    echo "XXX" ; sleep 1 && echo "${txPART0708}"; echo "XXX"
                    echo "67" ; SetSshConfigItem "PermitRootLogin" "without-password"
                    # Vergleichsmodus anpassen
                    echo "XXX" ; sleep 1 && echo "${txPART0708}"; echo "XXX"
                    echo "69" ; SetSshConfigItem "StrictModes" "yes"
                    # Public-Key-Authentifizierung ermöglichenn
                    echo "XXX" ; sleep 1 && echo "${txPART0708}"; echo "XXX"
                    echo "71" ; SetSshConfigItem "PubkeyAuthentication" "yes"
                    # Passwort-Authentifizierung nicht möglich
                    echo "XXX" ; sleep 1 && echo "${txPART0708}"; echo "XXX"
                    echo "72" ; SetSshConfigItem "PasswordAuthentication" "no"
                    echo "XXX" ; sleep 1 && echo "${txPART0708}"; echo "XXX"
                    echo "75" ; SetSshConfigItem "ChallengeResponseAuthentication" "no"
                    echo "XXX" ; sleep 1 && echo "${txPART0708}"; echo "XXX"
                    echo "77" ; SetSshConfigItem "KbdInteractiveAuthentication" "no"
                    echo "XXX" ; sleep 1 && echo "${txPART0709}"; echo "XXX"
                    echo "79" ; sleep 1 ;;
                TimeOut)
                    # Auto Session Timeout
                    echo "XXX" ; sleep 1 && echo "${txPART0710}"; echo "XXX"
                    echo "82" ; SetSshConfigItem "ClientAliveInterval" "0"
                    SetSshConfigItem "ClientAliveCountMax" "3"
                    echo "XXX" ; sleep 1 && echo "${txPART0711}"; echo "XXX"
                    echo "85" ; sleep 1 ;;
                AllowUser)
                    # Zugang auf User xx beschänken
                    echo "XXX" ; sleep 1 && echo "${txPART0712}$1${txPART0713}"; echo "XXX"
                    echo "90" ; SetSshConfigItem "AllowUsers" "$1"
                    echo "XXX" ; sleep 1 && echo "${txPART0714}$1${txPART0715}"; echo "XXX"
                    echo "95" ; sleep 1 ;;
            esac
        done
        # Letzter Schritt
        echo "XXX" ; sleep 1 && echo "${txPART0716}"; echo "XXX"
        echo "100" ; sleep 2 
    ) | 
    $DIALOG --backtitle "${APP_TITLE}" --title "${GAUGE_TITLE}" --gauge "$(echo "$txPART0701" | sed "s/%s/$1/")" 6 62
    $DIALOG --clear
    service sshd restart 
    # Schlüssel anzeigen ----------------------------------------------------
    ShowAndCopySshPrivateKey "$1"
    # Bildschirm löschen ----------------------------------------------------
    clear
    return 0 # return-code 0 : Schritt ausgeführt
}
SetFirewallConfig() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zur Konfiguration der Firewall
    # -----------------------------------------------------------------------
    # Parameter prüfen ------------------------------------------------------
    if [ -z "$1" ]; then return 1; fi                       # Keine Parameter
    # Analyse der übergebenen Parameter und bestimmen der Schrittweite ------
    local i=1
    local Param=$1
    local SteplvWidth=$(expr 90 / $(echo "$Param" | wc -w))
    # Dialog vorbereiten ----------------------------------------------------
    local DIALOG=dialog
    (
    echo "1"   ; sleep 1
    echo "XXX" ; sleep 1 && echo "${txPART0802}"; echo "XXX"
    echo "2"   ; InstallApp "ufw"
    echo "XXX" ; sleep 1 && echo "${txPART0803}"; echo "XXX"
    echo "3"   ; ufw default deny incoming > /dev/null 2>&1 &
    echo "XXX" ; sleep 1 && echo "${txPART0804}"; echo "XXX"
    echo "4"   ; ufw default allow outgoing > /dev/null 2>&1 &    
    for var in $Param
    do
        service=$(GetServiceByPort "${var}")
        echo "XXX" ; sleep 1 && echo "${txPART0805}${var} (${service})${txPART0806}"; echo "XXX"
        cnt=$(expr ${SteplvWidth} \* ${i}); echo "$cnt";
        # Firewall-Regel hinzufügen ------------------------------------ 
        ufw allow "${var}" > /dev/null 2>&1 &        
        i=$(expr $i + 1)
        sleep 1
    done
    echo "XXX" ; sleep 1 && echo "${txPART0807}"; echo "XXX"
    echo "98"   ; ufw enable > /dev/null 2>&1 &
    echo "XXX" ; sleep 1 && echo "${txPART0808}"; echo "XXX"
    echo "99"   ; ufw reload > /dev/null 2>&1 &    
    echo "XXX" ; echo "${txPART0809}"; echo "XXX"
    echo "100" ; sleep 2
    ) |
    $DIALOG --backtitle "${APP_TITLE}" --title "${GAUGE_TITLE}" --gauge "${txPART0801}" 6 62
    $DIALOG --clear
    # Bildschirm löschen ----------------------------------------------------
    clear
    return 0 # return-code 0 : Schritt ausgeführt
}
SetLoginProtection() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zum Schutz des Logins auf CLI und SSH mit Fail2ban
    # -----------------------------------------------------------------------
    # Parameter prüfen ------------------------------------------------------
    if [ -z "$1" ]; then return 1; fi                        # Kein Parameter
    # Analyse der übergebenen Parameter und bestimmen der Schrittweite ------
    i=1
    Param=$1
    SteplvWidth=$(expr 90 / $(echo "$Param" | wc -w))
    # Dialog vorbereiten ----------------------------------------------------
    local DIALOG=dialog
    (
    echo "1"   ; sleep 1
    for var in $*
    do
        cnt=$(expr ${SteplvWidth} \* ${i})  
        case "$var" in
            cli)    echo "XXX"; sleep 1; echo "${txPART0902}${var}${txPART0903}"
                    echo "XXX"; echo "$cnt"; SetFail2banCli
                    if [ $? = 1 ]
                    then LOG "${txLOG_0901}${var}${txLOG_0902}"
                    else LOG "${txLOG_0901}${var}${txLOG_0903}"; fi
                    sleep 1 ;;
            ssh)    echo "XXX"; sleep 1; echo "${txPART0902}${var}${txPART0903}"
                    echo "XXX"; echo "$cnt"; SetFail2banSsh
                    if [ $? = 1 ]
                    then LOG "${txLOG_0901}${var}${txLOG_0902}"
                    else LOG "${txLOG_0901}${var}${txLOG_0903}"; fi
                    sleep 1 ;;
        esac
        i=$(expr $i + 1)
    done
    echo "XXX" ; echo "${txPART0904}"; echo "XXX"
    echo "100" ; sleep 1
    ) |
    $DIALOG --backtitle "${APP_TITLE}" --title "${GAUGE_TITLE}" --gauge "${txPART0901}" 6 62
    $DIALOG --clear
    # Bildschirm löschen ----------------------------------------------------
    clear
    return 0 # return-code 0 : Schritt ausgeführt
}
SetHostname() {
    # -----------------------------------------------------------------------
    # Hilfsfunktion zum Ändern des Hostnamen
    # -----------------------------------------------------------------------
    # Systemwerte nur einmal ermitteln
    local iface=$(GetNetworkInterface)
    local ip_v4=$(GetActiveIPv4Address)
    local ip_v6=$(GetActiveIPv6Address)
    local host_v4=$(GetHostnames "$ip_v4")
    local host_v6=$(GetHostnames "$ip_v6")

    # Aktuelle Konfigurtion anzeigen, Auswahl der Netzwerkarte und der IP
    # Adresse für die der Hostname geändert werden soll
    HostnameSelection=$(dialog --output-fd 1\
      --backtitle "${APP_TITLE}" \
      --title "< Aktuelle Konfiguration >" \
      --yes-label "${YES_LABEL}" \
      --cancel-label "${CANCEL_LABEL}" \
      --checklist "${txPART1001}${txPART1002}${iface} (${ip_v4})${txPART1003}${host_v4}${txPART1004}${txPART1002}${iface} (${ip_v6})${txPART1003}${host_v6}${txPART1005}" \
      19 68 5 \
      "IPv4" "Netzwerkkarte '${iface} (${ip_v4})'" on \
      "IPv6" "Netzwerkkarte '${iface} (${ip_v6})'" off
    )

    # Antwort speichern, Dialog auswerten, Dialog bereinigen ----------------
    HostnameChange=$?
    dialog --clear
    if [ $HostnameChange -ne 0 ]; then return 1; fi      # Dialog abgebrochen

    # Dialog zur Änderung Hostname anzeigen ---------------------------------
    NewHostNames=$(dialog --output-fd 1\
        --backtitle "${APP_TITLE}" \
        --title "< Neue Hostnamen festlegen >" \
        --yes-label "${YES_LABEL}" \
        --cancel-label "${CANCEL_LABEL}" \
        --form "${txPART1006}" \
        10 70 3 \
        "${txPART1007}" 1 1 "$(GetHostnames $(GetActiveIPv4Address))"  1 17 128 0 \
        "${txPART1008}" 3 1 "$(GetHostnames $(GetActiveIPv6Address))"  3 17 128 0
    )

    # Antwort speichern, Dialog auswerten, Dialog bereinigen ----------------
    local antwort=$?
    dialog --clear
    if [ $antwort -ne 0 ]; then return 1; fi             # Dialog abgebrochen

    local hostname_v4=$(echo "$NewHostNames" | sed -n 1p)
    local hostname_v6=$(echo "$NewHostNames" | sed -n 2p)
    local ip_v4=$(GetActiveIPv4Address)
    local ip_v6=$(GetActiveIPv6Address)

    # Fortschrittsdialog vorbereiten und Änderungen vornehmen
    DIALOG=dialog
    (
        echo "1"   ; sleep 1
        echo "XXX" ; sleep 1 && echo "${txPART1010}"; echo "XXX"
        echo "25"  ; if [ -n "$hostname_v4" ] && [ -n "$ip_v4" ]; then SetHostnameIPv4 "$hostname_v4" "$ip_v4"; fi
        echo "XXX" ; sleep 1 && echo "${txPART1011}"; echo "XXX"
        echo "50"  ; sleep 1
        echo "XXX" ; sleep 1 && echo "${txPART1012}"; echo "XXX"
        echo "75"  ; if [ -n "$hostname_v6" ] && [ -n "$ip_v6" ]; then SetHostnameIPv6 "$hostname_v6" "$ip_v6"; fi
        echo "XXX" ; sleep 1 && echo "${txPART1013}"; echo "XXX"
        echo "90"  ; sleep 1
        echo "XXX" ; sleep 1 && echo "${txPART1014}"; echo "XXX"
        echo "100" ; sleep 1
    ) |
    $DIALOG --backtitle "${APP_TITLE}" --title "${GAUGE_TITLE}" --gauge "$txPART1009" 6 62
    # Bildschirm löschen ----------------------------------------------------
    $DIALOG --clear
    clear
    return 0 # return-code 0 : Schritt ausgeführt
}
SetDdosProtection () {
    # -----------------------------------------------------------------------
    # DDoS-Schutz aktivieren mit Fortschrittsdialog und Logging
    # -----------------------------------------------------------------------
    local DIALOG=dialog
    (
        echo "1" ; sleep 1
        echo "XXX"; echo "$txPART1101"; echo "XXX"
        if iptables -t mangle -A PREROUTING --ctstate INVALID -m conntrack -j DROP >/dev/null 2>&1; then
            LOG "${txLOG_1101} (OK)"
        else
            LOG "${txLOG_1101} (FEHLER)"
        fi

        echo "10"; sleep 1
        echo "XXX"; echo "$txPART1102"; echo "XXX"
        if iptables -t mangle -A PREROUTING -m conntrack -p tcp ! --syn --ctstate NEW -j DROP >/dev/null 2>&1; then
            LOG "${txLOG_1102} (OK)"
        else
            LOG "${txLOG_1102} (FEHLER)"
        fi

        echo "20"; sleep 1
        echo "XXX"; echo "$txPART1103"; echo "XXX"
        if iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP >/dev/null 2>&1; then
            LOG "${txLOG_1103} (OK)"
        else
            LOG "${txLOG_1103} (FEHLER)"
        fi

        echo "30"; sleep 1
        echo "XXX"; echo "$txPART1104"; echo "XXX"
        if iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP >/dev/null 2>&1 &&
           iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP >/dev/null 2>&1 &&
           iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP >/dev/null 2>&1; then
            LOG "${txLOG_1104} (OK)"
        else
            LOG "${txLOG_1104} (FEHLER)"
        fi

        echo "40"; sleep 1
        echo "XXX"; echo "$txPART1105"; echo "XXX"
        if iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP >/dev/null 2>&1 &&
           iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP >/dev/null 2>&1 &&
           iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP >/dev/null 2>&1 &&
           iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP >/dev/null 2>&1; then
            LOG "${txLOG_1105} (OK)"
        else
            LOG "${txLOG_1105} (FEHLER)"
        fi

        echo "50"; sleep 1
        echo "XXX"; echo "$txPART1106"; echo "XXX"
        if iptables -t mangle -A PREROUTING -f -j DROP >/dev/null 2>&1; then
            LOG "${txLOG_1106} (OK)"
        else
            LOG "${txLOG_1106} (FEHLER)"
        fi

        echo "60"; sleep 1
        echo "XXX"; echo "$txPART1107"; echo "XXX"
        if iptables -A INPUT -p udp -m limit --limit 150/s -j ACCEPT >/dev/null 2>&1 &&
           iptables -A INPUT -p udp -j DROP >/dev/null 2>&1; then
            LOG "${txLOG_1107} (OK)"
        else
            LOG "${txLOG_1107} (FEHLER)"
        fi

        echo "70"; sleep 1
        echo "XXX"; echo "$txPART1108"; echo "XXX"
        if iptables -A INPUT -p udp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT >/dev/null 2>&1 &&
           iptables -A INPUT -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT >/dev/null 2>&1 &&
           iptables -A INPUT -p udp --sport 53 -j DROP >/dev/null 2>&1; then
            LOG "${txLOG_1108} (OK)"
        else
            LOG "${txLOG_1108} (FEHLER)"
        fi

        echo "75"; sleep 1
        echo "XXX"; echo "$txPART1109"; echo "XXX"
        if iptables -A INPUT -p tcp --syn --dport 22 -m connlimit --connlimit-above 3 -j REJECT >/dev/null 2>&1 &&
           iptables -A INPUT -p tcp --syn --dport 22 -m recent --set --name ssh_flood >/dev/null 2>&1 &&
           iptables -A INPUT -p tcp --syn --dport 22 -m recent --update --seconds 60 --hitcount 5 --name ssh_flood -j DROP >/dev/null 2>&1 &&
           iptables -A INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above 20 -j REJECT >/dev/null 2>&1 &&
           iptables -A INPUT -p tcp --syn --dport 80 -m recent --set --name http_flood >/dev/null 2>&1 &&
           iptables -A INPUT -p tcp --syn --dport 80 -m recent --update --seconds 60 --hitcount 30 --name http_flood -j DROP >/dev/null 2>&1 &&
           iptables -A INPUT -p tcp --syn --dport 443 -m connlimit --connlimit-above 20 -j REJECT >/dev/null 2>&1 &&
           iptables -A INPUT -p tcp --syn --dport 443 -m recent --set --name https_flood >/dev/null 2>&1 &&
           iptables -A INPUT -p tcp --syn --dport 443 -m recent --update --seconds 60 --hitcount 30 --name https_flood -j DROP >/dev/null 2>&1; then
            LOG "${txLOG_1109} (OK)"
        else
            LOG "${txLOG_1109} (FEHLER)"
        fi

        echo "85"; sleep 1
        echo "XXX"; echo "$txPART1110"; echo "XXX"
        if sysctl -w net.ipv4.tcp_syncookies=1 >/dev/null 2>&1 &&
           sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1 >/dev/null 2>&1 &&
           sysctl -w net.ipv4.conf.all.rp_filter=1 >/dev/null 2>&1 &&
           sysctl -w net.ipv4.tcp_max_syn_backlog=2048 >/dev/null 2>&1 &&
           sysctl -w net.ipv4.tcp_synack_retries=2 >/dev/null 2>&1 &&
           sysctl -w net.ipv4.tcp_max_orphans=100 >/dev/null 2>&1; then
            LOG "${txLOG_1110} (OK)"
        else
            LOG "${txLOG_1110} (FEHLER)"
        fi

        echo "100"; sleep 1
        echo "XXX"; echo "$txPART1111"; echo "XXX"
        sleep 2
    ) |
    $DIALOG --backtitle "${APP_TITLE}" --title "${GAUGE_TITLE}" --gauge "$txPART1100" 6 62
    $DIALOG --clear
    clear
    return 0
}
SetIpSpoofingProtection() {
    # -----------------------------------------------------------------------
    # Schutz gegen IP-Spoofing aktivieren mit Fortschrittsdialog und Logging
    # -----------------------------------------------------------------------
    local DIALOG=dialog
    (
        echo "10"; sleep 1
        echo "XXX"; echo "$txPART1201"; echo "XXX"
        if sysctl -w net.ipv4.conf.all.rp_filter=1 >/dev/null 2>&1 &&
           sysctl -w net.ipv4.conf.default.rp_filter=1 >/dev/null 2>&1; then
            LOG "${txLOG_1201} (OK)"
        else
            LOG "${txLOG_1201} (FEHLER)"
        fi

        echo "40"; sleep 1
        echo "XXX"; echo "$txPART1202"; echo "XXX"
        if iptables -A INPUT -s 127.0.0.0/8 ! -i lo -j DROP >/dev/null 2>&1 &&
           iptables -A INPUT -s 224.0.0.0/3 -j DROP >/dev/null 2>&1 &&
           iptables -A INPUT -s 0.0.0.0/8 -j DROP >/dev/null 2>&1 &&
           iptables -A INPUT -s 240.0.0.0/5 -j DROP >/dev/null 2>&1 &&
           iptables -A INPUT -s 255.255.255.255 -j DROP >/dev/null 2>&1; then
            LOG "${txLOG_1202} (OK)"
        else
            LOG "${txLOG_1202} (FEHLER)"
        fi

        echo "70"; sleep 1
        echo "XXX"; echo "$txPART1203"; echo "XXX"
        if sysctl -w net.ipv4.conf.all.accept_source_route=0 >/dev/null 2>&1 &&
           sysctl -w net.ipv4.conf.default.accept_source_route=0 >/dev/null 2>&1 &&
           sysctl -w net.ipv4.conf.all.accept_redirects=0 >/dev/null 2>&1 &&
           sysctl -w net.ipv4.conf.default.accept_redirects=0 >/dev/null 2>&1 &&
           sysctl -w net.ipv4.conf.all.send_redirects=0 >/dev/null 2>&1 &&
           sysctl -w net.ipv4.conf.default.send_redirects=0 >/dev/null 2>&1; then
            LOG "${txLOG_1203} (OK)"
        else
            LOG "${txLOG_1203} (FEHLER)"
        fi

        echo "100"; sleep 1
        echo "XXX"; echo "$txPART1204"; echo "XXX"
        sleep 2
    ) |
    $DIALOG --backtitle "${APP_TITLE}" --title "${GAUGE_TITLE}" --gauge "${txPART1200}" 6 62
    $DIALOG --clear
    clear
    return 0
}
SetArpSpoofingProtection() {
    # -----------------------------------------------------------------------
    # ARP-Spoofing-Schutz aktivieren mit Fortschrittsdialog und Logging
    # -----------------------------------------------------------------------
    local DIALOG=dialog
    (
        echo "10"; sleep 1
        echo "XXX"; echo "$txPART1302"; echo "XXX"
        # Netzwerkinformationen ermitteln (erste nicht-loopback Schnittstelle)
        IFACE="$(GetNetworkInterface)"
        IPADDR="$(GetActiveIPv4Address)"
        MACADDR="$(GetActiveMacAddress)"
        if [ -n "$IFACE" ] && [ -n "$IPADDR" ] && [ -n "$MACADDR" ]; then
            LOG "${txLOG_1302} (OK): $IFACE $IPADDR $MACADDR"
        else
            LOG "${txLOG_1302} (FEHLER)"
        fi

        echo "35"; sleep 1
        echo "XXX"; echo "$txPART1303"; echo "XXX"
        # Skriptinhalt vorbereiten
        ARP_SCRIPT="/etc/network/if-up.d/add-my-static-arp"
        ARP_CMD="arp -i $IFACE -s $IPADDR $MACADDR"
        if [ -n "$ARP_CMD" ]; then
            LOG "${txLOG_1303} (OK): $ARP_CMD"
        else
            LOG "${txLOG_1303} (FEHLER)"
        fi

        echo "60"; sleep 1
        echo "XXX"; echo "$txPART1304"; echo "XXX"
        # Skript schreiben
        if echo -e "#!/bin/sh\n$ARP_CMD" > "$ARP_SCRIPT" 2>/dev/null; then
            LOG "${txLOG_1304} (OK): $ARP_SCRIPT"
        else
            LOG "${txLOG_1304} (FEHLER)"
        fi

        echo "80"; sleep 1
        echo "XXX"; echo "$txPART1305"; echo "XXX"
        # Skript ausführbar machen
        if chmod +x "$ARP_SCRIPT" >/dev/null 2>&1; then
            LOG "${txLOG_1305} (OK): $ARP_SCRIPT"
        else
            LOG "${txLOG_1305} (FEHLER)"
        fi

        echo "100"; sleep 1
        echo "XXX"; echo "$txPART1306"; echo "XXX"
        sleep 2
    ) |
    $DIALOG --backtitle "${APP_TITLE}" --title "${GAUGE_TITLE}" --gauge "${txPART1301}" 6 62
    $DIALOG --clear
    clear
    return 0
}
SetPrompt() {
    # -----------------------------------------------------------------------
    # Prompt-Anpassung systemweit und für alle neuen User vornehmen
    # -----------------------------------------------------------------------
    local DIALOG=dialog
    # Dialog vorbereiten ----------------------------------------------------
    (
        echo "20"
        echo "XXX"; echo "$txPART1402"; echo "XXX"
        if [ -f "/etc/bash.bashrc" ]; then
            if cp "/etc/bash.bashrc" "/etc/bash.bashrc.bak" 2>/dev/null; then
                LOG "${txLOG_1402} (OK)"
            else
                LOG "${txLOG_1402} (FEHLER)"
            fi
        fi

        echo "60"
        echo "XXX"; echo "$txPART1403"; echo "XXX"
        PROMPT_BLOCK="
# Angepasster, farbiger Bash-Prompt (automatisch gesetzt)
if [ -z \"\${debian_chroot:-}\" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=\$(cat /etc/debian_chroot)
fi
case \"\$TERM\" in
    xterm-color|*-256color) color_prompt=yes;;
esac
force_color_prompt=yes
if [ -n \"\$force_color_prompt\" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi
if [ \"\$color_prompt\" = yes ]; then
    PS1='\${debian_chroot:+(\$debian_chroot)}\\[\\033[01;31m\\]\\u\\[\\033[01;33m\\]@\\[\\033[01;36m\\]\\h \\[\\033[01;33m\\]\\w \\[\\033[01;35m\\]\\$ \\[\\033[00m\\]'
else
    PS1='\${debian_chroot:+(\$debian_chroot)}\\u@\\h:\\w\\$ '
fi
unset color_prompt force_color_prompt
case \"\$TERM\" in
    xterm*|rxvt*)
        PS1=\"\\[\\e]0;\${debian_chroot:+(\$debian_chroot)}\\u@\\h: \\w\\a\\]\$PS1\"
        ;;
    *)
        ;;
esac
"
        # Prompt-Block in /etc/bash.bashrc ersetzen oder anhängen
        awk '
            BEGIN {skip=0}
            /^# Angepasster, farbiger Bash-Prompt \(automatisch gesetzt\)/ {skip=1}
            skip && /^esac/ {skip=0; next}
            !skip {print}
        ' "/etc/bash.bashrc" > "/etc/bash.bashrc.tmp"
        echo "$PROMPT_BLOCK" >> "/etc/bash.bashrc.tmp"
        mv "/etc/bash.bashrc.tmp" "/etc/bash.bashrc"
        LOG "${txLOG_1403} (OK)"

        echo "80"
        echo "XXX"; echo "$txPART1404"; echo "XXX"
        # Prompt-Block in /etc/skel/.bashrc ersetzen oder anhängen
        if [ -f "/etc/skel/.bashrc" ]; then
            cp "/etc/skel/.bashrc" "/etc/skel/.bashrc.bak" 2>/dev/null
            awk '
                BEGIN {skip=0}
                /^# Angepasster, farbiger Bash-Prompt \(automatisch gesetzt\)/ {skip=1}
                skip && /^esac/ {skip=0; next}
                !skip {print}
            ' "/etc/skel/.bashrc.bak" > "/etc/skel/.bashrc.tmp"
            echo "$PROMPT_BLOCK" >> "/etc/skel/.bashrc.tmp"
            mv "/etc/skel/.bashrc.tmp" "/etc/skel/.bashrc"
            LOG "${txLOG_1404} (OK)"
        else
            echo "$PROMPT_BLOCK" >> "/etc/skel/.bashrc"
            LOG "${txLOG_1404} (neu angelegt)"
        fi

        echo "100"
        echo "XXX"; echo "$txPART1405"; echo "XXX"
        sleep 2
    ) |
    $DIALOG --backtitle "${APP_TITLE}" --title "Bash Prompt systemweit anpassen" --gauge "Prompt wird angepasst..." 8 62
    $DIALOG --clear
    clear
    return 0
}
ShowYesNoDlg() {
    # -----------------------------------------------------------------------
    # Ja/Nein Dialog anzeigen
    # Aufruf: ShowYesNoDialog "<Titel>" "<Nachricht>" "<Funktion>"
    # Parameter: $1 = Anzahl der Zeilen des Dialogs
    #            $2 = Breite des Dialogs
    #            $3 = Titel des Dialogs
    #            $4 = Nachricht die angezeigt werden soll
    #            $5 = Funktion die bei Ja aufgerufen werden soll
    # -----------------------------------------------------------------------
    
    # Parameter prüfen ------------------------------------------------------
    local res=1
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ]
    then return $res; fi

    # Dialog vorbereiten ----------------------------------------------------
    local lvDialog=dialog
    local lvLines="$1"
    local lvWidth="$2"
    local lvTitle="$3"
    local lvMessage="$4"
    local lvCallbackFnk="$5"
    shift 5
    local lvCallbackArgs=("$@")

    # Whitelist für aufzurufende Funktionen ---------------------------------
    ALLOWED_CALLBACKS="SetSystemUpDate SetAutoUpdate SetKeyboardLayout \
        SetAdminUser SetLoginProtection SetHostname SetDdosProtection \
        SetIpSpoofingProtection SetArpSpoofingProtection"
    if [[ ! " $ALLOWED_CALLBACKS " =~ " $lvCallbackFnk " ]]; then
        LOG "Nicht erlaubte Callback-Funktion: $lvCallbackFnk"
        return 3
    fi

    # LOG Titel und Schritt-ID ----------------------------------------------
    LOG "${txTITLE_00}${StepID}${lvTitle}"

    # Dialog anzeigen -------------------------------------------------------
    $lvDialog \
        --backtitle "${APP_TITLE}" \
        --title "${txTITLE_00}${StepID}${lvTitle}" \
        --yes-label "${YES_LABEL}" \
        --no-label "${CANCEL_LABEL}" \
        --yesno "${lvMessage}" \
        "$lvLines" "$lvWidth"

    # Antwort speichern, Dialog bereinigen ----------------------------------
    local lvAnswer=$?
    $lvDialog --clear

    # Dialog auswerten ------------------------------------------------------
    if [ "$lvAnswer" -eq 0 ]; then
        if declare -f "$lvCallbackFnk" > /dev/null; then
            # Funktion mit allen übergebenen Parametern aufrufen ------------
            "$lvCallbackFnk" "${lvCallbackArgs[@]}"
            res=$?
            LOG "Callback-Funktion '$lvCallbackFnk' - Return-Code: $res"
        else
            LOG "Callback-Funktion '$lvCallbackFnk' nicht gefunden"
            res=2
        fi
    else
        # Schritt beenden ---------------------------------------------------
        LOG "Dialog abgebrochen oder Nein gedrückt - Return-Code: $lvAnswer"
        res=1 # return-code 1 : Schritt abgebrochen
    fi

    # Bildschirm löschen, Schrittzähler erhöhen und Rückgabewert Dialog -----
    clear
    StepID=$(expr $StepID + 1)
    return $res
}

# ===========================================================================
# Installations Dialoge
# ===========================================================================
# Installations Dialog werden zu Beginn des jeweiligen Modul angezeigt und
# geben eine kurze Erklärung zu den folgenden Änderungen
DlgRecommendedSoftware() {
    # -----------------------------------------------------------------------
    # Dialog: Empfohlene Software installieren
    # -----------------------------------------------------------------------
    LOG "${txTITLE_00}${StepID}${txTITLE_03}"
    # Dialog anzeigen -------------------------------------------------------
    SelectedSoftware=$(dialog --output-fd 1\
      --backtitle "${APP_TITLE}" \
      --title "${txTITLE_00}${StepID}${txTITLE_03}" \
      --yes-label "${YES_LABEL}" \
      --cancel-label "${CANCEL_LABEL}" \
      --checklist "${txSTP_0301}${txSTP_0002}" \
      18 62 5 \
      "sudo" "Befehl als Admin starten" on \
      "curl" "Download-Tool" on \
      "nmap" "Portscanner" off \
      "htop" "Performance Analyse" off \
      "net-tools" "Hilfsprogramme zur Netzwerk Verwaltung" off 
    )
    # Antwort speichern, Dialog bereinigen ----------------------------------
    RecommendedSoftware=$?
    dialog --clear
    # Dialog auswerten ------------------------------------------------------
    if [ $RecommendedSoftware = 0 ] 
    then
        # Ausgewählte Software installieren ---------------------------------
        SetRecommendedSoftware "${SelectedSoftware}";
        res=0 # return-code 0 : Schritt ausgeführt
    else
        # Schritt beenden ---------------------------------------------------
        LOG "${txLOG_0300}"
        res=1 # return-code 1 : Schritt abgebrochen
    fi
    # Bildschirm löschen, Schrittzähler erhöhen und Rückgabewert Dialog -----
    clear
    StepID=$(expr $StepID + 1)
    return $res
}
DlgTimeZone() {
    # -----------------------------------------------------------------------
    # Dialog: Zeitzone und Synchronisation
    # -----------------------------------------------------------------------
    LOG "${txTITLE_00}${StepID}${txTITLE_05}"
    # Dialog anzeigen -------------------------------------------------------
    # TODO: stdout anpassen
    SelectedTimeZone=$(dialog  --output-fd 1\
      --backtitle "${APP_TITLE}" \
      --title "${txTITLE_00}${StepID}${txTITLE_05}" \
      --yes-label "${YES_LABEL}" \
      --cancel-label "${CANCEL_LABEL}" \
      --checklist "${txSTP_0501}${txSTP_0002}" \
      17 62 2 \
      "Zeitzone" "Zeitzone auf '${TIMEZONE}' setzen" on \
      "ntp" "Systemzeit mit Zeitserver synchronisieren" off
    )
    # Antwort speichern, Dialog bereinigen ----------------------------------
    TimeZone=$?
    dialog --clear
    # Dialog auswerten ------------------------------------------------------
    if [ $TimeZone = 0 ] 
    then
        SetTimeZone "${SelectedTimeZone}"
        res=0 # return-code 0 : Schritt ausgeführt
    else
        # Schritt beenden ---------------------------------------------------
        LOG "${txLOG_0500}"
        res=1 # return-code 1 : Schritt abgebrochen
    fi
    # Bildschirm löschen, Schrittzähler erhöhen und Rückgabewert Dialog -----
    clear
    StepID=$(expr $StepID + 1)
    return $res
}
DlgSshLogin() {
    # -----------------------------------------------------------------------
    # Dialog: SSH Login absichern
    # -----------------------------------------------------------------------
    LOG "${txTITLE_00}${StepID}${txTITLE_07}"
    # Dialog Optionen anzeigen ----------------------------------------------
    SSH_OPTIONS=$(dialog --output-fd 1\
      --backtitle "${APP_TITLE}" \
      --title "${txTITLE_00}${StepID}${txTITLE_07}" \
      --yes-label "${YES_LABEL}" \
      --cancel-label "${CANCEL_LABEL}" \
      --checklist "${txSTP_0701}${txSTP_0702}${txSTP_0002}" \
      19 62 4 \
      "KeyFile" "Zugang mit Passwort abschalten" on \
      "TimeOut" "Sitzung automatisch beenden" on \
      "AllowUser" "Nur berechtigte Nutzer zulassen" off 
    ) 
    # Antwort speichern, Dialog bereinigen, Antwort auswerten ---------------
    antwort=$?
    dialog --clear
    if [ $antwort = 0 ] 
    then
        # Dialog User Auswahl vorbereiten -----------------------------------
        local userlist=$(GetUserList | cut -d: -f1)
        local lstOptions=""
        local lstHeight=12
        i=0
        for item in $userlist
        do
            local lcUser="$(getent passwd $item | awk -F: '{print $1}')"
            local lcDesc="$(getent passwd $item | awk -F: '{print $5}')"
            local lcStat="$(if [ $i = 0 ]; then echo "on"; else echo "off"; fi)"
            lstOptions[$i]="$lcUser"
            i=$(expr $i + 1)
            lstOptions[$i]="$lcDesc"
            i=$(expr $i + 1)
            lstOptions[$i]="$lcStat"
            i=$(expr $i + 1)
            if [ $lstHeight -lt 19 ]; then
                lstHeight=$(expr $lstHeight + 1)
            fi
        done 
        # Dialog Userauswahl anzeigen ---------------------------------------
        SSH_USER=$( dialog --output-fd 1 \
          --backtitle "${APP_TITLE}" \
          --title "${txTITLE_00}${StepID}${txTITLE_06}" \
          --radiolist "${txSTP_0703}${txSTP_0002}" $lstHeight 62 4 \
          "${lstOptions[@]}" ) 
        # Antwort speichern, Dialog bereinigen, Schrittzähler erhöhen -------
        antwort=$?
        dialog --clear
        # Bildschirm löschen ------------------------------------------------
        clear
        # Dialog auswerten --------------------------------------------------
        if [ $antwort = 0 ] 
        then
            SetSshLogin "${SSH_USER}" "${SSH_OPTIONS}"
            res=0 # return-code 0 : Schritt ausgeführt
        else
            # Schritt beenden -----------------------------------------------
            LOG "${txLOG_0701}"
            res=1 # return-code 1 : Schritt abgebrochen
        fi
    else
        # Schritt beenden ---------------------------------------------------
        LOG "${txLOG_0700}"
        res=1 # return-code 1 : Schritt abgebrochen
    fi
    # Bildschirm löschen, Schrittzähler erhöhen und Rückgabewert Dialog -----
    clear
    StepID=$(expr $StepID + 1)
    return $res
}
DlgFirewallConfig() {
    # -----------------------------------------------------------------------
    # Dialog: Firewall einrichten
    # -----------------------------------------------------------------------
    LOG "${txTITLE_00}${StepID}${txTITLE_08}"
    # Dialog Optionen anzeigen ----------------------------------------------
    SelectedPorts=$(dialog --output-fd 1\
      --backtitle "${APP_TITLE}" \
      --title "${txTITLE_00}${StepID}${txTITLE_08}" \
      --yes-label "${YES_LABEL}" \
      --cancel-label "${CANCEL_LABEL}" \
      --checklist "${txSTP_0801}${txSTP_0802}" \
      18 62 2 \
      "22/tcp" "ssh Dienst" on \
      "21/tcp" "FTP-Server" off \
      "123/udp" "NTP-Server" off \
      "80/tcp" "WEB-Seiten" off \
      "443/tcp" "WEB-Seiten" off \
      "8080/tcp" "WEB-Seiten (HTTP-alt)" off \
      "81/tcp" "NGINX-Proxy Server (HTTP)" off \
      "3306/tcp" "mySQL-Server" off \
      "8086/tcp" "InfluxDB (HTTP-API)" off \
      "8088/tcp" "InfluxDB (RPC Service)" off \
      "2003/tcp" "InfluxDB (Graphite Input)" off \
      "4242/tcp" "InfluxDB (OpenTSDB)" off \
      "25826/udp" "InfluxDB (Collectd)" off \
      "445/tcp" "Samba-Server" off \
      "139/tcp" "Samba-Server (alt)" off \
      "137/udp" "Samba-Server (NetBIOS)" off \
      "138/udp" "Samba-Server (NetBIOS)" off \
      "631/tcp" "CUPS-Server (Drucker-Pool)" off \
      "53/tcp" "PiHole - DNS-Server" off \
      "80/tcp" "PiHole - Web-Interface (HTTP)" off \
      "443/tcp" "PiHole - Web-Interface (HTTPS)" off \
      "67/udp" "PiHole - DHCP-Server" off \
      "8000/tcp" "Portainer Edge Agent" off \
      "9000/tcp" "Portainer (WEB-GUI alt)" off \
      "9443/tcp" "Portainer (WEB-GUI https)" off \
      "9001/tcp" "Portainer (Deamon)" off \
      "9981/tcp" "TV-Head End (HTTP, Konfiguration, EPG)" off \
      "9982/tcp" "TV-Head End (TV-Streams)" off \
      "8096/tcp" "Jellyfin (WEB-GUI http)" off \
      "8920/tcp" "Jellyfin (WEB-GUI https)" off \
      "7359/udp" "Jellyfin (zero config)" off \
      "1900/udp" "Jellyfin (DLNA/UPnP)" off \
      "3389/tcp" "Rocrail (Server)" off \
      "8088/tcp" "Rocrail (Web Server)" off \
      "8051/udp" "Rocrail (Multibus-Protokoll)" off \
    )
    # Antwort speichern, Dialog bereinigen ----------------------------------
    FirewallDlg=$?
    dialog --clear
    # Dialog auswerten ------------------------------------------------------
    if [ $FirewallDlg = 0 ] 
    then
        # Firewall installieren und einrichten ------------------------------
        SetFirewallConfig "${SelectedPorts}"
        res=0 # return-code 0 : Schritt ausgeführt
    else
        # Schritt beenden ---------------------------------------------------
        LOG "${txLOG_0800}"
        res=1 # return-code 1 : Schritt abgebrochen
    fi
    # Bildschirm löschen, Schrittzähler erhöhen und Rückgabewert Dialog -----
    clear
    StepID=$(expr $StepID + 1)
    return $res
}
DlgLoginProtection() {
    # -----------------------------------------------------------------------
    # Dialog: Absicherung Login mit Fail2ban einrichten
    # -----------------------------------------------------------------------
    LOG "${txTITLE_00}${StepID}${txTITLE_09}"
    # Dialog anzeigen -------------------------------------------------------
    LoginSelection=$(dialog --output-fd 1\
      --backtitle "${APP_TITLE}" \
      --title "${txTITLE_00}${StepID}${txTITLE_09}" \
      --yes-label "${YES_LABEL}" \
      --cancel-label "${CANCEL_LABEL}" \
      --checklist "${txSTP_0901}${txSTP_0002}" \
      17 62 5 \
      "cli" "CLI-Login absichern" on \
      "ssh" "SSH-Login absichern" on
    )
    # Antwort speichern, Dialog bereinigen ----------------------------------
    LoginProtection=$?
    dialog --clear
    # Dialog auswerten ------------------------------------------------------
    if [ $LoginProtection = 0 ] 
    then
        # Ausgewählte Software installieren ---------------------------------
        SetLoginProtection "${LoginSelection}";
        res=0 # return-code 0 : Schritt ausgeführt
    else
        # Schritt beenden ---------------------------------------------------
        LOG "${txLOG_0900}"
        res=1 # return-code 1 : Schritt abgebrochen
    fi
    # Bildschirm löschen, Schrittzähler erhöhen und Rückgabewert Dialog -----
    clear
    StepID=$(expr $StepID + 1)
    return $res
}

# ===========================================================================
# Hauptprogramm
# ===========================================================================
# ---------------------------------------------------------------------------
# Schritt-Auswahl-Dialog 
# ---------------------------------------------------------------------------
STEP_OPTIONS=$(dialog --output-fd 1 \
  --backtitle "${APP_TITLE}" \
  --title "Schritt-Auswahl" \
  --checklist "Das Skript kann viele Einstellungen automatisch vornehmen. Welche Schritte sollen ausgeführt werden?\n(Mehrfachauswahl mit Leertaste)" 19 70 10 \
  "update"      "Systemupdate" on \
  "autoupdate"  "Automatische Updates" on \
  "software"    "Empfohlene Software" on \
  "keyboard"    "Tastatur-Layout" on \
  "timezone"    "Zeitzone/Timeserver" on \
  "adminuser"   "Administrativer Benutzer" on \
  "hostname"    "Hostname setzen" on \
  "ssh"         "SSH Login absichern" on \
  "firewall"    "Firewall einrichten" on \
  "loginprot"   "Login absichern (Fail2ban)" on \
  "ddos"        "DDoS-Schutz" off \
  "ipspoof"     "IP-Spoofing-Schutz" off \
  "arpspoof"    "ARP-Spoofing-Schutz" off \
  "prompt"      "Bash Prompt anpassen" on
)
dialog --clear

# ---------------------------------------------------------------------------
# System anpassen
# ---------------------------------------------------------------------------
StepID=1
CheckPrepared             # Ausführung als root, Dialog installiert
if [ $? -ne 0 ]; then exit; fi

# ---------------------------------------------------------------------------
# Dialoge anzeigen und Funktionen aufrufen
# ---------------------------------------------------------------------------
# Dialog: Systemupdate einrichten
if [[ $STEP_OPTIONS == *update* ]]; then
    ShowYesNoDlg 10 62 "${txTITLE_01}" "${txSTP_0101}" SetSystemUpDate
fi
# Dialog: Automatisches Update einrichten
if [[ $STEP_OPTIONS == *autoupdate* ]]; then
    ShowYesNoDlg 10 56 "${txTITLE_02}" "${txSTP_0201}" SetAutoUpdate
fi
# Dialog: Software
if [[ $STEP_OPTIONS == *software* ]]; then
    DlgRecommendedSoftware
fi
# Dialog: Tastatur Layout anpassen
if [[ $STEP_OPTIONS == *keyboard* ]]; then
    ShowYesNoDlg 10 62 "${txTITLE_04}" "${txSTP_0401}${txSTP_0001}" SetKeyboardLayout
fi
# Dialog: Zeitzone / Timesever
if [[ $STEP_OPTIONS == *timezone* ]]; then
    DlgTimeZone
fi
# Dialog: Administativer Benutzer einrichten 
if [[ $STEP_OPTIONS == *adminuser* ]]; then
    ShowYesNoDlg 14 62 "${txTITLE_06}" "${txSTP_0601}${txSTP_0602}$(GetUserList withroot | cut -d: -f1)\n${txSTP_0001}" SetAdminUser
fi
# Dialog: Hostname setzen
if [[ $STEP_OPTIONS == *hostname* ]]; then
    ShowYesNoDlg 17 60 "${txTITLE_10}" "${txSTP_1001}${txSTP_0001}" SetHostname
fi
# Dialog: SSH Login absichern
if [[ $STEP_OPTIONS == *ssh* ]]; then
    DlgSshLogin
fi
# Dialog: Firewall
if [[ $STEP_OPTIONS == *firewall* ]]; then
    DlgFirewallConfig
fi
# Dialog: Login absichern
if [[ $STEP_OPTIONS == *loginprot* ]]; then
    DlgLoginProtection
fi
# Dialog: Ddos Protection einrichten
if [[ $STEP_OPTIONS == *ddos* ]]; then
    ShowYesNoDlg 18 70 "${txTITLE_11}" "${txSTP_1101}" SetDdosProtection
fi
# Dialog: IpSpoofing Protection einrichten
if [[ $STEP_OPTIONS == *ipspoof* ]]; then
    ShowYesNoDlg 18 70 "${txTITLE_12}" "${txSTP_1201}" SetIpSpoofingProtection
fi
# Dialog: ArpSpoofing Protection einrichten
if [[ $STEP_OPTIONS == *arpspoof* ]]; then
    ShowYesNoDlg 15 62 "${txTITLE_13}" "${txSTP_1301}" SetArpSpoofingProtection
fi
# Dialog: Bash Prompt anpassen
if [[ $STEP_OPTIONS == *prompt* ]]; then
    ShowYesNoDlg 15 62 "${txTITLE_14}" "${txSTP_1401}" SetPrompt
fi
# Bildschirm löschen --------------------------------------------------------
clear
# ---------------------------------------------------------------------------
