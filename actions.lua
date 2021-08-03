-- Util

local clearAllKeys = function(t)
  for key, _ in pairs(t) do
   t[key] = nil
  end
end

local getNpcIdFromGUID = function(guidTarget)
  local idString = select(6, strsplit("-", guidTarget))
  return tonumber(idString)
end

local logIf = function(predicate, ...)
  if (predicate) then
    print(...)
    print("-----")
  end
end

local logSoggodonEncounterStart = function(guid)
  local tLog = aura_env.timingLog or {}
  local guidLog = tLog[guid] or {}

  if (not guidLog.threatListUpdate) then
    guidLog.threatListUpdate = GetTime()
    guidLog.npcId = getNpcIdFromGUID(guid)
  end

  tLog[guid] = guidLog
end

local logCast = function(guid, spellId)
  local tLog = aura_env.timingLog or {}
  local guidLog = tLog[guid] or {}
  local casts = guidLog.casts or {}
  local spellCasts = casts[spellId] or {}
  local time = GetTime()

  spellCasts[time] = true

  casts[spellId] = spellCasts
  guidLog.casts = casts
  tLog[guid] = guidLog
end

local writeSoggodonTimingsToFile = function()
  local tLog = aura_env.timingLog or {}

  print("Writing to file.", tLog)
  WeakAurasSaved["displays"]["Soggodon Grip"]["SOGGODON_TIMING"] = tLog
end

-- Assignments

aura_env.pulled = {}
aura_env.timingLog = {}

aura_env.clearAllKeys = clearAllKeys
aura_env.getNpcIdFromGUID = getNpcIdFromGUID
aura_env.logIf = logIf
aura_env.logSoggodonEncounterStart = logSoggodonEncounterStart
aura_env.logCast = logCast
aura_env.writeSoggodonTimingsToFile = writeSoggodonTimingsToFile

-- Notes

-- aura_env.soggodonId = 170383 -- Goldenback Drifter for testing
-- aura_env.bindingsOfMiseryId = 319224 -- Soulwing Monarh for testing
-- 324444
