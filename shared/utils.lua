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

Utils = {}

function Utils.DebugPrint(data)
    if not Variables.Get("DebugPrint") then return print("désactivé") end
    if data == nil then
        print("^3[DEBUG]^7 nil")
        return
    end

    if type(data) ~= "table" then
        print(("^3[DEBUG]^7 [%s] %s"):format(
            type(data),
            tostring(data)
        ))
        return
    end

    local seen = {}

    local function serialize(value)
        if type(value) ~= "table" then
            return value
        end

        if seen[value] then
            return "[CIRCULAR]"
        end

        seen[value] = true

        local result = {}

        for key, child in pairs(value) do
            result[key] = serialize(child)
        end

        return result
    end

    local success, encoded = pcall(function()
        return json.encode(serialize(data), {
            indent = true
        })
    end)

    if not success then
        print("^1[DEBUG ERROR]^7 " .. tostring(encoded))
        return
    end

    print("^5[DEBUG]^7")
    print(encoded)
end
