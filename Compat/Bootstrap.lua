local addon, ns = ...
local Hekili = _G[ addon ]

ns.Compat = ns.Compat or {}

if not _G.Enum then _G.Enum = {} end

if not Enum.PowerType then
    Enum.PowerType = {
        None = 0,
        Mana = 0,
        Rage = 1,
        Focus = 2,
        Energy = 3,
        ComboPoints = 4,
        Runes = 5,
        RunicPower = 6,
        SoulShards = 7,
        LunarPower = 8,
        HolyPower = 9,
        Alternate = 10,
        Maelstrom = 11,
        Chi = 12,
        Insanity = 13,
        Obsolete = 14,
        Obsolete2 = 15,
        ArcaneCharges = 16,
        Fury = 17,
        Pain = 18,
        Essence = 19,
        RuneBlood = 20,
        RuneFrost = 21,
        RuneUnholy = 22,
    }
end

if not Enum.ItemSlotFilterTypeMeta then
    Enum.ItemSlotFilterTypeMeta = {
        MaxValue = INVSLOT_LAST_EQUIPPED or 19
    }
end

if not _G.C_Container then _G.C_Container = {} end
if not C_Container.GetItemCooldown then
    C_Container.GetItemCooldown = _G.GetItemCooldown or function()
        return 0, 0, 1, 1
    end
end

if not _G.C_Spell then _G.C_Spell = {} end
if not C_Spell.IsSpellDataCached then
    C_Spell.IsSpellDataCached = function()
        return true
    end
end
if not C_Spell.RequestLoadSpellData then
    C_Spell.RequestLoadSpellData = function()
    end
end

if not _G.ItemLocation then
    _G.ItemLocation = {}
    function ItemLocation:CreateEmpty()
        return {
            SetEquipmentSlot = function()
            end,
            Clear = function()
            end
        }
    end
end

if not _G.C_AzeriteEmpoweredItem then
    _G.C_AzeriteEmpoweredItem = {
        GetAllTierInfoByItemID = function()
            return {}
        end,
        GetAllTierInfo = function()
            return {}
        end,
        GetPowerInfo = function()
            return nil
        end,
        IsAzeriteEmpoweredItemByID = function()
            return false
        end,
        IsPowerSelected = function()
            return false
        end
    }
end

if not _G.C_AzeriteEssence then
    _G.C_AzeriteEssence = {
        GetMilestoneEssence = function()
            return nil
        end,
        GetEssenceInfo = function()
            return nil
        end
    }
end

if not _G.GetPlayerAuraBySpellID then
    _G.GetPlayerAuraBySpellID = function( spellID )
        if not spellID then return nil end

        local i = 1
        while true do
            local name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, id = UnitBuff( "player", i )
            if not name then break end
            if id == spellID then
                return name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, id
            end
            i = i + 1
        end

        return nil
    end
end

ns.Compat.GetAddOnMetadata = function( name, field )
    if _G.C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata( name, field )
    end
    if _G.GetAddOnMetadata then
        return GetAddOnMetadata( name, field )
    end
    return nil
end

ns.Compat.GetItemCooldown = function( item )
    if C_Container and C_Container.GetItemCooldown then
        return C_Container.GetItemCooldown( item )
    end
    if _G.GetItemCooldown then
        return GetItemCooldown( item )
    end
    return 0, 0, 1, 1
end
