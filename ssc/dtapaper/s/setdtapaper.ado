*!   VERSION: 1.00  02/12/2015 
*!   AUTHOR: Christoph Thewes - thewes@uni-potsdam.de

*!	 CHANGELOG:
*!   1.0.0: 02/12/2015: Initial release 

program setdtapaper

version 13.0
	
	syntax , [Title(string) ABstract(string) Keywords(string) Source(string) ACcess(string) From(numlist) To(numlist) AUthor(string) Institution(string) Contact(string) Path(string) cb_var(numlist) cb_val(numlist) cb_lab(numlist) cb_note(numlist) cb_save(numlist) cb_drop(numlist) cb_n(numlist) cb_nvar(numlist) cb_name(numlist) clear]

local emptycount = 0


// Create global macros
// --------------------
foreach option in title abstract keywords source access from to author institution contact path cb_var cb_val cb_lab cb_note cb_drop cb_save cb_n cb_nvar cb_name {
	if "``option''"!="" global dp_`option' "``option''"
	if "``option''"=="" local emptycount = `emptycount' + 1
}


// Error if options AND clear are defined
// --------------------------------------
if `emptycount' != 20 & "`clear'" == "clear"{
	di _n as err "Option 'clear' would delete all defined macros. 'clear' is ignored."
}


// Clear out all macros
// --------------------
if "`clear'" == "clear" & `emptycount' == 20 {
	foreach option in title abstract keywords source access from to author institution contact path {
		global dp_`option' ""
	}
}

di _n as res "To see changes in " as text "DTAPAPER" as res " you may use the reset-button in the lower left corner of the DTAPAPER dialog."


// Error if no option defined
// --------------------------
if `emptycount' == 20 & "`clear'" != "clear"{
	di _n as err "Options are missing. No global macros defined."
}

// Checks
// ------
if $dp_cb_var==0 & $dp_cb_val==1 {
	di as err "Value-labels can't be activated if variable-list is deactivated. Value-labels are deactivated."
	global dp_cb_val 0
}

end
exit

