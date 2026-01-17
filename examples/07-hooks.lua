-- ============================================
-- 7. HOOKS & INTERCEPTORS
-- ============================================

-- 7.1: Simple before hook
hook("beforeMove", function(data)
  print("About to move to " .. data.x .. ", " .. data.y)
  return data
end)

-- 7.2: Before hook modifying data
hook("beforeMove", function(data)
  if data.x < 0 then
    data.x = 0
  end
  return data
end)

-- 7.3: Validation hook
hook("beforeMove", function(data)
  if getVariable("frozen") then
    return nil -- Cancel movement
  end
  return data
end)

-- 7.4: After hook
hook("afterMove", function(data)
  print("Moved to " .. data.x .. ", " .. data.y)
  emit("position.changed", data)
  return data
end)

-- 7.5: Hook with condition
hook("beforeAttack", function(data)
  if getVariable("mana") < 10 then
    print("Not enough mana!")
    return nil
  end
  setVariable("mana", getVariable("mana") - 10)
  return data
end)

-- 7.6: Hook for input validation
hook("beforeSaveGame", function(data)
  if data.playerName == "" then
    print("Player name cannot be empty")
    return nil
  end
  return data
end)

-- 7.7: Hook for logging
hook("beforeAction", function(data)
  print("[LOG] Action: " .. data.action .. " at " .. os.time())
  return data
end)

-- 7.8: Hook for cost deduction
hook("beforeSpellCast", function(data)
  local cost = data.cost or 10
  if getVariable("energy") < cost then
    print("Not enough energy!")
    return nil
  end
  setVariable("energy", getVariable("energy") - cost)
  return data
end)

-- 7.9: Chained hooks
hook("beforeDamage", function(data)
  -- First modification
  data.amount = data.amount * 1.5
  return data
end)

hook("beforeDamage", function(data)
  -- Second modification
  if getVariable("hasBuff") then
    data.amount = data.amount * 2
  end
  return data
end)

-- 7.10: Hook for armor reduction
hook("beforeTakeDamage", function(data)
  local armor = getVariable("armor")
  local reduction = armor * 0.1
  data.amount = data.amount - reduction
  if data.amount < 1 then
    data.amount = 1
  end
  return data
end)

-- 7.11: Hook for critical strike
hook("beforeAttack", function(data)
  local crit = math.random(1, 100)
  if crit <= 25 then
    data.isCritical = true
    data.damage = data.damage * 2
  end
  return data
end)

-- 7.12: Hook preventing action
hook("beforeCollect", function(data)
  if getVariable("inventoryFull") then
    print("Inventory is full!")
    return nil
  end
  return data
end)

-- 7.13: Hook for level progression
hook("beforeLevelUp", function(data)
  setVariable("level", getVariable("level") + 1)
  setVariable("health", 100)
  setVariable("mana", 100)
  return data
end)

-- 7.14: Hook for state transitions
hook("beforeStateChange", function(data)
  local currentState = getVariable("state")
  print("Changing from " .. currentState .. " to " .. data.newState)
  return data
end)

-- 7.15: Hook for time tracking
hook("beforeGameStart", function(data)
  setVariable("startTime", os.time())
  return data
end)

-- 7.16: Hook for combo system
hook("afterHit", function(data)
  setVariable("comboCount", getVariable("comboCount") + 1)
  if getVariable("comboCount") >= 10 then
    emit("combo.milestone", { count = 10 })
  end
  return data
end)

-- 7.17: Hook for debuff application
hook("afterTakeDamage", function(data)
  if math.random(1, 100) <= 30 then
    setVariable("isSlowed", true)
  end
  return data
end)

-- 7.18: Hook for recovery
hook("afterRest", function(data)
  setVariable("health", 100)
  setVariable("mana", 100)
  return data
end)

-- 7.19: Hook for conditional action
hook("beforeTeleport", function(data)
  if getVariable("lastPosition") then
    data.fromX = getVariable("lastPosition").x
    data.fromY = getVariable("lastPosition").y
  end
  setVariable("lastPosition", { x = data.x, y = data.y })
  return data
end)

-- 7.20: Hook for quest progress
hook("afterKillEnemy", function(data)
  setVariable("enemiesKilled", getVariable("enemiesKilled") + 1)
  if getVariable("questActive") then
    local progress = getVariable("questProgress") + 1
    setVariable("questProgress", progress)
    if progress >= getVariable("questTarget") then
      emit("quest.complete", {})
    end
  end
  return data
end)

-- 7.21: Hook preventing overlap
hook("beforeMoveEntity", function(data)
  local x = data.x
  local y = data.y
  if getVariable("entityAt_" .. x .. "_" .. y) then
    print("Position occupied!")
    return nil
  end
  return data
end)

-- 7.22: Hook for item effect
hook("beforeUseItem", function(data)
  if data.itemType == "potion" then
    setVariable("health", getVariable("health") + 25)
  elseif data.itemType == "mana_potion" then
    setVariable("mana", getVariable("mana") + 25)
  end
  return data
end)

-- 7.23: Hook for trade validation
hook("beforeTrade", function(data)
  if getVariable("gold") < data.cost then
    print("Not enough gold!")
    return nil
  end
  setVariable("gold", getVariable("gold") - data.cost)
  return data
end)

-- 7.24: Hook for stamina drain
hook("beforeAction", function(data)
  local stamina = getVariable("stamina")
  setVariable("stamina", stamina - 1)
  if stamina <= 0 then
    print("No stamina!")
    return nil
  end
  return data
end)

-- 7.25: Hook for cooldown check
hook("beforeSkillUse", function(data)
  local lastUsed = getVariable("skill_" .. data.skillId .. "_lastUsed") or 0
  local cooldown = data.cooldown or 5
  if os.time() - lastUsed < cooldown then
    print("Skill on cooldown!")
    return nil
  end
  setVariable("skill_" .. data.skillId .. "_lastUsed", os.time())
  return data
end)
