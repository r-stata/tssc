*! 1.0.0 MLB 13Okt2010
program define scenreg
	version 11
	if replay() {
		if (`"`e(cmd)'"' != "sensreg") error 301
		Replay `0'
	}
	else Estimate `0'
end

program Estimate, eclass
	syntax varlist [if] [in]         ///
	       [fweight pweight],        ///
	       sd(string)                ///
     	   [                         ///
		   link(string)              ///
		   family(string)            /// undocumented, for now only binomial allowed
		   dist(string)              ///
		   rho(string)               ///
		   eclear                    ///
		   noLOg noCONStant          ///
           VCE(passthru)             ///
           Robust                    /// old options
		   CLuster(passthru)         /// old options
		   draws(integer 100)        ///
		   start(integer 15)         ///
		   Level(integer `c(level)') ///
		   OR HR RR                  ///  
		   *                         ///
		   ]
	
	macro drop S_*
	gettoken y x : varlist
	
    // parse vce	   
    local vceopt =  `:length local vce'             |       ///
                    `:length local weight'          |       ///
                    `:length local cluster'         |       ///
                    `:length local robust'
    if `vceopt' {
        _vce_parse, argopt(CLuster) opt(OIM OPG Robust) old     ///
                   : [`weight'`exp'], `vce' `robust' `cluster'
        local vce
        if "`r(cluster)'" != "" {
            local clustvar `r(cluster)'
            local vce vce(cluster `r(cluster)')
        }
        else if "`r(robust)'" != "" {
            local vce vce(robust)
        }
        else if "`r(vce)'" != "" {
            local vce vce(`r(vce)')
        }
    }
	
	// mark estimation sample
	marksample touse
    if `:length local clustvar' {
        markout `touse' `clustvar', strok
    }
	qui count if `touse'
	if r(N) == 0 {
		error 2000
	}
	
   // weights
   if "`weight'" != "" local wgt `"[`weight'`exp']"'  
   if "`weight'" == "pweight" local sumwgt `"[aweight`exp']"'  
   
	// parse sd 
	tempvar sdvar
	capture gen double `sdvar' = `sd'
	if _rc {
		di as err "invalid expression specified in option sd()"
		exit _rc
	}
	capture assert `sdvar' >= 0 & `sdvar' <= 20
	if _rc {
		di as err "sd must result in numbers between 0 and 20"
		exit 198
	}
	global S_sd "`sdvar'"

	// parse dist
	gettoken dist pr : dist
    local l = max(4, length("`dist'"))
	local dist = lower("`dist'")  // makes sense to allow one to specify the Gaussian distribution
                                  // instead of the gaussian distribution
    if "`dist'" == substr("normal", 1, `l')  |  /// 
       "`dist'" == substr("gaussian", 1, `l') | ///
	   "`dist'" == "" {  
		global S_dist normal 
    }
	else if "`dist'" == substr("uniform", 1, `l') {
		global S_dist uniform
	}
	else if "`dist'" == substr("discrete", 1, `l') {
		global S_dist discrete
		
		// parse the probabilities and attach the mass points
		local ok = 1
		if `: word count `pr'' < 2 {
			local ok = 0
		}
		foreach p of local pr {
			capture confirm number `p'
			if _rc {
				local ok = 0
			}
			if `p' < 0 {
				local ok = 0
			}
		}
		tempname mpnts
		// This function creates equally spaced masspoints such that mean(e) = 0 & sd(e) = 1
		// Leaves these masspoints behind in $S_mpnts and matrix `mpnts'
		// Leaves pr behind in $S_pr
		// Leaves the sum of pr behind in local sum_pr
		if `ok' {
			mata masspoints()
		}
		
		if abs(`sum_pr' - 1) > .01 {
			local ok = 0
		}
		if !`ok' {
			di as err "when specifying discrete in dist() it must be followed by two or more positive numbers adding up to 1"
			exit 198
		}
		
		// make matrix pretty for later display
		matrix rownames `mpnts' = "mass_point" "proportion"
		forvalues i = 1/ `:word count `pr'' {
			local coln = `"`coln' "point_`i'""'
		}
		matrix colnames `mpnts' = `coln'
		local mpntsopt "mpnts(`mpnts')"

	}
	else {
		di as err "only normal, gaussian, uniform, or discrete are allowed in -dist()-"
		exit 198
	}
	
	// parse rho
	if "`rho'" != "" {
		if `: word count `rho'' != 2 {
			di as err "the rho option must contain one variable and one correlation"
			exit 198
		}
		gettoken var rho : rho
		if !`: list var in x' {
			di as err "the first element in rho must be one of the explanatory variables"
			exit 198
		}
		global S_rhovar "`var'"
		capture confirm number `rho'
		if _rc {
			di as err "the second element in rho must be one number between -.9 and .9"
			exit 198
		}
		if `rho' < -.9 | `rho' > .9 {
			di as err "the second element in rho must be one number between -.9 and .9"
			exit 198
		}
		global S_rho `rho'
		qui sum $S_rhovar if `touse' `sumwgt'
		global S_sdx = r(sd)
		global S_mx  = r(mean)
	}
	else {
		global S_rho = .
		global S_sdx = .
		global S_mx  = .
	}
	
	// check draws and start
	if `draws' <= 0 | `draws' > 1000 {
		di as err "draws must be an integer between 0 and 1000"
		exit 198
	}
	global S_draws = `draws'
	if `start' < 0  {
		di as err "start must be a positive integer"
		exit 198
	}
    global S_start = `start'

	//parse link
	local l = max(4,length("`link'"))
	if "`link'" == "" | "`link'" == substr("logit",1,`l') {
		global S_link logit
	}
	else if "`link'" == substr("identity", 1, `l'){
		global S_link identity
	}
	else if "`link'" == substr("probit",1,`l') {
		global S_link probit
	} 
	else if "`link'" == substr("cloglog", 1, `l') {
		global S_link cloglog
	}
	else if "`link'" == substr("loglog",1,`l') {
		global S_link loglog
	} 
	else if "`link'" == "log" {
		global S_link log
	}
	else {
		di as err "unrecognized link: `link'"
		exit 198
	}

	// parse eform options
	opts_exclusive "`hr' `or' `rr'"

	// make sure the name of the eform option makes sense given the link function	
	if "`hr'" != "" & "$S_link" != "cloglog" {
		di as err "the hr option is only allowed in combination with the cloglog link function"
		exit 198
	}
	if "`or'" != "" & "$S_link" != "logit" {
		di as err "the or option is only allowed in combination with the logit link function"
		exit 198
	}
	if "`rr'" != "" & "$S_link" != "log" {
		di as err "the rr option is only allowed in combination with the log link function"
		exit 198
	}
	if "`rr'" != "" {
		local `rr' "eform(Risk Ratio)"
	}

/*	
for now only binomial family allowed
reason is that the standard errors in the other families did not perform well in simulations


	if "`family'" == "" {
		if "$S_link" == "logit" | "$S_link" == "probit" | "$S_link" == "cloglog" | "$S_link" == "loglog"  {
			global S_family binomial
		}
		if "$S_link" == "log" {
			global S_family poisson
		}
		if "$S_link" == "identity" {
			global S_family gaussian
		}
	}
	local l = max(4, length("`family'"))
	else if "`family'" == substr("gaussian", 1, `l') | ///
	        "`family'" == substr("normal", 1, `l') {
		global S_family gaussian
		local sigma /ln_sigma
	}
	else if "`family'" == substr("binomial", 1, `l') {
		global S_family binomial
	}
	else if "`family'" == substr("poisson", 1, `l') {
		global S_family poisson
	}
	else {
		di as err "unrecognized family: `family'"
		exit 198
	}
*/
	global S_family binomial

	// check and collect -ml- and display options
   _get_diopts diopts options, `options'
   local diopts `diopts' level(`level') `or' `hr' `rr'

   mlopts mlopts, `options'

   // display/suppress itteration log
   local log = cond("`log'" == "", "noisily", "quietly")

	qui count if `touse'
	local N = r(N)
   
  
	// initial values
	qui glm `y' `x' `wgt' if `touse', `constant' link($S_link) family($S_family) iter(20)
	tempname b0
	matrix `b0' = e(b)
	matrix coleq `b0' = ""
	
    // make the samples from the "unobserved variable"
    mata: mk_e(`N', $S_draws, $S_start, "$S_sd", "`touse'", "$S_dist", ///
	           "$S_pr", "$S_mpnts",  $S_rho, "$S_rhovar", $S_sdx, $S_mx, "`eclear'")
	
	// full model
	`log' ml model lf scenreg_lf          ///
	         (xb : `y' = `x', `constant') ///
			 `sigma'                      /// will only occur with the normal family, which is now not allowed
			 `wgt' if `touse',            ///
			 `mlopts' `vce' maximize init(`b0') search(off) 
    
	ereturn local title "scenario model, link($S_link) family($S_family)"
	ereturn local link "$S_link"
	ereturn local family "$S_family"
	ereturn local cmd "scenreg"
	ereturn local sd "`sd'"
	if "$S_rhovar" != "" {
		ereturn scalar rho = $S_rho
		ereturn local rhovar "$S_rhovar"
	}
	ereturn local dist "$S_dist"
	if "$S_dist" == "discrete" {
		ereturn matrix mpnts `mpnts'
	}
	
	// clean up
	mata: rmexternal("S_unobserved_variable")
 
    Replay , `diopts'
end

program Replay
        syntax [, sd(string) mpnts(name) *]
        ml display, `options'
		di _n
		di as txt "Scenario:"
		di as txt "Unobserved variable is " as result "${S_dist}ly" as txt " distributed"
		if "$S_dist" == "discrete" {
			di as txt "The mass points and probabilities of the standardized unobserved variable are:"
			matlist e(mpnts), format(%7.3g)
			di _n
		}
		di as txt "The effect of the standardized unobserved variable is " as result "`e(sd)'"
		if "`e(rhovar)'" != "" {
			di as txt "The corelation between " as result "`e(rhovar)'" as txt " and the unobserved variable is " as result `e(rho)'
		}
end
	
/*----------- computes mass points when the discrete distribution is specified*/
mata:
void masspoints() {
	real matrix pr, mpnts
	real scalar Np, i
	string scalar str_mpnts
	pr = strtoreal(tokens(st_local("pr")))

	// initial guesses for mpnts
	// centered around 0, each category 1 appart
	Np = length(pr)
	mpnts = (1..Np):- (Np+1)/2


	// pr*mpnts' is the mean
	mpnts = mpnts :- (pr*mpnts')

	// pr*(mpnts :* mpnts)' is the variance
	mpnts = mpnts :/ sqrt(pr*(mpnts :* mpnts)')
	
	// return results
	str_mpnts = strofreal(mpnts[1])
	for(i=2; i<= length(mpnts); i++){
		str_mpnts = str_mpnts + " " + strofreal(mpnts[i])
	} 
	st_global("S_mpnts", str_mpnts)
	st_global("S_pr", st_local("pr"))
	st_matrix(st_local("mpnts"), mpnts \ pr)
	
	// return sum of pr to check if adds up to 1
	st_local("sum_pr", strofreal(sum(pr)))
}

// ---------------------------- make unobserved variable
void mk_e( real   scalar N,
           real   scalar draws,
	       real   scalar start,
		   string scalar sdname, 
           string scalar mlsamp,
		   string scalar dist,
		   string scalar prstr, 
		   string scalar mpntsstr,
		   real   scalar rho,
		   string scalar rhovar,
		   real   scalar sdx,
		   real   scalar mx,
		   string scalar eclear) {
	
	pointer(real matrix) scalar e 
    if ( (e = findexternal("S_unobserved_variable")) == NULL) {
        e = crexternal("S_unobserved_variable")
    }
	else if (eclear == "") {
		_error("external global matrix S_unobserved_variables already exist, specify the eclear option if you want to replace it")
	}
    else {
        rmexternal("S_unobserved_variable")
		e = crexternal("S_unobserved_variable")
    }
    
	real matrix ee, sd

	// create standardized distribution
	if (dist == "uniform") {
		ee = ( (halton(draws*N, 1, start) :- .5) :/ sqrt(1/12) )
	}
	else if (dist == "normal") {
		ee = invnormal(halton(draws*N, 1, start))
	}
	else if (dist == "discrete") {
		real matrix u, pr, mpnts
		real scalar cumpr, prev_cumpr, i
		
		pr = strtoreal(tokens(prstr))
		mpnts = strtoreal(tokens(mpntsstr))
		
		u = halton(draws*N, 1, start)
		ee = J(draws*N,1,0)
		cumpr = 0
		for (i = 1; i <= length(pr); i++){
			prev_cumpr = cumpr
			cumpr = cumpr + pr[i]
			ee = ee :+ ( (u:<cumpr):&(u:>=prev_cumpr) ) :* mpnts[i]
		}
	}
	
	// add correlation 
	ee = colshape(ee,draws)
	if (rhovar != "") {
		real matrix x
		st_view(x,.,rhovar,mlsamp)
		ee = (rho:*(x :- mx):/sdx :+ sqrt(1-rho^2):*ee)
	}
	
	// add standard deviation
	st_view(sd, ., sdname, mlsamp)
	ee = sd :* ee
	*e = ee
}	
end
