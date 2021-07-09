*! version 1.0.9 SB/PR 23dec2014.
program define artmenu
version 9
if "`1'"!="off" & "`1'"!="on" {
	di as err "Invalid syntax, enter artmenu on or artmenu off"
	exit 198
}
if "`1'"=="off" {
	window menu clear
	global S_artmenu
	di as txt "{hline 60}" _n "The menubar has been changed." _n ///
	 "NOTE THAT ALL ADDITIONS TO THE USER MENU HAVE BEEN CLEARED." _n "{hline 60}"
	exit
}
if "$S_artmenu"=="on" {
	di as text "ART menu already on.  Type {hi:artmenu off} to turn off." 
	exit
}
local version version 1.0.9, 23 December 2014
global S_artmenu "on"
window menu append submenu "stUser" "ART"
window menu append item "ART" "Survival outcomes" "db artsurv"
window menu append item "ART" "Binary outcomes" "db artbin"
window menu append item "ART" "Artpep" "db artpep"
window menu refresh
local maxwidth 78
local skip=`maxwidth'-length("ART - ANALYSIS OF RESOURCES FOR TRIALS")-length("(`version')")
di as text _n "{hi:ART} - {hi:A}NALYSIS OF {hi:R}ESOURCES FOR {hi:T}RIALS" /*
 */ _skip(`skip') "(`version')" _n "{hline `maxwidth'}"
display as text "A sample size program by Patrick Royston, Abdel Babiker & Friederike Barthel,"
display as text "MRC Clinical Trials Unit at UCL, London WC2B 6NH, UK." _n "{hline `maxwidth'}"
display as text _n "ART menu turned on. The {hi:User} menu has been changed."
display as text _n "Click on {help artwhatsnew} for news on recent changes to ART."
end


