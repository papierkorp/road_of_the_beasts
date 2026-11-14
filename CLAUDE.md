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
- **Godot-Stand vs. GDD:** Der Godot-Build darf den GDDs vorauslaufen, wenn der Nutzer eine Variante dort ausprobieren will; solche Abweichungen stehen in `godot/README.md` und als Aufgabe in `docs/temp_todo.md`. Eine GDD-Regel wird daraus erst durch ausdrücklichen Beschluss. **Stand seit dem Umbau vom 2026-11-13 (Nutzerentscheidungen, Aufgabe T40):** keine Höhe, keine Luftebene, keine Surges und Fallen; ein Feld ist Boden + Zone + Besetzer (Boden wirkt zu einem Zeitpunkt, eine Zone solange man drinsteht); ein Skill überbringt nur (Schlag, Bewegung, Selbstwirkung, erschafft Boden/Zone/Prop), Wann und Was stehen bei Boden, Zone und Prop; Dragon Veins (früher Wellsprings) gehören der Seite, die sie zuletzt berührt hat. Die Battle-GDDs beschreiben das, der Build spielt es. **Arbeitswerte, nicht bestätigt:** höchster Einzeltreffer 2 und niedrigste HP 3, die Skill-Liste, die Kits, die Test-Stats, alle Boden- und Zonenwerte. **Noch im Code, aber vom Spiel ungenutzt:** die Logik für Höhe, Luftebene, Surges und Fallen samt zugehöriger Testschalter (Aufräumen: T40, I56/I57). Testschalter in `godot/battle/core/battle_experiment.gd`.
- **CPU-Nutzung (Nutzerfreigabe 2026-11-14):** Full-CPU ist erlaubt; die frühere Low-CPU-Ausführung ist nicht verpflichtend. Godot darf direkt mit normalen Prozess-/CPU-Einstellungen aufgerufen werden; dafür ist keine Codeänderung nötig. `godot/tools/run_low_priority.ps1` bleibt ein optionaler, absichtlich drosselnder Launcher. Die Freigabe verspricht weder automatische Parallelisierung noch 100 % Auslastung aller CPUs bei jedem Lauf.
- **Werkzeuge und Simulationen:** [godot/tools/README.md](godot/tools/README.md) ist der Wegweiser für Bot-Läufe (`sim.gd`), Monster-Vergleiche (`compare.gd`), Entry-/Upgrade-Proxys (`progression.gd`) und Discovery mit Autorenwerten (`discovery.gd`). Progression/Discovery nutzen gepaarte Teams mit vollständigem Seitenwechsel und Quellen-/Abschlussprüfungen; diese Guards prüfen die Messung, nicht die Spielqualität. Statusfilter und Versuchsszenarien sind keine Regel- oder Inhaltsfreigabe. **Zweck (Nutzervorgabe 2026-11-12):** ausprobieren, ob das Gameplay Spaß macht und sinnvoll ist, und herausfinden, welche Skill-Preise nötig sind. Die Skill-Kalkulation ist nicht fest: Simulationen ignorieren Preise und prüfen Monster nicht gegen Budgets. Dasselbe gilt für die Stat-Kalkulation (Nutzervorgabe 2026-11-13): Stat-Preise, Budgets und Rahmen in `docs/gdd_monsters.md` §2.2 sind ungetestete Anfangswerte, nichts davon ist fixiert; sie werden zusammen mit Regeln und Skills über das Gameplay gefunden, ebenso welche Skills es überhaupt gibt und wie sie auszubalancieren sind. Läufe liefern Indizien, keine Balance-/Preisfreigabe und keine Regelquelle. **Daten:** genau ein Datenordner `godot/data/` mit einem Unterordner je Art (`monsters/`, `skills/`, `zones/`, `grounds/`, `props/`, `tamer/`; Nutzeraufträge 2026-11-12: keine zweiten Skill-, Zonen-, Kit-, Build- oder Preis-Sätze). `internal_calc_cost` steht direkt in der jeweiligen Ressource (Autorennotiz mit Altwerten des verworfenen Kalkulationsschemas oder −1, keine aktuelle Preisregel); es gibt keinen Preisordner und keinen Preisrechner. Skills, Monster, Böden, Zonen und Props tragen `content_status` = `approved`/`draft`/`experiment`/`test`/`simulation`/`archived`; der Filter sitzt in `ContentStatus.in_game` (aufgerufen von `GameData` und `BattleContent`), das Spiel verwendet nur `approved`, `draft` und `experiment` (Nutzerentscheidung 2026-11-13: Mechaniken zum Ausprobieren im Spiel, z. B. seltene, teure AP-/TPR-Skills; in der Übersicht sichtbar, keine GDD-Regel). Nicht mehr Gebrauchtes löschen (Git ist die Historie) oder auf `archived` setzen. Keine Python- oder JSON-Dateien im Projekt; die Werkzeuge bleiben schlank. Bot-, Progression- und Discovery-Messberichte gemäß [Werkzeugdokumentation](godot/tools/README.md#recording-results) in [docs/simulation_log.md](docs/simulation_log.md), Monster-Vergleichstabellen und Folgerungen in [docs/temp_todo.md](docs/temp_todo.md) (T13) festhalten; offene Regeln nicht erfinden.
- **Progressionsziel und Validierung:** Von Beginn an spielbare Monster und sinnvolle alternative Verbesserungen sind das Ziel, kein beschlossener numerischer Start. AP-Bezahlbarkeit, ein nutzbarer aktiver Skill, Budget-Fit oder ein Entry-Proxy belegen das nicht. Stat- und Skillentwicklung gemeinsam an Handlungsschwellen, Entscheidungen und Kampflänge prüfen; Regeln/Preise nicht hier kopieren. Zuständig: [Monsters §2.2](docs/gdd_monsters.md#22-frame-budget-level-ups), [Skills §5](docs/gdd_skills.md#5-value-and-prices)/[§6](docs/gdd_skills.md#6-slot-levels-development-and-replacement), Validierung und offene Entscheidungen: [T02/T03/T05/T13](docs/temp_todo.md).

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
| [`docs/gdd_battle.md`](docs/gdd_battle.md) | Kampfablauf, Initiative, Battle-AP-Laufzeit, Spielfeld, **was Böden, Zonen und Props tun und wann**, allgemeine Schadens-/Verschiebungsauflösung | Keine zweite Monster-Skill-, Kosten- oder Upgrade-Spezifikation |
| [`docs/gdd_monsters.md`](docs/gdd_monsters.md) | Monsteridentität, Stats, Kins, Roster, Monsterentwicklung | Keine Skill-Regeln oder -Inhalte (siehe `gdd_skills.md`); generische Kampfauflösung in Battle |
| [`docs/gdd_skills.md`](docs/gdd_skills.md) | Alles zu Monster-Skills: Kit, Skill-Karte, was ein Skill selbst tut und was er erschafft, Preise/AP, Slotentwicklung, Daten/Validierung, Strike-Formen und Bewegungsarten, Passives, Kits, Skill-Liste | Monsteridentität/Stats/Roster in `gdd_monsters.md`; Kampfauflösung in Battle; Meta-Integration in Overworld |
| [`docs/gdd_overworld.md`](docs/gdd_overworld.md) | Welt, Expeditionen, Monstererwerb/-unterbringung, Wirtschaft, Meta-Fortschritt, Tamer-Skills, Ausrüstung, Battle-Loadout | Nur Meta-Integration der Monster-Skills, nicht deren Konstruktion/Kampfauflösung |
| [`docs/temp_todo.md`](docs/temp_todo.md) | Offene Entscheidungen, Abhängigkeiten, Validierungsaufträge, aktuelle Übergabe | Arbeitsorganisation, keine zusätzliche verbindliche Regelsammlung |
| [`docs/simulation_log.md`](docs/simulation_log.md) | Datierte Ergebnisse der Godot-Bot-, Progression- und Discovery-Messungen im festen Eintragsformat samt Code-/Inhaltsstand | Nur Messwerte und Indizien; keine Regeln, Preise oder Freigaben; Folgerungen als Aufgabe in `temp_todo.md` |
| [`godot/tools/`](godot/tools/README.md) | Werkzeuge zum Ausprobieren (Bot-Läufe, Monster-Vergleich, Entry-/Upgrade-Proxys, Discovery); sie nutzen die Inhalte unter `godot/data/` | Indizien, keine Regel- oder Preisquelle |
| `CLAUDE.md` | Dauerhafte Arbeitsregeln und Agent-Wegweiser | Keine Balancewerte, detaillierten Spielregeln oder Übergabekopie |

### Zentrale Monster-Skill-Spezifikation

`docs/gdd_skills.md`:

| Abschnitt | Thema |
|---|---|
| §1 | Kit und Zugang |
| §2 | Die Skill-Karte (Kosten, Ort, Schlag, Bewegung, Selbstwirkung, erschafft Boden/Zone/Prop), Nutzung, Ort und Form |
| §3 | Was ein Skill selbst tut: Schlag, Bewegung, Wirkung auf den Nutzer |
| §4 | Was ein Skill erschafft: Boden, Zone, Prop und ihre Kombinationen |
| §5 | Wert und Preise (offen) |
| §6 | Slotentwicklung und Ersatz |
| §7 | Daten, Validierung, Übersicht, Skill-Baukasten und Generator |
| §8 | Strike-Formen, Kin-Effekte und Bewegungsarten |
| §9 | Passives |
| §10 | Kits der neun Monster (Arbeitsentwurf) |
| §11 | Skill-Liste (Arbeitsentwurf) |

- Wegweiser, keine zusätzliche Mechanikdefinition; bei Umstrukturierung Übersicht und betroffene Verweise mitführen.

### Umgang mit Widersprüchen

- **Zuständigkeit bestimmt Pflegeort**, bestätigt aber nicht automatisch vorhandene Entwürfe.
- **Status/Entscheidung prüfen:** aktueller Nutzerauftrag, Übergabe und zuständiger GDD-Abschnitt; nicht die bequemere Variante wählen.
- **Bestätigte Entscheidung:** in zuständige Quelle übernehmen, widersprechende aktive Angaben korrigieren. Bei Unklarheit Konflikt zur Klärung vorlegen.
