local addon, ns = ...
local Hekili = _G[ addon ]

if not Hekili.IsTBC() then return end

local class, state = Hekili.Class, Hekili.State

local RegisterEvent = ns.RegisterEvent

function ns.updateTalents()
    for _, tal in pairs( state.talent ) do
        tal.enabled = false
        tal.rank = 0
    end

    for k, v in pairs( class.talents ) do
        local maxRank = v[ 2 ]
        local talent = rawget( state.talent, k ) or {}
        talent.enabled = false
        talent.rank = 0

        for i = #v, 3, -1 do
            local spellID = v[ i ]
            if IsPlayerSpell( spellID ) then
                talent.enabled = true
                talent.rank = i - 2
                break
            end
        end

        if not talent.enabled and maxRank == 1 and IsPlayerSpell( v[ 3 ] ) then
            talent.enabled = true
            talent.rank = 1
        end

        state.talent[ k ] = talent
    end

    local spec = state.spec.id
    if not spec or not Hekili.DB.profile.specs[ spec ] or not Hekili.DB.profile.specs[ spec ].usePackSelector then
        return
    end

    local tab1, tab2, tab3 = unpack( ns.Compat.GetTalentTabPoints() )
    local fromPackage = Hekili.DB.profile.specs[ spec ].package

    for _, selector in ipairs( class.specs[ spec ].packSelectors ) do
        local toPackage = Hekili.DB.profile.specs[ spec ].autoPacks[ selector.key ] or "none"
        if not rawget( Hekili.DB.profile.packs, toPackage ) then toPackage = "none" end

        local cond = selector.condition
        local matched = false

        if type( cond ) == "function" then
            matched = cond( tab1, tab2, tab3 )
        elseif type( cond ) == "number" then
            matched =
                ( cond == 1 and tab1 > math.max( tab2, tab3 ) ) or
                ( cond == 2 and tab2 > math.max( tab1, tab3 ) ) or
                ( cond == 3 and tab3 > math.max( tab1, tab2 ) )
        end

        if matched then
            if toPackage ~= "none" and fromPackage ~= toPackage then
                Hekili.DB.profile.specs[ spec ].package = toPackage
                C_Timer.After( Hekili.PLAYER_ENTERING_WORLD and 0 or 2, function()
                    Hekili:Notify( toPackage .. " priority activated." )
                end )
            end
            break
        end
    end
end

RegisterEvent( "PLAYER_TALENT_UPDATE", function()
    ns.updateTalents()
    Hekili:SpecializationChanged()
end )
