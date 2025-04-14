local Card = {}
Card.__index = Card

function Card:new(suit, rank, faceUp)
    local imgPath = "cards/" .. suit .. rank .. ".png"
    local self = setmetatable({
        suit = suit,
        rank = rank,
        faceUp = faceUp or false,
        image = love.graphics.newImage(imgPath),
        back = love.graphics.newImage("cards/card_back.png"),
        x = 0, y = 0,
        width = 71, height = 96
    }, Card)
    return self
end

function Card:draw()
    local img = self.faceUp and self.image or self.back
    love.graphics.draw(img, self.x, self.y)
end

function Card:contains(x, y)
    return x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height
end

return Card
