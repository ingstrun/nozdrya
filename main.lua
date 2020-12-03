local playerX = 5
local playerY = 17
local accel = 300
local run = 0
local ground_level = {}
local mob_run = 0
local cellsize = 32
local world_h = 40
local world_w = 70

function love.load()
  dirt = love.graphics.newImage("dirt.png")
  grass = love.graphics.newImage("grass.png")
  Player = love.graphics.newImage("burger.png")
  Player2 = love.graphics.newImage("burger2.png")
  love.window.setTitle("Forager craft")
  love.window.setMode(cellsize * world_w, cellsize * world_h)
  no = love.graphics.newImage("пустота.png")
  wood = love.graphics.newImage("wood.png")
  for i=0, world_w do
    ground_level[i] = 15
  end
  sound = love.audio.newSource("music.mp3", "stream")
  love.audio.play(sound)
end

function love.draw()
  red = 0.7
  green = 0.7
  blue = 0.7
  alpha = 0/100

  -- love.graphics.setBackgroundColor( red, green, blue, alpha)

  love.graphics.clear(red, green, blue, alpha)
  w = love.graphics.getWidth()   -- window width
  h = love.graphics.getHeight()  -- window height
  
  x = cellsize
  
  while x < w do
    love.graphics.line(x, 0, x, h)
    x = x + cellsize
  end
  y = cellsize
  
  while y < h do
    love.graphics.line(0,y,w,y)
    y = y + cellsize
  end
  --grass
  for i=0,world_w do
    love.graphics.draw(grass, i*cellsize, cellsize * ground_level[i])
    for g=ground_level[i]+1,world_h do
      love.graphics.draw(dirt, i*cellsize, cellsize * g)
    end
  end
  
  --player
  if run==0 then  
    love.graphics.draw(Player, cellsize*playerX, cellsize*ground_level[playerX] - cellsize)
  else 
    love.graphics.draw(Player2, cellsize*playerX, cellsize*ground_level[playerX] - cellsize)
  end

  for i=0,10 do
   -- love.graphics.draw(grass, i*cellsize, cellsize * i)
  end
  -- love.graphics.draw(grass, love.mouse.getX(), love.mouse.getY( ))
  --love.graphics.draw(grass, cellsize, cellsize * 3)
  -- love.graphics.print("I like turtles", love.mouse.getX(), love.mouse.getY( ))
end

function love.keypressed( key )
  if key == "d" then
    playerX = playerX+1
    if run==0 then 
      run = run+1
    else
      run=run-1
    end  
   -- playerY = love.mouse.getY()
  end
   if key == "a" then
    playerX = playerX-1
    if run==0 then 
      run = run+1
    else
      run=run-1
    end  
  end
  
  if key == "o" then
    ground_level[playerX] = ground_level[playerX]+1
  end
  
  if key == "p" then
    ground_level[playerX] = ground_level[playerX]-1
  end 
  
  if key == "f5" then
    -- Opens a file in append mode
    file = io.open("world.txt", "w")    
    -- sets the default output file as test.lua
    io.output(file)

    for i = 0, world_w do
      io.write(ground_level[i])
      io.write("\n")
    end

    -- closes the open file
    io.close(file)
  end 

  if key == "f9" then
    i = 0
    for l in io.lines("world.txt") do
      ground_level[i] = tonumber(l)
      i = i+1
    end
  end
end
