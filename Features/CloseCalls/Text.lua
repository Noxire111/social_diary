-- Close calls' words (JRN-25): a close call in the level's prose
-- (Text.RegisterLines, UI/Journey/Text/Prose.lua), the plates' caption words
-- (Text.RegisterCaption), the cross's tooltip (Mark.lua) and the card's:
-- its heading, its tag, its deed and its tooltip (Card.lua's SetFoe). A
-- creature's name in a sentence ("a Plainstrider", "Hogger") is the
-- core's Text.KillerName, the health left held together ("6% health")
-- its Text.Health. Copy changes go through the copywriter skill, as every
-- player-read word does.

local addonName, ns = ...

local CloseCalls = ns.CloseCalls
local Text = ns.UI.JourneyText
local Capital, Health, NUMBER, When = Text.Capital, Text.Health, Text.NUMBER, Text.When

-- A close call's creature in a sentence: "a Plainstrider", "Hogger", "a
-- Plainstrider and two others" (it was one of `foes` targeted); nil when
-- no creature was.
local function Foes(call)
    local name = Text.KillerName(call)
    if not name then return nil end
    local more = (call.foes or 1) - 1
    if more == 1 then return ns.LF("%s and another", name) end
    if more > 1 then return ns.LF("%s and %s others", name, NUMBER[more] or tostring(more)) end
    return name
end

-- A close call in a sentence: "Got away from a Plainstrider with 6%
-- health.", or, no creature targeted, "Got out of a fight with 6%
-- health."
function CloseCalls.Sentence(call)
    local foes = Foes(call)
    return foes and ns.LF("Got away from %s with %s.", foes, Health(call)) or ns.LF("Got out of a fight with %s.", Health(call))
end

-- A close call's creature's level and rank, as its card's tag says them
-- (Card.lua's SetFoe): "Lv 45 (Elite)", "Lv ?? (Boss)" (a skull, -1),
-- "Lv 12" for a common creature, the rank alone where no level was kept
-- ("Elite"); nil with neither. The fight's length is never told: it said
-- nothing (11 Oct).
local TAG = { elite = ns.L("Elite"), rare = ns.L("Rare"), rareelite = ns.L("Rare Elite"), worldboss = ns.L("Boss") }

function CloseCalls.Tag(call)
    local level = call and call.foeLevel
    local lv = level == -1 and ns.L("Lv ??") or (type(level) == "number" and level > 0 and ns.LF("Lv %s", level)) or nil
    local rank = call and TAG[call.rank]
    if lv and rank then return lv .. " (" .. rank .. ")" end
    return lv or rank
end

-- What a close call is called on the page: its card's heading in the
-- diary's hand (Card.lua's SetFoe), and its cross's tooltip's title, so
-- the card and the mark it points to read as one thing.
function CloseCalls.Heading()
    return ns.L("A close call")
end

-- A close call's cross on a plate, for its tooltip: "A close call", then
-- what with, its level and rank, when.
function CloseCalls.Tip(call, now)
    local foes = Foes(call)
    local lines = { foes and ns.LF("%s%% health left, against %s", call.pct or 0, foes) or ns.LF("%s%% health left", call.pct or 0) }
    if foes then lines[#lines + 1] = CloseCalls.Tag(call) end
    lines[#lines + 1] = When(call.t, call.level, now)
    return CloseCalls.Heading(), lines
end

-- The card of the creature that nearly got you (Card.lua's SetFoe):
-- under its chart, how many it was against, "fought against three"; ""
-- against one ("fought" alone says nothing). And its tooltip.
function CloseCalls.Deed(call)
    local foes = call.foes or 1
    if foes <= 1 then return "" end
    return ns.LF("fought against %s", NUMBER[foes] or tostring(foes))
end

function CloseCalls.FoeTip(call, now)
    local lines = { CloseCalls.Tag(call) }
    lines[#lines + 1] = ns.LF("Left you with %s%% health", call.pct or 0)
    local more = (call.foes or 1) - 1
    if more > 0 then
        lines[#lines + 1] = more == 1 and ns.L("One more was in the fight")
            or ns.LF("%s more were in the fight", Capital(NUMBER[more] or tostring(more)))
    end
    lines[#lines + 1] = When(call.t, call.level, now)
    return call.name, lines
end

--------------------------------------------------------------------------
-- In the level's prose (Text.RegisterLines)
--------------------------------------------------------------------------

-- The level's close calls in its prose: each close call, at most `most`,
-- the rest counted. Nil with none. They open the fights' paragraph
-- ("combat", the `run` it shares with the luck with a quest's drops,
-- which runs on after it: Features/Hunts/Text.lua's "hunts", 75).
local PROSE = { most = 2 }

function CloseCalls.Lines(e)
    local parts = {}
    local calls = e.closeCalls or {}
    for i = 1, math.min(#calls, PROSE.most) do parts[#parts + 1] = CloseCalls.Sentence(calls[i]) end
    local more = #calls - PROSE.most
    if more > 0 then
        parts[#parts + 1] = more == 1 and ns.L("And one more close call.") or ns.LF("And %s more close calls.",
            NUMBER[more] or tostring(more))
    end
    if #parts == 0 then return nil end
    return table.concat(parts, " ")
end

-- After the professions' caps (60), first of the fights' paragraph.
Text.RegisterLines("close", { at = 70, run = "combat", lines = function(e) return CloseCalls.Lines(e) end })

--------------------------------------------------------------------------
-- On a plate (Text.RegisterCaption)
--------------------------------------------------------------------------

-- A close call: after the deaths, ", and a close call", or leading where
-- nothing above does. `said.close` (true): the card of the creature that
-- nearly got you is beside the plate (Card.lua's SetFoe), or a witness's
-- card names it, its health and fight charted there, so a close call
-- leading the words only names it ("A close call."); without, the
-- creature is named after the deaths too (", and a close call with a
-- Plainstrider"), as the killer is, and a lone close call leads whole
-- ("Got away from a Plainstrider with 6% health"). More are counted, "two
-- close calls". A killer's card and a close call's are two fights, so both
-- may be beside the plate, or either left off. It leads at 60 (after the
-- deaths, 50) and is told at 50 in the tail (after the deaths, 40).
local function Calls(calls, c)
    if #calls == 1 then
        local name = not c.said.close and Text.KillerName(calls[1])
        return name and ns.LF("a close call with %s", name) or ns.L("a close call")
    end
    return ns.LF("%s close calls", NUMBER[#calls] or tostring(#calls))
end

Text.RegisterCaption("close", {
    moment = "close",
    take = function(m) return m.call end,
    lead = { at = 60, say = function(calls, c)
        if #calls == 1 then return c.said.close and ns.L("A close call") or CloseCalls.Sentence(calls[1]):sub(1, -2) end
        return Capital(Calls(calls, c))
    end },
    tail = { at = 50, say = Calls },
})
