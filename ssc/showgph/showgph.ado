program define showgph
*! 1.1.0 6 February 2001 Nick Cox
*! 1.0.10 28 April 2000 Jan Brogger & Nick Cox
	version 6.0

	gettoken flspc 0 : 0, parse(",")
	local flspc = trim(`"`flspc'"')
	if `"`flspc'"' == "" { 
		local flspc "*.gph"
	}
	else if `"`flspc'"' == "," { /* retreat */
		local 0 ", `0'"
		local flspc "*.gph"
	}
	else if !index(`"`flspc'"',".gph") {
		local flspc `"`flspc'.gph"'
	}

	syntax [, Dir(str) Asis List ]
	
	if "`dir'" != "" { 
		local dirsep : dirsep 
		local lastch = substr("`dir'",-1,1)
		if "`lastch'" == "\" { 
			local ldir0 = length("`dir'") - 1 
			local dir0 = substr("`dir'",1,`ldir0') 
			local dir "`dir0'/" 
		}	
		else if "`lastch'" != "`dirsep'" { 
			local dir "`dir'`dirsep'"
		} 	
	}

/*

Stata requires the / in Windows pathnames that will be 
followed by a local macro, as explained in [U] 21.3.9. 

*/

	local more : set more

	tempfile gphlst
	
	qui {
		preserve
		drop _all
		local FLSPC "`dir'`flspc'"
		
		if "$S_OS" == "Unix" { 
			! ls -1 `FLSPC' > `gphlst' 
		} 	
		else { 		
			nobreak { 
				local logf : log
				if "`logf'" != "" { log close }
				
				* 7.0 -log- is by default smcl 
				if _caller() > 6 { local text ", text" } 
				log using "`gphlst'" `text' 
				noi dir "`FLSPC'"
				log close
	
				if "`logf'" != "" { 
					log using "`logf'", append 
				}
			}	
		} 	

		if "$S_OS" == "Unix" { 
			capture infix str80 files 1-80 using "`gphlst'", clear
		} 	
		else capture infix str80 files 25-104 using "`gphlst'", clear

		capture { 
			replace files = trim(files) 
			compress files 
			drop if missing(files) 
		} 
		
		count 
	}
	
	if `r(N)' {
		set more on
		sort files
		if "`list'" != "" { list files }

                local i = 1
		while `i' <= _N {
			local fn = files[`i']
			if "`asis'" == "" {
				graph using "`dir'`fn'", t1("`fn'")
			}
			else graph using "`dir'`fn'"
			if `i' < _N { more }
			local i = `i' + 1
		}
	 }
	 else di in g "No files match `flspc'"

	 local which = cond(`more', "off", "on")
	 set more `which'
end
