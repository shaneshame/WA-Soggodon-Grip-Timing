function (allstates, event, ...)
  local shouldUseSpellIdOverride = (aura_env.config.enableSpellIdOverride and (aura_env.config.spellIdOverride > 0))
  local shouldUseUnitIdOverride = (aura_env.config.enableUnitIdOverride and (aura_env.config.unitIdOverride > 0))

  local bindingsOfMiseryId = shouldUseSpellIdOverride and aura_env.config.spellIdOverride or 358773
  local soggodonId = shouldUseUnitIdOverride and aura_env.config.unitIdOverride or 179891

  local firstGripDelay = 11.83
  local gripIncrements = 21

  if (event == "UNIT_SPELLCAST_START") then
    local unit, lineId, spellId = ...
    local guid = UnitGUID(unit)
    local npcId = aura_env.getNpcIdFromGUID(guid)

    aura_env.logIf(aura_env.config.logAllCasts, "lineId", lineId)

    if (npcId == soggodonId) then
      aura_env.logCast(guid, spellId)
    end

    if spellId == bindingsOfMiseryId then
      allstates[lineId] = allstates[lineId] or {}
      local state = allstates[lineId]
      state.show = true
      state.changed = true
      state.progressType = "timed"
      state.autoHide = true
      state.changed = true
      state.duration = gripIncrements
      local _, _, icon = GetSpellInfo(bindingsOfMiseryId)
      state.icon = icon
      state.expirationTime = GetTime() + state.duration

      return true
    end
  end

  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    local _, subEvent, _, _, _, _, _, destGUID = ...

    if (subEvent == "UNIT_DIED") then
      local npcId = aura_env.getNpcIdFromGUID(destGUID)

      if (npcId == soggodonId) then
        allstates[destGUID] = allstates[destGUID] or {}
        local state = allstates[destGUID]
        state.show = false
        state.changed = true

        aura_env.writeSoggodonTimingsToFile()

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

      if (npcId == soggodonId) then
        allstates[guid] = allstates[guid] or {}
        local state = allstates[guid]

        if (not aura_env.pulled[guid]) then
          aura_env.logSoggodonEncounterStart(guid)

          state.show = true
          state.changed = true
          state.progressType = "timed"
          state.autoHide = true
          state.duration = firstGripDelay
          local _, _, icon = GetSpellInfo(bindingsOfMiseryId)
          state.icon = icon
          state.expirationTime = GetTime() + state.duration

          aura_env.pulled[guid] = true

          return true
        end
      end
    end
  elseif (event == "ENCOUNTER_END" or event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_DEAD") then
    aura_env.clearAllKeys(aura_env.pulled)
  end
end
