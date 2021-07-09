*! version 1.0.0  	<sept2018>
/*=======================================================
Program Name: povcalnet.ado
Author:		  
R.Andres Castaneda Aguilar
Jorge Soler Lopez
Espen Beer Prydz	
Christoph Lakner	
Ruoxuan Wu				
Qinghua Zhao			
World Bank Group	

project:	  Stata package to easily query the [PovcalNet API](http://iresearch.worldbank.org/PovcalNet/docs/PovcalNet%20API.pdf) 
Dependencies: The World Bank - DEC
-----------------------------------------------------------------------
Creation Date: 		  Sept 2018
References:	
Output:		dta file
=======================================================*/


program def povcalnet, rclass

set checksum off //temporarily bypasses control of files taken from internet

version 11.0

syntax [anything(name=subcommand)]    ///
[,                             ///
COUNtry(string)              /// 
REGion(string)               ///
YEAR(string)                 /// 
POVline(numlist)             /// 
PPP(numlist)                 /// 
AGGregate                    ///
CLEAR                        ///
INFOrmation                  ///
coverage(string)             ///
ISO                          /// Standard ISO codes
SERVER(string)               /// internal use
pause                        /// debugging
FILLgaps                     ///
N2disp(integer 15)           ///
noDIPSQuery                  ///
querytimes(integer 5)        ///
] 

if ("`pause'" == "pause") pause on
else                      pause off

qui {
	
	// ------------------------------------------------------------------------
	// New session procedure
	// ------------------------------------------------------------------------
	
	if ("${pcn_cmds_ssc}" == "") {
		
		// ---------------------------------------------------------------
		// Update PovcalNet 
		// ---------------------------------------------------------------
		
		mata: povcalnet_source("povcalnet") // creates local src
		
		* If povcalnet was installed from github
		if (regexm("`src'", "github")) {
			local git_cmds povcalnet github
			
			foreach cmd of local git_cmds {
				
				* Check repository of files 
				mata: povcalnet_source("`cmd'")
				
				if regexm("`src'", "\.io/") {  // if site
					if regexm("`src'", "://([^ ]+)\.github") {
						local repo = regexs(1) + "/`cmd'"
					}
				}
				else {  // if branch
					if regexm("`src'", "\.com/([^ ]+)(/`cmd')") {
						local repo = regexs(1) + regexs(2) 
					}
				}
						
				qui github query `repo'
				local latestversion = "`r(latestversion)'"
				
				qui github version `cmd'
				local crrtversion =  "`r(version)'"

				* force installation 
				if ("`crrtversion'" == "") {
					github install `repo', replace
					cap window stopbox note "github command has been reinstalled to " ///
					"keep record of new updates. Please type discard and retry."
					global pcn_cmds_ssc = ""
					exit 
				}

				if ("`latestversion'" != "`crrtversion'") {
					cap window stopbox rusure "There is a new version of `cmd' in Github (`latestversion')." ///
					"Would you like to install it now?"
					
					if (_rc == 0) {
						cap github update `cmd'
						if (_rc == 0) {
							cap window stopbox note "Installation complete. please type" ///
							"discard in your command window to finish"
							local bye "exit"
						}
						else {
							noi disp as err "there was an error in the installation. " _n ///
							"please run the following to retry, " _n(2) ///
							"{stata github update `cmd'}"
							local bye "error"
						}
					}	
					else local bye ""
					
				}  // end of checking github update
				
				else {
					noi disp as result "Github version of {cmd:`cmd'} is up to date."
					local bye ""
				}
				
			} // end of loop
			
		} // end if installed from github 
		
		else if (regexm("`src'", "repec")) {  // if povcalnet was installed from SSC
			qui adoupdate povcalnet, ssconly
			if ("`r(pkglist)'" == "povcalnet") {
				cap window stopbox rusure "There is a new version of povcalnet in SSC." ///
				"Would you like to install it now?"
				
				if (_rc == 0) {
					cap ado update povcalnet, ssconly update
					if (_rc == 0) {
						cap window stopbox note "Installation complete. please type" ///
						"discard in your command window to finish"
						local bye "exit"
					}
					else {
						noi disp as err "there was an error in the installation. " _n ///
						"please run the following to retry, " _n(2) ///
						"{stata ado update povcalnet, ssconly update}"
						local bye "error"
					}
				}
				else local bye ""
			}  // end of checking SSC update
			else {
				noi disp as result "SSC version of {cmd:povcalnet} is up to date."
				local bye ""
			}
		}  // Finish checking povclanet update 
		else {
			noi disp as result "Source of {cmd:povcalnet} package not found." _n ///
			"You won't be able to benefit from latest updates."
			local bye ""
		}
		
		/*==================================================
		Dependencies         
		==================================================*/
		*---------- check SSC commands
		
		local ssc_cmds missings 
		
		noi disp in y "Note: " in w "{cmd:povcalnet} requires the packages " ///
		"below from SSC: " _n in g "`ssc_cmds'"
		
		foreach cmd of local ssc_cmds {
			capture which `cmd'
			if (_rc != 0) {
				ssc install `cmd'
				noi disp in g "{cmd:`cmd'} " in w _col(15) "installed"
			}
		}
		
		adoupdate `ssc_cmds', ssconly
		if ("`r(pkglist)'" != "") adoupdate `r(pkglist)', update ssconly
		
		global pcn_cmds_ssc = 1  // make sure it does not execute again per session
		`bye'
	}
	
	
	/*==================================================
	Defaults           
	==================================================*/
	
	*---------- API defaults
	
	if "`server'"!=""  {
		if ("`server'" == "int") local server "http://wbgmsrech001"
		local base="`server'/PovcalNet/PovcalNetAPI.ashx"
	} 
	else {
		local serveri    = "http://iresearch.worldbank.org"
		local site_name = "PovcalNet"
		local handler   = "PovcalNetAPI.ashx"		
		local base      = "`serveri'/`site_name'/`handler'"
	}
	
	return local server    = "`serveri'`server'"
	return local site_name = "`site_name'"
	
	*---------- lower case subcommand
	local subcommand = lower("`subcommand'")
	
	*---------- Test
	if ("`subcommand'" == "test") {
		if ("${pcn_query}" == "") {
			noi di as err "global pcn_query does not exist. You cannot test the query."
			error
		}
		local fq = "`base'?${pcn_query}"
		view browse "`fq'"
		exit
	}
	
	*---------- Modify country(all) with aggregate
	if (lower("`country'") == "all" & "`aggregate'" != "") {
		local country ""
		local aggregate ""
		local subcommand "wb"
		local wb_change 1
		noi disp as err "Warning: " as text " {cmd:povclanet, country(all) aggregate} " /* 
	  */	"is equivalent to {cmd:povcalnet wb}. " _n /* 
	  */ " if you want to aggregate all countries by survey years, " /* 
	  */ "you need to parse the list of countries in {it:country()} option. See " /*
	  */  "{help povcalnet##options:aggregate option description} for an example on how to do it"
	}
	else {
		local wb_change 0
	}
	
	if ("`year'" == "") local year "all"
	* 
	
	*---------- Coverage
	if ("`coverage'" == "") local coverage = "all"
	local coverage = lower("`coverage'")
	
	foreach c of local coverage {	
		if !inlist(lower("`c'"), "national", "rural", "urban", "all") {
			noi disp in red `"option {it:coverage()} must be "national", "rural",  "urban" or "all" "'
			error
		}
	}
	
	*---------- Poverty line
	if ("`povline'" == "") local povline = 1.9
	
	*---------- Info
	if regexm("`subcommand'", "^info")	{
		local information = "information"
		local subcommand  = "information"
	}
	
	*---------- Subcommand consistency 
	if !inlist("`subcommand'", "wb", "information", "cl", "") {
		noi disp as err "subcommand must be either {it:wb}, {it:cl}, or {it:info}"
		error 
	}
	
	
	*---------- One-on-one execution
	if ("`subcommand'" == "cl" & lower("`country'") == "all") {
		noi disp in red "you cannot use option {it:countr(all)} with subcommand {it:cl}"
		error 197
	}
	
	*---------- PPP
	if (lower("`country'") == "all" & "`ppp'" != "") {
		noi disp as err "Option {it:ppp()} is not allowed with {it:country(all)}"
		error
	}
	
	*---------- WB aggregate
	
	if ("`subcommand'" == "wb") {
		if ("`country'" != "") {
			noi disp as err "option {it:country()} is not allowed with subcommand {it:wb}"
			error
		}
		noi disp as res "Note: " as txt "subcommand {it:wb} only accepts options " _n  /* 
		*/ "{it:region()} and {it:year()}"
	}
	
	
	*---------- Country
	if ("`country'" == "" & "`region'" == "") local country "all"
	if ("`country'" != "") {
		if (lower("`country'") != "all") local country = upper("`country'")
		else                             local country "all"
	}
	
	
	/*==================================================
	Main conditions
	==================================================*/
	
	if ("`information'" == "") {
		if (c(N) != 0 & "`clear'" == "" & /* 
		*/ "`information'" == "") {
			noi di as err "You must start with an empty dataset; or enable the option {it:clear}."
			error 4
		}
		drop _all
	}
	
	*---------- Country and region
	if  ("`country'" != "") & ("`region'" != "") {
		noi disp in r "options {it:country()} and {it:region()} are mutally exclusive"
		error
	}
	
	if ("`aggregate'" != "") {
		if ("`ppp'" != ""){
			noi di  as err "Option PPP cannot be combined with aggregate."
			error 198
		}
		noi disp as res "Note: " as text "Aggregation is only possible over reference years."
		local agg_display = "Aggregation in base year(s) `year'"
	}
	
	if (wordcount("`country'")>2) {
		if ("`ppp'" != ""){
			noi di as err "Option PPP can only be used with one country."
			error 198
		}
	}
	
	
	/*==================================================
	Execution 
	==================================================*/
	pause povcalnet - before execution
	
	*---------- Information
	if ("`information'" != ""){
		noi povcalnet_info, `clear' `pause' server(`server')
		return add 
		exit
	}	
	
	*---------- Country Level (one-on-one query)
	if ("`subcommand'" == "cl") {
		noi povcalnet_cl, country("`country'")  ///
		year("`year'")                   ///
		povline("`povline'")             ///
		ppp("`ppp'")                     ///
		server("`server'")               ///
		coverage(`coverage')             /// 
		`clear'                          ///
		`iso'                            ///
		`pause'
		return add
		exit
	}
	
	
	*---------- Regular query and Aggregate Query
	if ("`subcommand'" == "wb") {
		local wb "wb"
	}
	else local wb ""
	
	
	tempfile povcalf
	save `povcalf', empty 
	
	local f = 0
	
	foreach i_povline of local povline {	
		local ++f 
		
		/*==================================================
		Create Query
		==================================================*/
		povcalnet_query,   country("`country'")  ///
		region("`region'")                     ///
		year("`year'")                         ///
		povline("`i_povline'")                 ///
		ppp("`i_ppp'")                         ///
		coverage(`coverage')                   ///
		server(`server')                       ///
		`clear'                                ///
		`information'                          ///
		`iso'                                  ///
		`fillgaps'                             ///
		`aggregate'                            ///
		`wb'                                   ///
		`pause'                                ///
		`groupedby'                            //
		
		
		local query_ys = "`r(query_ys)'"
		local query_ct = "`r(query_ct)'"
		local query_pl = "`r(query_pl)'"
		local query_ds = "`r(query_ds)'"
		local query_pp = "`r(query_pp)'"
		
		return local query_ys_`f' = "`query_ys'"
		return local query_ct_`f' = "`query_ct'"
		return local query_pl_`f' = "`query_pl'"
		return local query_ds_`f' = "`query_ds'"
		return local query_pp_`f' = "`query_pp'"
		return local base      = "`base'"
		
		*---------- Query
		local query = "`query_ys'&`query_ct'&`query_pl'`query_pp'`query_ds'&format=csv"
		return local query_`f' "`query'"
		global pcn_query = "`query'"
		
		*---------- Base + query
		local queryfull "`base'?`query'"
		return local queryfull_`f' = "`queryfull'"
		
		
		/*==================================================
		Download  and clean data
		==================================================*/
		
		*---------- download data
		local rc = 0
		
		local qr = 1 // query round		
		while (`qr' <= `querytimes') {
			
			tempfile clfile
			cap copy "`queryfull'" `clfile'
			if (_rc == 0) {
				cap insheet using `clfile', clear name
				if (_rc != 0) local rc "in"
				continue, break
			} 
			else {
				local rc "copy"
				local ++qr
			} 
		}
		
		* global qr = `qr'
		
		if ("`aggregate'" == "" & "`wb'" == "") {
			local rtype 1
		}
		else {
			local rtype 2
		}
		
		pause after downdload
		
		*---------- Clean data
		povcalnet_clean `rtype', year("`year'") `iso' /* 
		*/ rc(`rc') region(`region') `pause'
		
		pause after cleaning
		
		/*==================================================
		Display Query
		==================================================*/
		
		if ("`dipsquery'" == "") {
			noi di as res _n "{ul: Query at \$`i_povline' poverty line}"
			noi di as res "{hline}"
			if ("`query_ys'" != "") noi di as res "Year:"         as txt "{p 4 6 2} `query_ys' {p_end}"
			if ("`query_ct'" != "") noi di as res "Country:"      as txt "{p 4 6 2} `query_ct' {p_end}"
			if ("`query_pl'" != "") noi di as res "Poverty line:" as txt "{p 4 6 2} `query_pl' {p_end}"
			if ("`query_ds'" != "") noi di as res "Aggregation:"  as txt "{p 4 6 2} `query_ds' {p_end}"
			if ("`query_pp'" != "") noi di as res "PPP:"          as txt "{p 4 6 2} `query_pp' {p_end}"
			noi di as res _dup(20) "-"
			noi di as res "No. Obs:"      as txt _col(20) c(N)
			noi di as res "{hline}"
		}
		
		/*==================================================
		Append data
		==================================================*/			
		if (`wb_change' == 1) {
			keep if regioncode == "WLD"
		}
		append using `povcalf'
		save `povcalf', replace
		
	} // end of povline loop
	return local npl = `f'
	
	// ------------------------------
	//  display results 
	// ------------------------------
	
	local n2disp = min(`c(N)', `n2disp')
	noi di as res _n "{ul: first `n2disp' observations}"
	
	if ("`subcommand'" == "wb") {
		sort  year regioncode
		noi list region year povertyline headcount mean in 1/`n2disp', /*
		*/ abbreviate(12)  sepby(year)
	}
	
	else {
		if ("`aggregate'" == "") {
			sort countrycode year regioncode
			noi list countrycode year povertyline headcount mean median datatype /*
			*/ in 1/`n2disp',  abbreviate(12)  sepby(countrycode)
		}
		else {
			sort year
			noi list year povertyline headcount mean , /*
			*/ abbreviate(12) sepby(povertyline)
		}		
	}
	
} // end of qui
end

// ------------------------------------------------------------------------
// MATA functions
// ------------------------------------------------------------------------


findfile stata.trk
local fn = "`r(fn)'"

cap mata: mata drop povcalnet_*()
mata:

// function to look for source of code
void povcalnet_source(string scalar cmd) {
	
	cmd =  cmd :+ "\.pkg"
	
	fh = _fopen("`fn'", "r")
	
	pos_a = ftell(fh)
	pos_b = 0
	while ((line=strtrim(fget(fh)))!=J(0,0,"")) {
		if (regexm(strtrim(line), cmd)) {
			fseek(fh, pos_b, -1)
			break
		}
		pos_b = pos_a
		pos_a = ftell(fh)
	}
	
	src = strtrim(fget(fh))
	if (rows(src) > 0) {
		src = substr(src, 3)
		st_local("src", src)
	} 
	else {
		st_local("src", "NotFound")
	}
	
	fclose(fh)
}

end 



exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
		
Version Control:


*##s

findfile stata.trk
local fn = "`r(fn)'"

mata:
cmd = "povcalnet"
cmd =  cmd :+ "\.pkg"
	
	fh = _fopen("`fn'", "r")
	
	pos_a = ftell(fh)
	pos_b = 0
	while ((line=strtrim(fget(fh)))!=J(0,0,"")) {
		if (regexm(strtrim(line), cmd)) {
			fseek(fh, pos_b, -1)
			break
		}
		pos_b = pos_a
		pos_a = ftell(fh)
	}
	
	src = strtrim(fget(fh))
	if (rows(src) > 0) {
		src = substr(src, 3)
		st_local("src", src)
	} 
	else {
		st_local("src", "NotFound")
	}
	
	fclose(fh)
	src
	
end 


*##e