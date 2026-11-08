-- Profession caps' words (JRN-29): a sentence each in the level's prose
-- (Text.RegisterLines, UI/Journey/Text/Prose.lua), the plates' caption words
-- (Text.RegisterCaption) and the stairs' tooltip (Mark.lua). Copy changes
-- go through the copywriter skill, as every player-read word does.

local addonName, ns = ...

local ProfessionCaps = ns.ProfessionCaps
local Text = ns.UI.JourneyText
local Capital, When, NUMBER = Text.Capital, Text.When, Text.NUMBER

-- Who a cap is as far as the training goes: each rank's trainer's title,
-- with its article. Any other number (a cap the client adds later) is
-- told bare, without the clause.
local SKILL_RANK = { [75] = ns.L("an Apprentice"), [150] = ns.L("a Journeyman"), [225] = ns.L("an Expert"), [300] = ns.L("an Artisan") }

-- The profession as the client called it, or "a profession" where it gave
-- no name.
local function Trade(cap)
    return cap.name and cap.name ~= "" and cap.name or ns.L("a profession")
end

-- The cap reached, as a number to say after "at": "75"; "its cap" where
-- the record has none.
local function Rank(cap)
    return cap.rank and tostring(cap.rank) or ns.L("its cap")
end

-- A cap in a few words, for a plate's caption: "First Aid at 75", "a
-- profession at 75".
function ProfessionCaps.Words(cap)
    return ns.LF("%s at %s", Trade(cap), Rank(cap))
end

-- How far the training goes, after a comma: "as far as an Apprentice
-- goes"; nil for a rank with no trainer's title.
local function AsFar(cap)
    local who = SKILL_RANK[cap.rank]
    return who and ns.LF("as far as %s goes", who) or nil
end

-- A cap in a sentence: "First Aid reached 75, as far as an Apprentice
-- goes." The same profession again straight after only counts on: "Then
-- 150, as far as a Journeyman goes."
function ProfessionCaps.Sentence(cap, before)
    local again = before and (before.skillLine or before.name) == (cap.skillLine or cap.name)
        and (cap.skillLine or cap.name) ~= nil
    local text = again and ns.LF("Then %s", Rank(cap)) or ns.LF("%s reached %s", Capital(Trade(cap)), Rank(cap))
    local far = AsFar(cap)
    if far then text = ns.LF("%s, %s", text, far) end
    return text .. "."
end

-- The level's caps in its prose, one sentence each.
function ProfessionCaps.Lines(e)
    local parts, before = {}, nil
    for _, cap in ipairs(e.skillCaps or {}) do
        parts[#parts + 1] = ProfessionCaps.Sentence(cap, before)
        before = cap
    end
    if #parts == 0 then return nil end
    return table.concat(parts, " ")
end

-- Its mark's tooltip: "First Aid at 75", then how far the training goes
-- ("As far as an Apprentice goes"), then when.
function ProfessionCaps.Tip(cap, now)
    local lines = {}
    local far = AsFar(cap)
    if far then lines[#lines + 1] = Capital(far) end
    lines[#lines + 1] = When(cap.t, cap.level, now)
    return Capital(ProfessionCaps.Words(cap)), lines
end

-- Its paragraph in the level's prose: after the chains finished (50),
-- before the close calls and luck (70).
Text.RegisterLines("skill", { at = 60, lines = function(e) return ProfessionCaps.Lines(e) end })

-- The caption's words: after the chains' ends, or leading where neither
-- finds nor finales do: "First Aid at 75"; one profession twice, "First
-- Aid at 75, then 150"; several, "two professions at their cap". Its lead
-- (`at` 40) comes after a chain's end (30), before a fight with strangers
-- (45); its tail (`at` 30) after the chains' ends (20), before the deaths
-- (40).
local function Capped(caps)
    local trades, seen = 0, {}
    for _, cap in ipairs(caps) do
        local key = cap.skillLine or cap.name or cap
        if not seen[key] then seen[key], trades = true, trades + 1 end
    end
    if trades > 1 then return ns.LF("%s professions at their cap", NUMBER[trades] or tostring(trades)) end
    local text = ProfessionCaps.Words(caps[1])
    for k = 2, #caps do text = ns.LF("%s, then %s", text, caps[k].rank or ns.L("its cap")) end
    return text
end

Text.RegisterCaption("skill", {
    moment = "skill",
    take = function(m) return m.cap end,
    lead = { at = 40, say = function(caps) return Capital(Capped(caps)) end },
    tail = { at = 30, say = Capped },
})
