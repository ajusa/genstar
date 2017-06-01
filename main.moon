isInBounds = (p) -> p.x > 0 and p.y > 0 and p.x<love.graphics.getWidth() and p.y<love.graphics.getHeight()
playerProj = (p,o,w2,h2) -> (p.x-p.w/2) < o.x+w2 and o.x < (p.x-p.w/2)+p.w and (p.y-p.h/2) < o.y+h2 and o.y < (p.y-p.h/2)+p.h
asteroidProj = (x1,y1,w1,h1, x2,y2,w2,h2) -> x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1
love.graphics.setDefaultFilter("nearest")
love.window.setFullscreen(true)
class Entity
  new: (p) => @p = p
  update: (dt) =>
	@p.x += @p.dx*dt
	@p.y += @p.dy*dt
class Asteroid extends Entity
	draw: => 
		love.graphics.draw(@p.image, @p.x, @p.y, 0, @p.scale, @p.scale)
	update: (dt) =>
		for i=#bullets,1,-1 do
    		if  asteroidProj(@p.x, @p.y, @p.scale*16, @p.scale*16, bullets[i].p.x, bullets[i].p.y, 6,6)
    	  		@p.lives -= 1
    	  		@p.dx += bullets[i].p.dx/15
    	  		@p.dy += bullets[i].p.dy/15
    	  		table.remove(bullets, i)
		if isInBounds({x:@p.x + @p.dx*dt, y:@p.y + @p.dy*dt}) then super dt
		else @p.dx, @p.dy = @p.dx/-1.1, @p.dy/-1.1
class Player extends Entity
	checkForBullets: (dt) =>
		for i=#bullets,1,-1 do
    		if bullets[i].p.from ~= @p.type and playerProj(@p, bullets[i].p, 6,6)
    	  		@p.lives -= love.math.random(5, 12)
    	  		table.remove(bullets, i)
    checkForAsteroids: (dt) =>
		for i=#asteroids,1,-1 do
    		if playerProj(@p, asteroids[i].p, asteroids[i].p.scale*16, asteroids[i].p.scale*16) and (love.timer.getTime() - start) > 3 --invincible for 3 seconds
    	  		@p.lives -= love.math.random(2, 7)*asteroids[i].p.scale
    	  		table.remove(asteroids, i)
	draw: => 
		love.graphics.print(@p.type .. " Health: " .. @p.lives .. "%", 50 + @p.offset, 20)
		love.graphics.draw(@p.image, @p.x, @p.y, @p.angle, 2, 2, 8, 8)
		if @p.lives < 1
   			love.graphics.print(@p.type .. " Loses! ", 300, 200)
   			love.graphics.draw(bomb, @p.x, @p.y, @p.angle, 2, 2, 8, 8)
	update: (dt) =>
		@checkForBullets(dt)
		@checkForAsteroids(dt)
		@p.timeFire += dt
		if love.keyboard.isDown @p.left then @p.angle -= @p.turnSpeed*dt
		if love.keyboard.isDown @p.right then @p.angle += @p.turnSpeed*dt
		if love.keyboard.isDown @p.forward then @p.dy, @p.dx = @p.dy - (@p.speed * math.cos(@p.angle)), @p.dx + (@p.speed * math.sin(@p.angle))
		if love.keyboard.isDown @p.backward then @p.dy, @p.dx = @p.dy + (@p.speed * math.cos(@p.angle)), @p.dx - (@p.speed * math.sin(@p.angle))
		if love.keyboard.isDown @p.fire
			if @p.timeFire > @p.fireDelay then
        		@p.timeFire = 0
        		table.insert(bullets, Entity {x: @p.x, y: @p.y, dx: @p.dx+ @p.bulletSpeed * math.sin(@p.angle), dy: @p.dy + (-@p.bulletSpeed * math.cos(@p.angle)), from: @p.type})
		if isInBounds({x:@p.x + @p.dx*dt, y:@p.y + @p.dy*dt}) then super dt
		else @p.dx, @p.dy = @p.dx/-2, @p.dy/-2
		@p.dy, @p.dx = @p.dy*.99, @p.dx*.995 --friction
love.load = ->
	export start = love.timer.getTime()
	export tie = Player x: 300, y: 300, w: 16, h: 16, dx: 0, dy: 0, speed: 1, angle: 0, turnSpeed: 1.2, fireDelay: .5, timeFire: 0, bulletSpeed: 200, lives: 100, left:"a", right:"d", forward:"w", backward:"s", fire:"space", type:"Tie Fighter", offset: 0
	export xwing = Player x: 700, y: 700, w: 16, h: 16, dx: 0, dy: 0, speed: .75, angle: 0, turnSpeed: 1.2, fireDelay: .4, timeFire: 0, bulletSpeed: 200, lives: 100, left:"left", right:"right", forward:"up", backward:"down", fire: "rctrl", type: "X-Wing", offset: 250
	export bullets = {}
    love.graphics.setFont(love.graphics.newFont("kenpixel.ttf", 14))
    tie.p.image = love.graphics.newImage("tie.png")
    xwing.p.image = love.graphics.newImage("xwing.png")
    export stars={}
    for i = 1, 40 do stars[i] = size: love.math.random(1, 8), x: love.math.random(1, love.graphics.getWidth()), y: love.math.random(1, love.graphics.getHeight())
    export asteroids = {}
    for i = 1, love.math.random(4, 10) do asteroids[i] = Asteroid lives: 5, x: love.math.random(1, 1200), y: love.math.random(1, 750), dx: love.math.random(-40, 40), dy: love.math.random(-40, 40), image: love.graphics.newImage("asteroid"..love.math.random(1, 3)..".png"), scale: love.math.random(1.5, 4)
    export bomb = love.graphics.newImage("bomb.png")
    export death = love.graphics.newImage("death.png")
love.update = (dt) ->
	if xwing.p.lives > 0 and tie.p.lives > 0
		for bullet in *bullets do bullet\update(dt)
		for asteroid in *asteroids do asteroid\update(dt)
		for i=#asteroids,1,-1 do if asteroids[i].p.lives < 0 then table.remove(asteroids, i)
		tie\update(dt)
		xwing\update(dt)
	else if love.keyboard.isDown "return" then love.load!
love.draw = ->
	for star in *stars do love.graphics.rectangle("fill", star.x, star.y, star.size, star.size)   
	love.graphics.draw(death, 600, 300) --deathstar
    for i,v in ipairs(bullets) do
    	if v.p.from == "X-Wing" then love.graphics.setColor(255, 0, 0)
		else love.graphics.setColor(0, 255, 0)
		love.graphics.circle("fill", v.p.x, v.p.y, 3)
	love.graphics.setColor(255,255,255)
	tie\draw!
	xwing\draw!
	for asteroid in *asteroids do asteroid\draw!