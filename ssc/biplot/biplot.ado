*! biplot version 2.3 21 June 2004 kohler@wz-berlin.de

* version 2.3.1 UK 22 Nov. 04
*           - Saved results
*           - new Option gen
* version 2.3 UK 21 Jun. 04
*           - vwiggins@stata.com solution on xsize from schemes
* version 2.2 UK 16 Jun. 04
*	         - Lines to first data-region
*           - Bug in Options mlabpos, mlabvpos corrected
*           - New Options varonly/obsonly
*           - New Option dimensions()
*           - Options for mixing types
* version 2.1 UK 01 Apr. 04
*           - Bug with options -jk- & -covariance- corrected
*           - New Colors
*           - Suboptions allowed for -subpop()-
* version 2.0 UK 18 Feb. 04 
*           - Upgrade to Stata 8.2
*           - Option RV added
*           - Option mahalanobis added
*           - Options for Biplot-Types changed
*           - Automatically sets Stretch Factors
*           - Graph-Options completely redesigned
*           - Some weights allowed
*           - Subpop Option added
* version 1.0.0 UK 18 Feb 98 on SSC 
* Vers0 22-7-97, NJC suggestions 12 Feb 1998, Rev. UK 18 Feb 1998
	
program define biplot, rclass
	if _caller() < 8 {
		biplot5 `0'
		exit
	}
	version 8.2
	
	syntax varlist(min=2 numeric) [if] [in] [aweight fweight/] ///
	  [, COVariance jk sq gh rv mixed(string) MAHALanobis     /// General Options
	  DIMensions(numlist integer min=2 max=2 >=1 sort)        ///
	  GENerate(namelist min=2 max=2) ///
	  Flip(string) STretch(string) OBSonly VARonly           ///  Biplot-Options    
	  MSymbol(string) MColor(string) MSIZe(string)           /// Scatter Options
	  MSTYle(string) ///
	  MLABSTYle(string) mlabel(string) MLABPOSition(string) ///
	  MLABVPOSition(string) MLABGap(string) ///
          MLABSize(string) MLABColor(string) ///
 	  CLColor(string) CLPattern(string) CLWidth(string) /// Line-Options
 	  jitter(string)  SUBpop(string)                   /// Obs-only Options
	  L1title(string) B2title(string)                   /// Twoway-Options
	  XScale(string) YScale(string) XLABel(string) ///
	  YLABel(string) LEGend(string) scheme(string) xsize(string) *]

 	if (("`sq'"!="") + ("`gh'"!="") + ("`jk'"!="") +("`mixed'" != "") ) > 1 {
                di as error "choose only one of options jk, gh, sq, mixed"
                exit 198 
 	}

 	if "`sq'" != "" {
 	 	local typeobs "SQ"
 	 	local typevar "SQ"
 	}
 	else if "`gh'" != "" {
 	 	local typeobs "GH"
 	 	local typevar "GH"
 	}
 	else if "`mixed'" != "" {
 	 	local typeobs: word 1 of `mixed'
      local typeobs = upper("`typeobs'")
 	 	local typevar: word 2 of `mixed'
      local typevar = upper("`typevar'")
 	}
 	else {
 	 	local typeobs "JK"
 	 	local typevar "JK"
 	}
	
 	if "`weight'" ~= "" {
 		local weightexp "[`weight' = `exp']"
 	}
 	
  	local k: word count `varlist'
	tempvar touse Wvar colnr GX GY HX HY names      
	tempname O Y U W V U1 U2 V1 V2 L Vt G H Lout Vout
	
	mark `touse' `if' `in'                                 
	markout `touse' `varlist'
	

	// Error Checks
	// ------------

	
	// generate()
	if "`generate'" != "" {
      local obsvar = word("`generate'",1)
      local varvar = word("`generate'",2)
		confirm new variable `obsvar'_x `obsvar'_y `varvar'_x `varvar'_y
	}
	
	// weights not for all types
 	if "`weight'"  != "" & "`rv'" ~= ""  {
		di as error "weights not allowed rv"
		exit 198
	} 		
 
 	if "`weight'"  == "aweight" & ("`typeobs'" != "JK" | "`typevar'" != "JK") {
 		di as error "aweights not allowed for gh, sq"
 		exit 198
 	}

	// Check Observations
	quietly count if `touse'   
	local n = r(N)
	if `n' == 0 {
		display as txt "no observations"
		exit
	}
	if `n' <= 2 {
		display as txt "insufficient observations"
		exit
	}

	// Check Matsize
	if  "`typeobs'" == "SQ" | "`typeobs'" == "GH" ///
	  | "`typevar'" == "SQ" | "`typevar'" == "GH" {
		matrix `O' = J(`n',`k',0)
		matrix drop `O'
	}
	
	// Check Mahalanobis 
	if "`mahalanobis'" != "" & ("`typeobs'" != "GH" | "`typevar'" != "GH") {
		local mahalanobis ""
		display as txt ///
		  "mahalanobis ignored (valid only for GH)"
	}
	
	// Check Stretch()
	if "`stretch'" ~= "" {
		if `stretch' <= 0 {                                 
			display as error "stretch(`stretch') must be positive"
			exit 198
		}
	}
	
	// Check Flip()
	local flip = trim(lower("`flip'"))                       
	if "`flip'" != "" & "`flip'" != "x" & "`flip'" != "y" & "`flip'" != "xy" {
		di as errpr "flip(`flip') invalid"
		exit 198
	}

	// Default Xsize from ysize of the scheme
	// --------------------------------------

   local scheme = cond(`"`scheme'"'!=`""',`"scheme(`scheme')"',`""')
	scatter `varlist', nodraw `scheme'
   local xsize = cond(`"`xsize'"'==`""' ///
	  ,`"xsize(`.Graph._scheme.graphsize.y')"' ///
	  ,`"xsize(`xsize')"')

	quietly {
		if "`typeobs'" != "JK" | "`typevar'" != "JK" ///
		  | "`rv'" ~= "" | "`covariance'" ~= "" {
			preserve
		}
		
		// Make the transformations for Compostional Data
		// ----------------------------------------------
		
		if "`rv'" != "" {
			tempvar sum nobs
			gen `sum' = 0
			gen `nobs' = 0
			foreach var of local varlist {
				replace `var' = log(`var'+.5)
				replace `sum' = `sum' + cond(`var'==.,0,`var') if `touse'
				replace `nobs' = `nobs' + (`var'!=.) if `touse'
			}
			foreach var of local varlist {
				replace `var' = `var' - `sum'/`nobs'
				sum `var', meanonly
				replace `var' = `var' - r(mean)
			}
 		}
		
		// Center Variables for unstandardized solution
		if "`covariance'" ~= "" {      
			foreach var of local varlist {
				sum `var' `weightexp', meanonly
				replace `var' = `var' - r(mean)
			}
		}

      if "`dimensions'" == "" {
          local dimensions "1 2"
      }
		local dim1: word 1 of `dimensions'
		local dim2: word 2 of `dimensions'

		
		// Explained Variances of the 2 Dimensions
		// ----------------------------------------
		
		factor `varlist' `weightexp' if `touse', pc `covariance'
		local vartot = 0
		forvalues i=1/`k' {
			local vartot = `vartot' + r(lambda`i')
			if `i' == 1 {
				matrix `Lout' = r(lambda`i')
			}
			if `i' > 1 {
				matrix `Lout' = `Lout', r(lambda`i')
			}
		}
		local explvar1=round(r(lambda`dim1')/`vartot'*100,1) 
		local explvar2=round(r(lambda`dim2')/`vartot'*100,1)
		
 		// JK-Biplot (the default)
		// -----------------------
		
		if "`typeobs'" == "JK"  | "`typevar'" == "JK" {
			forv i = 1/`k' {
				tempvar G`i'
				local Glist "`Glist' `G`i''"
			}
			score `Glist' if `touse'
			if "`typeobs'" == "JK" {
				gen `GX' = `G`dim1''
				gen `GY' = `G`dim2''
			}
			if "`typevar'" == "JK" {
				matrix `H' = get(Ld)
				gen `HX' = `H'[_n,`dim1']
				gen `HY' = `H'[_n,`dim2']
				matrix `Vout' = `H'
			}
		}

		// SQ/GH-Biplots
		// -------------

		if "`typeobs'" == "SQ" | "`typeobs'" == "GH" ///
		  | "`typevar'" == "SQ" | "`typevar'" == "GH" {
			
			// Listwise Deletion (Huge Matrices!)
			keep if `touse'

			// Standardize Variables if not Covariance
			if "`covariance'" == "" {      
				foreach var of local varlist {
					sum `var' `weightexp'
					replace `var' = (`var'-r(mean))/r(sd)
					local i = `i' + 1
				}
			}
			
			if "`weight'" != "" {
				expand `exp'
			}

			// SVD
			mkmat `varlist', matrix(`Y')                
			matrix svd `U' `W' `V' =`Y'
			matrix `Lout' = `W'
			matrix `Vout' = `V'
			
			// Select Elements of W 
			matrix `W' = `W''
			gen `Wvar' =`W'[_n,1]
			gen `colnr' = _n
			gsort -`Wvar'
			local col1=`colnr'[`dim1']
			local col2=`colnr'[`dim2']
			matrix drop `W'
			matrix `W' = `Wvar'[`dim1'] \\ `Wvar'[`dim2'] 

			// make L and from W 
			matrix `W' = `W''    
	      matrix `L' = diag(`W')

         // Square-Roots of W/L for SQ-Biplot
			if "`typeobs'"== "SQ"  | "`typevar'" == "SQ" {
            tempvar Wvar_s
            tempname W_s L_s
				gen `Wvar_s'= sqrt(`Wvar') 
				matrix `W_s' = `Wvar_s'[`dim1'] \\ `Wvar_s'[`dim2'] 
   			matrix `W_s' = `W_s''    
			   matrix `L_s' = diag(`W_s')
			}

         // Resort to original Sort
			sort `colnr'
			drop `colnr'

			// Submatrixes according to dimesions
			matrix `U1'=`U'[1...,`col1']       
			matrix `U2'=`U'[1...,`col2']
			matrix `U'=`U1',`U2'
			matrix `V1'=`V'[1...,`col1']
			matrix `V2'=`V'[1...,`col2']
			matrix `V'=`V1',`V2'
			matrix `Vt'=`V''
			matrix drop `Y' `U1' `U2' `V1' `V2' `V'

			//  GH 
			if "`typeobs'" == "GH" {                             
				matrix `G' =`U'
         }
			if "`typevar'" == "GH" {
            matrix `H' =`L'*`Vt'
				matrix `H' = `H''  
			}

			// SQ 
			if "`typeobs'" == "SQ" { 
				matrix `G' =`U'*`L_s'
         }
			if "`typevar'" == "SQ" {
				matrix `H' = `L_s'*`Vt' 
				matrix `H' = `H''
         }

        matrix drop `U' `L' `L_s' `Vt'

			// Variables G & H 
         if "`typeobs'" != "JK" {
            gen `GX' = `G'[_n,1]
            gen `GY' = `G'[_n,2]
         }
         if "`typevar'" != "JK" {
			    gen `HX' = `H'[_n,1]
			    gen `HY' = `H'[_n,2]
		   }
			
			if "`mahalanobis'" ~= "" {
				foreach axis in X Y {
					replace `G`axis'' = `G`axis''*sqrt(`n')
					replace `H`axis'' = `H`axis''/sqrt(`n')
				}
			}
		}

		// Flip 
		if "`flip'"=="x" {
			replace `GX'=`GX'*-1
			replace `HX'=`HX'*-1
		}
		else if "`flip'"=="y" {
			replace `GY'=`GY'*-1
			replace `HY'=`HY'*-1
		}
		else if "`flip'"=="xy" {
			replace `GX'=`GX'*-1
			replace `HX'=`HX'*-1
			replace `GY'=`GY'*-1
			replace `HY'=`HY'*-1
		}

      // Calculate Default Scale for Axis
		// --------------------------------

		sum `GX', meanonly                                         
		local minGX = r(min)
		local maxGX = r(max)
		sum `GY', meanonly
		local minGY = r(min)
		local maxGY = r(max)
		sum `HX', meanonly
		local minHX = r(min)
		local maxHX = r(max)
		sum `HY', meanonly
		local minHY = r(min)
		local maxHY = r(max)

      if "`varonly'" == "" {
         local min = min(`minGX',`minGY')
		   local max = max(`maxGX',`maxGY')
      }
      else {
         local min = min(`minHX',`minHY')
		   local max = max(`maxHX',`maxHY')
      }
		
		// Biplot Options
		// --------------

		// Stretch
		if "`stretch'" != "" {                                 
			replace `HX'=`HX'*`stretch'
			replace `HY'=`HY'*`stretch'
		}
		else {
			local Sfac1 = abs(`min')/max(abs(`minHX'),abs(`minHY')) 
			local Sfac2 = abs(`max')/max(abs(`maxHX'),abs(`maxHY')) 
			replace `HX' = `HX' * min(`Sfac1',`Sfac2')*.8
			replace `HY' = `HY' * min(`Sfac1',`Sfac2')*.8
		}
			
		// Scatter Options
		//-----------------

		// Split Scatter Options Into Obs and Var Part
		foreach macro in mstyle msymbol mcolor msize mlabel ///
		  mlabstyle mlabposition mlabvposition mlabgap ///
		  mlabsize mlabcolor {
		  	local obs`macro': word 1 of ``macro''
			local var`macro': word 2 of ``macro''
		}
 

		// Default Scatter-Options for Observations
		if "`obsmstyle'" == "" {
			local obsmstyle "p1"
		}
		if "`obsmsymbol'" != "" {
			local obsmsymbol "msymbol(`obsmsymbol')"
		}
		if "`obsmcolor'" != "" {
			local obsmcolor "mcolor(`obsmcolor')"
		}
		if "`obsmsize'" != "" {
			local obsmsize "msize(`obsmsize')"
		}
		if "`obsmlabel'" != "" {
			local obsmlabel "mlabel(`obsmlabel')"
		}
		if "`obsmlabstyle'" == "" {
			local obsmlabstyle "p1"
		}
      if "`obsmlabposition'" != "" {
			local obsmlabposition "mlabposition(`obsmlabposition')"
		}
		if "`obsmlabvposition'" != "" {
			local obsmlabvposition "mlabvposition(`obsmlabvposition')"
		}
		if "`obsmlabgap'" != "" {
			local obsmlabgap "mlabgap(`obsmlabgap')"
		}
		if "`obsmlabsize'" != "" {
			local obsmlabsize "mlabsize(`obsmlabsize')"
		}
		if "`obsmlabcolor'" != "" {
			local obsmlabcolor "mlabcolor(`obsmlabcolor')"
		}
		local obsopt "mstyle(`obsmstyle') mlabstyle(`obsmlabstyle') `obsmsymbol' `obsmcolor' `obsmsize'"
		local obsopt "`obsopt' `obsmlabel' `obsmlabposition' `obsmlabvposition' `obsmlabsize'"
		local obsopt "`obsopt' `obsmlabcolor'"
	

		// Default Scatter-Options for Variables
		if "`varmstyle'" == "" {
			local varmstyle "p1"
		}
		if "`varmsymbol'" == "" {
			local varmsymbol "i"
		}
		if "`varmcolor'" != "" {
			local varmcolor "mcolor(`varmcolor')"
		}
		if "`varmsize'" != "" {
			local varmsize "msize(`varmsize')"
		}
		if "`varmlabel'" == "" {
			local i 1
			gen  str `names' = ""  
			foreach var of local varlist {
				replace `names' = "`var'" in `i++' 
			}
			local varmlabel "`names'"
		}
		if "`varmlabstyle'" == "" {
			local varmlabstyle "`varmstyle'"
		}
		if "`varmlabposition'" != "" {
			local varmlabpostion "mlabposistion(`varmlabposition')"
		}
		if "`varmlabvposition'" == "" {
			tempname clock
			tempvar mlabpos
			foreach axis in Y X {
		 		tempvar H`axis'g
				sum `H`axis'' `if' `in', meanonly
				gen `H`axis'g' = 1 ///
				  if inrange(`H`axis'',r(min),r(min)/5*3)
				replace `H`axis'g' = 2 ///
				  if inrange(`H`axis'',r(min)/5*3,r(min)/5)
				replace `H`axis'g' = 3 ///
				  if inrange(`H`axis'',r(min)/5,r(max)/5)
				replace `H`axis'g' = 4 ///
				  if inrange(`H`axis'',r(max)/5,r(max)/5*3)
				replace `H`axis'g' = 5 ///
				  if inrange(`H`axis'',r(max)/5*3,r(max))
			}   
                	matrix input `clock' = ///
                 		        (11 12 12 12  1 \\ ///
               		         10 11 12  1  2 \\ ///
               		          9  9 12  3  3 \\ ///
               		          8  7  6  5  4 \\ ///
               		          7  6  6  6  5 )
                        gen `mlabpos' = .
                        forv i=1/5 {
	                	forv j=1/5 {
	                		replace `mlabpos' = `clock'[`i',`j'] ///
	                		  if (5 -`HYg') +1  == `i' & `HXg' == `j'
	                	}
	                }
	                local varmlabvposition "`mlabpos'"
		}
		if "`varmlabgap'" != "" {
			local varmlabgap ".1"
		}
		if "`varmlabsize'" != "" {
			local varmlabsize "mlabsize(`varmlabsize')"
		}
		if "`varmlabcolor'" != "" {
			local varmlabcolor "mlabcolor(`varmlabcolor')"
		}
		local varopt "mstyle(`varmstyle') msymbol(`varmsymbol') mlabstyle(`varmlabstyle') `varmcolor'"
		local varopt "`varopt' `varmsize'  mlabel(`varmlabel')"
		local varopt "`varopt' mlabvpos(`varmlabvposition')" 
		local varopt "`varopt' mlabgap(`varmlabgap') `varmlabsize'"
		local varopt "`varopt' `varmlabcolor'"
		

		// Line Options
		// ------------
		
		if "`clstyle'" == "" {
		   local clstyle "`varmstyle'"
		}
		if "`clpattern'" != "" {
			local clpattern "clpattern(`clpattern')"
	        }
          	if "`clwidth'" != "" {
          		local clwidth "clwidth(`clwidth')"
          	}
          	if "`clcolor'" != "" {
          		local clcolor "clcolor(`clcolor')"
          	}
		local lineopt "clstyle(`clstyle') `clcolor' `clpattern' `clwidth'"

		// Ops-only Options
		// -----------------
		
		if "`jitter'" ~= "" {
			local jitter "jitter(`jitter')"
      }
		local obsonlyopt "`jitter'"

		// Twoway-Options
		// --------------

		if "`xscale'" == "" {
			local xscale  "range(`min' `max')"
		}
		if "`yscale'" == "" {
			local yscale  "range(`min' `max')"
		}
		if "`xlabel'" == "" {
			local xlabel  "#5" 
		}
		if "`ylabel'" == "" {
			local ylabel  "#5"
		}
		if "`l1title'" == "" {
			local l1title "DIM `dim2' (`explvar2' % of Var)"
		}
		if "`b2title'" == "" {
			local b2title "DIM `dim1' (`explvar1' % of Var)"
		}
	
		// Make Command(s) for Observation-Part
		// ------------------------------------
		
		if "`subpop'" == "" {
			local obspart "(scatter `GY' `GX', `obsopt' `obsonlyopt')"
			if "`legend'" == "" {
				local legend "legend(off)"
			}
		}
		else {
			gettoken subpop subpopopt: subpop, parse(,)
			local subpopopt: subinstr local subpopopt "," "" 
			levels `subpop' if `touse', local(SUBPOP)
			local i 1
			foreach c of local SUBPOP {
				tempvar GY_`c'
				gen `GY_`c'' = `GY' if `subpop' == `c'
				local labsup: label (`subpop') `c'
				lab var `GY_`c'' "`labsup'"
				local subvars "`subvars' `GY_`c''"
				local order "`order' `i++'"
			}
			local legend "legend(order(`order') `legend')"
			local obspart "(scatter `subvars' `GX', `subpopopt' `legend')"
		}


		// Make Commands for Line-Part
		// ----------------------------
		
		forv i=1/`k' {
			tempvar hy`i' hx`i'
			gen `hy`i'' = `HY'[`i'] in 1
			replace `hy`i'' = 0 in 2
			gen `hx`i'' = `HX'[`i'] in 1
			replace `hx`i'' = 0 in 2
			local linepart ///
			"`linepart' (line `hy`i'' `hx`i'', `lineopt')"
		}
		
		// Make Command for Line-Labels
		// ----------------------------

		local linelabelpart "(scatter `HY' `HX', `varopt')"
	}
	
   // PCS- or PCL-Plot
   if "`varonly'"  ~= "" {
       local obspart ""
   }
   if "`obsonly'" ~= ""  {
       local linepart ""
       local linelabelpart ""
   }

	// Graph 
   // -----

	graph twoway /// 
		`obspart' `linepart' `linelabelpart',  /// 
	  	l1title(`l1title') b2title(`b2title') ///
		xscale(`xscale') yscale(`yscale') ///
		ylabel(`xlabel') xlabel(`xlabel') ///
		`legend' `scheme' `xsize' `options' 


// Store Results

if "`generate'" != "" {
  quietly gen `obsvar'_x = `GX'
  quietly gen `obsvar'_y = `GY'
  quietly gen `varvar'_x = `HX'
  quietly gen `varvar'_y = `HY'
}

return scalar k = `k'
return scalar N = `n'
return scalar expldim1 = `explvar1'
return scalar expldim2 = `explvar2'

matrix colnames `Lout' = `varlist'
return matrix L = `Lout'
matrix rownames `Vout' = `varlist'
return matrix V=`Vout'

end

exit

Bug-reports to kohler@wz-berlin.de

	
