local Pile = {}
Pile.__index = Pile

function Pile:new(x, y, isFoundation)
    local self = setmetatable({}, Pile)
    self.x = x
    self.y = y
    self.cards = {}
    self.isFoundation = isFoundation or false
    return self
end

function Pile:addCard(card)
    local offset = self.isFoundation and 0 or 20
    card.x = self.x
    card.y = self.y + (#self.cards * offset)
    table.insert(self.cards, card)
end

function Pile:addCards(cards)
    for _, card in ipairs(cards) do
        self:addCard(card)
    end
end

function Pile:removeCards(cards)
    local startIndex = nil
    for i = 1, #self.cards do
        if self.cards[i] == cards[1] then
            startIndex = i
            break
        end
    end

    if startIndex then
        for i = #self.cards, startIndex, -1 do
            table.remove(self.cards, i)
        end
    end
end

function Pile:removeTopCards(n)
    local removed = {}
    for i = 1, n do
        local card = table.remove(self.cards)
        if card then
            table.insert(removed, 1, card) -- insert at front to preserve order
        end
    end
    return removed
end

function Pile:getFaceUpCardsAt(x, y)
    local selected = {}

    if not self:isPointInside(x, y) then
        return selected
    end

    if self.isFoundation then
        local topCard = self.cards[#self.cards]
        if topCard and topCard.faceUp and
           x >= topCard.x and x <= topCard.x + 71 and
           y >= topCard.y and y <= topCard.y + 96 then
            table.insert(selected, topCard)
        end
    else
        for i = #self.cards, 1, -1 do
            local card = self.cards[i]
            if card.faceUp and
               x >= card.x and x <= card.x + 71 and
               y >= card.y and y <= card.y + 96 then
                for j = i, #self.cards do
                    table.insert(selected, self.cards[j])
                end
                break
            end
        end
    end

    return selected
end


function Pile:isPointInside(x, y)
    if self.isFoundation then
        return x >= self.x and x <= self.x + 71 and y >= self.y and y <= self.y + 96
    else
        local lastY = self.y + (#self.cards - 1) * 20
        return x >= self.x and x <= self.x + 71 and y >= self.y and y <= lastY + 96
    end
end

function Pile:canAcceptToFoundation(card)
    if not self.isFoundation then return false end

    local top = self.cards[#self.cards]
    if not top then
        return card.rank == "A" or card.value == 1
    else
        return top.suit == card.suit and card.value == top.value + 1
    end
end

function Pile:canAcceptToTableau(card)
    if self.isFoundation then return false end

    local top = self.cards[#self.cards]
    if not top then
        return card.value == 13 -- King
    else
        return top.color ~= card.color and card.value == top.value - 1
    end
end

function Pile:draw()
    if #self.cards == 0 then
        love.graphics.setColor(0.2, 0.6, 0.2)
        love.graphics.rectangle("line", self.x, self.y, 71, 96)
        love.graphics.setColor(1, 1, 1)
    end

    for i, card in ipairs(self.cards) do
        local offset = self.isFoundation and 0 or (i - 1) * 20
        card.x = self.x
        card.y = self.y + offset
        card:draw()
    end
end

return Pile
