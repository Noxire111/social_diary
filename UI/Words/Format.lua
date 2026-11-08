-- The text helpers, ns.UI.Format: durations, days, lists, counts, money,
-- and characters in words. Callers that write often keep the table (or the
-- functions they use) in a local, taken at load; Core loads before the UI,
-- so it reads ns.UI.Format when it writes. Its siblings: the chrome
-- (ns.UI.Chrome, UI/Kit/Chrome.lua), the virtual list (UI/Kit/List.lua).

local addonName, ns = ...

local Format = {}
ns.UI.Format = Format

--------------------------------------------------------------------------
-- Formatting
--------------------------------------------------------------------------

function Format.Duration(seconds)
    local minutes = math.floor((seconds or 0) / 60)
    if minutes < 60 then return minutes .. " min" end
    local hours = math.floor(minutes / 60)
    minutes = minutes % 60
    if minutes == 0 then return hours .. " h" end
    return ("%d h %d min"):format(hours, minutes)
end

-- DAT-4: stored as server epoch, shown relative or in local time.
function Format.Ago(time, now)
    if not time then return ns.L("never") end
    now = now or ns.Now()
    local days = math.floor((now - time) / ns.DAY)
    if days < 1 then return ns.L("today") end
    if days < 2 then return ns.L("yesterday") end
    if days < 14 then return ns.LF("%d days ago", days) end
    if days < 60 then return ns.LF("%d weeks ago", math.floor(days / 7)) end
    return ns.LDate("%d %b %Y", time)
end

-- "1 time", "3 times".
function Format.Count(n, one, many)
    return n .. " " .. ns.L(n == 1 and one or many)
end

-- "Mulgore", "Mulgore and Durotar", "Mulgore, Durotar and The Barrens".
--
-- `opts` (all optional):
--   max      past this many names, only `shown` of them and a count of the
--            rest: "Mulgore, Durotar and 2 more"
--   shown    how many to name then (default `max`)
--   more     the word for the rest (default "more"; "others" for people)
--   oxford   a comma before the last "and" once there are three or more,
--            for lists of clauses rather than names
--
-- nil for an empty list.
function Format.List(names, opts)
    local n = #names
    if n == 0 then return nil end
    opts = opts or {}

    if opts.max and n > opts.max then
        local shown = opts.shown or opts.max
        return ns.LF("%s and %d %s", table.concat(names, ", ", 1, shown), n - shown, ns.L(opts.more or "more"))
    end

    if n == 1 then return names[1] end
    -- Spanish: "y", which becomes "e" before an i- or hi- sound, and no
    -- comma before it (the Oxford comma is English's).
    local join = ns.L(" and ")
    if ns.Locale.Active() then
        local following = names[n]:lower():gsub("^[^%a\195]+", "")
        join = (following:find("^h?i") and not following:find("^hie") or following:find("^\195\173")) and " e " or " y "
    end
    if n == 2 then return names[1] .. join .. names[2] end
    return table.concat(names, ", ", 1, n - 1) .. ((opts.oxford and not ns.Locale.Active()) and ", and " or join) .. names[n]
end

--------------------------------------------------------------------------
-- Days
--------------------------------------------------------------------------
--
-- Calendar days in local time, not 24-hour blocks: 23:50 last night is
-- "yesterday", not "today".

-- 0 when `time` falls on `now`'s day, 1 on the day before, nil otherwise.
local function DaysBack(time, now)  -- also Format.DayBack, for words that tell today and yesterday apart  -- also Format.DayBack, for words that tell today and yesterday apart
    local day = date("%Y-%m-%d", time)
    if day == date("%Y-%m-%d", now) then return 0 end
    if day == date("%Y-%m-%d", now - ns.DAY) then return 1 end
    return nil
end

-- "6 October". Given `now`, the year too once it is not now's: "6 October
-- 2025". Without it, never -- for a page that only reaches back as far as
-- the buffer does.
function Format.DayMonth(time, now)
    local text = ns.L("%d %s", "Words"):format(tonumber(date("%d", time)), ns.LDate("%B", time))
    if now and date("%Y", time) ~= date("%Y", now) then
        text = ns.L("%s %s", "Words"):format(text, date("%Y", time))
    end
    return text
end

-- A heading for the day `time` falls on: "Today", "Yesterday", else
-- "Monday, 6 October" (with the year once it is not now's).
function Format.DayLabel(time, now)
    now = now or ns.Now()
    local back = DaysBack(time, now)
    if back == 0 then return ns.L("Today") end
    if back == 1 then return ns.L("Yesterday") end
    return ns.UpperFirst(ns.LDate("%A, ", time)) .. Format.DayMonth(time, now)
end

-- "today at 21:43", "yesterday at 18:02", "on 12 Sep at 18:02"; the year is
-- added once it is not this one.
function Format.At(time, now)
    now = now or ns.Now()
    local clock = date("%H:%M", time)
    local back = DaysBack(time, now)

    if back == 0 then return ns.LF("today at %s", clock) end
    if back == 1 then return ns.LF("yesterday at %s", clock) end
    if date("%Y", time) == date("%Y", now) then
        return ns.LF("on %s at %s", ns.LDate("%d %b", time), clock)
    end
    return ns.LF("on %s at %s", ns.LDate("%d %b %Y", time), clock)
end

-- The profile's "last seen" line, from a character record's `seen`.
function Format.SeenText(seen, now)
    if not seen then return ns.L("Not seen nearby yet.") end

    -- Subzone first, as every place is written: "Goldshire, Elwynn Forest".
    local place = seen.zone
    if place and seen.subZone and seen.subZone ~= seen.zone then
        place = seen.subZone .. ", " .. place
    end

    if place then return ns.LF("Last seen %s in %s", Format.At(seen.time, now), place) end
    return ns.LF("Last seen %s", Format.At(seen.time, now))
end

-- "once", "twice", "5 times".
function Format.Times(n)
    if n == 1 then return ns.L("once") end
    if n == 2 then return ns.L("twice") end
    return ns.LF("%d times", n)
end

-- The score with a foe, from Interactions.Fights: "You've killed them twice and
-- they've killed you 5 times." A kill by the group counts, and the sentence
-- says whose it was: "Your group has killed them once", "You and your group
-- have killed them 3 times". `em` marks the numbers, if given. `short`,
-- for the reunion card's two lines: "You've killed them 3 times, they've
-- killed you twice", every kill counted as yours. nil for no fights.
function Format.FightsText(fights, em, short)
    if not fights then return nil end
    em = em or tostring
    local kills
    if fights.kills > 0 then
        local template = (short or fights.yours == fights.kills) and "You've killed them %s"
            or fights.yours == 0 and "Your group has killed them %s" or "You and your group have killed them %s"
        kills = ns.LF(template, em(Format.Times(fights.kills)))
    end
    local deaths = fights.deaths > 0 and em(Format.Times(fights.deaths)) or nil

    if kills and deaths then
        return ns.LF(short and "%s, they've killed you %s." or "%s and they've killed you %s.", kills, deaths)
    end
    if kills then return ns.LF("%s.", kills) end
    if deaths then return ns.LF("They've killed you %s.", deaths) end
    return nil
end

function Format.Money(copper)
    copper = copper or 0
    local gold = math.floor(copper / 10000)
    local silver = math.floor(copper / 100) % 100
    local rest = copper % 100

    local parts = {}
    if gold > 0 then parts[#parts + 1] = gold .. ns.L("g", "Words") end
    if silver > 0 then parts[#parts + 1] = silver .. ns.L("s", "Words") end
    if rest > 0 or #parts == 0 then parts[#parts + 1] = rest .. ns.L("c", "Words") end
    return table.concat(parts, " ")
end

function Format.ClassColor(guid)
    local record = ns.Characters.Get(guid)
    local token = record and record.class
    local color = token and RAID_CLASS_COLORS and RAID_CLASS_COLORS[token]
    if not color then return "|cffffffff" end
    return ("|cff%02x%02x%02x"):format(color.r * 255, color.g * 255, color.b * 255)
end

--------------------------------------------------------------------------
-- Characters in words
--------------------------------------------------------------------------
--
-- The colours are the Style files', which load after this one: ns.Style is
-- read when a line is written, never at load.

-- The user in a record's words. A record one of the user's characters
-- wrote keeps who (`me`, `addedBy`, a death's `guid`); in a shared diary
-- another character's "you" is not the one playing, so it is named. Write
-- the sentence as it reads for the one playing, each "you" word in braces:
--
--   You(row.me, "{You} killed Bram")        "You killed Bram", "Thrall killed Bram"
--   You(row.me, "Bram saved {you}")         "Bram saved you", "Bram saved Thrall"
--   You(row.me, "{Your} group killed Bram") "Your group ...", "Thrall's group ..."
--   You(row.me, "{You've} met twice")       "You've met ...", "Thrall has met ..."
--
-- "You" stays for the character playing, a diary of its own, a record from
-- before characters were kept apart (no `me`), and a character without a
-- name. Totals over every character (the score with someone, times met)
-- are the player's and keep a plain "you".

-- Each brace word for another character, its name in place of %s.
local YOU_FOR = {
    ["you"] = "%s", ["your"] = "%s's", ["yours"] = "%s's",
    ["you've"] = "%s has", ["you're"] = "%s is", ["you were"] = "%s was",
}

-- Whether `me` is "you": the character playing, or as good as.
Format.DayBack = DaysBack

Format.DayBack = DaysBack

function Format.IsYou(me)
    return not ns.diaryShared or me == nil or me == ns.ownGUID or Format.YouName(me) == nil
end

-- The first name of the user's character `me`, or nil.
function Format.YouName(me)
    local own = me and ns.OwnCharacters()[me]
    return own and own.first or (me and ns.Characters.Name(me)) or nil
end

-- `text` is looked up in the language first, so a caller passes the English
-- sentence and a translation brings its own braces. Spanish conjugates, so
-- its braces hold both forms, "{Mataste|$n mató} a Bram": the first for the
-- character playing, the second for another ($n their name).
function Format.You(me, text)
    text = ns.L(text)
    if Format.IsYou(me) then
        return (text:gsub("{(.-)}", function(word) return (word:match("^(.-)|") or word) end))
    end
    local name = Format.YouName(me)
    return (text:gsub("{(.-)}", function(word)
        local other = word:match("|(.*)$")
        if other then return (other:gsub("%$n", function() return name end)) end
        local form = YOU_FOR[word:lower()]
        return form and form:format(name) or word
    end))
end

-- You(me, template) with the template's %s/%d filled in after the language
-- and the braces have been settled, so a translation may reorder nothing but
-- may carry its own braces.
function Format.YouF(me, template, ...)
    return Format.You(me, template):format(...)
end

local RACE_NAMES = { Scourge = ns.L("Undead"), NightElf = ns.L("Night Elf") }

function Format.RaceName(record)
    if record.raceID and C_CreatureInfo and C_CreatureInfo.GetRaceInfo then
        local info = C_CreatureInfo.GetRaceInfo(record.raceID)
        if info and type(info.raceName) == "string" then return info.raceName end
    end
    return record.race and (RACE_NAMES[record.race] or ns.L(record.race, "Words"))
end

function Format.ClassName(record)
    local token = record.class
    if not token then return nil end
    local names = record.sex == 3 and LOCALIZED_CLASS_NAMES_FEMALE or LOCALIZED_CLASS_NAMES_MALE
    if names and names[token] then return names[token] end
    return ns.L(token:sub(1, 1) .. token:sub(2):lower(), "Words")
end

-- "Level 6 Tauren Druid  ·  Horde  <Guild>", inked for the page. With
-- dropOwn the faction goes when it is the player's own, as it nearly
-- always is out in the world; with "always" it goes whoever's it is (the
-- person's page: the portrait and the book say enough).
function Format.WhoLine(record, guild, dropOwn)
    record = record or {}
    local parts = {}
    if record.level then parts[#parts + 1] = ns.LF("Level %s", record.level) end
    parts[#parts + 1] = Format.RaceName(record)
    parts[#parts + 1] = Format.ClassName(record)

    local text = table.concat(parts, " ")
    local own = dropOwn == "always" or (dropOwn and record.faction == UnitFactionGroup("player"))
    if not own and (record.faction == "Horde" or record.faction == "Alliance") then
        local hex = record.faction == "Horde" and ns.Style.HEX.horde or ns.Style.HEX.alliance
        text = text .. (text ~= "" and "  ·  " or "") .. "|cff" .. hex .. ns.L(record.faction) .. "|r"
    end

    if guild then text = text .. "  |cff" .. ns.Style.HEX.faded .. "<" .. guild .. ">|r" end
    return text
end
