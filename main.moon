isInBounds = (p) ->  
	p.x > 0 and p.y > 0 and p.x<love.graphics.getWidth() and p.y<love.graphics.getHeight()
playerProj = (p,o,w2,h2) ->
  return (p.x-p.w/2) < o.x+w2 and
         o.x < (p.x-p.w/2)+p.w and
         (p.y-p.h/2) < o.y+h2 and
         o.y < (p.y-p.h/2)+p.h
createStars = ->
    if stars==nil then
        export stars={}
        for i = 1, 40 do
			stars[i] = {
                Size: love.math.random(1, 8),
                XPosition: love.math.random(1, 1200),
                YPosition: love.math.random(1, 750),
            }
love.graphics.setDefaultFilter("nearest")
love.window.setFullscreen(true)
class Entity
  new: (p) => @p = p
  update: (dt) =>
	@p.x += @p.dx*dt
	@p.y += @p.dy*dt
class Player extends Entity
	update: (dt) =>
		@p.timeFire += dt
		if love.keyboard.isDown @p.left then @p.angle -= @p.turnSpeed*dt
		if love.keyboard.isDown @p.right then @p.angle += @p.turnSpeed*dt
		if love.keyboard.isDown @p.forward
			@p.dy, @p.dx = @p.dy - (@p.speed * math.cos(@p.angle)), @p.dx + (@p.speed * math.sin(@p.angle))
		if love.keyboard.isDown @p.backward
			@p.dy, @p.dx = @p.dy + (@p.speed * math.cos(@p.angle)), @p.dx - (@p.speed * math.sin(@p.angle))
		if love.keyboard.isDown @p.fire
			if @p.timeFire > @p.fireDelay then
        		@p.timeFire = 0
        		bullet = Entity {x: @p.x, y: @p.y, dx: @p.dx+ @p.bulletSpeed * math.sin(@p.angle), dy: @p.dy + (-@p.bulletSpeed * math.cos(@p.angle)), from: @p.type}
        		table.insert(bullets, bullet)
		if isInBounds({x:@p.x + @p.dx*dt, y:@p.y + @p.dy*dt}) then super dt
		else
			@p.dx /= -2
			@p.dy /= -2
		@p.dy, @p.dx = @p.dy*.99, @p.dx*.99
tie = Player x: 300, y: 300, w: 16, h: 16, dx: 0, dy: 0, speed: 1, angle: 0, turnSpeed: 1.2, fireDelay: .5, timeFire: 0, bulletSpeed: 200, lives: 5, left:"a", right:"d", forward:"w", backward:"s", fire:"space", type:"tie"
xwing = Player x: 700, y: 700, w: 16, h: 16, dx: 0, dy: 0, speed: .75, angle: 0, turnSpeed: 1.2, fireDelay: .4, timeFire: 0, bulletSpeed: 200, lives: 5, left:"left", right:"right", forward:"up", backward:"down", fire: "rctrl", type: "xwing"
game = true
export bullets = {}
love.load = ->
    font = love.graphics.newFont("kenpixel.ttf", 14)
    love.graphics.setFont(font)
    tie.p.image = love.graphics.newImage("tie.png")
    xwing.p.image = love.graphics.newImage("xwing.png")
    export bomb = love.graphics.newImage("bomb.png")
    export death = love.graphics.newImage("death.png")
love.update = (dt) ->
	if game
		for i=#bullets,1,-1 do
			bullets[i]\update(dt)
    		if bullets[i].p.from == "xwing" and (playerProj(tie.p, bullets[i].p, 6,6)) then
    	  		tie.p.lives = tie.p.lives - 1
    	  		table.remove(bullets, i)
			elseif bullets[i].p.from == "tie" and (playerProj(xwing.p, bullets[i].p, 6,6)) then
    	  		xwing.p.lives = xwing.p.lives - 1
    	  		table.remove(bullets, i)
		tie\update(dt)
		xwing\update(dt)
love.draw = ->
	createStars()
	for _, star in ipairs(stars) do
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle("fill", star.XPosition, star.YPosition, star.Size, star.Size)
	love.graphics.setColor(255,255,255)
	love.graphics.draw(death, 600, 300)
    for i,v in ipairs(bullets) do
    	if v.p.from == "xwing"
			love.graphics.setColor(255, 0, 0)
		else love.graphics.setColor(0, 255, 0)
		love.graphics.circle("fill", v.p.x, v.p.y, 3)
	love.graphics.setColor(255,255,255)
	love.graphics.print("Tie Lives: " .. tie.p.lives, 50, 20)
	love.graphics.print("X-Wing Lives: " .. xwing.p.lives, 200, 20)
	love.graphics.draw(tie.p.image, tie.p.x, tie.p.y, tie.p.angle, 2, 2, 8, 8)
	love.graphics.draw(xwing.p.image, xwing.p.x, xwing.p.y, xwing.p.angle, 2, 2, 8, 8)
	if xwing.p.lives < 1
   		love.graphics.print("Tie Fighter Wins! ", 300, 200)
   		love.graphics.draw(bomb, xwing.p.x, xwing.p.y, xwing.p.angle, 2, 2, 8, 8)
   		game = false
	if tie.p.lives < 1
    	love.graphics.print("X-Wing Wins! ", 300, 200)
    	love.graphics.draw(bomb, tie.p.x, tie.p.y, tie.p.angle, 2, 2, 8, 8)
    	game = false