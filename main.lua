local tie = {x=400, y=400, w=16, h=16, dx=0, dy=0, speed=1.5, angle=0, turnSpeed = 2, fireDelay = .5, timeFire = 0, bulletSpeed = 200, lives = 5}
local xwing = {x=500, y=500, w=16, h=16, dx=0, dy=0, speed=1.5, angle=0, turnSpeed = 2, fireDelay = .5, timeFire = 0, bulletSpeed = 200, lives = 5}
game = true
love.graphics.setDefaultFilter("nearest")
function love.load()
    font = love.graphics.newFont("kenpixel.ttf", 14)
    love.graphics.setFont(font)
    tie.image = love.graphics.newImage("tie.png")
    xwing.image = love.graphics.newImage("xwing.png")
	bullets = {}
end
function love.update(dt)

if game then
	for i=#bullets,1,-1 do
		bullets[i].x, bullets[i].y =  bullets[i].x + (bullets[i].dx * dt), bullets[i].y + (bullets[i].dy * dt)
    if bullets[i].from == "xwing" and (playerProj(tie, bullets[i], 6,6)) then
      tie.lives = tie.lives - 1
      table.remove(bullets, i)
    elseif bullets[i].from == "tie" and (playerProj(xwing, bullets[i], 6,6)) then
      xwing.lives = xwing.lives - 1
      table.remove(bullets, i)
    end
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
        bullet = {x = tie.x, y = tie.y, dx = tie.dx+ tie.bulletSpeed * math.sin(tie.angle), dy = tie.dy + (-tie.bulletSpeed * math.cos(tie.angle)), from = "tie"}
        table.insert(bullets, bullet)
      end
    end
    if isInBounds({x=tie.x + tie.dx*dt, y=tie.y + tie.dy*dt}) then
      tie.x, tie.y = tie.x + tie.dx*dt, tie.y + tie.dy*dt
    else
      tie.dx = -tie.dx/4
      tie.dy = -tie.dy/4
    end
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
        bullet = {x = xwing.x, y = xwing.y, dx = xwing.dx + xwing.bulletSpeed * math.sin(xwing.angle), dy = xwing.dy + (-xwing.bulletSpeed * math.cos(xwing.angle)), from = "xwing"}
        table.insert(bullets, bullet)
      end
    end
    if isInBounds({x=xwing.x + xwing.dx*dt, y=xwing.y + xwing.dy*dt}) then
      xwing.x, xwing.y = xwing.x + xwing.dx*dt, xwing.y + xwing.dy*dt
    else
      xwing.dx = -xwing.dx/4
      xwing.dy = -xwing.dy/4
    end
    
  end
end
function love.draw()
  if xwing.lives < 1 then
    love.graphics.print("Tie Fighter Wins! ", 300, 200)
    game = false
  elseif tie.lives < 1 then
    love.graphics.print("X-Wing Wins! ", 300, 200)
    game = false
  end
  love.graphics.print("Tie Lives: " .. tie.lives, 50, 20)
  love.graphics.print("X-Wing Lives: " .. xwing.lives, 200, 20)
  for i,v in ipairs(bullets) do
		love.graphics.circle("fill", v.x, v.y, 3)
	end
    love.graphics.draw(tie.image, tie.x, tie.y, tie.angle, 2, 2, 8, 8)
    love.graphics.draw(xwing.image, xwing.x, xwing.y, xwing.angle, 2, 2, 8, 8)
end
function playerProj(p,o,w2,h2)
  return (p.x-p.w/2) < o.x+w2 and
         o.x < (p.x-p.w/2)+p.w and
         (p.y-p.h/2) < o.y+h2 and
         o.y < (p.y-p.h/2)+p.h
end
function isInBounds(p)
  return p.x > 0 and p.y > 0 and p.x<love.graphics.getWidth() and p.y<love.graphics.getHeight()
end