import "CoreLibs/object"
import "fonts/fonts"
import "render/imageCache"

class("EditorMenu").extends()

function EditorMenu:init(title, options)
	EditorMenu.super.init(self)
	self.title = title
	self.options = options
	self.highlightedOptionIndex = 1
	self.parentMenu = nil
	self.childMenu = nil
	self.cursorImage = imageCache.loadImage("images/editor/menu-cursor.png")
end

function EditorMenu:update()
	if self.childMenu then
		self.childMenu:update()
	end
end

function EditorMenu:draw()
	local x, y = 10, 10
	if self.childMenu then
		self.childMenu:draw(x, y)
	else
		local cursorWidth, cursorHeight = self.cursorImage:getSize()
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
		local startIndex = math.max(1, self.highlightedOptionIndex - 9)
		local endIndex = math.min(startIndex + 11, #self.options)
		for i = startIndex, endIndex do
			local text = self.options[i].text
			local textWidth, textHeight = playdate.graphics.getTextSize(text)
			playdate.graphics.setColor(playdate.graphics.kColorWhite)
			playdate.graphics.fillRect(x - 2, y - 1, textWidth + cursorWidth + 6, textHeight + 2)
			playdate.graphics.setColor(playdate.graphics.kColorBlack)
			playdate.graphics.drawText(text, x + cursorWidth + 2, y)

			-- Draw the cursor next to the selected option
			if i == self.highlightedOptionIndex then
				self.cursorImage:draw(x, y - cursorHeight / 2 + textHeight / 2)
			end

			y += textHeight + 2
		end
	end
end

function EditorMenu:setOptions(options)
	self.options = options
	self.highlightedOptionIndex = 1
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

function EditorMenu:change(dir)
	if self.childMenu then
		self.childMenu:change()
	else
		local option = self.options[self.highlightedOptionIndex]
		if option.change then
			option.change(dir, self, option)
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
