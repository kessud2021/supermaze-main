-- ============================================
-- 5. GAME-SPECIFIC LOGIC
-- ============================================

-- 5.1: Track player position changes
on("player.move", function(data)
  setVariable("playerX", data.x)
  setVariable("playerY", data.y)
  setVariable("moveCount", getVariable("moveCount") + 1)
end)

-- 5.2: Detect collision with wall
on("player.collision", function(data)
  if data.tile.type == "wall" then
    print("Collision with wall at " .. data.x .. ", " .. data.y)
  end
end)

-- 5.3: Collect items on collision
on("player.collision", function(data)
  if data.tile.type == "item" then
    setVariable("itemsCollected", getVariable("itemsCollected") + 1)
    emit("item.collected", { id = data.tile.id })
  end
end)

-- 5.4: Teleporter functionality
on("player.collision", function(data)
  if data.tile.type == "teleporter" then
    emit("player.teleport", { 
      from = { x = data.x, y = data.y },
      to = data.tile.target 
    })
  end
end)

-- 5.5: Speed boost effect
on("player.collision", function(data)
  if data.tile.type == "speedboost" then
    setVariable("speed", getVariable("speed") + 50)
    emit("powerup.activated", { type = "speedboost" })
  end
end)

-- 5.6: Maze completion detection
on("player.collision", function(data)
  if data.tile.type == "end" then
    local time = os.time() - getVariable("mazeStartTime")
    emit("maze.complete", { 
      username = getVariable("currentPlayer"),
      time = time 
    })
  end
end)

-- 5.7: Damage from hazards
on("player.collision", function(data)
  if data.tile.type == "hazard" then
    setVariable("health", getVariable("health") - 10)
    print("Hit hazard! Health now: " .. getVariable("health"))
  end
end)

-- 5.8: Key collection
on("player.collision", function(data)
  if data.tile.type == "key" then
    setVariable("keysCollected", getVariable("keysCollected") + 1)
    if getVariable("keysCollected") >= 3 then
      setVariable("doorsUnlocked", true)
      emit("doors.unlocked", {})
    end
  end
end)

-- 5.9: Points from movement
on("player.move", function(data)
  setVariable("score", getVariable("score") + 1)
end)

-- 5.10: Combo system
on("player.move", function(data)
  setVariable("movesSinceLastHit", getVariable("movesSinceLastHit") + 1)
  if getVariable("movesSinceLastHit") > 50 then
    setVariable("comboMultiplier", 1)
  else
    setVariable("comboMultiplier", 1 + (getVariable("movesSinceLastHit") / 50))
  end
end)

-- 5.11: Time limit system
function checkTimeLimit()
  local elapsed = os.time() - getVariable("startTime")
  if elapsed > getVariable("timeLimit") then
    emit("timelimit.exceeded", {})
  end
end

-- 5.12: Leaderboard tracking
on("maze.complete", function(data)
  local bestTime = getVariable("bestTime")
  if data.time < bestTime then
    setVariable("bestTime", data.time)
    setVariable("bestPlayer", data.username)
  end
end)

-- 5.13: Difficulty scaling
function initializeDifficulty(level)
  if level == 1 then
    setVariable("enemySpeed", 1)
    setVariable("timeLimit", 300)
  elseif level == 2 then
    setVariable("enemySpeed", 2)
    setVariable("timeLimit", 200)
  elseif level == 3 then
    setVariable("enemySpeed", 3)
    setVariable("timeLimit", 100)
  end
end

-- 5.14: Skill system
on("player.collision", function(data)
  if data.tile.type == "skillbook" then
    setVariable("skillPoints", getVariable("skillPoints") + 1)
  end
end)

-- 5.15: Experience gain
on("maze.complete", function(data)
  local xp = 100 + (getVariable("level") * 10)
  setVariable("experience", getVariable("experience") + xp)
  if getVariable("experience") >= 1000 then
    setVariable("level", getVariable("level") + 1)
    setVariable("experience", 0)
  end
end)

-- 5.16: Boss battle logic
function startBossBattle()
  setVariable("bossHealth", 500)
  setVariable("bossActive", true)
  emit("boss.appeared", { maxHealth = 500 })
end

-- 5.17: NPC interaction
on("player.collision", function(data)
  if data.tile.type == "npc" then
    setVariable("lastNPC", data.tile.name)
    emit("npc.interact", { npcId = data.tile.id })
  end
end)

-- 5.18: Puzzle solving
on("player.collision", function(data)
  if data.tile.type == "puzzle" then
    if getVariable("hasPuzzleKey") then
      setVariable("puzzlesSolved", getVariable("puzzlesSolved") + 1)
      emit("puzzle.solved", {})
    end
  end
end)

-- 5.19: Checkpoint system
on("player.collision", function(data)
  if data.tile.type == "checkpoint" then
    setVariable("lastCheckpoint", { x = data.x, y = data.y })
    print("Checkpoint reached!")
  end
end)

-- 5.20: Multiplayer sync
on("player.move", function(data)
  emit("player.position.sync", {
    playerId = getVariable("playerId"),
    x = data.x,
    y = data.y,
    timestamp = os.time()
  })
end)

-- 5.21: Respawn system
function respawnPlayer()
  local lastCheckpoint = getVariable("lastCheckpoint")
  if lastCheckpoint then
    setVariable("playerX", lastCheckpoint.x)
    setVariable("playerY", lastCheckpoint.y)
  else
    setVariable("playerX", 0)
    setVariable("playerY", 0)
  end
  setVariable("health", 100)
end

-- 5.22: Loot system
function generateLoot()
  local lootTable = { "gold", "potion", "gem", "key" }
  local randomIndex = math.random(1, 4)
  return lootTable[randomIndex]
end

-- 5.23: Buff/Debuff system
function applyBuff(buffName, duration)
  setVariable("buff_" .. buffName, os.time() + duration)
end

-- 5.24: Statistics tracking
on("maze.complete", function(data)
  setVariable("totalMazesCompleted", getVariable("totalMazesCompleted") + 1)
  setVariable("totalTimePlayed", getVariable("totalTimePlayed") + data.time)
  setVariable("averageTime", getVariable("totalTimePlayed") / getVariable("totalMazesCompleted"))
end)

-- 5.25: Achievement unlocking
function checkAchievements()
  if getVariable("moveCount") > 1000 then
    emit("achievement.unlocked", { name = "Marathon", points = 50 })
  end
  if getVariable("score") > 50000 then
    emit("achievement.unlocked", { name = "High Scorer", points = 100 })
  end
end
