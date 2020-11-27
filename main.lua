local playerX = 5
local playerY = 17
local accel = 300
local run = 0

local speedX = 0
local speedY = 0

function love.load()
  grass = love.graphics.newImage("grass.png")
  Player = love.graphics.newImage("burger.png")
  Player2 = love.graphics.newImage("burger2.png")
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
  cellsize = 32
  
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
  
  for i=0,32 do
    love.graphics.draw(grass, i*cellsize, cellsize*18)

  end

  --player
  if run==0 then  
    love.graphics.draw(Player,cellsize*playerX,cellsize*17)
  else 
    love.graphics.draw(Player2,cellsize*playerX,cellsize*17)
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
end
