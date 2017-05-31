local isInBounds
isInBounds = function(p)
  return p.x > 0 and p.y > 0 and p.x < love.graphics.getWidth() and p.y < love.graphics.getHeight()
end
local playerProj
playerProj = function(p, o, w2, h2)
  return (p.x - p.w / 2) < o.x + w2 and o.x < (p.x - p.w / 2) + p.w and (p.y - p.h / 2) < o.y + h2 and o.y < (p.y - p.h / 2) + p.h
end
local createStars
createStars = function()
  if stars == nil then
    stars = { }
    for i = 1, 40 do
      stars[i] = {
        Size = love.math.random(1, 8),
        XPosition = love.math.random(1, 1200),
        YPosition = love.math.random(1, 750)
      }
    end
  end
end
love.graphics.setDefaultFilter("nearest")
love.window.setFullscreen(true)
local Entity
do
  local _class_0
  local _base_0 = {
    update = function(self, dt)
      self.p.x = self.p.x + (self.p.dx * dt)
      self.p.y = self.p.y + (self.p.dy * dt)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, p)
      self.p = p
    end,
    __base = _base_0,
    __name = "Entity"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Entity = _class_0
end
local Player
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    update = function(self, dt)
      self.p.timeFire = self.p.timeFire + dt
      if love.keyboard.isDown(self.p.left) then
        self.p.angle = self.p.angle - (self.p.turnSpeed * dt)
      end
      if love.keyboard.isDown(self.p.right) then
        self.p.angle = self.p.angle + (self.p.turnSpeed * dt)
      end
      if love.keyboard.isDown(self.p.forward) then
        self.p.dy, self.p.dx = self.p.dy - (self.p.speed * math.cos(self.p.angle)), self.p.dx + (self.p.speed * math.sin(self.p.angle))
      end
      if love.keyboard.isDown(self.p.backward) then
        self.p.dy, self.p.dx = self.p.dy + (self.p.speed * math.cos(self.p.angle)), self.p.dx - (self.p.speed * math.sin(self.p.angle))
      end
      if love.keyboard.isDown(self.p.fire) then
        if self.p.timeFire > self.p.fireDelay then
          self.p.timeFire = 0
          local bullet = Entity({
            x = self.p.x,
            y = self.p.y,
            dx = self.p.dx + self.p.bulletSpeed * math.sin(self.p.angle),
            dy = self.p.dy + (-self.p.bulletSpeed * math.cos(self.p.angle)),
            from = self.p.type
          })
          table.insert(bullets, bullet)
        end
      end
      if isInBounds({
        x = self.p.x + self.p.dx * dt,
        y = self.p.y + self.p.dy * dt
      }) then
        _class_0.__parent.__base.update(self, dt)
      else
        self.p.dx = self.p.dx / -2
        self.p.dy = self.p.dy / -2
      end
      self.p.dy, self.p.dx = self.p.dy * .99, self.p.dx * .99
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Player",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Player = _class_0
end
local tie = Player({
  x = 300,
  y = 300,
  w = 16,
  h = 16,
  dx = 0,
  dy = 0,
  speed = 1,
  angle = 0,
  turnSpeed = 1.2,
  fireDelay = .5,
  timeFire = 0,
  bulletSpeed = 200,
  lives = 5,
  left = "a",
  right = "d",
  forward = "w",
  backward = "s",
  fire = "space",
  type = "tie"
})
local xwing = Player({
  x = 700,
  y = 700,
  w = 16,
  h = 16,
  dx = 0,
  dy = 0,
  speed = .75,
  angle = 0,
  turnSpeed = 1.2,
  fireDelay = .4,
  timeFire = 0,
  bulletSpeed = 200,
  lives = 5,
  left = "left",
  right = "right",
  forward = "up",
  backward = "down",
  fire = "rctrl",
  type = "xwing"
})
local game = true
bullets = { }
love.load = function()
  local font = love.graphics.newFont("kenpixel.ttf", 14)
  love.graphics.setFont(font)
  tie.p.image = love.graphics.newImage("tie.png")
  xwing.p.image = love.graphics.newImage("xwing.png")
  bomb = love.graphics.newImage("bomb.png")
  death = love.graphics.newImage("death.png")
end
love.update = function(dt)
  if game then
    for i = #bullets, 1, -1 do
      bullets[i]:update(dt)
      if bullets[i].p.from == "xwing" and (playerProj(tie.p, bullets[i].p, 6, 6)) then
        tie.p.lives = tie.p.lives - 1
        table.remove(bullets, i)
      elseif bullets[i].p.from == "tie" and (playerProj(xwing.p, bullets[i].p, 6, 6)) then
        xwing.p.lives = xwing.p.lives - 1
        table.remove(bullets, i)
      end
    end
    tie:update(dt)
    return xwing:update(dt)
  end
end
love.draw = function()
  createStars()
  for _, star in ipairs(stars) do
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", star.XPosition, star.YPosition, star.Size, star.Size)
  end
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(death, 600, 300)
  for i, v in ipairs(bullets) do
    if v.p.from == "xwing" then
      love.graphics.setColor(255, 0, 0)
    else
      love.graphics.setColor(0, 255, 0)
    end
    love.graphics.circle("fill", v.p.x, v.p.y, 3)
  end
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("Tie Lives: " .. tie.p.lives, 50, 20)
  love.graphics.print("X-Wing Lives: " .. xwing.p.lives, 200, 20)
  love.graphics.draw(tie.p.image, tie.p.x, tie.p.y, tie.p.angle, 2, 2, 8, 8)
  love.graphics.draw(xwing.p.image, xwing.p.x, xwing.p.y, xwing.p.angle, 2, 2, 8, 8)
  if xwing.p.lives < 1 then
    love.graphics.print("Tie Fighter Wins! ", 300, 200)
    love.graphics.draw(bomb, xwing.p.x, xwing.p.y, xwing.p.angle, 2, 2, 8, 8)
    game = false
  end
  if tie.p.lives < 1 then
    love.graphics.print("X-Wing Wins! ", 300, 200)
    love.graphics.draw(bomb, tie.p.x, tie.p.y, tie.p.angle, 2, 2, 8, 8)
    game = false
  end
end
