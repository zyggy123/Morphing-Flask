-- ============================================
-- Morphing Flask System - AzerothCore / Eluna
-- With Visual Buff, Right-Click Cancel & RANDOM MORPHS
-- ============================================

local FLASK_ITEM       = 900001
local RECHARGER_ITEM   = 900002
local REAGENT_ITEM     = 34054   
local REAGENT_COST     = 3       
local MAX_CHARGES      = 5       
local MORPH_DURATION   = 1800    -- 30 minutes in seconds
local BUFF_SPELL_ID    = 16739   -- "Disguise" (Foarte stabil, nu dispare singur)

-- ============================================
-- ADD YOUR DISPLAY IDs HERE
-- ============================================
local MORPH_DISPLAY_IDS = {
    29229, -- Iron Dwarf (original)
    20318, -- Murloc
    21228, -- Fel Orc
    19724, -- Blood Elf
    22917, -- Skeleton
    19692, -- Custom addition
    2676,  -- Custom addition
    3887   -- Custom addition
}

local playerCharges  = {}
local playerTimers   = {}
local activeMorphs   = {} 

local function GetCharges(player)
    local guid = player:GetGUIDLow()
    if playerCharges[guid] == nil then
        playerCharges[guid] = 0
    end
    return playerCharges[guid]
end

local function SetCharges(player, charges)
    local guid = player:GetGUIDLow()
    playerCharges[guid] = charges
end

-- ============================================
-- Timer Monitor (Buff Observer Loop)
-- ============================================

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

-- ============================================
-- FLASK (900001) - Activate / Deactivate
-- ============================================

local function OnFlaskUse(event, player, item, target)
    local guid    = player:GetGUIDLow()
    local charges = GetCharges(player)

    -- If the player already has the buff, remove it. 
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

    -- Apply the visual buff and capture it directly
    local aura = player:AddAura(BUFF_SPELL_ID, player)
    
    -- Fortam atat durata curenta, cat si durata maxima
    if aura then
        aura:SetMaxDuration(MORPH_DURATION * 1000)
        aura:SetDuration(MORPH_DURATION * 1000)
    end

    player:SetDisplayId(chosenMorph)
    StartMorphTimer(player)
    SetCharges(player, charges - 1)

    player:SendBroadcastMessage("|cff00ff00[Morphing Flask]|r Transformation activated! (30 minutes)")
    player:SendBroadcastMessage("|cff00ff00[Morphing Flask]|r Charges remaining: |cffffd700" .. (charges - 1) .. "/" .. MAX_CHARGES .. "|r")

    return false
end

-- ============================================
-- RECHARGER (900002) - Recharge with Infinite Dust
-- ============================================

local function OnRechargerUse(event, player, item, target)
    local charges   = GetCharges(player)
    local dustCount = player:GetItemCount(REAGENT_ITEM, false)

    if charges >= MAX_CHARGES then
        player:SendBroadcastMessage("|cffff9900[Flask Recharger]|r The flask is already full!")
        player:SendBroadcastMessage("|cffff9900[Flask Recharger]|r Charges: |cffffd700" .. MAX_CHARGES .. "/" .. MAX_CHARGES .. "|r")
        return false
    end

    if dustCount < REAGENT_COST then
        player:SendBroadcastMessage("|cffff0000[Flask Recharger]|r You don't have enough Infinite Dust!")
        player:SendBroadcastMessage("|cffff0000[Flask Recharger]|r You have |cffffd700" .. dustCount .. "|r, you need |cffffd700" .. REAGENT_COST .. "x|r per charge.")
        return false
    end

    local freeSlots      = MAX_CHARGES - charges
    local maxFromDust    = math.floor(dustCount / REAGENT_COST)
    local toAdd          = math.min(freeSlots, maxFromDust)
    local dustToConsume  = toAdd * REAGENT_COST

    player:RemoveItem(REAGENT_ITEM, dustToConsume)
    SetCharges(player, charges + toAdd)

    player:SendBroadcastMessage("|cff00ff00[Flask Recharger]|r Recharged successfully!")
    player:SendBroadcastMessage("|cff00ff00[Flask Recharger]|r |cffffd700+" .. toAdd .. " charges|r using |cff00ccff" .. dustToConsume .. "x Infinite Dust|r.")
    player:SendBroadcastMessage("|cff00ccff[Flask Recharger]|r Charges now: |cffffd700" .. (charges + toAdd) .. "/" .. MAX_CHARGES .. "|r")

    return false
end

-- ============================================
-- Login / Logout Events
-- ============================================

local function OnPlayerLogin(event, player)
    local guid = player:GetGUIDLow()
    
    if player:HasAura(BUFF_SPELL_ID) then
        if not activeMorphs[guid] then
            activeMorphs[guid] = MORPH_DISPLAY_IDS[math.random(1, #MORPH_DISPLAY_IDS)]
        end
        
        player:SetDisplayId(activeMorphs[guid])
        StartMorphTimer(player)
    end
end

local function OnPlayerLogout(event, player)
    local guid = player:GetGUIDLow()
    StopMorphTimer(guid)
    playerCharges[guid] = nil
end

RegisterItemEvent(FLASK_ITEM,     2, OnFlaskUse)
RegisterItemEvent(RECHARGER_ITEM, 2, OnRechargerUse)

RegisterPlayerEvent(3, OnPlayerLogin)  
RegisterPlayerEvent(4, OnPlayerLogout)