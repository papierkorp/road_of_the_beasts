# Temporäre Klärungsliste — Road of the Beasts

Zentrale Liste der offenen Designentscheidungen und Validierungen aus den drei GDDs. Die Reihenfolge unten ist eine vorgeschlagene Arbeitsreihenfolge, keine neue Spielregel. **Nur im Ordner `docs` und auf `main` arbeiten.**

## Verwendung

- Die GDDs beschreiben den aktuellen Arbeitsstand; vorhandene Vorschläge und Zahlen sind durch diese Auslagerung **nicht automatisch beschlossen**.
- Offene Fragen, Alternativen und Prüfaufträge werden ausschließlich hier gepflegt. Inhaltliche Entwürfe, historische Changelogs und dokumentierte Prototyp-Abweichungen bleiben in den GDDs erhalten.
- Erst die unter „Voraussetzung“ genannten Punkte abschließen, dann das Thema entscheiden. Unabhängige Punkte derselben Phase können parallel bearbeitet werden.
- Nach Abschluss: Entscheidung in die angegebenen GDD-Abschnitte übernehmen, betroffene Begleitdateien synchronisieren und den Punkt hier abhaken. Bei Playtests erst Messung und Ergebnis dokumentieren, dann gegebenenfalls Regeln ändern.
- **D** = Designentscheidung, **V** = Validierung/Balance, **K** = Konsistenzkorrektur. Quellen beziehen sich auf die weiterhin gültigen Abschnittsnummern der GDDs.
- **Zentrale Skill-Spezifikation:** `gdd_monsters.md` Kapitel 4. Dort werden Kit, Baukasten, Schema, Validierung, Zugang und Slotentwicklung definiert. Battle beschreibt die generische Laufzeit-/Board-Auflösung; Overworld nur Meta-Integration, Ökonomie und eigene Tamer-/Loadout-Inhalte. Keine parallelen Monster-Skillpreislisten oder Upgrade-Regeln pflegen. Historische Angaben sind keine aktive Spezifikation.

## Übergabe / Wiedereinstieg — aktueller Stand 2026-11-08

Diese Übergabe ersetzt die alten Gesprächsverläufe und Rechenproben. Die Aufgaben T01–T35 darunter bleiben maßgeblich. **T02, T05 und T13 sind offen; keine Balancefreigabe.**

### Arbeitsweise und Zuständigkeiten

- **Nur `docs/`, auf `main` bleiben.** Keine Implementierung, Commits, Branches, Pulls oder Resets ohne Auftrag. Gestagte/ungestagte Nutzeränderungen erhalten; vor Änderungen Git-Stand prüfen. Zuletzt `main` einen Commit hinter `origin/main`; nicht automatisch synchronisieren.
- Deutsch, knapp und verständlich. Der Nutzer möchte ähnliche **Kostenentwürfe gesammelt durch den Agenten ausarbeiten lassen**, nicht jede Zahl einzeln bestätigen. Grundsätzliche Gameplayänderungen nicht aus dieser Erlaubnis ableiten; Empfehlungen begründen und neue Zahlen als Entwurf kennzeichnen.
- **Lesbarkeit ist ausdrücklich wichtig:** kompakte Tabellen und kurze Regeln statt wiederholter Warntexte/Entscheidungsprotokolle. §4.5 wurde bereits gebündelt; beim Weiterarbeiten nicht erneut aufblähen. Gesprächskontext gehört hierher, Preise nur zentral ins GDD.
- **Monsters Kapitel 4 ist die zentrale Skillquelle:** §4.1 Kit/Zugang, §4.2 gemeinsames Modell, §4.3 Ausführungsprofile, §4.4 Effekt-/Boardverträge, §4.5 Kosten, §4.6 Slotentwicklung, §4.7 Referenzen/Validierung. Battle besitzt allgemeine Kampf-/Boardauflösung; Overworld Meta, Tamer und Loadout. Bereits erfolgte Konsolidierung nicht neu planen.
- Alle Monster-Skills einschließlich Passives/Self-Buffs/Signatures nutzen dieselben 14 Feldgruppen. Keine Custom-/`unique`-Sonderstruktur, künstlichen Flächen für Non-Area-Skills, globalen `affects_ground`/`affects_air`-Autoreneingaben oder 0-AP-Aktivpassives. Ebenen stehen am Effekt, Bodenänderungen in `board_changes`. Darstellbarkeit/Preis ist keine Contentfreigabe.

### Bestätigte Prinzipien und gewählte Arbeitswerte

- Keine Aspekte, Dreiecke, Attunement oder festen Ersatz-Elemente. Freie Themen und entworfene Spezies-Lernlisten; T01/T33/T34 abgeschlossen.
- Designer erstellen fertige Skills/Upgrades; keine freie Spieler-Konstruktion. Konstruktionspunkte sind interne Bewertungsdaten, nicht Schaden, EP, Spielerwährung oder Overworld-Blueprint-Items.
- **Gemeinsame Budgetobergrenzen 24/30/36 für Slot-Level 1/2/3**, keine Ratings, Mindestwerte, Zufallsbudgets oder eigenen Pools/AP-Klassenbudgets. Skillart allein bekommt keinen pauschalen Preis; bewertet werden Mechaniken/Verträge.
- **AP-Effizienz:** 1/2/3/4/5 Battle-AP kosten 12/6/3/1/0 Konstruktionspunkte. Hohe AP geben keine negativen Gutschriften. Bestehende Battle-AP nicht automatisch verändern.
- **Schadenskomponente:** Schaden × potenzielle Trefferzellen × 2. Sofortschaden 100 %, kein pauschaler Sofortzuschlag; angekündigter ausweichbarer Surge-Schaden 50 % ausschließlich dieses Schadensanteils. Andere Komponenten nicht automatisch halbieren. Trefferzellen sind keine garantierten Treffer.
- **Strike verursacht weiterhin 2 HP Schaden pro getroffenem Monster.** Zahlen wie 32 in einer Kostenspalte sind Konstruktionspunkte! Tabellen eindeutig beschriften. 2×2-Treffermultiplikation bleibt offen, nicht implizit einführen.
- Boardanker innerhalb Reach ohne LOS zusammen +2; wirksame Strike-Richtungsauswahl +2, symmetrische Formen ohne geänderte Trefferfelder +0. Boden-/Luft-Schadensabdeckung +2 je Schadenseffekt. Normale Surge-Markerblockierung +1 je vollständigem Marker.
- Fixe Nicht-Strike-Formen bekommen keinen pauschalen Formaufschlag. **Strike-Ausnahme:** +2 pro Trefferzelle außerhalb des angrenzenden 8er-Rings; für 1×1 `max(abs(dx), abs(dy)) > 1`, nicht Manhattan Reach.
- Kin-Effekte zählen ins gemeinsame Budget. Scaled-Push +2 je potenzieller Trefferzelle, Winged-Rückzug +3 einmal pro Einsatz. Normale Prop-Schädigung offensiver Skills vorerst ohne generellen Zuschlag; keine neuen Schadensrechte für Support/Bewegung.
- Vollständige Entwicklung bei ursprünglichem AP-Preis erforderlich. Keine direkten Schadens-, AP-Senkungs- oder Cast-Reichweiten-Upgrades; höhere AP nur optionale sichtbare Zweige. Slotfortschritt individuell, gemeinsamer EP-Pool mit körperlicher Evolution. Pillenbasierter Skillwechsel außerhalb Expeditionen erhält Slotfortschritt; EP-/Pillenökonomie noch offen.

### Zuletzt beschlossen — hier genau wieder einsteigen

1. **Kombinationszuschläge sind generell gestrichen**, auch innerhalb eines Skills. Gesamtpreis = tatsächliche mechanische Komponenten + AP-Effizienz beziehungsweise passive Verfügbarkeit. Früher ergänzte Synergieaufschläge nicht wieder einführen. Vorhandene `combination_cost`-Felder bleiben 0. Wechselwirkungen trotzdem testen; bei Problemen verantwortliche Komponenten/Regeln prüfen.
2. **„Rückstand“ meint die Bodenänderung nach Surge-Ausführung**, nicht Props. Eruption → Lava I, Flood → Thornbed I, Rift → Blight I, mit vorhandenen Höhen-/Prop-Ausnahmen. Diese Bodenwirkung gehört zu den konkreten Profilen; der allgemeine Surge-Lifecycle verlangt sie nicht automatisch. Die rückstandsfreie Referenz ersetzt diese Profile nicht.
3. **Brauchbare grundlegende Surges einschließlich ihrer vorgesehenen Bodenwirkung sollen 1 Battle-AP kosten können.** Nicht alles auf 2 AP verteuern: Bewegung kostet bereits 2, AP-Stat anfangs 2; das würde die Aktionsmöglichkeiten verarmen lassen.
4. Verzögerter Surge-Hazardrückstand hat jetzt **agentenseitig entworfene 1 Konstruktionspunkt/Zelle** statt 4 bei sofortiger Hazardplatzierung. Kein weiterer 50-%-Rabatt, zweiter Cast-Anker oder zweite AP-Effizienz. Der Nutzer hat die Richtung „günstiger, keine Kombokosten“ beschlossen, **nicht diesen exakten Einzelpreis separat ausgewählt**.

Die Änderungen stehen in Monsters §4.5/§4.7, der Overworld-Trackingverweis ist synchronisiert. Keine Gameplay-AP oder Schadenswerte geändert. Alte Rechnungen mit 42 Punkten für den Drei-Zellen-Rückstands-Surge sind gelöscht/ersetzt; nicht als aktuellen Befund verwenden.

### Bereits durch den Agenten ausgearbeitet — Testentwürfe, keine validierte Gleichwertigkeit

Die vollständigen Preise/Annahmen stehen ausschließlich in Monsters §4.5; hier nur Orientierung:

| Bereich | Aktueller Stand |
|---------|-----------------|
| Strikes | 11 Formen × 6 Kins tabelliert; Spirit/Swarm/Ancient je +2 je potenzieller Trefferzelle. Swarm/Ancient besonders vorläufig wegen Prop-/Höhenüberarbeitung. |
| Bewegung | Feste Profilpreise statt je gelaufenem Feld: Run 6, Leap/Glide/Burrow 8, Phase 7, Blink 10; jeweils +6 AP-Effizienz bei 2 Battle-AP. Swim geplant (7 + angenommene 6), Step slotfrei/außerhalb Skillbudget. Keine freien Flag-Upgrades. |
| Self/Passive | Focus 8 + 12 = 20; Adaptive 6 + 12 Verfügbarkeit = 18. Focus weiterhin Contententwurf; passive Verfügbarkeit zunächst nur für selbstgebundene kontinuierliche boolesche Erlaubnis, nicht alle Passives. |
| Zonen/Schutz/Heilung | Raten für Statmods, Push/Pull, Veil und Mend; normales AP-bezahltes Leveln/Refresh in Basisraten enthalten. Erlaubte Werte/Caps/Heiltrigger dadurch nicht entschieden. |
| Ground/Board | Paketpreise für permanente Gefahren-/Segensböden, Raise Ground/Collapse und vorläufige Props/Relocate. Permanente Wirkung nicht nochmals als sofortiger Schaden/Zone berechnen. Zusätzliche Cleanse-Quellen nur Preisplatzhalter, keine Freigabe. |

Alle sechs Referenzfälle haben erste Rechnungen: **Beast-Jab 14, Slow-Zone 23, rückstandsfreier Surge 24, Run 12, Focus 20, Adaptive 18**. Keine vollständigen dreistufigen Entwicklungspfade oder Content-/Balancefreigaben.

### Aktuelle Gegenprobe und verbleibende Konflikte

| Beispiel | Punkte | Aussage |
|----------|--------|---------|
| Struktureller Surge: 2 Zellen, 3 Schaden, Hazardrückstand, 1 AP | 23 | 6 Schadenkosten + 2 Rückstand + 1 Marker + 2 Anker + 12 AP-Effizienz |
| Derselbe Strukturentwurf mit 3 Zellen, 1 AP | 27 | 9 + 3 + 1 + 2 + 12; noch über Basisbudget 24 |
| Veil / Quicken 1: 2 Zellen, 2 Runden, 1 AP | 22 | Kleine Basiskandidaten rechnerisch möglich, keine neuen Footprints beschlossen |
| Mend 1: 2 Zellen, 2 Runden, 1 AP | 26 | Heilungsregeln und Basiskosten noch abstimmen |
| Long Whirl / Long Cross als Beast bei 5 AP | 42 | Größte Legacy-Strikes passen nicht in 36; AP-Effizienz schon 0, AP-Anheben hilft nicht |

**Keine komplette Eruption-/Flood-/Rift-Bewertung:** obige Surge-Beispiele enthalten keine besonderen Push-, Höhen- oder Propwirkungen. Kleine Basiskandidaten sind eine Empfehlung, kein Beschluss „alle Basic-Skills nur zwei Felder“. Keine Preis-/Budgetänderung nur zum passenden Ergebnis verstecken.

### Nächster Agent: konkreter Arbeitsauftrag

- Zuerst diese Übergabe und Monsters §4.5 lesen; §4.3/§4.4/§4.7 gezielt hinzunehmen. Budget/AP-/Schadensprinzipien, Props und gestrichene Kombokosten **nicht erneut zur Grundsatzwahl stellen**.
- **Zuerst den letzten Surge-Stand abrunden:** grundlegende Eruption/Flood/Rift inklusive vorgesehener Bodenwirkung und bestehender Zusatzmechanik als kompakte Gegenprobe bei **1 AP** berechnen. Restkonflikte benennen, insbesondere Flood-Push/Rift-Höhenbruch; offene Auflösungsregeln nicht erfinden. Exakter Rückstandspreis bleibt Testentwurf.
- Danach wenige vollständige **Same-AP-Entwicklungspfade** entwerfen: Run, einfache Zone, Surge mit vorgesehener Bodenwirkung sowie Jab. Budgetgrenzen, reale Verbesserungen und zugelassene Patches prüfen. Jab benötigt sinnvolle Entwicklung ohne Schadens-/AP-/Range-Upgrade. Bei nicht lösbaren Legacy-Konflikten klar zur Entscheidung vorlegen, nicht Grundprinzipien umgehen.
- Erst anschließend gemeinsame EP-Vergabe/-Kosten für körperliche und Slotentwicklung ausarbeiten (T05). T02 nicht vor vollständiger Kalkulation/Vertragsprüfung als erledigt markieren; T13 erst nach echten Tests.

### Offen lassen / Validierungsstand

- **Props später grundsätzlich überarbeiten (T04):** konkrete Einwirkung × Prop bestimmt Zerstörbarkeit und Reaktion; Splitter/Fallen können sichtbaren Schaden verursachen, Baum kann sich teilen oder anders abbrennen. Zunächst Fallwirkung plus Boden-/Darstellungsreste, keine beweglichen Baumhälften. Alles deterministisch vorhersehbar. Battle §4.9 enthält die Richtung; alte pauschale Shatter-Regeln nur Zwischenstand. Keine Detailrunde dazu vorziehen.
- Effekt-Caps/Stacking/Refresh über Quellen, Tod/Entfernung, passive Trigger/Frequenz/Rekursion, Focus-Refresh/Contentwerte, Schutzverbrauch, Flood-/Tail-Sweep-Reihenfolge, Pull-Gleichstände, Kollision, Zielverlust, Luft/2×2 und Major-/Signature-Zugang bleiben Fachaufgaben. Preisplatzhalter lösen keine davon.
- EP-Mengen/Unlocks, passive Slotentwicklung/Aktiv-Passiv-Wechsel, Same-Skill-Respec, EP-Rücknahme/-Übertragung, Umlernpillen-Rezept/Preis und Tages-AP offen; alte Normal-Vergabe ergibt insgesamt nur 2 EP und ist ungeprüft.
- Ausschließlich Dokumentation. Rechensummen (u. a. 66 Strike-Summen, Bewegungs-/Buff-/Residuebeispiele) und `git diff --check` wurden geprüft; keine Engine-/Balance-Playtests. Früherer Prototyp implementiert nicht automatisch den aktuellen GDD-Stand.

## Phase 1 — Grundlagen und widersprüchliche Regeln klären

### [x] T01 · Aspekt-System bestätigen (D/V)
**Voraussetzung:** keine.
**Quelle:** `gdd_monsters.md` §7.4; `gdd_battle.md` §3.2, §4.8.
- **Beschlossen:** Dreieck und feste Monster-Aspekte entfallen; keine festen Elemente als Ersatz. Monster erhalten freie beschreibende Themen, ihre erlaubten Fähigkeiten bestimmen bewusst entworfene Spezies-Lernlisten.
- Attunement entfällt. Konkrete Skills, Böden und Surge-Verhalten bleiben als Baukasten erhalten, ohne feste Aspektbindung oder verpflichtende Dreifachvarianten.
- In allen drei GDDs übernommen. Neue Bodeninteraktionen werden unter T07 geklärt; konkrete Lernlisten und Roster unter T10–T12. Die Balance der verbleibenden Mechaniken ist dadurch noch nicht validiert.

### [ ] T02 · Datenmodell, Punktekalkulation und AP-Effizienz abschließen (D/K)
**Voraussetzung:** T01.
**Quelle:** `gdd_monsters.md` §4.1–§4.7; `gdd_battle.md` §2.3/§5; `gdd_overworld.md` §6.3.2.

**Erarbeitet und dokumentiert:**
- Gemeinsames Modell aller Monster-Skills, zentrale Profile/Verträge und sechs Referenzen; keine parallelen Skillquellen oder Custom-Sonderstrukturen. Designer-Skills/Upgrade-Auswahlen statt Spieler-Konstruktion.
- Gemeinsame Budgetobergrenzen 24/30/36, AP-Effizienz 12/6/3/1/0, Schadensfaktor 2 und 50 % ausschließlich auf angekündigten ausweichbaren Surge-Schaden als gewählte Arbeitsentwürfe. **Keine Kombinationszuschläge.**
- Tabellenentwürfe für alle Strikes/Bewegungsprofile, Self/Passive, Zonen/Schutz/Heilung sowie Boden/Board. Sechs Referenzen mit ersten Summen, noch keine vollständige Content-/Balancevalidierung. Preise nur zentral in Monsters §4.5 pflegen, hier nicht duplizieren.
- Surge-Rückstand = verzögerte Bodenänderung; Eruption/Flood/Rift behalten ihre vorgesehenen Böden. Neuer Designer-Testpreis 1 Punkt/Zelle für verzögerten Hazardrückstand (sofortiger Field 4/Zelle); grundlegende Surges sollen inklusive Bodenwirkung bei 1 AP möglich sein.

**Noch zu erledigen:**
- Vollständige 1-AP-Gegenprobe für Eruption/Flood/Rift inklusive Zusatzmechaniken; fehlende Regeln T04/T07/T09 zuordnen, keine impliziten Defaults. Kleine strukturelle Gegenprobe passt bei zwei Zellen in 24, drei Zellen kosten 27; das ist keine automatische Skillfreigabe.
- Budgetkonflikte bei großen Strikes, Heilung und komplexen Surges gezielt lösen, ohne automatisch Budgets/AP/Schaden zu ändern oder getrennte Skillart-Pools einzuführen. Keine doppelte Flächen-/Flag-/Quellenbewertung.
- Vollständige Entwicklungspfade bei ursprünglichen AP ausarbeiten, insbesondere Jab; größere Formen behalten bestehende AP bis zur Neuentscheidung. Keine direkten Schadens-, AP-Senkungs- oder Cast-Reichweiten-Upgrades. Anschließend T05/EP.
- Fehlende Footprints/Anker/Orientierungen, Sicht/Zielgültigkeit, Effektwerte/Caps, Trigger/Endbedingungen und Interaktionsreihenfolgen vervollständigen. Self-/Passive-Stacking, Quellengruppen, Tod/Entfernung und Wiederholung/Rekursion explizit festlegen. Focus bleibt Entwurf; keine neue Mechanik allein durch ein Schemafeld zulassen.
- Kombinationen und Wiederholung als Balance-/Vertragsfrage prüfen, **nicht als zusätzliche Preiskategorie**. Props, Heilung, Luft und 2×2 nach T04/T07–T09 einbeziehen. Zahlen erst durch geeignete Tests validieren; T13 bleibt offen.

### [ ] T03 · Stat-Budget, Frames und Progressionsgrenzen prüfen (V/K)
**Voraussetzung:** T02.
**Quelle:** `gdd_monsters.md` §2.1–§2.3, §7.4; `gdd_overworld.md` §1.2, §2.4.
- Preise, Budgets und alle skalierten Frames prüfen; Reichweite kostet 3 Punkte pro Stufe und betrifft nun alle Casts. Reach-2-Individuen gegen den alten Surge-Radius 3 testen.
- Init beim Roll 1 Punkt = 1.0, beim Level-up = 0.1: gleiche erhaltene Punkte bedeuten nicht zwingend gleiche resultierende Stärke; frisch gerollte und hochgezogene Individuen vergleichen.
- Stage vs. genauer Sub-Tier als Monster-Cap vereinheitlichen (§7.4 nennt den Schritt, andere Texte nur die Stage).
- Overworld-Texte begrenzen ausgegebene Punkte teils noch durch den Frame; Monster-GDD begrenzt nur den Roll durch den Frame.
- Step-only-Monster: zufällige Movement-Punkte gegenüber „bleibt am Frame-Minimum“ eindeutig regeln.

### [ ] T04 · Auflösungsregeln und Sonderfälle konsistent machen (D/K)
**Voraussetzung:** T01, T02.
**Quelle:** `gdd_battle.md` §2.2, §4.1, §4.4, §4.8, §4.10, §6.1–§6.3; `gdd_monsters.md` §5.
- Kollision: Schadensgesetz nennt Monster-Kollisionen, Detailregel sagt kein Schaden. Crashlander dagegen abgleichen. Shockwaves bisherigen Kollisionsbonus +1 gegen das feste Ereignisschadensgesetz prüfen; bislang keine beschlossene Ausnahme.
- Auflösungsreihenfolge für Flood-Schaden/Rückstand/Push und Tail-Sweep-Schaden/Push festlegen; Pull-Gleichstände und Verhalten bei bereits belegtem Anker explizit definieren.
- Schutzquellen: Stacking, Reihenfolge und Verbrauch bei auf 0 reduziertem Schaden festlegen; Ward, Veil und Hallowed unterscheiden. Tamer-Ausnahmen mit T20 abstimmen.
- Kombinierte Boardoperationen: Reihenfolge von Collapse, Debris, Residue und Cleanse festlegen; Relocate-Distanz, Pfad, legale Ziele und Reaktionen konkretisieren. Keine freien Defaults aus Datenfeld-Reihenfolge ableiten.
- Attunement-/Elevated-Konflikt durch T01 entfallen; verbleibende Kombinationen aus Höhe und konkretem Boden prüfen.
- Zonenwerte ohne Attunement: harte Caps für Slow (2) und Push/Pull (1) sowie Level-Skalierung konsistent halten.
- **Prop-Überarbeitung:** gemeinsame Einwirkungs-/Reaktionsverträge; breit zerstörbare Props und konkrete Ausnahmen/Resistenzen definieren. Zerstörungsart bestimmt Splitter-/Fallwirkung und Rückstände statt immer identischem Shatter. Baum kann sich teilen; zunächst Fallwirkung plus Boden-/Darstellungsreste, keine separat beweglichen Hälften. Fallrichtung, Trefferfelder, Schaden und Zustand danach deterministisch vorhersagen. Einwirkungskategorien, Prop-Katalog, HP/Schadensmatrix, Kettenreaktionen und Ereignisreihenfolge noch offen. Bestehende Zahlen bleiben Zwischenstand, keine neuen pauschalen Trefferrechte. Gewöhnliche Prop-Schädigung für Kosten vorläufig gemeinsame Basis ohne Zuschlag (Monsters §4.5); besondere Vorteile und Kosten nach Redesign prüfen.
- Sigil ist betretbar; Prop-Regel sagt „Prop nimmt Schaden, Monster dort nicht“. Trefferreihenfolge für Monster auf Field-Props definieren.
- Zielgültigkeit bei Auflösung klären: bewegtes, gefallenes oder entferntes Einheiten-/Propziel und ungültig gewordene Platzierung. Kein implizites Tracking, Retargeting oder frei erfundener Abbruch-/Erstattungsdefault. Gleichzeitige Ereignisse und Ablauf-/Trigger-Reihenfolge deterministisch festlegen.
- Surge bei mehreren Turns pro Runde, geänderter Initiative oder totem Caster präzisieren: „nächster Caster-Turn“ garantiert nicht, dass alle anderen vorher handeln.
- Deterministische Gleichstände bei Voidscar-Auswahl sowie Push/Pull-Ziel und freien Ausweichfeldern definieren.
- Punktsymmetrische Generierung gegen ungerade Prop-Anzahlen prüfen; zulässige zentrale Einzelobjekte je Boardgröße festlegen.

## Phase 2 — Skills, Entwicklung und Monster-Identität

### [ ] T05 · Skill-Verbesserungen abschließen (D)
**Voraussetzung:** T02.
**Quelle:** `gdd_monsters.md` §4.6 (Slotentwicklung), §7.2/§7.4 (EP-/Fortschrittsentwurf); `gdd_overworld.md` §6.3.2 (Integration).
- **Beschlossen:** Permanente Skillslotentwicklung ist eine zusätzliche Evolutionsmöglichkeit des individuellen Monsters. Körperliche Evolution und Slotentwicklung verwenden denselben EP-Pool. Ein bezahlter Slotentwicklungsschritt gewährt direkt eine von Designern entworfene, skillabhängige Upgrade-Auswahl; keine zusätzliche Spieler-Punktwährung.
- **Beschlossen:** Skillwechsel aus der freigeschalteten Spezies-Lernliste außerhalb von Expeditionen kostet eine wertvolle Umlernpille statt EP. Slotentwicklung bleibt erhalten; passende Upgrades für den neuen Skill werden im bestehenden Entwicklungsumfang neu gewählt. Kein kostenloses Re-Slotting, kein EP-bezahlter Swap-Pfad.
- **Nächster Schritt:** Gemeinsames EP-Budget und Preise für körperliche Evolution und Slotentwicklung entwerfen. Alte Vergabe von 1 EP für Normal/Rare bzw. 2 EP für Epic/Legendary ist unvalidiert; Normal hätte bisher insgesamt nur 2 EP. Zielinvestitionen über mehrere Slots und Konkurrenz zu körperlichen Entwicklungen prüfen.
- **Beschlossen:** Slot-Level 1–3 mit steigenden Budgetobergrenzen, keine Skill-Ratings. EP-Preise, Freischaltungen und mögliche Zwischenentwicklung innerhalb dieser Level festlegen; keine weitere Ranghierarchie voraussetzen.
- **Beschlossen:** Kleine feste Schadenswerte bleiben erhalten. Slot-Upgrades erhöhen keinen direkten Schaden, senken keine AP-Kosten und erhöhen keine Cast-Reichweite. Erlaubte Verbesserungsarten: Fläche, Form/Orientierung, Dauer, Bewegung/Verschiebung und ausdrücklich entworfene Zusatzeffekte; jeweils mit skillabhängigen Grenzen. Gesamtauswirkung durch mehr Ziele oder Trigger trotzdem prüfen.
- Für jeden Skill ausreichend viele vorab sichtbare Upgrade-Auswahlen, Voraussetzungen, Ausschlüsse und Caps entwerfen; Shape, Size, Twist und Small value als Kandidaten prüfen. Die entfernten Legacy-Swap-Pfade nicht wieder einführen; Wechsel bleibt pillenbasiert.
- Klären, wie Slots mit unterschiedlich vielen legalen Upgrade-Angeboten behandelt werden und wie passive bzw. passive-only Slots sowie Aktiv/Passiv-Wechsel funktionieren. Keine Slotinvestition beim Wechsel verlieren lassen.
- Noch offen: Kosten der Neuwahl bestehender Upgrades desselben Skills, Rücknahme von EP-Investitionen und eventuelle Übertragung zwischen Slots. Pillenkosten für Upgrade-Respec sind bislang nur Empfehlung, nicht beschlossen.
- Umlernpille konkretisieren: verlässliche Beschaffung, Rezept, Tier, Preis und Tages-AP mit T16/T30/T31 abstimmen; bewusster Wechsel statt ständigem Umbau, ohne Experimentieren dauerhaft zu bestrafen.
- Generisches Size-Maximum 4 gegen Strike-Formen bis 8 Felder abgrenzen. Die alten widersprüchlichen Shape-Preise sind überholt; konkrete Upgrade-Angebote und EP-Schrittpreise im gemeinsamen Modell festlegen.

### [ ] T06 · Strike-Formen und Kin-Effekte abschließen (D/V)
**Voraussetzung:** T02, T03, T05.
**Quelle:** `gdd_monsters.md` §3.2.
- Vor Core nur Jab: kommen interessante Formen zu spät? Storm/5-AP-Formen erreichen nur späte TPR-1-Builds.
- Whirl (4 Felder) gegen Arc (3) zum selben Preis sowie Nutzen der Thrust-Reichweite testen. Die alte Frage nennt „Skewer“, die Tabelle „Thrust“: Bezeichnung vereinheitlichen.
- Beast Bite: eigenen Effekt ohne Verletzung der Schadensobergrenze geben oder fehlenden Effekt bewusst akzeptieren.

### [ ] T07 · Bodeninteraktionen und Heilung abstimmen (D/V)
**Voraussetzung:** T01, T02, T04.
**Quelle:** `gdd_battle.md` §4.6–§4.8; `gdd_monsters.md` §4.2, §4.4–§4.5.
- Permanente Residuen: füllt sich das Board zu schnell, wird Rift/Blight dadurch übermächtig?
- Hazard-Anteil auf 7×7 bis Runde 5 messen. Falls nötig: Field 2 AP oder maximal N Field-Felder pro Monster als Alternativen prüfen.
- Ohne Dreieck festlegen, ob und wie Zonen vorhandene Böden verändern; keine automatische Überlegenheit aus Monsterthemen ableiten.
- Attunement und Painting-Snowball entfallen durch T01. Stattdessen Gegenmittel gegen permanente Gefahrenböden und deren Zugänglichkeit prüfen.
- Blessing: 2 AP für permanente 3–4 Felder angemessen? Mossbed pro Turn begrenzen?
- Boon/`mend`: Heilung bei HP 1–10 prüfen; darf das Zonenlevel die Heilung erhöhen oder bleibt sie fest bei 1? Numerischen Heilungs-Cap und Mossbed-Wiedereintritt/per-Turn-Limit explizit definieren; Persistenz gewährt keine zusätzlichen Heiltrigger.
- Level-II-Rückstand als konkrete Erweiterung bewerten; der frühere Name „Deep Residue“ und +1 AP sind keine bestätigte universelle Regel.

### [ ] T08 · Wasser und Swim definieren (D)
**Voraussetzung:** T02, T07.
**Quelle:** `gdd_battle.md` §4.7, §5.5; `gdd_monsters.md` §3.3.
- Wo entsteht Wasser: nur Generator oder auch Skills? Dürfen erzeugte Gefahren- oder Segensböden Wasser ersetzen?
- Welche Kins erhalten Swim? Kostenprofil und Flag-Ausnahmen gegen die allgemeine Bewegungstabelle prüfen.

### [ ] T09 · Luft-Ebene und 2×2-Regeln spezifizieren (D/K)
**Voraussetzung:** T02, T04, T06, T07.
**Quelle:** `gdd_battle.md` §4.3, §5.5–§5.6; `gdd_monsters.md` §3.1, §4.2, §4.7.
- Welche Effekte außer Strike dürfen Luft-Empfänger haben? Ebenen am jeweiligen Effekt definieren, kein globales `affects_air`-Autorenflag. Mindestens ausreichend lesbare Gegenmittel gegen Winged ab Soul sicherstellen.
- Flugbewegung, Besetzung und Interaktion mit Props/Boden konkretisieren. Für 2×2 zusätzlich Distanzursprung, Flächenüberschneidung, Empfänger-Deduplizierung sowie Eintritts-/Austrittsauswertung über mehrere Felder definieren; das generische Flächenmodell entscheidet diese Fälle nicht.
- Ergänzend bei der Analyse gefunden: 2×2 ist angekündigt, aber Flächentreffer, Schadensmultiplikation, Platzierung, Bewegung und Displacement sind nicht ausreichend definiert. Mehrfach belegte Felder dürfen keine implizite Mehrfachschadensregel erzeugen.

### [ ] T10 · Konkrete Skills aus Blueprints neu aufbauen (D)
**Voraussetzung:** T05–T09.
**Quelle:** `gdd_monsters.md` §4.2–§4.6.
- Konkrete Skills ausschließlich im gemeinsamen Schema §4.5 erstellen und nach §4.3 validieren; keine neue parallele Blueprint-/Beispieltabelle. Effekte, Trigger, Zielwahl, Footprints, Interaktionen, Kosten und autorisierte Upgrade-Patches vollständig definieren.
- Speziesexklusive und Signature-Skills verwenden dasselbe Schema; Unterschiede über Zugang, Urheberschaft und explizite Regeln darstellen. Frühere benannte Ideen sind kein zugesagter Content. Konkrete Skills und ausreichend tiefe Upgrade-Auswahlen erst nach bestätigten Budgets auswählen.

### [ ] T11 · Lernlisten, Passives und Referenzroster überarbeiten (D)
**Voraussetzung:** T03, T06, T10.
**Quelle:** `gdd_monsters.md` §4.4, §5, §6.1, §7.4.
- Für jede Spezies lernbare Skills (derzeit Ziel ungefähr 8) und verfügbare Passives definieren: Spezies- und Individualbindung unterscheiden; freie Themen sind keine zusätzliche Lernbeschränkung. Ehemals aspektabhängige Passive überarbeiten oder streichen.
- Die neun Referenzmonster haben aktuell vier aktive Skills plus Passive; auf vier gemeinsame Slots reduzieren, Epic+-Zusatzslot gesondert behandeln.
- Jede Spezies erhält einen Species-Twist statt des gemeinsamen Platzhalters sowie eine konkrete Strike-Form und feste Surge-Orientierung.
- Beschreibungen wie „weak Flood“/„weaker Rift“ mit den geltenden Schadens- und AP-Regeln abgleichen.

### [ ] T12 · Launch-Roster auswählen (D)
**Voraussetzung:** T11.
**Quelle:** `gdd_monsters.md` §6.1–§6.2.
- Ohne Kin×Aspekt-Pflichtmatrix aus den neun Referenzmonstern und weiteren Namensideen ein vielfältiges Roster auswählen (bisher Ziel etwa 15); freie Themen und eigenständige Spielweisen statt Kategorienvollständigkeit priorisieren.
- Fehlende Blueprint-/Movement-Abdeckung und unterscheidbare Ein-Satz-Identitäten prüfen.

## Phase 3 — Kampf validieren, bevor die Meta Zahlen festschreibt

### [ ] T13 · Kampftests mit dem überarbeiteten Regelstand planen und auswerten (V)
**Voraussetzung:** T04, T07, T11; T08/T09 für Wasser-/Soul-Tests.
**Quelle:** `gdd_battle.md` §7.2; ehemalige §8; `gdd_monsters.md` §2.2, ehemalige §8.
- Erst sicherstellen, dass der getestete Build den untersuchten Entwurf umsetzt: dokumentierter Godot-Stand ist v6.0, nicht v6.3. Codeänderungen sind nicht Teil dieser Docs-Aufgabe.
- Residuen: treffen Surges indirekt auch beim Ausweichen oder erzwingen sie sinnvolle Wege?
- Lesbare Kombos: Current → Surge/Lava, Pull → Strike; Pull-Anker und Push-Richtung prüfen.
- Strike ab 2 AP: lohnend oder ungenutzt, Nahkampf zu klebrig?
- No-Cooldown-Spam und Double Veil (2 AP → Level II, Shield 3) prüfen. Fallback: Level-up nur einmal pro Turn und Feld.
- Veil Shield 2, Level/Attunement und Surge 3 auf echte Gegenmittel prüfen.
- Bewegungspreise, Step-only-Viabilität und Movement-Cap 5 prüfen.
- Drei Surge-Typen gegen Elevated; Props als taktische Ressourcen statt Hindernisse.
- 3v3/7×7: Lesbarkeit, Rundenzahl, Collapse-Anteil und Startdistanzen; Reach 4 + Elevated = 5 gegen das Versprechen eines sicheren Openings prüfen.
- First-Surge-claims-square und Initiative-Ketten/Fokusfeuer prüfen. Fallback bei Dominanz: Initiative teurer machen.
- Dusk Moth (historisch 87 % Sim-Winrate) mit Menschen und KI vergleichen; Native Ground/Wide/Blight getrennt betrachten.
- Stat-/Strike-/Heilungs-Tests aus T03/T06/T07 gemeinsam auswerten; Preise erst anhand der Ergebnisse nachjustieren.

### [ ] T14 · Reshape gegen Reroll-Ausnutzung absichern (D/V)
**Voraussetzung:** T03, T13.
**Quelle:** `gdd_monsters.md` §2.2; `gdd_overworld.md` §2.6, §7.5.
- Genügen seltenes Elixier und Ritualkosten oder braucht es Cap/Cooldown gegen wiederholtes Optimierungs-Rollen?

## Phase 4 — Welt, Kataloge und Ausrüstung (teilweise parallel zu Phase 2/3)

### [ ] T15 · Stadtmächte, Zuständigkeiten und Inhalte festlegen (D)
**Voraussetzung:** keine; parallel zum Kampfdesign möglich.
**Quelle:** `gdd_overworld.md` §3.1–§3.2, §7.2.
- Fraktionsnamen, Profile und Angebote der drei Familien festlegen.
- Betreiber von Arena, Teleport Plaza, Business District bestätigen: Vorschlag City Lord, City Lord, Guild.
- Gebäude/Zugang der Rival Compounds und Zweck der Slums klären; Black Stall bleibt eine optionale Idee, kein zugesagtes Feature.

### [ ] T16 · Material-, Item- und Rezeptkataloge vervollständigen (D)
**Voraussetzung:** T01; T10 für kampfbezogene Produkte.
**Quelle:** `gdd_overworld.md` §6.6–§6.8, §7.5–§7.8.
- Aus Mustern konkrete Materialien, Kräuter, Seeds, Rezepte, Seals, Scrolls und Blueprints ableiten; Anzahl, Stufen und Grade bestimmen.
- Mengenannahme „vier Tiers/~40 Pills“ gegen sechs Kultivierungsstufen und fehlende Sovereign-XP-Werte abgleichen.
- Grade-Abhängigkeiten und Bezugsquellen gegen „Geld kauft niemals exklusive Macht“ prüfen; Legendary-Blutlinien-Zutaten sind derzeit zugleich nur Story und bei Boss/Quest/Auktion verortet.
- Array-Rezepte und Forge-Weg (Ore + Beast Parts) bestätigen; festlegen, ob Upper Stones reine Währung oder auch Ritualmaterial sind.

### [ ] T17 · Artefakt-Regeln und Stapelung festlegen (D/K)
**Voraussetzung:** T03, T11, T16.
**Quelle:** `gdd_overworld.md` §6.7, §6.9, §7.5; `gdd_monsters.md` §7.2.
- Tamer: zwei oder drei Slots, und wann? Monster: zweiter Slot bei Epic+ oder erst zusätzlich ab Core? Tabellen synchronisieren.
- Passive ODER Stat-Mod gegenüber Schema „Passive + kleiner Stat-Mod“ klären; doppelte Passive und mehrere Artefakte begrenzen.
- +1 AP/Tag, Kapazitäts- und Skill-Mods gegen Tagesökonomie, Stage-Caps und die Options-statt-Zahlen-Regel prüfen.

### [ ] T18 · Medicines und Arrays spezifizieren (D)
**Voraussetzung:** T07, T10, T16.
**Quelle:** `gdd_overworld.md` §6.6, §6.8, §7.5–§7.6.
- Medicine-Effekte, Rezepte, Item-Kind und Abgrenzung zu Pills bestimmen. Schutz-/Heilungs-/Boardeffekte benötigen eigene Quellen-, Verbrauchs- und Timingverträge im gemeinsamen Datenmodell; Monster-Effektverträge erteilen keine automatische Item-Freigabe.
- Welche Arrays sind verbrauchbar, welche wiederverwendbar? Haltbarkeit, Platzierung und Effekte im Kampf definieren.
- Pre-battle-Arrays als begrenzte Ausnahme von neutralem/punktsymmetrischem Start bestätigen; vier bisherige Array-Entwürfe prüfen.

### [ ] T19 · Battle-Loadout und Timing abschließen (D)
**Voraussetzung:** T18.
**Quelle:** `gdd_battle.md` §5.8; `gdd_overworld.md` §2.1, §7.9, §8.
- Anzahl Medicines/Arrays, Aktivierungsfenster (eigener Turn oder jederzeit), AP-Kosten und Verbrauch festlegen.
- Dieselben Regeln für menschliche Gegner; Sichtbarkeit, Vorschau, Pre-battle-Fixierung und Rückgabe verbrauchter Items im BattleResult präzisieren.
- Abhängigkeit ist gerichtet: erst Item-Effekte/Kosten, dann Loadout-Limits; nicht beide gegenseitig blockieren lassen.

### [ ] T20 · Tamer-Skills einschließlich Beast Swap validieren (D/V)
**Voraussetzung:** T09, T13, T19.
**Quelle:** `gdd_overworld.md` §6.4; `gdd_battle.md` §5.8.
- Vorschläge Swap Places, Urgent Order, Second Wind, Life Thread, Double Bind und Seal Mastery bestätigen/ändern/verwerfen; Attune ist durch T01 entfallen. Tamer-Quellen im gemeinsamen Effektmodell ausdrücklich definieren, ohne Monster-Skillrechte oder AP-Klassen zu übertragen.
- Life Thread gegen Spirit Shield und Urgent Order gegen Initiative testen; Nutzungstiming der kostenlosen Skills festlegen.
- Beast Swap: HP, Verletzung, Warteschlange, eigene ladende Surges, 2×2-Platzbedarf und Nachrück-Regeln definieren.
- Scrolls lehren Skills früher, Beast Swap darf erst ab Soul geslottet werden: Lernen vs. Nutzen und Stage-Gates eindeutig trennen.

## Phase 5 — Expedition, Sammlung und räumliche Welt

### [ ] T21 · Dungeon-Node ↔ Board-Generator-Vertrag festlegen (D)
**Voraussetzung:** T04, T08, T12.
**Quelle:** `gdd_overworld.md` §3.3; `gdd_battle.md` §4.1.
- Was fixiert der Node, was generiert der Generator? Vorschlag: Node bestimmt Modus, Thema/Bodenfamilien und Prop-Anzahlbereich; Generator setzt alles punktsymmetrisch.
- Encounter-Zugang gegen notwendige Teamgröße und verfügbare gesunde Monster prüfen.

### [ ] T22 · Expeditionen und Loot-Tabellen abschließen (D/V)
**Voraussetzung:** T16, T19, T21.
**Quelle:** `gdd_overworld.md` §2.2, §7.8.
- Floors/Kämpfe pro Run, tieferer Einstieg (1/2 Tages-AP), Rückzug und Reward-Tabellen je Floor/Boss bestimmen.
- HP-Persistenz und kostenloser Rückzug mit Loot sind bereits Arbeitsstand, nicht erneut grundlos öffnen; offene Detailfälle daran anschließen.
- „Healing Pill ist einzige Heilung im Run“ gegen Mend/Mossbed, Heilpassives und Second Wind präzisieren: außerhalb oder auch innerhalb der Kämpfe gemeint?

### [ ] T23 · Verletzung und Deadly-Dungeons abstimmen (D/V)
**Voraussetzung:** T16, T20, T22.
**Quelle:** `gdd_overworld.md` §5.2, §6.6.
- Zwei Nächte Ausfall, Revival-Preis und Deadly-Lootbonus prüfen; optionale Deadly-Dungeons für Launch bestätigen oder zurückstellen.
- Recovery Spring halbiert bereits auf eine Nacht; zusätzlicher −1-Nacht-Nachbarschaftsbonus: Minimum festlegen.
- Heilung nach Rückkehr/nachts für nicht verletzte Monster und HP nach Genesung festlegen; Verhältnis Soul Tether/Life Thread zu permanentem Verlust prüfen.

### [ ] T24 · Binding, Eier, Zucht und Hive konkretisieren (D/V)
**Voraussetzung:** T12, T16, T20, T22.
**Quelle:** `gdd_overworld.md` §5.1, §7.5.
- Seal-Preise/Grade und zweite Bindung balancieren; Seal Mastery gegen Spieler-Stage-Cap prüfen.
- Zucht-/Hive-/Schlupfzeiten je Rarity sowie Brutbedingungen definieren; gleiche Spezies vs. „Spezies eines Elternteils“ präzisieren.
- Ei-Rarity, Spezies-Sichtbarkeit und Zufallszeitpunkt eindeutig machen.

### [ ] T25 · Internal World: Kapazität, Gebäude, Nachbarschaft (D/V)
**Voraussetzung:** T09, T16, T23, T24.
**Quelle:** `gdd_overworld.md` §4.2–§4.4.
- Grid-/Kapazitätskurve, Footprints, Unlocks und neue Strukturen bestätigen.
- Housing-Kapazitätsbonus, Mood/Loyalty und deren konkreten Nutzen festlegen oder unnötiges System streichen.
- Schlupf bei voller Kapazität, gemietete Monster und Bench-Größe regeln.
- Trial Pillar öffnet erst Foundation, wird aber für den Weg dorthin gebraucht; Zugang zum ersten Durchbruch klären.
- Nachbarschaftsboni: Mindestzeiten, Mehrfachnachbarn und Stapelgrenzen; Furnace −1 AP bis 0 gegen „Ausführung kostet AP“ abgleichen.
- Staff bleiben innen vorerst ausgeschlossen. Nur bei konkretem Nutzen neu entscheiden; keine Implementierung allein wegen der Möglichkeit.

## Phase 6 — Ökonomie, Fortschritt und Tagesbalance

### [ ] T26 · Staff-Traits und Zahlen ausarbeiten (D/V)
**Voraussetzung:** T15, T16.
**Quelle:** `gdd_overworld.md` §7.1.1.
- Modell B ist gewählt: sichtbare Skill-/Loyalty-Werte plus ein Trait. Nicht erneut Modelle A/B/C auswählen.
- Trait-Liste, Löhne, Output, Loyalty-Änderung, Kündigung, Abwerbung und Gegenangebote definieren.
- Verdeckte Deception höchstens als spätere geskriptete Story-Idee behandeln, nicht für zufällige Hires.

### [ ] T27 · Favor/Standing und Request-Pools abstimmen (D/V)
**Voraussetzung:** T15, T16, T26.
**Quelle:** `gdd_overworld.md` §7.2.
- Modell Favor + lebenslanges Earned Total/Standing ist gewählt; Zahlen, Request-Größen, Laufzeiten und Schwellen testen.
- Rivalenregel (Allied bei einer Familie begrenzt die andere auf Trusted) bestätigen.
- Eigene Familie: Fortschritt über Stärke/Arena konkret berechnen.
- Standing schaltet Zugang frei, Tabelle nennt Lizenzen/Recruitment/Einladungen zusätzlich als Favor-Ausgabe: Zugangsvoraussetzung und Kaufpreis sauber trennen.
- Request-Pools pro Faktion und Stage, Wiederholungsgrenzen und Belohnungen definieren.

### [ ] T28 · Markt, Properties und Businesses balancieren (D/V)
**Voraussetzung:** T16, T22, T26, T27.
**Quelle:** `gdd_overworld.md` §3.1.5, §7.1, §7.5–§7.8.
- Erst nach den Katalogen: Preisfluktuationsmodell, Basispreise, Kauf/Verkauf und Schutz vor endloser Arbitrage bestimmen.
- Property-Kosten, Lizenzen, Facility-Output, Queue-Dauer, Verkaufsmengen und Staff-Automatisierung mit Dungeon-Erträgen vergleichen.
- Deal umfasst viele Tätigkeiten: eine Tätigkeit pro AP oder mehrere in einem Deal? Gratis Queue gegen sofortige Work-Produktion abgrenzen.
- Monster-Hall-Verkauf, Dojo und Dungeon Company als Datenkonfigurationen konkretisieren.

### [ ] T29 · XP-Kurven und Kultivierungs-Pacing prüfen (V)
**Voraussetzung:** T05, T22, T25, T28.
**Quelle:** `gdd_monsters.md` §7.4; `gdd_overworld.md` §2.4.
- Erste 18-Schritte-XP-Kurve, Pill-XP, Win-XP, Training/Cultivate und Idle-XP prüfen; Spielerwerte ggf. getrennt bestimmen.
- Ziel 3–6 fokussierte Tage je Sub-Tier gegen Farm-/Kauf-/Staff-Einkommen prüfen; nicht anhand alter Prototypzahlen als bestätigt behandeln.

### [ ] T30 · Breakthrough-Trials und Rituale abschließen (D/V)
**Voraussetzung:** T20, T25, T27, T29.
**Quelle:** `gdd_overworld.md` §6.3.1; `gdd_monsters.md` §7.3.
- Ersten Trial-Entwurf mit Prototyp/Spielablauf prüfen; Materialmengen und Pill-Effekt bestätigen.
- „Spieler startet bei halben HP“/„Spieler im Gewinnerteam“ widerspricht der Rolle als nicht kämpfender Tamer: welches Monster/Team ist gemeint?
- Spieler-/Monster-Trials, Wiederholung, Failure-Kosten und Trial-Zugang festlegen; Rarity-Ascension-Zutaten und Beschaffungswege synchronisieren.

### [ ] T31 · Tages-AP und Aktionskosten final abstimmen (D/V)
**Voraussetzung:** T22, T25, T28–T30.
**Quelle:** `gdd_overworld.md` §2.3, §2.6.
- Vorschlag 3/4/4/5/5/6 AP je Stage und Arena-Preis pro Turnierrunde prüfen.
- Expedition, Kultivierung, Story und Arbeit gegeneinander balancieren; staffbedingte Entlastung berücksichtigen.
- Gratis Entscheiden/Queue/Umstellen gegen kostenpflichtiges Ausführen konsistent halten.

## Phase 7 — Spätes Spiel und Abschluss

### [ ] T32 · Major Surges und Signatures gestalten (D)
**Voraussetzung:** T09, T12, T13.
**Quelle:** `gdd_battle.md` §5.4; `gdd_monsters.md` §3.1, §4.2, §4.6, §7.4.
- Konkrete Formen, Fläche und Reichweite bestimmen; halbes Board/2 AP/einmal pro Kampf prüfen.
- Zugang Ancient UND Legendary ab Sovereign gegen teilweise nur „Ancient“ in Tabellen synchronisieren; Signatures anderer Legendary-Kins abgrenzen.

### [x] T33 · Legendary-Aspektwechsel entfällt (D)
**Voraussetzung:** T01, T11, T30.
**Quelle:** `gdd_monsters.md` §7.2.
- Durch T01 gestrichen: Ohne feste Aspekte gibt es keinen Aspektwechsel. Kein Ersatzfeature beschlossen; sonstige Legendary-Entwicklung bleibt Gegenstand der bestehenden Progressionsaufgaben.

### [x] T34 · Dual-Aspekt-System entfällt (D)
**Voraussetzung:** T01, T09, T13.
**Quelle:** `gdd_monsters.md` §7.4; `gdd_overworld.md` §6.3.
- Durch T01 gestrichen: keine Dual-Aspekte und kein entsprechender Immortal-Unlock. Mehrere freie Themen benötigen keine eigene Freischaltung oder Sondermechanik.

### [ ] T35 · GDD-Synchronisierung und Umsetzungsplan aktualisieren (K)
**Voraussetzung:** jeweils die betroffenen Entscheidungen; Gesamtabschluss nach T01–T34.
**Quelle:** alle drei GDDs, besonders technische Notizen und Development Phases.
- Beschlossene Regeln, Vorschläge, vorhandenen Prototyp und spätere Features eindeutig unterscheiden.
- Tabellen, Schemafelder, Abschnittsverweise und Versionsstände synchronisieren. Technischer Validator fordert derzeit Surge/Utility, obwohl offene Kits beides nicht vorschreiben; Species-Passive vs. slotgebundene Lernliste abgleichen.
- Entwicklungsphasen anhand der geklärten Abhängigkeiten aktualisieren; Implementierungsaufgaben nicht mit offenen Designentscheidungen vermischen.
- Historische Changelogs nicht nachträglich als aktuelle Spezifikation umschreiben.

## Abhängigkeitsübersicht

```mermaid
flowchart TD
    A[T01 Aspekte] --> B[T02 Blueprints und Kosten]
    B --> C[T03 Stats und T04 Auflösung]
    C --> D[T05 bis T11 Skills und Referenzroster]
    D --> E[T12 Launch-Roster und T13 Kampftests]
    A --> F[T16 Item- und Rezeptkataloge]
    D --> F
    F --> G[T17 bis T20 Ausrüstung und Loadout]
    E --> H[T21 bis T25 Expedition und Sammlung]
    G --> H
    I[T15 Stadtmächte] --> J[T26 bis T28 Staff Favor und Markt]
    F --> J
    H --> J
    J --> K[T29 XP und T30 Trials]
    K --> L[T31 Tages-AP]
    E --> M[T32 bis T34 Spätspiel]
    L --> N[T35 GDD-Abgleich]
    M --> N
```

Die Detailvoraussetzungen je Punkt sind maßgeblich; das Diagramm fasst nur die großen Arbeitsstränge zusammen.
