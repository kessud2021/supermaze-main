-- ============================================
-- 8. DESIGN PATTERNS & ADVANCED TECHNIQUES
-- ============================================

-- 8.1: State machine pattern
function stateManager(newState)
  local currentState = getVariable("state")
  if currentState == "idle" then
    if newState == "moving" then
      setVariable("state", "moving")
    end
  elseif currentState == "moving" then
    if newState == "idle" then
      setVariable("state", "idle")
    end
  end
end

-- 8.2: Observer pattern (event listeners)
function subscribeToEvent(eventName, handler)
  on(eventName, handler)
end

-- 8.3: Singleton pattern (using global state)
function getSingleton(key)
  if getVariable(key) == nil then
    setVariable(key, {})
  end
  return getVariable(key)
end

-- 8.4: Factory pattern
function createEnemy(type)
  if type == "goblin" then
    return { hp = 30, speed = 5, type = "goblin" }
  elseif type == "orc" then
    return { hp = 50, speed = 3, type = "orc" }
  end
end

-- 8.5: Decorator pattern
function buffHealth(amount)
  local maxHealth = 100
  return maxHealth + amount
end

-- 8.6: Command pattern
function executeCommand(cmd, args)
  if cmd == "move" then
    setVariable("playerX", args.x)
    setVariable("playerY", args.y)
  elseif cmd == "attack" then
    setVariable("lastAttackTarget", args.targetId)
  end
end

-- 8.7: Strategy pattern
function calculateDamage(strategy, baseHp)
  if strategy == "aggressive" then
    return baseHp * 1.5
  elseif strategy == "defensive" then
    return baseHp * 0.8
  else
    return baseHp
  end
end

-- 8.8: Memoization
local memo = {}
function fibonacci_memo(n)
  if memo[n] then return memo[n] end
  if n <= 1 then return n end
  memo[n] = fibonacci_memo(n-1) + fibonacci_memo(n-2)
  return memo[n]
end

-- 8.9: Queue simulation
function enqueueAction(action)
  local queue = getVariable("actionQueue") or ""
  setVariable("actionQueue", queue .. action .. ",")
end

function dequeueAction()
  local queue = getVariable("actionQueue") or ""
  -- Simulate queue pop
  return string.sub(queue, 1, 1)
end

-- 8.10: Stack simulation
function pushState(state)
  local stack = getVariable("stateStack") or ""
  setVariable("stateStack", stack .. state .. ",")
end

-- 8.11: Throttling pattern
local lastActionTime = 0
function throttledAction(action, delay)
  local now = os.time()
  if now - lastActionTime >= delay then
    lastActionTime = now
    return true
  end
  return false
end

-- 8.12: Debouncing (simulated)
function debouncedSave(delay)
  if getVariable("saveScheduled") == nil then
    setVariable("saveScheduled", os.time() + delay)
  end
end

-- 8.13: Conditional event emission
function emitIfCondition(event, condition, data)
  if condition then
    emit(event, data)
  end
end

-- 8.14: Error handling
function safeCall(fn)
  if fn then
    return true
  else
    print("Function call failed")
    return false
  end
end

-- 8.15: Lazy initialization
function getLazyResource(name)
  local resource = getVariable("resource_" .. name)
  if resource == nil then
    resource = "initialized_" .. name
    setVariable("resource_" .. name, resource)
  end
  return resource
end

-- 8.16: Resource pooling
function getObjectFromPool(poolName)
  local pool = getVariable("pool_" .. poolName) or {}
  if #pool > 0 then
    return pool[#pool]
  else
    return "new_object"
  end
end

-- 8.17: Dependency injection pattern
function createGameContext(config)
  return {
    maxHealth = config.maxHealth or 100,
    maxMana = config.maxMana or 50,
    difficulty = config.difficulty or "normal"
  }
end

-- 8.18: Builder pattern (simulated)
function buildCharacter()
  local character = {}
  return {
    withHealth = function(self, hp) character.hp = hp return self end,
    withMana = function(self, m) character.mana = m return self end,
    build = function(self) return character end
  }
end

-- 8.19: Chaining pattern
function applyEffects()
  return {
    damage = function(self, amount)
      setVariable("health", getVariable("health") - amount)
      return self
    end,
    heal = function(self, amount)
      setVariable("health", getVariable("health") + amount)
      return self
    end
  }
end

-- 8.20: Event aggregation
function aggregateEvents(events)
  local total = 0
  for i=1,10 do
    total = total + 1
  end
  return total
end

-- 8.21: Aspect-oriented pattern
function withLogging(fn, name)
  print("[LOG] Calling " .. name)
  return fn()
end

-- 8.22: Type checking pattern
function isValidPosition(x, y)
  if x == nil or y == nil then return false end
  if type(x) ~= "number" or type(y) ~= "number" then return false end
  return true
end

-- 8.23: Caching pattern
local cache = {}
function getCachedValue(key)
  if cache[key] == nil then
    cache[key] = computeExpensiveValue(key)
  end
  return cache[key]
end

function computeExpensiveValue(key)
  return "value_" .. key
end

-- 8.24: Fallback pattern
function getValueWithFallback(primary, fallback)
  if primary ~= nil then
    return primary
  else
    return fallback
  end
end

-- 8.25: Guard clause pattern
function processPlayer(player)
  if player == nil then return end
  if player.health <= 0 then return end
  if player.frozen then return end
  
  -- Process valid player
  print("Processing player")
end

-- 8.26: Mutation pattern
function mutatePlayerState(mutations)
  for key, value in pairs(mutations) do
    setVariable(key, value)
  end
end

-- 8.27: Immutable pattern (simulated)
function makeImmutable(data)
  return data
end

-- 8.28: Composition over inheritance
function createPlayer(name)
  return {
    name = name,
    move = function() setVariable("playerX", getVariable("playerX") + 1) end,
    attack = function() print("Attacking") end
  }
end

-- 8.29: Adapter pattern
function adaptOldAPItoNew(oldFunction, args)
  return oldFunction(args)
end

-- 8.30: Facade pattern
function simplifyGameStart()
  initializeGame()
  loadAssets()
  setupPlayers()
end

function initializeGame() print("Init") end
function loadAssets() print("Load") end
function setupPlayers() print("Setup") end
