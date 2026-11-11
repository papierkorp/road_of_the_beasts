# Project

- **Road of the Beasts:** deterministische, rundenbasierte Monsterkämpfe mit Management und Kultivierung.
- **Designziel:** „Easy to learn, hard to master“: wenige, einheitliche und gut lesbare Regeln; Tiefe entsteht aus Kombinationen und Entscheidungen, nicht aus Sonderregeln. Bei Designvorschlägen und Mechanik-Abwägungen als Maßstab nutzen (Ausnahmen und Sonderfälle begründen).
- **Auftrag:** GDDs überarbeiten, vervollständigen und konsistent halten; Spielimplementierung nur im Rahmen einer ausdrücklichen Nutzerfreigabe (siehe Safety).

## Safety

- **Branch:** `docs/update_gdd` für reine GDD-Arbeit; `main` für den Battle-Implementierungsauftrag (Nutzerfreigabe 2026-11-11). Vor Änderungen Branch/Git-Status prüfen; bei anderem Branch anhalten und nachfragen, nicht selbst wechseln.
- **Schreibbereich:** `docs/` und die Pflege dieser `CLAUDE.md`. `godot/` nur für den Battle-Implementierungsauftrag (Nutzerfreigabe 2026-11-11): Battle-System und dessen notwendige Anbindung (`godot/battle/`, Battle-Verträge in `godot/shared/`, `godot/data/`, `godot/tests/`, `godot/tools/`, `godot/README.md`), einschließlich der Simulations- und Preiswerkzeuge unter `godot/tools/` samt `godot/tests/tools/` (Nutzerauftrag 2026-11-11); die Overworld (`godot/overworld/`) bleibt funktional unverändert. Keine Änderungen an `tools/html_prototype/` oder anderen Pfaden.
- **Git/Nutzerarbeit:** keine Commits, Branchwechsel, Pulls, Resets oder sonstigen eingreifenden Git-Aktionen ohne ausdrücklichen Auftrag. Nutzeränderungen erhalten; nichts automatisch synchronisieren.
- **Validierung:** Prototypen bestätigen nicht das aktuelle Design; Dokumentationsprüfung und Rechenproben sind keine Gameplay-/Balancevalidierung.
- **Werkzeuge:** `godot/tools/` (Bot-Läufe `sim.gd`, kostengleicher Build-Vergleich `compare.gd`, Preisrechner `price.gd`, Preisrecords und Test-Builds als Resource-Dateien unter `godot/tools/data/`; Kontext, Umfang und Grenzen in `godot/tools/README.md`) liefern nur Indizien, keine Balance-/Preisfreigabe und keine Regelquelle. Sie ersetzen den Python-Simulator `tools/simulator/`, der auf Nutzerauftrag vom 2026-11-11 nach Godot übertragen und gelöscht wurde; Simulationen laufen seitdem auf dem Battle-Kern. Keine Python- oder JSON-Dateien im Projekt: Werkzeugdaten sind `.tres`-Ressourcen wie der übrige Inhalt (Nutzerauftrag 2026-11-11). Die Werkzeuge bleiben schlank: schnelle Preis- und Ablaufindizien, kein Vollständigkeitsprojekt; als Prüfung nur die kleinen Suiten unter `godot/tests/tools/` (Papierpreise, Abgleich Preisrecord gegen Skill-Definition), keine Legacy-Regressionsdateien für Kampfergebnisse. Preisrecords, Test-Builds und Papier-Rechenwerte bleiben wiederverwendbar (Nutzerklärung 2026-11-11). Abweichungen im README benennen, offene Regeln nicht erfinden; `sim.gd`-Laufblöcke in `docs/simulation_log.md`, Vergleichstabellen und Folgerungen in `docs/temp_todo.md` (T13) festhalten.

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
| [`godot/tools/`](godot/tools/README.md) | Prüfwerkzeuge (Bot-Läufe, Build-Vergleich, Preisrechner) samt Preisrecords und Test-Builds als `.tres` | Indizien, keine Regel- oder Preisquelle |
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
