local playerX = 5
local playerY = 5
local run = 0
local cellsize = 32
local room_w = 70
local room_h = 40
local world_w = 3 * room_w
local world_h = 5 * room_h
local dange_h = 9
local dange_w = 8
local cave_h = 9
local cave_w = 9
local cave2_h = 11
local cave2_w = 19
local tree_h = 2
local tree_w = 8
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
local blocks = {}
local boss_live = 30
game_mode = "mainmenu"
blocks[0] = { number = 0, set_key = "0", sprite = nil, passable = true, breakable = false, collectable = false, pushable = false }
blocks[1] = { number = 1, set_key = "1", sprite = "grass.png", passable = false, breakable = true, collectable = false, pushable = false }
blocks[2] = { number = 2, set_key = "2", sprite = "dirt.png", passable = false, breakable = true, collectable = false, pushable = false }
blocks[3] = { number = 3, set_key = "3", sprite = "stone.png", passable = false, breakable = false, collectable = false, pushable = false }
blocks[4] = { number = 4, set_key = "4", sprite = "bricks.png", passable = false, breakable = true, collectable = false, pushable = false }
blocks[5] = { number = 5, set_key = "5", sprite = "wood.png", passable = false, breakable = true, collectable = false, pushable = false }
blocks[6] = { number = 6, set_key = "6", sprite = "background.png", passable = true, breakable = false, collectable = false, pushable = false }
blocks[9] = { number = 9, set_key = "_", sprite = "sword.png", passable = true, breakable = false, collectable = true, pushable = false }
blocks[8] = { number = 8, set_key = "_", sprite = "gold_ore.png", passable = false, breakable = true, collectable = false, pushable = false }
blocks[7] = { number = 7, set_key = "_", sprite = "pick.png", passable = true, breakable = false, collectable = true, pushable = false }
blocks[10] = { number = 10, set_key = "_", sprite = "sheld.png", passable = true, breakable = false, collectable = true, pushable = false }
blocks[11] = { number = 11, set_key = "7", sprite = "pepper.png", passable = true, breakable = false, collectable = true, pushable = false }
blocks[12] = { number = 12, set_key = "8", sprite = "myaso.png", passable = true, breakable = false, collectable = true, pushable = false }

local inv = {}
inv[9]=666
inv[7]=666
inv[1]=1
inv[2]=5
inv[5]=0
inv[4]=0
inv[8]=0
inv[3]=0
inv[10]=666
local mobs = {}
mobs[1] = {x = 25, y = 5, speed_X=-1, speed_Y=0, bonks_left = 15, mob_type = "cow"}
mobs[2] = {x = 25, y = 15, speed_X=-1, speed_Y=0, bonks_left = 66, mob_type = "boss"}
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
        stonks = {2,2,2,3,8}
        idx = math.random(1,#stonks)
        world[x][y] = stonks[idx]
      end
      if y==20 then
        world[x][y] = 1
      end
    end
  end
  --dange
  

  file = io.open("cave 2", "r")
  -- sets the default output file as test.lua
  io.input(file)
    cave2X=math.random(0,world_w-cave2_w)
    cave2Y=math.random(23,world_h-cave2_h)
  for i = 0, cave2_h-1 do
    for XD = 0, cave2_w-1 do
      world[XD+cave2X][i+cave2Y] = io.read("*number")
    end
  end
  io.close(file)
  dangeX=math.random(0,world_w-dange_w)
  dangeY=math.random(23,world_h-dange_h)

  file = io.open("dange.txt", "r")
  -- sets the default output file as test.lua
  io.input(file)

  for i = 0, dange_h-1 do
    for XD = 0, dange_w-1 do
      world[XD+dangeX][i+dangeY] = io.read("*number")
    end
  end
  io.close(file)

  file = io.open("cave", "r")
  -- sets the default output file as test.lua
  io.input(file)
  caveX=math.random(0,world_w-dange_w)
  caveY=math.random(23,world_h-dange_h)

  for i = 0, cave_h-1 do
    for XD = 0, cave_w-1 do
      world[XD+caveX][i+caveY] = io.read("*number")
    end
  end
  io.close(file)

  file = io.open("tree","r")
  io.input(file)
  treeX=math.random(0,world_w-dange_w)
  treeY=18

  for i = 0, tree_h-1 do
    for XD = 0, tree_w-1 do
      world[XD+treeX][i+treeY] = io.read("*number")
    end
  end
  io.close(file)
end

function can_walk(x,y)
  return ( x>=0 and x<world_w and y>=0 and y<world_h ) and blocks[world[x][y]].passable
end

function love.update(dt)
  if game_mode == "mainmenu" then
    return
  end    
  gameover = hitpoints<1

  game_seconds = game_seconds + dt

  mouseXpx = love.mouse.getX()
  mouseX = math.floor(mouseXpx / cellsize)
  mouseYpx = love.mouse.getY()
  mouseY = math.floor(mouseYpx / cellsize)

  for i, bl in pairs(blocks) do   
    if love.keyboard.isDown( bl.set_key ) then
      world[this_room_start_x+mouseX][this_room_start_y+mouseY] = i
    end
  end

  if game_seconds > last_tick + 0.3 then
    -- tick
    for i, mob in ipairs(mobs) do
      if playerX>mob.x then
        mob.speed_X=1
      elseif playerX == mob.x then
        mob.speed_X = 0
      else
        mob.speed_X=-1
      end

      if playerY > mob.y then
        mob.speed_Y=1
      elseif playerY == mob.y then
        mob.speed_Y = 0
      else
        mob.speed_Y = -1
      end
      newcowX = mob.x + mob.speed_X
      newcowY = mob.y + mob.speed_Y
      if mob["mob_type"] == "cow" then
        if can_walk(newcowX, newcowY) then
          mob.x = mob.x + mob.speed_X
          mob.y = mob.y + mob.speed_Y
        else
          if mob.bonks_left > 0 then
            sound_bonk:stop()
            sound_bonk:play()
            mob.bonks_left = mob.bonks_left -1
          end
          mob.speed_X = - mob.speed_X
          mob.speed_Y = - mob.speed_Y
        end
      else
        --boss run
        if (newcowX >= 0 and newcowX<world_w and newcowY >= 0 and newcowY<world_h) and blocks[world[newcowX][newcowY]].breakable then
          world[newcowX][newcowY] = 0
        end
        if can_walk(newcowX, newcowY) then
          mob.x = newcowX
          mob.y = newcowY
        end
      end

      last_tick = game_seconds
      damage=1
      if mob["mob_type"]=="boss" then
        damage=3
      end
      if mob.x == playerX and mob.y == playerY then
        if inv[9]>0 and inv[10]<0 and mob["mob_type"]=="cow" then
            inv[9]=inv[9]-1
            hitpoints=hitpoints-damage
            sound_oof:stop()
            sound_oof:play()
            table.remove (mobs,i)
        elseif mob["mob_type"]=="boss" and inv[9]>0 and inv[10]<0 then
            boss_live = boss_live-1
            inv[9]=inv[9]-1
            hitpoints=hitpoints-damage
            sound_oof:stop()
            sound_oof:play()
        elseif inv[9]>0 and inv[10]>0 and mob["mob_type"]=="cow" then
          inv[9]=inv[9]-1
          inv[10]=inv[10]-damage
          table.remove (mobs,i)
        elseif mob["mob_type"]=="boss" and inv[9]>0 and inv[10]>0 then
          boss_live = boss_live-1
          if boss_live<1 then
            table.remove (mobs,i)
          end
          inv[9]=inv[9]-1
          inv[10]=inv[10]-damage
        elseif inv[9]<0 and inv[10]>0 then
          inv[10]=inv[10]-damage
        else
          hitpoints=hitpoints-damage
          sound_oof:stop()
          sound_oof:play()
        end
      end
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
  love.window.setMode(cellsize * room_w, cellsize * room_h)

  Player = love.graphics.newImage("burger.png")
  Player2 = love.graphics.newImage("burger2.png")
  heart = love.graphics.newImage("heart.png")
  rip = love.graphics.newImage("tomb.png")
  die = love.graphics.newImage("gameover.png")
  sprite["cow"] = love.graphics.newImage("cow.png")
  rip_stone = love.graphics.newImage("tomb_cave.png")
  boss_herht = love.graphics.newImage("1_BOSS_HERHT.png")
  sprite["boss"] = love.graphics.newImage("1_BOSS.png")
  boss_sh = love.graphics.newImage("1_BOSS_SH.png")
  boss_oof = love.graphics.newImage("1_BOSS_OOF.png")
  nose = love.graphics.newImage("nozdrya.jpg")

  for i, bl in pairs(blocks) do
    if bl.sprite then
      bl.img = love.graphics.newImage(bl.sprite)
    end
  end

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

  this_room_start_x = room_w * math.floor(playerX/room_w)
  this_room_start_y = room_h * math.floor(playerY/room_h)
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
  for x = 0, room_w do
    for y = 0, room_h do
      sprite_to_draw = blocks[ world[this_room_start_x+x][this_room_start_y+y] ].img
      if sprite_to_draw then
        love.graphics.draw(sprite_to_draw, cellsize*x, cellsize*y)
      end
    end
  end

  love.graphics.print(game_mode, cellsize*10,cellsize*10, 0, 2)

  -- mobs
  for i, mob in pairs(mobs) do
    if mob ["mob_type"] == "boss" then
      love.graphics.draw(sprite.boss, cellsize*(mob.x-this_room_start_x)-16, cellsize*(mob.y-this_room_start_y)-16)
    else
      love.graphics.draw(sprite.cow, cellsize * (mob.x-this_room_start_x), cellsize*(mob.y-this_room_start_y))
    end
  end

  --player
  player_sprite = Player
  if hitpoints<1 then
    -- dead
    if playerY<30 then
      player_sprite = rip
    else
      player_sprite = rip_stone
    end
  elseif run==0 then
    player_sprite = Player
  else
    player_sprite = Player2
  end
  love.graphics.draw(player_sprite, cellsize*(playerX-this_room_start_x), cellsize*(playerY-this_room_start_y) )

  --Жижа
  for hit=1,hitpoints do
    love.graphics.draw(heart,cellsize*hit,cellsize)
  end



  --boss ЖИЖА!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  for boss_live=1,boss_live do
    love.graphics.draw(boss_herht,cellsize*boss_live,cellsize,cellsize*180)
  end
  e = 2*2



  for what, num in pairs(inv) do
    love.graphics.draw(blocks[what].img,cellsize,cellsize*e)
    love.graphics.print(" x "..inv[what], cellsize*2,cellsize*e, 0, 2)
    e = e+2
  end
  if gameover then
    love.graphics.draw(die,room_w*32/2-die:getWidth()/2,room_h*32/2-die:getHeight()/2-100)
  end
  if game_mode == "mainmenu" then
    a = nose:getWidth()/2
    b = room_w * cellsize
    cx = (b-a)/2
    love.graphics.draw(nose, cx ,0 , 0, 0.5) 
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

  if key == "escape" then
    if  game_mode == "mainmenu" then   
      game_mode = "play"
    else
      game_mode = "mainmenu" 
    end    
  end

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
  if game_mode == "mainmenu" then
    return
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
    newcow = {x = mouseX+this_room_start_x, y = mouseY+this_room_start_y, speed_X=-1, speed_Y=0, bonks_left = 15}
    table.insert(mobs, newcow)
  end

  if (newX >= 0 and newX<world_w and newY >= 0 and newY<world_h) and blocks[world[newX][newY]].breakable then
    item = world[newX][newY]
    -- FIXME check if inventory entry present
    if inv[7]>0 then
      inv[7]=inv[7]-1

      if inv[item] == nil then
        inv[item] = 0
      end
      if item == 11 then
        hitpoints=hitpoints+1
      else
        inv[item] = inv[item] + 1
        world[newX][newY] = 0
      end
    else
    end
  end

  if can_walk(newX, newY) then
    item = world[newX][newY]
    player_tp(newX,newY)
    if blocks[world[newX][newY]].collectable then
      if item == 11 or item == 12 then
        hitpoints=hitpoints+1
      else
        if inv[item] == nil then
          inv[item] = 0
        end

        -- add to inventory
        inv[item] = inv[item] + 10
      end
      world[newX][newY] = 0
    end
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
  if key=="p" then
    if inv[8]>4 then
      if inv[5]>0 then
        inv[8]=inv[8]-5
        inv[5]=inv[5]-1
        inv[9]=inv[9]+10
      end
    end
  end
  if key=="o" then
    if inv[2]>4 then
      if inv[5]>0 then
        inv[2]=inv[2]-5
        inv[5]=inv[5]-1
        inv[7]=inv[7]+10
      end
    end
  end
end
--XD
--stonks
--LINK
