import "CoreLibs/object"

class("Level").extends()

function Level:init()
	Level.super.init(self)
end

function Level:update()
	physics:update()
end

function Level:draw()
	physics:draw()
end
