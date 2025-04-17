local Pile = {}
Pile.__index = Pile

function Pile:new(x, y)
    local self = setmetatable({
        x = x, y = y,
        cards = {}
    }, Pile)
    return self
end

function Pile:addCard(card)
    card.x = self.x
    card.y = self.y + (#self.cards * 20)
    table.insert(self.cards, card)
end

--function Pile:draw()
 --   for _, card in ipairs(self.cards) do
 --       card:draw()
 --   end
--end

function Pile:draw()
    if #self.cards == 0 then
        love.graphics.setColor(0.2, 0.6, 0.2)
        love.graphics.rectangle("line", self.x, self.y, 71, 96)
        love.graphics.setColor(1, 1, 1)
    end

    for i, card in ipairs(self.cards) do
        card.x = self.x
        card.y = self.y + (not self.isFoundation and (i - 1) * 20 or 0)
        card:draw()
    end
end


function Pile:isPointInside(x, y)
    local lastY = self.y + (#self.cards - 1) * 20
    return x >= self.x and x <= self.x + 71 and y >= self.y and y <= lastY + 96
end


function Pile:isFoundationPointInside(x, y)
    return x >= self.x and x <= self.x + 71 and y >= self.y and y <= self.y + 96
end


function Pile:getFaceUpCardsAt(x, y)
    local selected = {}
    for i = #self.cards, 1, -1 do
        local card = self.cards[i]
        if card.faceUp and card:contains(x, y) then
            for j = i, #self.cards do
                table.insert(selected, self.cards[j])
            end
            return selected
        end
    end
    return selected
end

function Pile:removeCards(cards)
    for _ = 1, #cards do
        table.remove(self.cards)
    end
end

function Pile:canAcceptCard(card)
    local top = self.cards[#self.cards]
    if not top then
        return card.rank == "K"
    end
    local color1 = top:getColor()
    local color2 = card:getColor()
    local rankOrder = {
        A = 1, ["02"] = 2, ["03"] = 3, ["04"] = 4, ["05"] = 5, ["06"] = 6,
        ["07"] = 7, ["08"] = 8, ["09"] = 9, ["10"] = 10, J = 11, Q = 12, K = 13
    }
    return color1 ~= color2 and rankOrder[card.rank] == rankOrder[top.rank] - 1
end

function Pile:canAcceptToFoundation(card)
    if not self.isFoundation then return false end

    local top = self.cards[#self.cards]
    if not top then
        return card.rank == 1 -- Ace
    else
        return card.suit == top.suit and card.rank == top.rank + 1
    end
end

return Pile