local addon, ns = ...

local ranksByName = {}
local spellbookReady = false

local function parseRank( rankText )
    if type( rankText ) ~= "string" then return 0 end
    local rank = rankText:match( "(%d+)" )
    return tonumber( rank ) or 0
end

local function rememberSpell( name, spellID, rank )
    if not name or not spellID then return end

    local data = ranksByName[ name ]
    if not data then
        data = {
            ids = {},
            bestID = spellID,
            bestRank = rank or 0
        }
        ranksByName[ name ] = data
    end

    data.ids[ spellID ] = true

    rank = rank or 0
    if rank > data.bestRank or ( rank == data.bestRank and spellID > data.bestID ) then
        data.bestRank = rank
        data.bestID = spellID
    end
end

function ns.ScanSpellbookRanks()
    wipe( ranksByName )

    if not _G.GetNumSpellTabs or not _G.GetSpellTabInfo then
        return
    end

    local tabs = GetNumSpellTabs()
    for tab = 1, tabs do
        local _, _, offset, numSlots = GetSpellTabInfo( tab )
        if offset and numSlots then
            for i = 1, numSlots do
                local idx = offset + i
                local spellType, spellID = GetSpellBookItemInfo( idx, BOOKTYPE_SPELL )
                if spellType == "SPELL" and spellID then
                    local name, rankText = GetSpellBookItemName( idx, BOOKTYPE_SPELL )
                    rememberSpell( name, spellID, parseRank( rankText ) )
                end
            end
        end
    end

    spellbookReady = true
end

function ns.GetKnownSpellIDsByName( name )
    if not spellbookReady then ns.ScanSpellbookRanks() end
    local data = ranksByName[ name ]
    return data and data.ids or nil
end

function ns.GetBestKnownSpellIDByName( name )
    if not spellbookReady then ns.ScanSpellbookRanks() end
    local data = ranksByName[ name ]
    return data and data.bestID or nil
end

if _G.CreateFrame then
    local f = CreateFrame( "Frame" )
    f:RegisterEvent( "PLAYER_LOGIN" )
    f:RegisterEvent( "SPELLS_CHANGED" )
    f:RegisterEvent( "LEARNED_SPELL_IN_TAB" )
    f:SetScript( "OnEvent", function()
        ns.ScanSpellbookRanks()
    end )
end
