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
	v1.00 - Initial Release
	v1.01 - Added more patterns
	v1.02 - changed patterns to a table to reduce load in loop routine
--]]

--------------------------------------------------------------------------------
-- Locals for application
local patternSw, delayPot
local lastClk = 0
local sysTimer = 0
local delay = 0
local ctrlIdx = 1
local pattern, patternStep, lockSw, delay, output = 0,1,0,0,1,0
local liConVersion = "1.02"
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Pattern Table
local patTbl={}
patTbl[0] = "Off"
patTbl[1] = -1
patTbl[2] = -1
patTbl[3] = -1
patTbl[4] = -1
patTbl[5] = -1
patTbl[6] = -1

patTbl[10] = "Always On"
patTbl[11] = 1
patTbl[12] = 1
patTbl[13] = 1
patTbl[14] = 1
patTbl[15] = 1
patTbl[16] = 1

patTbl[20] = "Flash"
patTbl[21] = 1
patTbl[22] = -1
patTbl[23] = 1
patTbl[24] = -1
patTbl[25] = 1
patTbl[26] = -1

patTbl[30] = "Slow Flash"
patTbl[31] = 1
patTbl[32] = 1
patTbl[33] = 1
patTbl[34] = -1
patTbl[35] = -1
patTbl[36] = -1

patTbl[40] = "Short Flash"
patTbl[41] = 1
patTbl[42] = -1
patTbl[43] = -1
patTbl[44] = 1
patTbl[45] = -1
patTbl[46] = -1

patTbl[50] = "Double Flash"
patTbl[51] = 1
patTbl[52] = -1
patTbl[53] = 1
patTbl[54] = -1
patTbl[55] = -1
patTbl[56] = -1

patTbl[60] = "Short On"
patTbl[61] = 1
patTbl[62] = 1
patTbl[63] = -1
patTbl[64] = -1
patTbl[65] = -1
patTbl[66] = -1

patTbl[70] = "Long On"
patTbl[71] = 1
patTbl[72] = 1
patTbl[73] = 1
patTbl[74] = 1
patTbl[75] = -1
patTbl[76] = -1

patTbl[80] = "Blink"
patTbl[81] = 1
patTbl[82] = -1
patTbl[83] = -1
patTbl[84] = -1
patTbl[85] = -1
patTbl[86] = -1

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
	-- Print telemetry
	if height == 24 then -- Small Display
		lcd.setColor(0,0,0)
		lcd.drawText(5,5,patTbl[pattern],FONT_BOLD)
		if patTbl[pattern + patternStep] == 1 then-- set colour based on output 
			lcd.setColor(0,255,0)
			else
			lcd.setColor(200,200,200)
		end
		lcd.drawImage (120,8,":rec")
	else  -- Large Display
		lcd.setColor(0,0,0)
		lcd.drawText(5,10,"Pattern",FONT_MINI)
		lcd.drawText(5,30,"Delay(ms)",FONT_MINI)
		lcd.drawText(55,5,patTbl[pattern],FONT_BOLD)
		lcd.drawText(75,25,math.floor(delay),FONT_BOLD)
		for i=1,6,1 do
			if patTbl[pattern + i] == 1 and patternStep == i then  -- set colour based on pattern
				lcd.setColor(0,255,0) 
			elseif patTbl[pattern + i] == 1 and patternStep ~= i then 
				lcd.setColor(0,120,0) 
			else 
				lcd.setColor(200,200,200) 
			end
			lcd.drawImage (i * 19,50,":rec")
		end
		lcd.setColor(0,255,0)	
		lcd.drawImage (patternStep * 19,50,":rec")
		
	end
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  Main Application loop
local function loop()
-- If the inputs are not set then prevent loop	
	if patternSw == nil or delayPot == nil then
		system.messageBox ("Set PML-LiCon Inputs")
		return
	end
	
-- set input variables	
	delay = system.getInputsVal(delayPot)*1000	

-- Change the pattern from patternSw changed
	if system.getInputsVal(patternSw) == 1 and lockSw == 0 then
			pattern = pattern + 10
			lockSw = 1
		elseif system.getInputsVal(patternSw) < 1 and lockSw == 1 then
			lockSw = 0
	end
	
		if pattern > 80 then pattern = 0 end

-- Manage timer
	sysTimer = system.getTimeCounter()
	
-- Timer loop
	if sysTimer > (lastClk + delay)  then
		output = patTbl[pattern + patternStep]	
		patternStep = patternStep + 1	-- Increment the pattern step
		if patternStep > 6 then patternStep = 1 end -- reset the patternStep
		lastClk = sysTimer -- Update the last timer clock
		system.setControl(1, output,0,0)  -- set the output 
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