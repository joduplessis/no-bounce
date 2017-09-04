local http = require("socket.http")
local ltn12 = require("ltn12")
local vibrate_trigger = true
local screenW, screenH = display.contentWidth, display.contentHeight
local friction = 0.8
local gravity = .08
local speedX, speedY, prevX, prevY, lastTime, prevTime = 0, 0, 0, 0, 0, 0
local background = display.newImage( "background.jpg", true )
background.x = screenW / 2
background.y = screenH / 2
local logo = display.newImage( "logo.png", true )
logo.x = ( logo.width / 2 ) + 10
logo.y = screenH - 40
local tt_x = screenW - 170 ;
local tt_y = screenH - 50 ;
local tt = display.newText( "Top score so far is 0", tt_x, tt_y, native.systemFontBold, 16 )

tt:setTextColor( 255,255,255 )

local ball = display.newCircle( 0, 0, 40)

ball:setFillColor(255, 116, 0, 255)
ball:setStrokeColor(182, 83, 0, 255)
ball.strokeWidth = 5

local t_x = (screenW / 2 ) - 50
local t_y = screenH - 60
local t = display.newText( "Timer: 0", t_x, t_y, native.systemFont, 30 )

t:setTextColor( 255, 116, 0, 255 )

ball.x = screenW * 0.5
ball.y = ball.height

local bounceMultiplier, tiltMultiplier, timerCount, topTimer = 1, 0, 0, 0
local mRand = math.random; math.randomseed(os.time())
local xGravity, yGravity, xWind, yWind = 0, 13, 45, 2
local snow = display.newGroup()

-- snow functions

local function animateSnow(event)
	for i=1,snow.numChildren do
		local flake = snow[i]
		flake:translate( (flake.xVelocity+xWind)*0.1, (flake.yVelocity+yWind)*0.1 )
		if flake.y > display.contentHeight then
			flake.x, flake.y = mRand( display.contentWidth ), mRand( 60 )
		end
	end
	if mRand(64) == 1 then xWind = 0-xWind; end
end

local function initSnow(snowCount)
	for i=1,snowCount do
		local flake = display.newImageRect( snow, "flake.jpg", 2, 2 )
		if mRand( 1, 2 ) == 1 then flake.alpha = mRand( 25, 100 ) * .01; end
		flake.x, flake.y = mRand( display.contentWidth ), mRand( display.contentHeight )
		flake.yVelocity, flake.xVelocity = mRand( 60 ), mRand( 50 )
	end
	Runtime:addEventListener("enterFrame", animateSnow )
end

-- accellorometer event

local function onAccelerate( event )

	tiltMultiplier = ball.x * (event.yGravity * -1) / 5000

end

-- here we move the circle, simulating the basic physics

function onMoveCircle(event)

	local timePassed = event.time - lastTime
	lastTime = lastTime + timePassed

	speedY = (speedY + gravity)
	speedX = speedX * bounceMultiplier + tiltMultiplier

	ball.x = ball.x + speedX*timePassed
	ball.y = ball.y + speedY*timePassed

	background.x = ( ball.x * 0.2 ) + 300

	if ball.x >= screenW - ball.width*.5 then

		ball.x = screenW - ball.width*.5
		speedX = speedX*friction
		speedX = speedX*-1 --change direction

	elseif ball.x <= ball.width*.5 then

	    ball.x = ball.width*.5
		speedX = speedX*friction
		speedX = speedX*-1 --change direction

	end

	if ball.y >= (screenH-85) - ball.height*.5 then

		ball.y = (screenH-85) - ball.height*.5
		speedY = speedY*friction
		speedX = speedX*friction
		speedY = speedY*-1  --change direction

		-- when the ball hits the ground

		bounceMultiplier = 1
		timerCount = 0

	end
end

-- when there is a click on the scoreboard

local function bounceBall( event )

	local director = (ball.x - event.x) / 100

	vibrate_trigger = true

	speedY = -1
	speedX = director -- direction the ball goes

	if resetTimer then
		resetTimer = false
	end

end

-- when there is a click

function t:timer( event )

	local count = event.count
	timerCount = timerCount + 1
	self.text = "Timer: " .. timerCount - 1

	if topTimer<(timerCount - 1) then
		topTimer = (timerCount - 1)
		tt.text = "Top score so far is " .. topTimer
	end

	bounceMultiplier = bounceMultiplier + (0.0005 * timerCount)
	gravity = gravity + (0.0002 * timerCount)

end

initSnow(1000)
timer.performWithDelay( 1000, t, 5000 )
ball:addEventListener("touch", bounceBall)
Runtime:addEventListener ("accelerometer", onAccelerate);
Runtime:addEventListener("enterFrame", onMoveCircle)
