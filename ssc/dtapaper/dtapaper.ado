*!   VERSION: 1.00  02/12/2015 
*!   AUTHOR: Christoph Thewes - thewes@uni-potsdam.de

*!	 CHANGELOG:
*!   1.0.0: 02/12/2015: Initial release 

program dtapaper
version 13.0
syntax [,vars values numeric]

	* ---------------	
	* INITIAL PROGRAM
	* ---------------

	capture confirm variable *	// check if data has any variables 
		if _rc == 111 {
			noi di as err "No variables in data."
			}
		
		else {
			foreach x in dp_cb_var dp_cb_lab dp_cb_note dp_cb_n dp_cb_nvar dp_cb_name {
				if "$`x'" == "" global `x' 1
			}

			foreach x in dp_cb_val dp_cb_save dp_cb_n_drop {
				if "$`x'" == "" global `x' 0
			}

			if "`vars'" == "" db dtapaper
		}


	* -------------------------------------------	
	* SUB-PROGRAM for var-labels and value labels
	* called inside dtapaper.dlg
	* -------------------------------------------
	
	if "`vars'" == "vars" {
			quietly {
				file write data "{smcl}"_n(2) ///
				  "{title:Variable List:}" _n(2) ///
				  "{synoptset 32}{...}" _n
				if "`values'" == "" file write data "{p2col:Name}Label{p_end}" _n "{synoptline}"_n
				else if "`values'" == "values" file write data "{p2col:Name}Label [Value Labels]{p_end}" _n "{synoptline}"_n
		
				foreach var of varlist * {
					local labelstring ""									// clean old locals
					local marker ""
					local count = 0
					
					local label : variable label `var'							// get variable label
					
					if "`values'" == "values" {
						capture label list `var'							// check if variable has value labels
							if !_rc {
							qui: label list `var'
							local labdif = `r(max)' - `r(min)'
							if `labdif' < 30 {							// only variables with a low range (30) between min. and max. value
								qui: levelsof `var', local(L)
								
								foreach l of local L {
									if `count' <= 10 {
										local value : label `var' `l', strict		// get value labels 
										
										if "`value'" != "" {
											if `count'==0 local labelstring `labelstring' `value'		// combine to single string (first value)
											if `count'>0 local labelstring `labelstring' / `value'		// combine to single string (following values with sperator "/")
											local count = `count' + 1
										}
									}
									
									if `count' == 11  {					// check after 10 value labels if more exists. If yes, set marker
										local l = `l' + 1
										local value : label `var' `l', strict			
		 
										if "`value'" != "" {
											local marker "dots"
										}
									}
								}
							}
						}
					}
		
					if "`labelstring'" == "" {								// only print `value' if value label exist
						file write data "{synopt :`var'}`label'{p_end}"_n
					}
					else {
						if "`marker'" == "dots" {							// mark that not all value labels ars displayed (max 10)
							file write data "{synopt :`var'}`label' [`labelstring' / ...]{p_end}"_n
						}
						else {
							file write data "{synopt :`var'}`label' [`labelstring']{p_end}"_n
						}
					}
				}
				
				file write data "{synoptline}" _n "{p2colreset}{...}" _n
				
			}
		}
		
		
end


exit
