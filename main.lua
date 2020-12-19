local playerX = 5
local playerY = 17
local accel = 300
local run = 0
local ground_level = {}
local mob_run = 0
local cellsize = 32
local world_h = 40
local world_w = 70
local time_start_run = 0
local start_time = love.timer.getTime()
local last_set_ground = start_time - 1
local offset = 0
local jump_stop = 0
local hitpoints = 10
local game_over = false

function set_ground_sinus(offset)
  math.randomseed(os.time())
  for i=0, world_w do
    ground_level[i] = math.floor(6*math.random())+13
    --ground_level[i] = world_h/2
  end
end

function love.update(dt)
  if hitpoints<1 then
    gameover=true
  end
  now = love.timer.getTime()
  if now > time_start_run + 0.5 then
    -- offset = offset + 1
    -- set_ground_sinus(offset)
    last_set_ground = now
    run = 0
  end
end

function love.load()
  dirt = love.graphics.newImage("dirt.png")
  grass = love.graphics.newImage("grass.png")
  Player = love.graphics.newImage("burger.png")
  Player2 = love.graphics.newImage("burger2.png")
  stone=love.graphics.newImage("stone.png")
  love.window.setTitle("Ноздря")
  love.window.setMode(cellsize * world_w, cellsize * world_h)
  no = love.graphics.newImage("пустота.png")
  wood = love.graphics.newImage("wood.png")
  heart = love.graphics.newImage("heart.png")
  set_ground_sinus(offset)
  music = love.audio.newSource("music.mp3", "stream")
  sound_bonk = love.audio.newSource("bonk.mp3", "static")
  love.audio.play(music)
  rip = love.graphics.newImage("tomb.png")
  die = love.graphics.newImage("gameover.png")
  sound_oof = love.audio.newSource("oof.mp3", "static")
  stone_grass = love.graphics.newImage("stone_grass.png")
  rip_stone = love.graphics.newImage("tomb_cave.png")
end

function love.draw()
  red = 13/100
  green = 68/100
  blue = 96/100
  alpha = 0/100

  -- love.graphics.setBackgroundColor( red, green, blue, alpha)

  love.graphics.clear(red, green, blue, alpha)
  w = love.graphics.getWidth()   -- window width
  h = love.graphics.getHeight()  -- window height
  
  x = cellsize
  --[[|||
  while x < w do
    love.graphics.line(x, 0, x, h)
    x = x + cellsize
  end
  y = cellsize
  
  -- ___
  while y < h do
    love.graphics.line(0,y,w,y)
    y = y + cellsize
  end
  --]]

  --Жижа
  for hit=1,hitpoints do
    love.graphics.draw(heart,cellsize*hit,cellsize*2)
  end
  --?
  
  --grass
  for i=0,world_w do
    if ground_level[i]<30 then
      love.graphics.draw(grass, i*cellsize, cellsize * ground_level[i])
    else
      love.graphics.draw(stone_grass, i*cellsize, cellsize * ground_level[i])
    end
    
    -- zemlya
    for g=ground_level[i]+1,world_h do
      if g<30 then
        love.graphics.draw(dirt, i*cellsize, cellsize * g)
      else
        love.graphics.draw(stone, i*cellsize, cellsize * g)
      end
    end
    -- cifry snizu
    love.graphics.print(ground_level[i], i*cellsize, (world_h-1)*cellsize)
  end
  
  --player
  if hitpoints<1 then
    -- dead
    if ground_level[playerX]<30 then
      love.graphics.draw(rip, cellsize*playerX, cellsize*ground_level[playerX] - cellsize)
    else
      love.graphics.draw(rip_stone, cellsize*playerX, cellsize*ground_level[playerX] - cellsize)
    end
  elseif run==0 then    
    love.graphics.draw(Player, cellsize*playerX, cellsize*ground_level[playerX] - cellsize)
  else 
    love.graphics.draw(Player2, cellsize*playerX, cellsize*ground_level[playerX] - cellsize)
  end
  
  -- над головой у человечка
  love.graphics.print(ground_level[playerX], cellsize*playerX, cellsize* (ground_level[playerX]-2) )
  
  if playerX-0>0 then
    love.graphics.print(ground_level[playerX-1]-ground_level[playerX], cellsize*(playerX-1), cellsize* (ground_level[playerX]-2) )
  end
  
  love.graphics.print(ground_level[playerX+1]-ground_level[playerX], cellsize*(playerX+1), cellsize* (ground_level[playerX]-2) )

  for i=0,10 do
   -- love.graphics.draw(grass, i*cellsize, cellsize * i)
  end
  -- love.graphics.draw(grass, love.mouse.getX(), love.mouse.getY( ))
  --love.graphics.draw(grass, cellsize, cellsize * 3)
  --love.graphics.print("I like turtles", love.mouse.getX(), love.mouse.getY( ))

  mouseXpx = love.mouse.getX()
  mouseX = math.floor(mouseXpx / cellsize)
  -- love.graphics.circle("fill", mouseX*cellsize + cellsize/2, 0, 10, 10)
  x1 = mouseX*cellsize + cellsize/2
  x2 = mouseX*cellsize + cellsize/2
  y1=0
  y2=cellsize*world_h
  love.graphics.setColor(1, 0.5, 0.5)
  love.graphics.line( x1, y1, x2, y2 )
  love.graphics.setColor(1, 1, 1)

  if gameover then
     love.graphics.draw(die,world_w*32/2-die:getWidth()/2,world_h*32/2-die:getHeight()/2-100)
  end
end

function love.mousepressed( mouseXpx, mouseYpx, button, istouch, presses )
  -- x -- in pixels
  -- button 1=left, 2=right
  colnum = math.floor(mouseXpx / cellsize)
  if button == 1 then 
    ground_level[colnum] = ground_level[colnum]+1
  else 
    ground_level[colnum] = ground_level[colnum]-1
  end
end
  
function love.keypressed( key ) 
  if key == "f9" then
    i = 0
    for l in io.lines("world.txt") do
      ground_level[i] = tonumber(l)
      i = i+1
    end
  end

  if gameover then
    return
  end

  if key == "d" then
    if ground_level[playerX]>ground_level[playerX+1]+2 or playerX+1==world_w then
      sound_bonk:stop()
      sound_bonk:play()
    else
      if ground_level[playerX+1]-ground_level[playerX]>3 then
        hitpoints = hitpoints-1 
        sound_oof:stop()
        sound_oof:play()
      end

      playerX = playerX+1
      run = 1
      time_start_run = love.timer.getTime()
    end
  
  end

  
  if key == "a" then
    if playerX-1==-1 or ground_level[playerX]>ground_level[playerX-1]+2 then
      sound_bonk:stop()
      sound_bonk:play()
    else
      if ground_level[playerX-1]-ground_level[playerX]>3 then
        hitpoints = hitpoints-1
        sound_oof:play()
      end
      playerX = playerX-1
      run = 1
      time_start_run = love.timer.getTime()
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

  if key == "h" then
    for i=0,world_w do
      ground_level[i] = world_h/2
    end  
  
  end
end
