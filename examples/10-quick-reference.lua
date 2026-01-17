-- ============================================
-- 10. QUICK REFERENCE - ALL APIS & SNIPPETS
-- ============================================

-- ===== GAME ENGINE API =====
on("event", function(data) end)          -- Listen to event
emit("event", { key = "value" })          -- Emit event
hook("hookName", function(data) end)      -- Register hook
setVariable("key", value)                 -- Set game variable
getVariable("key")                        -- Get game variable

-- ===== AVAILABLE EVENTS =====
-- player.move, player.collision, maze.start, maze.complete, collision

-- ===== LUA BUILTINS =====
print("text")                             -- Print to console
tostring(value)                           -- Convert to string
tonumber(string)                          -- Convert to number
type(value)                               -- Get type

-- ===== MATH =====
math.random()                             -- Random 0-1
math.random(max)                          -- Random 1-max
math.random(min, max)                     -- Random min-max
math.sqrt(n)                              -- Square root
math.abs(n)                               -- Absolute value
math.floor(n)                             -- Round down
math.ceil(n)                              -- Round up
math.min(a, b, c)                         -- Minimum
math.max(a, b, c)                         -- Maximum
math.sin(x), math.cos(x), math.tan(x)    -- Trigonometry
n ^ 2                                     -- Power
n % 2                                     -- Modulo

-- ===== STRINGS =====
"hello" .. " " .. "world"                 -- Concatenation
string.len("text")                        -- Length
string.sub("hello", 1, 3)                 -- Substring
string.find("hello world", "world")       -- Find position

-- ===== CONTROL FLOW =====
if condition then end
if condition then else end
if condition then elseif condition2 then else end
for i=1,10 do end
for i=1,10,2 do end
for i=10,1,-1 do end
while condition do end
return value

-- ===== FUNCTIONS =====
function name(params) return value end
local function name(params) end

-- ===== COMMON PATTERNS =====

-- Simple counter
on("event", function(data)
  setVariable("count", getVariable("count") + 1)
end)

-- Conditional action
on("event", function(data)
  if condition then
    action()
  end
end)

-- State tracking
setVariable("state", "idle")
if getVariable("state") == "idle" then
  setVariable("state", "moving")
end

-- Resource management
local cost = 10
if getVariable("resource") >= cost then
  setVariable("resource", getVariable("resource") - cost)
end

-- Cooldown checking
local lastTime = getVariable("lastAction") or 0
if os.time() - lastTime >= 5 then
  setVariable("lastAction", os.time())
  action()
end

-- Value clamping
function clamp(value, min, max)
  if value < min then return min end
  if value > max then return max end
  return value
end

-- Distance calculation
function distance(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return math.sqrt(dx * dx + dy * dy)
end

-- Check in range
function inRange(x, minX, maxX)
  return x >= minX and x <= maxX
end

-- Percentage calculation
function percent(value, total)
  return (value / total) * 100
end

-- Ratio calculation
function ratio(a, b)
  return a / b
end

-- Linear interpolation
function lerp(a, b, t)
  return a + (b - a) * t
end

-- Random element
function randomElement(items)
  return items[math.random(1, #items)]
end

-- Counter loop
local count = 0
while count < 10 do
  print(count)
  count = count + 1
end

-- Conditional loop
local active = true
while active do
  if condition then
    active = false
  end
end

-- Nested loops
for i=1,5 do
  for j=1,5 do
    print(i .. "," .. j)
  end
end

-- Error checking
if value == nil then
  print("No value!")
  return
end

-- Type checking
if type(value) == "number" then
  print("Is number")
end

-- Boolean conversion
local flag = true
if not flag then print("False") end

-- Ternary-like
local result = condition and "yes" or "no"

-- Default value
local value = param or "default"

-- Initialization check
if getVariable("initialized") == nil then
  setVariable("initialized", true)
  -- Setup code
end

-- Time-based action
local sessionTime = os.time() - getVariable("sessionStart")
if sessionTime > 60 then
  print("1 minute passed")
end

-- Increment with limit
local val = getVariable("value")
if val < 100 then
  setVariable("value", val + 1)
end

-- Decrement with floor
local val = getVariable("value")
if val > 0 then
  setVariable("value", val - 1)
end

-- Multiple conditions
if a and b and c then
  print("All true")
end

-- Any condition
if a or b or c then
  print("At least one true")
end

-- Inverted condition
if not (a and b) then
  print("Not both")
end

-- Priority checking
if a then return "a" end
if b then return "b" end
if c then return "c" end
return "none"

-- Fallback pattern
local value = primary or backup or default

-- Guard clauses
if not condition1 then return end
if not condition2 then return end
print("All checks passed")

-- State machine
local state = getVariable("state")
if state == "idle" then
  -- Handle idle
elseif state == "moving" then
  -- Handle moving
elseif state == "attacking" then
  -- Handle attacking
end

-- Event with data spread
on("event", function(data)
  local x = data.x
  local y = data.y
  local type = data.type
  -- Use variables
end)

-- Emitting with full data
emit("event", {
  x = 10,
  y = 20,
  type = "collision",
  damage = 50
})

-- Async-like pattern
hook("beforeAction", function(data)
  if validate(data) then
    return data
  else
    return nil
  end
end)

-- Resource cleanup
function cleanup()
  setVariable("resource", nil)
  setVariable("state", "idle")
end

-- Common game loop pattern
on("game.tick", function()
  updatePhysics()
  updateAI()
  checkCollisions()
  render()
end)
