local playerX = 5
local playerY = 5
local run = 0
local cellsize = 32
local room_w = 70
local room_h = 40
local world_w = 5 * room_w
local world_h = 8 * room_h
local dange_h = 9
local dange_w = 8
local cave_h = 9
local cave_w = 9
local cave2_h = 11
local cave2_w = 19
local tree_h = 8
local tree_w = 8
local ogorod_h = 2
local ogorod_w = 11
local time_start_run = 0
local start_time = love.timer.getTime()
local last_set_ground = start_time - 1
local offset = 0
local jump_stop = 0
local hitpoints = 10
local game_over = false
local armor_type = 0
local game_seconds = 0
local last_tick = 0
local sprite = {}
local world = {}
local blocks = {}
local boss_live = 10
local storona = 0
local selected_craft_number = "nothing"
game_mode = "craft"
blocks[0]  = { number =  0, name = "nil", set_key = "0", sprite = nil, passable = true, breakable = false, collectable = false, pushable = false }
blocks[1]  = { number =  1, name = "grass", set_key = "1", sprite = "grass.png", passable = false, breakable = true, collectable = false, pushable = false }
blocks[2]  = { number =  2, name = "dirt", set_key = "2", sprite = "dirt.png", passable = false, breakable = true, collectable = false, pushable = false }
blocks[3]  = { number =  3, name = "stone", set_key = "3", sprite = "stone.png", passable = false, breakable = true, collectable = false, pushable = false }
blocks[4]  = { number =  4, name = "bricks", set_key = "4", sprite = "bricks.png", passable = false, breakable = true, collectable = false, pushable = false }
blocks[5]  = { number =  5, name = "wood", set_key = "5", sprite = "wood.png", passable = false, breakable = true, collectable = false, pushable = false }
blocks[6]  = { number =  6, name = "background", set_key = "6", sprite = "background.png", passable = true, breakable = false, collectable = false, pushable = false }
blocks[9]  = { number =  9, name = "sword", set_key = "_", sprite = "sword.png", passable = true, breakable = false, collectable = true, pushable = false }
blocks[8]  = { number =  8, name = "gold_ore", set_key = "_", sprite = "gold_ore.png", passable = false, breakable = true, collectable = false, pushable = false }
blocks[7]  = { number =  7, name = "pick", set_key = "_", sprite = "pick.png", passable = true, breakable = false, collectable = true, pushable = false }
blocks[10] = { number = 10, name = "shield", set_key = "_", sprite = "sheld.png", passable = true, breakable = false, collectable = true, pushable = false }
blocks[11] = { number = 11, name = "pepper", set_key = "_", sprite = "pepper.png", passable = true, breakable = false, collectable = true, pushable = false }
blocks[12] = { number = 12, name = "meat", set_key = "_", sprite = "myaso.png", passable = true, breakable = false, collectable = true, pushable = false }
blocks[13] = { number = 13, name = "water", set_key = "9", sprite = "water.png", passable = true, breakable = false, collectable = true, pushable = false }
blocks[14] = { number = 14, name = "chest", set_key = "/", sprite = "chest.png", passable = false, breakable = false, collectable = false, pushable = true }
blocks[15] = { number = 15, name = "boom1", set_key = "=", sprite = "Boom1.png", passable = true, breakable = false, collectable = false, pushable = false }
blocks[16] = { number = 16, name = "boom2", set_key = "=", sprite = "Boom2.png", passable = true, breakable = false, collectable = false, pushable = false }
for bombs = 17,25 do
  blocks[bombs] = { number = bombs, name = "bomb", set_key = ".", sprite = "TNTboom.png", passable = false, breakable = false, collectable = false, pushable = true }
end
blocks[26] = { number = 26, name = "leaves", set_key = "\\", sprite = "leaves.png", passable = true, breakable = true, collectable = true, pushable = false }
blocks[27] = { number = 27, name = "stone_and_ice", set_key = "\\", sprite = "stone and ice.png", passable = false, breakable = true, collectable = true, pushable = false }
blocks[28] = { number = 28, name = "furnace_for_pizza_no_active", set_key = "8", sprite = "furnaceforpizzanoactive.png", passable = true, breakable = false, collectable = false, pushable = false }
blocks[29] = { number = 29, name = "iron", set_key = "_", sprite = "iron.png", passable = false, breakable = true, collectable = false, pushable = false }

local inv = {}
inv[9]=666
inv[7]=666
inv[1]=1
inv[2]=5
inv[5]=0
inv[4]=0
inv[8]=2
inv[3]=0
inv[10]=666
local mobs = {}
mobs[1] = {x = 25, y = 5, max_hitpoints = 5, hitpoints = 3, bonks_left = 15, mob_type = "cow"}
mobs[2] = {x = 25, y = 15, max_hitpoints = 30, hitpoints = 10, bonks_left = 66, mob_type = "boss"}
mobs[3] = {x = 25, y = 10, max_hitpoints = 5, hitpoints = 3, bonks_left = 15, mob_type = "pig"}

recipes = {}
table.insert(recipes, {ins = { {'wood', 3}, {'gold_ore', 1} }, outs = { {'shield', 10}}})
table.insert(recipes, {ins = { {"dirt" , 2}, {"gold_ore" , 2} }, outs = { {"pick" , 20}}})
table.insert(recipes, {ins = { {"wood" , 10}, {"gold_ore" , 30} }, outs = { {"sword" , 15}}})
table.insert(recipes, {ins = { {'wood', 1}, {'bricks', 4} }, outs = { {'dirt', 10}}})
table.insert(recipes, {ins = { {'wood', 5}, {'gold_ore', 1} }, outs = { {'dirt', 10}}})
table.insert(recipes, {ins = { {'wood', 2}, {'stone', 1} }, outs = { {'dirt', 10}}})

function explosion(x,y,exbl)
  for ex=x-5,x+5 do
    for ey=y-5,y+5 do
      if in_world(ex,ey) then
        world[ex][ey] = exbl
      end  
    end
  end

  world[x][y] = 1
end

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
  tree_number=12
  for room_number=0, tree_number-1 do
    file = io.open("tree","r")
    io.input(file)
    treeX=math.random(0,70*5)                            --(room_w*room_number, room_w*(room_number+1)-1-tree_w)
    treeY=12

    for i = 0, tree_h-1 do
      for XD = 0, tree_w-1 do
        if in_world(XD+treeX, i+treeY) then
          world[XD+treeX][i+treeY] = io.read("*number")
        end  
      end
    end
    io.close(file)
  end  
  
    file = io.open("ogorod","r")
    io.input(file)
    ogorodX=math.random(0,70*5)                            --(room_w*room_number, room_w*(room_number+1)-1-tree_w)
    ogorodY=18

    for i = 0, ogorod_h-1 do
      for XD = 0, ogorod_w-1 do
        if in_world(XD+ogorodX, i+ogorodY) then
          world[XD+ogorodX][i+ogorodY] = io.read("*number")
        end  
      end
    end
    io.close(file)

  explosion(10,10,16)
end

function in_world(x,y)
  return ( x>=0 and x<world_w and y>=0 and y<world_h )
end

function can_walk(x,y)
  return in_world(x,y) and blocks[world[x][y]].passable
end

function love.update(dt)

  if game_mode ~= "play" then
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
    sword = {}
    sword.x=playerX
    sword.y=playerY
    if storona == "up" then
      sword.y = sword.y-1
    elseif storona == "down" then
      sword.y = sword.y+1
    elseif storona == "left" then
      sword.x = sword.x-1
    elseif storona == "right" then
      sword.x = sword.x+1
    end
    storona = 0
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

      if mob["mob_type"] == "cow" then
        newmobX = mob.x + mob.speed_X
        newmobY = mob.y + mob.speed_Y
        if can_walk(newmobX, newmobY) then
          mob.x = newmobX
          mob.y = newmobY
        else
          if mob.bonks_left > 0 then
            sound_bonk:stop()
            sound_bonk:play()
            mob.bonks_left = mob.bonks_left -1
          end
        end
        damage=1
      elseif mob["mob_type"] == "boss" then
        --boss run
        newmobX = mob.x + mob.speed_X
        newmobY = mob.y + mob.speed_Y
        if (newmobX >= 0 and newmobX<world_w and newmobY >= 0 and newmobY<world_h) and blocks[world[newmobX][newmobY]].breakable then
          world[newmobX][newmobY] = 0
        end
        if can_walk(newmobX, newmobY) then
          mob.x = newmobX
          mob.y = newmobY
        end
      elseif mob["mob_type"] == "pig" then
        newmobX = mob.x - mob.speed_X
        newmobY = mob.y - mob.speed_Y
        if can_walk(newmobX, newmobY) then
          mob.x = newmobX
          mob.y = newmobY
          damage=0
        else
          if mob.bonks_left > 0 then
            sound_bonk:stop()
            sound_bonk:play()
            mob.bonks_left = mob.bonks_left -1
          end
        end
      end

      mob_damage = { boss = 3, cow = 1, pig = 0 }
      damage=mob_damage[ mob["mob_type"] ]

      if inv[10]>0 then
       if playerY==mob.y and playerX==mob.x then
        inv[10]=inv[10]-damage
       end
      else
        hitpoints=hitpoints-1
        sound_oof:stop()
        sound_oof:play()
      end

      if inv[9]>0 and sword.y==mob.y and sword.x==mob.x then
        mob.hitpoints=mob.hitpoints-1
        inv[9]=inv[9]-1
      end
      if mob.hitpoints<1 then
        table.remove (mobs,i)
        world[mob.x][mob.y]=12
      end
    end
    -- done with mobs

    -- bomb update
    for x = 0, world_w do
      for y = 0, world_h do
        if world[x][y]==15 then
          world[x][y]=0
        elseif world[x][y] >15 and world[x][y] <=25 then
          world[x][y]=world[x][y]-1
          if world[x][y]==16 then
            explosion(x,y,16)
            sound_boom:play()
          end
        end
      end
    end

    last_tick = game_seconds


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
  sprite["pig"] = love.graphics.newImage("pig.png")
  sprite["armor1"] = love.graphics.newImage("armor1.png")
  sprite["armor2"] = love.graphics.newImage("armor2.png")
  rip_stone = love.graphics.newImage("tomb_cave.png")
  boss_herht = love.graphics.newImage("1_BOSS_HERHT.png")
  sprite["boss"] = love.graphics.newImage("1_BOSS.png")
  boss_sh = love.graphics.newImage("1_BOSS_SH.png")
  boss_oof = love.graphics.newImage("1_BOSS_OOF.png")
  nose = love.graphics.newImage("nozdrya.jpg")
  moon = love.graphics.newImage("moon.png")
  sun = love.graphics.newImage("sun.png")
  trap_1 = love.graphics.newImage("its a trap!.png")
  trap_2 = love.graphics.newImage("its a trap! 2 .png")
  swordup = love.graphics.newImage("swordup.png")
  craft_title = love.graphics.newImage("craft title.png")
  for i, bl in pairs(blocks) do
    if bl.sprite then
      bl.img = love.graphics.newImage(bl.sprite)
    end
  end
  sound_boom = love.audio.newSource("boom.ogg", "static")
  sound_bonk = love.audio.newSource("bonk.mp3", "static")
  sound_oof = love.audio.newSource("oof.mp3", "static")
  music = love.audio.newSource("music.mp3", "stream")
  --love.audio.play(music)
end

function love.draw()
  local sunnight = sun and night
  local day_plus_night = 240
  local daytime = game_seconds % day_plus_night
  if daytime < day_plus_night / 2 then
    sunnight = sun
    red = 13/100
    green = 68/100
    blue = 96/100
    alpha = 0/100
  else
    sunnight = moon
    red = 11/100
    green = 12/100
    blue = 29/100
    alpha = 0/100
  end


  love.graphics.setBackgroundColor( red, green, blue, alpha)

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
      block_to_draw = blocks[ world[this_room_start_x+x][this_room_start_y+y] ]
      local sprite_to_draw = block_to_draw.img
      if block_to_draw.sprite == "water.png" then
        quad = love.graphics.newQuad( math.floor(game_seconds*30) % 32, 0, 32, 32, sprite_to_draw )
        love.graphics.draw(sprite_to_draw, quad, cellsize*x, cellsize*y)
      elseif block_to_draw.number >=15 and block_to_draw.number <=25 then
        love.graphics.draw(sprite_to_draw, cellsize*x, cellsize*y)
        love.graphics.print(block_to_draw.number-15,cellsize*x, cellsize*y )
      elseif sprite_to_draw then
        love.graphics.draw(sprite_to_draw, cellsize*x, cellsize*y)
      end

    end
  end

  love.graphics.print(game_mode, cellsize*10,cellsize*10, 0, 2)
  love.graphics.print(storona, cellsize*12,cellsize*10, 0, 2)
  -- mobs
  for i, mob in pairs(mobs) do
    if mob ["mob_type"] == "boss" then
      love.graphics.draw(sprite.boss, cellsize*(mob.x-this_room_start_x), cellsize*(mob.y-this_room_start_y))
    elseif mob ["mob_type"] == "cow" then
      love.graphics.draw(sprite.cow, cellsize * (mob.x-this_room_start_x), cellsize*(mob.y-this_room_start_y))
    elseif mob ["mob_type"] == "pig" then
      love.graphics.draw(sprite.pig, cellsize * (mob.x-this_room_start_x), cellsize*(mob.y-this_room_start_y))
    end
    love.graphics.print(mob.hitpoints,cellsize*(mob.x-this_room_start_x), cellsize*(mob.y-this_room_start_y))
  end

  if storona == "up" then
    love.graphics.draw(swordup, cellsize*(playerX-this_room_start_x), cellsize*(playerY-1-this_room_start_y) )
  elseif storona == "down" then
    love.graphics.draw(swordup, cellsize*(playerX-this_room_start_x), cellsize*(playerY+1-this_room_start_y), math.rad(180), 1, 1, 32, 32 )
  elseif storona == "left" then
    love.graphics.draw(swordup, cellsize*(playerX-1-this_room_start_x), cellsize*(playerY-this_room_start_y), math.rad(270), 1, 1, 32, 0 )
  elseif storona == "right" then
    love.graphics.draw(swordup, cellsize*(playerX+1-this_room_start_x), cellsize*(playerY-this_room_start_y), math.rad(90), 1, 1, 0, 32  )
  end
  --player
  player_sprite = Player
  armor_sprite = nil
  if hitpoints<1 then
    -- dead
    if playerY<30 then
      player_sprite = rip
    else
      player_sprite = rip_stone
    end
  elseif run==0 then
    player_sprite = Player
    if armor_type > 0 then
      armor_sprite = sprite["armor" .. armor_type]
    end
  else
    player_sprite = Player2
    if armor_type > 0 then
      armor_sprite = sprite["armor" .. armor_type]
    end
  end
  love.graphics.draw(player_sprite, cellsize*(playerX-this_room_start_x), cellsize*(playerY-this_room_start_y) )
  if armor_sprite then
    love.graphics.draw(armor_sprite, cellsize*(playerX-this_room_start_x), cellsize*(playerY-this_room_start_y) )
  end

  --Жижа
  for hit=1,hitpoints do
    love.graphics.draw(heart,cellsize*hit,cellsize)
  end

  -- SUN!
  local sunpos = ( game_seconds % (day_plus_night / 2) ) / (day_plus_night / 2)
  love.graphics.print(sunpos, cellsize*10,cellsize*11, 0, 2)
  love.graphics.draw(sunnight,sunpos*room_w*cellsize,cellsize*3)

  e = 2*2
  --inv
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
  
  if game_mode == "craft" then
    -- print selected craft
    love.graphics.print(selected_craft_number,8,8)

    a = craft_title:getWidth()
    b = room_w * cellsize
    cx = (b-a)/2
    love.graphics.draw(craft_title, cx ,0 , 0.1, 1.0)

    recipe_number=1
    selected_craft_number="nothing"
    for y=0,1 do
      for x=0,4 do
        draw_recipe(recipe_number, 320*(x+1),320*(y+1))
        recipe_number=recipe_number+1
      end
    end  
  end
end

function find_block_by_name(name)
  for B=0,#blocks do
    if blocks[B]["name"]==name then
      return blocks[B]
    end  
  end  
end

function draw_recipe(recipe_number, x,y)
  if recipe_number%2>0 then
    love.graphics.setColor(1, 1, 1)
  else
    love.graphics.setColor(0,1,1)  
  end  
  love.graphics.rectangle("fill",x,y,320,320,10,10)
  love.graphics.setColor(0, 0, 0)
  if recipe_number > #recipes then
    return
  end
  first_out = recipes[recipe_number]["outs"][1]
  out_what, out_num = first_out[1], first_out[2]

  in1 = recipes[recipe_number]["ins"][1]
  in1_what, in1_num = in1[1], in1[2]
  in2 = recipes[recipe_number]["ins"][2]
  in2_what, in2_num = in2[1], in2[2]

  local sprite_to_draw = find_block_by_name(out_what)["img"]
  local sprite_in1 = find_block_by_name(in1_what)["img"]
  local sprite_in2 = find_block_by_name(in2_what)["img"]

  love.graphics.print("X"..out_num,x+200,y+80,0,4)
  love.graphics.print("X",x+(32*2.5),y+(32*7),0,2)
  love.graphics.print("X",x+(32*5.5),y+(32*7),0,2)

  love.graphics.setColor(1,0,1) 
  love.graphics.rectangle("line",x+32,y+32,32*5,32*5,10,10)
  love.graphics.setLineWidth( 3 )
  love.graphics.rectangle("line",x+(32*4),y+(32*7),32*1,32*1,0,10)
  love.graphics.rectangle("line",x+32,y+(32*7),32*1,32*1,0,10)
  love.graphics.setLineWidth( 1 )
  love.graphics.setColor(1,1,1) 
  love.graphics.draw(sprite_to_draw,x+32,y+32,0,5,5)
  love.graphics.draw(sprite_in1,x+(32*4),y+(32*7))
  love.graphics.draw(sprite_in2,x+32,y+(32*7))
  love.graphics.setColor(0,0,0) 
  love.graphics.print(in1_num,x+(32*3),y+(32*7),0,2)
  love.graphics.print(in2_num,x+(32*6),y+(32*7),0,2)
  --обводка
  mouseXpx = love.mouse.getX()
  mouseYpx = love.mouse.getY()
 
  if mouseXpx>x and mouseYpx>y and mouseXpx<x+320 and mouseYpx<y+320 then
    selected_craft_number=recipe_number
    if enough_for(recipe_number) then
      love.graphics.setColor(0,0.5,0)
    else
      love.graphics.setColor(1,0,0)  
    end  
    love.graphics.setLineWidth( 10 ) 
    love.graphics.rectangle("line",x,y,320-5,320-5,10,10)
    love.graphics.setLineWidth( 1 )
    love.graphics.setColor(0,0,0)
  end  
end  
--table.insert(recipes, {ins = { {"wood" , 1}, {"gold_ore" , 3} }, outs = { {"sword" , 15}}})
function enough_for(recipe_number) 
  for i, in_rec in pairs(recipes[recipe_number]["ins"]) do
    in_what_word, in_num = in_rec[1], in_rec[2]
  end  
  aaa=find_block_by_name(in_what_word)["number"]
  --for  do
    if inv[aaa]>=in_num then
      result = 1
    elseif inv[aaa]<in_num then
      result = false
    end  
  --end  
  return result
end
function remove_ins(recipe_number)

end  

function love.mousepressed( mouseXpx, mouseYpx, button, istouch, presses )
  -- x -- in pixels
  -- button 1=left, 2=right
  colnum = math.floor(mouseXpx / cellsize)
  rownum = math.floor(mouseYpx / cellsize)
  if game_mode == "play" then
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
 
  if game_mode == "craft" then
    if selected_craft_number=="nothing" then
    else
      if enough_for(selected_craft_number) then
        -- add out1
        first_out = recipes[selected_craft_number]["outs"][1]
        out_what, out_num = first_out[1], first_out[2]
        rrr=find_block_by_name(out_what)["number"]
        inv[rrr]=inv[rrr]+out_num

        remove_ins(selected_craft_number)
      else
        --недостаточно  
        sound_bonk:stop()
        sound_bonk:play()
      end  
    end    
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
  
  if key == "k" then    
    if  game_mode == "craft" then
      game_mode = "play"
    else
      game_mode = "craft"
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

  if game_mode ~= "play" then
    return
  end
  if gameover then
    return
  end
  -- everything after this only works in PLAY

  if key == "f12" then
    armor_type = armor_type + 1
    if armor_type > 2 then
      armor_type = 0
    end
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

  if key == "up" then
    storona = "up"
  elseif key == "down" then
    storona = "down"
  elseif key == "left" then
    storona = "left"
  elseif key == "right" then
    storona = "right"
  end

  mouseXpx = love.mouse.getX()
  mouseX = math.floor(mouseXpx / cellsize)
  mouseYpx = love.mouse.getY()
  mouseY = math.floor(mouseYpx / cellsize)

  if key == "c" then
    newcow = {x = mouseX+this_room_start_x, y = mouseY+this_room_start_y,max_hitpoints = 5, hitpoints = 5, bonks_left = 15, mob_type = "cow"}
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

  if in_world(newX, newY) and blocks[world[newX][newY]].pushable then
    newX2 = newX+newX-playerX
    newY2 = newY+newY-playerY
    if world[newX2][newY2]==0 then
      world[newX2][newY2]=world[newX][newY]
      world[newX][newY]=0
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
  --кирки
  if key=="o" then
    if inv[2]>4 then
      if inv[5]>0 then
        inv[2]=inv[2]-5
        inv[8]=inv[8]-1
        inv[7]=inv[7]+10
      end
    end
  end
end