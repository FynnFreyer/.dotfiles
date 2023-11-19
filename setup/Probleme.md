# Suspend on Session Unlock

Der Laptop ist an der Docking-Station, verbunden mit mehreren Bildschirmen, aber zugeklappt.
Wenn auf SDDM das Login Passwort eingegeben wird dauert es einen kurzen Moment bis KWin übernimmt.
In diesem Moment geht der Laptop in den Schlafzustand.

# Touchpad Wisch-Gesten

Sind (nach sehr kurzer Recherche) anscheinend nicht konfigurierbar, außer man kompiliert sein eigenes KWin.
Touchegg und Touche funktionieren nicht auf Wayland.

# Kontact

Bei Thunderbird kann man ein Profil exportieren, indem man den entsprechenden Profilordner kopiert.
Wie kann ich das gleiche bei Kontact erreichen?

# WPA3 Netzwerke

Müssen über `nmcli` hinzugefügt werden, da die GUI unter KDE abkackt.

    nmcli --ask con

# Overview auf Meta-Taste

Der Overview-Effekt kann nur über die Kommandozeile, bzw. durch editieren von `kwinrc` mit der Meta-Taste assoziiert werden.
Antwort übernommen von [Stack-Overflow](https://askubuntu.com/a/1392753).

    kwriteconfig5 --file kwinrc --group ModifierOnlyShortcuts --key Meta "org.kde.kglobalaccel,/component/kwin,,invokeShortcut,Overview"
    qdbus org.kde.KWin /KWin reconfigure


# Timed Darkmode

Es existiert ein [Bug-Report](https://bugs.kde.org/show_bug.cgi?id=408563) bei KDE, um dieses Feature zu implementieren, aber momentan muss entweder [Yin-Yang](https://github.com/oskarsh/Yin-Yang) (aktivere Entwicklung) oder [Koi](https://github.com/baduhai/Koi) (verfügbar via `nix`) installiert werden.

# KWin Scripts

Um einen guten Workflow zu haben sind einige KWin Skripte nötig.

- Dynamic Workspaces

# Keyboard-Shortcuts

Eigene Keyboard-Shortcuts können in `kglobalshortcutsrc` und `khotkeysrc` definiert werden.

