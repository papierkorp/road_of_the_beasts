# Project

- **Road of the Beasts:** deterministische, rundenbasierte Monsterkämpfe; offline, Einzelspieler, am Handy (Querformat) wie am PC spielbar. Der Kampf ist das Spiel: Alles drumherum (Hub, Kultivierung, Handwerk) existiert nur, um den Kampf zu verändern oder zu verbessern; Vorschläge daran messen.
- **Designziel:** „Easy to learn, hard to master“: wenige, einheitliche und gut lesbare Regeln; Tiefe entsteht aus Kombinationen und Entscheidungen, nicht aus Sonderregeln. Vorschläge daran messen, Ausnahmen begründen.
- **Battle-Ziele:** stehen in [docs/battle.md §1](docs/battle.md#1-goals-and-pillars); Regel-, Inhalts- und Preisvorschläge daran messen.
- **Rahmen:** [docs/vision.md](docs/vision.md) beschreibt das Spiel im Ganzen und geht den Regeldateien vor; Vorschläge für Hub und Ingame-Kampf daran messen.
- **Fokus:** Der Battle-Kern steht. Zuerst wird der Rahmen fertig geklärt (Säulen, ihre Ressourcen und Quellen), dann werden die Regeldateien und Aufgaben daran angeglichen. Der Multiplayer-Kampf ist kein Arbeitsziel; der Rahmen darf Entscheidungen des Ingame-Kampfs begründen, nie die des Multiplayer-Kampfs.
- **Zwei Kämpfe, strikt getrennt:** Der „Multiplayer-Kampf“ (Multiplayer-Modus: Draft-Sandbox im Godot-Build, gleiche Punkte für alle) und der „Ingame-Kampf“ (gewachsene Monster, eigene Battlegrounds, Board-Events) teilen nur die Kernregeln aus `docs/battle.md`. Regeln, Inhalte, Messungen und Balance des einen sind kein Grund für Entscheidungen im anderen; bei jedem Vorschlag und jedem Lauf den Kampf nennen.
- **Begriffe:** „das Spiel“ meint das Spiel mit Hub und Fortschritt.

## Safety

- **Branch:** `main`. Vor Änderungen Branch und Git-Status prüfen; bei anderem Branch anhalten und nachfragen, nicht selbst wechseln.
- **Schreibbereich:** `docs/`, diese `CLAUDE.md` und der Ordner `godot/`. Keine Änderungen an `tools/html_prototype/` oder anderen Pfaden.
- **Git:** keine Commits, Branchwechsel, Pulls oder Resets ohne ausdrücklichen Auftrag. Nutzeränderungen erhalten.
- **Simulationsläufe nur auf ausdrücklichen Auftrag:** keine Bot-, Progression-, Discovery- oder Vergleichsserien aus eigenem Antrieb, auch nicht zur Absicherung und nicht als stiller Teil einer Rückfrage-Option. Abgesichert wird mit den Regeltests (gdUnit) und kurzen gezielten Prüfungen; eine Serie höchstens vorschlagen.
- **Ergebnisse von Läufen:** immer mittlere Runden und die Zahl der Kämpfe unter 3 und über 5 Runden nennen. Läufe liefern Indizien, keine Freigabe von Regeln, Preisen oder Balance.
- **Validierung:** Dokumentprüfung, Rechenproben, Tests und Bot-Läufe sind keine Gameplay-Validierung.
- **Daten:** genau ein Datenordner `godot/data/` mit einem Unterordner je Art; keine zweiten Skill-, Kit- oder Preis-Sätze; keine Python- oder JSON-Dateien im Projekt. Nicht mehr Gebrauchtes löschen oder auf `archived` setzen.
- **CPU:** volle Auslastung ist erlaubt.
- **Tasten:** Jede Taste und jeder Mausknopf ist eine Aktion in der Input Map (`godot/project.godot`). Im Code nie Tasten abfragen (`KEY_…`, `MOUSE_BUTTON_…`), sondern Aktionen; Tastennamen in Texten kommen aus `UiTheme.key_text(aktion)`.
- **Export-Felder:** Ein `@export`-Feld mit Packed-Array-Typ bekommt nie ein Array-Literal als Startwert (`= []`): Der Godot-Export verwirft sonst den gespeicherten Wert, und nur der exportierte Build zeigt es. Stattdessen `Array[String] = []` oder kein Startwert; Details in [godot/README.md](godot/README.md#adding-content). Datenfehler, die nur am Handy auftreten, zuerst gegen das exportierte Paket prüfen.
- **Werkzeuge:** [godot/tools/README.md](godot/tools/README.md); Build und Schalter: [godot/README.md](godot/README.md).

## Dokumente

| Datei | Zuständig für | Richtwert (Zeichen) |
|---|---|---|
| [`docs/battle.md`](docs/battle.md) | Kernregeln beider Kämpfe (Multiplayer-Eigenes dort gekennzeichnet): Ablauf, Zeitpunkte, Brett, Rollen von Boden/Zone/Prop, Schaden, Verschiebung | 30 000 |
| [`docs/battle_ingame.md`](docs/battle_ingame.md) | Regeln, die nur der Ingame-Kampf hat: Battlegrounds, Board-Events, eigene Skills und Funktionen | 15 000 |
| [`docs/skills.md`](docs/skills.md) | Regeln der Skills: Kit, Skill-Karte, Formen, Bewegungsarten, Passives, Slots | 20 000 |
| [`docs/monsters.md`](docs/monsters.md) | Regeln der Monster: Stats, Kalkulation, Kins, Seltenheit, Wachstum | 15 000 |
| [`docs/content.md`](docs/content.md) | Alle Inhaltsentwürfe: Böden, Zonen, Props, Skills, Kits, Monster | 20 000 |
| [`docs/vision.md`](docs/vision.md) | Rahmen des Spiels (Hub und Ingame-Kampf) mit Diagrammen; geht den Regeldateien vor | 15 000 |
| [`docs/overworld.md`](docs/overworld.md) | Das Spiel um den Kampf: Tag, Kosten, Monster erhalten, Fortschritt, Kultivierungssystem, Tamer-Skills, Güter | 25 000 |
| [`docs/architecture.md`](docs/architecture.md) | Technische Zielstruktur | — |
| [`docs/contract.md`](docs/contract.md) | Vertrag des neu gebauten Kampfs: Formate, Aktionen, Events, lesbarer Zustand | eingefrorener Entwurf |
| [`docs/decisions.md`](docs/decisions.md) | Entscheidungsprotokoll: Entscheidung, Verworfenes, Grund | wächst nur zeilenweise |
| [`docs/temp_todo.md`](docs/temp_todo.md) | Übersicht: Stand, offene Fragen, Aufgabentabelle | 10 000 |
| [`docs/todo/`](docs/todo/) | Eine Datei je Aufgabe, in Ordnern nach Status und Epic | 6 000 je Aufgabe |
| [`docs/prompts.md`](docs/prompts.md) | Wiederverwendbare Arbeitsaufträge (deutsch) | — |
| [`docs/simulation_log.md`](docs/simulation_log.md) | Messreihen, nur anhängen | — |

## Regeln für die Dokumente

1. **Nur der aktuelle Stand:** Regel- und Inhaltsdateien enthalten keine Datumsangaben, keine Entscheidungsgeschichte, kein „früher/jetzt“ und keine verworfenen Varianten.
2. **Ersetzen statt ergänzen:** Eine neue Entscheidung ersetzt den alten Text.
3. **Nach jeder Nutzerentscheidung:** den zuständigen Abschnitt ersetzen und eine Zeile in `docs/decisions.md` anhängen. Daten und Entscheidungsgeschichte stehen ausschließlich dort.
4. **Vor einem Vorschlag,** der eine Regel ändert oder ein beschlossenes Thema neu öffnet: `docs/decisions.md` prüfen. Verworfenes nur bei neuem Anlass wieder vorschlagen.
5. **Jede Regel steht genau einmal;** anderswo wird verlinkt. Regeln stehen in den Regeldateien, konkrete Werte und Namen in `content.md`.
6. **Offene Fragen, Alternativen und Übergaben** stehen ausschließlich in der Aufgabenverwaltung (`docs/temp_todo.md`, `docs/todo/`). Regeldateien nennen eine Lücke höchstens als „not defined“.
7. **Status einmal je Abschnitt oder Tabelle** kennzeichnen (beschlossen, working value), nicht an jeder Aussage.
8. **Testschalter, Messhinweise und ungenutzter Code** gehören nicht in die Regeldateien, sondern in die Godot-READMEs oder als Aufgabe in `docs/todo/`.
9. **Umfang:** Überschreitet eine Datei ihren Richtwert, wird zuerst gekürzt oder geteilt, dann erst ergänzt.
10. **Aufgaben:** eine Datei je Aufgabe; ein Statuswechsel verschiebt die Datei in den passenden Ordner und aktualisiert die Tabelle in `docs/temp_todo.md`. Erledigtes wandert nach `done/`, später nach `archive/`.
11. **Diese `CLAUDE.md`** enthält nur dauerhafte Arbeitsregeln: keine Spielregeln, Zahlen oder Zwischenstände.
12. **`docs/simulation_log.md`** wird nur angehängt; bestehende Einträge werden nicht geändert.
13. **`docs/contract.md`** ist ein eingefrorener Entwurf: bei Regeländerungen nicht mitpflegen. Beim Start des Neubaus wird er einmal gegen die fertigen Regeln überarbeitet und dem Nutzer zur Abnahme vorgelegt.

## Working style

- **Sprache:** Chat Deutsch, knapp und verständlich; Dokumente unter `docs/` Englisch (Ausnahme: `docs/prompts.md`).
- **Wiedereinstieg:** `docs/temp_todo.md` lesen, dann gezielt die zuständigen Abschnitte. `docs/decisions.md` ist keine Pflichtlektüre beim Einstieg (siehe Regel 4).
- **Priorität:** aktuelle Nutzeranweisung vor älterer Übergabe.
- **Entscheidungen:** grundlegendes Gameplay mit dem Nutzer klären; Beschlossenes nur bei neuem Anlass erneut öffnen.
- **Rückfragen:** für Nutzerentscheidungen das AskUserQuestion-Tool verwenden (Empfehlung zuerst, gebündelt). Nicht nach dem nächsten Arbeitsschritt fragen, sondern ihn aus der Aufgabenliste vorgeben.
- **Tempo:** Der Nutzer will Änderungen in der Regel schnell umgesetzt haben; keine ungefragten Nebenarbeiten.
- **Entwürfe:** neue Zahlen und Empfehlungen als Entwurf kennzeichnen; daraus keine Freigabe ableiten.
- **Lücken:** fehlende Regeln und Widersprüche benennen und gebündelt vorlegen, keine Standardannahmen erfinden.
- **Darstellung:** kurzer Überblick, präzise Regeln, Tabellen für Vergleiche und Referenzwerte; Bedingungen, Ausnahmen, Einheiten und Status vollständig erhalten; Battle-AP, Tages-AP, Statpunkte, Schaden und XP trennen.
- **Abschluss:** Aufgaben erst bei erfüllter Abschlussbedingung nach `done/` verschieben. Vor dem Bericht Links, `git diff --check` und betroffene Tests prüfen und berichten, was tatsächlich geprüft wurde.
