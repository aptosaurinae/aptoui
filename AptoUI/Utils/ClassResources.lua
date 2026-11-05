-- Todo: Consider tracking things like Whirlwind charges for Warrior, or Stagger for Brewmaster?

-- Enum.PowerType is a built-in Blizzard system for looking up these types
-- Primary power types can be looked up with UnitPowerType("player")
-- Power colours can be looked up in PowerBarColor using the Enum.PowerType value

local power_colour_overwrite = {
    [Enum.PowerType.ComboPoints] = { r = 1, g = 0.8, b = 0.1 },
    rogue_charged = { r = 0, g = 0.5, b = 1 },
    dk_runes = { r = 1, g = 1, b = 1 },
    [Enum.PowerType.Essence] = { r = 0.2, g = 0.58, b = 0.5}
}
local power_additional_events = {
    [Enum.PowerType.ComboPoints] = {
        "UNIT_POWER_POINT_CHARGE",
        "UNIT_POWER_FREQUENT",
    },
    dk_runes = {
        "RUNE_POWER_UPDATE",
        "RUNE_TYPE_UPDATE",
    }
}

local power_mana = { primary = Enum.PowerType.Mana }
local power_rage = { primary = Enum.PowerType.Rage }

local power_dk = { primary = Enum.PowerType.RunicPower, dk_runes = "dk_runes" }
local power_dh = { primary = Enum.PowerType.Fury }
local power_evoker = { primary = Enum.PowerType.Mana, secondary = Enum.PowerType.Essence }
local power_hunter = { primary = Enum.PowerType.Focus }
local power_mage = power_mana
local power_paladin = { primary = Enum.PowerType.Mana, secondary = Enum.PowerType.HolyPower }
local power_priest = power_mana
local power_rogue = {
    primary = Enum.PowerType.Energy,
    secondary = Enum.PowerType.ComboPoints,
    rogue_charged = "rogue_charged",
}
local power_shaman = power_mana
local power_warlock = power_mana
local power_warrior = power_rage

local powerStartsAtZeroList = {
    Enum.PowerType.Rage,
    Enum.PowerType.RunicPower,
    Enum.PowerType.HolyPower,
    Enum.PowerType.ComboPoints,
    Enum.PowerType.Fury,
    Enum.PowerType.ArcaneCharges,
    Enum.PowerType.Insanity,
    Enum.PowerType.Maelstrom,
}
local powerStartsAtZero = {}
for _, name in ipairs(powerStartsAtZeroList) do
    powerStartsAtZero[name] = true
end

local PowerLookupDruidForm = {
    -- moonkin
    [31] = { primary = Enum.PowerType.Mana, secondary = Enum.PowerType.LunarPower },
    -- cat
    [1] = { primary = Enum.PowerType.Energy, secondary = Enum.PowerType.ComboPoints },
    -- bear
    [5] = power_rage,
}

-- See wowlookups/ClassSpecs for the numbers used here
local PowerLookup = {
    deathknight = {
        -- Blood
        [250] = power_dk,
        -- Frost
        [251] = power_dk,
        -- Unholy
        [252] = power_dk
    },
    demonhunter = {
        -- Devourer
        [577] = power_dh,
        -- Havoc
        [581] = power_dh,
        -- Vengeance
        [1480] = power_dh
    },
    druid = {  -- note that these are for "no form" druid, see PowerLookupDruidForm for form values
        -- no spec (forever)
        [1484] = power_mana,
        -- balance
        [102] = { primary = Enum.PowerType.Mana, secondary = Enum.PowerType.LunarPower },
        -- feral
        [103] = { primary = Enum.PowerType.Mana, secondary = Enum.PowerType.ComboPoints },
        -- guardian
        [104] = power_mana,
        -- resto
        [105] = power_mana
    },
    evoker = {
        -- Augmentation
        [1473] = power_evoker,
        -- Devastation
        [1467] = power_evoker,
        -- Preservation
        [1468] = power_evoker
    },
    hunter = {
        -- no spec (forever)
        [1485] = power_mana,
        -- Beast Master
        [253] = power_hunter,
        -- Marksmanship
        [254] = power_hunter,
        -- Survival
        [255] = power_hunter
    },
    mage = {
        -- no spec (forever)
        [1482] = power_mana,
        -- Arcane
        [62] = { primary = Enum.PowerType.Mana, secondary = Enum.PowerType.ArcaneCharges },
        -- Fire
        [63] = power_mage,
        -- Frost
        [64] = power_mage
    },
    monk = {
        -- Brewmaster
        [268] = { primary = Enum.PowerType.Energy },
        -- Mistweaver
        [270] = power_mana,
        -- Windwalker
        [269] = { primary = Enum.PowerType.Energy, secondary = Enum.PowerType.Chi }
    },
    paladin = {
        -- no spec (forever)
        [1486] = power_mana,
        -- Holy
        [65] = power_paladin,
        -- Protection
        [66] = power_paladin,
        -- Retribution
        [70] = power_paladin
    },
    priest = {
        -- no spec (forever)
        [1487] = power_mana,
        -- Discipline
        [256] = power_priest,
        -- Holy
        [257] = power_priest,
        -- Shadow
        [258] = { primary = Enum.PowerType.Mana, secondary = Enum.PowerType.Insanity }
    },
    rogue = {
        -- no spec (forever)
        [1488] = power_energy,
        -- Assassination
        [259] = power_rogue,
        -- Outlaw
        [260] = power_rogue,
        -- Subtlety
        [261] = power_rogue
    },
    shaman = {
        -- no spec (forever)
        [1489] = power_mana,
        -- Elemental
        [262] = { primary = Enum.PowerType.Mana, secondary = Enum.PowerType.Maelstrom },
        -- Enhancement
        [263] = power_shaman,
        -- Resto
        [264] = power_shaman
    },
    warlock = {
        -- no spec (forever)
        [1490] = power_mana,
        -- Affliction
        [265] = power_warlock,
        -- Demonology
        [266] = power_warlock,
        -- Destruction
        [267] = power_warlock
    },
    warrior = {
        -- no spec (forever)
        [1491] = power_rage,
        -- Arms
        [71] = power_warrior,
        -- Fury
        [72] = power_warrior,
        -- Protection
        [73] = power_warrior
    }
}

-- GetShapeshiftFormID is a Blizzard function
function AptoUI.Utils.GetResourceTypes()
    local class, specID = AptoUI.Utils.GetClassAndSpec()
    local shapeshiftType
    if class == "druid" then
        local formID = GetShapeshiftFormID()
        shapeshiftResourceTypes = PowerLookupDruidForm[formID]
        if shapeshiftResourceTypes then
            return shapeshiftResourceTypes
        end
    end
    local powers = PowerLookup[class][specID]
    if powers == nil then
        return {}
    end
    return powers
end

-- Gets the power type ID from a lookup, based on the type of power
-- resourceType in "primary", "secondary"
function AptoUI.Utils.GetPowerType(resourceType)
    local resources = AptoUI.Utils.GetResourceTypes()
    if not resources then
        return nil, nil
    end
    local powerType = resources[resourceType]
    if not powerType then
        return nil, nil
    end
    local startsAtZero = powerStartsAtZero[powerType] or false
    return powerType, startsAtZero
end

function AptoUI.Utils.GetPowerColour(powerType)
    return power_colour_overwrite[powerType] or PowerBarColor[powerType] or {r = 1, g = 1, b = 1}
end

function AptoUI.Utils.GetPowerEvents(powerType)
    return power_additional_events[powerType] or {}
end
