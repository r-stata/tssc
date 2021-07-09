
*! version 2.00
*

capture program drop _welcom_inst
program define _welcom_inst

set more off
net from http://dasp.ecn.ulaval.ca/welcom/Installer
net install welcom, force
cap addITMenu profile.do _welcom_menu


end


