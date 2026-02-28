if UnitClassBase( "player" ) ~= "PALADIN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]

if not Hekili.IsTBC() then return end

local class = Hekili.Class

local function BestID( name, fallback )
    return function()
        return ns.GetBestKnownSpellIDByName( name ) or fallback
    end
end

local function addCommonPaladinKit( spec )
    spec:RegisterResource( Enum.PowerType.Mana )

    spec:RegisterAuras( {
        righteous_fury = {
            id = BestID( "Righteous Fury", 25780 ),
            duration = 1800,
            max_stack = 1,
        },
        holy_shield = {
            id = BestID( "Holy Shield", 20925 ),
            duration = 10,
            max_stack = 4,
            copy = { 20925, 20927, 20928, 27179 },
        },
        active_consecration = {
            duration = 8,
            max_stack = 1,
            generate = function( t )
                local applied = action.consecration.lastCast
                if applied and now - applied < 8 then
                    t.count = 1
                    t.expires = applied + 8
                    t.applied = applied
                    t.caster = "player"
                    return
                end

                t.count = 0
                t.expires = 0
                t.applied = 0
                t.caster = "nobody"
            end
        },
        seal_of_righteousness = {
            id = BestID( "Seal of Righteousness", 21084 ),
            duration = 30,
            max_stack = 1,
        },
        seal_of_command = {
            id = BestID( "Seal of Command", 20375 ),
            duration = 30,
            max_stack = 1,
        },
        seal_of_blood = {
            id = BestID( "Seal of Blood", 31892 ),
            duration = 30,
            max_stack = 1,
        },
        seal_of_vengeance = {
            id = BestID( "Seal of Vengeance", 31801 ),
            duration = 30,
            max_stack = 1,
        },
        active_seal = {
            alias = { "seal_of_command", "seal_of_blood", "seal_of_vengeance", "seal_of_righteousness" },
            aliasMode = "latest",
            aliasType = "buff",
        },
        judgement_of_the_crusader = {
            id = BestID( "Judgement of the Crusader", 20305 ),
            duration = 20,
            max_stack = 1,
        },
        judgement_of_wisdom = {
            id = BestID( "Judgement of Wisdom", 20186 ),
            duration = 20,
            max_stack = 1,
        },
        judgement_of_light = {
            id = BestID( "Judgement of Light", 20185 ),
            duration = 20,
            max_stack = 1,
        },
    } )

    spec:RegisterStateExpr( "tbc_target_undead_or_demon", function()
        local creatureType = UnitExists( "target" ) and UnitCreatureType( "target" )
        return creatureType == "Undead" or creatureType == "Demon"
    end )

    spec:RegisterStateExpr( "tbc_heal_target_exists", function()
        local unit = settings.healing_target or "focus"
        return UnitExists( unit ) and UnitCanAssist( "player", unit )
    end )

    spec:RegisterStateExpr( "tbc_heal_target_health_pct", function()
        local unit = settings.healing_target or "focus"
        if not UnitExists( unit ) or not UnitCanAssist( "player", unit ) then return 100 end
        local hpMax = UnitHealthMax( unit )
        if not hpMax or hpMax <= 0 then return 100 end
        return 100 * UnitHealth( unit ) / hpMax
    end )

    spec:RegisterAbilities( {
        righteous_fury = {
            id = BestID( "Righteous Fury", 25780 ),
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            handler = function()
                applyBuff( "righteous_fury" )
            end
        },
        holy_shield = {
            id = BestID( "Holy Shield", 20925 ),
            cast = 0,
            cooldown = 10,
            gcd = "spell",
            handler = function()
                applyBuff( "holy_shield", nil, 4 )
            end,
        },
        consecration = {
            id = BestID( "Consecration", 27173 ),
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            handler = function()
                applyBuff( "active_consecration" )
            end,
        },
        judgement = {
            id = BestID( "Judgement", 20271 ),
            cast = 0,
            cooldown = 10,
            gcd = "spell",
            handler = function()
                if buff.seal_of_command.up then
                    applyDebuff( "judgement_of_the_crusader" )
                elseif buff.seal_of_vengeance.up then
                    applyDebuff( "judgement_of_wisdom" )
                else
                    applyDebuff( "judgement_of_light" )
                end

                removeBuff( "seal_of_righteousness" )
                removeBuff( "seal_of_command" )
                removeBuff( "seal_of_blood" )
                removeBuff( "seal_of_vengeance" )
            end,
        },
        seal_of_righteousness = {
            id = BestID( "Seal of Righteousness", 21084 ),
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            handler = function()
                applyBuff( "seal_of_righteousness" )
            end,
        },
        seal_of_command = {
            id = BestID( "Seal of Command", 20375 ),
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            handler = function()
                applyBuff( "seal_of_command" )
            end,
        },
        seal_of_blood = {
            id = BestID( "Seal of Blood", 31892 ),
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            handler = function()
                applyBuff( "seal_of_blood" )
            end,
        },
        seal_of_vengeance = {
            id = BestID( "Seal of Vengeance", 31801 ),
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            handler = function()
                applyBuff( "seal_of_vengeance" )
            end,
        },
        crusader_strike = {
            id = BestID( "Crusader Strike", 35395 ),
            cast = 0,
            cooldown = 6,
            gcd = "spell",
        },
        exorcism = {
            id = BestID( "Exorcism", 10314 ),
            cast = 1.5,
            cooldown = 15,
            gcd = "spell",
            usable = function()
                return tbc_target_undead_or_demon
            end,
        },
        hammer_of_wrath = {
            id = BestID( "Hammer of Wrath", 24275 ),
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            usable = function()
                return target.health.pct <= 20
            end
        },
        holy_light = {
            id = BestID( "Holy Light", 27136 ),
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",
            friendly = true,
            startsCombat = false,
            usable = function()
                local unit = settings.healing_target or "focus"
                return UnitExists( unit ) and UnitCanAssist( "player", unit )
            end,
        },
        flash_of_light = {
            id = BestID( "Flash of Light", 27137 ),
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            friendly = true,
            startsCombat = false,
            usable = function()
                local unit = settings.healing_target or "focus"
                return UnitExists( unit ) and UnitCanAssist( "player", unit )
            end,
        },
        holy_shock = {
            id = BestID( "Holy Shock", 20473 ),
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            friendly = true,
            startsCombat = false,
            usable = function()
                local unit = settings.healing_target or "focus"
                return UnitExists( unit ) and UnitCanAssist( "player", unit )
            end,
        },
    } )
end

local holy = Hekili:NewSpecialization( 65 )
local prot = Hekili:NewSpecialization( 66 )
local ret  = Hekili:NewSpecialization( 70 )

addCommonPaladinKit( holy )
addCommonPaladinKit( prot )
addCommonPaladinKit( ret )

holy:RegisterTalents( {
    holy_shock = { 1502, 1, 20473 },
} )

prot:RegisterTalents( {
    holy_shield = { 1430, 4, 20925, 20927, 20928, 27179 },
    avengers_shield = { 1754, 1, 31935 },
} )

ret:RegisterTalents( {
    crusader_strike = { 1823, 1, 35395 },
    seal_of_command = { 1481, 1, 20375 },
} )

holy:RegisterSetting( "healing_target", "focus", {
    type = "select",
    name = "Healing Target",
    desc = "Unit to use for Holy healing recommendations.",
    values = function()
        return {
            focus = "focus",
            target = "target",
            party1 = "party1",
            party2 = "party2",
            party3 = "party3",
            party4 = "party4",
        }
    end
} )

holy:RegisterSetting( "holy_healing_mode", true, {
    type = "toggle",
    name = "Healing Mode",
    desc = "Enable Holy healing recommendations."
} )

holy:RegisterSetting( "holy_holy_shock_pct", 55, {
    type = "range",
    name = "Holy Shock %",
    desc = "Use Holy Shock at or below this HP%.",
    min = 1,
    max = 100,
    step = 1
} )

holy:RegisterSetting( "holy_flash_of_light_pct", 78, {
    type = "range",
    name = "Flash of Light %",
    desc = "Use Flash of Light at or below this HP%.",
    min = 1,
    max = 100,
    step = 1
} )

holy:RegisterSetting( "holy_holy_light_pct", 40, {
    type = "range",
    name = "Holy Light %",
    desc = "Use Holy Light at or below this HP%.",
    min = 1,
    max = 100,
    step = 1
} )

ret:RegisterSetting( "ret_enable_twisting", false, {
    type = "toggle",
    name = "Seal Twisting (Experimental)",
    desc = "Optional placeholder toggle for future twisting support."
} )

prot:RegisterPackSelector(
    "tbc_paladin_holy",
    "Paladin_Holy_TBC",
    "Holy Auto Pack",
    "When Holy has the most talent points, use this pack.",
    function( t1, t2, t3 ) return t1 > t2 and t1 > t3 end
)
prot:RegisterPackSelector(
    "tbc_paladin_prot",
    "Paladin_Protection_TBC",
    "Protection Auto Pack",
    "When Protection has the most talent points, use this pack.",
    function( t1, t2, t3 ) return t2 > t1 and t2 > t3 end
)
prot:RegisterPackSelector(
    "tbc_paladin_ret",
    "Paladin_Retribution_TBC",
    "Retribution Auto Pack",
    "When Retribution has the most talent points, use this pack.",
    function( t1, t2, t3 ) return t3 >= t1 and t3 >= t2 end
)

local function payload( specID, name, source, lists )
    return {
        spec = specID,
        source = source,
        author = "Hekili",
        date = 20260228.1,
        name = name,
        lists = lists,
    }
end

local protPack = payload( 66, "Paladin_Protection_TBC", "TBC Anniversary MVP", {
    precombat = {
        { action = "righteous_fury", criteria = "buff.righteous_fury.down", enabled = true },
        { action = "seal_of_righteousness", criteria = "buff.active_seal.down", enabled = true },
    },
    default = {
        { action = "holy_shield", criteria = "buff.holy_shield.down|buff.holy_shield.remains<=gcd", enabled = true },
        { action = "consecration", criteria = "active_enemies>=2&cooldown.consecration.remains<=gcd", enabled = true },
        { action = "judgement", criteria = "cooldown.judgement.remains<=gcd", enabled = true },
        { action = "seal_of_righteousness", criteria = "buff.active_seal.down", enabled = true },
        { action = "crusader_strike", criteria = "cooldown.crusader_strike.remains<=gcd", enabled = true },
        { action = "hammer_of_wrath", criteria = "target.health.pct<=20", enabled = true },
    }
} )

local retPack = payload( 70, "Paladin_Retribution_TBC", "TBC Anniversary MVP", {
    precombat = {
        { action = "seal_of_command", criteria = "buff.active_seal.down", enabled = true },
    },
    default = {
        { action = "judgement", criteria = "cooldown.judgement.remains<=gcd", enabled = true },
        { action = "seal_of_command", criteria = "buff.active_seal.down", enabled = true },
        { action = "crusader_strike", criteria = "cooldown.crusader_strike.remains<=gcd", enabled = true },
        { action = "consecration", criteria = "active_enemies>=2&cooldown.consecration.remains<=gcd", enabled = true },
        { action = "exorcism", criteria = "tbc_target_undead_or_demon&cooldown.exorcism.remains<=gcd", enabled = true },
        { action = "hammer_of_wrath", criteria = "target.health.pct<=20", enabled = true },
    }
} )

local holyPack = payload( 65, "Paladin_Holy_TBC", "TBC Anniversary MVP", {
    precombat = {},
    default = {
        { action = "holy_shock", criteria = "settings.holy_healing_mode&tbc_heal_target_exists&tbc_heal_target_health_pct<=settings.holy_holy_shock_pct&cooldown.holy_shock.remains<=gcd", enabled = true },
        { action = "holy_light", criteria = "settings.holy_healing_mode&tbc_heal_target_exists&tbc_heal_target_health_pct<=settings.holy_holy_light_pct", enabled = true },
        { action = "flash_of_light", criteria = "settings.holy_healing_mode&tbc_heal_target_exists&tbc_heal_target_health_pct<=settings.holy_flash_of_light_pct", enabled = true },
    }
} )

holy:RegisterPackTable( "Paladin_Holy_TBC", 20260228.1, holyPack )
prot:RegisterPackTable( "Paladin_Protection_TBC", 20260228.1, protPack )
ret:RegisterPackTable( "Paladin_Retribution_TBC", 20260228.1, retPack )
