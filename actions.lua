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

local logSoggodonEncounterStart = function()
  local tLog = aura_env.timingLog or {}
  local soggodonTiming = tLog.soggodonTiming or {}

  if (not soggodonTiming.threatListUpdate) then
    soggodonTiming.threatListUpdate = GetTime()
  end

  tLog.soggodonTiming = soggodonTiming
end

local logSoggodonBindingsCast = function()
  local tLog = aura_env.timingLog or {}
  local soggodonTiming = tLog.soggodonTiming or {}

  local bindingsOfMiseryCasts = soggodonTiming.bindingsOfMiseryCasts or {}

  table.insert(bindingsOfMiseryCasts, GetTime())

  soggodonTiming.bindingsOfMiseryCasts = bindingsOfMiseryCasts
  tLog.soggodonTiming = soggodonTiming
end

local writeSoggodonTimingsToFile = function()
  local tLog = aura_env.timingLog or {}
  local soggodonTiming = tLog.soggodonTiming or {}

  print("Writing to file.", soggodonTiming)
  WeakAurasSaved["displays"]["Soggodon Grip"]["SOGGODON_TIMING"] = soggodonTiming
end

aura_env.pulled = {}
aura_env.timingLog = {}

aura_env.getNpcIdFromGUID = getNpcIdFromGUID
aura_env.logIf = logIf
aura_env.logSoggodonEncounterStart = logSoggodonEncounterStart
aura_env.logSoggodonBindingsCast = logSoggodonBindingsCast
aura_env.writeSoggodonTimingsToFile = writeSoggodonTimingsToFile

-- aura_env.soggodonId = 170383 -- Goldenback Drifter for testing
-- aura_env.bindingsOfMiseryId = 319224 -- Soulwing Monarh for testing
-- 324444
