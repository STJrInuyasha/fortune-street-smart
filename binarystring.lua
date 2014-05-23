
	local function bytesToNumber(word, signed)

		local n, i	= 0
		local l	= word:len()
		for i = 1, l do
			n	= n + word:byte(i) * 256 ^ (i - 1)
		end

		if signed then
			if n >= (2 ^ (l * 8 - 1)) then
				n	= n - (2 ^ (l * 8))
			end
		end

		return n

	end

	
	function toBinary(n, l)

		out		= ""
		while n >= 1 do
			out	= math.floor(math.fmod(n, 2)) .. out
			n	= math.floor(n / 2)
		end

		local p	= math.ceil(out:len() / 8) * 8

		return string.format("%0".. (l and l or p) .."s", out)

	end


	function string:hexDump(showDec)

		local len	= self:len()
		local out	= ""
		local out2	= ""
		for i = 1, len do
			out		= out .. string.format("%02x ", self:byte(i))
			if (i % 4 == 1) then
				out2	= out2 .. string.format("%11d  ", self:getWord(i - 1))
			end
			if (i % 4 == 0) then
				out	= out .. " "
			end

		end
		return out .. (showDec and ("\n".. out2) or "")

	end


	function string:getWord(ofs, l, signed)
		return bytesToNumber(self:sub0(ofs, l and l or 4), signed and true or false)
	end


	-- s = start (0-ind), l = length
	function string:sub0(s, l)
		return self:sub(s + 1, l and (s + l) or nil)
	end

