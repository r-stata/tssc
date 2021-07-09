*! svcom version 1.0 \ Dennis Lund Hansen \ dlh@dadlnet.dk \ autum 2018
*! Saves output of command to log, without aditional logging noise


program define svcom 
version 10.0

if `c(userversion)' != `c(stata_version)' {
display as error `"Your current Stata version is `c(stata_version)', but you have set the version to `c(userversion)'?"'
display as error `"Command in -svcom- will be execueted as in Stata `c(userversion)'"'
display `"If this is intensionally, no action is needed."' 
display as result _n ""
}

syntax anything(everything) [,  HEADline(string) NOTEtxt(str) noCOMmand NOCOMMANDpermanent(str) noLIne NOLINEpermanent(str) DUPlicate DUPLICATEpermanent(str) *]


_on_colon_parse `anything'

if missing(`"`s(before)'"') ==1{
	capture confirm scalar sv_lognavn_dvpd
	if _rc { 	
	display as error "LOGNAME missing and not previously defined"
	exit 198
	}
}	
	
if wordcount(`"`s(before)'"')==1 {
	scalar sv_lognavn_dvpd = `"`s(before)'"'
}


if wordcount(`"`s(before)'"')>1 {
	display as error `"Seperator (:) missing or misplaced"'
	exit  198
}

	
	
*control and error messages:
if missing(`"`s(after)'"')==1 {
	display as error "Command is missing"
	exit 198
}


local commands = `"`s(after)'"'




* store information about permanent settings

* set command off or on permanent
capture confirm scalar scalar_nocommand_permanent 
if _rc!=0{
	scalar scalar_nocommand_permanent = .
}

if `"`nocommandpermanent'"'==`"on"' {
scalar scalar_nocommand_permanent = 1
display as result `"Nocommand permanent on"'
}
 if `"`nocommandpermanent'"'==`"off"' {
scalar scalar_nocommand_permanent = 0
display as result `"Permament nocommand is off - interactive mode"'
} 


* set noline off or on permanent
capture confirm scalar scalar_noline_permanent 
if _rc!=0{
	scalar scalar_noline_permanent = .
}

if `"`nolinepermanent'"'==`"on"' {
scalar scalar_noline_permanent = 1
display as result "Noline permanent on"
}
 if `"`nolinepermanent'"'==`"off"' {
scalar scalar_noline_permanent = 0
display as result "Permament noline is off - interactive mode"
} 


* set duplicate on or off permanent
capture confirm scalar scalar_duplicate_permanent 
if _rc!=0{
	scalar scalar_duplicate_permanent = .
}

if `"`duplicatepermanent'"'==`"on"' {
scalar scalar_duplicate_permanent = 1
display as result `"duplicate permanent on"'
}
 if `"`duplicatepermanent'"'==`"off"' {
scalar scalar_duplicate_permanent = 0
display as result `"Permament duplicate is off - interactive mode"'
} 




*place duplicat outside "quiet-area":
if (`"`duplicate'"'==`"duplicate"' | `=scalar_duplicate_permanent'==1) {
	if `"`options'"'==`""' {
	noisily display as smcl _n`"{cmd:`commands'}"'
	version `c(userversion)'
	noisily  `commands'
	version 9
	}

	if `"`options'"'!=`""' {
	noisily display as smcl _n`"{cmd:`commands', `options'}"'
	version `c(userversion)'
	noisily  `commands', `options'
	version 9
	}
}

	quietly{
	log on `=scalar(sv_lognavn_dvpd)'
* forming output inside quiet-area:

* setting hline and headline:
	if (`"`line'"'==`""' & `=scalar_noline_permanent'!=1) {
		noisily display in smcl `"{hline 25}"' 
	}
	noisily display in smcl _n
	if (`"`headline'"'==`""') {
		if (`"`command'"'==`""' & `=scalar_nocommand_permanent' != 1) {
			if `"`options'"'==`""'{
				noisily display as text in smcl `"{ul on}Inputcommand:  `commands' {ul off}"' _n  
			}
			else {
				noisily display as text in smcl `"{ul on}`commands', `options'  {ul off}"' _n 
			}
		}
	}
	if (`"`headline'"'!="") {	
		if (`"`command'"'=="" & `=scalar_nocommand_permanent' != 1) {
			if `"`options'"'==`""'{
				noisily display as text in smcl `"{ul on}Inputcommand:  `commands' {bf} - `headline'  {ul off}"' _n  
			}
			else {
				noisily display as text in smcl `"{ul on}`commands', `options' {bf} - `headline'  {ul off}"' _n 
			}
		}
		if (`"`command'"'==`"nocommand"' | `=scalar_nocommand_permanent' == 1) {
		noisily display as text in smcl `"{ul on}{bf}`headline'{ul off}"' _n 
		}
	}
* executing command:
	if `"`options'"'==`""' {
		version `c(userversion)'
		noisily  `commands'
		version 9
	}
	if `"`options'"'!=`""' {
		version `c(userversion)'
		noisily  `commands', `options'
		version 9
	}

* setting notetext and hline:
	noisily display as text in smcl _n `"`notetxt'"'
	if ("`line'"=="" & `=scalar_noline_permanent'!=1){
		noisily display in smcl "{hline 25}" 
	}
	noisily display in smcl _n
	log off `=scalar(sv_lognavn_dvpd)'
	}

end
