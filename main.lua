local playerX = 5
local playerY = 5
local cow = {x = 5, y = 5, speed_X=-1, speed_Y=0.}
local accel = 300
local run = 0
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
local game_seconds = 0
local last_tick = 0
local sprite = {}
local world = {}

--горнасть
function init_world()
  math.randomseed(os.time())
  math.random(0,10)
  for x = 0, world_w do
    world[x] = {}
    for y = 0, world_h do
      if y>-1 and y<20 then
        world[x][y] = 0
      else
        world[x][y] = math.random(2,3) 
      end               
      if y==20 then
        world[x][y] = 1
      end  
    end               
  end
end

function love.update(dt)
  gameover = hitpoints<1
  
  game_seconds = game_seconds + dt

  mouseXpx = love.mouse.getX()
  mouseX = math.floor(mouseXpx / cellsize)
  mouseYpx = love.mouse.getY()
  mouseY = math.floor(mouseYpx / cellsize)

  if love.keyboard.isDown("1") then
    world[mouseX][mouseY] = 1
  end


  if love.keyboard.isDown("2") then
    world[mouseX][mouseY] = 2
  end

  if love.keyboard.isDown("3") then
    world[mouseX][mouseY] = 3
  end

  if love.keyboard.isDown("4") then
    world[mouseX][mouseY] = 4
  end

  if love.keyboard.isDown("5") then
    world[mouseX][mouseY] = 5
  end

  if love.keyboard.isDown("6") then
    world[mouseX][mouseY] = 6
  end

  if love.keyboard.isDown("0") then
    world[mouseX][mouseY] = 0
  end
  
  if game_seconds > last_tick + 0.1 then
    -- tick
    newcowY = cow.y + cow.speed_Y
    newcowX = cow.x + cow.speed_X
    if ( newcowX>=0 and newcowX<world_w and newcowY>=0 and newcowY<world_h ) and ( world[newcowX][newcowY]==0 or world[newcowX][newcowY]==6 ) then
      cow.x = cow.x + cow.speed_X
      cow.y = cow.y + cow.speed_Y
    else
      sound_bonk:stop()
      sound_bonk:play()
      cow.speed_X = - cow.speed_X
      cow.speed_Y = - cow.speed_Y
    end
    last_tick = game_seconds
    if cow.x == playerX and cow.y == playerY then
      hitpoints=hitpoints-1
      sound_oof:stop()
      sound_oof:play()
    end  
  end
  
  now = love.timer.getTime()
  if now > time_start_run + 0.5 then
    last_set_ground = now
    run = 0
  end
end

function love.load()
  init_world()
  love.window.setTitle("Ноздря")
  love.window.setMode(cellsize * world_w, cellsize * world_h)
  
  sprite["dirt"] = love.graphics.newImage("dirt.png")
  sprite["grass"] = love.graphics.newImage("grass.png")
  Player = love.graphics.newImage("burger.png")
  Player2 = love.graphics.newImage("burger2.png")
  sprite["stone"]=love.graphics.newImage("stone.png")
  no = love.graphics.newImage("пустота.png")
  sprite["wood"] = love.graphics.newImage("wood.png")
  heart = love.graphics.newImage("heart.png")
  rip = love.graphics.newImage("tomb.png")
  die = love.graphics.newImage("gameover.png")
  stone_grass = love.graphics.newImage("stone_grass.png")
  rip_stone = love.graphics.newImage("tomb_cave.png")
  sprite["cow"] = love.graphics.newImage("cow.png")
  sprite["bricks"] = love.graphics.newImage("bricks.png")
  sprite["background"] = love.graphics.newImage("background.png")

  sound_bonk = love.audio.newSource("bonk.mp3", "static")
  sound_oof = love.audio.newSource("oof.mp3", "static")
  music = love.audio.newSource("music.mp3", "stream")
  love.audio.play(music)
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
  
 
  
  mouseXpx = love.mouse.getX()
  mouseX = math.floor(mouseXpx / cellsize)
  mouseYpx = love.mouse.getY()
  mouseY = math.floor(mouseYpx / cellsize)
  love.graphics.setColor(1, 0.5, 0.5)
  love.graphics.rectangle("line", mouseX*cellsize, mouseY*cellsize, cellsize, cellsize )
  love.graphics.setColor(1, 1, 1)
 
 
  -- 2d world
  for x = 0, world_w do
    for y = 0, world_h do
      sprite_to_draw = no
      if world[x][y] == 1 then
        sprite_to_draw = sprite["grass"]
      end
      if world[x][y] == 2 then
        sprite_to_draw = sprite["dirt"]
      end
      if world[x][y] == 3 then
        sprite_to_draw = sprite["stone"]
      end
      if world[x][y] == 4 then
        sprite_to_draw = sprite["bricks"]
      end 
      if world[x][y] == 5 then
        sprite_to_draw = sprite["wood"]
      end
      if world[x][y] == 6 then
        sprite_to_draw = sprite["background"]
      end
      
      love.graphics.draw(sprite_to_draw, cellsize*x, cellsize*y)
      --love.graphics.print(world[x][y], cellsize*x, cellsize*y)
    end
  end
  
  --cow
  love.graphics.draw(sprite.cow,cellsize*cow.x,cellsize*cow.y)
  
  --player
  if hitpoints<1 then
    -- dead
    if playerY<30 then
      love.graphics.draw(rip, cellsize*playerX, cellsize*playerY)
    else
      love.graphics.draw(rip_stone, cellsize*playerX, cellsize*playerY)
    end
  elseif run==0 then    
    love.graphics.draw(Player, cellsize*playerX, cellsize*playerY )
  else 
    love.graphics.draw(Player2, cellsize*playerX, cellsize*playerY )
  end
  --Жижа
  for hit=1,hitpoints do
    love.graphics.draw(heart,cellsize*hit,cellsize*2)
  end
  if gameover then
    love.graphics.draw(die,world_w*32/2-die:getWidth()/2,world_h*32/2-die:getHeight()/2-100)
 end
end

function love.mousepressed( mouseXpx, mouseYpx, button, istouch, presses )
  -- x -- in pixels
  -- button 1=left, 2=right
  colnum = math.floor(mouseXpx / cellsize)
  rownum = math.floor(mouseYpx / cellsize)
  
  if button == 1 then 
    world[colnum][rownum] = world[colnum][rownum] + 1
  else 
    if world[colnum][rownum] > 0 then
      world[colnum][rownum] = world[colnum][rownum] - 1
    end  
  end
  if world[colnum][rownum] > 5 then
    world[colnum][rownum] = world[colnum][rownum] - 1
  end  
end

function player_tp(targetX, targetY)
  playerX, playerY = targetX, targetY
end

function love.keypressed( key ) 
  if key == "f9" then
    file = io.open("world.txt", "r")
    -- sets the default output file as test.lua
    io.input(file)
    i = 0
    playerX = io.read("*number")
    playerY = io.read("*number")
    hitpoints = io.read("*number")
    for i = 0, world_h-1 do
      for XD = 0, world_w-1 do
        world[XD][i] = io.read("*number")      
      end
    end
   
    io.close(file)
  end

  if gameover then
    return
  end
  
  newX=playerX
  newY=playerY 
  if key == "d" then
    newX = playerX+1
  end
  if key == "a" then
    newX = playerX-1
  end
  if key == "w" then
    newY = playerY-1
  end
  if key == "s" then
    newY = playerY+1
  end
  if key == "g" then
    init_world()
  end
  mouseXpx = love.mouse.getX()
  mouseX = math.floor(mouseXpx / cellsize)
  mouseYpx = love.mouse.getY()
  mouseY = math.floor(mouseYpx / cellsize)

  if key == "c" then
    cow.x = mouseX
    cow.y = mouseY
  end

  if world[newX][newY] == 0 or world[newX][newY] == 6 then
    player_tp(newX,newY) 
    run = 1
    time_start_run = love.timer.getTime()
  else
    -- cant go
    sound_bonk:stop()
    sound_bonk:play()
    
  end

  if key == "f5" then
    -- Opens a file in append mode
    file = io.open("world.txt", "w")    
    -- sets the default output file as test.lua
    io.output(file)
    io.write(playerX)
    io.write("\n")
    io.write(playerY)
    io.write("\n")
    io.write(hitpoints)
    io.write("\n")
    for i = 0, world_h-1 do
      for XD = 0, world_w-1 do
        io.write(world[XD][i])
        io.write(" ")
      end
      io.write("\n")
    end
    
    -- closes the open file
    io.close(file)
  end 
end
--XD