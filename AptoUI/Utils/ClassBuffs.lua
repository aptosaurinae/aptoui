AptoUI.Utils.ClassBuffLookup = {
    druid = {},
    evoker = {},
    mage = {},
    priest = {},
    rogue = {},
    shaman = {},
    warrior = {},
}
AptoUI.Utils.ClassBuffLookup["druid"]["Mark of the Wild"] = {
    motw = "Mark of the Wild"
}
AptoUI.Utils.ClassBuffLookup["evoker"]["Blessing of the Bronze"] = {
    blessingbronze = "Blessing of the Bronze"
}
AptoUI.Utils.ClassBuffLookup["mage"]["Arcane Intellect"] = {
    arcaneint = "Arcane Intellect"
}
AptoUI.Utils.ClassBuffLookup["priest"]["Power Word: Fortitude"] = {
    pwfort = "Power Word: Fortitude"
}
AptoUI.Utils.ClassBuffLookup["rogue"]["Lethal Poison"] = {
    deadly = "Deadly Poison",
    instant = "Instant Poison",
    wound = "Wound Poison",
}
AptoUI.Utils.ClassBuffLookup["shaman"]["Skyfury"] = {
    skyfury = "Skyfury"
}
AptoUI.Utils.ClassBuffLookup["rogue"]["Non-Lethal Poison"] = {
    atrophic = "Atrophic Poison",
    crippling = "Crippling Poison",
    numbing = "Numbing Poison",
}
AptoUI.Utils.ClassBuffLookup["warrior"]["Battle Shout"] = {
    bshout = "Battle Shout"
}


-- buffsList = {name = "name"}
-- aurasList = {name = true}
local function CheckActiveBuff(buffsList, aurasList)
    for _, buffName in pairs(buffsList) do
        if aurasList[buffName] then
            return true
        end
    end
    return false
end

function AptoUI.Utils.HasMissingClassBuff(class)
    local activeBuffs = {}
    -- if we get an error trying to get auras (such as for a brief moment as combat starts)
    -- we want to just skip doing this.
    local noError, err = pcall(function()
        AuraUtil.ForEachAura("player", "HELPFUL", nil, function(aura)
            activeBuffs[aura] = true
        end)
    end)

    local missingBuffTypes = {}
    for buffCategoryName, buffCategoryBuffNames in pairs(AptoUI.Utils.ClassBuffLookup[class]) do
        missingBuffTypes[buffCategoryName] = not CheckActiveBuff(buffCategoryBuffNames, activeBuffs)
    end

    return missingBuffTypes
end
