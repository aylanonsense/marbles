import "CoreLibs/object"
import "fonts/fonts"

class("EditorMenu").extends()

EditorMenu.CursorImage = playdate.graphics.image.new("images/menu-cursor.png")

function EditorMenu:init(title, options)
	EditorMenu.super.init(self)
	self.title = title
	self.options = options
	self.highlightedOptionIndex = 1
	self.parentMenu = nil
	self.childMenu = nil
end

function EditorMenu:update()
	if self.childMenu then
		self.childMenu:update()
	end
end

function EditorMenu:draw(x, y)
	if self.childMenu then
		self.childMenu:draw(x, y)
	else
		local cursorWidth, cursorHeight = EditorMenu.CursorImage:getSize()
		playdate.graphics.setFont(fonts.FullCircle)

		-- Draw the menu title
		if self.title then
			local textWidth, textHeight = playdate.graphics.getTextSize(self.title)
			playdate.graphics.setColor(playdate.graphics.kColorWhite)
			playdate.graphics.fillRect(x - 2, y - 1, textWidth + 4, textHeight + 2)
			playdate.graphics.setColor(playdate.graphics.kColorBlack)
			playdate.graphics.drawText(self.title, x + 2, y)
			playdate.graphics.setLineWidth(2)
			playdate.graphics.drawLine(x, y + textHeight, x + textWidth, y + textHeight)
			y += textHeight + 5
		end

		-- Draw the menu options
		for i = 1, #self.options do
			local text = self.options[i].text
			local textWidth, textHeight = playdate.graphics.getTextSize(text)
			playdate.graphics.setColor(playdate.graphics.kColorWhite)
			playdate.graphics.fillRect(x - 2, y - 1, textWidth + cursorWidth + 6, textHeight + 2)
			playdate.graphics.setColor(playdate.graphics.kColorBlack)
			playdate.graphics.drawText(text, x + cursorWidth + 2, y)

			-- Draw the cursor next to the selected option
			if i == self.highlightedOptionIndex then
				EditorMenu.CursorImage:drawAt(x, y - cursorHeight / 2 + textHeight / 2)
			end

			y += textHeight + 2
		end
	end
end

function EditorMenu:highlightNextOption()
	if self.childMenu then
		self.childMenu:highlightNextOption()
	else
		self.highlightedOptionIndex += 1
		if self.highlightedOptionIndex > #self.options then
			self.highlightedOptionIndex = 1
		end
	end
end

function EditorMenu:highlightPreviousOption()
	if self.childMenu then
		self.childMenu:highlightPreviousOption()
	else
		self.highlightedOptionIndex -= 1
		if self.highlightedOptionIndex < 1 then
			self.highlightedOptionIndex = #self.options
		end
	end
end

function EditorMenu:select()
	if self.childMenu then
		self.childMenu:select()
	else
		local option = self.options[self.highlightedOptionIndex]
		if option.selected then
			option.selected(self, option)
		end
		if option.submenu then
			self.childMenu = option.submenu
			self.childMenu.parentMenu = self
		end
	end
end

function EditorMenu:increase()
	if self.childMenu then
		self.childMenu:increase()
	else
		local option = self.options[self.highlightedOptionIndex]
		if option.increase then
			option.increase(self, option)
		end
	end
end

function EditorMenu:decrease()
	if self.childMenu then
		self.childMenu:decrease()
	else
		local option = self.options[self.highlightedOptionIndex]
		if option.decrease then
			option.decrease(self, option)
		end
	end
end

function EditorMenu:deselect()
	if self.childMenu then
		self.childMenu:deselect()
		return true
	elseif self.parentMenu then
		self.parentMenu.childMenu = nil
		self.parentMenu = nil
		return true
	end
end
