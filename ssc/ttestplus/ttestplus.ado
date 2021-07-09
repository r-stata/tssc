program define ttestplus
version 11.0

syntax varlist [if] [in], by(varlist) [cut(string)] [CLuster(varname)] [t] [se]

* Initialize tempvars for by and cluster

	tempname btemp cltemp

* Quit if bad syntax for cut

	if "`cut'"!="mean" & "`cut'"!="median" & !regexm("`cut'", "[0-9]+") & "`cut'"!="" {
		di in red "Specify cut(value), cut(mean), or cut(median) only"
		exit 198
		}
		
* Convert cut to numerical if appropriate

	if regexm("`cut'", "[0-9]+") {
		local cutpoint = `cut'
		}
		
* Prep clustering locals

	if "`cluster'"!="" {
		cap ssc install cltest
		cap ssc adoupdate cltest, update
		local cl    = "cl"
		local clust = `"cluster(`cltemp')"'
		local se1   = "r(se_1)"
		local se2   = "r(se_2)"
		}
	else {
		local se1   = "[r(sd_1)/sqrt(r(N_1))]"
		local se2   = "[r(sd_2)/sqrt(r(N_2))]"
		}
		
* Prep varlist & bylist

	tokenize      `by'
	local byfirst `1'
	macro shift
	local byrest  `*'

	tokenize      `varlist'
	local first   `1'
	macro shift
	local rest    `*'
	
	* Quit if bad by/varlist combo
	
		if "`first'"!="`varlist'" & "`byfirst'"!="`by'" {
			di in red "Multiple by-variables cannot be combined with multiple analysis dimensions"
			exit 198
			}
			
		if "`cut'"!="" & "`byfirst'"!="`by'" {
			di in red "Multiple by-variables cannot be combined with cut"
			exit 198
			}
			
	* Prep varlist macro
	
		if "`byfirst'"=="`by'" {
			local byvar    = "byfirst"
			local testvar  = "var"
			local firstvar = "first"
			}
		else {
			local byvar    = "var"
			local byon     = "by"
			local testvar  = "first"
			local firstvar = "byfirst"
			}

* Cut groupvar if specified

	if "`cut'"=="mean" | "`cut'"=="median" | regexm("`cut'", "[0-9]+") {
		
		qui sum `by', d
		
		if "`cut'"=="median" {
			local cutpoint = `r(p50)'
			}
			
		if "`cut'"=="mean" {
			local cutpoint = `r(mean)'
			}
			
		local cutmin      = `r(min)' - 1
		local cutmax      = `r(max)' + 1
		qui egen `btemp'  = cut(`by'), at(`cutmin',`cutpoint',`cutmax')
		local bytemp      = "`by'"
		local by          = "`btemp'"
		local byfirst     = "`btemp'"
		}

* Initialize results matrix
	
	mat stat = J(1,1,.)
	
* Run t-tests and add to results matrix

	* Run t-tests
	
		if "`cluster'"!="" {
			cap drop `cltemp'
			qui egen `cltemp' = group(`byfirst' `cluster')
			}			
		
		qui `cl'ttest `first' `if' `in', by(`byfirst') `clust'
		
			if "`t'"=="t" { 
				local stat = "r(t)"
				}
			else { 
				mat stat[1,1] = min( r(p_u), r(p_l), r(p) )
				local stat    = "stat"
				}
			
			mat b1               = r(mu_1),r(mu_2),`stat'
			mat results          = b1
			mat rownames results = "``firstvar''" 
			
			if "`se'"=="se" {
				mat se1         = `se1'
				mat se2         = `se2'
				mat b2          = se1,se2,[.]
				mat rownames b2 = "SE"
				mat results     = results\b2
				}
	
	if "``byon'rest'"!="" {
		foreach var of varlist ``byon'rest' {
		
		* Run t-test
			
			if "`cluster'"!="" {
			cap drop `cltemp'
			qui egen `cltemp' = group(``byvar'' `cluster')
			}

			qui `cl'ttest ``testvar'' `if' `in', by(``byvar'') `clust'
			
			if "`t'"=="t" { 
				local stat = "r(t)"
				}
			else { 
				mat stat[1,1] = min( r(p_u), r(p_l), r(p) )
				local stat    = "stat"
				}
			
			mat b1               = r(mu_1),r(mu_2),`stat'
			mat rownames b1      = "`var'"
			mat results          = results\b1
						
			if "`se'"=="se" {
				mat se1         = `se1'
				mat se2         = `se2'
				mat b2          = se1,se2,[.]
				mat rownames b2 = "SE"
				mat results     = results\b2
				}
			}
		}
		
* Output

	if "`t'"=="t" { 
		mat colnames results = "Group 1" "Group 2" "t-Stat"
		}
	else { 
		mat colnames results = "Group 1" "Group 2" "p-Stat"
		}
	
	di " "
	if "`cut'"!="" {
		if regexm("`cut'", "[0-9]+") {
			local cut = "specified"
			}
		di "`bytemp' cut at `cutpoint' (`cut')"
		}
	if "`cluster'"!="" {
		di "Standard errors clustered by `cluster'"
		}
		
	matlist results
	
end
