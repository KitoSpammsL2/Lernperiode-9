# Lernperiode-9



## 20.2.2026

Heute habe ich ein Backend für mein Godot-Spiel implementiert, damit die Coins dauerhaft gespeichert werden und nach einem Neustart nicht verloren gehen. Ich habe mich für ASP.NET Core mit C# entschieden, weil ich bereits mit C# arbeite und es gut zu meinem Projekt passt. Als Datenbank habe ich SQLite gewählt, da sie einfach zu verwenden ist und keine zusätzliche Serverinstallation benötigt. Ich habe verschiedene HTTP-Endpunkte erstellt, über die das Spiel Coins laden und speichern kann. Anschließend habe ich mein Godot-Spiel über HTTPRequest mit dem Backend verbunden und getestet, ob die Coins korrekt gespeichert und wieder geladen werden. Nach mehreren Tests konnte ich bestätigen, dass das System funktioniert und die Coins persistent gespeichert bleiben. Beim nächsten Mal möchte ich am eigentlichen Spiel weiterprogrammieren und zusätzlich ein Ziel sowie einen Timer einbauen, um das Gameplay interessanter und strukturierter zu machen.

<img width="525" height="307" alt="Screenshot 2026-02-20 110948" src="https://github.com/user-attachments/assets/f47b39ca-aa87-428a-be9c-7270eddb2222" />

<img width="495" height="308" alt="Screenshot 2026-02-20 111201" src="https://github.com/user-attachments/assets/9c4d0066-5208-4c4b-95d5-026e403f72d5" />


## 27.2.2026 

 - [x] Enemy hinzufügen
 - [x] Ein Score hinzufügen
 - [x] Audio hinzufügen
 - [x] Mehr Animationen hinzufügen für den PLayer. (Links, rechts)

Heute habe ich einen Enemy hinzugefügt, der sich zwischen zwei Wänden bewegt. Ich habe noch verschiedene Animationen hinzugefügt, wie links und rechts gehen, und eine neue Todesanimation. Ich habe das Spiel eigentlich fertig, ich muss nur noch ein bisschen weiterbauen und ein Ziel machen. Danach kann ich den Timer speichern und ein Leaderboard erstellen.

 ## 6.03.2026

 - [X] Die Map erweitern
 - [X] Ziel erstellen.
 - [ ] Timer machen denn man sieht
 - [ ] Die Zeit wird gepseichert.

Also ich habe die Map erweitert und ein Ziel erstellt. Jedoch bin ich mir nicht sicher, warum es nicht funktioniert. Eigentlich sollte es funktionieren, aber im Moment funktioniert es noch nicht. Ich habe auch noch eine andere Idee: Ich möchte einen Startbildschirm machen. Dort soll man den Top-Scorer und den Namen sehen. Man kann dort seinen eigenen Namen eingeben und dann eine Runde starten. Während der Runde wird die Zeit gestoppt. So sollte dann etwa das Endprodukt aussehen, und das wird später alles gespeichert.


## 13.03.2026

- [x] Ziel debuggen
- [x] Timmer erstellen
- [x] Speichern von der Zeit
- [ ] Zeit wird in Reihen folge gemacht

Ich bin sehr zufrieden mit dem, was ich geschafft habe. Ich habe mein Ziel erreicht und konnte den Fehler erfolgreich debuggen. Außerdem habe ich einen Timer erstellt, der jetzt oben links angezeigt wird. Die Zeit wird auch im SQL Server gespeichert. Ich muss noch hinzufügen, dass die Zeit sortiert wird, aber ich glaube, das wird kein großes Problem sein.


## 20.03.2026

- [ ] Zeit wird sortiert
- [ ] Es zeift die top 3 an
- [ ] ein Start Knopf machen
- [ ] Namen eingeben beim Start
