-- A dungeon run's page in Your Diary's words (ns.UI.JourneyText): the
-- keepsake page (.claude/ui-proposal/super-plate.md, B, round 5, 28 Oct;
-- UI/Journey/Run.lua). The user's own wording, taken as written: no
-- /copywriter pass (their decision, 28 Oct).
--
-- The module and its siblings: UI/Journey/Text/Grammar.lua.

local addonName, ns = ...

local Text = ns.UI.JourneyText

-- Numbers a person says in words, up to twenty; past that, figures.
local SAID = {}
for i, word in ipairs({ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve",
    "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen", "twenty" }) do
    SAID[i] = ns.L(word)
end
local function Said(n)
    return SAID[n] or tostring(n)
end
Text.RunSaid = Said

-- How long, in hours and minutes: "35 minutes", "1 hour 52 minutes",
-- "2 hours"; under a minute, "a minute".
function Text.RunDuration(seconds)
    local minutes = math.floor((seconds or 0) / 60 + 0.5)
    if minutes < 1 then return ns.L("a minute") end
    local h, m = math.floor(minutes / 60), minutes % 60
    local parts = {}
    if h > 0 then parts[#parts + 1] = h == 1 and ns.L("1 hour") or ns.LF("%d hours", h) end
    if m > 0 then parts[#parts + 1] = m == 1 and ns.L("1 minute") or ns.LF("%d minutes", m) end
    return table.concat(parts, " ")
end

-- The subtitle: the level span and the time inside, no date (the user):
-- "Level 22–23, 1 hour 52 minutes", or "Level 22, 35 minutes".
function Text.RunSubtitle(from, to, seconds)
    local time = Text.RunDuration(seconds)
    if not from then return time end
    if to and to > from then return ns.LF("Level %d\226\128\147%d, %s", from, to, time) end
    return ns.LF("Level %d, %s", from, time)
end

-- The boss strip: "4 out of 7 bosses slain", or "Full run" (underlined by
-- the page in ink, never by the font).
function Text.RunBosses(k, m, full)
    if full then return ns.L("Full run") end
    return ns.LF("%d out of %d bosses slain", k or 0, m or 0)
end

-- The slip pinned to the last keepsake: "and eleven more".
function Text.RunMore(n)
    return ns.LF("and %s more", Said(n))
end

-- Whose a keepsake is: "yours at last", "yours", "Brom's" ("Atlas'").
function Text.RunWhose(item, name)
    if item.mine then return item.atLast and ns.L("yours at last") or ns.L("yours") end
    if not name or name == "" then return ns.L("someone's") end
    if ns.Locale.Active() then return ns.LF("%s's", name) end   -- "de Koko"
    return name:find("s$") and (name .. "'") or (name .. "'s")
end

-- The fallen note's first line: "we fell once", "we fell twice", "we fell
-- six times".
function Text.RunFell(n)
    if n == 1 then return ns.L("we fell once") end
    if n == 2 then return ns.L("we fell twice") end
    return ns.LF("we fell %s times", Said(n))
end

-- One of the fallen with how often: "you", "you twice", "Brom thrice",
-- "Zuri four times".
function Text.RunFallenOne(name, times)
    if times == 1 then return name end
    if times == 2 then return ns.LF("%s twice", name) end
    if times == 3 then return ns.LF("%s thrice", name) end
    return ns.LF("%s %s times", name, Said(times))
end

-- Everyone who fell, as many as `fits(words)` lets in, the rest counted:
-- "you twice, Brom twice, Zuri, Grimble", "…, and three others". `names`
-- is each one's words (RunFallenOne). Returns the words.
function Text.RunFallen(names, fits)
    for take = #names, 1, -1 do
        local rest = #names - take
        local words = table.concat(names, ", ", 1, take)
        if rest > 0 then words = words .. ns.LF(rest > 1 and ", and %s others" or ", and %s other", Said(rest)) end
        if take == 1 or not fits or fits(words) then return words end
    end
    return ""
end

-- A death in the fallen note's tooltip: "Grimble died to Overlord Ramtusk".
function Text.RunDiedTo(name, killer)
    if killer and killer ~= "" then return ns.LF("%s died to %s", name, killer) end
    return ns.LF("%s died", name)
end

-- After the names: members a run saved no name for, "and one you didn't
-- keep"; and who has no room on this turn of the list, "and 34 others".
function Text.RunStrangers(n)
    return ns.LF("and %s you didn't keep", Said(n))
end
function Text.RunOthers(n)
    return ns.LF(n == 1 and "and %d other" or "and %d others", n)
end

Text.RUN = {
    nobody = ns.L("Nobody fell."),
    nothing = ns.L("No noteworthy drops."),
    you = ns.L("you"),
    someone = ns.L("someone"),
    open = ns.L("Click to open its map."),
    sheet = ns.L("Click to open its sheet."),
    add = ns.L("+ Add"),
}

-- The title's tooltip, TLN-12's line: "Razorfen Kraul, 35 min, 4 of 6
-- bosses, 6 deaths, with Brom, Kaelith and Zuri".
function Text.RunTip(visit, seconds, k, m, deaths, names)
    local parts = { visit.name or ns.L("A dungeon"), ns.UI.Format.Duration(seconds) }
    if m then parts[#parts + 1] = ns.LF("%d of %d bosses", k, m) end
    if deaths > 0 then parts[#parts + 1] = deaths == 1 and ns.L("1 death") or ns.LF("%d deaths", deaths) end
    local line = table.concat(parts, ", ")
    local with = ns.UI.Format.List(names or {}, { max = 4, shown = 3, more = "others" })
    if with then line = ns.LF("%s, with %s", line, with) end
    return line
end
