-- Spanish names for the dungeon data's English ones (LOC-2), shown only: the
-- logic of Core/Dungeons.lua and the data under Vendor/ keep working by the
-- English names (see Core/Locale.lua, Locale.Dungeon and Locale.Boss).
-- Keys are the names exactly as Vendor/DungeonCrawlerForever/Data/Dungeons.lua
-- and Wings.lua spell them. A name left out shows in English.
--
-- Bosses: when a boss falls, the map already shows the client's own name for it
-- (UI/Dungeon/Print.lua, DungeonPage.Names), so the unkilled ones are what this
-- table is for. It is empty on purpose: the official names are not guessed at.
-- Add { ["Rethilgore"] = "..." } lines to the "boss" block as they are checked.

local addonName, ns = ...

ns.Locale.RegisterNames("dungeon", {
    ["Shadowfang Keep"] = "Castillo de Colmillo Oscuro",
    ["Stormwind Stockade"] = "Las Mazmorras de Ventormenta",
    ["Deadmines"] = "Las Minas de la Muerte",
    ["Wailing Caverns"] = "Cuevas de los Lamentos",
    ["Razorfen Kraul"] = "Horado Rajacieno",
    ["Blackfathom Deeps"] = "Cavernas de Brazanegra",
    ["Sunken Temple"] = "El Templo Sumergido",
    ["Razorfen Downs"] = "Zahúrda Rajacieno",
    ["Scarlet Monastery"] = "Monasterio Escarlata",
    ["Scarlet Monastery - Graveyard"] = "Monasterio Escarlata - Cementerio",
    ["Scarlet Monastery - Library"] = "Monasterio Escarlata - Biblioteca",
    ["Scarlet Monastery - Armory"] = "Monasterio Escarlata - Armería",
    ["Scarlet Monastery - Cathedral"] = "Monasterio Escarlata - Catedral",
    ["Blackrock Spire"] = "Cumbre de Roca Negra",
    ["Lower Blackrock Spire"] = "Cumbre de Roca Negra inferior",
    ["Upper Blackrock Spire"] = "Cumbre de Roca Negra superior",
    ["Blackrock Depths"] = "Profundidades de Roca Negra",
    ["Onyxia's Lair"] = "Guarida de Onyxia",
    ["Ragefire Chasm"] = "Sima Ígnea",
    ["Molten Core"] = "Núcleo de Magma",
    ["Dire Maul"] = "La Masacre",
    ["Dire Maul - East"] = "La Masacre - Este",
    ["Dire Maul - West"] = "La Masacre - Oeste",
    ["Dire Maul - North"] = "La Masacre - Norte",
    ["Blackwing Lair"] = "Guarida Alanegra",
    ["Ruins of Ahn'Qiraj"] = "Ruinas de Ahn'Qiraj",
    ["Ahn'Qiraj Temple"] = "Templo de Ahn'Qiraj",
    ["Ruins of Lordaeron"] = "Ruinas de Lordaeron",
    ["City of Dalaran"] = "Ciudad de Dalaran",
    -- Spelled the same: Uldaman, Gnomeregan, Zul'Farrak, Scholomance,
    -- Zul'Gurub, Stratholme, Maraudon, Naxxramas.
})

ns.Locale.RegisterNames("boss", {
})

-- The names the formatting falls back on when the client gives none (a race or
-- class token kept by the diary, and the capitals the timeline treats as one place).
ns.Locale.Register("Words", {
    ["Human"] = "Humano", ["Orc"] = "Orco", ["Dwarf"] = "Enano", ["Troll"] = "Troll", ["Tauren"] = "Tauren",
    ["Gnome"] = "Gnomo", ["Goblin"] = "Goblin", ["Draenei"] = "Draenei", ["BloodElf"] = "Elfo de sangre",
    ["Worgen"] = "Huargen", ["Pandaren"] = "Pandaren",
    ["Warrior"] = "Guerrero", ["Paladin"] = "Paladín", ["Hunter"] = "Cazador", ["Rogue"] = "Pícaro",
    ["Priest"] = "Sacerdote", ["Shaman"] = "Chamán", ["Mage"] = "Mago", ["Warlock"] = "Brujo", ["Druid"] = "Druida",
})
ns.Locale.Register("Timeline", {
    ["Stormwind City"] = "Ciudad de Ventormenta", ["Orgrimmar"] = "Orgrimmar", ["Ironforge"] = "Forjaz",
    ["Thunder Bluff"] = "Cima del Trueno", ["Darnassus"] = "Darnassus", ["Undercity"] = "Entrañas",
    ["Deeprun Tram"] = "Tranvía Subterráneo",
})
