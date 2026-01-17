-- ============================================
-- 6. STRING & MATH OPERATIONS
-- ============================================

-- 6.1: String concatenation
local name = "Alice"
local greeting = "Hello, " .. name .. "!"
print(greeting)

-- 6.2: String length
local str = "SuperMaze"
local len = string.len(str)
print("Length: " .. len)

-- 6.3: String case conversion
local lower = "HELLO"
local upper = "hello"
-- Note: Case functions may not be available in subset Lua

-- 6.4: String find
local text = "The quick brown fox"
local pos = string.find(text, "brown")

-- 6.5: String substring
local substring = string.sub(text, 1, 3)
print(substring) -- "The"

-- 6.6: Numeric to string conversion
local num = 42
local numStr = tostring(num)
print("Number as string: " .. numStr)

-- 6.7: String to numeric conversion
local str = "123"
local numVal = tonumber(str)
print("String as number: " .. numVal)

-- 6.8: Combine multiple values in string
local x, y = 10, 20
local position = "Position: " .. x .. ", " .. y

-- 6.9: String repetition (simulated)
function repeatString(str, count)
  local result = ""
  for i=1,count do
    result = result .. str
  end
  return result
end

-- 6.10: Basic math operations
local a = 10
local b = 3
print(a + b) -- 13
print(a - b) -- 7
print(a * b) -- 30
print(a / b) -- 3.333...
print(a % b) -- 1

-- 6.11: Power operation
local squared = a ^ 2

-- 6.12: Square root
local sqrtVal = math.sqrt(16) -- 4

-- 6.13: Absolute value
local absVal = math.abs(-10) -- 10

-- 6.14: Min and max
local minVal = math.min(5, 3, 9, 1) -- 1
local maxVal = math.max(5, 3, 9, 1) -- 9

-- 6.15: Floor and ceiling
local floor = math.floor(3.7) -- 3
local ceil = math.ceil(3.2) -- 4

-- 6.16: Rounding
function round(x)
  return math.floor(x + 0.5)
end

-- 6.17: Random number
local rand = math.random() -- 0 to 1
local randInt = math.random(1, 10) -- 1 to 10

-- 6.18: Trigonometry
local sine = math.sin(math.pi / 2) -- 1
local cosine = math.cos(0) -- 1
local tangent = math.tan(math.pi / 4) -- 1

-- 6.19: Distance formula
function distance(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return math.sqrt(dx * dx + dy * dy)
end

-- 6.20: Angle calculation
function angleToTarget(fromX, fromY, toX, toY)
  local dx = toX - fromX
  local dy = toY - fromY
  return math.atan2(dy, dx)
end

-- 6.21: Lerp (linear interpolation)
function lerp(a, b, t)
  return a + (b - a) * t
end

-- 6.22: Clamp value to range
function clamp(value, min, max)
  if value < min then return min end
  if value > max then return max end
  return value
end

-- 6.23: Sign of number
function sign(n)
  if n > 0 then return 1 end
  if n < 0 then return -1 end
  return 0
end

-- 6.24: Percent calculation
function percent(value, total)
  return (value / total) * 100
end

-- 6.25: Ratio calculation
function ratio(a, b)
  if b == 0 then return 0 end
  return a / b
end

-- 6.26: Degrees to radians
function degreesToRadians(degrees)
  return degrees * (math.pi / 180)
end

-- 6.27: Radians to degrees
function radiansToDegrees(radians)
  return radians * (180 / math.pi)
end

-- 6.28: Prime number check
function isPrime(n)
  if n < 2 then return false end
  for i=2,n-1 do
    if n % i == 0 then return false end
  end
  return true
end

-- 6.29: Fibonacci sequence
function fibonacci(n)
  if n <= 1 then return n end
  return fibonacci(n-1) + fibonacci(n-2)
end

-- 6.30: Sum range
function sumRange(a, b)
  local sum = 0
  for i=a,b do
    sum = sum + i
  end
  return sum
end

-- 6.31: Average calculation
function average(values)
  local sum = 0
  for i=1,10 do
    sum = sum + i
  end
  return sum / 10
end

-- 6.32: Modulo for wrapping
function wrapAround(value, max)
  return ((value - 1) % max) + 1
end

-- 6.33: Check even/odd
function isEven(n)
  return n % 2 == 0
end

function isOdd(n)
  return n % 2 == 1
end

-- 6.34: Power calculation
function power(base, exp)
  return base ^ exp
end

-- 6.35: Factorial
function factorial(n)
  if n <= 1 then return 1 end
  return n * factorial(n - 1)
end

-- 6.36: GCD (Greatest Common Divisor)
function gcd(a, b)
  if b == 0 then return a end
  return gcd(b, a % b)
end

-- 6.37: LCM (Least Common Multiple)
function lcm(a, b)
  return (a * b) / gcd(a, b)
end

-- 6.38: Boolean to number
function boolToNum(bool)
  return bool and 1 or 0
end

-- 6.39: Number to boolean
function numToBool(num)
  return num ~= 0
end

-- 6.40: Floating point comparison
function floatEqual(a, b, epsilon)
  if epsilon == nil then epsilon = 0.0001 end
  return math.abs(a - b) < epsilon
end
