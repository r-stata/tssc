/*	
	'GETDATA': module to import data
	Author: Duarte Goncalves (duarte.goncalves.dg@outlook.com)
	Last update: 24 March 2016
	Version 1.22
	
	This program uses the SDMX Connector for STATA, licensed to Banca d'Italia (Bank of Italy) under a European Union Public Licence
	(world-wide, royalty-free, non-exclusive, sub-licensable licence). 
	See https://github.com/amattioc/SDMX/wiki/SDMX-Connector-for-STATA and
	https://joinup.ec.europa.eu/sites/default/files/eupl1.1.-licence-en_0.pdf
	
	
	I dearly thank Attilio Mattiocco (Attilio.Mattiocco@bancaditalia.it) for all the help regarding the SDMX Connector for STATA
	and Bo Werth (Bo.WERTH@oecd.org) for additional clarifications.
*/







cap program drop getdataconfig
program define getdataconfig
quietly {
local SDMX_CONF_PATH = subinstr("`c(sysdir_plus)'jar\configuration.properties","/","\",.)
if "`c(os)'" == "MacOSX" | "`c(os)'" == "Unix" {
cap ! export SDMX_CONF="`SDMX_CONF_PATH'"
}
if "`c(os)'" == "Unix" {
cap ! setenv SDMX_CONF "`SDMX_CONF_PATH'"
}
if "`c(os)'" == "Windows" {
cap ! cmd /c setx SDMX_CONF "`SDMX_CONF_PATH'"
}
}
end
