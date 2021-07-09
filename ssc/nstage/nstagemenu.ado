*! version 1.0.5 10Aug2017

program define nstagemenu
version 10.0
if "`1'"!="off" & "`1'"!="on" {
	di in red "invalid syntax, enter nstagemenu on or nstagemenu off"
	exit 198
}
if "`1'"=="off" {
	window menu clear
	global S_NSTAGEMENU
	di as txt "{hline 60}" _n "The menubar has been changed." _n ///
	 "NOTE THAT ALL ADDITIONS TO THE USER MENU HAVE BEEN CLEARED." _n "{hline 60}"
	exit
}
if "$S_NSTAGEMENU"=="on" {
	di as txt "n-stage trial design menu already on.  Type nstagemenu off to turn off." 
	exit
}
global S_NSTAGEMENU "on"
window menu append submenu "stUser" "n-stage trial"
window menu append item "n-stage trial" "Multi stage trial designs" "db nstage"
window menu refresh
di as txt _n "nstage version 4.0.1, September 2019." _n
di as txt "Software written at the MRC Clinical Trials Unit at UCL, London."
di as txt "{hline 64}" _n "n-stage trial design menu on.  The menubar has been changed." _n "{hline 64}" 
end
