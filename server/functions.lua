_Func = {}

_Func.GetIdentifier = function(source, type)
  if not source or not type then
    return nil
  end

  for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
    if identifier:sub(1, #type) == type then
      return identifier:sub(#type + 1)
    end
  end

  return "Aucun identifiant trouvé"
end
