function OnClear()
    scite.StripShow("")
end

function spell()
    spell_table = {}
    offset = 0
    local ln = 0
    local text = editor:GetSelText()
    if text == "" then text = (editor:GetText()) else
        ln = editor:LineFromPosition(editor.SelectionStart)
        if editor:PositionFromLine(ln) ~= editor.SelectionStart then
            offset = editor.SelectionStart - editor:PositionFromLine(ln) end
    end
    editor.IndicatorCurrent = 2
    editor.IndicStyle[2] = INDIC_SQUIGGLE
    local h_out = io.popen('sh -c "sed \'s/^$/ /g\' | aspell -a" << p-i-p-e\n' .. text:gsub('`', ' ') .. '\np-i-p-e')
    for l in h_out:lines() do
        if l == "" then ln = ln + 1 end
        for k, v in string.gmatch(l, "[&|#] (.+): (.+)") do
            local w = k:match("(%w+)")
            local c = k:match(" (%w+)$")
            if ln == editor:LineFromPosition(editor.SelectionStart) then c = c + offset end
            editor:GotoLine(ln)
            editor:IndicatorFillRange(editor.CurrentPos + c, w:len())
            table.insert(spell_table, {line = ln, column = c, word = w, suggestions = v})
        end
    end
    if table.getn(spell_table) == 0 then scite.StripShow("'Spell-check completed: no misspelled words'") else
        h_out:close()
        scite.StripShow("'Current Word:'[](&Add)(&Skip)\n'Suggestion:'{}(&Replace)(&Cancel)")
        process_spell_matches()
    end
end

function clear_field()
    spell_table = nil
    editor:SetSel(0, 0)
    editor.IndicatorCurrent = 2
    editor:IndicatorClearRange(0, editor.TextLength)
    scite.StripShow("")
end

function process_spell_matches(x)
    local h = spell_table[1]
    if h then
        if y ~= h.line then offset = 0 else
            if x then offset = offset + x - wl end
        end
        y = h.line
        table.remove(spell_table, 1)
        editor:GotoLine(y)
        local pos = editor.CurrentPos + h.column
        editor:SetSel(pos + offset, pos + offset + h.word:len())
        scite.StripSet(1, h.word)
        scite.StripSet(5, h.suggestions:match("(%w+)"))
        scite.StripSetList(5, "")
        scite.StripSetList(5, h.suggestions:gsub(", ", "\n"))
    else clear_field() end
end

function OnStrip(control, change)
    if change == 1 then
        if control == 2 then  -- Add
            local a = io.open(props["SciteUserHome"] .. "/.aspell.en.pws", "a")
            if a then a:write(scite.StripValue(1) .. "\n") end
            a:close()
            process_spell_matches()
        end
        if control == 3 then process_spell_matches() end  -- Next
        if control == 6 then  -- Replace
            _, wl = editor:GetSelText()
            if wl > 0 then wl = wl - 1; editor:ReplaceSel(scite.StripValue(5)) end
            process_spell_matches(scite.StripValue(5):len())
        end
        if control == 7 then clear_field() end  -- Cancel
    end
end
