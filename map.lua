
	require "binarystring"

	-- 0x7C: Starting cash values
	-- 0x80: Salary base
	-- 0x84: Lap bonus
	-- 0x88: Suggested target value
	
	-- 0x8C: ??? start pointer
	-- 0x90: District start pointer
	-- 0x94: Square start pointer


	function getDistrictData(data)
		-- Get data from <district start pointer> to <square start pointer - 1>
		local districtPointer	= data:getWord(0x90)
		local squarePointer		= data:getWord(0x94)

		print(string.format("DP: %04X - SP: %04X", districtPointer, squarePointer))

		return data:sub0(districtPointer, squarePointer - districtPointer)
	end


	function getSquareData(data)
		local squarePointer		= data:getWord(0x94)

		return data:sub0(squarePointer)
	end


	function parseDistricts(data)

		-- 30 bytes:	District name
		-- 1 byte: District ID
		-- 1 byte: District color
		-- 8 bytes: District squares (FF: not used)

		local len		= data:len()
		local districts	= len / 40
		print("Len: ".. len)
		assert(math.fmod(len, 40) == 0)

		local districtArray	= {}

		for i = 1, districts do
			local dData		= data:sub0(40 * (i - 1), 40)

			-- Grab the name and cut off the nulls
			local dName		= dData:sub0(0, 30):gsub("%z+$", "")
			local dId		= dData:byte(31)
			local dColor	= dData:byte(32)

			local dProperties = {}
			for j = 1, 8 do
				local dProp = dData:byte(32 + j)
				if dProp ~= 0xFF then
					dProperties[j] = dProp
				end
			end

			districtArray[dId]	= {
				id			= dId,
				name		= dName,
				color		= dColor,
				properties	= dProperties
			}

			print(string.format("%d: %-30s (id %d, col %d)", i, dName, dId, dColor))
		end

		return districtArray
	end


	function parseSquares(data)

		local len		= data:len()
		local squares	= len / 76

		local squareArray	= {}

		for i = 1, squares do
			local sData		= data:sub0(76 * (i - 1), 76)

			local sName		= sData:sub0(0, 27):gsub("%z+$", "")
			if sName == "" then sName = "<null>" end

			local sExtra	= sData:sub0(28, 4)
			local sDest		= sData:getWord(28, 1) -- Destination square for warps
			local sVariant	= sData:getWord(30, 1) -- Square variant; for warp color, etc
			local sZPos		= sData:getWord(31, 1) -- For maps with multiple floors, 0 is 1F, 1 is B1, etc
			local sType		= sData:getWord(32, 1)
			local sDistrict	= sData:getWord(33, 1)
			local sPrice	= sData:getWord(34, 2)
			local sValue	= sData:getWord(36, 4)
			local sXPos		= sData:getWord(40, 1, true)
			local sYPos		= sData:getWord(41, 1, true)

			-- Sorry if you figured this out already, but I thought this over while laying in bed
			--   sleepless.  I don't feel like touching your code so I'll just leave this long
			--   comment explaining things.
			-- <3 ~Inu
			--
			-- So this bitfield we were puzzling over before? There's 17 16-bit integers, yes?
			-- I think I worked out what they're all used for, and why there's a lot of null
			--   bytes in that mess...
			--
			-- So... each of the first 16 integers?  I'm pretty sure they correspond to
			--   what directions you're allowed to move when you move onto the square coming
			--   from that direction.
			-- I'm guessing most of them are just blank because you can't move onto the square
			--   from that direction in the first place, so there's no point filling it in?
			-- And about the seventeenth? I think that's for when you can move in any direction,
			--   via the venture card or warping on the square, or whatever.

			local sFullMoveMask	= ""
			for uDump = 0, 16 do
				for uDumpB = 0, 1 do
					sFullMoveMask	= sFullMoveMask .. toBinary(sData:getWord(42 + 2 * uDump + uDumpB, 1), 8) .. " "
				end
				-- print(hexdump(sData:sub0(42 + 2 * uDump, 2)), sFullMoveMask:gsub("0", "."))
			end

			local uDump	= 16
			local binOut	= ""
			for uDumpB = 0, 1 do
				binOut	= binOut .. toBinary(sData:getWord(42 + 2 * uDump + uDumpB, 1), 8)
			end

			squareArray[i - 1]	= {
				id			= i - 1,
				xPos		= sXPos,
				yPos		= sYPos,
				zPos		= sZPos,

				name		= sName,
				type		= sType,
				variant		= sVariant,

				value		= sValue,
				price		= sPrice,
				district	= sDistrict,
				destination	= sDest,

				moveMask	= binOut,
				moveMaskAll	= sFullMoveMask,

				extra		= sExtra
			}

		end

		return squareArray
	end
