local bump = require 'bump'
local tie = {x=400, y=400, w=16, h=16, dx=0, dy=0, speed=1.5, angle=0, turnSpeed = 2, fireDelay = .5, timeFire = 0, bulletSpeed = 100, lives = 5}
local xwing = {x=500, y=500, w=16, h=16, dx=0, dy=0, speed=1.5, angle=0, turnSpeed = 2, fireDelay = .5, timeFire = 0, bulletSpeed = 100, lives = 5}
local world
love.graphics.setDefaultFilter("nearest")
local tieFilter = function(item, other)
  if other.isxwing then
    --world:remove(other)
    item.lives = item.lives - 1 
    return 'cross'
  end
  return "cross"
end
local xwingFilter = function(item, other)
  if other.istie then 
    --world:remove(other)
    item.lives = item.lives - 1 
    return 'cross'
  end
  return "cross"
end
local bulletFilter = function(item, other)
  return "cross"
end
function love.load()
    font = love.graphics.newFont("kenpixel.ttf", 14)
    love.graphics.setFont(font)
    world = bump.newWorld()
    tie.image = love.graphics.newImage("tie.png")
    xwing.image = love.graphics.newImage("xwing.png")
    world:add(tie, tie.x, tie.y, 16, 16)
    world:add(xwing, xwing.x, xwing.y, 16, 16)
	bullets = {}
end
function love.update(dt)
	for i,v in ipairs(bullets) do
		v.x, v.y = world:move(v, v.x + (v.dx * dt), v.y + (v.dy * dt), bulletFilter)
	end
  --start tie
    tie.timeFire = tie.timeFire + dt
    if love.keyboard.isDown("a") then
      tie.angle = tie.angle - tie.turnSpeed*dt
   	end
   	if love.keyboard.isDown("d") then
      tie.angle = tie.angle + tie.turnSpeed*dt
   	end
   	if love.keyboard.isDown("w") then
      tie.dy, tie.dx = tie.dy - (tie.speed * math.cos(tie.angle)), tie.dx + (tie.speed * math.sin(tie.angle))
   	end
   	if love.keyboard.isDown("s") then
      tie.dy, tie.dx = tie.dy + (tie.speed * math.cos(tie.angle)), tie.dx - (tie.speed * math.sin(tie.angle))
   	end
    if love.keyboard.isDown("space") then
      if tie.timeFire > tie.fireDelay then
        tie.timeFire = 0
        bullet = {x = tie.x, y = tie.y, dx = tie.dx+ tie.bulletSpeed * math.sin(tie.angle), dy = tie.dy + (-tie.bulletSpeed * math.cos(tie.angle)), istie = true}
        table.insert(bullets, bullet)
        world:add(bullet, bullet.x, bullet.y, 6, 6)
      end
    end
    tie.x, tie.y = world:move(tie, tie.x + tie.dx*dt, tie.y + tie.dy*dt, tieFilter)
    --start xwing
    xwing.timeFire = xwing.timeFire + dt
    if love.keyboard.isDown("left") then
      xwing.angle = xwing.angle - xwing.turnSpeed*dt
    end
    if love.keyboard.isDown("right") then
      xwing.angle = xwing.angle + xwing.turnSpeed*dt
    end
    if love.keyboard.isDown("up") then
      xwing.dy, xwing.dx = xwing.dy - (xwing.speed * math.cos(xwing.angle)), xwing.dx + (xwing.speed * math.sin(xwing.angle))
    end
    if love.keyboard.isDown("down") then
      xwing.dy, xwing.dx = xwing.dy + (xwing.speed * math.cos(xwing.angle)), xwing.dx - (xwing.speed * math.sin(xwing.angle))
    end
    if love.keyboard.isDown("rctrl") then
      if xwing.timeFire > xwing.fireDelay then
        xwing.timeFire = 0
        bullet = {x = xwing.x, y = xwing.y, dx = xwing.dx + xwing.bulletSpeed * math.sin(xwing.angle), dy = xwing.dy + (-xwing.bulletSpeed * math.cos(xwing.angle)), isxwing = true}
        table.insert(bullets, bullet)
        world:add(bullet, bullet.x, bullet.y, 6, 6)
      end
    end
    xwing.x, xwing.y = world:move(xwing, xwing.x + xwing.dx*dt, xwing.y + xwing.dy*dt, xwingFilter)
end
function love.draw()
  love.graphics.print("Tie Lives: " .. tie.lives, 50, 20)
  love.graphics.print("X-Wing Lives: " .. xwing.lives, 200, 20)
  for i,v in ipairs(bullets) do
		love.graphics.circle("fill", v.x, v.y, 3)
	end
    love.graphics.draw(tie.image, tie.x, tie.y, tie.angle, 2, 2, 8, 8)
    love.graphics.draw(xwing.image, xwing.x, xwing.y, xwing.angle, 2, 2, 8, 8)
end