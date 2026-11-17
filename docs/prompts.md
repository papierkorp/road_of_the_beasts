# AI Prompts

## Godot-Battle anhand der aktuellen GDDs implementieren

```text
Du sollst das Battle-System dieses Godot-Projekts auf den Stand der aktuellen Game Design Documents bringen. Arbeite direkt im Repository und setze die erforderlichen Änderungen vollständig um.

Umfang und maßgebliche Quellen:
- Dieser Prompt beschreibt einen späteren Implementierungsauftrag. Vor dem Start müssen der Arbeitsbranch und der Schreibbereich für Godot-Code ausdrücklich freigegeben sein, falls die dann geltenden Repository-Anweisungen weiterhin nur Dokumentationsarbeit erlauben. Der gespeicherte Prompt allein hebt diese Beschränkungen nicht auf.
- Beschränke deine Arbeit auf das Battle-System und dessen notwendige Anbindung. Die Overworld soll funktional unverändert bleiben.
- Lies zuerst die Repository-Anweisungen, docs/temp_todo.md (Context Handoff, offene Battle-Aufgaben und Battle Completion Gate), die aktuellen GDDs und den bestehenden Battle-Code. Maßgeblich sind docs/battle.md, docs/monsters.md und docs/skills.md sowie die Battle-Schnittstellen in docs/overworld.md. Bestehender Code kann veraltet sein.
- Unterscheide bestätigte Regeln, gekennzeichnete Entwürfe und offene Entscheidungen. Ein GDD-Entwurf ist keine automatische Freigabe. Wenn zentrale Regeln widersprüchlich oder ungeklärt sind, frage gezielt nach und arbeite an unabhängigen Teilen weiter, statt eine Spielregel zu erfinden.
- Du darfst den Battle-Code umfassend refactoren oder ersetzen. Bewahre vorhandene Implementierungen dort, wo sie zur neuen Spezifikation und Architektur passen. Erhalte unbeteiligte Nutzeränderungen.
- Implementiere keine zusätzlichen Spielmechaniken außerhalb der GDDs. Keine Commits oder sonstigen eingreifenden Git-Aktionen ohne ausdrücklichen Auftrag.

Architektur und Erweiterbarkeit:
- Das Battle soll deterministisch, gut nachvollziehbar und leicht erweiterbar sein. Verwende klare Verantwortlichkeiten, geeignete Klassen und explizite Verträge für Monster, Skills, Props, Ground und ihre Interaktionen. Nutze zu Godot und der verwendeten Sprache passende Mittel, etwa Resources, Komposition und gemeinsame Basistypen.
- Trenne Definitionen (Daten zu Monstern, Skills, Props, Ground und Effekten), Battle-Zustand (veränderliche Daten einer Begegnung), Regelauswertung (Validierung und deterministische Auflösung) sowie Darstellung und Eingabe (Szenen, Animationen, UI, Audio und Steuerung).
- Die Regelauswertung darf nicht von Animationen, Framerate, Szenenbaum-Timing oder UI-Zuständen abhängen. Die Darstellung bildet die Ergebnisse der Simulation ab.
- Modelliere gemeinsame Mechaniken über wiederverwendbare Regeln, Effekte und Fähigkeiten. Vermeide verstreute Abfragen nach konkreten Monster-, Skill-, Prop- oder Ground-IDs. Kapsle tatsächlich einzigartige Mechaniken hinter klaren Erweiterungspunkten.
- Baue keine unnötig abstrakte Universal-Engine oder eigene Regelsprache. Wähle die einfachste Architektur, die die aktuellen GDDs sauber abbildet und absehbare Inhaltserweiterungen ermöglicht. Neue Inhalte mit bestehenden Mechaniken sollen meist nur Daten brauchen; neue Mechaniken dürfen neuen Code brauchen.

Konkretes Erweiterungsziel:
- Ein zusätzlicher Ground-Typ soll sich über eine neue Definition und gegebenenfalls wiederverwendbare Verhaltenselemente ergänzen lassen, ohne Änderungen in zahlreichen unabhängigen Systemen zu benötigen.
- Wasser ist dafür nur ein hypothetisches Architekturbeispiel, kein Implementierungsauftrag und keine Wiederaufnahme der entfernten Water/Swim-Mechanik. Eigenschaften und Interaktionen bestimmen ausschließlich die aktuellen bestätigten Regeln.
- Dasselbe Prinzip gilt für Monster, Skills und Props: Bestehende Mechaniken sollen durch neue Daten kombinierbar sein. Neue Mechaniken sollen einen klaren, möglichst lokalen Erweiterungspunkt haben.

Determinismus:
- Gleicher initialer Battle-Zustand, gleiche versionierte Inhaltsdefinitionen, gleicher Seed und gleiche geordnete Aktionen müssen zum gleichen Ergebnis führen.
- Verwende ausschließlich kontrollierte Zufallsquellen innerhalb der Simulation, soweit die GDDs überhaupt Zufall vorsehen.
- Definiere eine stabile Reihenfolge für Aktionen, Effekte, Trigger und Gleichstände entsprechend den GDDs.
- Vermeide Abhängigkeiten von unbestimmter Iterationsreihenfolge, Echtzeit oder Darstellungsabläufen.
- Stelle Battle-Ergebnisse und relevante Zustandsänderungen so bereit, dass sie unabhängig von der Darstellung geprüft und nachvollzogen werden können.

Arbeitsweise:
1. Prüfe GDDs und Implementierung. Erstelle eine knappe Bestandsaufnahme mit Abweichungen, offenen Regelfragen und betroffenen Battle-Systemen.
2. Leite daraus einen konkreten Implementierungsplan und eine passende Zielarchitektur ab. Verknüpfe wesentliche Anforderungen mit ihren GDD-Quellen. Offene Designentscheidungen bleiben sichtbar und werden nicht durch technische Standardwerte entschieden.
3. Setze den Plan um. Bleibe nicht bei Analyse oder Architekturvorschlägen stehen. Frage nur nach, wenn eine ungeklärte Entscheidung die korrekte Umsetzung tatsächlich blockiert; bearbeite unabhängige Teile weiter.
4. Prüfe die Umsetzung mit geeigneten automatisierten Tests für Battle-Regeln, Effektinteraktionen, stabile Auflösungsreihenfolgen und Determinismus. Nutze nach Möglichkeit Tests ohne grafische Oberfläche und überprüfe konkrete erwartete Ergebnisse, nicht nur die Wiederholbarkeit.
5. Prüfe zusätzlich die spielbare Battle-Anbindung in Godot sowie die bestehenden Übergänge zur Overworld. Fehlende Meta-Systeme dürfen nicht durch erfundene Erwerbs-, Wirtschafts- oder Fortschrittsregeln ersetzt werden; nötige Battle-Testdaten klar als Testdaten kennzeichnen.
6. Dokumentiere kurz, wo neue Monster, Skills, Props und Ground-Typen ergänzt werden und wann neue Verhaltenslogik nötig ist.

Abnahmekriterien:
- Die Battle-Regeln entsprechen den aktuellen bestätigten GDDs; verbleibende Lücken und noch nicht freigegebene Inhalte werden konkret benannt. Keine stillschweigende Verkleinerung des vereinbarten Battle-Umfangs.
- Battle-Simulation und Darstellung sind voneinander getrennt.
- Determinismus ist durch reproduzierbare Tests belegt.
- Gemeinsames Verhalten wird wiederverwendet; inhaltsspezifische Sonderfälle sind lokal gekapselt.
- Neue Inhalte mit bestehenden Mechaniken lassen sich ohne Änderungen an der zentralen Battle-Auflösung hinzufügen.
- Das Battle ist in Godot spielbar und korrekt angebunden.
- Die Overworld bleibt funktional unverändert.
- Behaupte keinen vollständigen Battle-Abschluss, solange erforderliche Regeln, Inhalte oder tatsächlich ausgeführte Prüfungen fehlen. Das aktuelle Battle Completion Gate bleibt maßgeblich.

Berichte abschließend knapp, was umgesetzt wurde, welche Prüfungen tatsächlich bestanden haben und welche konkreten Punkte gegebenenfalls noch offen sind.
```

Reusable German chat prompts and subsection titles are an explicit exception to the English documentation rule. These are instructions, not design rules or an execution log. Copy the relevant prompt into a new agent session; the agent must read current files rather than assume the prompt embeds the latest state.

## Alle GDDs prüfen und Aufgabenliste aktualisieren

```text
Analysiere alle GDDs von Road of the Beasts und aktualisiere docs/temp_todo.md passend zum aktuellen Projektstand. Verlasse dich nicht auf frühere Chatverläufe.

Sicherheit und Umfang:
- Lies CLAUDE.md. Prüfe zuerst Branch und Git-Status: nur auf main arbeiten; andernfalls anhalten und nachfragen, nicht selbst wechseln.
- Erhalte Nutzeränderungen. Bearbeite für diese Prüfung ausschließlich docs/temp_todo.md; keine Spielimplementierung und keine GDD-Änderungen. Keine Commits, Branchwechsel, Pulls, Pushes, Resets oder automatische Synchronisierung.
- Chat Deutsch, Dokumentation Englisch. Ausnahme: wiederverwendbare Chat-Prompts samt Unterüberschriften unter AI Prompts bleiben Deutsch. Nutze kompakte thematische Stichpunkte und hilfreiche Übersichtstabellen; bewahre Bedingungen, Ausnahmen, Negationen, Einheiten und Entscheidungsstatus. Kein Changelog.

Projektfokus und Reihenfolge — Battle als Kern des Spiels:
- Battle zuerst abschließen; danach die Overworld auf den ausgearbeiteten und getesteten Kampf ausrichten. Prüfe trotzdem alle vier GDDs vollständig und erhalte offene Meta-Aufgaben; Battle-first begrenzt die Arbeitsreihenfolge, nicht den Analyseumfang.
- Battle umfasst mehr als battle.md: auch Monster-Stats und zulässige Entwicklungsstände, Skills, Passives, Upgrade-Pfade, Slotentwicklung, Roster und Major-/Signature-Inhalte sowie direkte Kampfeinflüsse aus dem Overworld-GDD (Tamer-Skills, Artefakte, Medicines/Arrays, Loadout, Board-Eingaben und HP-/Niederlagen-Schnittstellen).
- Trenne bei gemischten Aufgaben die Battle-Ergebnisse von der späteren Meta-Integration. Kampfauswirkungen, Entwicklungsumfang und legale Test-Sheets/Loadouts zuerst definieren und prüfen; Erwerb, XP-Tempo, Rezepte, Preise, Ritualorte, Gebäude, Wirtschaft und Tages-AP danach darauf abstimmen. Fehlende Meta-Details sind weder kostenlose/sofortige Standardannahmen noch pauschale Blocker für Battle. Bereits beschlossene Mechanikentfernungen nicht durch die neue Priorität rückgängig machen.
- Erhalte die Battle-first-Reihenfolge in Recommended Work Order, Aufgaben-Voraussetzungen, Dependency Overview und Context Handoff. Unabhängige Battle-Arbeit darf parallel laufen; reine Overworld-Themen bleiben bis zum Battle-Abschluss zurückgestellt, sofern der Nutzer die Priorität nicht ausdrücklich ändert. Keine Zyklen erzeugen: notwendige Definitionen vor ihren Tests, nicht abgeschlossene Validierung als Voraussetzung ihrer eigenen Testeingaben.
- Gleiche den Battle-Abschluss mit dem aktuellen Battle Completion Gate ab: vollständige Regeln/Inhalte/Schnittstellen im ausdrücklich vereinbarten Umfang und tatsächlich durchgeführte geeignete Tests mit dokumentierten Ergebnissen. Ein Regelentwurf, Budget-Fit, Rechenprüfer oder historischer Prototyp reicht nicht. Keine stillschweigende Verkleinerung des Rosters oder Auslassung von Items, 2×2 oder Late-Game-Inhalten; dafür wäre eine ausdrückliche Nutzerentscheidung nötig. Die Luftebene ist bereits ausdrücklich entfernt, nicht zurückgestellt. Gemischte Aufgaben bleiben für ihre offenen Meta-Anteile offen.

Lesen und analysieren:
1. Lies die gesamte aktuelle temp_todo.md, besonders Context Handoff, danach alle aktuellen GDDs vollständig: docs/battle.md, docs/monsters.md, docs/overworld.md und die zentrale Skill-Spezifikation docs/skills.md. Große Dateien abschnittsweise lesen; eine Gliederungsübersicht allein ist keine vollständige Prüfung.
2. Gleiche jede vorhandene Aufgabe mit den zuständigen GDD-Abschnitten ab: noch offen, teilweise bearbeitet, nachweislich abgeschlossen, ersetzt, doppelt oder blockiert. Bestehende Aufgabenformulierungen und Arbeitswerte sind nicht automatisch Beschlüsse; GDD-Texte sind nicht automatisch validiert.
3. Prüfe fehlende Regeln, Widersprüche, offene Alternativen, Zuständigkeiten, doppelte Definitionen, veraltete Verweise, Sprache/Lesbarkeit, quellenspezifische Ausnahmen und den Status als Entwurf/Beschluss/Historie. Prüfe gegebenenfalls Rechensummen; Rechenproben und Prototypergebnisse sind keine Gameplay-/Balancevalidierung.
4. Entscheide keine offenen Gameplayvarianten, erfinde keine Standardannahmen und öffne bestätigte Prinzipien nicht ohne neuen Anlass. Höhe, Luftebene, Surges und Fallen sind entfernt; historische Höhenbruchregeln nicht als aktive Spezifikation wiederherstellen. Unklarheiten benennen, nicht stillschweigend eine Variante bestätigen.

Aufgabenliste aktualisieren:
- Überarbeite oder erstelle temp_todo.md erst neu, nachdem du ihren Bestand mit allen vier aktuellen GDDs abgeglichen hast. Erhalte alle weiterhin relevanten Entscheidungen, Einschränkungen, ausschließlich in der Übergabe enthaltenen Informationen und offenen Fragen. Nicht aus dem Gedächtnis ersetzen oder Punkte nur deshalb streichen, weil sie im GDD fehlen.
- Erhalte Context Handoff und AI Prompts als Hauptabschnitte, einschließlich dieser wiederverwendbaren Prompts. Vorhandene Aufgaben-IDs und gültige Abhängigkeiten möglichst bewahren; bei Zusammenlegung/Ersatz Nachvollziehbarkeit erhalten und alle betroffenen Verweise/Diagrammkanten innerhalb dieser Datei aktualisieren. IDs nie für sachfremde Themen wiederverwenden.
- Eindeutig ersetzte oder abgeschlossene Arbeit erst nach Prüfung ihrer restlichen Informationen und Abschlussbedingungen aus dem aktiven Backlog entfernen. Validierungsaufgaben brauchen tatsächlich durchgeführte geeignete Tests mit dokumentierten Ergebnissen; andernfalls offen lassen.
- Jede bearbeitbare Aufgabe erhält Status, zuständige Quellenlinks, konkrete Lücke/Entscheidung, Voraussetzungen und Abschlussbedingungen. Zusammengehöriges bündeln und eine Battle-first-Reihenfolge mit getrennten Battle-/Meta-Ergebnissen festlegen; unabhängige Battle-Arbeit darf parallel bleiben. Neue Lücken ohne doppelte Aufgaben ergänzen.
- Regeln, Preise und vollständige Referenzrechnungen bleiben in den zuständigen GDDs: verlinken statt kopieren. Vorgeschlagene GDD-Korrekturen als Aufgaben erfassen, nicht als unbestätigte neue Regeln.
- Veraltete Übergabe durch einen knappen aktuellen Stand ersetzen: Fokus, Beschlüsse gegenüber Entwürfen, Blocker, nächste konkrete Aktion/Fragen, betroffene Quellen, beobachteter Git-Stand und tatsächlich erfolgte Prüfungen. Zum Sessionende aktualisieren.

Prüfung und Antwort:
- Fokussierten Diff auf Informationsverlust und unbeabsichtigte Entscheidungsänderungen prüfen; relative Links, Aufgabenverweise, Abhängigkeiten und durchgeführte Rechnungen kontrollieren. git diff --check ausführen.
- Auf Deutsch berichten: tatsächlich geprüfter Umfang, wichtigste Befunde, Aufgabenänderungen, offene Entscheidungen, erfolgte Prüfungen und empfohlene nächste Battle-Besprechung. Benenne Battle-Blocker und später folgende Meta-Aufgaben getrennt. Bei unvollständiger Analyse genau benennen, was fehlt; keine vollständige Prüfung behaupten.
```

## Mit anderem Agent oder Rechner weiterarbeiten

```text
Setze die Dokumentationsarbeit an Road of the Beasts fort, ohne frühere Chatverläufe vorauszusetzen. Lies CLAUDE.md, prüfe Branch/Git-Status und halte an, falls nicht main aktiv ist. Keine eigenständigen Branchwechsel oder automatische Synchronisierung; lokale Nutzeränderungen erhalten.

Lies in docs/temp_todo.md Usage, Context Handoff und die betroffenen offenen Aufgaben; danach die zuständigen GDD-Abschnitte und verlinkten Schnittstellen. Aktueller ausdrücklicher Nutzerauftrag hat Vorrang vor älteren Übergabeanweisungen. Chat Deutsch, Dokumentation Englisch; wiederverwendbare Chat-Prompts samt Unterüberschriften unter AI Prompts bleiben Deutsch. Nur in docs/ arbeiten; keine Implementierung oder unaufgeforderten Git-Eingriffe.

Fasse Fokus und nächsten Schritt kurz zusammen. Belegte redaktionelle Korrekturen direkt bearbeiten; grundlegende Gameplayentscheidungen vorher klären. Entwürfe, Budget-Fit oder historisches Prototypverhalten nicht als bestätigte Regeln behandeln. Zum Abschluss Context Handoff mit tatsächlichem Ergebnis, Blockern, nächstem Schritt, beobachtetem Git-Stand und Validierung aktualisieren; veralteten Text ersetzen statt Historie anzuhängen.
```

## Session abschließen und Kontextübergabe aktualisieren

```text
Aktualisiere ausschließlich docs/temp_todo.md für die Übergabe dieser Dokumentationssession. Lies CLAUDE.md, prüfe Branch/Git-Status (main) und erhalte Nutzeränderungen. Nutze die aktuellen Dateien und ausdrücklichen Entscheidungen dieser Session; Empfehlungen sind keine Freigaben.

Aktualisiere Context Handoff: Fokus, Beschlüsse gegenüber Vorschlägen, offene Fragen/Blocker, genaue nächste Schritte/Quellenlinks, beobachteter Git-/Commit-Stand und tatsächlich erfolgte oder noch fehlende Prüfungen. Aufgabenstatus nur bei erfüllten Abschlussbedingungen ändern. AI Prompts und unbeteiligte Aufgaben erhalten. Keine Regel-/Preiskopien oder laufende Historie; veralteten Kontext ersetzen. Dokumentation Englisch, Antwort Deutsch; wiederverwendbare Chat-Prompts samt Unterüberschriften unter AI Prompts bleiben Deutsch. git diff --check ausführen; ohne ausdrücklichen Auftrag weder committen noch synchronisieren.
```

## GDDs redaktionell refactoren (Duplikate und Fließtext)

```text
Refactore die GDDs von Road of the Beasts redaktionell gemäß CLAUDE.md. Verlasse dich nicht auf frühere Chatverläufe.

Sicherheit und Umfang:
- Lies CLAUDE.md. Prüfe zuerst Branch und Git-Status: nur auf main arbeiten; andernfalls anhalten und nachfragen, nicht selbst wechseln.
- Erhalte Nutzeränderungen. Schreibe nur in docs/ (docs/battle.md, docs/monsters.md, docs/overworld.md, docs/skills.md; docs/temp_todo.md nur für Verweise und Übergabe). Keine Spielimplementierung, keine Commits, Branchwechsel, Pulls, Pushes oder Resets ohne ausdrücklichen Auftrag.
- Chat Deutsch; alle Dokumentation unter docs/ bleibt Englisch (Ausnahme: Chat-Prompts samt Unterüberschriften unter AI Prompts). Deutsche Bestandsabschnitte ins Englische übersetzen, ohne Regeln oder Entscheidungsstatus zu ändern.

Analyse zuerst:
1. Lies docs/temp_todo.md (Context Handoff, offene Aufgaben) und danach alle vier aktuellen GDDs (Battle, Monsters, Overworld, Skills) vollständig, abschnittsweise. Eine Gliederungsübersicht allein genügt nicht.
2. Erstelle vor dem Bearbeiten eine Befundliste: (a) Spielmechaniken, Regeln, Formeln, Preislisten oder Datenstrukturen, die an mehreren Stellen definiert oder fast wortgleich wiederholt werden; (b) lange Fließtext-Absätze und überlange Tabellenzellen; (c) deutsche Reste; (d) Verweise, die nach Umbauten brechen würden. Lege die Liste dem Nutzer kurz vor, wenn du mehr als nur eindeutige Duplikate zusammenführen willst.

Refactoring-Ziele (in dieser Priorität):
1. Keine doppelten oder mehrfachen Definitionen: Jede Regel, Formel, Preisliste und Datenstruktur hat genau einen zuständigen Abschnitt (Zuständigkeiten laut CLAUDE.md, Tabelle „Dokumentzuständigkeiten“). Alle anderen Stellen verlinken per relativem Markdown-Link und beschreiben nur ihre eigene Schnittstelle, keine Regelkopien. Beispiele und Referenzrechnungen folgen den zentralen Regeln und bilden keine zweite Regelversion. Allgemeine Regeln beschreiben Effekt-/Skillklassen statt Namenslisten; Skill-Ausnahmen nie auf ganze Klassen übertragen.
2. Keine Fließtext-Absätze: Längeren Fließtext in thematische Stichpunktlisten umwandeln, zusammengehörige Aussagen bündeln (nicht jeden Satz einzeln aufzählen), Unterlisten nur für echte Unterstruktur, Abläufe nummerieren, Vergleiche und Referenzwerte in kompakten Tabellen. Kurze Überblicks- und Begründungssätze dürfen bleiben.
3. Sprache: Englisch, einheitliche GDD-Terminologie und Bezeichner.

Harte Grenzen:
- Reines Refactoring: keine Regel, Zahl, Bedingung, Ausnahme, Negation, Einheit und kein Entscheidungsstatus (beschlossen / Arbeitsentwurf / nicht validiert) darf sich ändern. Keine neuen Mechaniken, keine Standardannahmen, offene Alternativen nicht entscheiden. Widersprüche nicht still auflösen, sondern als Aufgabe in docs/temp_todo.md erfassen.
- Informationserhalt prüfen: tatsächlichen Zeichenumfang vergleichen, mehr Zeilen sind keine Kürzung. Beim Zusammenführen von Duplikaten die vollständigste Fassung behalten und nur wirklich redundante Teile entfernen; Bedingungen nur in einer Quelle nicht verlieren.
- Überschriften stabil halten; nach Verschiebungen oder Umbenennungen alle Links, Abschnittsnummern und Anker in allen GDDs und in temp_todo.md aktualisieren. Aufgaben-IDs in temp_todo.md bleiben erhalten.
- Arbeite in kleinen, thematisch geschlossenen Schritten (ein Kapitel oder eine Mechanik pro Schritt) und prüfe jeden Schritt, bevor du fortfährst.

Prüfung und Antwort:
- Prüfe Diff auf Informationsverlust und unbeabsichtigte Entscheidungsänderungen, alle relativen Links und Anker (per Skript), Rechensummen, verbliebene doppelte Definitionen (gezielte Suche nach Schlüsselbegriffen) und `git diff --check`.
- Aktualisiere Context Handoff in docs/temp_todo.md auf den tatsächlichen Stand (Fokus, Blocker, nächster Schritt, Git-Stand, erfolgte Prüfungen).
- Berichte auf Deutsch: geprüfter Umfang, zusammengeführte Duplikate (mit zuständigem Abschnitt), umgewandelte Fließtexte, gefundene Widersprüche und neue Aufgaben, durchgeführte Prüfungen, offene Punkte. Keine vollständige Prüfung behaupten, wenn etwas fehlt.
```

## Architektur prüfen (Projektplaner mit technischer Erfahrung)

```text
Du prüfst die technische Zielarchitektur eines Spielprojekts, bevor danach gebaut wird.
Arbeite als erfahrener Projektplaner mit technischem Hintergrund: Dich interessiert,
ob sich nach diesem Plan tatsächlich bauen lässt, wo er später teuer wird und was fehlt.

## Das Projekt
„Road of the Beasts“ ist ein Spiel in Godot 4 mit zwei Teilen: einem deterministischen,
rundenbasierten Monster-Kampf auf einem Raster (Battle) und einer Management- und
Story-Ebene in einer Xianxia-Welt (Overworld). Der Kampf ist der Kern und wird zuerst
fertig. Der heutige Code unter godot/ ist ein Prototyp; das Spiel soll danach sauber
neu aufgebaut werden. Entwickelt wird von einer Person mit AI-Agents, nicht von einem Team.

## Was du prüfst
docs/architecture.md beschreibt den Neuaufbau. Nichts davon ist gebaut. Die wichtigste
Entscheidung darin: Battle und Overworld sind zwei getrennte Spiele, die einander nicht
kennen und sich nur über ein gemeinsames Datenformat treffen.

Lies dazu:
- docs/architecture.md vollständig (das ist der Prüfgegenstand)
- docs/battle.md, docs/skills.md, docs/monsters.md für die Regeln, die die Architektur tragen muss
- docs/overworld.md für das, was die Overworld leisten soll
- docs/decisions.md, bevor du etwas vorschlägst: dort steht, was bereits entschieden und
  was verworfen wurde. Verworfenes schlägst du nur mit einem neuen Grund wieder vor.
- godot/README.md und die Ordner unter godot/, um zu sehen, was der Prototyp heute tut
  und was beim Umzug in die neue Struktur wohin müsste

## Die Fragen, auf die ich Antworten brauche
1. Trägt die Trennung in zwei Spiele? Wo müssen Battle und Overworld doch voneinander
   wissen (Skill-Karten anzeigen, Kampfvorschau, Tamer-Skills, Spielstand, Übersetzung),
   und reicht das gemeinsame Datenformat dafür aus?
2. Liegt die Grenze von shared/ richtig? Was gehört hinein, was nicht, und was passiert,
   wenn sich das Datenformat ändert, während Spielstände existieren?
3. Dialog- und Story-System: Reichen die beschriebenen Felder für eine verzweigende
   Geschichte mit vielen Dialogen? Welche Fälle sind nicht abgedeckt?
4. Was fehlt ganz? Zum Beispiel Spielstände und ihre Versionierung, Fehlerbehandlung,
   Build und Export, Leistung, Tests über die Grenze der beiden Spiele, Werkzeuge für Inhalte.
5. Reihenfolge und Aufwand: In welchen Schritten würdest du vom Prototyp zur Zielstruktur
   kommen, was ist das größte Risiko, und was lässt sich weglassen, ohne später zu bereuen?
6. Ist etwas überplant für ein Ein-Personen-Projekt?

## Grenzen
- Du änderst nichts: keine Dateien, keine Commits. Das Ergebnis ist ein Bericht.
- Die Spielregeln stehen nicht zur Prüfung. Wenn eine Regel die Architektur schwierig
  macht, nenne es, aber schlage keine Regeländerung als Lösung vor.
- Trenne, was du im Dokument oder im Code nachgelesen hast, von dem, was du annimmst.
  Wo das Dokument eine Frage offen lässt, sag das, statt eine Antwort zu erfinden.

## Was du zurückgibst
Zuerst dein Urteil in zwei, drei Sätzen: tragfähig, tragfähig mit Änderungen oder nicht.
Danach die Befunde nach Schwere geordnet, die wichtigsten zuerst. Je Befund: was das
Problem ist, woran du es festmachst (Abschnitt oder Datei), was es kostet, wenn es bleibt,
und was du stattdessen vorschlägst. Zum Schluss die Fragen, die nur der Projektinhaber
beantworten kann. Lieber wenige belastbare Befunde als eine lange Liste von Kleinigkeiten.
```

## Battle-System gegen die Ziele prüfen (neutrale Zweitmeinung)

Stand des Prompts: nach der ersten Prüfung und dem Review-Paket vom 2026-11-17 (T44, S039). Vor dem nächsten Einsatz die genannten Messeinträge und Aufgaben an den Stand anpassen.

```text
Du prüfst das Kampfsystem eines Spiels, das sich noch im Entwurf befindet. Du bist an
keiner bisherigen Entscheidung beteiligt und sollst unvoreingenommen urteilen: Was trägt
die Ziele, was arbeitet gegen sie, was fehlt und was kann weg. Es gab bereits eine erste
Prüfung; ihre Vorschläge sind als Testschalter gebaut und gemessen. Du sollst sie nicht
wiederholen, sondern prüfen, ob sie stimmen, und dort weiterdenken, wo sie nicht weiterkam.

## Das Projekt
„Road of the Beasts“ ist ein deterministischer, rundenbasierter Monster-Kampf auf einem
Raster (meist 3 gegen 3 auf 7×7), gebaut in Godot 4. Der Kampf ist der Kern des Spiels und
wird zuerst fertig. Der Code unter godot/ ist ein Prototyp zum Ausprobieren von Regeln;
entwickelt wird von einer Person mit AI-Agents.

Wichtig für deine Prüfung: Alle vorhandenen Monster und Skills sind Wegwerf-Inhalte. Sie
dienten nur zum Ausprobieren der Regeln und dürfen alle gelöscht werden. Beurteile die
Regeln und Systeme, nicht einzelne Monster oder Skills. Als Nächstes soll ein Kalkulator
für Skills entstehen (wie es ihn für Monster-Stats schon gibt), mit dem Spieler und
Generator Skills bauen.

Es gibt drei Stände, die du auseinanderhalten musst:
- die Regeln, wie sie in docs/battle.md, skills.md und monsters.md stehen;
- den Build davor: Strikes schieben nur, dazu ein Basic Jab für 2 AP (T43);
- den Build jetzt: zusätzlich das Review-Paket (T44), als Testschalter und standardmäßig an.
Build-Defaults sind Versuche, keine beschlossenen Regeln.

## Die Ziele, an denen du alles misst
1. Deterministisch: kein Würfeln, keine verdeckten Informationen.
2. Easy to learn, hard to master: wenige, einheitliche Regeln; Tiefe aus Kombinationen
   und Entscheidungen, nicht aus Sonderregeln.
3. Kein frustrierender Tod: Kein Monster fällt, ohne dass sein Spieler etwas dagegen tun
   konnte. Möglichst kein Monster fällt in Runde 1; jedes soll mindestens einen Zug haben.
4. Entscheidungen haben sichtbaren Einfluss auf das Brett und den Verlauf.
5. Taktik und Strategie gewinnen, nicht das Wiederholen eines einzelnen Skills.
   Skillvielfalt ist ausdrücklich wichtig: Jeder Skill soll seine Situation haben.
6. Der Kampf endet, wenn alle Monster einer Seite 0 HP haben.
7. Verschiedene Monster bieten verschiedene Spielweisen. Dafür gibt es die Stat-Kalkulation:
   Jeder Stat soll spürbar sein, Monster sollen sich nicht ähneln.
8. Der Kampf dauert nicht ewig: im Mittel 3,5 bis 4,5 Runden.
9. Grundziel ist Square Control: Wer Felder kontrolliert, gewinnt. Das Brett ist die Waffe.

Die Ziele stehen auch in docs/battle.md §1, dort ist Square Control ein Mittel (Säule),
kein Ziel. Wo diese Liste davon abweicht, nenne die Abweichung, statt eine der beiden
Fassungen stillschweigend zu nehmen.

## Was die erste Prüfung ergeben hat (prüfe es, übernimm es nicht)
Gemessen mit einfachen Bots (S039); mittlere Runden · Kämpfe unter 3 · über 5 Runden von 320:
- Regeln 3,75 · 37 · 23; Build davor 4,18 · 14 · 38; Build jetzt 4,04 · 1 · 13.
- Belegt: Eine Runde 1 ohne Schaden nimmt die frühen Enden weg, kostet aber Länge; stärkere
  Dragon Veins (2 Schaden ab Runde 3) holen die Länge zurück.
- Nicht belegt: dass das Rundenende den begünstigt, der zuletzt zieht, und Pace deshalb
  verkehrt herum wirkt; dass Züge pro Runde „einmal pro Zug“ aushebeln. Die Schalter dazu
  (geschlossenes Rundenende, Abwarten, Nutzung je Runde) bewegen bei den Bots nichts.
- Ohne messbare Wirkung, also nur ein Argument über Lernaufwand: Zonen ohne Stat-Effekte,
  keine Kin-Effekte, Boden ohne Stufen, Schub auf jedem getroffenen Feld, Props mit Uhr.
- Neue Nebenwirkungen: Dragon Veins machen jetzt über ein Drittel des Schadens, und es gibt
  mehr Unentschieden. Mit dem planenden Bot war das Paket (Adern ab Runde 5) zu lang:
  4,88 · 0 · 33 von 160; Adern ab Runde 3 sind mit ihm nicht gemessen.
- Mit ruhiger Runde 1 ist direkter Strike-Schaden für Ziel 3 kaum noch ein Problem
  (4,03 · 7 · 16); offen bleibt, ob er Ziel 9 schadet.

## Was du liest
- docs/battle.md vollständig: Ziele und Säulen (§1), Ablauf, Zeitpunkte, Brett, Schaden,
  Verschiebung
- docs/skills.md: Skill-Karte, Formen, Bewegungsarten, Wert und Preise
- docs/monsters.md: Stats, Kalkulation, Kins
- docs/content.md nur als Beispielmaterial (Wegwerf-Inhalte, siehe oben)
- docs/decisions.md, bevor du etwas vorschlägst: dort steht, was entschieden und was
  verworfen wurde. Verworfenes schlägst du nur mit einem neuen Grund wieder vor.
- docs/temp_todo.md, docs/todo/to-clarify/battle/T43-*.md und T44-*.md: was gerade
  ausprobiert wird, mit den Lesarten, die beim Bauen gewählt wurden
- godot/README.md: welche Testschalter es gibt und welche als Build-Default gesetzt sind
- docs/simulation_log.md, die Einträge S032 bis S039. Das sind Indizien von einfachen Bots,
  keine Belege dafür, wie Menschen spielen. Die Bots zielen keine Flächen, planen nicht um
  Boden herum, haushalten nicht mit Stamina und planen keine Zugreihenfolge. Ein Schalter
  ohne messbare Wirkung ist damit nicht widerlegt.

## Die Fragen, auf die ich Antworten brauche
1. Die erste Prüfung: Wo hat sie recht, wo irrt sie, was hat sie übersehen? Nenne mindestens
   einen Befund, dem du widersprichst, oder begründe, warum du keinem widersprichst.
2. Square Control: Der Kampf hängt an drei Feldern und einer Uhr. Ist das Square Control im
   Sinn von Ziel 9, oder ein Wettlauf um drei Berührungen? Was hieße „kontrollieren“
   (zuletzt berührt, gehalten, Mehrheit), und wie bekämen mehr Felder einen Wert, ohne eine
   neue Mechanik und ohne längere Kämpfe?
3. Dragon Veins als Längenhebel: Ist doppelter Schaden ab einer Runde der richtige Weg, oder
   besser Zahl und Lage der Adern oder die Brettgröße? Was tun gegen die Unentschieden?
4. Runde 1: Schutz per Regel (kein Schaden), per Abstand (größeres Brett) oder gar nicht?
   Was kostet jede Variante an Regeln und an Kampflänge?
5. Direkter Schaden, jetzt als reine Frage von Ziel 9 und Ziel 5: Sollen Strikes Schaden
   machen, nur schieben, oder soll Schaden ein teurer Teil der Skill-Karte sein? Braucht es
   den Basic Jab als dritte Grundaktion neben Step?
6. Pace und Reach: Beide zeigen bei den Bots nichts. Haben sie nach den Regeln eine eigene,
   spürbare Aufgabe? Wenn nein: was gäbe ihnen eine, mit möglichst wenig Regel, oder soll
   einer der beiden weg? Bewerte „Abwarten“ ausdrücklich.
7. Was Bots nicht zeigen können: Welche der kleinen Schalter (Zonen, Kin, Bodenstufen,
   Rundenende, Nutzung je Runde, Props mit Uhr) würdest du allein aus der Regelsicht
   behalten oder verwerfen, und woran sollte der Projektinhaber es beim Spielen von Hand
   erkennen? Gib je Schalter eine Beobachtung an, auf die er achten kann.
8. Skill-Kalkulator: Welche festen Verhältnisse muss er vorgeben, bevor Preise gemessen
   werden (Schaden mit und ohne Position, Heilung, AP-Stufen, Nutzungsgrenzen in einem
   Kampf von vier Runden)? Was gehört auf die Karte, was in eine Prüfung des ganzen Kits?
9. Neue Ideen: höchstens drei, jede an einem Ziel begründet, jede so einfach wie möglich.
   Lieber eine bestehende Regel verallgemeinern als eine neue hinzufügen.

## Grenzen
- Du änderst nichts: keine Dateien, keine Commits, keine Simulationsläufe. Das Ergebnis
  ist ein Bericht.
- Die Overworld (Management, Fortschritt, Geschichte) steht nicht zur Prüfung und ist kein
  Argument für oder gegen eine Kampfregel.
- Trenne, was du in den Dokumenten oder im Code nachgelesen hast, von dem, was du annimmst
  oder aus Erfahrung mit anderen Spielen schließt. Wo die Dokumente eine Frage offen
  lassen, sag das, statt eine Antwort zu erfinden.
- Nenne bei jedem Messwert, den du zitierst, mittlere Runden und die Kämpfe unter 3 und
  über 5 Runden, und aus welchem der drei Stände er stammt.
- Schone nichts, weil es schon gebaut ist, und lobe nichts, um höflich zu sein. Das gilt
  auch für die erste Prüfung.

## Was du zurückgibst
Zuerst dein Urteil in drei, vier Sätzen: Trägt der Build jetzt die Ziele besser als die
Regeln, und was ist das größte verbleibende Problem. Danach:
- Zur ersten Prüfung: bestätigt, widersprochen, übersehen (je mit Beleg)
- Regel werden lassen: welche Schalter aus T43 und T44 du übernehmen würdest
- Verwerfen: welche nicht, und warum
- Von Hand prüfen: je Schalter die Beobachtung, auf die es ankommt
- Neue Ideen: höchstens drei
Dann die Antworten auf die Fragen 2 bis 8, je in wenigen Sätzen, und zum Schluss die
Fragen, die nur der Projektinhaber beantworten kann. Lieber wenige belastbare Befunde als
eine lange Liste von Kleinigkeiten.
```
