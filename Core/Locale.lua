-- Localisation of the addon's own interface (LOC-2). LOC-1 is the other
-- half: reading the client's global strings, never English words. This
-- file is the mechanism; the Spanish text is Locale/esES*.lua's.
--
--   ns.L(key)          the key's translation on a Spanish client (esES or
--                      esMX), otherwise -- or where nothing is translated
--                      yet -- the key itself. The key IS the English text,
--                      so on any other client the result is the very string
--                      that was passed in, and an untranslated key shows in
--                      English instead of breaking.
--   ns.LF(key, ...)    ns.L, then string.format: for templates with %s/%d.
--                      Lua 5.1 has no positional "%1$s", so a translation
--                      keeps the arguments in the English order.
--   ns.LDate(fmt, t)   date(fmt, t) with %A %a %B %b in the client's
--                      language: the game has no setlocale, and date()
--                      always answers in English.
--
-- Translations are registered by area, so the tables stay a size one can
-- read and fill by phase:
--
--   ns.Locale.Register("Settings", { ["Keys"] = "Teclas", ... })
--
-- ns.Locale.Strings[area][key] keeps the areas apart; the lookup reads them
-- as one table (the first registration of a key wins, so the same English
-- word is translated once), and ns.L(key, area) asks one area first for a
-- word that needs a different translation in one place.
--
-- Nothing is saved: text is chosen when it is written, never stored, so
-- changing the client's language needs no migration.

local addonName, ns = ...

local Locale = {}
ns.Locale = Locale

local CLIENT = GetLocale and GetLocale() or "enUS"
local SPANISH = { esES = true, esMX = true }

-- Whether translations are in use: a Spanish client.
local active = SPANISH[CLIENT] == true
Locale.client = CLIENT

function Locale.Active()
    return active
end

-- For the smoke tests, which have no client to switch: forces the language
-- on or off (nil puts the client's back) and returns what it was.
function ns._test.SetLocaleActive(on)
    local was = active
    if on == nil then active = SPANISH[CLIENT] == true else active = on == true end
    return was
end

Locale.Strings = {}
local merged = {}

function Locale.Register(area, strings)
    local into = Locale.Strings[area]
    if not into then
        into = {}
        Locale.Strings[area] = into
    end
    for key, text in pairs(strings) do
        into[key] = text
        if merged[key] == nil then merged[key] = text end
    end
end

-- Translated and total keys per area, for the progress checklist.
function Locale.Progress()
    local out = {}
    for area, strings in pairs(Locale.Strings) do
        local n = 0
        for _ in pairs(strings) do n = n + 1 end
        out[area] = n
    end
    return out
end

function ns.L(key, area)
    if not active then return key end
    local from = area and Locale.Strings[area]
    return (from and from[key]) or merged[key] or key
end

function ns.LF(key, ...)
    return ns.L(key):format(...)
end

--------------------------------------------------------------------------
-- Dates
--------------------------------------------------------------------------

-- date("*t").wday is 1 for Sunday and month is 1 for January.
local DAYS = {
    { "Sunday", "domingo", "dom" }, { "Monday", "lunes", "lun" }, { "Tuesday", "martes", "mar" },
    { "Wednesday", "miércoles", "mié" }, { "Thursday", "jueves", "jue" },
    { "Friday", "viernes", "vie" }, { "Saturday", "sábado", "sáb" },
}
local MONTHS = {
    { "January", "enero", "ene" }, { "February", "febrero", "feb" }, { "March", "marzo", "mar" },
    { "April", "abril", "abr" }, { "May", "mayo", "may" }, { "June", "junio", "jun" },
    { "July", "julio", "jul" }, { "August", "agosto", "ago" },
    { "September", "septiembre", "sep" }, { "October", "octubre", "oct" },
    { "November", "noviembre", "nov" }, { "December", "diciembre", "dic" },
}

function ns.LDate(fmt, time)
    if not active or fmt:find("^!?%*t") then
        if time then return date(fmt, time) end
        return date(fmt)
    end

    local parts = date("*t", time)
    -- "%%" first, so that "%%A" stays a literal "%A".
    local text = fmt:gsub("%%(.)", function(code)
        if code == "A" then return DAYS[parts.wday][2] end
        if code == "a" then return DAYS[parts.wday][3] end
        if code == "B" then return MONTHS[parts.month][2] end
        if code == "b" then return MONTHS[parts.month][3] end
        return "%" .. code
    end)
    -- The substituted words hold no "%", but "%%" must survive as it came.
    if time then return date(text, time) end
    return date(text)
end

--------------------------------------------------------------------------
-- Capitals
--------------------------------------------------------------------------

-- string.upper leaves the bytes of an accented letter alone (á stays á), so
-- on a Spanish client these step each Latin-1 letter in UTF-8 (C3 A0-BE) up
-- to its capital. Elsewhere they are string.upper, as the code always used.
local function Accents(second)
    if second ~= "\183" then return "\195" .. string.char(second:byte() - 32) end
end

function ns.Upper(text)
    text = text:upper()
    if not active then return text end
    return (text:gsub("\195([\160-\190])", Accents))
end

-- The first letter capitalised: whole UTF-8 character, not its first byte.
function ns.UpperFirst(text)
    if not active then return text:sub(1, 1):upper() .. text:sub(2) end
    local first = text:match("^[%z\1-\127\194-\244][\128-\191]*") or ""
    return ns.Upper(first) .. text:sub(#first + 1)
end

--------------------------------------------------------------------------
-- Names the addon's data holds in English
--------------------------------------------------------------------------
--
-- The dungeon data (Vendor/DungeonCrawlerForever/) and the logic over it
-- (Core/Dungeons.lua) work by those English names, so they are not touched:
-- these only change what is shown. A name with no entry, or any client but a
-- Spanish one, is shown as the data has it.

Locale.Names = { dungeon = {}, boss = {} }

function Locale.RegisterNames(kind, names)
    local into = Locale.Names[kind]
    for english, local_ in pairs(names) do into[english] = local_ end
end

-- A dungeon's (or a wing's, "Scarlet Monastery - Library") name to show.
function Locale.Dungeon(name)
    if not active or type(name) ~= "string" then return name end
    return Locale.Names.dungeon[name] or name
end

-- A boss's name to show, or nil where there is no entry (so `x or name` reads).
function Locale.Boss(name)
    if not active then return nil end
    return Locale.Names.boss[name]
end
