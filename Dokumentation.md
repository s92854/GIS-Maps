# Dokumentation zur App GIS-Maps
## Planung
<img width="600" title="Abb. 1 - Planung" src="https://github.com/s92854/GIS-Maps/assets/134683810/d4f4bc20-c07f-4253-96f0-e4913faa3147">

> Abb. 1 - Die Planung

Die Aufgabenstellung eine GeoIT-App auf Basis von IoT/GeoIoT, iOS|Android/LBA und/oder Geowebinfrastrukturen abzugeben ließ viel Platz für Kreativität.<br>Ich wollte bereits von Anfang an die Google Maps Services verwenden, da Google damit eine einheitliche, unkomplizierte und versionskompatible API zur Verfügung stellt.

&nbsp;

## Die Programmierung

<img width="600" title="Abb. 2 - Programmierung" src="https://github.com/s92854/GIS-Maps/assets/134683810/f84df205-e135-4de8-80d1-779e2ca3ed0c">

> Abb. 2 - Die Programmierung

### Die Karte

Zu Beginn der Programmierarbeiten musste ich einen API-Key für die Google-Services anfordern, wofür wiederum ein Google-Cloud-Konto notwendig ist, welches 3 Monate kostenlos nutzbar ist. Anschließend sind die zu verwendenden APIs zu konfigurieren. Also aktivierte ich die Maps-, Geolokalisierungs-, Geocodierungs- und Places-API.

Das Grundgerüst der App, also die Google Maps Karte, war schnell gebaut. Anschließend konnte ich weitere Funktionen einfügen. Die erste ist die Geolokalisierung. Dazu muss der Nutzer den Standortzugriff durch die App manuell erlauben. Nachdem der Standort abgerufen wurde, übergibt die Funktion Latitude und Longitude an eine weitere Funktion, die dann einen benutzerdefinierten Marker genau an dieser Stelle platziert.

Um das Geocoding zu implementieren, entschied ich mich für eine Suchleiste, die sich zwar fest in der Mitte oben auf der Karte befindet, jedoch dynamisch öffnet und schließt, sobald man darauf klickt. Für das weiße, abgerundete Design orientierte ich mich an der offiziellen Google-Suchleiste, jedoch mit leichten Anpassungen.

Um nun noch eine Routenfunktion zur Karte hinzuzufügen, implementierte ich das Polylines-Paket. Wenn der Benutzer auf einen beliebigen Punkt in der Karte klickt, soll eine Polyline vom aktuellen Standort zum angeklickten Punkt erstellt werden, basierend auf den in Google Maps verzeichneten Straßen. Auch hier soll ein eigener Marker verwendet werden.

Mithilfe eines FloatingActionButtons (FAB) soll die aktuelle Position aktualisiert werden. Der FAB bekam ein eigenes Icon und wurde unten links mit einem Offset platziert (siehe Abb. 3). Aufgrund der Konfiguration und erstellten Variablen wäre ein Wechsel der Position des FABs zu jeder Zeit problemlos möglich.

Ich fand heraus, dass das Theme der Karte durch JSON-Dateien veränderbar ist. Also erstellte ich eine Funktion, die durch einen weiteren Button mittig unten das Theme ändert (siehe Abb. 3). Wenn man auf den Button klickt, soll sich eine Leiste mit den verfügbaren Themes öffnen.<br>So gut wie jede Kartenanwendung kann auch auf das Satellitenbild umschalten. Jedoch ist das programmiertechnisch ein Problem, da das Satellitenbild nicht über eine JSON-Datei geladen wird. Nach einer Weile fand ich jedoch eine Lösung zur Implementierung dieser Funktion.

<img width="600" title="Abb. 3 - Buttons" src="https://github.com/s92854/GIS-Maps/assets/134683810/8258dab7-d1e0-420f-83f1-8a01dfcbcc0d">

> Abb. 3 - Buttons

&nbsp;

### Die App Bar

Um der App einen modernen Look zu verpassen, suchte ich nach Merkmalen anderer moderner Apps. Egal ob Discord, Instagram, WhatsApp oder sogar DBNavigator, alle haben eine App Bar. Also implementierte und personalisierte ich meine App Bar (siehe Abb. 4).

<img width="600" title="Abb. 4 - App Bar" src="https://github.com/s92854/GIS-Maps/assets/134683810/40427991-92f3-446d-850f-eecb3c345e41">

> Abb. 4 - Die App Bar

Als Startseite richtete ich eine farbenfrohe Seite mit ein paar Informationen bezüglich der App ein. Das BHT-Logo darf hier natürlich nicht fehlen😉.

<img height="600" title="Abb. 5 - Startseite" src="https://github.com/s92854/GIS-Maps/assets/134683810/c85fa7db-848c-48c7-b4a4-ef46d6b0c7f5">

> Abb. 5 - Die Startseite

Die zweite und mittige Funktion (die Hauptfunktion der App) ist die Karte. Die Features wurden bereits oben unter dem Punkt [Die Karte](https://github.com/s92854/GIS-Maps/blob/master/Dokumentation.md#die-karte) erläutert.

<img height="600" title="Abb. 6 - Die Karte" src="https://github.com/s92854/GIS-Maps/assets/134683810/03163607-1993-423a-a822-8ee0b46083f9">

> Abb. 6 - Die Karte

Ganz rechts befindet sich die Infoseite, in der weitere Details zur App aufgelistet sind.

<img height="600" title="Abb. 7 - Die Infoseite" src="https://github.com/s92854/GIS-Maps/assets/134683810/78c542c6-da76-44aa-905d-726c14da8e2c">

> Abb. 7 - Die Infoseite

