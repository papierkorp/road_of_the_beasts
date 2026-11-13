# Project

- **Road of the Beasts:** deterministische, rundenbasierte Monsterkämpfe mit Management und Kultivierung.
- **Designziel:** „Easy to learn, hard to master“: wenige, einheitliche und gut lesbare Regeln; Tiefe entsteht aus Kombinationen und Entscheidungen, nicht aus Sonderregeln. Bei Designvorschlägen und Mechanik-Abwägungen als Maßstab nutzen (Ausnahmen und Sonderfälle begründen).
- **Battle-Ziele (Nutzervorgabe 2026-11-12, ausformuliert in `docs/gdd_battle.md` §1.2):** Spielerentscheidungen haben Einfluss und Folgen; deterministisch; kurze Kämpfe (rund 15 Runden sind schon sehr lang); taktisch statt Skill-Spam; jeder Skill je nach Situation sinnvoll; Niederlagen fühlen sich wie eigene Fehler an, nicht unfair; einfach zu lernen, keine versteckten Fähigkeiten. Regel-, Inhalts- und Preisvorschläge daran messen.
- **Fokus (Nutzervorgabe, bekräftigt 2026-11-12):** Das Battle ist der Kern des Spiels und wird zuerst fertig. Die Overworld ist bis dahin nachrangig: nicht daran arbeiten, sie nicht als Grund für Battle-Entscheidungen heranziehen und beim Battle-Umbau nicht schonen. Sie wird erst an das Battle angepasst, wenn es steht und der Nutzer damit zufrieden ist, oder wenn er ausdrücklich etwas anderes sagt. Offene Overworld-Aufgaben bleiben in `docs/temp_todo.md` erhalten, werden aber nicht vorgezogen.
- **Auftrag:** GDDs überarbeiten, vervollständigen und konsistent halten; Spielimplementierung nur im Rahmen einer ausdrücklichen Nutzerfreigabe (siehe Safety).

## Safety

- **Branch:** `main` für GDD-Arbeit (Nutzerfreigabe 2026-11-12; der frühere Branch `docs/update_gdd` wird nicht mehr verlangt) und für den Battle-Implementierungsauftrag (Nutzerfreigabe 2026-11-11). Vor Änderungen Branch/Git-Status prüfen; bei anderem Branch anhalten und nachfragen, nicht selbst wechseln.
- **Schreibbereich:** `docs/`, die Pflege dieser `CLAUDE.md` und der gesamte Ordner `godot/` (Nutzerfreigabe 2026-11-12: das ganze Godot-Spiel ist ein Experiment, Battle wie Overworld dürfen umgebaut werden, Altes muss nicht erhalten bleiben). Keine Änderungen an `tools/html_prototype/` oder anderen Pfaden.
- **Git/Nutzerarbeit:** keine Commits, Branchwechsel, Pulls, Resets oder sonstigen eingreifenden Git-Aktionen ohne ausdrücklichen Auftrag. Nutzeränderungen erhalten; nichts automatisch synchronisieren.
- **Validierung:** Prototypen bestätigen nicht das aktuelle Design; Dokumentationsprüfung und Rechenproben sind keine Gameplay-/Balancevalidierung.
- **Godot-Stand vs. GDD:** Der Godot-Build darf den GDDs vorauslaufen, wenn der Nutzer eine Variante dort ausprobieren will; solche Abweichungen stehen in `godot/README.md` und als Aufgabe in `docs/temp_todo.md` (derzeit die Testschalter in `godot/battle/core/battle_experiment.gd`, standardmäßig aus: Push über 2 Felder, Beast/Spirit-Verschiebung, Druck ohne Schaden, Fallen-Uhr, Start auf der hintersten Reihe, Zug aufschieben, Surge-Zeitpunkt-Varianten; seit den Nutzerentscheidungen 2026-11-12/13 Standard des Builds und Arbeitsentwurf in den GDDs: Boden-Uhr 2 Runden, eine Falle je Fallen-Skill, keine Schildzonen in Kits, vorrückende KI, Wellsprings mit Umzingeln (Battle §4.2), TPR ab Runde 2, später Druck nur ohne Quellenhalter, neue Stat-Preise und vier Rahmen (Monsters §2.2); als Build-Test ohne GDD-Entwurf seit 2026-11-13: Movement-Skills mit voller Movement-Weite, alle außer Run 2 AP; Fallen-Surges, Brettrand-Schaden und Stachel-Props stehen seit 2026-11-12 als Arbeitsentwurf in den GDDs, T38). Eine GDD-Regel wird daraus erst durch ausdrücklichen Beschluss.
- **Werkzeuge und Simulationen:** `godot/tools/` (Bot-Läufe `sim.gd`, Monster-Vergleich `compare.gd`; Kontext und Grenzen in `godot/tools/README.md`). **Zweck (Nutzervorgabe 2026-11-12):** ausprobieren, ob das Gameplay Spaß macht und sinnvoll ist, und herausfinden, welche Skill-Preise nötig sind. Die Skill-Kalkulation ist nicht fest: Simulationen ignorieren Preise und prüfen Monster nicht gegen Budgets. Dasselbe gilt für die Stat-Kalkulation (Nutzervorgabe 2026-11-13): Stat-Preise, Budgets und Rahmen in `docs/gdd_monsters.md` §2.2 sind ungetestete Anfangswerte, nichts davon ist fixiert; sie werden zusammen mit Regeln und Skills über das Gameplay gefunden, ebenso welche Skills es überhaupt gibt und wie sie auszubalancieren sind. Läufe liefern Indizien, keine Balance-/Preisfreigabe und keine Regelquelle. **Daten:** genau ein Datenordner `godot/data/` mit einem Unterordner je Art (`monsters/`, `skills/`, `zones/`, `grounds/`, `props/`, `tamer/`; Nutzeraufträge 2026-11-12: keine zweiten Skill-, Zonen-, Kit-, Build- oder Preis-Sätze). Der aktuelle Rechenwert steht als Feld `internal_calc_cost` direkt in der jeweiligen Ressource (Autorennotiz, keine Regel); es gibt keinen Preisordner und keinen Preisrechner. Skills und Monster tragen `content_status` = `approved`/`draft`/`experiment`/`test`/`simulation`/`archived`; der Filter sitzt in `ContentStatus.in_game` (aufgerufen von `GameData` und `BattleContent`), das Spiel verwendet nur `approved`, `draft` und `experiment` (Nutzerentscheidung 2026-11-13: Mechaniken zum Ausprobieren im Spiel, z. B. seltene, teure AP-/TPR-Skills; in der Übersicht sichtbar, keine GDD-Regel). Nicht mehr Gebrauchtes löschen (Git ist die Historie) oder auf `archived` setzen. Keine Python- oder JSON-Dateien im Projekt; die Werkzeuge bleiben schlank. `sim.gd`-Läufe in `docs/simulation_log.md`, Vergleichstabellen und Folgerungen in `docs/temp_todo.md` (T13) festhalten; offene Regeln nicht erfinden.

## Working style

### Einstieg und Zusammenarbeit

- **Sprache:** Chat Deutsch, knapp und verständlich; Dokumentation unter `docs/` Englisch, einschließlich `temp_todo.md`; Ausnahme: wiederverwendbare Chat-Prompts samt Unterüberschriften unter `AI Prompts` Deutsch. Englische GDD-Terminologie/Bezeichner konsistent halten; deutsche Bestandsabschnitte bei Überarbeitung übersetzen, ohne Regeln oder Entscheidungsstatus zu ändern.
- **Wiedereinstieg:** in `docs/temp_todo.md` Verwendung, aktuelle Übergabe und betroffene Aufgabe lesen; danach gezielt zuständige GDD-Abschnitte.
- **Priorität:** aktuelle Nutzeranweisung vor älterer Übergabe; veraltete Arbeitsanweisungen korrigieren.
- **Entscheidungen:** grundlegendes Gameplay mit dem Nutzer klären; beschlossene Prinzipien nur bei neuem Anlass erneut öffnen.
- **Rückfragen:** Wo eine Nutzerentscheidung nötig ist, das AskUserQuestion-Tool verwenden (Optionen mit Empfehlung zuerst, Entscheidungen gebündelt), nicht als Fließtextfrage im Chat. Nicht nach dem nächsten Arbeitsschritt fragen: diesen selbst aus Übergabe und Aufgabenliste vorgeben.
- **Entwürfe:** zusammengehörige Kosten/Rechenbeispiele gesammelt ausarbeiten. Neue Zahlen/Empfehlungen als Entwurf kennzeichnen; keine Freigabe neuer Mechaniken oder grundlegender Gameplayänderungen daraus ableiten.
- **Lücken:** fehlende Regeln/Widersprüche benennen, keine Standardannahmen erfinden. Budget-Fit ist keine Content-/Balancefreigabe.

### Gemeinsame Darstellung für Menschen und AI-Agents

- **Eine Quelle:** gemeinsame Markdown-Spezifikation nach Themen, nicht getrennt nach Menschen/AI.
- **Aufbau:** kurzer Überblick, präzise Regeln, kompakte Vergleichs-/Referenztabellen. Längeren Fließtext durch thematische Stichpunkte ersetzen, wenn dieselbe Information schneller erfassbar wird.
- **Kompaktheit:** zusammengehörige Aussagen bündeln, nicht jeden Satz einzeln aufzählen. Unterlisten/Zwischenlabels nur für echte Unterstruktur; kurze Überblicks-/Begründungssätze dürfen Fließtext bleiben, Abläufe bei Bedarf nummerieren.
- **Informationserhalt:** Bedingungen, Ausnahmen, Negationen, Einheiten und Entscheidungsstatus vollständig bewahren. Tatsächlichen Zeichenumfang prüfen: mehr Zeilen sind keine Kürzung; keine Regeln zugunsten knapper Stichworte streichen.
- **Darstellungswahl:** Tabellen für Vergleiche/Referenzwerte, nicht für jeden Text. Beispiele/strukturierte Daten nur für besseres Verständnis oder Vollständigkeitsprüfung; sie folgen den zentralen Regeln und bilden keine unabhängige Regelversion.
- **Präzision:** Bedingungen, Kosten, Grenzen und Auflösungsreihenfolge eindeutig; Battle-AP, Tages-AP, Konstruktionspunkte, Schaden und EP trennen.
- **Status:** beschlossen, Arbeitsentwurf und noch nicht validiert sichtbar unterscheiden. Abschnitts-/Tabellenstatus statt wiederholter Warnungen an jeder Aussage.
- **Zuständigkeit:** jede Regel, Formel, Preisliste und Datenstruktur hat genau einen zuständigen Abschnitt. Anderswo verlinken und nur die eigene Schnittstelle beschreiben, keine Regelkopien.
- **Skills:** allgemeine Regeln/Kosten über präzise Effekt-/Skillklassen statt Namenslisten beschreiben. Konkrete Skills samt Ausnahmen einmal zentral in `docs/gdd_skills.md` definieren; Namen sonst nur für nötige Inhaltsreferenzen, abgegrenzte Referenzrechnungen oder konkrete offene Aufgaben. Skill-Ausnahmen nie auf ganze Klassen übertragen.
- **Navigation:** stabile, aussagekräftige Überschriften und relative Markdown-Links; nach Verschiebungen Links/Abschnittsverweise aktualisieren.

### Überarbeitung und Abschluss

- **Bereinigung:** eindeutig verworfene/ersetzte Ideen dürfen entfallen; bei unklarem Status erst klären. Keine unnötigen Archive oder parallelen Alternativkataloge.
- **Historie:** Git statt Changelogs/laufender Änderungshistorien in GDDs oder `temp_todo.md`. Einzige Ausnahme: `docs/simulation_log.md` ist eine datierte Messreihe (nur anhängen, Einträge nicht nachträglich ändern). Vor Entfernen historischer Einträge ausschließlich dort vorhandene, weiterhin gültige Informationen in zuständige GDD-Abschnitte übernehmen.
- **Prototyp/Versionen:** historische Abweichungen nur zur nötigen Abgrenzung vom aktuellen Design behalten, nie als aktive Spezifikation. Keine manuellen GDD-Versions-/Synchronisierungsversprechen ohne definierten Releaseprozess.
- **Arbeitsstand:** offene Fragen, Alternativen, Prüfaufträge und jeweils aktuelle Übergabe nur in `docs/temp_todo.md`. GDDs enthalten aktuelles Design samt gekennzeichneten Inhaltsentwürfen, kein Gesprächsprotokoll; `Context Handoff` nach jeder Session auf den aktuellen Stand bringen: Fokus, offene Entscheidungen/Blocker, nächster Schritt, Git-/Validierungsstand; keine vollständigen Preislisten/Regelkopien oder laufende Historie. Wiederverwendbare Arbeitsaufträge unter `AI Prompts` pflegen.
- **Nach Entscheidungen:** zuständiges GDD aktualisieren, betroffene Schnittstellen/Verweise prüfen und Aufgaben-/Übergabestand anpassen.
- **Abschluss:** Aufgaben erst bei erfüllten Abschlussbedingungen abhaken; Validierungsaufgaben brauchen passende Tests und dokumentierte Ergebnisse.
- **Prüfung:** fokussierter Diff, Verweise, gegebenenfalls Rechensummen und `git diff --check`; tatsächlich Geprüftes und offene Fragen berichten.

## Architecture

### Dokumentzuständigkeiten

| Datei | Zuständigkeit | Abgrenzung |
|---|---|---|
| [`docs/gdd_battle.md`](docs/gdd_battle.md) | Kampfablauf, Initiative, Battle-AP-Laufzeit, Spielfeld, Zonen, Böden, Props, allgemeine Schadens-/Verschiebungsauflösung | Keine zweite Monster-Skill-, Kosten- oder Upgrade-Spezifikation |
| [`docs/gdd_monsters.md`](docs/gdd_monsters.md) | Monsteridentität, Stats, Kins, Roster, Monsterentwicklung | Keine Skill-Regeln oder -Inhalte (siehe `gdd_skills.md`); generische Kampfauflösung in Battle |
| [`docs/gdd_skills.md`](docs/gdd_skills.md) | Alles zu Monster-Skills: Kit, Datenmodell, Profile, Effektverträge, Preise/AP, Slotentwicklung, Validierung, Kin-Strike-/Bewegungstabellen, Passives, Spezies-Zuordnungen, konkrete Skill-Records | Monsteridentität/Stats/Roster in `gdd_monsters.md`; Kampfauflösung in Battle; Meta-Integration in Overworld |
| [`docs/gdd_overworld.md`](docs/gdd_overworld.md) | Welt, Expeditionen, Monstererwerb/-unterbringung, Wirtschaft, Meta-Fortschritt, Tamer-Skills, Ausrüstung, Battle-Loadout | Nur Meta-Integration der Monster-Skills, nicht deren Konstruktion/Kampfauflösung |
| [`docs/temp_todo.md`](docs/temp_todo.md) | Offene Entscheidungen, Abhängigkeiten, Validierungsaufträge, aktuelle Übergabe | Arbeitsorganisation, keine zusätzliche verbindliche Regelsammlung |
| [`docs/simulation_log.md`](docs/simulation_log.md) | Datierte Ergebnisse der Godot-KI-Simulationen (`godot/tools/sim.gd`) im festen Eintragsformat samt Code-/Inhaltsstand | Nur Messwerte und Indizien; keine Regeln, Preise oder Freigaben; Folgerungen als Aufgabe in `temp_todo.md` |
| [`godot/tools/`](godot/tools/README.md) | Werkzeuge zum Ausprobieren (Bot-Läufe, Monster-Vergleich); sie nutzen die Inhalte unter `godot/data/` | Indizien, keine Regel- oder Preisquelle |
| `CLAUDE.md` | Dauerhafte Arbeitsregeln und Agent-Wegweiser | Keine Balancewerte, detaillierten Spielregeln oder Übergabekopie |

### Zentrale Monster-Skill-Spezifikation

`docs/gdd_skills.md`:

| Abschnitt | Thema |
|---|---|
| §1 | Kit und Zugang |
| §2 | Gemeinsames Datenmodell und Konstruktionsfelder |
| §3 | Ausführungsprofile |
| §4 | Effekt- und Boardverträge |
| §5 | Konstruktionspunkte, Preise und AP-Effizienz |
| §6 | Slotentwicklung, Ersatz und Upgrades |
| §7 | Validierung |
| §8 | Kin-Strike- und Bewegungstabellen |
| §9 | Passives |
| §10 | Spezies-Skill-Zuordnungen (Entwurf) |
| §11 | Konkrete Skill-Records |

- Wegweiser, keine zusätzliche Mechanikdefinition; bei Umstrukturierung Übersicht und betroffene Verweise mitführen.

### Umgang mit Widersprüchen

- **Zuständigkeit bestimmt Pflegeort**, bestätigt aber nicht automatisch vorhandene Entwürfe.
- **Status/Entscheidung prüfen:** aktueller Nutzerauftrag, Übergabe und zuständiger GDD-Abschnitt; nicht die bequemere Variante wählen.
- **Bestätigte Entscheidung:** in zuständige Quelle übernehmen, widersprechende aktive Angaben korrigieren. Bei Unklarheit Konflikt zur Klärung vorlegen.
