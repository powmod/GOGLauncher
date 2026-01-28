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
    return padNums(a) < padNums(b)
end

function round(num)
    return math.floor(num + 0.5)
end

-- Function to check if a file exists
function fileExists(path)
    local file = io.open(path, 'r')
    if file then
        file:close()
        return true
    end
    return false
end

-- Function to get file size (to check if file has content)
function getFileSize(path)
    local file = io.open(path, 'r')
    if file then
        local size = file:seek("end")
        file:close()
        return size
    end
    return 0
end

-- Helper function to generate meter entries
function generateMeterEntry(count, path, launch, x, y, w, h, radius, GOGClient)
    local glowAction = string.format(
        "[!SetOption MeterGlow%d ImageAlpha 50]" ..
        "[!SetOption MeterGrid%d ColorMatrix1 1.924452;-0.055548;-0.055548;0;0]" ..
        "[!SetOption MeterGrid%d ColorMatrix2 -0.109692;1.870308;-0.109692;0;0]" ..
        "[!SetOption MeterGrid%d ColorMatrix3 -0.01476;-0.01476;1.96524;0;0]" ..
        "[!SetOption MeterGrid%d ColorMatrix5 -0.15;-0.15;-0.15;0;1]" ..
        "[!UpdateMeter MeterGlow%d][!UpdateMeter MeterGrid%d][!Redraw]",
        count, count, count, count, count, count, count
    )
    
    local leaveAction = string.format(
        "[!SetOption MeterGlow%d ImageAlpha 0]" ..
        "[!SetOption MeterGrid%d ColorMatrix1 1;0;0;0;0]" ..
        "[!SetOption MeterGrid%d ColorMatrix2 0;1;0;0;0]" ..
        "[!SetOption MeterGrid%d ColorMatrix3 0;0;1;0;0]" ..
        "[!SetOption MeterGrid%d ColorMatrix5 0;0;0;0;1]" ..
        "[!UpdateMeter MeterGlow%d][!UpdateMeter MeterGrid%d][!Redraw]",
        count, count, count, count, count, count, count
    )
    
    local launchAction = string.format('["'.. GOGClient .. '" /command=runGame /gameId=%s]', launch)
    
    local meterGrid = string.format([[
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
MouseOverAction=%s
MouseLeaveAction=%s
LeftMouseDoubleClickAction=%s
]], 
    count, path, x, y, w, h, count,
    count, x, y, w, h, count,
    glowAction, leaveAction, launchAction)
    
    local meterMask = string.format([[
[MeterMask%d]
Meter=Shape
Shape=Rectangle %f, %f, %f, %f, %f, %f
]], count, x, y, w * 0.99, h * 0.99, radius, radius)
    
    return meterMask, meterGrid
end

function Initialize()
    SKIN:Bang('!DeactivateConfig', 'GOGLauncher')
    
    -- Get configuration variables
    local update = SKIN:GetVariable('updateList')
    local GOGClient = SKIN:GetVariable('GOGGalaxyPath')
    local script = SKIN:GetVariable('ScriptPath')
    local Database = SKIN:GetVariable('DatabasePath')
    local gameDataPath = SKIN:GetVariable('GameDataPath')
    
    print("=== GOG Launcher Update Script ===")
    print("Script path: " .. (script or "nil"))
    print("Database path: " .. (Database or "nil"))
    print("GameData path: " .. (gameDataPath or "nil"))
    print("Update flag: " .. (update or "nil"))
    
    -- Update database if requested
    if tonumber(update) == 1 then
        print("Updating game data from database...")
        
        -- Check if database exists
        if not fileExists(Database) then
            print("ERROR: Database file not found: " .. Database)
            print("Make sure GOG Galaxy is installed and the database path is correct.")
            return
        end
        print("Database file found: OK")
        
        -- Check if sqlite3.exe exists in script folder
        local sqlite3Path = script .. "sqlite3.exe"
        if not fileExists(sqlite3Path) then
            print("WARNING: sqlite3.exe not found in script folder: " .. sqlite3Path)
            print("Trying system PATH...")
        else
            print("sqlite3.exe found: OK")
        end
        
        -- Check if query.sql exists
        local queryPath = script .. "query.sql"
        if not fileExists(queryPath) then
            print("ERROR: query.sql not found: " .. queryPath)
            return
        end
        print("query.sql found: OK")
        
        -- Build and execute the command using cmd /c for better reliability
        -- Use full paths to avoid working directory issues
        local batPath = script .. "Update.bat"
        if not fileExists(batPath) then
            print("ERROR: Update.bat not found: " .. batPath)
            return
        end
        print("Update.bat found: OK")
        
        -- Execute with cmd /c and full path to batch file
        local command = string.format('cmd /c ""%s" "%s""', batPath, Database)
        print("Executing command: " .. command)
        
        local result = os.execute(command)
        print("Command result: " .. tostring(result))
        
        -- Check if GameData.txt was created/updated
        if not fileExists(gameDataPath) then
            print("ERROR: GameData.txt was not created!")
            print("Check that sqlite3.exe is in the Script folder or system PATH")
            return
        end
        
        local fileSize = getFileSize(gameDataPath)
        print("GameData.txt size: " .. fileSize .. " bytes")
        
        if fileSize == 0 then
            print("WARNING: GameData.txt is empty!")
            print("This could mean:")
            print("  - sqlite3.exe is not available")
            print("  - The query returned no results")
            print("  - GOG Galaxy database has no games")
        end
    else
        print("Skipping database update (updateList=0)")
    end
    
    -- Get display parameters
    local ResX = tonumber(SKIN:GetVariable('WORKAREAWIDTH'))
    local ResY = tonumber(SKIN:GetVariable('WORKAREAHEIGHT'))
    local factor = 5E-4 * math.sqrt(ResX * ResY)
    local ImgX = tonumber(SKIN:GetVariable('ImageWidth'))
    local ImgY = tonumber(SKIN:GetVariable('ImageHeight'))
    local padding = tonumber(SKIN:GetVariable('ImageSpacing')) * factor
    local radius = tonumber(SKIN:GetVariable('CornerRadius')) * factor
    local NperRow = math.floor(tonumber(SKIN:GetVariable('NumberOfColumns')))
    local zoom = tonumber(SKIN:GetVariable('Zoom'))
    local transpose = tonumber(SKIN:GetVariable('Transpose'))
    
    -- Get alignment setting (default to center if not specified)
    local gridAlignment = SKIN:GetVariable('GridAlignment')
    if gridAlignment == nil or gridAlignment == '' then
        gridAlignment = 'center'
    end
    gridAlignment = gridAlignment:lower()  -- Convert to lowercase for consistency
    
    -- Shadow parameters
    local shadow = tonumber(SKIN:GetVariable('dropShadow'))
    local shadowAlpha = tonumber(SKIN:GetVariable('shadowAlpha'))
    local shadowOffset = tonumber(SKIN:GetVariable('shadowOffset')) * factor
    local shadowSize = tonumber(SKIN:GetVariable('shadowSize')) * factor * zoom
    local shadowMask = SKIN:GetVariable('shadowMask')
    
    print("Resolution:", ResX, "x", ResY)
    print("Image dimensions:", ImgX, "x", ImgY)
    print("Transpose:", transpose)
    print("Grid alignment:", gridAlignment)
    
    -- Read and process game data
    local file = io.open(gameDataPath, 'r')
    local excludeFile = io.open(SKIN:GetVariable('ExcludeList'), 'r')
    
    if not file then
        print("ERROR: Could not open game data file: " .. gameDataPath)
        print("Make sure the database update ran successfully")
        return
    end
    
    -- Build exclude list
    local excludeLines = {}
    if excludeFile then
        for line in excludeFile:lines() do
            excludeLines[line] = true
        end
        excludeFile:close()
    end
    
    -- Read and filter game entries
    local lines = {}
    for line in file:lines() do
        if line ~= "" and not excludeLines[line] then
            table.insert(lines, line)
        end
    end
    file:close()
    
    print("Total lines read: " .. #lines)
    
    -- Sort games alphabetically
    table.sort(lines, function(a, b)
        local aColumns = split(a, "|")
        local bColumns = split(b, "|")
        return naturalSort(aColumns[1], bColumns[1])
    end)
    
    -- Extract launch parameters and image paths
    local launchParams = {}
    local imagePaths = {}
    local webCachePath = SKIN:GetVariable('WebCachePath')
    
    for i, line in ipairs(lines) do
        local columns = split(line, "|")
        if #columns >= 5 then
            table.insert(launchParams, columns[2])
            
            -- Get the image path from column 5
            local imgPath = columns[5]
            
            -- Debug output
            print("Game " .. i .. ": " .. columns[1])
            print("  Path from DB: '" .. imgPath .. "'")
            
            local fullPath
            
            -- Check if it's already an absolute Windows path (has drive letter like C:\)
            if imgPath:match("^[A-Za-z]:[/\\]") then
                -- Already absolute, use as-is
                fullPath = imgPath
                print("  -> Absolute path, using as-is")
            else
                -- Relative path - simply concatenate with webcache path
                -- Keep it simple: webcache path + backslash + relative path
                -- Rainmeter handles mixed slashes fine (backslash then forward slashes)
                fullPath = webCachePath .. '\\' .. imgPath
                print("  -> Relative path, prepended webcache")
            end
            
            print("  Final: '" .. fullPath .. "'")
            
            table.insert(imagePaths, fullPath)
        else
            print("Warning: Invalid line format (expected 5+ columns, got " .. #columns .. "): " .. line)
        end
    end
    
    local N = #imagePaths
    print("Number of games:", N)
    
    if N == 0 then
        print("No games found!")
        print("Possible causes:")
        print("  - GameData.txt is empty or not populated")
        print("  - All games are in the exclude list")
        print("  - Database query returned no results")
        return
    end
    
    -- Calculate grid layout
    local Nx, Ny, scaling
    local WorkAreaX = ResX - padding * 2
    local WorkAreaY = ResY - padding * 2
    
    if NperRow == 0 then
        -- Auto-calculate optimal grid layout by testing all possible configurations
        local bestScaling = 0
        local bestNx = 1
        local bestNy = N
        
        -- Test all possible column counts from 1 to N
        for testNx = 1, N do
            local testNy = math.ceil(N / testNx)
            
            -- Calculate scaling for this configuration
            -- Account for padding between images (not at edges)
            local availableWidth = WorkAreaX - (testNx - 1) * padding
            local availableHeight = WorkAreaY - (testNy - 1) * padding
            
            local scaling_x = availableWidth / (testNx * ImgX)
            local scaling_y = availableHeight / (testNy * ImgY)
            local testScaling = math.min(scaling_x, scaling_y)
            
            -- Check if this configuration is better
            if testScaling > bestScaling then
                bestScaling = testScaling
                bestNx = testNx
                bestNy = testNy
            end
        end
        
        Nx = bestNx
        Ny = bestNy
        scaling = bestScaling
        
        print("Auto-layout: tested all configurations")
        print("Best configuration: " .. Nx .. " columns x " .. Ny .. " rows")
        print("Best scaling: " .. scaling)
    else
        Nx = NperRow
        Ny = math.ceil(N / Nx)
        
        -- Calculate scaling with proper padding calculation
        local availableWidth = WorkAreaX - (Nx - 1) * padding
        local availableHeight = WorkAreaY - (Ny - 1) * padding
        
        local scaling_x = availableWidth / (Nx * ImgX)
        local scaling_y = availableHeight / (Ny * ImgY)
        scaling = math.min(scaling_x, scaling_y)
    end
    
    -- Apply zoom
    scaling = scaling * zoom
    
    print("Grid layout:", Nx, "x", Ny)
    print("Scaling factor:", scaling)
    
    -- Calculate scaled image dimensions
    local ImgXS = ImgX * scaling
    local ImgYS = ImgY * scaling
    
    -- Handle transposition BEFORE calculating positions
    local GridCols, GridRows = Nx, Ny
    local CellWidth, CellHeight = ImgXS, ImgYS
    
    if transpose == 1 then
        -- For transposed layout: iterate in column-major order
        -- but keep the same grid dimensions
        print("Applying transpose")
    end
    
    -- Calculate starting positions based on alignment
    local totalWidth = GridCols * CellWidth + (GridCols - 1) * padding
    local totalHeight = GridRows * CellHeight + (GridRows - 1) * padding
    local startX, startY
    
    -- Calculate horizontal position based on alignment
    if gridAlignment == 'left' then
        startX = 2 * padding  -- Align to left with padding
    elseif gridAlignment == 'right' then
        startX = ResX - totalWidth - padding  -- Align to right with padding
    else  -- center (default)
        startX = (ResX - totalWidth) / 2  -- Center horizontally
    end
    
    -- Vertical position is always centered
    startY = (ResY - totalHeight) / 2
    
    print("Grid starting position: X=" .. startX .. ", Y=" .. startY)
    
    -- Generate INI content
    local iniContent = [[

[MeasureContextMenu]
Measure=Script
ScriptFile=#@#Script\ContextMenu.lua

]]
    local count = 1
    
    for idx = 1, N do
        local row, col
        
        if transpose == 1 then
            -- Column-major order (fill columns first)
            col = math.floor((idx - 1) / GridRows) + 1
            row = ((idx - 1) % GridRows) + 1
        else
            -- Row-major order (fill rows first - default)
            row = math.floor((idx - 1) / GridCols) + 1
            col = ((idx - 1) % GridCols) + 1
        end
        
        -- Calculate position
        local x = startX + (col - 1) * (CellWidth + padding)
        local y = startY + (row - 1) * (CellHeight + padding)
        
        -- Generate shadow meter if enabled
        if shadow == 1 then
            local shadowEntry = string.format([[
[MeterShadow%d]
Meter=Image
ImageName=%s
X=%f
Y=%f
W=%f
H=%f
ImageAlpha=%f
]], count, shadowMask, x + shadowOffset, y + shadowOffset, 
    CellWidth + shadowSize, CellHeight + shadowSize, shadowAlpha)
            iniContent = iniContent .. shadowEntry .. "\n"
        end
        
        -- Generate mask and grid meters
        local maskEntry, gridEntry = generateMeterEntry(
            count, imagePaths[idx], launchParams[idx], 
            x, y, CellWidth, CellHeight, radius, GOGClient
        )
        
        iniContent = iniContent .. maskEntry .. "\n" .. gridEntry .. "\n"
        count = count + 1
    end
    
    -- Write the generated INI file
    local mainPath = SKIN:GetVariable('mainPath')
    print("Writing configuration to: " .. mainPath)
    
    local iniFile = io.open(mainPath, 'w')
    if iniFile then
        iniFile:write(iniContent)
        iniFile:close()
        print("Configuration file generated successfully")
    else
        print("ERROR: Could not write configuration file: " .. mainPath)
        return
    end
    
    print("=== DONE! ===")
    SKIN:Bang('!ActivateConfig', 'GOGLauncher', 'GOGLauncher.ini')
end
