function Initialize()
    -- This script handles context menu actions for hiding/showing games
end

function HideGame(gameData)
    -- Parse the game data (format: "title|launchId|userId|typeId|imagePath")
    local excludeFile = SKIN:GetVariable('@') .. 'Script\\ExcludeList.txt'
    
    -- Append the game to exclude list
    local file = io.open(excludeFile, 'a')
    if file then
        file:write(gameData .. '\n')
        file:close()
        
        -- Refresh the skin
        SKIN:Bang('!SetVariable', 'updateList', '0')  -- Don't update from database
        SKIN:Bang('!Refresh', 'GOGLauncher', 'Update.ini')
    else
        print("Error: Could not open exclude list for writing")
    end
end

function ShowHiddenGames()
    local excludeFile = SKIN:GetVariable('@') .. 'Script\\ExcludeList.txt'
    local gameDataFile = SKIN:GetVariable('@') .. 'Script\\GameData.txt'
    
    -- Read excluded games
    local file = io.open(excludeFile, 'r')
    if not file then
        SKIN:Bang('!SetOption', 'MeterHiddenGames', 'Text', 'No hidden games')
        SKIN:Bang('!ShowMeter', 'MeterHiddenGames')
        SKIN:Bang('!Redraw')
        return
    end
    
    local excludedGames = {}
    for line in file:lines() do
        table.insert(excludedGames, line)
    end
    file:close()
    
    if #excludedGames == 0 then
        SKIN:Bang('!SetOption', 'MeterHiddenGames', 'Text', 'No hidden games')
        SKIN:Bang('!ShowMeter', 'MeterHiddenGames')
        SKIN:Bang('!Redraw')
        return
    end
    
    -- Create a temporary skin file to show hidden games
    local tempSkinContent = [[
[Rainmeter]
Update=1000
BackgroundMode=2
SolidColor=20,20,20,240

[Variables]
Padding=10
ItemHeight=30
ItemWidth=400

[MeterBackground]
Meter=Image
SolidColor=20,20,20,240
W=420
H=(20+#ItemHeight#*]] .. #excludedGames .. [[)
MouseScrollUpAction=[!SetVariable ScrollOffset "(Clamp(#ScrollOffset#-1,0,]] .. (#excludedGames - 10) .. [[))"][!UpdateMeter *][!Redraw]
MouseScrollDownAction=[!SetVariable ScrollOffset "(Clamp(#ScrollOffset#+1,0,]] .. (#excludedGames - 10) .. [[))"][!UpdateMeter *][!Redraw]

[MeterTitle]
Meter=String
Text=Hidden Games (Right-click to unhide)
X=10
Y=5
FontColor=255,255,255,255
FontSize=12
FontWeight=Bold
AntiAlias=1

]]
    
    -- Add a meter for each hidden game
    for i, gameData in ipairs(excludedGames) do
        local columns = {}
        for match in (gameData..'|'):gmatch('(.-)|') do
            table.insert(columns, match)
        end
        
        local gameTitle = columns[1] or "Unknown Game"
        -- Escape special characters in game data for Rainmeter
        local escapedData = gameData:gsub('"', '""')
        
        tempSkinContent = tempSkinContent .. string.format([[
[MeterGame%d]
Meter=String
Text=%s
X=10
Y=(25+#ItemHeight#*%d)
W=#ItemWidth#
H=#ItemHeight#
FontColor=200,200,200,255
FontSize=10
AntiAlias=1
MouseOverAction=[!SetOption MeterGame%d FontColor "255,255,255,255"][!Redraw]
MouseLeaveAction=[!SetOption MeterGame%d FontColor "200,200,200,255"][!Redraw]
RightMouseUpAction=[!CommandMeasure MeasureScript "UnhideGame('%s')"]
ToolTipText=Right-click to unhide this game

]], i, gameTitle, i-1, i, i, escapedData:gsub("'", "\\'"))
    end
    
    -- Add the script measure
    tempSkinContent = tempSkinContent .. [[
[MeasureScript]
Measure=Script
ScriptFile=#@#Script\ContextMenu.lua
]]
    
    -- Write the temporary skin
    local tempSkinFile = SKIN:GetVariable('@') .. '..\\GOGLauncher\\HiddenGames.ini'
    local file = io.open(tempSkinFile, 'w')
    if file then
        file:write(tempSkinContent)
        file:close()
        
        -- Load the hidden games skin
        SKIN:Bang('!ActivateConfig', 'GOGLauncher', 'HiddenGames.ini')
    end
end

function UnhideGame(gameData)
    local excludeFile = SKIN:GetVariable('@') .. 'Script\\ExcludeList.txt'
    
    -- Read all lines except the one to unhide
    local file = io.open(excludeFile, 'r')
    if not file then return end
    
    local lines = {}
    for line in file:lines() do
        if line ~= gameData then
            table.insert(lines, line)
        end
    end
    file:close()
    
    -- Write back the filtered list
    file = io.open(excludeFile, 'w')
    if file then
        for _, line in ipairs(lines) do
            file:write(line .. '\n')
        end
        file:close()
        
        -- Refresh both skins
        SKIN:Bang('!DeactivateConfig', 'GOGLauncher', 'HiddenGames.ini')
        SKIN:Bang('!SetVariable', 'updateList', '0')
        SKIN:Bang('!Refresh', 'GOGLauncher', 'Update.ini')
    end
end

function ViewExcludeList()
    -- Open the exclude list in notepad for manual editing
    local excludeFile = SKIN:GetVariable('@') .. 'Script\\ExcludeList.txt'
    SKIN:Bang('["notepad.exe" "' .. excludeFile .. '"]')
end