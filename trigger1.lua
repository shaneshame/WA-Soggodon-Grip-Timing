function (allstates, event, ...)
    local defaultEnemyId = aura_env.SOGGODON_REAL_ID
    local defaultSpellId = aura_env.MASSIVE_SMASH_REAL_ID

    local shouldUseUnitIdOverride = (aura_env.config.enableUnitIdOverride and (aura_env.config.unitIdOverride > 0))
    local shouldUseSpellIdOverride = (aura_env.config.enableSpellIdOverride and (aura_env.config.spellIdOverride > 0))

    local soggodonId = shouldUseUnitIdOverride and aura_env.config.unitIdOverride or defaultEnemyId
    local bindingsOfMiseryId = shouldUseSpellIdOverride and aura_env.config.spellIdOverride or defaultSpellId

    local trackedOverrides = {
        [soggodonId] = {
            ["npcId"] = soggodonId,
            ["trackedCasts"] = {
                [bindingsOfMiseryId] = {
                    ["firstCastDelay"] = aura_env.FIRST_GRIP_DELAY,
                    ["spellCooldown"] = aura_env.GRIP_INCREMENT
                }
            }
        }
    }

    aura_env.initTrackedMobs(trackedOverrides)

    if (event == "UNIT_SPELLCAST_START") then
        local unit, castId, spellId = ...
        local guid = UnitGUID(unit)
        local npcId = aura_env.getNpcIdFromGUID(guid)

        aura_env.logIf(aura_env.config.logAllCasts, "castId", castId)

        local mobTracking = aura_env.trackedMobs[npcId]

        if (mobTracking) then
            aura_env.logCast(guid, spellId)

            local trackedCasts = mobTracking.trackedCasts

            if (trackedCasts) then
                local isTrackingCast = trackedCasts[spellId]

                if (isTrackingCast) then
                    aura_env.startTrackedCastBars(allstates, guid, castId)
                    return true
                end
            end
        end
    end

    if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
        local _, subEvent, _, _, _, _, _, destGUID = ...

        if (subEvent == "UNIT_DIED") then
            local npcId = aura_env.getNpcIdFromGUID(destGUID)

            local isTrackingMob = aura_env.trackedMobs[npcId]

            if (isTrackingMob) then
                aura_env.stopTrackedCastBars(allstates, destGUID)

                aura_env.writeTimingsToFile()

                return true
            end
        end
    end

    if (event == "UNIT_THREAT_LIST_UPDATE" and InCombatLockdown()) then
        local unit = ...
        local guid = UnitGUID(unit)

        if (guid) then
            aura_env.logIf(aura_env.config.logAllThreats, "[UNIT_THREAT_LIST_UPDATE]", guid)

            local npcId = aura_env.getNpcIdFromGUID(guid)
            local trackedMob = aura_env.trackedMobs[npcId]

            if (trackedMob) then
                if (not aura_env.pulled[guid]) then
                    aura_env.pulled[guid] = true
                    aura_env.logEncounterStart(guid)
                    aura_env.startFirstCastDelayBars(allstates, guid)

                    return true
                end
            end
        end
    elseif (event == "ENCOUNTER_END" or event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_DEAD") then
        aura_env.clearAllKeys(aura_env.pulled)
    end
end
