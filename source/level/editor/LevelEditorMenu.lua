import "CoreLibs/object"
import "fonts/fonts"

class("LevelEditorMenu").extends()

LevelEditorMenu.CursorImage = playdate.graphics.image.new("images/menu-cursor.png")

function LevelEditorMenu:init(title, options)
	LevelEditorMenu.super.init(self)
	self.title = title
	self.options = options
	self.highlightedOptionIndex = 1
	self.parentMenu = nil
	self.childMenu = nil
end

function LevelEditorMenu:update(dt)
	if self.childMenu then
		self.childMenu:update(dt)
	end
end

function LevelEditorMenu:draw(x, y)
	if self.childMenu then
		self.childMenu:draw(x, y)
	else
		local cursorWidth, cursorHeight = LevelEditorMenu.CursorImage:getSize()
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
				LevelEditorMenu.CursorImage:drawAt(x, y - cursorHeight / 2 + textHeight / 2)
			end

			y += textHeight + 2
		end
	end
end

function LevelEditorMenu:highlightNextOption()
	if self.childMenu then
		self.childMenu:highlightNextOption()
	else
		self.highlightedOptionIndex += 1
		if self.highlightedOptionIndex > #self.options then
			self.highlightedOptionIndex = 1
		end
	end
end

function LevelEditorMenu:highlightPreviousOption()
	if self.childMenu then
		self.childMenu:highlightPreviousOption()
	else
		self.highlightedOptionIndex -= 1
		if self.highlightedOptionIndex < 1 then
			self.highlightedOptionIndex = #self.options
		end
	end
end

function LevelEditorMenu:select()
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

function LevelEditorMenu:increase()
	if self.childMenu then
		self.childMenu:increase()
	else
		local option = self.options[self.highlightedOptionIndex]
		if option.increase then
			option.increase(self, option)
		end
	end
end

function LevelEditorMenu:decrease()
	if self.childMenu then
		self.childMenu:decrease()
	else
		local option = self.options[self.highlightedOptionIndex]
		if option.decrease then
			option.decrease(self, option)
		end
	end
end

function LevelEditorMenu:deselect()
	if self.childMenu then
		self.childMenu:deselect()
	else
		if self.parentMenu then
			self.parentMenu.childMenu = nil
			self.parentMenu = nil
		end
	end
end
