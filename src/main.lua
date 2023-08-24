import "globals"

Screen = {}

---Hard reset the screen.
---@param color Color?
function Screen:reset(color)
	self.oldPixels = {}
	self.pixels = {}
	for i=1, SCREEN_SIZE*SCREEN_SIZE do
		self.pixels[i] = WHITE
		self.oldPixels[i] = WHITE
	end

	GFX.clear(BLACK)
	GFX.setColor(color or WHITE)
	GFX.fillRect(0, 0, SCREEN_SIZE_IN_PIX, SCREEN_SIZE_IN_PIX)
end

---Set all the pixels on the screen to `color`.
---@param color Color?
function Screen:clear(color)
	self:drawRect(0, 0, SCREEN_SIZE, SCREEN_SIZE, color or WHITE)
end

---Set a pixel in the screen to `color`.
---@param x number
---@param y number
---@param color Color?
function Screen:setPixel(x, y, color)
	color = color or WHITE

	if x < 0 or y < 0 or x >= SCREEN_SIZE or y >= SCREEN_SIZE then return end
	x = math.floor(x); y = math.floor(y)

	self.pixels[(y*SCREEN_SIZE+x)+1] = color
end

---Draw a sprite onto the screen.
---@param sprite Sprite
---@param x integer
---@param y integer
function Screen:drawSprite(sprite, x, y)
	for py=0, sprite.height-1 do
		for px=0, sprite.width-1 do
			local pos = (py*sprite.width+px)+1
			local char = sprite.data:sub(pos, pos)
			local col
			if     char == "0" then col = WHITE
			elseif char == "1" then col = BLACK
			elseif char == "2" then col = XOR
			elseif char == "-" then goto continue
			end
			if not col then error("invalid color "..char) end
			self:setPixel(x+px, y+py, col)
		    ::continue::
		end
	end
end

---Draw a rectangle onto the screen.
---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@param color Color?
function Screen:drawRect(x, y, w, h, color)
	for ry=0, h-1 do
		for rx=0, w-1 do
			self:setPixel(x+rx, y+ry, color)
		end
	end
end

---Ask the screen for a redraw.
---@return boolean # If the screen did change.
function Screen:requestRedraw()
	local didChange = false

	for i=1, SCREEN_SIZE*SCREEN_SIZE do
		if self.pixels[i] ~= self.oldPixels[i] then
			local c = self.pixels[i]

			GFX.setColor(c)
			GFX.drawPixel(
				((i-1)%SCREEN_SIZE)*SCALE,
				math.floor((i-1)/SCREEN_SIZE)
			)

			didChange = true
		end
	end

	self.oldPixels = self.pixels
	self.pixels = {}
	return didChange
end

---@type Sprite
local testSprite = {
	width = 8, height = 8,
	data = "0011110000011000001111001111111100111100001111000010010000100100",
}

local px, py = 0, 0
local oldPx, oldPy

local init = true
function PD.update()
	if init then
		Screen.reset(WHITE)
		init = false
	else
		if PD.buttonIsPressed "right" then px = px + 2 end
		if PD.buttonIsPressed "left"  then px = px - 2 end
		if PD.buttonIsPressed "down"  then py = py + 2 end
		if PD.buttonIsPressed "up"    then py = py - 2 end

		Screen:clear()
		Screen:drawSprite(testSprite, px, py)

		if px ~= oldPx or py ~= oldPy then
			Screen:requestRedraw()
			oldPx, oldPy = px, py
		end
	end
	PD.drawFPS()
end
