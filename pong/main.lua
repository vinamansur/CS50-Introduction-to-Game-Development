-- PONG GAME
-- CS50's Introduction to Game Development
-- Pong Remake by Colton Ogden (cogden@cs50.harvard.edu) 2018
-- Modified version by Vinicius Mansur (vinamansur2@gmail.com)
-- October 2022

push = require 'push'

Class = require 'class'
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200


function love.load()
    love.graphics.setDefaultFilter('nearest','nearest')
    love.window.setTitle(' Pong! ')
    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)

    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    } )

    p1Score = 0
    p2Score = 0
    servingPlayer = 1

    p1 = Paddle(10, 30, 5, 20)
    p2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 30, 5, 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2,VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gameState == 'serve' then
        ball:reset()
        if servingPlayer == 1 then
            ball.dx = 100
        else
            ball.dx = -100
        end
    elseif gameState == 'play' then
        ball:update(dt)
        -- collision with paddle 1
        if ball:collision(p1) then
            ball.dx = -ball.dx * 1.03
            ball.x = p1.x + p1.width
            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
            sounds.paddle_hit:play()
        end
        -- collision with paddle 2
        if ball:collision(p2) then
            ball.dx = -ball.dx * 1.03
            ball.x = p2.x - ball.width
            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
            sounds.paddle_hit:play()
        end
        -- collision with edges
        if ball.y <= 0 then
            ball.y=0
            ball.dy = -ball.dy
            sounds.wall_hit:play()
        end
        if ball.y >= VIRTUAL_HEIGHT - ball.height then
            ball.y = VIRTUAL_HEIGHT - ball.height
            ball.dy = -ball.dy
            sounds.wall_hit:play()
        end
    end

    if ball.x < 0 then
        sounds.score:play()
        p2Score = p2Score + 1
        servingPlayer = 1
        gameState = 'serve'
    end
    if ball.x > VIRTUAL_WIDTH then
        sounds.score:play()
        p1Score = p1Score + 1
        servingPlayer = 2
        gameState = 'serve'
    end

    -- P1 paddle control
    if love.keyboard.isDown('w') then
        p1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        p1.dy = PADDLE_SPEED
    else
        p1.dy = 0
    end

    -- P2 paddle control
    if love.keyboard.isDown('up') then
        p2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        p2.dy = PADDLE_SPEED
    else
        p2.dy = 0
    end

    p1:update(dt)
    p2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        end
    end
end

function love.draw()
    push:apply('start')
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    displayScore()
    
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Pong!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press ENTER to start the game, ESC to quit", 0, 40, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press C to display game commands", 0, 50, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Player " .. tostring(servingPlayer) ..": press ENTER to serve, ESC to quit", 0, 40, VIRTUAL_WIDTH, 'center')
    end

    -- rendering paddles and ball
    p1:render()
    p2:render()
    ball:render()

    -- displays frames per second while 'f' is pressed
    if love.keyboard.isDown('f') then
        displayFPS()
    end

    if love.keyboard.isDown('c') then
        displayCommands()
    end

    push:apply('end')
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
    if gameState == 'serve' then
        love.graphics.setFont(scoreFont)
        love.graphics.print(tostring(p1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
        love.graphics.print(tostring(p2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
    elseif gameState == 'play' then
        love.graphics.setFont(smallFont)
        love.graphics.print(tostring(p1Score), VIRTUAL_WIDTH / 2 - 10, 20)
        love.graphics.print(tostring(p2Score), VIRTUAL_WIDTH / 2 + 10, 20)
    end
end

function displayCommands()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.printf('Player 1: use W and S to move the paddle', 0, VIRTUAL_HEIGHT - 50, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Player 2: use up and down arrows to move the paddle', 0, VIRTUAL_HEIGHT - 40, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press F to display current FPS', 0, VIRTUAL_HEIGHT - 30, VIRTUAL_WIDTH, 'center')
end