program define longplot
* 0.0 ZWANG August 13 1998
* 0.1 NJC suggestions August 14 1998
* 1.0.0 ZWANG & NJC August 18 1998
* 1.1.0 NJC Stata 6.0 version 27 April 1999
* 1.2.0 NJC & ZWANG 21 Sept 1999 
*! 1.3.0 NJC & ZWANG 29 Oct 1999
*! 1.3.1 NJC 31 May 2001
*! 1.3.2 NJC 4 June 2001 
*! 1.3.3 NJC 9 July 2001 
        version 6.0
        syntax varlist(min=2 max=2) [if] [in] , [ Id(varname) /*
	*/ by(varname) XLAbel(str) YLAbel(str) Symbol(str) /* 
	*/ Connect(str) Pen(str) bbox(str) SAving(str asis) /* 
	*/ ROWBEG(int 1500) ROWSTEP(int 1500) COLpos(int 28200) /* 
	*/ YSCale(str) XSCale(str) SHake * ] 

	if "`id'" == "" { 
		capture tsset 
		local id "`r(panelvar)'" 
		if "`id'" == "" { 
			di in r "id( ) option required" 
			exit 198 
		} 
	} 	
	
        tokenize `varlist'
	args y x 

	if "`connect'" != "" & "`connect'" != "L"  { 
		di in r "only connect(L) supported" 
		exit 198
	}
	
	if "`symbol'" == "" { local symbol "OSTodp." }
	else if index("`symbol'", "[") { 
		di in r "sy([varname]) and sy([_n]) not supported"
		exit 198 
	} 	
	
	if "`pen'" == "" { local pen "2345678" }

        if `"`xlabel'"' == `""' { local xlabel "xla" }
        else local xlabel `"xla(`xlabel')"'
        if `"`ylabel'"' == `""' { local ylabel "yla" }
        else local ylabel `"yla(`ylabel')"'

	preserve
        tempvar xmin xmax grp

        qui {
		marksample touse 
                keep if `touse'

		if "`by'" != "" { 
			drop if missing(`by') 
		} 	
		
		count 
		if r(N) == 0 { 
			di in r "no observations" 
			exit 2000 
		} 
	
                if "`by'" != "" { 
	            	local glabel : value label `by'
	    	        egen `grp' = group(`by')
			su `grp', meanonly 
        	        local ngrps = r(max)
			if `ngrps' > 7 {
		                local ngrps = 7
                		noi di in bl /* 
			*/ "Results plotted for first 7 groups only" 
			} 
			if "`bbox'" == "" { 
				local bbox "0,0,23063,28000,570,290,0" 
			}
	        }
		else { 
			gen byte `grp' = 1 
			local ngrps = 1
		}
		
		if "`bbox'" != "" { local bb "bbox(`bbox')" }

		if "`shake'" != "" { 
		* shake apart tied values by adding random noise 
			tempvar xdiff x2
			sort `x' 
			gen `xdiff' = `x' - `x'[_n-1] 
			su `xdiff' if `xdiff', meanonly 
			local xresol = r(min) 
			gen `x2' = `x' + 0.001 * `xresol' * (uniform( ) - 0.5) 
			_crcslbl `x2' `x' 
		        local xfmt : format `x'
		        format `x2' `xfmt'
                        local xlab : value label `x'
                        label val `x' `xlab'
			local x `x2' 
		}	
		
            	egen `xmin' = min(`x'), by(`id')
                egen `xmax' = max(`x'), by(`id')

                sum `y', meanonly
                local ysmin = r(min)
                local ysmax = r(max)

                sum `x', meanonly
                local xsmin = r(min)
                local xsmax = r(max)
		
		if "`yscale'" != "" { 
			tokenize "`yscale'", parse(",") 
			if "`2'" != "," | "`4'" != "" { 
				di in r "invalid yscale( ) option"
				exit 198
			}	
			if "`1'" != "." & `1' < `ysmin' { local ysmin = `1' } 
			if "`3'" != "." & `3' > `ysmax' { local ysmax = `3' } 
		}

		if "`xscale'" != "" { 
			tokenize "`xscale'", parse(",") 
			if "`2'" != "," | "`4'" != "" { 
				di in r "invalid xscale( ) option"
				exit 198
			}	
			if "`1'" != "." & `1' < `xsmin' { local xsmin = `1' } 
			if "`3'" != "." & `3' > `xsmax' { local xsmax = `3' } 
		}
                gsort `by' - `xmin' - `xmax' `id' `x'
        }
       
        if "`saving'" != "" { local saving `"saving(`saving')"' } 
        gph open, `saving' 

        local i = 1
        local j = 1

        while `i' <= `ngrps' {
		local s = substr("`symbol'",`i',1)
		local p = substr("`pen'",`i',1) 

                gr `y' `x' if `grp' == `i', c(L) s(`s') /*
                */ xscale(`xsmin',`xsmax') yscale(`ysmin',`ysmax') /*
                */ `xlabel' `ylabel' pen(`p') `bb' `options'

		if "`by'" != "" { 
			local colpos2 = `colpos' + 300
	                local r1 = `rowbeg' + `rowstep' * (`i' - 1) 
        	        local r2 = `r1' + 100
			local s = substr("`symbol'", `i',1) 
			Gphtrans `s' 
                	gph point `r1' `colpos' 150 `g'
	                local gid = `by'[`j']
        	        if "`glabel'" != "" { 
				local gid : label `glabel' `gid' 
			}
                	gph text `r2' `colpos2' 0 -1 `gid'
	                qui count if `grp' == `i'
        	        local j = `j' + r(N)
		}
		
                local i = `i' + 1
        }

        gph close
end

program def Gphtrans /* transliterate ".OSTodpx" -> "01234567" */
* 1.0.0 NJC 4 June 2001
    version 6.0
    args s
	    
    if "`s'" == "."      { loc g 0 }
    else if "`s'" == "O" { loc g 1 }
    else if "`s'" == "S" { loc g 2 }
    else if "`s'" == "T" { loc g 3 }
    else if "`s'" == "o" { loc g 4 }
    else if "`s'" == "d" { loc g 5 }
    else if "`s'" == "p" { loc g 6 }
    else if "`s'" == "x" { loc g 7 } /* requires version 7, really */ 

    c_local g `g' 
end                      

