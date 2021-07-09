*! mac_unab - unabbreviate global macros list
*! EBooth <ebooth@tamu.edu>
*! Last Modified:  Apr 2011


program def mac_unab, rclass
		version 9.2
		gettoken user  0: 0, parse(" :") 
		gettoken colon 0: 0, parse(" :")
		if `"`colon'"' != ":"  error 198 
		
**syntax**
syntax [anything] [, Ignore(str asis)]
	loc varlist: subinstr local anything "*" " ", all
	loc mn `user'
			**clear user specified macros**
			global `mn' ""
			local  `mn' ""
			*global j  
			return local mac_list ""
****
preserve

		**log file for processing**
		cap log close _all
		tempfile zmacros
		log using "`zmacros'", text replace
		macro li 
		cap log close _all
		**log file for processing**
		
**processing of macro lists**				
foreach v in `varlist' {
		local len:length local v		
	**read in log file**	
		clear
		qui insheet using `zmacros', tab nonames
	**first 4 and last 6 lines are from log, remove those: 
			if "`c(rmsg)'" == "on" loc del 7
			if "`c(rmsg)'" == "off" loc del 6
		if `=_N' > 6 {
			qui drop in 1/5
			qui drop in `=_N-`del''/l
		}
		if `=_N' < 2 {
			di as err as smcl `"No Macros matching that pattern, see {stata macro list}"'
			exit 198
			}
	**keep if starts with unab list**
		tempvar flag
		qui g `flag' = 1 if substr(v1, 1, `len')==`"`v'"'
		if `"`ignore'"' != ""  qui replace `flag' = 1 if v1 == `"`ignore'"'
		qui drop if `flag' != 1
		qui sum `flag', meanonly
			if "`r(mean)'" != "" {
					**get names of all globals that start with `v'**
						qui split v1, p(": ")
						qui keep v11
						cap levelsof v11, loc(levels`mn') clean
					    global `mn'   $`mn'   `levels`mn'' 
					}
	} //each v in varlist loop
	global `mn': list uniq global(`mn')
		**IGNORE OPTION**
		if `"`ignore'"' != "" {
			qui token `"`ignore'"'
				while `"`1'"' != "" {
				global `mn': subinstr global `mn' "`1'" "", all
				macro shift 
					}
				} //ignore not blank loop
			if `"`ignore'"' == "SYSTEM" {
					foreach sys in MYEDITOR F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12 F13 F14 F15 F16 F17 S_ADO S_FLAVOR S_MACH S_OS S_OSDTL S_StataMP S_StataSE S_level StatTransfer_path textwrangler "textwrangler.app" "StatTransfer_path:" { 
						global `mn': subinstr global `mn' "`sys' " " ", all
						global `mn': subinstr global `mn' `"  "' `" "', all
						}
					foreach sys in MYEDITOR F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12 F13 F14 F15 F16 F17 S_ADO S_FLAVOR S_MACH S_OS S_OSDTL S_StataMP S_StataSE S_level StatTransfer_path textwrangler "textwrangler.app" "StatTransfer_path:" { 
						global `mn': subinstr global `mn' " `sys'" " ", all
						global `mn': subinstr global `mn' `"  "' `" "', all
						global `mn': subinstr global `mn' "textwrangler.app" " ", all
						}					
				}
restore
****
**	`r(mac_list)'
return local mac_list =  `"$`mn'"'
ret local `mn' "$`mn'"
global `mn' `"$`mn'"'
noi di as smcl in g `"{hline}"'
noi di as smcl in g `"Unabbreviated Macro list: "' in y `"$`mn' "' 
di as smcl in g `"{ul:Note}: Unabbreviated Macro list stored in {stata display r(mac_list): r(mac_list)} "'
noi di as smcl in g `"{hline}"'

end
** Stems from question asked on statalist by Nick Mosely: http://www.stata.com/statalist/archive/2011-02/msg00093.html
** (`r(mac_list)' stores list)
** need to add ability to use asterisks at beginning of varlist & wildcards



/*
**EXAMPLES

clear*
discard
****
global one "pocket asdf bank"
global two "bank"
global three "blah blah"
global only "end of list"
****
mac_unab mymacli1 : t* 
di "`r(mac_list)'"
di `"$mymacli1"'


mac_unab mymacli2 : on* th* 
di `"$mymacli2"'


mac_unab mymacli3 : o* S*, ignore(S_level)
di `"$mymacli3"'

tr: mac_unab mymacli4 : o* S*, ignore(SYSTEM)
di `"$mymacli4"'

	
**here are the function key mappings:
mac_unab keys: F*
	di "$keys"
	
**end example
*/


