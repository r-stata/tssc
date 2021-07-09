*! version 1.1.1 13jul2018 daniel klein
program trackobs
    version 11.2
	
	if (replay()) {
	    gettoken 0 zero : 0 , parse(":")
		syntax [ , RETURN ]
		local 0 : copy local zero 
	}
	
	gettoken subcmd zero : 0 , parse(" :,")
	if (inlist(`"`subcmd'"', "set", "clear", "saving", "report")) {
	    trackobs_`subcmd' `zero'
		exit
	}
	else if (`"`subcmd'"' == ":") local 0 `zero'
	
	local I : char _dta[trackobs_counter]
	trackobs_assert_counter , counter(`I')
		
	nobreak {
	    forvalues i = 1/`I' {
			local trackobs_`i' : char _dta[trackobs_`i']
		}
		local N_was = c(N)
	    capture noisily break `0'
		local rc = _rc
		local N_now = c(N)
		forvalues i = 1/`I' {
		    char _dta[trackobs_`i'] `: copy local trackobs_`i''
		}
		if (((!`rc') | (`N_was' != `N_now')) & (!mi(`"`0'"'))) {
		    local ++I
		    char _dta[trackobs_`I']     `N_was' `N_now' `0'
		    char _dta[trackobs_counter]                 `I'
		}
		if ("`return'" != "") trackobs_return
	}
	exit `rc'
end

program trackobs_set
    version 11.2
	
	syntax [ , CLEAR ]
	
	if ("`clear'" != "") capture trackobs_clear
	
	if (`"`: char _dta[trackobs_counter]'"' != "") {
	    display as err "trackobs counter already set"
		exit 498
	}
	else char _dta[trackobs_counter] 0
end

program trackobs_clear
    version 11.2
	
	syntax // nothing allowed
	
	local I : char _dta[trackobs_counter]
	trackobs_assert_counter , counter(`I')
	
	nobreak {
	    forvalues i = 1/`I' {
		    char _dta[trackobs_`i'] // void
		}
		char _dta[trackobs_counter] // void
	}
end

program trackobs_saving
    version 11.2
	
	local 0 using `0'
	syntax using/ [ , REPLACE ]
	
	local I : char _dta[trackobs_counter]
	trackobs_assert_counter , counter(`I')
	
	forvalues i = 1/`I' {
	    local trackobs_`i' : char _dta[trackobs_`i']
	}
	
	preserve
	clear
	quietly {
	    set obs `I'
		generate cmdline      = ""
		char cmdline[varname] Command
		generate long N_was   = .z
		char N_was[varname]   Obs. was
		generate long N_now   = .z
		char N_now[varname]   Obs. now
		forvalues i = 1/`I' {
			gettoken N_was trackobs_`i' : trackobs_`i'
			gettoken N_now trackobs_`i' : trackobs_`i'
			local    cmdline             `trackobs_`i''
			replace  N_was   = `N_was'          in `i'
			replace  N_now   = `N_now'          in `i'
		    replace  cmdline = `"`cmdline'"'    in `i'
		}
		char _dta[trackobs] trackobs
		save `"`using'"' , `replace'
	}
	restore
end

program trackobs_report
    version 11.2
	
	syntax [ using/ ]
	
	if (mi(`"`using'"')) {
	    tempfile using
		trackobs_saving `"`using'"'
	}
	
	preserve
	quietly use `"`using'"' , clear
	if (`"`: char _dta[trackobs]'"' != "trackobs") {
	    display as err "file not created by trackobs"
		exit 698
	}
	else list , noobs nodotz subvarname
	restore
end

program trackobs_return , rclass
    version 11.2
	
	local I : char _dta[trackobs_counter]
	if (!`I') exit
	else local trackobs_`I' : char _dta[trackobs_`I']
	
	gettoken N_was trackobs_`I' : trackobs_`I'
	gettoken N_now trackobs_`I' : trackobs_`I'
	
	return scalar N_now   = `N_now'
	return scalar N_was   = `N_was'
	return local  cmdline   `trackobs_`I''
end

program trackobs_assert_counter
    version 11.2
	capture syntax , COUNTER(numlist integer max=1 >=0)
	if (_rc) {
	    display as err "trackobs counter not set"
		exit 499
	}
end
exit

1.1.1 13jul2018 minor code polish
1.1.0 13jul2018 new colon syntax for prefix
                new option clear
				new option return
				new subcommand -saving-
				new reporting routine
                preserve characteristics accross datasets
1.0.0 11jul2018 posted on Statalist
