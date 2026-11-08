# Spanish (esES / esMX) progress - LOC-2

Keys are the English text; an untranslated key shows in English (Core/Locale.lua).
Check with the harness described in the phase report; counts are keys registered
in Locale/esES/*.lua against ~1,500 distinct strings estimated in the code.

| Phase | Scope | State |
|-------|-------|-------|
| 0 | ns.L / ns.LF / ns.LDate, TOC titles, bindings, dedupe of /sd help and key labels | done |
| 1 | Settings (10 sections), /sd, tour and parcel, hints, confirmations, entry page, minimap, ribbons, toast static words, Format static | done: 245 keys (Settings 135, Slash 60, Chrome 31, Intro 30, Toast 15, Words 13, Hints 6) |
| 2 | Grammar, prose, time, timeline, dungeon, person | done |
| 3 | Features, Journey, Journal, Dungeon, Blizzard, Paper, Map | done: see the report for what stays English |
| 4 | Dungeon/wing names (Locale/esES/Dungeons.lua), QuestFinales (live client title), capitals by name+map, race/class fallbacks | done; boss names empty |
| 5 | Stored-vs-live comparisons | reviewed: Sightings.SamePlace already uses mapID; Instances loot uses encounter id; Questie guard OK |
| 6 | In-game QA | partly run: text generation from places, actions and dungeons checked in the client; rest of QA-esES.md pending |
| 7 | CHANGELOG, README | done |

Terms: diary = diario, toast = aviso, sightings = avistamientos, foe = enemigo, hints = pistas.
