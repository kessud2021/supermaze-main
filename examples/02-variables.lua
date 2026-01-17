-- ============================================
-- 2. VARIABLE & STATE MANAGEMENT
-- ============================================

-- 2.1: Basic variable declaration
local x = 10
local name = "Player"
local isActive = true

-- 2.2: Set game variable
setVariable("score", 100)

-- 2.3: Get game variable
local score = getVariable("score")
print("Score: " .. score)

-- 2.4: Update variable
setVariable("score", getVariable("score") + 10)

-- 2.5: String variables
local playerName = "Alice"
setVariable("currentPlayer", playerName)

-- 2.6: Numeric variables
local health = 100
local mana = 50
local stamina = 75

-- 2.7: Boolean flags
setVariable("isInMaze", true)
setVariable("hasKey", false)
setVariable("levelComplete", false)

-- 2.8: Initialize counter
setVariable("moveCount", 0)

-- 2.9: Track position
setVariable("playerX", 0)
setVariable("playerY", 0)

-- 2.10: Store multiple values
on("player.move", function(data)
  setVariable("lastX", getVariable("playerX"))
  setVariable("lastY", getVariable("playerY"))
  setVariable("playerX", data.x)
  setVariable("playerY", data.y)
end)

-- 2.11: Score tracking
on("maze.complete", function(data)
  setVariable("completedMazes", getVariable("completedMazes") + 1)
  setVariable("totalTime", getVariable("totalTime") + data.time)
end)

-- 2.12: Level variables
local level = 1
local maxLevel = 10
setVariable("currentLevel", level)

-- 2.13: Difficulty tracking
setVariable("difficulty", "normal")

-- 2.14: Time-based variables
setVariable("sessionStart", os.time())

-- 2.15: Array-like variables (stored as strings)
setVariable("collectedItems", "0,0,0,0,0")

-- 2.16: Increment counter
on("player.move", function(data)
  local count = getVariable("moveCount")
  setVariable("moveCount", count + 1)
end)

-- 2.17: Track achievements
setVariable("speedrunRecord", 999999)
setVariable("deathCount", 0)
setVariable("perfectRuns", 0)

-- 2.18: Session variables
setVariable("gamesPlayed", 0)
setVariable("gamesWon", 0)
setVariable("bestTime", 9999)

-- 2.19: Player stats
local playerStats = {}
setVariable("stats", "hp:100,atk:10,def:5")

-- 2.20: Conditional variable assignment
on("player.collision", function(data)
  if data.tile.type == "powerup" then
    setVariable("hasBoost", true)
  end
end)
