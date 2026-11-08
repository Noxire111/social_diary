-- The sheet's labels and tooltips in Your Diary (ns.UI.JourneyText): a
-- meeting mark's, a stop's (its kind, its label, its tooltip), a pin's, a
-- dungeon's, a flight's, a first sighting's, a face's on the rubric and an
-- ink pool's. No key on the plates: these say what each mark means.
--
-- The module and its siblings: UI/Journey/Text/Grammar.lua.

local addonName, ns = ...

local Format = ns.UI.Format

local Text = ns.UI.JourneyText
local List = Format.List
-- Tooltips and single lines keep the plain formatter; what wraps (the
-- prose, captions, margin notes) holds its times together (Text.Duration,
-- UI/Journey/Text/Time.lua).
local Plain = Format.Duration
local MapName, Who, Written, When = Text.MapName, Text.Who, Text.Written, Text.When
local Times, PEOPLE = Text.Times, Text.PEOPLE

--------------------------------------------------------------------------
-- The sheet's tooltips (JRN-14)
--------------------------------------------------------------------------

-- A stop's deed for its tooltip on the plates ("35 min, mostly fighting").
local ACTIVITY = { fighting = ns.L("mostly fighting"), questing = ns.L("questing"), resting = ns.L("resting") }

-- A meeting mark's tooltip: a title and lines. Who, when, at what level.
function Text.Meeting(m, now, index)
    if m.kind == "session" then
        local names = {}
        for guid in pairs(m.session.participants or {}) do names[#names + 1] = Who(guid) or ns.L("someone") end
        table.sort(names)
        local s = m.session
        local seconds = ns.Sessions.Duration(s)
        return ns.LF("With %s", List(names, PEOPLE) or ns.L("someone")), {
            ns.LF("Together for %s", Plain(seconds)),
            When(s.startedAt, m.level, now),
        }
    elseif m.kind == "fight" then
        local text = Text.Fight(m.mark, index)
        return ns.UpperFirst(text), { When(m.t, m.level, now) }
    elseif m.kind == "note" then
        local about = {}
        for guid in pairs(m.note.about or {}) do about[#about + 1] = Who(guid) or ns.L("someone") end
        table.sort(about)
        local lines = { Written(m.note.text) }
        if #about > 0 then lines[#lines + 1] = ns.LF("About %s", List(about)) end
        lines[#lines + 1] = When(m.t, m.level, now)
        return ns.L("Your note"), lines
    end
    return "", {}
end

-- What kind of place a stop was, for the sheet's activity areas:
-- "fighting", "questing", "resting", or nil for a place you only stayed.
-- The recap's main activity, and a quest taken or handed in on a short
-- stop (a quest giver passed on the way) counts as questing too.
function Text.StopKind(seg)
    local main = ns.JourneyRecap.MainActivity(seg)
    if main then return main end
    local act = seg.act
    if act and (act.questsIn or 0) + (act.questsOut or 0) > 0 then return "questing" end
    return nil
end

local SHORT = { fighting = ns.L("fighting"), questing = ns.L("questing"), resting = ns.L("resting") }

-- How long a stop lasted, in words: a quest giver passed on the way is
-- "under a minute", not "0 min".
local function StopTime(seconds)
    return seconds >= 60 and Plain(seconds) or nil
end

-- A stop's label on the sheet: "Red Cloud Mesa · 6 min", or what was done
-- there where the place has no name ("fighting · 2 min"), the time left
-- off under a minute; nil with neither name nor deed.
function Text.StopLabel(seg, seconds)
    local kind = Text.StopKind(seg)
    local name = seg.subZone or (kind and SHORT[kind])
    if not name then return nil end
    local time = StopTime(seconds or seg.seconds or (seg.to - seg.from))
    return time and (name .. " \194\183 " .. time) or name
end

-- A stop's tooltip: where, how long and what was done there, in plain
-- words, then when and at what level. `more` is how many short stays
-- close by the sheet drew as this one.
function Text.Stop(seg, now, more)
    local kind = Text.StopKind(seg)
    local lead = StopTime(seg.seconds or (seg.to - seg.from)) or ns.L("Under a minute")
    local lines = { kind and ns.LF("%s, %s", lead, ACTIVITY[kind]) or lead }
    local act = seg.act or {}
    local combat = act.combat or 0
    if combat >= 60 then
        lines[#lines + 1] = ns.LF("Fought here for %s", Plain(combat))
    elseif combat > 0 then
        lines[#lines + 1] = ns.L("Fought here")
    end
    local took, gave = act.questsIn or 0, act.questsOut or 0
    if took > 0 then lines[#lines + 1] = took == 1 and ns.L("Took a quest") or ns.LF("Took %d quests", took) end
    if gave > 0 then
        lines[#lines + 1] = gave == 1 and ns.L("Handed in a quest") or ns.LF("Handed in %d quests", gave)
    end
    local deaths = act.deaths or 0
    if deaths > 0 then lines[#lines + 1] = Times(deaths, ns.L("Died here"), ns.L("Died here %s")) end
    local levels = seg.levelFrom ~= seg.levelTo and ns.LF("Levels %d to %d", seg.levelFrom or 0, seg.levelTo or 0)
        or (seg.levelFrom and ns.LF("Level %s", seg.levelFrom))
    lines[#lines + 1] = When(seg.from, nil, now) .. (levels and (" \194\183 " .. levels) or "")
    if more and more > 0 then
        lines[#lines + 1] = more == 1 and ns.L("And one more short stay close by")
            or ns.LF("And %d more short stays close by", more)
    end
    return seg.subZone or MapName(seg.mapID) or ns.L("A stop"), lines
end

function Text.Pin(pin, now)
    return ns.LF("Level %d", pin.level), { ns.LF("Reached %s", Format.At(pin.at, now)) }
end

function Text.Dungeon(seg, now)
    return seg.name or ns.L("An instance"), {
        ns.LF("%s inside", Plain(seg.seconds or 0)),
        When(seg.from, seg.levelFrom, now),
    }
end

function Text.Flight(seg, mapID, now)
    local other = seg.mapID1 == mapID and seg.mapID2 or seg.mapID1
    local name = MapName(other)
    local title
    if seg.mapID1 == seg.mapID2 then title = ns.L("A flight")
    else title = ns.LF(seg.mapID1 == mapID and "Flew to %s" or "Flew in from %s", name or "") end
    return title, { When(seg.from, seg.levelFrom, now) }
end

-- The hollow lozenge's tooltip: "First seen: Koko Skybluff", "Sunday, 4
-- October, at level 1".
function Text.FirstSeen(f, now)
    now = now or ns.Now()
    return ns.LF("First seen: %s", Who(f.guid) or ns.L("someone")), {
        Format.DayLabel(f.t, now) .. (f.level and ns.LF(", at level %s", f.level) or ""),
    }
end

-- A face on a level's rubric: "Koko Skybluff · 20 min together".
function Text.Face(face, e)
    local name = Who(face.guid) or ns.L("someone")
    for _, person in ipairs(e.people or {}) do
        if person.guid == face.guid and person.seconds >= 60 then
            return name .. "  \194\183  " .. ns.LF("%s together", Plain(person.seconds))
        end
    end
    for _, f in ipairs(e.hindsight or {}) do
        if f.guid == face.guid then return name .. "  \194\183  " .. ns.L("first seen") end
    end
    for _, mark in ipairs(e.fights or {}) do
        if mark.guid == face.guid then
            return name .. "  \194\183  " .. (mark.outcome == "lost" and ns.L("killed you") or ns.L("a fight, won"))
        end
    end
    return name
end

-- A pool's tooltip: its ink's meaning and time (no key on the plates).
local POOL = { fighting = ns.L("Fought here"), questing = ns.L("Quested here"), resting = ns.L("Rested here") }

function Text.Pool(seg)
    local kind = Text.StopKind(seg)
    local seconds = seg.seconds or (seg.to - seg.from)
    return ns.LF("%s, %s", POOL[kind] or ns.L("Stayed here"), seconds >= 60 and Plain(seconds) or ns.L("under a minute"))
end
