Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dx = 0
    self.dy = math.random(-50,50)
    self.speed = math.sqrt((self.dx * self.dx) + (self.dy * self.dy))
end

function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dy = math.random(-50,50)
end

function Ball:update(dt)
    self.x = self.x + self.dx*dt
    self.y = self.y + self.dy*dt
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Ball:collision(paddle)
    -- AABB detection: if any of those conditions evaluate true, there's no collision
    if  paddle.x > self.x + self.width or
        paddle.x + paddle.width < self.x or
        paddle.y > self.y + self.height or
        paddle.y + paddle.height < self.y then
            return false
    end
    -- if no condition is met, there's a collision
    return true
end