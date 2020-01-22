import "CoreLibs/object"

class("Menu").extends()

-- Load a font for the menu text
Menu.Font = playdate.graphics.loadFont("fonts/Full Circle/font-full-circle")
Menu.CursorImage = playdate.graphics.image.new("images/menu-cursor.png")

function Menu:init(x, y, options)
	Menu.super.init(self)
	self.position = playdate.geometry.vector2D.new(x, y)
	self.options = options
	self.selectedOptionIndex = 1
end

function Menu:update(dt)
end

function Menu:draw()
	local cursorWidth, cursorHeight = Menu.CursorImage:getSize()
	playdate.graphics.setFont(Menu.Font)

	-- Draw the menu options
	local x, y = self.position.x, self.position.y
	for i = 1, #self.options do
		local text = self.options[i].text
		local textWidth, textHeight = playdate.graphics.getTextSize(text)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRect(x - 2, y - 1, textWidth + cursorWidth + 6, textHeight + 2)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.drawText(text, x + cursorWidth + 2, y)

		-- Draw the cursor next to the selected option
		if i == self.selectedOptionIndex then
			Menu.CursorImage:drawAt(x, y - cursorHeight / 2 + textHeight / 2)
		end

		y += textHeight + 2
	end
end

function Menu:navigateDown()
	self.selectedOptionIndex += 1
	if self.selectedOptionIndex > #self.options then
		self.selectedOptionIndex = 1
	end
end

function Menu:navigateUp()
	self.selectedOptionIndex -= 1
	if self.selectedOptionIndex < 1 then
		self.selectedOptionIndex = #self.options
	end
end

function Menu:select()
	local option = self.options[self.selectedOptionIndex]
	if option.selected then
		option.selected()
	end
end
