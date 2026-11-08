-- Spanish text for the Chrome area (LOC-2): key bindings, dialogs, the entry page, the minimap tooltip and the page ribbons.
-- The key is the English text exactly as the code passes it to ns.L / ns.LF;
-- see Core/Locale.lua. A key left out shows in English.

local addonName, ns = ...

ns.Locale.Register("Chrome", {
    ["Delete"] = "Borrar",
    ["Cancel"] = "Cancelar",
    ["Delete everything Social Diary knows about %s?\n\nThis cannot be undone."] = "¿Borrar todo lo que Social Diary sabe sobre %s?\n\nNo se puede deshacer.",
    ["deleted everything about |cffffffff%s|r."] = "se borró todo sobre |cffffffff%s|r.",
    ["Remove %s from the diary?\n\nTheir history can stay as an ordinary character, where the buffer's retention rules apply to it again."] = "¿Quitar a %s del diario?\n\nSu historial puede quedarse como el de un personaje cualquiera, y vuelven a aplicarse las reglas de retención del búfer.",
    ["Keep history"] = "Conservar historial",
    ["Delete everything"] = "Borrarlo todo",
    ["no interactions yet"] = "aún sin interacciones",
    ["%d interaction on record"] = "%d interacción registrada",
    ["%d interactions on record"] = "%d interacciones registradas",
    ["Added %s in %s  ·  %s"] = "Añadido el %s en %s  ·  %s",
    ["Added %s  ·  %s"] = "Añadido el %s  ·  %s",
    ["What happened? What should you remember about them?"] = "¿Qué pasó? ¿Qué deberías recordar de esa persona?",
    ["Tags"] = "Etiquetas",
    ["+ add a tag"] = "+ añadir etiqueta",
    ["Relationship"] = "Relación",
    ["'leveling buddy', 'weirdo', 'Sulfuras Guy', …"] = "'compañero de nivelación', 'rarito', 'el de Sulfuras', …",
    ["Note"] = "Nota",
    ["Remove from the diary"] = "Quitar del diario",
    ["Done"] = "Hecho",
    ["could not identify that character."] = "no se pudo identificar a ese personaje.",
    ["|cffffffff%s|r is already in the diary."] = "|cffffffff%s|r ya está en el diario.",
    ["Click to open or close the journal."] = "Clic para abrir o cerrar el diario.",
    ["Right-click to open the settings."] = "Clic derecho para abrir los ajustes.",
    ["Drag to move this button."] = "Arrastra para mover este botón.",
    ["Your Diary"] = "Tu Diario",
    ["People"] = "Gente",
    ["Recently nearby"] = "Cerca hace poco",
    ["Social Diary"] = "Diario Social",
    ["Remember this"] = "Recordar esto",
    ["Open the journal"] = "Abrir el diario",
})
