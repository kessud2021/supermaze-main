-- ============================================
-- 3. CONTROL FLOW & CONDITIONALS
-- ============================================

-- 3.1: Simple if statement
if true then
  print("This will print")
end

-- 3.2: If-else
local x = 10
if x > 5 then
  print("x is greater than 5")
else
  print("x is less than or equal to 5")
end

-- 3.3: Elseif chain
local score = 75
if score >= 90 then
  print("Grade A")
elseif score >= 80 then
  print("Grade B")
elseif score >= 70 then
  print("Grade C")
else
  print("Grade F")
end

-- 3.4: Nested if statements
local x = 10
local y = 20
if x > 5 then
  if y > 15 then
    print("Both conditions true")
  end
end

-- 3.5: Logical AND
if x > 5 and y < 30 then
  print("Both true")
end

-- 3.6: Logical OR
if x < 5 or y > 15 then
  print("At least one true")
end

-- 3.7: NOT operator
if not false then
  print("This prints because NOT false = true")
end

-- 3.8: Comparison operators
if 10 == 10 then print("Equal") end
if 10 ~= 5 then print("Not equal") end
if 10 > 5 then print("Greater") end
if 5 < 10 then print("Less") end
if 10 >= 10 then print("GTE") end
if 10 <= 10 then print("LTE") end

-- 3.9: For loop - numeric
for i=1,10 do
  print(i)
end

-- 3.10: For loop with step
for i=1,10,2 do
  print(i)
end

-- 3.11: For loop countdown
for i=10,1,-1 do
  print(i)
end

-- 3.12: Nested loops
for i=1,3 do
  for j=1,3 do
    print("i=" .. i .. " j=" .. j)
  end
end

-- 3.13: While loop
local count = 0
while count < 5 do
  print(count)
  count = count + 1
end

-- 3.14: Infinite loop with break (simulate)
local x = 0
while true do
  x = x + 1
  if x >= 5 then
    break
  end
  print(x)
end

-- 3.15: Event with control flow
on("player.move", function(data)
  if data.x == 5 and data.y == 5 then
    print("Reached special location")
  end
end)

-- 3.16: State machine pattern
setVariable("state", "idle")
local state = getVariable("state")
if state == "idle" then
  print("Waiting...")
elseif state == "moving" then
  print("Moving...")
elseif state == "attacking" then
  print("Attacking...")
end

-- 3.17: Complex conditional
on("player.collision", function(data)
  if data.tile and (data.tile.type == "wall" or data.tile.type == "obstacle") then
    if getVariable("health") > 0 then
      print("Can still move")
    end
  end
end)

-- 3.18: Loop with condition
local sum = 0
for i=1,100 do
  if i % 2 == 0 then
    sum = sum + i
  end
end
print("Sum of even numbers: " .. sum)

-- 3.19: Early return in logic
local function checkValid(value)
  if value == nil then return false end
  if value < 0 then return false end
  return true
end

-- 3.20: Ternary-like pattern (simulated)
local age = 25
local canVote = age >= 18 and "yes" or "no"
print("Can vote: " .. canVote)
