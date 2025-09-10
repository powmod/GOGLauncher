function split(str, delimiter)
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

-- Function to perform natural sorting
function naturalSort(a, b)
    local function padNums(s)
        return s:gsub("(%d+)", function(n)
            return ("%012d"):format(tonumber(n))
        end)
    end

    a = padNums(a)
    b = padNums(b)

    return a < b
end

function round(num)
	print("num round", num)
	return math.ceil(num)
    --return math.floor(num + .5)
end

function Initialize()
	SKIN:Bang('!DeactivateConfig', 'GOGLauncher')
	local update = SKIN:GetVariable('updateList')
	
	-- function fileExists(filename)
		-- local file = io.open(filename, "r")
		-- if file then
			-- io.close(file)
			-- return true
		-- else
			-- return false
		-- end
	-- end
	
	-- if not fileExists(SKIN:GetVariable('GameDataPath')) then

		-- local script = SKIN:GetVariable('ScriptPath')
		-- local Database = SKIN:GetVariable('DatabasePath')
		-- local cd = string.format('cd "%s"', script)	
		-- local command = string.format('Update.bat "%s"', Database)	
		-- local commands = cd .. " && " .. command
		-- os.execute(commands)
	-- end
	
	local GOGClient = SKIN:GetVariable('GOGGalaxyPath')
	local script = SKIN:GetVariable('ScriptPath')
	local Database = SKIN:GetVariable('DatabasePath')
	-- local Exclude = SKIN:GetVariable('ExcludeList')
	
	if tonumber(update) == 1 then
		local cd = string.format('cd "%s"', script)	
		local command = string.format('Update.bat "%s"', Database)	
		local commands = cd .. " && " .. command
		os.execute(commands)
	end
	
	
	-- Parameters
	local ResX, ResY = SKIN:GetVariable('WORKAREAWIDTH'), SKIN:GetVariable('WORKAREAHEIGHT')  -- Screen resolution
	local factor = 5E-4 * math.sqrt(ResX * ResY)
	local ImgX, ImgY = SKIN:GetVariable('ImageWidth'), SKIN:GetVariable('ImageHeight')    -- Image size
	local ImgA = ImgX * ImgY
	local padding = SKIN:GetVariable('ImageSpacing') * factor 
	local ResA = (ResX - padding*2) * (ResY - padding*2)
	local radius = SKIN:GetVariable('CornerRadius') * factor
	local NperRow = math.floor(SKIN:GetVariable('NumberOfColumns'))
	local zoom = SKIN:GetVariable('Zoom')
	local comp = .99
	local shadow, shadowAlpha = SKIN:GetVariable('dropShadow'), SKIN:GetVariable('shadowAlpha')
	local shadowOffset =  SKIN:GetVariable('shadowOffset') * factor
	local shadowSize = zoom * SKIN:GetVariable('shadowSize') * factor
	local shadowMask = SKIN:GetVariable('shadowMask')
	local transpose = SKIN:GetVariable('Transpose')

	print("res x, res y", ResX, ResY)
	print("total work area", ResA)
	
    local iniContent = [[


]]

    local file = io.open(SKIN:GetVariable('GameDataPath'), 'r')
	local Exclude = io.open(SKIN:GetVariable('ExcludeList'), 'r')
	
	local excludeLines = {}
	for line in Exclude:lines() do
		excludeLines[line] = true
	end

	local lines = {}
	for line in file:lines() do
		if not excludeLines[line] then
			table.insert(lines, line)
		end
	end
	
	table.sort(lines, function(a, b)
		local aColumns = split(a, "|")
		local bColumns = split(b, "|")
		return naturalSort(aColumns[1], bColumns[1])
	end)

	if file then
		local launchParams = {}
		local linesArray = {}
		for i, line in ipairs(lines) do
			local columns = split(line, "|")
			local launch = columns[2]
			local path = columns[5]
			entry = SKIN:GetVariable('WebCachePath') .. '\\' .. path
			table.insert(linesArray, entry)
			table.insert(launchParams, launch)
		end

		N = #linesArray
		print("N", N)

		if tonumber(NperRow) == 0 then
			scaling = math.sqrt((ResA - N * (padding * (ImgX + ImgY) - padding^2)) / (N * ImgA))
			--print("scaling", scaling)
			
			Nx = math.floor(ResX / (ImgX * scaling + padding))
			--Ny = math.ceil(ResY / (ImgY * scaling + padding))
			--print(ResX / (ImgX * scaling + padding),ResY / (ImgY * scaling + padding))
			Ny = round(N / Nx)
			scaling_x = (((ResX / Nx) - padding) / ImgX)
			scaling_y = (((ResY / Ny) - padding) / ImgY)
			
			scaling = math.min(scaling_x, scaling_y)
			print("scaling", scaling)
			print("Nx", Nx)
			print("Ny", Ny)
			
		else
			Nx = NperRow
			Ny = round(N / Nx)
			scaling_x = (((ResX / Nx) - padding) / ImgX)
			scaling_y = (((ResY / Ny) - padding) / ImgY)
			
			scaling = math.min(scaling_x, scaling_y)
			print("scaling", scaling)
			print("Nx", Nx)
			print("Ny", Ny)
			
		end

		
		ImgXS = ImgX * scaling * zoom
		ImgYS = ImgY * scaling * zoom

		emptyX = (ResX - Nx * (ImgXS + padding)) / 2
		emptyY = (ResY - Ny * (ImgYS + padding)) / 2

		startX = emptyX - (padding / 2) - ImgXS
		startY = emptyY - (padding / 2) - ImgYS
		
		if tonumber(transpose) == 1 then
			tempY = Ny
			tempX = Nx
			Nx = tempY
			Ny = tempX
			
			tempImgXS = ImgXS
			tempImgYS = ImgYS
			tempstartX = startX
			tempstartY = startY
			
			ImgXS = tempImgYS
			ImgYS = tempImgXS
			startX = tempstartY
			startY = tempstartX
			
		end
			
			

		count = 1
		for n = 1, Ny do
			for m = 1, Nx do
				pathN = linesArray[count]
				launchN = launchParams[count]
				x = m * (padding + ImgXS) + startX
				y = n * (padding + ImgYS) + startY
				

				entryMeter1 = string.format([[
[MeterGrid%d]
Meter=Image
ImageName=%s
X=%f
Y=%f
W=%f
H=%f
Container=MeterMask%d


[MeterGlow%d]
Meter=Image
ImageName=#@#\glow.png
X=%f
Y=%f
W=%f
H=%f
ColorMatrix1=1; 0; 0; 0; 0
ColorMatrix2=0; 1; 0; 0; 0
ColorMatrix3=0; 0; 1; 0; 0
ColorMatrix5=.5; .5; .5; 0; 1
Container=MeterMask%d
ImageAlpha=0
MouseOverAction=[!SetOption MeterGlow%d ImageAlpha 50][!SetOption MeterGrid%d ColorMatrix1 1.924452;-0.055548;-0.055548;0;0][!SetOption MeterGrid%d ColorMatrix2 -0.109692;1.870308;-0.109692;0;0][!SetOption MeterGrid%d ColorMatrix3 -0.01476;-0.01476;1.96524;0;0][!SetOption MeterGrid%d ColorMatrix5 -0.15;-0.15;-0.15;0;1][!UpdateMeter MeterGlow%d][!UpdateMeter MeterGrid%d][!Redraw]
MouseLeaveAction=[!SetOption MeterGlow%d ImageAlpha 0][!SetOption MeterGrid%d ColorMatrix1 1;0;0;0;0][!SetOption MeterGrid%d ColorMatrix2 0;1;0;0;0][!SetOption MeterGrid%d ColorMatrix3 0;0;1;0;0][!SetOption MeterGrid%d ColorMatrix5 0;0;0;0;1][!UpdateMeter MeterGlow%d][!UpdateMeter MeterGrid%d][!Redraw]
LeftMouseDoubleClickAction=%s

]], count, pathN, x, y, ImgXS, ImgYS, count, 
	count, x, y, ImgXS, ImgYS, count, count, count, count, count, count, count, count, count, count, count, count, count, count, count,  '["'.. GOGClient .. '"' .. " /command=runGame /gameId=" .. launchN .. "]")
				
				entryMeter2 = string.format([[
[MeterMask%d]
Meter=Shape
Shape=Rectangle %f, %f, %f, %f, %f, %f

]], count, x, y, ImgXS * comp, ImgYS * comp, radius, radius)
				
				if tonumber(shadow) == 1 then
				
					entryMeter3 = string.format([[
[MeterShadow%d]
Meter=Image
ImageName=%s
X=%f
Y=%f
W=%f
H=%f
ImageAlpha=%f

]], count, shadowMask, x+shadowOffset, y+shadowOffset, ImgXS+shadowSize, ImgYS+shadowSize, shadowAlpha)

					iniContent = iniContent .. '\n' .. entryMeter3 .. entryMeter2 .. entryMeter1
				else
					iniContent = iniContent .. '\n' .. entryMeter2 .. entryMeter1
				end

				count = count + 1

				if count > N then
					break
				end
			end

			if count > N then
				break
			end
		end

		file:close()
	end

    iniFile = io.open(SKIN:GetVariable('mainPath'), 'w')
    iniFile:write(iniContent)
    iniFile:close()

	print("DONE!")
	SKIN:Bang('!ActivateConfig', 'GOGLauncher', 'GOGLauncher.ini')
end
