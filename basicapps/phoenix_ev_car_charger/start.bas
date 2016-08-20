' This script is an example of the EMDO101 energy manager
' Please visit us at www.swissembedded.com
' Copyright (c) 2015-2016 swissEmbedded GmbH, All rights reserved.
' Phoenix EV electric car charger with excess energy over modbus TCP and RTU
' Testet with Wallb-e Pro
SYS.Set "rs485", "baud=9600 data=8 stop=1 parity=n"
kW=0.0
slv%=180
if$="TCP:192.168.0.114:502"
start:
 PhoenixEV(if$,slv%,kW,st%)
 print "Phoenix " st% T
 pause 30000
 goto start
 
' Phoenix EV electric car charger controller
' This function must be called at least every 60 seconds,
' if$ modbus interface (see EMDO modbus library for details)
' slv% slave address of charger (default 180)
' kW home energy at energy meter neg. value = excess energy
' st% device status
FUNC PhoenixEV(if$,slv%,kW,st%)
 ' Read EV Status
 err%= mbFuncRead(if$,slv%,3,&H100,8,reG$,500) OR mbFuncRead(if$,slv%,2,&H200,8,reD$,500) OR mbFuncRead(if$,slv%,3,&H300,2,reC$,500) OR mbFuncRead(if$,slv%,1,&H400,16,reR$,500)
 if err% then
  print "EV error on read"
  exit func
 end if
 ' Status 
 eS$=mid$(reG$,2,1)
 ' Proximity charge current in A
 eP%=conv("bbe/i16",mid$(reG$,3,2))
 ' Charging time in s
 eT%=conv("bbe/i32",mid$(reG$,5,4))
 ' Firmware version e.g. 430 = 4.30
 eV%=conv("bbe/i32",mid$(reG$,11,4))
 ' Error code
 eE%=conv("bbe/i16",mid$(reG$,15,2))
 ' Discrete inputs 
 ' Enable, External Release, Lock Detection, Manual Lock, Charger Ready, Locking Request, Vehicle Ready, Error
 eD%=asc(left$(reD$,1)
 ' Charge current
 eC%=conv("bbe/i16",left$(reC$,2))
 ' Charge control register 
 ' Enable charge process, reuqest digital communication, manual charging available, manual locking
 ' Activate overcurrent shutdown
 ' "Voltage status A/B detected" - function activated
 ' "Status D, reject vehicle" function activated
 ' Reset charging controller
 ' Voltage in status A/B detected
 ' Status D, reject vehilce
 ' Configuration of input ML
 eR%=conv("bbe/i16",left$(reR$,2))
 enD%=eD% and 1 ' Enable
 xrD%=eD% and 2 ' External release
 ldD%=eD% and 4 ' Lock detection
 mlD%=eD% and 8 ' Manual lock
 crD%=eD% and 16 ' Charger Ready
 lrD%=eD% and 32 ' Locking Request
 vrD%=eD% and 64 ' Vehicle Ready
 erD%=eD% and 128 ' Error
 enR%=eR% and 1 ' Enable charge process
 rdcR%=eR% and 2 ' Request digital communication
 csaR%=eR% and 4 ' Charging station available
 mlR%=eR% and 8 ' Manual locking
 aosR%=eR% and 512 ' Activate overcurrent shutdown
 ' Request charging
 
 select case eS$
  case "A"
   ' Charger is not connected to car
  case "B"
   ' Charger is connected to car
   ' or charging ended
  case "C"
   ' Charging without ventilation
  case "E"
   ' Charging with ventilation
  case "F"
   ' Missing proximity plug
   ' Or car stops charging
  case else  
   ' Unknown status
 end select
END FUNC
 