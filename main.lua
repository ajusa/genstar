local isInBounds
isInBounds = function(p)
  return p.x > 0 and p.y > 0 and p.x < love.graphics.getWidth() and p.y < love.graphics.getHeight()
end
local collision
collision = function(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end
local random
random = function(l, h)
  return love.math.random(l, h)
end
love.graphics.setDefaultFilter("nearest")
love.window.setFullscreen(true)
love.graphics.setFont(love.graphics.newFont("kenpixel.ttf", 14))
local Entity
do
  local _class_0
  local _base_0 = {
    update = function(self, dt)
      self.p.x, self.p.y = self.p.x + self.p.dx * dt, self.p.y + self.p.dy * dt
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
local Asteroid
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    draw = function(self)
      return love.graphics.draw(self.p.image, self.p.x, self.p.y, 0, self.p.scale, self.p.scale)
    end,
    update = function(self, dt)
      for i = #bullets, 1, -1 do
        if collision(self.p.x, self.p.y, self.p.scale * 16, self.p.scale * 16, bullets[i].p.x, bullets[i].p.y, 6, 6) then
          self.p.lives = self.p.lives - 1
          self.p.dx, self.p.dy = self.p.dx + bullets[i].p.dx / 15, self.p.dy + bullets[i].p.dy / 15
          table.remove(bullets, i)
        end
      end
      if isInBounds({
        x = self.p.x + self.p.dx * dt,
        y = self.p.y + self.p.dy * dt
      }) then
        return _class_0.__parent.__base.update(self, dt)
      else
        self.p.dx, self.p.dy = self.p.dx / -1.1, self.p.dy / -1.1
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Asteroid",
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
  Asteroid = _class_0
end
local Player
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    checkForBullets = function(self, dt)
      for i = #bullets, 1, -1 do
        if bullets[i].p.from ~= self.p.type and collision(self.p.x - 16, self.p.y - 16, 32, 32, bullets[i].p.x, bullets[i].p.y, 6, 6) then
          self.p.lives = self.p.lives - 10
          table.remove(bullets, i)
        end
      end
    end,
    checkForAsteroids = function(self, dt)
      for i = #asteroids, 1, -1 do
        if collision(self.p.x - 16, self.p.y - 16, 32, 32, asteroids[i].p.x, asteroids[i].p.y, asteroids[i].p.scale * 16, asteroids[i].p.scale * 16) and (love.timer.getTime() - start) > 3 then
          self.p.lives = self.p.lives - (random(2, 7) * asteroids[i].p.scale)
          table.remove(asteroids, i)
        end
      end
    end,
    draw = function(self)
      love.graphics.print(self.p.type .. " Health: " .. self.p.lives .. "%", 50 + self.p.offset, 20)
      love.graphics.draw(self.p.image, self.p.x, self.p.y, self.p.angle, 2, 2, 8, 8)
      if self.p.lives <= 0 then
        love.graphics.print(self.p.type .. " Loses! ", 300, 200)
        return love.graphics.draw(bomb, self.p.x, self.p.y, self.p.angle, 2, 2, 8, 8)
      end
    end,
    update = function(self, dt)
      self:checkForBullets(dt)
      self:checkForAsteroids(dt)
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
      if love.keyboard.isDown(self.p.fire) and self.p.timeFire > self.p.fireDelay then
        self.p.timeFire = 0
        table.insert(bullets, Entity({
          x = self.p.x,
          y = self.p.y,
          dx = self.p.dx + self.p.bulletSpeed * math.sin(self.p.angle),
          dy = self.p.dy + (-self.p.bulletSpeed * math.cos(self.p.angle)),
          from = self.p.type
        }))
      end
      if isInBounds({
        x = self.p.x + self.p.dx * dt,
        y = self.p.y + self.p.dy * dt
      }) then
        _class_0.__parent.__base.update(self, dt)
      else
        self.p.dx, self.p.dy = self.p.dx / -2, self.p.dy / -2
      end
      self.p.dy, self.p.dx = self.p.dy * .99, self.p.dx * .995
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
love.load = function()
  start = love.timer.getTime()
  tie = Player({
    x = 300,
    y = 300,
    w = 16,
    h = 16,
    dx = 0,
    dy = 0,
    speed = 1,
    angle = 0,
    turnSpeed = 1,
    fireDelay = .5,
    timeFire = 0,
    bulletSpeed = 200,
    lives = 100,
    left = "a",
    right = "d",
    forward = "w",
    backward = "s",
    fire = "space",
    type = "Tie Fighter",
    offset = 0,
    image = love.graphics.newImage("tie.png")
  })
  xwing = Player({
    x = 700,
    y = 700,
    w = 16,
    h = 16,
    dx = 0,
    dy = 0,
    speed = .75,
    angle = 0,
    turnSpeed = 1,
    fireDelay = .4,
    timeFire = 0,
    bulletSpeed = 200,
    lives = 100,
    left = "left",
    right = "right",
    forward = "up",
    backward = "down",
    fire = "rctrl",
    type = "X-Wing",
    offset = 250,
    image = love.graphics.newImage("xwing.png")
  })
  bullets = { }
  do
    local _accum_0 = { }
    local _len_0 = 1
    for i = 1, 40 do
      _accum_0[_len_0] = {
        size = random(1, 8),
        x = random(1, love.graphics.getWidth()),
        y = random(1, love.graphics.getHeight())
      }
      _len_0 = _len_0 + 1
    end
    stars = _accum_0
  end
  do
    local _accum_0 = { }
    local _len_0 = 1
    for i = 1, random(4, 10) do
      _accum_0[_len_0] = Asteroid({
        lives = 5,
        x = random(1, 1200),
        y = random(1, 750),
        dx = random(-40, 40),
        dy = random(-40, 40),
        image = love.graphics.newImage("asteroid" .. random(1, 3) .. ".png"),
        scale = random(1.5, 4)
      })
      _len_0 = _len_0 + 1
    end
    asteroids = _accum_0
  end
  bomb = love.graphics.newImage("bomb.png")
  death = love.graphics.newImage("death.png")
end
love.update = function(dt)
  if xwing.p.lives > 0 and tie.p.lives > 0 then
    local _list_0 = bullets
    for _index_0 = 1, #_list_0 do
      local bullet = _list_0[_index_0]
      bullet:update(dt)
    end
    for i = #asteroids, 1, -1 do
      asteroids[i]:update(dt)
      if asteroids[i].p.lives < 0 then
        table.remove(asteroids, i)
      end
    end
    tie:update(dt)
    return xwing:update(dt)
  else
    if love.keyboard.isDown("return") then
      return love.load()
    end
  end
end
love.draw = function()
  local _list_0 = stars
  for _index_0 = 1, #_list_0 do
    local star = _list_0[_index_0]
    love.graphics.rectangle("fill", star.x, star.y, star.size, star.size)
  end
  love.graphics.draw(death, 600, 300)
  for i, v in ipairs(bullets) do
    local _exp_0 = v.p.from
    if "X-Wing" == _exp_0 then
      love.graphics.setColor(255, 0, 0)
    else
      love.graphics.setColor(0, 255, 0)
    end
    love.graphics.circle("fill", v.p.x, v.p.y, 3)
  end
  love.graphics.setColor(255, 255, 255)
  tie:draw()
  xwing:draw()
  for _, asteroid in pairs(asteroids) do
    asteroid:draw()
  end
end
