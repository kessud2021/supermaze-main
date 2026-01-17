-- ============================================
-- 1. EVENT HANDLING EXAMPLES
-- ============================================

-- 1.1: Simple event listener
on("player.move", function(data)
  print("Player moved to " .. data.x .. ", " .. data.y)
end)

-- 1.2: Multiple event listeners
on("player.move", function(data)
  print("Event 1: Player at " .. data.x .. "," .. data.y)
end)
on("player.move", function(data)
  print("Event 2: Moved!")
end)

-- 1.3: Collision detection
on("player.collision", function(data)
  if data.tile.type == "wall" then
    print("Hit a wall!")
  end
end)

-- 1.4: Teleporter logic
on("player.collision", function(data)
  if data.tile.type == "teleporter" then
    print("Teleporting to " .. data.tile.target)
    emit("player.teleport", { destination = data.tile.target })
  end
end)

-- 1.5: Maze completion event
on("maze.complete", function(data)
  print(data.username .. " completed the maze in " .. data.time .. " seconds!")
  setVariable("lastWinner", data.username)
end)

-- 1.6: Storing event data
on("player.move", function(data)
  setVariable("lastPosition", { x = data.x, y = data.y })
end)

-- 1.7: Conditional event handling
on("player.move", function(data)
  if data.x > 10 then
    print("Player is far from start!")
  elseif data.x > 5 then
    print("Player is in middle area")
  else
    print("Player is near start")
  end
end)

-- 1.8: Event with object data
on("collision", function(data)
  print("Collision detected at position: " .. data.x .. "," .. data.y)
end)

-- 1.9: Chain events
on("player.move", function(data)
  emit("position.updated", { x = data.x, y = data.y, timestamp = os.time() })
end)

-- 1.10: Null-safe event handling
on("player.move", function(data)
  if data and data.x and data.y then
    print("Valid position: " .. data.x .. ", " .. data.y)
  else
    print("Invalid position data")
  end
end)
