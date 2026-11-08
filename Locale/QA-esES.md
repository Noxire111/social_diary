# In-game QA checklist, esES / esMX (Phase 6)

Partly run in a client. Checked so far: text generation from places and actions,
including dungeons (the maintainer's test). The rest of this list is still to be walked through. Switch the
client to esES, `/reload`, and look for Lua errors (an `ns.L` of a missing key
shows English, it never errors) and for text that overflows.

- [ ] `/sd`, `/sd help`, add, remove, forget, list, settings, about, debug, sightings recent|of|city
- [ ] Introduction: parcel ("Rómpelo", "Luego"), the five tour steps, the example person
- [ ] Settings: the 10 sections, and each destructive confirmation (Memory)
- [x] Text generation from places and actions, including dungeons (checked in the client)
- [ ] Hints on Your Diary, People, the timeline, a dungeon page
- [ ] Reunion toast (group, nearby, foe/avoid), duels, firsts, deaths, professions, close calls
- [ ] Key bindings menu header and names; the two macros ("Open Social Diary" keeps its macro name)
- [ ] Minimap tooltip, player tooltip lines
- [ ] Questie installed with an esES client: creature names, quest drops
- [ ] Layout: HintSlip (200 px, body wraps, title is one line), KEY_LABEL_W 160, COMMAND_W 150, buttons,
      toast heading/name (UPPER-CASE headings are the longest), settings nav `about` lines (no wrap)
- [ ] Accents: ns.Upper on headings (á→Á, ñ→Ñ); a capital initial in the medallion
- [ ] Dates: weekday/month names, "6 de octubre", sittings "25 oct, tarde"
- [ ] Bosses not yet killed show in English (the boss table is empty on purpose)
