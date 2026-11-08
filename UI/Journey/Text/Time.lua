-- How Your Diary writes a time (ns.UI.JourneyText): a duration held
-- together (Duration), a zone's time in the ledger (LedgerTime), a time as
-- one speaks it (Spoken), a day ("6 October") and a tooltip's last line
-- (When).
--
-- The module and its siblings: UI/Journey/Text/Grammar.lua.

local addonName, ns = ...

local Format = ns.UI.Format

local Text = ns.UI.JourneyText
local Glue = Text.Glue

local function Duration(seconds)
    return Glue(Format.Duration(seconds))
end
Text.Duration = Duration

-- A zone's time in the ledger under an entry, short as a column of
-- figures: "1 h 33", "2 h", "52 min".
function Text.LedgerTime(seconds)
    local minutes = math.floor((seconds or 0) / 60)
    if minutes < 60 then return Glue(minutes .. " min") end
    local h, m = math.floor(minutes / 60), minutes % 60
    if m == 0 then return Glue(h .. " h") end
    return Glue(("%d h %02d"):format(h, m))
end

-- A time as the diary says it in a sentence, rounded the way one speaks:
-- "a few minutes", "twenty minutes", "half an hour", "an hour and a half",
-- "three hours". The prose is not a ledger; the zone rows carry the
-- exact times.
local WORDS = { [2] = ns.L("two"), [3] = ns.L("three"), [4] = ns.L("four"), [5] = ns.L("five"), [6] = ns.L("six"),
    [7] = ns.L("seven"), [8] = ns.L("eight"), [9] = ns.L("nine"), [10] = ns.L("ten"), [11] = ns.L("eleven"),
    [12] = ns.L("twelve"), [15] = ns.L("fifteen"), [20] = ns.L("twenty"), [25] = ns.L("twenty-five"),
    [40] = ns.L("forty"), [45] = ns.L("forty-five"), [50] = ns.L("fifty"), [55] = ns.L("fifty-five") }

local function Spoken(seconds)
    local m = (seconds or 0) / 60
    if m < 1 then return ns.L("a moment") end
    if m < 8 then return ns.L("a few minutes") end
    if m < 25 or (m >= 38 and m < 53) then
        local n = 5 * math.floor(m / 5 + 0.5)
        return WORDS[n] and ns.LF("%s minutes", WORDS[n]) or Glue(ns.LF("%s minutes", n))
    end
    if m < 38 then return ns.L("half an hour") end
    if m < 75 then return ns.L("an hour") end
    if m < 105 then return ns.L("an hour and a half") end
    local halves = math.floor(m / 30 + 0.5)
    local whole = math.floor(halves / 2)
    local name = WORDS[whole] or Glue(tostring(whole))
    return ns.LF(halves % 2 == 1 and "%s and a half hours" or "%s hours", name)
end
Text.Spoken = Spoken

-- "6 October", with the year once it is not this one's.
local function Day(t, now)
    return Format.DayMonth(t, now or ns.Now())
end

local function When(t, level, now)
    local text = Format.At(t, now)
    text = ns.UpperFirst(text)
    if level then text = ns.LF("%s, at level %s", text, level) end
    return text
end

Text.Day, Text.When, Text.WORDS = Day, When, WORDS

-- A sitting's label under its level (.claude/sittings-plan.md): "Oct 25th",
-- and when another sitting began that day the part of it, "Oct 25th,
-- Evening" (two alike are fine: "Noon" and "Noon"). The year once it is
-- not this one's. `p` a recap piece: its `at`, `many`. A night past
-- midnight is the day before's (Recap.SittingDay), and its part "Night".
local PARTS = {
    { 5, ns.L("Morning") }, { 11, ns.L("Noon") }, { 14, ns.L("Afternoon") }, { 18, ns.L("Evening") }, { 22, ns.L("Night") },
}

local function Ordinal(n)
    if ns.Locale.Active() then return tostring(n) end   -- Spanish dates are cardinal: "25 oct"
    local tail = n % 100
    if tail >= 11 and tail <= 13 then return n .. "th" end
    local last = n % 10
    return n .. (last == 1 and "st" or last == 2 and "nd" or last == 3 and "rd" or "th")
end

local function Part(t)
    local hour = date("*t", t).hour
    local name = ns.L("Night")
    for _, part in ipairs(PARTS) do
        if hour >= part[1] then name = part[2] end
    end
    return name
end
Text.DayPart = Part

function Text.SittingLabel(p, now)
    local t = p.at or p.from
    local day = ns.JourneyRecap.SittingDay(t) + 12 * 3600
    local month, number = ns.LDate("%b", day), Ordinal(tonumber(date("%d", day)))
    local text = ns.Locale.Active() and (number .. " " .. month) or (month .. " " .. number)
    if date("%Y", day) ~= date("%Y", now or ns.Now()) then text = text .. " " .. date("%Y", day) end
    text = Glue(text)
    if p.many then text = text .. ", " .. (ns.Locale.Active() and Part(t):lower() or Part(t)) end
    return text
end
