*! NJC 1.0.0 28 Nov 2007 
program corrtable
	version 8 
	forval k = 1/7 { 
		local opts `opts' flag`k'(str) howflag`k'(str) 
	}

	syntax varlist(numeric) [if] [in] [,                        ///
	COMBine(str asis) DIAGonal(str asis) n Pval LISTwise HAlf   ///
	rformat(str) pformat(str) rsize(str) `opts' * ] 

	if "`rsize'" != "" & !index("`rsize'", "r(rho)") { 
		di as err "rsize() must refer to r(rho)" 
		exit 198 
	} 

	if "`listwise'" != "" marksample touse, novarlist 
	else                  marksample touse 
	qui count if `touse' 
	if r(N) == 0 error 2000 

	tokenize "`varlist'" 
	local nv : word count `varlist' 
	local h1 = 2 
	local h2 = `nv' 	

	qui forval i = 1/`nv' { 
		local I : variable label ``i'' 
		if `"`I'"' == "" local I "``i''"
		local I = trim(`"`I'"') 

		if `i' < `nv' local holes `holes' `h1'/`h2' 

		local J = cond("`half'" != "", `i', `nv') 

		forval j = 1/`J' { 
			tempname g 

			if `i' == `j' { 
				forval l = 1/5 { 
					local p`l' : piece `l' 16 of "`I'", nobreak 
				}
				
				local y = 5 
				local call `y' 1 `"`p1'"'

				forval l = 2/5 { 
					if `"`p`l''"' != "" { 
						local --y 
						local call `call' `y' 1 `"`p`l''"' 
					} 
				}

			        if `y' < 5 { 
					local --y
					local scale r(`y' 6) 
				} 
				else local scale 

				twoway scatteri `call', mlabsize(*3) mlabpos(0) ms(none ..) name(`g') ///
				nodraw ysc(`scale' off) yla(, nogrid) xsc(off) `diagonal' 
			}
			else { 
				corr ``i'' ``j'' if `touse' 

				if "`rsize'" != "" { 
					local rlabsize = `rsize' 
					local rsizecall mlabsize(*`rlabsize') 
				} 

				if "`rformat'" == "" local rformat %5.3f
				local rho : di `rformat' r(rho) 
				local y = 3 
				local call `y' 1 "`rho'" 

				if "`n'" != "" { 
					local --y 
					local call `call' `y' 1 "`r(N)'" 
				}

				if "`pval'" != "" { 
					if "`pformat'" == "" local pformat %4.3f 
					local P = 2 * ttail(r(N)-2, abs(r(rho)) * sqrt(r(N)-2) / sqrt(1 - r(rho)^2)) 
					local P : di `pformat' `P' 
					local --y
					local call `call' `y' 1 "`P'"
				}

				local --y 

				local show 
				forval k = 1/7 {
					if "`flag`k''" != "" {  
						if `flag`k'' local show `howflag`k''
					}
				} 

				twoway scatteri `call', mlabsize(*4) mlabpos(0) ///
				ysc(r(`y' 4) off) xsc(r(0 2) off) yla(, nogrid) name(`g')     /// 
				ms(none ..) nodraw `options' `show' `rsizecall' 
			}

			local G `G' `g' 
		}

		local h1 = `h1' + `nv' + 1 
		local h2 = `h2' + `nv' 
	}

	if "`half'" != "" graph combine `G', holes(`holes') `combine'
	else graph combine `G', `combine' 
end

