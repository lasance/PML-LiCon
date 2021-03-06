# PML-LiCon
A LUA app for JETI transmitters which allows an on/off RX switch to flash lights


PML-LiCon.lua

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

To setup the app on your JETI Transmitter
-----------------------------------------
copy the PML-LiCon.la (or .lua) file to the Apps folder via  a USB lead
copy the PML-LiCon.jsn file to the Apps\Lang folder via  a USB lead

Go to [applications] [User Applications] and click [+] and add the application PML-LiCon

you will get a message on the top of your TX saying you need to "Set PML-LiCon Inputs", this is because you need to set up the inputs

Click the jog wheel to run the application and set your 
Pattern Switch (change the pattern) ideally to a non-latching switch
Delay Pot to a Knob or slider - set the input to be proportional and non-centered (i.e. 0-100%)

Go to [Model] [Functions Assignment] [+] 
Give your function a name like "Lights"
Select Input Control by pressing [+] [User Applications] [C01]
 
Go to [Model] [Servo Assignment]
Select the Channel you want to control - MAKE SURE YOU DO NOT PICK A CHANNEL WHICH CONTROLS THE Model

Goto [Timers/Sensors] [Displayed Telemetry] [Add]
Select Option [Lua] [Light COntroller] Use either Single or Double size [YES]


Using the App
-------------
To use the app the pattern switch changes the lights pattern, when you turn off the Tx it will return to the default pattern
The Pattern switch will change the Pattern which changes at a speed stermined by the Delay Pot.

Patterns
--------
There are 9 Patterns

  1  2  3  4  5  6 (step)  
0 0  0  0  0  0  0  Off (Default)
1 1  0  1  0  1  0  Flash
2 1  1  1  0  0  0  Slow Flash
3 1  0  0  1  0  0  Short Flash
4 1  0  1  0  0  0  Double Flash
5 1  1  0  0  0  0  Short On Long Off
6 1  1  1  1  0  0  Long ON short OFF
7 1  0  0  0  0  0  Blink
8 1  1  1  1  1  1  Always On

