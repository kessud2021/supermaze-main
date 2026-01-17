-- ============================================
-- 9. ADVANCED GAME SCRIPTING
-- ============================================

-- 9.1: Dynamic difficulty scaling
function updateDifficulty()
  local moveCount = getVariable("moveCount")
  if moveCount > 100 then
    setVariable("difficulty", "hard")
  elseif moveCount > 50 then
    setVariable("difficulty", "medium")
  else
    setVariable("difficulty", "easy")
  end
end

-- 9.2: Procedural level generation
function generateLevelLayout(seed)
  math.randomseed(seed)
  local layout = {}
  for x=1,10 do
    for y=1,10 do
      if math.random(1, 3) == 1 then
        table.insert(layout, { x = x, y = y, type = "wall" })
      end
    end
  end
  return layout
end

-- 9.3: Dynamic spawning
function spawnEnemiesNear(playerX, playerY, count)
  for i=1,count do
    local offsetX = math.random(-5, 5)
    local offsetY = math.random(-5, 5)
    emit("enemy.spawn", {
      x = playerX + offsetX,
      y = playerY + offsetY
    })
  end
end

-- 9.4: Pathfinding hint
function findShortestPath(fromX, fromY, toX, toY)
  local dx = math.abs(toX - fromX)
  local dy = math.abs(toY - fromY)
  return dx + dy -- Manhattan distance
end

-- 9.5: Stealth mechanics
on("player.move", function(data)
  local noise = getVariable("movementNoise")
  if noise > getVariable("detectionRange") then
    emit("player.detected", {})
  end
end)

-- 9.6: Conversation system
function startConversation(npcId, dialogueIndex)
  local dialogues = {
    "Hello there!",
    "How are you?",
    "Good luck!"
  }
  return dialogues[dialogueIndex] or "..."
end

-- 9.7: Quest branching
function processQuestChoice(questId, choice)
  if choice == "accept" then
    setVariable("quest_" .. questId .. "_status", "active")
    emit("quest.started", { questId = questId })
  elseif choice == "decline" then
    emit("quest.declined", { questId = questId })
  end
end

-- 9.8: Inventory weight system
function canCarryItem(itemWeight)
  local currentWeight = getVariable("inventoryWeight") or 0
  local maxWeight = 50
  return (currentWeight + itemWeight) <= maxWeight
end

-- 9.9: Durability system
on("player.move", function(data)
  local weaponDurability = getVariable("weaponDurability")
  setVariable("weaponDurability", weaponDurability - 0.1)
  if weaponDurability <= 0 then
    print("Weapon broke!")
    emit("item.broken", { itemType = "weapon" })
  end
end)

-- 9.10: Currency system
function purchaseItem(itemId, cost)
  local gold = getVariable("gold")
  if gold >= cost then
    setVariable("gold", gold - cost)
    emit("item.purchased", { itemId = itemId })
    return true
  else
    print("Not enough gold!")
    return false
  end
end

-- 9.11: Reputation system
function changeReputation(faction, amount)
  local rep = getVariable("reputation_" .. faction) or 0
  setVariable("reputation_" .. faction, rep + amount)
  
  if rep + amount >= 100 then
    emit("faction.loved", { faction = faction })
  elseif rep + amount <= -100 then
    emit("faction.hated", { faction = faction })
  end
end

-- 9.12: Relationship tracking
function modifyRelationship(npcId, change)
  local affinity = getVariable("affinity_" .. npcId) or 0
  setVariable("affinity_" .. npcId, affinity + change)
  
  if affinity + change >= 100 then
    emit("npc.romance", { npcId = npcId })
  end
end

-- 9.13: Crafting system
function craftItem(recipe)
  for i=1,10 do
    if getVariable("ingredient_" .. i) then
      return { crafted = true, item = recipe.output }
    end
  end
  return { crafted = false }
end

-- 9.14: Enchantment system
function enchantItem(itemId, enchantment, level)
  setVariable("item_" .. itemId .. "_enchantment", enchantment)
  setVariable("item_" .. itemId .. "_enchantLevel", level)
end

-- 9.15: Damage type resistance
function calculateActualDamage(baseDamage, damageType)
  local resistance = getVariable("resistance_" .. damageType) or 0
  return baseDamage * (1 - (resistance / 100))
end

-- 9.16: Multi-target effects
function applyAOEDamage(centerX, centerY, radius, damage)
  for x=centerX-radius,centerX+radius do
    for y=centerY-radius,centerY+radius do
      emit("damage.applied", {
        x = x, y = y, amount = damage
      })
    end
  end
end

-- 9.17: Status effect management
function applyStatusEffect(effect, duration)
  local effectId = effect .. "_" .. os.time()
  setVariable("effect_" .. effectId, os.time() + duration)
  emit("effect.applied", { effect = effect, duration = duration })
end

-- 9.18: Cooldown management
function getCooldownRemaining(abilityId)
  local lastUsed = getVariable("ability_" .. abilityId .. "_lastUsed") or 0
  local cooldown = 5
  local remaining = cooldown - (os.time() - lastUsed)
  return math.max(0, remaining)
end

-- 9.19: Resource generation
function generateResources()
  local time = os.time() - getVariable("sessionStart")
  local healthRegen = math.floor(time / 10)
  setVariable("health", getVariable("health") + healthRegen)
end

-- 9.20: Wave-based spawning
setVariable("currentWave", 0)
function nextWave()
  setVariable("currentWave", getVariable("currentWave") + 1)
  local waveNum = getVariable("currentWave")
  local enemyCount = 3 + (waveNum * 2)
  print("Wave " .. waveNum .. ": " .. enemyCount .. " enemies")
end

-- 9.21: Boss behavior
function bossBehavior()
  local bossHealth = getVariable("bossHealth")
  if bossHealth > 250 then
    setVariable("bossPhase", 1)
  elseif bossHealth > 100 then
    setVariable("bossPhase", 2)
  else
    setVariable("bossPhase", 3)
  end
end

-- 9.22: Minion spawning
function spawnMinions(count)
  for i=1,count do
    emit("minion.spawn", { id = "minion_" .. i })
  end
end

-- 9.23: Portal mechanics
function activatePortal(portalId)
  local linkedPortal = getVariable("portal_" .. portalId .. "_link")
  if linkedPortal then
    emit("player.teleport", { destination = linkedPortal })
  end
end

-- 9.24: Dynamic music transitions
function updateMusicTrack()
  local intensity = getVariable("combatIntensity")
  if intensity > 75 then
    emit("music.change", { track = "intense_boss_battle" })
  elseif intensity > 50 then
    emit("music.change", { track = "active_combat" })
  else
    emit("music.change", { track = "exploration" })
  end
end

-- 9.25: Event-driven animation
on("player.move", function(data)
  emit("animation.play", { name = "walk", duration = 0.3 })
end)

-- 9.26: Dialogue branching
function getDialogueOptions(npcId)
  return {
    { text = "Tell me more", next = 2 },
    { text = "I have to go", next = 0 },
    { text = "Can I take this quest?", next = 3 }
  }
end

-- 9.27: Tutorial progression
function checkTutorialStatus()
  local step = getVariable("tutorialStep") or 0
  if step == 0 then
    emit("tutorial.show", { msg = "Use arrow keys to move" })
    setVariable("tutorialStep", 1)
  end
end

-- 9.28: Seasonal events
function checkSeasonalEvent()
  local month = os.date("%m")
  if month == "12" then
    emit("event.holiday", { type = "christmas" })
  elseif month == "10" then
    emit("event.holiday", { type = "halloween" })
  end
end

-- 9.29: Challenge mode
function startChallengeMode(challengeId)
  setVariable("challengeActive", true)
  setVariable("challengeId", challengeId)
  setVariable("challengeStartTime", os.time())
end

-- 9.30: Leaderboard submission
function submitScore(playerName, score, time)
  emit("leaderboard.submit", {
    player = playerName,
    score = score,
    time = time,
    timestamp = os.time()
  })
end
