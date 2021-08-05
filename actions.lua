-- Constants

aura_env.WA_NAME = "Soggodon Grip"
aura_env.WA_LOG_KEY = "TIMING_LOG"

local GOLDEN_DRIFTER_ID = 170383
local MONARCH_ID = 170336
local MONARCH_SPELL = 319224
local SPIRITED_SKYMANE = 170247

-- Soggodon
aura_env.SOGGODON_REAL_ID = 179891
aura_env.BINDINGS_OF_MISERY_REAL_ID = 358773
aura_env.MASSIVE_SMASH_REAL_ID = 355806
aura_env.FIRST_GRIP_DELAY = 11.83
aura_env.GRIP_INCREMENT = 20.63

-- Oros
aura_env.OROS_REAL_ID = 179892
aura_env.FROST_LANCE = 356414

-- Incinerator
aura_env.INFERNO = 358967
aura_env.SCORCHING_BLAST = 355737
aura_env.INCINERATOR_REAL_ID = 179446

-- Varruth
aura_env.FEAR = 358971
aura_env.VARRUTH_REAL_ID = 179890


aura_env.TRACKED_MOBS_DEFAULTS = {
    [MONARCH_ID] = {
        ["npcId"] = MONARCH_ID,
        ["trackedCasts"] = {
            [MONARCH_SPELL] = {
                ["firstCastDelay"] = 5,
                ["spellCooldown"] = 10
            }
        }
    },
    [aura_env.SOGGODON_REAL_ID] = {
        ["npcId"] = aura_env.SOGGODON_REAL_ID,
        ["trackedCasts"] = {
            [aura_env.BINDINGS_OF_MISERY_REAL_ID] = {
                ["firstCastDelay"] = aura_env.FIRST_GRIP_DELAY,
                ["spellCooldown"] = aura_env.GRIP_INCREMENT
            }
        }
    },
    [aura_env.OROS_REAL_ID] = {
        ["npcId"] = aura_env.OROS_REAL_ID,
        ["trackedCasts"] = {
            [aura_env.FROST_LANCE] = {
                ["firstCastDelay"] = 8.3,
                ["spellCooldown"] = 17
            }
        }
    },
    [aura_env.INCINERATOR_REAL_ID] = {
        ["npcId"] = aura_env.INCINERATOR_REAL_ID,
        ["trackedCasts"] = {
            [aura_env.INFERNO] = {
                ["firstCastDelay"] = 6.33,
                ["spellCooldown"] = 10.9
            },
            [aura_env.SCORCHING_BLAST] = {
                ["firstCastDelay"] = 8.77,
                ["spellCooldown"] = 12.15
            }
        },
    },
    [aura_env.VARRUTH_REAL_ID] = {
        ["npcId"] = aura_env.VARRUTH_REAL_ID,
        ["trackedCasts"] = {
            [aura_env.FEAR] = {
                ["firstCastDelay"] = 10.9,
                ["spellCooldown"] = 19.4
            }
        }
    },
}

aura_env.SPELL_IDS_TO_DISPLAY_TEXT = {
    [aura_env.FEAR] = aura_env.config.varruthFearText or "FEAR",
    [aura_env.BINDINGS_OF_MISERY_REAL_ID] = aura_env.config.soggodonGripText or "GRIP",
    [aura_env.FROST_LANCE] = aura_env.config.orosLanceText or "FRONTAL",
    [aura_env.SCORCHING_BLAST] = aura_env.config.incineratorBlastText or "DODGE",
    [aura_env.INFERNO] = aura_env.config.incineratorInfernoText or "INTERRUPT",
    [MONARCH_SPELL] = "MONARRACH",
}

aura_env.SPELL_IDS_TO_BAR_COLOR = {
    [aura_env.FEAR] = aura_env.config.varruthFearColor,
    [aura_env.BINDINGS_OF_MISERY_REAL_ID] = aura_env.config.soggodonGripColor,
    [aura_env.FROST_LANCE] = aura_env.config.orosLanceColor,
    [aura_env.SCORCHING_BLAST] = aura_env.config.incineratorBlastColor,
    [aura_env.INFERNO] = aura_env.config.incineratorInfernoColor,
    [MONARCH_SPELL] = aura_env.config.varruthFearColor,
}

-- Util

local buildPath = function(...)
    local t = {...}
    return table.concat(t, "/")
end

local startsWith = function(str, pattern)
    return str:find(pattern, 1, true) == 1
end

local getSpellIcon = function(spellId)
    local _, _, icon = GetSpellInfo(spellId)
    print('Icon Id: ', icon)

    return icon
end

local getPairs = function(tableA)
    local result = {}

    for key, value in pairs(tableA) do
        local p = {key, value}
        table.insert(result, p)
    end

    return result
end

local mergeTables = function(tableA, tableB)
    for k, v in pairs(tableB) do
        tableA[k] = v
    end

    return tableA
end

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

local logEncounterStart = function(guid)
    local tLog = aura_env.timingLog
    local guidLog = tLog[guid] or {}

    if (not guidLog.threatListUpdate) then
        guidLog.threatListUpdate = GetTime()
        guidLog.npcId = getNpcIdFromGUID(guid)
    end

    tLog[guid] = guidLog
end

local logCast = function(guid, spellId)
    print('Logging cast: ', spellId)
    local tLog = aura_env.timingLog
    local guidLog = tLog[guid] or {}
    local casts = guidLog.casts or {}
    local spellCasts = casts[spellId] or {}
    local time = GetTime()

    spellCasts[time] = true

    casts[spellId] = spellCasts
    guidLog.casts = casts
    tLog[guid] = guidLog
end

local writeTimingsToFile = function()
    local tLog = aura_env.timingLog

    print("Updating WeakAurasSaved", aura_env.WA_NAME, aura_env.WA_LOG_KEY)
    -- WeakAurasSaved["displays"][aura_env.WA_NAME][aura_env.WA_LOG_KEY] = tLog
end

local startFirstCastDelayBars = function(allstates, guid)
    local npcId = aura_env.getNpcIdFromGUID(guid)
    local mobTrackingData = aura_env.trackedMobs[npcId]

    if (not mobTrackingData.trackedCasts) then
        return
    end

    local mobCasts = aura_env.getPairs(mobTrackingData.trackedCasts)

    for _, castData in pairs(mobCasts) do
        local spellId = castData[1]
        local castTimings = castData[2]

        local stateKey = aura_env.buildPath(guid, spellId)

        allstates[stateKey] = allstates[stateKey] or {}
        local state = allstates[stateKey]

        aura_env.setStateSpellColor(state, spellId)

        state.autoHide = true
        state.changed = true
        state.displayText = aura_env.SPELL_IDS_TO_DISPLAY_TEXT[spellId]
        state.duration = castTimings.firstCastDelay
        state.expirationTime = GetTime() + castTimings.firstCastDelay
        state.icon = aura_env.getSpellIcon(spellId)
        state.progressType = "timed"
        state.show = true

        allstates[stateKey] = state
    end
end

local startTrackedCastBars = function(allstates, guid, castId)
    local npcId = aura_env.getNpcIdFromGUID(guid)
    local mobTrackingData = aura_env.trackedMobs[npcId]

    if (not mobTrackingData.trackedCasts) then
        return
    end

    local mobCasts = aura_env.getPairs(mobTrackingData.trackedCasts)

    for _, castData in pairs(mobCasts) do
        local spellId = castData[1]
        local castTimings = castData[2]

        allstates[castId] = allstates[castId] or {}
        local state = allstates[castId]

        aura_env.setStateSpellColor(state, spellId)

        state.autoHide = true
        state.changed = true
        state.displayText = aura_env.SPELL_IDS_TO_DISPLAY_TEXT[spellId]
        state.duration = castTimings.spellCooldown
        state.expirationTime = GetTime() + castTimings.spellCooldown
        state.icon = aura_env.getSpellIcon(spellId)
        state.progressType = "timed"
        state.show = true
    end
end

local stopTrackedCastBars = function(allstates, guid)
    for key, _ in pairs(allstates) do
        if (startsWith(key, guid)) then
            allstates[key] = allstates[key] or {}
            local state = allstates[key]
            state.changed = true
            state.show = false
        end
    end
end

local initTrackedMobs = function(overrides)
    local trackedMobs = {}

    if (overrides) then
        trackedMobs = mergeTables(aura_env.TRACKED_MOBS_DEFAULTS, overrides)
    else
        trackedMobs = aura_env.TRACKED_MOBS_DEFAULTS
    end

    aura_env.trackedMobs = trackedMobs
end

local createTestBar = function(allstates, key, duration)
    allstates[key] = allstates[key] or {}
    local state = allstates[key]

    state.autoHide = true
    state.changed = true
    state.duration = duration
    state.expirationTime = GetTime() + duration
    state.icon = aura_env.getSpellIcon(spellId)
    state.progressType = "timed"
    state.show = true
end

local setStateSpellColor = function(state, spellId)
    local color = aura_env.SPELL_IDS_TO_BAR_COLOR[spellId]
    local red = color[1]
    local green = color[2]
    local blue = color[3]
    local alpha = color[4]

    state.red = red
    state.green = green
    state.blue = blue
    state.alpha = alpha
end

-- Assignments

aura_env.pulled = {}
aura_env.timingLog = {}
-- aura_env.timingLog = WeakAurasSaved["displays"][aura_env.WA_NAME][aura_env.WA_LOG_KEY] or {}

aura_env.createTestBar = createTestBar
aura_env.buildPath = buildPath
aura_env.clearAllKeys = clearAllKeys
aura_env.getPairs = getPairs
aura_env.getNpcIdFromGUID = getNpcIdFromGUID
aura_env.getSpellIcon = getSpellIcon
aura_env.logIf = logIf
aura_env.logEncounterStart = logEncounterStart
aura_env.logCast = logCast
aura_env.setStateSpellColor = setStateSpellColor
aura_env.startFirstCastDelayBars = startFirstCastDelayBars
aura_env.startTrackedCastBars = startTrackedCastBars
aura_env.stopTrackedCastBars = stopTrackedCastBars
aura_env.writeTimingsToFile = writeTimingsToFile

aura_env.initTrackedMobs = initTrackedMobs

-- Notes

-- aura_env.soggodonId = 170383 -- Goldenback Drifter for testing
-- aura_env.bindingsOfMiseryId = 319224 -- Soulwing Monarh for testing
-- 324444
