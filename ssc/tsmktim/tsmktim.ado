*! version 1.2.1  25jun2004  cfb
*  1.1.2: CFBaum/VWiggins 9812     STB-57: dm81
*  1.2.0: revised to allow use in panel with I()
*  1.2.1: correct sequence option to make compatible with v7,8
*         and no longer compatible with v6

	prog def tsmktim
	version 7.0

	 syntax newvarname, Start(str) [  SEQuence(varname)  I(str)  ]

	 local offset 1

	 if "`i'" ~= "" {
	 	local pv "bys `i' : "
 	 }
	 if "`sequence'" == "" {
		 local sequence _n
		 local offset 1
	 }
	 else {
		 if `sequence'[1] != . {
		 local offset = `sequence'[1] 
	 	}
	 }

	 qui gen `varlist' = .
	 	if real("`start'") !=.  {
	 	qui `pv' replace `varlist' = y(`start')+`sequence'-`offset'
	 	format `varlist' %ty
	 	}
	 	else if length("`start'") > 7 {
	 	qui `pv' replace `varlist' = d(`start')+`sequence'-`offset'
		 	format `varlist' %td
	 	}
		else {
			local period = lower(substr("`start'", 5, 1))

		 	if !index("hqmw", "`period'") {
	  			di in red "tsmktim cannot use start=`start'."
				di in red "Start dates must contain q,m,w,h or a 3-letter month"
			 	di in red	"abbreviation unless data are annual. Years must have 4 digits."
			 	exit 198
		 	}
	 		 	qui `pv' replace `varlist' = `period'(`start')+`sequence'-`offset'
		 	format `varlist' %t`period'
	 	}	
	 	tsset `i' `varlist'

end

