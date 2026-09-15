function DebugPrint(data)
    local function cpy(t)
        local seen = {}
        local function _cpy(t)
            if type(t) ~= "table" then
                return tostring(t)
            elseif seen[t] then
                return "[CIRCULAR]"
            end
            local s = {}
            seen[t] = s
            for k, v in pairs(t) do
                s[_cpy(k)] = _cpy(v)
            end
            return s
        end
        return _cpy(t)
    end

    local success, result = pcall(json.encode, cpy(data), { indent = true })
    if success then
        print(result)
    else
        print("Erreur de sérialisation:", result)
        print("Type:", type(data), "Valeur:", tostring(data))
    end
end
