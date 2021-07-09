*! renamed 27 February 2003 
*! 1.1.2 NJC 27 February 2003
*! 1.1.1 NJC 26 July 2002
* 1.1.0 NJC 11 June 2002
* 1.0.0 NJC 5 June 2002
program define ofrtplot7
	version 7.0
	#delimit ; 
	syntax [varname(ts def=none)]
	[ , Symbol(str) Connect(str) BY(varname) Gap(int 5)  
	RLAbel1(str) RLAbel2 RLIne1(str) RLIne2 RTIck1(str) RTIck2 RSCale(str) 
	YLAbel1(str) YLAbel2 YLIne1(str) YLIne2 YTIck1(str) YTIck2 YSCale(str)
	XLAbel1(str) XLAbel2 
	R1title(str asis) R2title(str asis) 
	L1title(str asis) L2title(str asis) 
	B2title(str asis) TItle(str asis) SAving(str asis) noSOrt 
	super tfrac(real 0.625) rfrac(str) NLAbel(int 4) * ];
	#delimit cr 

	* x variable defaults to time variable 
	if "`varlist'" == "" { 
		qui tsset 
		local varlist "`r(timevar)'" 
	}
	* -sort- is default with explicit varname 
	else { 
		if "`sort'" == "" { local sort "sort" } 
	} 	
	
	* get observed and model results 
	tempvar fit residual zero 
	quietly {
		* observed 
		if "`e(depvar)'" == "" { 
			di as err "estimates not found" 
			exit 301 
		} 
		local ndepvar : word count `e(depvar)' 
		if `ndepvar' > 1 { 
			di as err "ofrtplot not allowed after `e(cmd)'" 
			exit 498 
		} 	
		local observed "`e(depvar)'" 
 
 		* fitted and residual 
		predict `fit' if e(sample) 
		predict `residual' if e(sample), res
		label var `fit' "Fitted" 
		label var `residual' "Residual" 

		* zeros 
		gen byte `zero' = 0
	}	

	* no by() 
	if "`by'" != "" { 
		di as err "by() not supported" 
		exit 198 
	}

	* check between forms like -ylabel- and -ylabel()- 
	Check ylabel `"`ylabel1'"' `"`ylabel2'"' yla 
	Check yline  `"`yline1'"'  `"`yline2'"'  yli 
	Check ytick  `"`ytick1'"'  `"`ytick2'"'  yti
	Check xlabel `"`xlabel1'"' `"`xlabel2'"' xla 

	if "`super'" == "" { 
		Check rlabel `"`rlabel1'"' `"`rlabel2'"' Ryla  
		Check rline  `"`rline1'"'  `"`rline2'"'  Ryli 
		Check rtick  `"`rtick1'"'  `"`rtick2'"'  Ryti 
	} 
	else { 
		Check rlabel `"`rlabel1'"' `"`rlabel2'"' rla  
		Check rline  `"`rline1'"'  `"`rline2'"'  rli 
		Check rtick  `"`rtick1'"'  `"`rtick2'"'  rti 
	} 

	* -yscale()- and -rscale()- 
	if "`yscale'" != "" { local ysc "ysc(`yscale')" }
	if "`rscale'" != "" { 
		if "`super'" == "" { 
			local rsc "ysc(`rscale')" 
		}
		else local rsc "rsc(`rscale')" 
	} 
	
	if "`xla'" == "" {
		tempvar year 
		local format : format `varlist' 
		local which = substr("`format'",2,1) 
		local which2 = substr("`format'",3,.)
		
		/* formats beginning "%t", but not "%ty" */ 
		if "`which'" == "t" & "`which2'" != "y" { 			
	 		local which = substr("`format'",3,1)
			if "`which'" != "d" { 
				qui gen `year' = yofd(dof`which'(`varlist')) 
				su `year' if e(sample), meanonly        
				Nicenum `nlabel' 
				local X "`r(numlist)'"  
				if "`X'" != "" { 
					foreach x of local X {
						local la = `which'(`x'`which'1) 
						local LA "`LA'`la' " 
					}
				}
			} 
		}
		
		/* format "%ty" */ 
		else if "`which'" == "t" & "`which2'" == "y" { 			
			su `varlist' if e(sample), meanonly        
			Nicenum `nlabel' 
			local X "`r(numlist)'"  
			if "`X'" != "" { local LA "`X'" } 					
		} 
		
		/* formats beginning "%d" or "%td" */ 
		else if "`which'" == "d" { 
			qui gen `year' = yofd(`varlist')
			su `year' if e(sample), meanonly        
			Nicenum `nlabel' 
			local X "`r(numlist)'"  
			if "`X'" != "" { 
				foreach x of local X {
					local la = d(1jan`x') 
					local LA "`LA'`la' " 
				}
			}
		}
	
		if "`LA'" != "" { local xla "xla(`LA')" } 
	} 

	* symbol() 
	if "`symbol'" == "" { 
		if "`super'" == "" { 
			local syof "ii" 
			local syrz "ii" 
		}
		else local symbol "iiii" 
	} 
	else if "`super'" == "" { 
		local symbol = trim("`symbol'") 
		local len = length("`symbol'") 
		local j = 1 
		local acc = 0 /* 1 => accumulate chars */ 
		forval i = 1/`len' { 
			local c = substr("`symbol'",`i',1) 
			if "`c'" == "[" { /* start accumulating */ 
				local s`j' "`c'" 
				local acc = 1 
			}
			else if "`c'" == "]" { /* stop accumulating */ 
				local s`j' "`s`j''`c'" 
				local acc = 0 
				local j = `j' + 1 
			}
			else if `acc' { /* accumulating */ 
				local s`j' "`s`j''`c'"
			}
			else if "`c'" == " " { /* skip spaces */  
				* do nothing 
			} 	
			else { /* other chars */ 
				local s`j' "`c'" 
				local j = `j' + 1 
			}
		}
		local syof "`s1'`s2'" 
		local syrz "`s3'`s4'" 
	}	
	
	* connect() 
	if "`connect'" == "" { 
		if "`super'" == "" { 
			local cof "ll[-]" 
			local crz "||" 
		}
		else local connect "ll[-]||" 
	} 
	else if "`super'" == "" { 
		local connect = trim("`connect'") 
		local len = length("`connect'") 
		local j = 0 
		local acc = 0 /* 1 => accumulate chars */ 
		forval i = 1/`len' { 
			local c = substr("`connect'",`i',1)
			if "`c'" == "|" | "`c'" == "I" { /* || or II */ 
				local j = `j' + 1 - `acc' 
				local c`j' "`c`j''`c'" 
				local acc = 1  - `acc' 
			} 
			else if "`c'" == "[" { /* start accumulating */  
				local c`j' "`c`j''`c'" 
				local acc = 1 
			}
			else if "`c'" == "]" { /* stop accumulating */  
				local c`j' "`c`j''`c'" 
				local acc = 0 
			}
			else if `acc' { /* accumulating */ 
				local c`j' "`c`j''`c'"
			}
			else if "`c'" == " " { /* skip spaces */  
				* do nothing 
			} 	
			else { /* other chars */
				local j = `j' + 1 
				local c`j' "`c'" 
			}
		}
		local cof "`c1'`c2'" 
		local crz "`c3'`c4'" 
	}	

	* draw graph
	if "`super'" == "" { /* default: separate panels */ 
		if `"`saving'`title'"' != "" { 
			tempfile savefile 
			local temp ", saving(`savefile')" 
		}	

		local tbottom = cond(`tfrac' >= 1, 23063, int(`tfrac' * 23063))

		* -rfrac()- is undocumented: 
		* note especially that (`tfrac' + `rfrac') can be >1 
		if "`rfrac'" == "" { local rfrac = 1 - `tfrac' } 
		local rtop = cond(`tfrac' <= 0, 0, int((1 - `rfrac') * 23063)) 
			
	        gph open `temp' 
	
		if `tfrac' > 0 { /* top panel */  
			if `"`l1title'"' == "" {
				local l1title "Observed and fitted"  
			}
			if `"`b2title'"' == "" { 
				local b2title " " 
			}
			if `"`l2title'"' != "" { 
				local l2title `"l2("`l2title'")"'   
			}

			#delimit ; 
	        	graph `observed' `fit' `varlist' if e(sample), 
			`options' l1(`"`l1title'"') `l2title'  
			sy(`syof') c(`cof') gap(`gap') `sort'  
			`yla' `yli' `yti' `ysc' `xla'  
			bbox(0,0,`tbottom',32000,923,444,0) 
			b2(`"`b2title'"') ; 
			#delimit cr 
		} 	
		
		if `tfrac' < 1 { /* residual panel */ 
			if `"`r1title'"' == "" { 
				local r1title "Residuals"  
			}
			if `"`b2title'"' != "" { 
				local b2title `"b2("`b2title'")"' 
			}
			if `"`r2title'"' != "" { 
				local r2title `"l2("`r2title'")"' 
			}

			#delimit ; 
			graph `residual' `zero' `varlist' if e(sample), 
			`options' l1(`"`r1title'"') `r2title' 
			sy(`syrz') c(`crz') gap(`gap') `sort' 
			`Ryla' `Ryli' `Ryti' `rsc' `xla'   
			bbox(`rtop',0,23063,32000,923,444,0) 
			`b2title' ;   
			#delimit cr 
		} 	
		
		gph close 
		
		* any -title()- or -saving()- applies to whole image
		if "`temp'" != "" { 
			if `"`title'"' != "" { 
				local Title `"ti(`title')"' 
			}
			if `"`saving'"' != "" { 
				local Saving `"sa(`saving')"' 
			} 	
			graph using "`savefile'", `Title' `Saving' 
		}	
	}
	else { /* superimposed */  
		if `"`l1title'"' == "" { 
			local l1title "Observed, fitted and residuals" 
		}
		if `"`b2title'"' != "" { 
			local b2title `"b2("`b2title'")"' 
		}
		if `"`r1title'"' != "" { 
			local r1title `"r1("`r1title'")"' 
		}
		if `"`r2title'"' != "" { 
			local r2title `"r2("`r2title'")"' 
		}
		if `"`l2title'"' != "" { 
			local l2title `"l2("`l2title'")"' 
		}

		if `"`saving'`title'"' != "" { 
			if `"`saving'"' != "" { 
				local Saving `"saving(`saving')"' 
			} 
			if `"`title'"' != "" { 
				local Title `"ti(`title')"' 
			} 
		}	
		#delimit ; 
	        graph `observed' `fit' `residual' `zero' `varlist' if e(sample), 
		`options' l1(`"`l1title'"') `l2title' `b2title' 
		`r1title' `r2title'  
		sy(`symbol') c(`connect') gap(`gap') `sort'  
		`yla' `yli' `yti' `rla' `rli' `rti' `ysc' `rsc' `xla' 
		`Saving' `Title' ; 
		#delimit cr 
	}
end

program define Check 
	args option spec1 spec2 opt 
	
	if `"`spec1'"' != "" & `"`spec2'"' != "" { 
		di as err "may not specify both `option' and `option'()" 
		exit 198 
	} 	

	local opt2 : subinstr local opt "R" "" 
	if `"`spec1'"' != "" { 
		c_local `opt' "`opt2'(`spec1')" 
	} 
	else if `"`spec2'"' != "" { 
		c_local `opt' "`opt2'" 
	} 	
end

* main algorithm based on -nicenum- 1.1.0 11/4/94 (STB-25: dm28)
program define Nicenum, rclass 
	version 7.0
	args nlabel
	tempname gmin gmax grange exp d f nf tmp1 tmp2
	
	* these arguments from -summarize- just earlier 
	scalar `gmin' = r(min)
	scalar `gmax' = r(max)
	
	* all within same year? no go!
	if `gmin' == `gmax' { 
		exit 0 
	} 

	local N = `nlabel' 
        local inter = `N' + 1
	local ntick = `inter' 
	
	scalar `grange' = `gmax' - `gmin'
	scalar `exp' = log10(`grange')
	scalar `exp' = int(`exp') - (`exp' < 0.0)
	
	scalar `f' = `grange' / (10^`exp')
	if `f' <= 1      { scalar `nf' = 1  }
	else if `f' <= 2 { scalar `nf' = 2  }
	else if `f' <= 5 { scalar `nf' = 5  }
	else             { scalar `nf' = 10 }

	scalar `grange' = `nf' * 10^`exp' 
	scalar `d' = `grange' / (`ntick' - 1)
	scalar `exp' = log10(`d')
	scalar `exp' = int(`exp') - (`exp' < 0.0)
	
	scalar `f' = `d' / (10^`exp')
	if `f' < 1.5    { scalar `nf' = 1 }
	else if `f' < 3 { scalar `nf' = 2 }
	else if `f' < 7 { scalar `nf' = 5 }
	else            { scalar `nf' = 10 }

	scalar `d' = `nf' * 10^`exp'
	scalar `gmin' = `gmin' / `d'
	scalar `gmin' = (int(`gmin') - (`gmin' < 0.0)) * `d'
	scalar `tmp1' = `gmax' / `d'
	scalar `tmp2' = int(`tmp1')
	if `tmp2' < float(`tmp1') { scalar `tmp2' = `tmp2' + 1 }
	scalar `gmax' = `tmp2' * `d'
	scalar `tmp1' = log10(`d')
	
	local nfrac = int(-`tmp1') + (`tmp1' < 0.0)
	if `nfrac' <= 0 { local nfrac = 0 }
	if `nfrac' == 0 { scalar `tmp1' = `gmin' }
	else scalar `tmp1' = `gmin' + 1 / (10^(`nfrac' + 1)) 		
	scalar `tmp2' = `gmax' + `d'/ 2
	
	while `tmp1' <= `tmp2' {
		local stub = int(`tmp1')
		if `nfrac' {
			local gminb = int(`tmp1' * (10^`nfrac'))
			local stubb = int(`stub' * (10^`nfrac'))
			local frac = `gminb' - `stubb'
			local frst = "00000000000000000000" + /*
			*/	string(`frac')
			local fstr = substr("`frst'", -`nfrac', .)
			local numlist "`numlist' `stub'.`fstr'"
		}
		else	{ 
			local tstr = string(`tmp1')
			local numlist "`numlist' `tstr'" 
		}
		scalar `tmp1' = `tmp1' + `d' 
	}  

	return local numlist "`numlist'" 
end

