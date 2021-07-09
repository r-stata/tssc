



*capture program drop calldiagram
program define calldiagram
	
	local n 1
	if substr(trim(`"`macval(0)'"'),1,9) == "suppress(" {
		di as err "YEEEPPPPPP"
		local 0 : subinstr local 0 "suppress(" ""
		
		local mt = strpos(`"`macval(0)'"',")") 
		local suppress = substr(`"`macval(0)'"',1, `mt'-1)
		local 0 = substr(`"`macval(0)'"',`mt'+1, .)
		
		tokenize "`suppress'"
		while "`1'" != "" {
			local sup`n' "`1'"
			local n `++n'
			macro shift
		}
	}
	
	
	if "`c(trace)'" != "on" {
		local trace 1
		set trace on
	}
	
	tempfile log
	tempfile tmp
	tempname hitch knot
	
	// check the log status
	quietly log query
	if "`r(status)'" == "on" {
		local logfile "`r(filename)'"
		qui log c
	}
	
	// make sure the log is not open
	quietly log using "`log'", replace smcl
	`0'
	quietly log close
	
	copy "`log'" sth.txt, replace
	
	qui file open `hitch' using "`log'", read
	qui file open `knot' using "`tmp'", write replace
	file read `hitch' line
	while r(eof)==0 {
		di as err "1"
		local line : subinstr local line "`" "", all
		local line : subinstr local line "'" "", all
		local line : subinstr local line `"""' "", all
		*capture display "`line'" //exclude lines that include weird stuff
		local line : di ustrltrim(`"`macval(line)'"')
		local b : di substr(ustrltrim(`"`macval(line)'"'), 1,6)
		*if _rc != 0 {
			*local b : di trim(substr(`"`macval(line)'"', 1,6))
			if "`b'" == "{hline" {
				local line : di substr(`"`macval(line)'"', 11, strlen("`line'")-18)
				
				file write `knot' `"`macval(line)'"' _n 
			}	
		*}
		file read `hitch' line
	}
	
	
		
	if !missing("`trace'") {
		set trace off
	}
	
	file close `knot'
	file close `hitch'
	

	
	copy "`tmp'" sth2.txt, replace
	
	
	tempfile tmp2
	tempname hitch knot
	
	qui file open `hitch' using "`tmp'", read
	qui file open `knot' using "`tmp2'", write replace
	file read `hitch' line
	
	local n = `n' -1
	
	while r(eof)==0 {
		
		local equal
		
		
		di as err "N:`n'"
		forval j = 1/`n' {
			di as err "??? `sup`j'' == `line'"
			if trim("begin `sup`j''") == trim("`line'") | 						///
			trim("end `sup`j''") == trim("`line'") {
				local equal 1
			}
			
		}
		if missing("`equal'") file write `knot' `"`macval(line)'"' _n 		
		file read `hitch' line
	}	
	file close `knot'
	file close `hitch'
	
	
	*copy "`tmp2'" sth3.txt, replace
	
	
	copy "`tmp2'" "`tmp'", replace
	
			
	
	// Initiate the diagram
	// -------------------------------------------------------------------------
	tempfile export
	tempname knot hitch
	
	qui file open `hitch' using "`tmp'", read
	qui file open `knot' using "`export'", write text replace
	
	file write `knot' "digraph G {" _n 											///
	`"    penwidth="0.1";"' _n														///
	`"    edge [comment="Wildcard edge",fontname="sans-serif","'					///
    `"fontsize=10,colorscheme="greys3",color=2,fontcolor=3];"' _n 			///
    `"    node [fontname="serif",fontsize=13,fillcolor="1", "'					///
	`"colorscheme="greys3",color="2",fontcolor="4",style="filled"];"' _n
	
	file read `hitch' line
	if substr(trim("`line'"),1,5) == "begin" {
		local line : subinstr local line "begin " ""
	}
	
	local i 1					// written lines counter
	local position     1
	local node1    "`line'"
	local previous : di trim("`line'")
	

	
	while r(eof)==0 {

		if substr(trim("`line'"),1,5) == "begin" {
			local line : subinstr local line "begin " ""
			local equal
			forval j = 1/`n' {
				if "sup`j'" == "`line'" {
					local equal 1
				}
			}
			
			if missing("`equal'") {
				local position `++position'
				local node`position' "`line'"
			
				forval j = 1/`i' {
					if "`writtenline`j''" == "`previous' -> `line';" {
						local equal 1
					}	
				}
			
			
				if missing("`equal'") {
					file write `knot' "    `previous' -> `line';" _n 
					local i `++i'
					local writtenline`i' "`previous' -> `line';"
					local previous `node`position''
				}
			}	
		}
		if substr(trim("`line'"),1,3) == "end" {
			local line : subinstr local line "end " ""
			local equal
				
				local position `--position'
			*local node`position' "`line'"
			*file write `knot' "	`previous' -> `line';" _n 
				local list "`list' `line'"
				local previous `node`position''
			
		}
		file read `hitch' line
		
	}
	
	file write `knot' "}" _n 
	file close `knot'
	
		
	// AVOID DUPLICATIONS
	
	// REOPEN THE LOG, IF IT WAS OPEN
	if !missing("`logfile'") {
		qui log using "`logfile'", append
	}
	
	cls
	
	qui copy "`export'" calldiagram.gv, replace
	
	// report the results
	cap confirm file "calldiagram.gv"
	if _rc == 0 {
		di as txt "(calldiagram created "`"{bf:{browse "calldiagram.gv"}})"' _n
	}
	else display as err "calldiagram could not produce calldiagram.gv" _n
	
	
end


*calldiagram suppress(duplicates clear label) makediagram using "cluster.dta", export(cluster.gv)  replace

*calldiagram suppress(findfile clear label) diagram using "circo.txt", export(example.png)  replace
