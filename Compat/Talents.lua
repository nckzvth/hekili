local addon, ns = ...
local Hekili = _G[ addon ]

ns.Compat = ns.Compat or {}

function ns.Compat.GetTalentTabPoints()
    local points = { 0, 0, 0 }

    if not _G.GetTalentTabInfo then
        return points
    end

    for i = 1, 3 do
        points[ i ] = select( 3, GetTalentTabInfo( i ) ) or 0
    end

    return points
end

function ns.Compat.GetTBCPaladinSpecID()
    local t = ns.Compat.GetTalentTabPoints()
    local bestTab, bestPoints = 1, -1

    for i = 1, 3 do
        if t[ i ] > bestPoints then
            bestTab = i
            bestPoints = t[ i ]
        end
    end

    if bestTab == 1 then return 65, "Holy", "HEALER" end
    if bestTab == 2 then return 66, "Protection", "TANK" end
    return 70, "Retribution", "DAMAGER"
end

function ns.Compat.GetTBCSpecialization()
    local _, classFile = UnitClass( "player" )

    if classFile == "PALADIN" then
        return ns.Compat.GetTBCPaladinSpecID()
    end

    local classID = select( 3, UnitClass( "player" ) )
    local className = UnitClass( "player" )
    return classID, className, "DAMAGER"
end
