
prog fraclogit, eclass
// fractional logit regression of Wedderburn (1974)
// Dan Powers
// Dept. Sociology and Population Research Center
// University of Texas at Austin
// DAP 10/12/12 (incoporating suggestions by MLB) 
// DAP 8/12/12
  version 12.0
    if !replay() {
	syntax varlist(min=1 numeric fv) [if] [in] [fw pw iw aw] [,  EFOrm Level(integer `c(level)')]
    local fvops = "`s(fvops)'" == "true" | _caller() >= 11
    marksample touse 
    gettoken y xvars: varlist		
    local wtype `weight'
    local wtexp `"`exp'"'
    if "`weight'" != "" local wgt `"[`weight'`exp']"'  
	
	tempname p q z v eta db ll x2
	
	// check on data bounds
	qui count if ( `y' < 0 | `y' > 1 ) & `touse'
	 if r(N) > 0 {
     di as txt "`r(N)' observations are less than 0 or more than 1, these will be ignored"
	   }
     qui replace `touse' = 0 if ( `y' < 0 | `y' > 1 ) 

	qui glm `y' `xvars' `wgt' if `touse', f(b) 	
	qui predict double `eta' if `touse', xb
	qui gen double `p' = invlogit(`eta') if `touse'
    qui gen double `q' = invlogit(-`eta') if `touse'
	qui gen double `v' = `p' * `q' if `touse'
	qui gen double `z' = `eta' + (`y' - `p')/`v' if `touse'

// iteration 0
	// iteration loop (replace with Newton-Raphson soon)
	    scal `ll' = e(deviance)
		scal `db' = 1
	    local iter = 0
		   while (`db' > 1.e-5 & `iter' < 50) {
		qui glm `z' `xvars' `wgt' if `touse'
		qui drop `eta'
		qui predict double `eta' if `touse', xb
		qui replace `p' = invlogit(`eta')
		qui replace `q' = invlogit(-`eta')
		// something bad happens if p is on the boundary so bail out with a logit model
		qui count if (`p' == 0 | `p' == 1 ) & `touse' 
		if r(N) > 0 {
		qui replace `p' = cond(`p'==0, .001, `p') 
		qui replace `p' = cond(`p'==1, .999, `p') 
		di as txt "`r(N)' predictions are less than 0 or more than 1, recoding to boundary and switching to glm"
		qui glm `y' `xvars' `wgt', f(b) robust
		 }
		qui replace `v' = `p' * `q'
		qui replace `z' = `eta' + (`y' - `p')/`v'
		cap drop `x2'
		qui egen double `x2' = total( ((`y' - `p')*(`y' - `p')) / ((`p'*`q')*(`p'*`q'))  ) if `touse'
		scal `db' = abs((`ll' - e(deviance))/`ll')
		scal `ll' = e(deviance)
		local iter = `iter' + 1
		// di `iter'
		// di `ll'
		// di `db'
		// di `x2'
      }

	
// format the results for posting and display

  tempname b V 
	matrix `b' = e(b)
	matrix `V' = e(V)
	local   N  = e(N)   
	local  df  = e(k)
	local dev  = `x2'
	local rmse = e(dispers)
	local cname : colnames e(b)
	mat colnames `b' = `cname'
	mat rownames `V' = `cname'
	mat colnames `V' = `cname'
	mat coleq `b' = ""
	mat coleq `V' = ""
	mat roweq `V' = ""
ereturn post `b' `V', depname(`1') obs(`N') esample(`touse')
tokenize "`varlist'" 
ereturn local depvar "`1'"  
ereturn scalar df   = `df'   // note: this is number of parameters
ereturn scalar dev   = `dev'  
ereturn scalar rmse = `rmse'
ereturn local cmd = "fraclogit"

}
else { // replay
    syntax [, Level(integer `c(level)') EForm]
	}
	
if "`e(cmd)'" != "fraclogit" error 301
if `level' < 10 | `level' > 99 {
   di as err "level() must be between 10 and 99 inclusive"
   exit 198
   }
  
  if "`eform'"!="" {
		local eopt "eform(or)"
		
	}
	
    
 di as text "{hline 11}{c +}{hline 65}"
 di %10s as text "fractional logit results "    as text %45s   " Obs  = "   as res %-7.0f e(N)
 di %10s as text "                         "    as text %45s   " rmse = "   as res %-7.5f e(rmse)
 di %10s as text "                         "    as text %45s   " df   = "   as res %-7.0f e(df)
 di %10s as text "                         "    as text %45s   " pearson  = "   as res %-7.3f e(dev)
 
 ereturn display, level(`level') `eopt'
 end
 


