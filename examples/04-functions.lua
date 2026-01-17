-- ============================================
-- 4. FUNCTIONS & PROCEDURES
-- ============================================

-- 4.1: Simple function
function greet()
  print("Hello!")
end
greet()

-- 4.2: Function with parameters
function add(a, b)
  return a + b
end
print(add(5, 3))

-- 4.3: Function with return value
function multiply(x, y)
  return x * y
end
local result = multiply(4, 5)

-- 4.4: Multiple returns (simulated)
function getCoordinates()
  return 10, 20
end
local x, y = getCoordinates()

-- 4.5: Optional parameters
function printMessage(msg, prefix)
  if prefix == nil then
    prefix = "[LOG]"
  end
  print(prefix .. " " .. msg)
end
printMessage("Hello")
printMessage("Error!", "[ERROR]")

-- 4.6: Function with default values
function damage(hp, amount)
  if amount == nil then amount = 10 end
  return hp - amount
end

-- 4.7: Recursive function
function factorial(n)
  if n <= 1 then
    return 1
  else
    return n * factorial(n - 1)
  end
end

-- 4.8: Function that modifies game state
function levelUp()
  setVariable("level", getVariable("level") + 1)
  print("Leveled up to " .. getVariable("level"))
end

-- 4.9: Function with event emission
function triggerVictory(playerName, time)
  emit("victory", { player = playerName, time = time })
end

-- 4.10: Pure function (no side effects)
function isEven(n)
  return n % 2 == 0
end

-- 4.11: Function to check position
function isInBounds(x, y, maxX, maxY)
  return x >= 0 and x <= maxX and y >= 0 and y <= maxY
end

-- 4.12: Function to calculate distance
function distance(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return math.sqrt(dx * dx + dy * dy)
end

-- 4.13: Function with validation
function setPlayerHealth(hp)
  if hp < 0 then hp = 0 end
  if hp > 100 then hp = 100 end
  setVariable("health", hp)
end

-- 4.14: Function to find value in range
function clamp(value, min, max)
  if value < min then return min end
  if value > max then return max end
  return value
end

-- 4.15: Function to toggle flag
function toggleFlag(flagName)
  local current = getVariable(flagName)
  setVariable(flagName, not current)
end

-- 4.16: Function to increment with limit
function incrementScore(amount, maxScore)
  local score = getVariable("score")
  score = score + amount
  if score > maxScore then score = maxScore end
  setVariable("score", score)
end

-- 4.17: Function handling game logic
function movePlayer(dx, dy)
  local x = getVariable("playerX")
  local y = getVariable("playerY")
  setVariable("playerX", x + dx)
  setVariable("playerY", y + dy)
end

-- 4.18: Function with conditional logic
function applyDamage(amount)
  local defense = getVariable("defense")
  local actualDamage = amount - defense
  if actualDamage < 1 then actualDamage = 1 end
  setVariable("health", getVariable("health") - actualDamage)
end

-- 4.19: Function to reset state
function resetGame()
  setVariable("score", 0)
  setVariable("level", 1)
  setVariable("health", 100)
  setVariable("playerX", 0)
  setVariable("playerY", 0)
end

-- 4.20: Callback function
function onPlayerDeath()
  print("Player died!")
  setVariable("deathCount", getVariable("deathCount") + 1)
  emit("player.death", {})
end

-- 4.21: Function composition
function applyBoost(statName, amount)
  local current = getVariable(statName)
  setVariable(statName, current + amount)
end

-- 4.22: Function with early exit
function canMove(x, y)
  if x < 0 then return false end
  if x > 100 then return false end
  if y < 0 then return false end
  if y > 100 then return false end
  return true
end

-- 4.23: Function to compare values
function max(a, b)
  if a > b then return a else return b end
end

-- 4.24: Function to calculate percentage
function getHealthPercent()
  local health = getVariable("health")
  local maxHealth = 100
  return (health / maxHealth) * 100
end

-- 4.25: Utility function
function sleep(ms)
  -- Simulated sleep, not real in Lua
  print("Sleeping for " .. ms .. "ms")
end
