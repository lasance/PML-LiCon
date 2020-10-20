--[[
	---------------------------------------------------------
    PML Lights Controller 
    
    This is a simple app to control the patterns of lights connected
	to an electronic switch such as the RCExel Opti.
    
	---------------------------------------------------------
	Localisation-file has to be as /Apps/Lang/PML-LiCon.jsn
	---------------------------------------------------------
	This software is freeware and offered with no warranty.
	
	Ensure you do not select a control channel as this will
	make the servos move without control input, only use for
	ancillary functions
	---------------------------------------------------------
	Written by Paul Lasance 2020
	---------------------------------------------------------
--]]

--------------------------------------------------------------------------------
-- Locals for application
local actSw, patternSw, delayPot
local lastClk = 0
local sysTimer = 0
local delay = 0
local ctrlIdx = 1
local patternName = ""
local switch, pattern, patternStep, lockSw,delay, output = 1,7,0,0,0,1,0
local liConVersion = "1.01"
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Read Language File
local function setLanguage()
    local lng=system.getLocale()
    local file = io.readall("Apps/Lang/PML-LiCon.jsn")
    local obj = json.decode(file)
    if(obj) then
        trans21 = obj[lng] or obj[obj.default]
    end
end
--------------------------------------------------------------------------------

----------------------------------------------------------------------
-- Actions when settings changed
local function actSwChanged(value)
    local pSave = system.pSave
 	actSw = value
	pSave("actSw", value)
end

local function patternSwChanged(value)
    local pSave = system.pSave
 	patternSw = value
	pSave("patternSw", value)
end

local function delayPotChanged(value)
    local pSave = system.pSave
 	delayPot = value
	pSave("delayPot", value)
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Draw the main form (Application interface)
local function initForm()
    local form, addRow, addLabel = form, form.addRow ,form.addLabel
    local addIntbox, addCheckbox = form.addIntbox, form.addCheckbox
    local addSelectbox, addInputbox = form.addSelectbox, form.addInputbox
	
    addRow(2)
    addLabel({label=trans21.actSw, width=220})
    addInputbox(actSw, false, actSwChanged)
    
    addRow(2)
    addLabel({label=trans21.patternSw, width=220})
    addInputbox(patternSw, false, patternSwChanged)
    
    addRow(2)
    addLabel({label=trans21.delayPot, width=220})
    addInputbox(delayPot, true, delayPotChanged)
    
    addRow(1)
    addLabel({label="Written by Paul Lasance 2020 v" .. liConVersion, font=FONT_MINI, alignRight=true})
    collectgarbage()
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  Output light pattern to telemetry
local function printTelem(width, height)
if height == 24 then
	lcd.drawText(5,5,patternName)
	else
	lcd.drawText(5,5,patternName)
	end
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  Main Application loop
local function loop()
-- If the inputs are not set then prevent loop	
	if actSw == nil or patternSw == nil or delayPot == nil then
		system.messageBox ("Set PML-LiCon Inputs")
		return
	end
	
-- set input variables	
	switch = system.getInputsVal(actSw)
	delay = system.getInputsVal(delayPot)*1000	

-- Change the pattern from patternSw changed

	if system.getInputsVal(patternSw) == 1 and lockSw == 0 then
			pattern = pattern + 1
			lockSw = 1
		elseif system.getInputsVal(patternSw) < 1 and lockSw == 1 then
			lockSw = 0
	end
	
		if pattern > 7 then pattern = 0 end
		
print (pattern,system.getInputsVal(patternSw), lockSw,patternStep)

-- Manage timer
	sysTimer = system.getTimeCounter()
	
-- Timer loop
	if sysTimer > (lastClk + delay)  then
		-- If the actSw is on
		if switch == 1 then
			
			if pattern == 1 then -- flash without delay
					patternName = "Flash"
					if patternStep == 1 then output = 1 end
					if patternStep == 2 then output = -1 end
					if patternStep == 3 then output = 1 end
					if patternStep == 4 then output = -1 end
					if patternStep == 5 then output = 1 end
					if patternStep == 6 then output = -1 end
				elseif pattern == 2 then  -- slow flash 
					patternName = "Slow Flash"
					if patternStep == 1 then output = 1 end
					if patternStep == 2 then output = 1 end
					if patternStep == 3 then output = 1 end
					if patternStep == 4 then output = -1 end
					if patternStep == 5 then output = -1 end
					if patternStep == 6 then output = -1 end
				elseif pattern == 3 then  -- Short on double
					patternName = "Short Flash"
					if patternStep == 1 then output = 1 end
					if patternStep == 2 then output = -1 end
					if patternStep == 3 then output = -1 end
					if patternStep == 4 then output = 1 end
					if patternStep == 5 then output = -1 end
					if patternStep == 6 then output = -1 end
				elseif pattern == 4 then  -- double flash with delay
					patternName = "Double Flash"
					if patternStep == 1 then output = 1 end
					if patternStep == 2 then output = -1 end
					if patternStep == 3 then output = 1 end
					if patternStep == 4 then output = -1 end
					if patternStep == 5 then output = -1 end
					if patternStep == 6 then output = -1 end
				elseif pattern == 5 then  -- short on long off
					patternName = "Short ON Long OFF"
					if patternStep == 1 then output = 1 end
					if patternStep == 2 then output = 1 end
					if patternStep == 3 then output = -1 end
					if patternStep == 4 then output = -1 end
					if patternStep == 5 then output = -1 end
					if patternStep == 6 then output = -1 end
				elseif pattern == 6 then  -- long on short off
					patternName = "Long ON short OFF"
					if patternStep == 1 then output = 1 end
					if patternStep == 2 then output = 1 end
					if patternStep == 3 then output = 1 end
					if patternStep == 4 then output = 1 end
					if patternStep == 5 then output = -1 end
					if patternStep == 6 then output = -1 end
				elseif pattern == 7 then  -- blink
					patternName = "Blink"
					if patternStep == 1 then output = 1 end
					if patternStep == 2 then output = -1 end
					if patternStep == 3 then output = -1 end
					if patternStep == 4 then output = -1 end
					if patternStep == 5 then output = -1 end
					if patternStep == 6 then output = -1 end

				else -- On constant 
					patternName = "Always On"
					output = 1
			end		
		else
			output = -1 -- turn off the lights if actSw changed during pattern
			patternStep = 1
			patternName = "Lights Off"
		end
		
		patternStep = patternStep + 1	-- Increment the pattern step
		if patternStep > 6 then patternStep = 1 end -- reset the patternStep
		lastClk = sysTimer -- Update the last timer clock
		system.setControl(1, output,0,0)
	end
    collectgarbage()
end
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Application Initialisation
local function init()
    local pLoad, registerForm = system.pLoad, system.registerForm
	system.registerTelemetry(1,"Light Controller",0,printTelem)
	
	actSw = pLoad("actSw")
	patternSw = pLoad("patternSw")
    delayPot = pLoad("delayPot")
	ctrlIdx = system.registerControl(1, "PML-LiCon","C01")
	registerForm(1, MENU_APPS, trans21.appName, initForm)
	collectgarbage()
end
--------------------------------------------------------------------------------

setLanguage()
collectgarbage()
return {init=init, loop=loop, author="Paul Lasance", version=liConVersion, name=trans21.appName}