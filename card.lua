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
        width = 106, height = 144
    }, Card)

    self.value = self:getValue()
    self.color = self:getColor()

    return self
end

function Card:draw()
    local img = self.faceUp and self.image or self.back
    love.graphics.draw(img, self.x, self.y, 0, 1.5, 1.5)
end


function Card:contains(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

function Card:getColor()
    if self.suit == "card_hearts_" or self.suit == "card_diamonds_" then
        return "red"
    else
        return "black"
    end
end

function Card:getValue()
    local values = {
        A = 1, ["02"] = 2, ["03"] = 3, ["04"] = 4,
        ["05"] = 5, ["06"] = 6, ["07"] = 7, ["08"] = 8,
        ["09"] = 9, ["10"] = 10, J = 11, Q = 12, K = 13
    }
    return values[self.rank]
end

return Card
