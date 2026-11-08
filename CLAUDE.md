# Project

Road of the Beasts ist ein Spiel mit deterministischen, rundenbasierten Monsterkämpfen sowie einer Management- und Kultivierungsebene. Der aktuelle Arbeitsauftrag ist, die Game Design Documents (GDDs) zu überarbeiten, zu vervollständigen und konsistent zu halten — nicht das Spiel zu implementieren.

## Safety

- Ausschließlich auf dem Branch `docs/update_gdd` arbeiten. Vor Änderungen Branch und Git-Status prüfen; bei einem anderen Branch anhalten und nachfragen, nicht selbst wechseln.
- Änderungen sind auf `docs/` beschränkt. Die Pflege dieser Datei im Projektroot ist die ausdrücklich erlaubte Ausnahme. Daraus folgt keine Erlaubnis für weitere Änderungen außerhalb von `docs/`.
- Keine Implementierung oder Änderungen an `godot/` und `html_prototype/` im Rahmen dieses Auftrags.
- Keine Commits, Branchwechsel, Pulls, Resets oder andere eingreifende Git-Aktionen ohne ausdrücklichen Auftrag. Nutzeränderungen erhalten; nichts automatisch synchronisieren.
- Bestehende Prototypen sind keine Bestätigung des aktuellen Designs. Dokumentationsprüfung und Rechenproben sind keine Gameplay- oder Balancevalidierung.

## Working style

### Einstieg und Zusammenarbeit

- Im Chat auf Deutsch, knapp und verständlich kommunizieren. Dokumentation unter `docs/` auf Englisch verfassen und pflegen, einschließlich `temp_todo.md`. Bestehende englische GDD-Terminologie und Bezeichner konsistent verwenden. Noch deutsche Bestandsabschnitte bei ihrer Überarbeitung ins Englische übertragen, ohne dabei Regeln oder Entscheidungsstatus zu ändern.
- Zum Wiedereinstieg `docs/temp_todo.md` lesen: Verwendung, aktuelle Übergabe und den betroffenen Aufgabenpunkt. Danach gezielt die zuständigen GDD-Abschnitte lesen.
- Die aktuelle Nutzeranweisung hat Vorrang vor älteren Übergaben. Veraltete Arbeitsanweisungen korrigieren, statt sie weiterzutragen.
- Grundlegende Gameplayentscheidungen mit dem Nutzer klären. Bereits beschlossene Prinzipien nicht ohne neuen Anlass erneut zur Wahl stellen.
- Zusammengehörige Kostenentwürfe und Rechenbeispiele darf der Agent gesammelt ausarbeiten. Neue Zahlen und Empfehlungen als Entwurf kennzeichnen; daraus keine Freigabe neuer Mechaniken oder grundlegender Gameplayänderungen ableiten.
- Fehlende Regeln und Widersprüche benennen, nicht durch erfundene Standardannahmen verdecken. Eine Berechnung innerhalb des Budgets ist noch keine Content- oder Balancefreigabe.

### Gemeinsame Darstellung für Menschen und AI-Agents

- Eine gemeinsame Markdown-Spezifikation pflegen, keine getrennten GDD-Versionen für Menschen und AI. Die Aufteilung erfolgt nach Themen, nicht nach Zielgruppen.
- Pro Thema: kurzer Überblick, kompakte Vergleichs- oder Referenztabellen und präzise Regeln. Beispiele und strukturierte Datenblöcke nur ergänzen, wenn sie das Verständnis oder die Vollständigkeitsprüfung verbessern.
- Bedingungen, Einheiten, Kosten, Grenzen und Auflösungsreihenfolgen eindeutig benennen. Insbesondere Battle-AP, Tages-AP, Konstruktionspunkte, Schaden und EP nicht vermischen.
- Status sichtbar unterscheiden: beschlossen, Arbeitsentwurf und noch nicht validiert. Nicht jede Aussage mit wiederholten Warntexten überladen; Status am zusammengehörigen Abschnitt oder an der Tabelle kennzeichnen.
- Jede Regel, Formel, Preisliste und Datenstruktur hat genau einen zuständigen Abschnitt. Andere Stellen verlinken dorthin und beschreiben nur ihre eigene Schnittstelle, statt die Spezifikation zu kopieren.
- Allgemeine Regeln und Kostenkomponenten mit präzisen Effekt- oder Skillklassen beschreiben, nicht mit wiederholten Listen konkreter Skillnamen. Konkrete Skills und ihre Ausnahmen einmal zentral definieren; Namen außerhalb davon nur für notwendige Inhaltsreferenzen, klar abgegrenzte Referenzrechnungen oder konkrete offene Aufgaben verwenden. Beim Verallgemeinern keine skillgebundene Ausnahme auf eine ganze Skillklasse übertragen.
- Menschenlesbare Tabellen und strukturierte Beispiele dürfen keine voneinander unabhängigen Regelversionen bilden. Beispiele müssen aus den zentralen Regeln folgen.
- Stabile, aussagekräftige Überschriften und relative Markdown-Links verwenden. Nach Verschiebungen betroffene Links und Abschnittsverweise aktualisieren.

### Überarbeitung und Abschluss

- Eindeutig verworfene oder ersetzte Ideen dürfen gelöscht werden; keine Archive oder parallelen Alternativkataloge ohne Bedarf anlegen. Bei unklarem Status erst klären.
- Keine Changelogs oder laufenden Änderungshistorien in den GDDs oder `docs/temp_todo.md` pflegen. Die Git-Historie dient der Änderungsnachverfolgung; `temp_todo.md` enthält nur offene Arbeit und eine jeweils aktualisierte aktuelle Übergabe. Vor dem Entfernen historischer Einträge prüfen, ob weiterhin gültige Informationen ausschließlich dort stehen, und diese gegebenenfalls in den zuständigen GDD-Abschnitt übernehmen. Historische Prototyp-Abweichungen nur behalten, soweit sie zur Abgrenzung vom aktuellen Design nötig sind; sie sind keine aktive Spezifikation. Keine manuellen GDD-Versions- oder Synchronisierungsversprechen ohne definierten Releaseprozess.
- Offene Fragen, Alternativen und Prüfaufträge zentral in `docs/temp_todo.md` pflegen. Die GDDs enthalten den aktuellen Designstand einschließlich ausdrücklich gekennzeichneter inhaltlicher Entwürfe, nicht das Gesprächsprotokoll.
- Nach einer Entscheidung den zuständigen GDD-Abschnitt aktualisieren, betroffene Schnittstellen und Verweise prüfen und den Aufgaben-/Übergabestand in `docs/temp_todo.md` anpassen. Keine vollständigen Preislisten oder Regelkopien in die Übergabe übernehmen.
- Aufgaben erst abhaken, wenn ihre Abschlussbedingungen erfüllt sind. Validierungsaufgaben erfordern passende Tests und dokumentierte Ergebnisse.
- Änderungen fokussiert halten. Zum Abschluss Diff, Verweise und gegebenenfalls Rechensummen prüfen sowie `git diff --check` ausführen. Berichten, was tatsächlich geprüft wurde und welche Fragen offen bleiben.

## Architecture

### Dokumentzuständigkeiten

| Datei | Zentrale Zuständigkeit | Abgrenzung |
|---|---|---|
| [`docs/gdd_battle.md`](docs/gdd_battle.md) | Kampfablauf, Initiative, Battle-AP-Laufzeit, Spielfeld, Zonen, Böden, Props, allgemeine Schadens- und Verschiebungsauflösung | Keine zweite Monster-Skill-, Kosten- oder Upgrade-Spezifikation |
| [`docs/gdd_monsters.md`](docs/gdd_monsters.md) | Monsteridentität, Stats, Kins, Monster-Skills, Passives, Roster und Monsterentwicklung | Kapitel 4 ist die zentrale Monster-Skill-Spezifikation; generische Kampfauflösung liegt in Battle |
| [`docs/gdd_overworld.md`](docs/gdd_overworld.md) | Welt, Expeditionen, Erwerb und Unterbringung von Monstern, Wirtschaft, Meta-Fortschritt, Tamer-Skills, Ausrüstung und Battle-Loadout | Beschreibt die Meta-Integration von Monster-Skills, nicht erneut deren Konstruktion oder Kampfauflösung |
| [`docs/temp_todo.md`](docs/temp_todo.md) | Zentrale offene Entscheidungen, Abhängigkeiten, Validierungsaufträge und aktuelle Übergabe | Arbeitsorganisation, keine zusätzliche verbindliche Spielregelsammlung |
| `CLAUDE.md` | Dauerhafte Arbeitsregeln und Dokumentwegweiser für Agents | Keine Balancewerte, detaillierten Spielregeln oder Kopie der aktuellen Übergabe |

### Zentrale Monster-Skill-Spezifikation

`docs/gdd_monsters.md`, Kapitel 4, bündelt die Monster-Skill-Definitionen:

| Abschnitt | Thema |
|---|---|
| §4.1 | Kit und Zugang |
| §4.2 | Gemeinsames Datenmodell und Konstruktionsfelder |
| §4.3 | Ausführungsprofile |
| §4.4 | Effekt- und Boardverträge |
| §4.5 | Konstruktionspunkte, Preise und AP-Effizienz |
| §4.6 | Slotentwicklung, Ersatz und Upgrades |
| §4.7 | Vollständige Referenzen und Validierung |

Diese Übersicht ist ein Wegweiser, keine zusätzliche Definition der Mechaniken. Bei einer bewussten Umstrukturierung die Übersicht und alle betroffenen Verweise mitführen.

### Umgang mit Widersprüchen

- Die Zuständigkeitstabelle bestimmt, wo eine Regel gepflegt wird; sie macht nicht jeden vorhandenen Entwurf automatisch verbindlich.
- Bei widersprüchlichen Angaben Status und aktuelle Entscheidungen anhand von Nutzerauftrag, Übergabe und zuständigem GDD-Abschnitt prüfen. Nicht stillschweigend die bequemere Variante auswählen.
- Bestätigte Entscheidungen in die zuständige Quelle übernehmen und widersprechende aktive Angaben korrigieren. Ist die Entscheidung nicht eindeutig, den Konflikt zur Klärung vorlegen.
