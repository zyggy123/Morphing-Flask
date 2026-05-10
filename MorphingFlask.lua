-- ============================================
-- Morphing Flask System - AzerothCore / Eluna
-- With Visual Buff, Right-Click Cancel & RANDOM MORPHS
-- ============================================

-- Configuration
local FLASK_ITEM       = 900001
local RECHARGER_ITEM   = 900002
local REAGENT_ITEM     = 34054   -- Item required to recharge (Infinite Dust)
local REAGENT_COST     = 3       -- Dust needed per charge
local MAX_CHARGES      = 5       
local MORPH_DURATION   = 1800    -- Duration in seconds (30 min)
local BUFF_SPELL_ID    = 16739   

-- Random Appearances List
local MORPH_DISPLAY_IDS = {
    29229, -- Iron Dwarf
    20318, -- Murloc
    21228, -- Fel Orc
    19724, -- Blood Elf
    22917, -- Skeleton
    19692, -- Custom NPC 1
    2676,  -- Custom NPC 2
    3887   -- Custom NPC 3
}

-- RAM storage
local playerCharges  = {}
local playerTimers   = {}
local activeMorphs   = {} 

-- Helper Functions
local function GetCharges(player)
    local guid = player:GetGUIDLow()
    if playerCharges[guid] == nil then playerCharges[guid] = 0 end
    return playerCharges[guid]
end

local function SetCharges(player, charges)
    local guid = player:GetGUIDLow()
    playerCharges[guid] = charges
end

-- Timer Observer
local function StopMorphTimer(guid)
    if playerTimers[guid] then
        RemoveEventById(playerTimers[guid])
        playerTimers[guid] = nil
    end
end

local function StartMorphTimer(player)
    local guid = player:GetGUIDLow()
    StopMorphTimer(guid)

    playerTimers[guid] = CreateLuaEvent(function(eventId, delay, repeats)
        local p = GetPlayerByGUID(guid)
        if p and p:IsInWorld() then
            if not p:HasAura(BUFF_SPELL_ID) then
                p:DeMorph() 
                activeMorphs[guid] = nil 
                p:SendBroadcastMessage("|cffff9900[Morphing Flask]|r Your transformation has ended.")
                RemoveEventById(eventId)
                playerTimers[guid] = nil
            end
        else
            RemoveEventById(eventId)
            playerTimers[guid] = nil
        end
    end, 500, 0)
end

-- Item: Morphing Flask
local function OnFlaskUse(event, player, item, target)
    local guid    = player:GetGUIDLow()
    local charges = GetCharges(player)

    if player:HasAura(BUFF_SPELL_ID) then
        player:RemoveAura(BUFF_SPELL_ID)
        activeMorphs[guid] = nil
        player:SendBroadcastMessage("|cffff4444[Morphing Flask]|r Transformation deactivated.")
        return false
    end

    if charges <= 0 then
        player:SendBroadcastMessage("|cffff0000[Morphing Flask]|r You have no charges left!")
        player:SendBroadcastMessage("|cffff0000[Morphing Flask]|r Use |cff00ff00Flask Recharger|r with " .. REAGENT_COST .. "x Infinite Dust.")
        return false
    end

    local randomIndex = math.random(1, #MORPH_DISPLAY_IDS)
    local chosenMorph = MORPH_DISPLAY_IDS[randomIndex]
    activeMorphs[guid] = chosenMorph

    local aura = player:AddAura(BUFF_SPELL_ID, player)
    if aura then
        aura:SetMaxDuration(MORPH_DURATION * 1000)
        aura:SetDuration(MORPH_DURATION * 1000)
    end

    player:SetDisplayId(chosenMorph)
    StartMorphTimer(player)
    SetCharges(player, charges - 1)

    player:SendBroadcastMessage("|cff00ff00[Morphing Flask]|r Transformation activated! (30 minutes)")
    player:SendBroadcastMessage("|cff00ff00[Morphing Flask]|r Charges: |cffffd700" .. (charges - 1) .. "/" .. MAX_CHARGES .. "|r")

    return false
end

-- Item: Flask Recharger
local function OnRechargerUse(event, player, item, target)
    local charges   = GetCharges(player)
    local dustCount = player:GetItemCount(REAGENT_ITEM, false)

    if charges >= MAX_CHARGES then
        player:SendBroadcastMessage("|cffff9900[Flask Recharger]|r The flask is already full!")
        return false
    end

    if dustCount < REAGENT_COST then
        player:SendBroadcastMessage("|cffff0000[Flask Recharger]|r You need at least " .. REAGENT_COST .. "x Infinite Dust.")
        return false
    end

    local freeSlots      = MAX_CHARGES - charges
    local maxFromDust    = math.floor(dustCount / REAGENT_COST)
    local toAdd          = math.min(freeSlots, maxFromDust)
    local dustToConsume  = toAdd * REAGENT_COST

    player:RemoveItem(REAGENT_ITEM, dustToConsume)
    SetCharges(player, charges + toAdd)

    player:SendBroadcastMessage("|cff00ff00[Flask Recharger]|r Recharged! |cffffd700+" .. toAdd .. " charges|r.")
    return false
end

-- Events
RegisterItemEvent(FLASK_ITEM,     2, OnFlaskUse)
RegisterItemEvent(RECHARGER_ITEM, 2, OnRechargerUse)

RegisterPlayerEvent(3, function(event, player) -- Login
    local guid = player:GetGUIDLow()
    if player:HasAura(BUFF_SPELL_ID) then
        if not activeMorphs[guid] then activeMorphs[guid] = MORPH_DISPLAY_IDS[math.random(1, #MORPH_DISPLAY_IDS)] end
        player:SetDisplayId(activeMorphs[guid])
        StartMorphTimer(player)
    end
end)

RegisterPlayerEvent(4, function(event, player) -- Logout
    StopMorphTimer(player:GetGUIDLow())
    playerCharges[player:GetGUIDLow()] = nil
end)
