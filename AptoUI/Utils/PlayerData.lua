function AptoUI.Utils.GetClassAndSpec()
    local _, class = UnitClass("player")
    local class = class:lower()
    local specID = AptoUI.Utils.GetPlayerSpec()
    return class, specID
end

function AptoUI.Utils.GetPlayerSpec()
    local spec = C_SpecializationInfo.GetSpecialization()
    local specID = C_SpecializationInfo.GetSpecializationInfo(spec)
    -- print("spec: ", spec, "specID:", specID)
    return specID
end

function AptoUI.Utils.GetClassColour()
    local _, class = UnitClass("player")
    local colour = RAID_CLASS_COLORS[class]
    return colour
end
