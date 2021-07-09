*! v 2.0.0 N.Orsini 17sep2007 Probabilistic Sensitivity Analysis
*! v 1.0.0 N.Orsini 01mar2007 Deterministic Sensitivity Analysis

capture program drop episens
program  episens, rclass
version 9.2
syntax varlist(min=2 max=3) [if] [in] [fw] [ , /// 
DPExp(string) DPUnexp(string  ) DRRcd(string) DORce(string)   /// Unmeasured confounding bias parameters - distribution of values
CORRPrev(string)                          	      	   /// Correlation of prevalences of the confounder among the exposed and unexposed
DSECa(string) DSPCa(string  )  DSENc(string) DSPNc(string)   /// Misclassification of the exposure - distribution of values
CORRSEns(string) CORRSPec(string)				       	/// Correlation of sensitivities and specificities among cases and non-cases
DPSCEx(string) DPSCUn(string)  DPSNEx(string) DPSNUn(string) DSBFactor(string)  /// Selection bias - distribution of values
ndraw(integer 1000) reps(integer 2000) seed(string) NOdots saving(string) /// Monte-Carlo simulations parameters
GRPrior GRARRSys GRARRTot /// Graph priors and adjusted RR (systematic and systematic plus random error)
Format(string) STudy(string) COrder(string) COMBined *  ]

	tokenize `varlist'
	local cas `1'
	local ex `2'
	local tim `3'

	marksample use

// get the dataset name

gettoken dataname  :  saving  , parse(",") match(par)  

* di as text "`dataname'"

// check display format

	if "`format'" == "" {
		local fmt = "%3.2f"
	}   
	else {
		local fmt = "`format'"
	} 

// check type of study

	if "`study'" == "" {
		local type = "cc"
	}   
	else {
		local type = "`study'"
	} 

	if "`tim'" != "" {
		local type = "ir"
	}   

	if inlist("`type'", "cc", "ir", "cs") != 1 {
		di in red "specify cc, ir, or cs for the option study()"
		exit 198
	} 

// case-control and cumulative incidence data

	if inlist("`type'", "cc", "cs")==1 {

		quietly { 
				tempvar WGT one
				quietly gen byte `one'=1

 			if `"`weight'"'!="" { 
				qui gen double `WGT' `exp' if `use'
				local w "[fweight=`WGT']"
			}

			safesum `one' `w' if `cas' & `ex' & `use'
			local a=r(sum)
			safesum `one' `w' if `cas' & `ex'==0 & `use'
			local b=r(sum)
			safesum `one' `w' if `cas'==0 & `ex' & `use'
			local c=r(sum)
			safesum `one' `w' if `cas'==0 & `ex'==0 & `use'
			local d=r(sum)
		}
	}

// incidence rate data

	if "`type'" == "ir" {
		quietly { 
			sum `cas' `weight' if `ex' & `use'
			local a=int(r(N)*r(mean)+.5)
			sum `tim' `weight' if `ex' & `use'
			local c = r(N)*r(mean)
			sum `cas' `weight' if `ex'==0 & `use'
			local b=int(r(N)*r(mean)+.5)
			sum `tim' `weight' if `ex'==0 & `use'
			local d= r(N)*r(mean)
		}
	}

	*di " `a'  `b'  `c'  `d'"

	confirm integer number `a'
	confirm integer number `b'
	confirm integer number `c'
	confirm integer number `d'

	if `a'<0 | `b'<0 | `c'<0 | `d'<0 { 
		di in red "negative numbers invalid"
		exit 498
	}

// sum of the cases and non-cases

local m1 = `a' + `b'
local m0 = `c' + `d'

// Get the user-specified bias parameters

di ""

// Misclassification of the exposure - distribution of values

if "`dseca'" != "" {
	check_dist_bp , dist(`dseca')

	local name_dist_seca = "`r(distribution_bp)'"
	local ns_seca = "`r(distribution_ns)'" 
	
	if "`name_dist_seca'" == "Constant" {
	tempname c_dseca  
	scalar `c_dseca' = r(c)
	di  as text "Se|Cases   : " as res "`name_dist_seca'(" `c_dseca' ")"
	}

	if "`name_dist_seca'" == "Uniform" {
	tempname a_dseca b_dseca
	scalar `a_dseca' = r(a)
	scalar `b_dseca' = r(b)
	di  as text "Se|Cases   : " as res "`name_dist_seca'(" `a_dseca' "," `b_dseca' ")"
	}

	if inlist("`name_dist_seca'", "Triangular", "Trapezoidal") == 1 {
	tempname a_dseca b_dseca c_dseca d_dseca
	scalar `a_dseca' = r(a)
	scalar `b_dseca' = r(b)
	scalar `c_dseca' = r(c)
	scalar `d_dseca' = r(d)
	if inlist("`name_dist_seca'", "Triangular") == 1  di  as text "Se|Cases   : " as res "`name_dist_seca'("  `a_dseca' "," `b_dseca' "," `d_dseca' ")"
	if inlist("`name_dist_seca'", "Trapezoidal") == 1 di  as text "Se|Cases   : " as res "`name_dist_seca'(" `a_dseca' "," `b_dseca' "," `c_dseca' "," `d_dseca' ")"
	}	

	if inlist("`name_dist_seca'", "Logit-Logistic", "Logit-Normal") == 1 {

	tempname m_dseca s_dseca lb_dseca ub_dseca
	scalar `m_dseca' = r(m)	
	scalar `s_dseca' = r(s)	
	scalar `lb_dseca' = r(lb)	
	scalar `ub_dseca' = r(ub)		

	if r(boundaries) == 0 {
					di as text "Se|Cases   : " as res  "`name_dist_seca'(" `fmt' `m_dseca' "," `fmt' `s_dseca' ")"
	}
	else {
		 di as text "Se|Cases   : " as res  "`name_dist_seca'(" `fmt' `m_dseca' "," `fmt' `s_dseca' ")  Bound(" `lb_dseca' "," `ub_dseca' ")"	
	}

	}

}


if "`dspca'" != "" {
	check_dist_bp , dist(`dspca')
	local name_dist_spca = "`r(distribution_bp)'"
	local ns_spca = "`r(distribution_ns)'" 

	if "`name_dist_spca'" == "Constant" {
	tempname c_dspca  
	scalar `c_dspca' = r(c)
	di  as text "Sp|Cases   : " as res "`name_dist_spca'(" `c_dspca' ")"
	}

	if "`name_dist_spca'" == "Uniform" {
	tempname a_dspca b_dspca
	scalar `a_dspca' = r(a)
	scalar `b_dspca' = r(b)
	di  as text "Sp|Cases   : " as res "`name_dist_spca'(" `a_dspca' "," `b_dspca' ")"
	}

	if inlist("`name_dist_spca'", "Triangular", "Trapezoidal") == 1 {
	tempname a_dspca b_dspca c_dspca d_dspca
	scalar `a_dspca' = r(a)
	scalar `b_dspca' = r(b)
	scalar `c_dspca' = r(c)
	scalar `d_dspca' = r(d)
	if inlist("`name_dist_spca'", "Triangular") == 1  di  as text "Sp|Cases   : " as res "`name_dist_spca'("  `a_dspca' "," `b_dspca' "," `d_dspca' ")"
	if inlist("`name_dist_spca'", "Trapezoidal") == 1 di  as text "Sp|Cases   : " as res "`name_dist_spca'(" `a_dspca' "," `b_dspca' "," `c_dspca' "," `d_dspca' ")"
	}	

	if inlist("`name_dist_spca'", "Logit-Logistic", "Logit-Normal") == 1 {

	tempname m_dspca s_dspca lb_dspca ub_dspca
	scalar `m_dspca' = r(m)	
	scalar `s_dspca' = r(s)	
	scalar `lb_dspca' = r(lb)	
	scalar `ub_dspca' = r(ub)		

	if r(boundaries) == 0 {
					di as text "Sp|Cases   : " as res  "`name_dist_spca'(" `fmt' `m_dspca' "," `fmt' `s_dspca' ")"
	}
	else {
		 di as text "Sp|Cases   : " as res  "`name_dist_spca'(" `fmt' `m_dspca' "," `fmt' `s_dspca' ")  Bound(" `lb_dspca' "," `ub_dspca' ")"	
	}

	}
}


if "`dsenc'" != "" {
	check_dist_bp , dist(`dsenc')
	local name_dist_senc = "`r(distribution_bp)'"
	local ns_senc = "`r(distribution_ns)'" 

	if "`name_dist_senc'" == "Constant" {
	tempname c_dsenc  
	scalar `c_dsenc' = r(c)
	di  as text "Se|No-Cases: " as res "`name_dist_senc'(" `c_dsenc' ")"
	}

	if "`name_dist_senc'" == "Uniform" {
	tempname a_dsenc b_dsenc
	scalar `a_dsenc' = r(a)
	scalar `b_dsenc' = r(b)
	di  as text "Se|No-Cases: " as res "`name_dist_senc'(" `a_dsenc' "," `b_dsenc' ")"
	}

	if inlist("`name_dist_senc'", "Triangular", "Trapezoidal") == 1 {
	tempname a_dsenc b_dsenc c_dsenc d_dsenc
	scalar `a_dsenc' = r(a)
	scalar `b_dsenc' = r(b)
	scalar `c_dsenc' = r(c)
	scalar `d_dsenc' = r(d)
	if inlist("`name_dist_senc'", "Triangular") == 1  di  as text "Se|No-Cases: " as res "`name_dist_senc'("  `a_dsenc' "," `b_dsenc' "," `d_dsenc' ")"
	if inlist("`name_dist_senc'", "Trapezoidal") == 1 di  as text "Se|No-Cases: " as res "`name_dist_senc'(" `a_dsenc' "," `b_dsenc' "," `c_dsenc' "," `d_dsenc' ")"
	}	

	if inlist("`name_dist_senc'", "Logit-Logistic", "Logit-Normal") == 1 {

	tempname m_dsenc s_dsenc lb_dsenc ub_dsenc
	scalar `m_dsenc' = r(m)	
	scalar `s_dsenc' = r(s)	
	scalar `lb_dsenc' = r(lb)	
	scalar `ub_dsenc' = r(ub)		

	if r(boundaries) == 0 {
					di as text "Se|No-Cases: " as res  "`name_dist_senc'(" `fmt' `m_dsenc' "," `fmt' `s_dsenc' ")"
	}
	else {
		 di as text "Se|No-Cases: " as res  "`name_dist_senc'(" `fmt' `m_dsenc' "," `fmt' `s_dsenc' ")  Bound(" `lb_dsenc' "," `ub_dsenc' ")"	
	}

	}

}
 

if "`dspnc'" != "" {
	check_dist_bp , dist(`dspnc')
	
	local name_dist_spnc = "`r(distribution_bp)'"
	local ns_spnc = "`r(distribution_ns)'" 

	if "`name_dist_spnc'" == "Constant" {
	tempname c_dspnc  
	scalar `c_dspnc' = r(c)
	di  as text "Sp|No-Cases: " as res "`name_dist_spnc'(" `c_dspnc' ")"
	}

	if "`name_dist_spnc'" == "Uniform" {
	tempname a_dspnc b_dspnc
	scalar `a_dspnc' = r(a)
	scalar `b_dspnc' = r(b)
	di  as text "Sp|No-Cases: " as res "`name_dist_spnc'(" `a_dspnc' "," `b_dspnc' ")"
	}

	if inlist("`name_dist_spnc'", "Triangular", "Trapezoidal") == 1 {
	tempname a_dspnc b_dspnc c_dspnc d_dspnc
	scalar `a_dspnc' = r(a)
	scalar `b_dspnc' = r(b)
	scalar `c_dspnc' = r(c)
	scalar `d_dspnc' = r(d)
	if inlist("`name_dist_spnc'", "Triangular") == 1  di  as text "Sp|No-Cases: " as res "`name_dist_spnc'("  `a_dspnc' "," `b_dspnc' "," `d_dspnc' ")"
	if inlist("`name_dist_spnc'", "Trapezoidal") == 1 di  as text "Sp|No-Cases: " as res "`name_dist_spnc'(" `a_dspnc' "," `b_dspnc' "," `c_dspnc' "," `d_dspnc' ")"
	}	

	if inlist("`name_dist_spnc'", "Logit-Logistic", "Logit-Normal") == 1 {

	tempname m_dspnc s_dspnc lb_dspnc ub_dspnc
	scalar `m_dspnc' = r(m)	
	scalar `s_dspnc' = r(s)	
	scalar `lb_dspnc' = r(lb)	
	scalar `ub_dspnc' = r(ub)		

	if r(boundaries) == 0 {
					di as text "Sp|No-Cases: " as res  "`name_dist_spnc'(" `fmt' `m_dspnc' "," `fmt' `s_dspnc' ")"
	}
	else {
		 di as text "Sp|No-Cases: " as res  "`name_dist_spnc'(" `fmt' `m_dspnc' "," `fmt' `s_dspnc' ")  Bound(" `lb_dspnc' "," `ub_dspnc' ")"	
	}

	}

}

// Get the correlations of sensitivities and specificities among cases and non-cases

	if "`corrsens'" != "" {
	
		if inrange(`corrsens',0,1) == 1 {
			tempname c_sens
			scalar `c_sens' = `corrsens'
			di as text "Corr Se|Cases and Se|No-Cases : " as res `c_sens'
		}
		else {
			di as err "Specify correctly the correlation (0,1) among sensitivities"	
			exit 198	
		}

	}

	if "`corrspec'" != "" {
	
		if inrange(`corrspec',0,1) == 1 {
			tempname c_spec
			scalar `c_spec' = `corrspec'
			di as text "Corr Sp|Cases and Sp|No-Cases : " as res `c_spec'
		}
		else {
			di as err "Specify correctly the correlation (0,1) among specificities"	
			exit 198	
		}

	}

// Selection biases - distribution of values

if "`dpscex'" != "" {
	check_dist_bp , dist(`dpscex')

	local name_dist_pscex = "`r(distribution_bp)'"
	local ns_pscex = "`r(distribution_ns)'" 
	
	if "`name_dist_pscex'" == "Constant" {
	tempname c_dpscex  
	scalar `c_dpscex' = r(c)
	di  as text "Pr Case Selection Exposed: " as res "`name_dist_pscex'(" `c_dpscex' ")"
	}

	if "`name_dist_pscex'" == "Uniform" {
	tempname a_dpscex b_dpscex
	scalar `a_dpscex' = r(a)
	scalar `b_dpscex' = r(b)
	di  as text "Pr Case Selection Exposed: " as res "`name_dist_pexp'(" `a_dpscex' "," `b_dpscex' ")"
	}

	if inlist("`name_dist_pscex'", "Triangular", "Trapezoidal") == 1 {
	tempname a_dpscex b_dpscex c_dpscex d_dpscex
	scalar `a_dpscex' = r(a)
	scalar `b_dpscex' = r(b)
	scalar `c_dpscex' = r(c)
	scalar `d_dpscex' = r(d)
	if inlist("`name_dist_pscex'", "Triangular") == 1  di  as text "Pr Case Selection Exposed: " as res "`name_dist_pscex'("  `a_dpscex' "," `b_dpscex' "," `d_dpscex' ")"
	if inlist("`name_dist_pscex'", "Trapezoidal") == 1 di  as text "Pr Case Selection Exposed: " as res "`name_dist_pscex'(" `a_dpscex' "," `b_dpscex' "," `c_dpscex' "," `d_dpscex' ")"
	}	

	if inlist("`name_dist_pscex'", "Logit-Logistic", "Logit-Normal") == 1 {

	tempname m_dpscex s_dpscex lb_dpscex ub_dpscex
	scalar `m_dpscex' = r(m)	
	scalar `s_dpscex' = r(s)	
	scalar `lb_dpscex' = r(lb)	
	scalar `ub_dpscex' = r(ub)		

	if r(boundaries) == 0 {
					di as text "Pr Case Selection Exposed: " as res  "`name_dist_pscex'(" `fmt' `m_dpscex' "," `fmt' `s_dpscex' ")"
	}
	else {
		 di as text "Pr Case Selection Exposed: " as res  "`name_dist_pscex'(" `fmt' `m_dpscex' "," `fmt' `s_dpscex' ")  Bound(" `lb_dpscex' "," `ub_dpscex' ")"	
	}

	}

}

if "`dpscun'" != "" {
	check_dist_bp , dist(`dpscun')

	local name_dist_pscun = "`r(distribution_bp)'"
	local ns_pscun  = "`r(distribution_ns)'" 
	
	if "`name_dist_pscun'" == "Constant" {
	tempname c_dpscun  
	scalar `c_dpscun' = r(c)
	di  as text "Pr Case Selection No-Exposed: " as res "`name_dist_pscun'(" `c_dpscun' ")"
	}

	if "`name_dist_pscun'" == "Uniform" {
	tempname a_dpscun b_dpscun
	scalar `a_dpscun' = r(a)
	scalar `b_dpscun' = r(b)
	di  as text "Pr Case Selection No-Exposed: " as res "`name_dist_pexp'(" `a_dpscun' "," `b_dpscun' ")"
	}

	if inlist("`name_dist_pscun'", "Triangular", "Trapezoidal") == 1 {
	tempname a_dpscun b_dpscun c_dpscun d_dpscun
	scalar `a_dpscun' = r(a)
	scalar `b_dpscun' = r(b)
	scalar `c_dpscun' = r(c)
	scalar `d_dpscun' = r(d)
	if inlist("`name_dist_pscun'", "Triangular") == 1  di  as text "Pr Case Selection No-Exposed: " as res "`name_dist_pscun'("  `a_dpscun' "," `b_dpscun' "," `d_dpscun' ")"
	if inlist("`name_dist_pscun'", "Trapezoidal") == 1 di  as text "Pr Case Selection No-Exposed: " as res "`name_dist_pscun'(" `a_dpscun' "," `b_dpscun' "," `c_dpscun' "," `d_dpscun' ")"
	}	

	if inlist("`name_dist_pscun'", "Logit-Logistic", "Logit-Normal") == 1 {

	tempname m_dpscun s_dpscun lb_dpscun ub_dpscun
	scalar `m_dpscun' = r(m)	
	scalar `s_dpscun' = r(s)	
	scalar `lb_dpscun' = r(lb)	
	scalar `ub_dpscun' = r(ub)		

	if r(boundaries) == 0 {
					di as text "Pr Case Selection No-Exposed: " as res  "`name_dist_pscun'(" `fmt' `m_dpscun' "," `fmt' `s_dpscun' ")"
	}
	else {
		 di as text "Pr Case Selection No-Exposed: " as res  "`name_dist_pscun'(" `fmt' `m_dpscun' "," `fmt' `s_dpscun' ")  Bound(" `lb_dpscun' "," `ub_dpscun' ")"	
	}

	}

}

if "`dpsnex'" != "" {
	check_dist_bp , dist(`dpsnex')

	local name_dist_psnex = "`r(distribution_bp)'"
	local ns_psnex  = "`r(distribution_ns)'" 
	
	if "`name_dist_psnex'" == "Constant" {
	tempname c_dpsnex  
	scalar `c_dpsnex' = r(c)
	di  as text "Pr No-Case Selection Exposed: " as res "`name_dist_psnex'(" `c_dpsnex' ")"
	}

	if "`name_dist_psnex'" == "Uniform" {
	tempname a_dpsnex b_dpsnex
	scalar `a_dpsnex' = r(a)
	scalar `b_dpsnex' = r(b)
	di  as text "Pr No-Case Selection Exposed: " as res "`name_dist_psnex'(" `a_dpsnex' "," `b_dpsnex' ")"
	}

	if inlist("`name_dist_psnex'", "Triangular", "Trapezoidal") == 1 {
	tempname a_dpsnex b_dpsnex c_dpsnex d_dpsnex
	scalar `a_dpsnex' = r(a)
	scalar `b_dpsnex' = r(b)
	scalar `c_dpsnex' = r(c)
	scalar `d_dpsnex' = r(d)
	if inlist("`name_dist_psnex'", "Triangular") == 1  di  as text "Pr No-Case Selection Exposed: " as res "`name_dist_psnex'("  `a_dpsnex' "," `b_dpsnex' "," `d_dpsnex' ")"
	if inlist("`name_dist_psnex'", "Trapezoidal") == 1 di  as text "Pr No-Case Selection Exposed: " as res "`name_dist_psnex'(" `a_dpsnex' "," `b_dpsnex' "," `c_dpsnex' "," `d_dpsnex' ")"
	}	

	if inlist("`name_dist_psnex'", "Logit-Logistic", "Logit-Normal") == 1 {

	tempname m_dpsnex s_dpsnex lb_dpsnex ub_dpsnex
	scalar `m_dpsnex' = r(m)	
	scalar `s_dpsnex' = r(s)	
	scalar `lb_dpsnex' = r(lb)	
	scalar `ub_dpsnex' = r(ub)		

	if r(boundaries) == 0 {
					di as text "Pr No-Case Selection Exposed: " as res  "`name_dist_psnex'(" `fmt' `m_dpsnex' "," `fmt' `s_dpsnex' ")"
	}
	else {
		 di as text "Pr No-Case Selection Exposed: " as res  "`name_dist_psnex'(" `fmt' `m_dpsnex' "," `fmt' `s_dpsnex' ")  Bound(" `lb_dpsnex' "," `ub_dpsnex' ")"	
	}

	}

}

if "`dpsnun'" != "" {
	check_dist_bp , dist(`dpsnun')

	local name_dist_psnun = "`r(distribution_bp)'"
	local ns_psnun  = "`r(distribution_ns)'" 
	
	if "`name_dist_psnun'" == "Constant" {
	tempname c_dpsnun  
	scalar `c_dpsnun' = r(c)
	di  as text "Pr No-Case Selection No-Exposed: " as res "`name_dist_psnun'(" `c_dpsnun' ")"
	}

	if "`name_dist_psnun'" == "Uniform" {
	tempname a_dpsnun b_dpsnun
	scalar `a_dpsnun' = r(a)
	scalar `b_dpsnun' = r(b)
	di  as text "Pr No-Case Selection No-Exposed: " as res "`name_dist_psnun'(" `a_dpsnun' "," `b_dpsnun' ")"
	}

	if inlist("`name_dist_psnun'", "Triangular", "Trapezoidal") == 1 {
	tempname a_dpsnun b_dpsnun c_dpsnun d_dpsnun
	scalar `a_dpsnun' = r(a)
	scalar `b_dpsnun' = r(b)
	scalar `c_dpsnun' = r(c)
	scalar `d_dpsnun' = r(d)
	if inlist("`name_dist_psnun'", "Triangular") == 1  di  as text "Pr No-Case Selection No-Exposed: " as res "`name_dist_psnun'("  `a_dpsnun' "," `b_dpsnun' "," `d_dpsnun' ")"
	if inlist("`name_dist_psnun'", "Trapezoidal") == 1 di  as text "Pr No-Case Selection No-Exposed: " as res "`name_dist_psnun'(" `a_dpsnun' "," `b_dpsnun' "," `c_dpsnun' "," `d_dpsnun' ")"
	}	

	if inlist("`name_dist_psnun'", "Logit-Logistic", "Logit-Normal") == 1 {

	tempname m_dpsnun s_dpsnun lb_dpsnun ub_dpsnun
	scalar `m_dpsnun' = r(m)	
	scalar `s_dpsnun' = r(s)	
	scalar `lb_dpsnun' = r(lb)	
	scalar `ub_dpsnun' = r(ub)		

	if r(boundaries) == 0 {
					di as text "Pr No-Case Selection No-Exposed: " as res  "`name_dist_psnun'(" `fmt' `m_dpsnun' "," `fmt' `s_dpsnun' ")"
	}
	else {
		 di as text "Pr No-Case Selection No-Exposed: " as res  "`name_dist_psnun'(" `fmt' `m_dpsnun' "," `fmt' `s_dpsnun' ")  Bound(" `lb_dpsnun' "," `ub_dpsnun' ")"	
	}

	}

}

if "`dsbfactor'" != "" {

	check_dist_bp , dist(`dsbfactor')

	local name_dist_sbfactor = "`r(distribution_bp)'"
	local ns_sbfactor  = "`r(distribution_ns)'" 
	
	if "`name_dist_sbfactor'" == "Constant" {
	tempname c_dsbfactor  
	scalar `c_dsbfactor' = r(c)
	di  as text "Selection bias factor: " as res "`name_dist_sbfactor'(" `c_dsbfactor' ")"
	}

	if "`name_dist_sbfactor'" == "Uniform" {
	tempname a_dsbfactor b_dsbfactor
	scalar `a_dsbfactor' = r(a)
	scalar `b_dsbfactor' = r(b)
	di  as text "Selection bias factor: " as res "`name_dist_pexp'(" `a_dsbfactor' "," `b_dsbfactor' ")"
	}

	if inlist("`name_dist_sbfactor'", "Triangular", "Trapezoidal") == 1 {
	tempname a_dsbfactor b_dsbfactor c_dsbfactor d_dsbfactor
	scalar `a_dsbfactor' = r(a)
	scalar `b_dsbfactor' = r(b)
	scalar `c_dsbfactor' = r(c)
	scalar `d_dsbfactor' = r(d)
	if inlist("`name_dist_sbfactor'", "Triangular") == 1  di  as text "Selection bias factor: " as res "`name_dist_sbfactor'("  `a_dsbfactor' "," `b_dsbfactor' "," `d_dsbfactor' ")"
	if inlist("`name_dist_sbfactor'", "Trapezoidal") == 1 di  as text "Selection bias factor: " as res "`name_dist_sbfactor'(" `a_dsbfactor' "," `b_dsbfactor' "," `c_dsbfactor' "," `d_dsbfactor' ")"
	}	

	if inlist("`name_dist_sbfactor'", "Logit-Logistic", "Logit-Normal") == 1 {

	tempname m_dsbfactor s_dsbfactor lb_dsbfactor ub_dsbfactor
	scalar `m_dsbfactor' = r(m)	
	scalar `s_dsbfactor' = r(s)	
	scalar `lb_dsbfactor' = r(lb)	
	scalar `ub_dsbfactor' = r(ub)		

	if r(boundaries) == 0 {
					di as text "Selection bias factor: " as res  "`name_dist_sbfactor'(" `fmt' `m_dsbfactor' "," `fmt' `s_dsbfactor' ")"
	}
	else {
		 di as text "Selection bias factor: " as res  "`name_dist_sbfactor'(" `fmt' `m_dsbfactor' "," `fmt' `s_dsbfactor' ")  Bound(" `lb_dsbfactor' "," `ub_dsbfactor' ")"	
	}

	}

	if inlist("`name_dist_sbfactor'", "Log-Normal", "Log-Logistic") == 1 {
	tempname m_dsbfactor s_dsbfactor boundaries 
	scalar `m_dsbfactor' = r(m)
	scalar `s_dsbfactor' = r(s)
	di as text "Selection bias factor: " as res  "`name_dist_sbfactor'(" `fmt' `m_dsbfactor' "," `fmt' `s_dsbfactor' ")"	
	}	


}

// Unmeasured confounding bias parameters - distribution of values

if "`dpexp'" != "" {

	check_dist_bp , dist(`dpexp')
	local name_dist_pexp = "`r(distribution_bp)'" 
	local ns_pexp = "`r(distribution_ns)'" 
 
	if "`name_dist_pexp'" == "Constant" {
	tempname c_dpexp  
	scalar `c_dpexp' = r(c)
	di  as text "Pr(c=1|e=1): " as res "`name_dist_pexp'(" `c_dpexp' ")"
	}
	
	if "`name_dist_pexp'" == "Uniform" {
	tempname a_dpexp b_dpexp
	scalar `a_dpexp' = r(a)
	scalar `b_dpexp' = r(b)
	di  as text "Pr(c=1|e=1): " as res "`name_dist_pexp'(" `a_dpexp' "," `b_dpexp' ")"
	}

	if inlist("`name_dist_pexp'", "Triangular", "Trapezoidal") == 1 {

	tempname a_dpexp b_dpexp c_dpexp d_dpexp
	scalar `a_dpexp' = r(a)
	scalar `b_dpexp' = r(b)
	scalar `c_dpexp' = r(c)
	scalar `d_dpexp' = r(d)
	if inlist("`name_dist_pexp'", "Triangular") == 1 di  as text "Pr(c=1|e=1): " as res "`name_dist_pexp'(" `a_dpexp' "," `b_dpexp' "," `d_dpexp' ")"
	if inlist("`name_dist_pexp'", "Trapezoidal") == 1 di  as text "Pr(c=1|e=1): " as res "`name_dist_pexp'(" `a_dpexp' "," `b_dpexp' "," `c_dpexp' "," `d_dpexp' ")"
	}
	
	if inlist("`name_dist_pexp'", "Logit-Logistic", "Logit-Normal") == 1 {

	tempname m_dpexp s_dpexp lb_dpexp ub_dpexp
	scalar `m_dpexp' = r(m)	
	scalar `s_dpexp' = r(s)	
	scalar `lb_dpexp' = r(lb)	
	scalar `ub_dpexp' = r(ub)		

	if r(boundaries) == 0 {
					di as text "Pr(c=1|e=1): " as res  "`name_dist_pexp'(" `fmt' `m_dpexp' "," `fmt' `s_dpexp' ")"
	}
	else {
		 di as text "Pr(c=1|e=1): " as res  "`name_dist_pexp'(" `fmt' `m_dpexp' "," `fmt' `s_dpexp' ")  Bound(" `lb_dpexp' "," `ub_dpexp' ")"	
	}

	}

}


if "`dpunexp'" != "" {

	check_dist_bp , dist(`dpunexp')
	local name_dist_punexp = "`r(distribution_bp)'"
 	local ns_punexp = "`r(distribution_ns)'" 

	if "`name_dist_punexp'" == "Constant" {
	tempname c_dpunexp  
	scalar `c_dpunexp' = r(c)
	di  as text "Pr(c=1|e=0): " as res "`name_dist_punexp'(" `c_dpunexp' ")"
	}

	if "`name_dist_punexp'" == "Uniform" {
	tempname a_dpunexp b_dpunexp
	scalar `a_dpunexp' = r(a)
	scalar `b_dpunexp' = r(b)
	di  as text "Pr(c=1|e=0): " as res "`name_dist_punexp'(" `a_dpunexp' "," `b_dpunexp' ")"
	}

	if inlist("`name_dist_punexp'", "Triangular", "Trapezoidal") == 1 {
	tempname a_dpunexp b_dpunexp c_dpunexp d_dpunexp
	scalar `a_dpunexp' = r(a)
	scalar `b_dpunexp' = r(b)
	scalar `c_dpunexp' = r(c)
	scalar `d_dpunexp' = r(d)
	if inlist("`name_dist_punexp'", "Triangular") == 1 di  as text "Pr(c=1|e=0): " as res "`name_dist_punexp'("  `a_dpunexp' "," `b_dpunexp' "," `d_dpunexp' ")"
	if inlist("`name_dist_punexp'", "Trapezoidal") == 1 di  as text "Pr(c=1|e=0): " as res "`name_dist_punexp'(" `a_dpunexp' "," `b_dpunexp' "," `c_dpunexp' "," `d_dpunexp' ")"
	}	

	if inlist("`name_dist_punexp'", "Logit-Logistic", "Logit-Normal") == 1 {

	tempname m_dpunexp s_dpunexp lb_dpunexp ub_dpunexp
	scalar `m_dpunexp' = r(m)	
	scalar `s_dpunexp' = r(s)	
	scalar `lb_dpunexp' = r(lb)	
	scalar `ub_dpunexp' = r(ub)		

	if r(boundaries) == 0 {
					di as text "Pr(c=1|e=0): " as res  "`name_dist_punexp'(" `fmt' `m_dpunexp' "," `fmt' `s_dpunexp' ")"
	}
	else {
		 di as text "Pr(c=1|e=0): " as res  "`name_dist_punexp'(" `fmt' `m_dpunexp' "," `fmt' `s_dpunexp' ")  Bound(" `lb_dpunexp' "," `ub_dpunexp' ")"	
	}

	}

}


if "`drrcd'" != "" {
	check_dist_bp , dist(`drrcd')
	local name_dist_rrcd = "`r(distribution_bp)'"  
 	local ns_rrcd = "`r(distribution_ns)'" 

	if "`name_dist_rrcd'" == "Constant" {
	tempname c_drrcd  
	scalar `c_drrcd' = r(c)
	di  as text "RR_cd      : " as res "`name_dist_rrcd'(" `c_drrcd' ")"
	}

	if inlist("`name_dist_rrcd'", "Log-Normal", "Log-Logistic") == 1 {
	tempname m_drrcd s_drrcd boundaries 
	scalar `m_drrcd' = r(m)
	scalar `s_drrcd' = r(s)
	di as text "RR_cd      : " as res  "`name_dist_rrcd'(" `fmt' `m_drrcd' "," `fmt' `s_drrcd' ")"	
	}	
}


	
if "`dorce'" != "" {
	check_dist_bp , dist(`dorce')
	local name_dist_orce = "`r(distribution_bp)'" 
	local ns_orce = "`r(distribution_ns)'" 

	if "`name_dist_orce'" == "Constant" {
	tempname c_dorce  
	scalar `c_dorce' = r(c)
	di  as text "OR_ce      : " as res "`name_dist_orce'(" `c_dorce' ")"
	}

	if inlist("`name_dist_orce'", "Log-Normal", "Log-Logistic") == 1 {
	tempname m_dorce s_dorce
	scalar `m_dorce' = r(m)
	scalar `s_dorce' = r(s)
	di as text "OR_ce      : " as res  "`name_dist_orce'(" `fmt' `m_dorce' "," `fmt' `s_dorce' ")"	
	}

}

if "`corrprev'" != "" {
	
		if inrange(`corrprev',0,1) == 1 {
			tempname c_prev
			scalar `c_prev' = `corrprev'
			di as text "Corr confounder-exposure specific prevalences: " as res `c_prev'
		}
		else {
			di as err "Specify correctly the correlation (0,1) among prevalences"	
			exit 198	
		}

}

// Get the observed relative risk
 
if "`type'" == "cc" {	
	qui cci `a'  `b'  `c'  `d' , woolf
	tempname arrdx lbarr ubarr 
	scalar `arrdx' = r(or)
	scalar `lbarr' = r(lb_or)
	scalar `ubarr' = r(ub_or)
	local effect = "Odds Ratio"
}

if "`type'" == "ir" {	
	qui iri `a'  `b'  `c'  `d'
	tempname arrdx lbarr ubarr 
	scalar `arrdx' = r(irr)
	scalar `lbarr' = r(lb_irr)
	scalar `ubarr' = r(ub_irr)
	local effect = "Rate Ratio"

} 

if "`type'" == "cs" {	
	qui csi `a'  `b'  `c'  `d'  , woolf
	tempname arrdx lbarr ubarr n1 n0
	scalar `arrdx' = r(rr)
	scalar `lbarr' = r(lb_rr)
	scalar `ubarr' = r(ub_rr)
	scalar `n1' = `a' + `c' 
	scalar `n0' = `b' + `d' 
	local effect = "Risk Ratio"
}




// Check of the user typed distributions 

if ("`name_dist_seca'" == "Constant") &  ("`name_dist_spca'" == "Constant") & ///
   ("`name_dist_senc'" == "Constant") &  ("`name_dist_spnc'" == "Constant")   {
	local ordmie = "Yes"
   if ("`combined'" == "") local combmie = "No"	
	else local combmie = "Yes"	
}
else {
	if ("`name_dist_seca'"!="") & ("`name_dist_spca'" != "") & ("`name_dist_senc'" != "") & ("`name_dist_spnc'" != "") {
	local probmie = "Yes"
		 if ("`combined'" == "") local combmie = "No"	
			else local combmie = "Yes"	
	}
}

 
if [ ("`name_dist_pscex'" == "Constant") &  ("`name_dist_pscun'" == "Constant") & ///
     ("`name_dist_psnex'" == "Constant") &  ("`name_dist_psnun'" == "Constant") ] | ("`name_dist_sbfactor'" == "Constant")   {	
	local ordsel = "Yes"
	
		if "`type'" != "cc" {
			di as err "selection bias correction works for case-control data"
			exit 198
		}

  	 if ("`combined'" == "") local combsel = "No"	
		else local combsel = "Yes"	
}
else {
	if [ ("`name_dist_pscex'" != "") &  ("`name_dist_pscun'" != "") & ///
    	     ("`name_dist_psnex'" != "") &  ("`name_dist_psnun'" != "") ] | ("`name_dist_sbfactor'" != "")   {	

		local probsel = "Yes"

		if ("`type'" != "cc") {
			di as err "selection bias correction works for case-control data"
			exit 198
		}

		 if ("`combined'" == "") local combsel = "No"	
			else local combsel = "Yes"	
	}
}


if 	("`name_dist_punexp'" == "Constant") & ("`name_dist_pexp'" == "Constant" | "`name_dist_orce'" == "Constant") & ///
	("`name_dist_rrcd'" == "Constant")     {
	local ordunc = "Yes"
 
   if ("`combined'" == "") local combunc = "No"	
	else local combunc = "Yes"	
}
else {

	if 	("`name_dist_punexp'" != "") & ("`name_dist_pexp'" != "" | "`name_dist_orce'" != "") & ///
		("`name_dist_rrcd'" != "")     {

		local probunc = "Yes"
	 	if ("`combined'" == "") local combunc = "No"	
			else local combunc = "Yes"	
	}
}
	
if   ("`ordmie'"=="Yes") | ("`ordsel'"=="Yes") | ("`ordunc'"=="Yes")   {

// Display the observed relative risk and 95% CI

  	di _col(1) _n as text "Observed `effect' [95% Conf. Interval]= " `fmt' as res `arrdx' ///
          in g " [" in y `fmt' `lbarr' in gr ", " in y `fmt' `ubarr' in gr "]" 

}

// Sensitivity analysis for misclassification of the exposure - Deterministic sensitivity analysis

if ("`ordmie'" == "Yes") & ("`combined'" == "")  {

	di _n as text "Deterministic sensitivity analysis for misclassification of the exposure"
	episens_mie `a'  `b'  `c'  `d' , seec(`ns_seca') spec(`ns_spca') seeo(`ns_senc') speo(`ns_spnc') arrdx(`arrdx') type(`type')
	
  	di _col(4) as text "External adjusted `effect' = " `fmt' as res r(rrdx_mie)
	di _col(4) as text "Percent bias = " %3.0f as res r(bias_mie) "%"

		// Saved results

		return scalar rrdx_mie = r(rrdx_mie)
		return scalar bias_mie = r(bias_mie)
}

// Sensitivity analysis for selection bias (only for Case-Control studies) - Deterministic sensitivity analysis

if ("`ordsel'" == "Yes") & ("`combined'" == "")  {

	di _n as text "Deterministic sensitivity analysis for selection bias"
	episens_sel `a'  `b'  `c'  `d' , spscex(`ns_pscex') spscun(`ns_pscun') spsnex(`ns_psnex') spsnun(`ns_psnun') ///
						    ssbfactor(`ns_sbfactor') arrdx(`arrdx') type(`type')
	
  	di _col(4) as text "External adjusted `effect' = " `fmt' as res r(rrdx_sel)
	di _col(4) as text "Percent bias = " %3.0f as res r(bias_sel) "%"

	// Saved results

	return scalar rrdx_sel = r(rrdx_sel)
	return scalar bias_sel = r(bias_sel)
}

// Sensitivity analysis of a binary unmeasured confounder - Deterministic sensitivity analysis

if ("`ordunc'" == "Yes") & ("`combined'" == "")  {

 di _n as text "Deterministic sensitivity analysis for unmeasured confounding""
	episens_unc `a'  `b'  `c'  `d' , prz1(`ns_pexp') prz0(`ns_punexp') orze(`ns_orce') rrdz(`ns_rrcd') arrdx(`arrdx') type(`type')
 
/*  	di _col(4) as text "External adjusted `effect' [95% Conf. Interval] = " `fmt' as res r(rrdx_unc) ///
          in g " [" in y `fmt' `lbarr'/(`arrdx'/r(rrdx_unc)) in gr ", " in y `fmt' `ubarr'/(`arrdx'/r(rrdx_unc)) in gr "]" 
*/

  	di _col(4) as text "External adjusted `effect' = " `fmt' as res r(rrdx_unc)
	di _col(4) as text "Percent bias = " %3.0f as res r(bias_unc) "%"

		return scalar rrdx_unc = r(rrdx_unc)
		return scalar bias_unc = r(bias_unc)
}


// Combined corrections in this order: misclassification of the exposure, selection bias (only if case-control), and unmeasured confounding

if  ("`combined'" != "")  {

		if ("`probmie'"!= "Yes") & ("`probsel'"!= "Yes")  & ("`probunc'"!= "Yes") di _n as text "Deterministic sensitivity analysis - Combined corrections"

		local rrstep = `arrdx' 

	if   ("`ordmie'" == "Yes")  &  ("`combmie'" == "Yes")  {

		episens_mie `a'  `b'  `c'  `d' , seec(`ns_seca') spec(`ns_spca') seeo(`ns_senc') speo(`ns_spnc') arrdx(`arrdx') type(`type')

		// get the counts, round the counts, and put them into locals

		tempname a1 b1 c1 d1

		scalar `a1' = r(a1)
		scalar `b1' = r(b1)
		scalar `c1' = r(c1)
		scalar `d1' = r(d1)


		local a1 = `a1' 
		local b1 = `b1'
		local c1 = `c1'
		local d1 = `d1'

		di _col(1) _n as text   "Misclassification of the exposure"
  		di _col(4) as text "External adjusted `effect' = " `fmt' as res r(rrdx_mie)
		di _col(4) as text "Percent bias = " %3.0f as res r(bias_mie) "%"

		return scalar rrdx_mie = r(rrdx_mie)
		return scalar bias_mie = r(bias_mie)
		
		local rrstep = r(rrdx_mie) 

	}

	if  ("`ordsel'" == "Yes") & ("`combsel'" == "Yes")  {

	      episens_sel  `a'  `b'  `c'  `d'  , spscex(`ns_pscex') spscun(`ns_pscun') spsnex(`ns_psnex') spsnun(`ns_psnun') ///
						    ssbfactor(`ns_sbfactor') arrdx(`rrstep') type(`type') 

		di _n as text "Selection bias"
  		di _col(4) as text "External adjusted `effect' = " `fmt' as res r(rrdx_sel)
		di _col(4) as text "Percent bias = " %3.0f as res %3.0f (`arrdx'-r(rrdx_sel))/r(rrdx_sel)*100  "%"
 

		return scalar rrdx_sel = r(rrdx_sel)
		return scalar bias_sel = (`arrdx'-r(rrdx_sel))/r(rrdx_sel)*100	

		local rrstep = r(rrdx_sel) 
	}

	if  ("`ordunc'" == "Yes") & ("`combunc'" == "Yes")  {

	      episens_unc `a'  `b'  `c'  `d'  , prz1(`ns_pexp') prz0(`ns_punexp') orze(`ns_orce') rrdz(`ns_rrcd') arrdx(`rrstep') type(`type') ordered

		di _col(1) as text _n "Unmeasured confounding"
  		di _col(4) as text "External adjusted `effect' = " `fmt' as res r(rrdx_unc)
		di _col(4) as text "Percent bias = " %3.0f as res (`arrdx'-r(rrdx_unc))/r(rrdx_unc)*100  "%"

		// Saved results

		return scalar rrdx_unc = r(rrdx_unc)
		return scalar bias_unc = (`arrdx'-r(rrdx_unc))/r(rrdx_unc)*100 	
	}

	return scalar arrdx = `arrdx'

}

 

// Sensitivity analysis for misclassification of the exposure - Probabilistic sensitivity analysis

preserve

if  ("`probmie'"=="Yes") & ("`combmie'" == "No") {

di _n as text "Probabilistic sensitivity analysis for misclassification of the exposure"

/*
di "`name_dist_seca'  `ns_seca'"
di "`name_dist_spca'  `ns_spca'"
di "`name_dist_senc'  `ns_senc'" 
di "`name_dist_spnc'  `ns_spnc'" 
di `corrsens'  " " `corrspec'
*/

simulate adjrrmiesys =r(adj_rr_mie) adj_fac_mie = r(adj_factor_mie) perc_bias_mie = r(perc_bias) pseca=r(pseca) psenc=r(psenc) pspca=r(pspca) pspnc=r(pspnc)  ///
           a1 = r(a1) a0 = r(a0) b1 = r(b1) b0 = r(b0) rhose = r(rhose) rhosp= r(rhosp) , reps(`reps') seed(`seed') nolegend `nodots' saving(`saving') : ///
            episens_mcsa_mie `a'  `b'  `c'  `d' , sseca(`name_dist_seca'  `ns_seca') sspca(`name_dist_spca'  `ns_spca') ///
					                    ssenc(`name_dist_senc'  `ns_senc') sspnc(`name_dist_spnc'  `ns_spnc') ///
								  apprr(`arrdx') obs(`ndraw')  studytype(`type') scorrsens(`corrsens') scorrspec(`corrspec')

	qui gen double adjrrmietot = exp(log(adjrrmiesys) - invnorm(uniform())*[ (log(`ubarr')-log(`lbarr'))/(invnorm(.975)*2) ])

* Display results

	di  _col(40)  as text "Percentiles" _col(60) "Ratio"
	di _col(1) as text  _col(30) "2.5" _col(40) "50" _col(50) "97.5" _col(60) "97.5/2.5"
	di _col(30) _dup(40) "-"
	di    _col(1) as text  "Conventional " as res _col(30) `fmt'  `lbarr'  _col(40) `fmt'  `arrdx'     _col(50) `fmt' `ubarr' _col(60) `fmt' `ubarr'/`lbarr'
	_pctile adjrrmiesys , percentiles(2.5 50 97.5)
	di    _col(1) as text  "Systematic error " as res _col(30) `fmt' r(r1)   _col(40) `fmt' r(r2)    _col(50) `fmt' r(r3) _col(60) `fmt' r(r3)/r(r1)
	_pctile  adjrrmietot , percentiles(2.5 50 97.5)
	di    _col(1) as text  "Systematic and random error " as res  _col(30) `fmt' r(r1)   _col(40) `fmt' r(r2)    _col(50) `fmt' r(r3) _col(60) `fmt' r(r3)/r(r1)

	// Saved results
	return scalar rrdx_mie_plb = r(r1)
	return scalar rrdx_mie_pm = r(r2)
	return scalar rrdx_mie_pub = r(r3)
		
	gen sim_n = _n
	label var adjrrmiesys "RR adjusted for systematic error"
	label var adjrrmietot "RR adjusted for systematic and random error"
	label var sim_n "Simulation number"
	order sim_n adjrrmiesys adjrrmietot
	if ("`saving'"!="") qui save `dataname' , replace

// Graph - do not display sens and spec truncated for negative adjustment

	if "`grprior'" != "" {
			
        qui hist pseca if (pseca >= `a'/`m1')  , name(pseca, replace) frequency xtitle("Sensitivity Cases")
        qui hist psenc if (psenc >= `c'/`m0')  , name(psenc, replace) frequency xtitle("Sensitivity Noncases")
        qui hist pspca if (pspca >= `b'/`m1') , name(pspca, replace) frequency xtitle("Specificity Cases")
        qui hist pspnc if (pspnc >= `d'/`m0') , name(pspnc, replace) frequency xtitle("Specificity Noncases")
		gr combine pseca  psenc  pspca  pspnc, name(priors_misclassification, replace)
		gr drop pseca  psenc  pspca  pspnc
	} 

	if "`grarrsys'" != "" {
		qui su adjrrmiesys, d
		local p1 = r(p1)		
		local p99 = r(p99)
		qui hist adjrrmiesys if  adjrrmiesys < `p99', name(adjrrmiesys, replace) frequency  xtitle("Simulated RR adjusted for exposure misclassification") ///
				note("Exclusion of values < Percentile 99%")
	}
	
	if "`grarrtot'" != "" {
		qui su adjrrmietot, d
		local p1 = r(p1)		
		local p99 = r(p99)
		qui hist  adjrrmietot  if adjrrmietot < `p99', name(adjrrmietot, replace) frequency xtitle("Simulated RR adjusted for exposure misclassification and random error") ///
				note("Exclusion of values < Percentile 99%")
	}


}

// Sensitivity analysis of selection bias - Probabilistic sensitivity analysis

if  ("`probsel'"=="Yes") & ("`combsel'" == "No") {

di _n as text "Probabilistic sensitivity analysis for selection bias"

/*
di "`name_dist_pscex'"
di "`name_dist_pscun'"
di "`name_dist_psnex'" 
di "`name_dist_psnun'" 
di "`name_dist_sbfactor'" 
*/

simulate adjrrselsys =r(adj_rr_sel) adj_fac_sel = r(adj_factor_sel) perc_bias_sel = r(perc_bias)   ///
          pscex = r(pscex) pscun = r(pscun) psnex = r(psnex) psnun = r(psnun) sbfactor = r(sbf), reps(`reps') seed(`seed') nolegend `nodots' saving(`saving') : ///
            episens_mcsa_sel `a'  `b'  `c'  `d' , spscex(`name_dist_pscex'  `ns_pscex') spscun(`name_dist_pscun'  `ns_pscun') ///
					                    spsnex(`name_dist_psnex'  `ns_psnex') spsnun(`name_dist_psnun'  `ns_psnun') ssbfactor(`name_dist_sbfactor'  `ns_sbfactor') ///
								  apprr(`arrdx')  obs(`ndraw')  studytype(`type') 


	qui gen double adjrrseltot = exp(log(adjrrselsys) - invnorm(uniform())*[ (log(`ubarr')-log(`lbarr'))/(invnorm(.975)*2) ])

* Display results
 
	di  _col(40)  as text "Percentiles" _col(60) "Ratio"
	di _col(1) as text  _col(30) "2.5" _col(40) "50" _col(50) "97.5" _col(60) "97.5/2.5"
	di _col(30) _dup(40) "-"
	di    _col(1) as text  "Conventional " as res _col(30) `fmt'  `lbarr'  _col(40) `fmt'  `arrdx'     _col(50) `fmt' `ubarr' _col(60) `fmt' `ubarr'/`lbarr'
	_pctile adjrrselsys, percentiles(2.5 50 97.5)
	di    _col(1) as text  "Systematic error " as res _col(30) `fmt' r(r1)   _col(40) `fmt' r(r2)    _col(50) `fmt' r(r3)  _col(60) `fmt' r(r3)/r(r1)
	_pctile  adjrrseltot , percentiles(2.5 50 97.5)
	di    _col(1) as text  "Systematic and random error " as res  _col(30) `fmt' r(r1)   _col(40) `fmt' r(r2)    _col(50) `fmt' r(r3)  _col(60) `fmt' r(r3)/r(r1)

	// Saved results
	return scalar rrdx_sel_plb = r(r1)
	return scalar rrdx_sel_pm = r(r2)
	return scalar rrdx_sel_pub = r(r3)

	gen sim_n = _n
	order sim_n adjrrselsys adjrrseltot
	label var adjrrselsys "RR adjusted for systematic error"
	label var adjrrseltot "RR adjusted for systematic and random error"
	label var sim_n "Simulation number"
	if ("`saving'"!="") qui save `dataname' , replace

// Graph

   if "`grprior'" != "" {

	if ("`name_dist_pscex'"!= "") & ("`name_dist_pscun'"!= "") & ("`name_dist_psnex'"!= "") & ("`name_dist_psnun'"!= "") {
             qui hist pscex , name(pscex, replace) frequency xtitle("Selection Cases Exposed")
		qui hist pscun , name(pscun , replace) frequency xtitle("Selection Cases Unexposed")
		qui hist psnex , name(psnex, replace) frequency xtitle("Selection Noncases Exposed")
		qui hist psnun , name(psnun, replace) frequency xtitle("Selection Noncases Unxposed")
		gr combine   pscex  pscun   psnex  psnun , name(priors_selection_bias, replace)
		gr drop pscex  pscun   psnex  psnun
	}
	else {
             qui hist sbfactor , name(sbsfactor, replace) frequency xtitle("Selection bias factor")
	}	
  }

	if "`grarrsys'" != "" {
		qui hist adjrrselsys , name(adjrrselsys, replace)  frequency xtitle("Simulated RR adjusted for selection bias")	
	}
	
	if "`grarrtot'" != "" {
		qui hist adjrrseltot , name(adjrrseltot, replace)  frequency xtitle("Simulated RR adjusted for selection bias and random error")	
	}

}


// Sensitivity analysis of a binary unmeasured confounder - Probabilistic sensitivity analysis

if  ("`probunc'"=="Yes") & ("`combunc'" == "No") {

di _n as text "Probabilistic sensitivity analysis for unmeasured confounding"

/* 
di "`name_dist_punexp'  `ns_punexp'"
di "`name_dist_pexp'  `ns_pexp'"
di "`name_dist_rrcd'  `ns_rrcd'" 
di "`name_dist_orce'  `ns_orce'" 
 */

if "`dorce'" == ""  {
simulate adjrruncsys =r(adj_rr_unc) adj_fac_unc = r(adj_factor_unc) perc_bias_unc = r(perc_bias) pc1 = r(pc1) pc0 = r(pc0) rrcd = r(rrcd) orce = r(orce) ///
           a1 = r(a1) a0 = r(a0) b1 = r(b1) b0 = r(b0) rhoprev = r(rhoprev)  , reps(`reps') seed(`seed') nolegend `nodots' saving(`saving') : ///
            episens_mcsa_unc `a'  `b'  `c'  `d' , spexp(`name_dist_pexp'  `ns_pexp') spunexp(`name_dist_punexp'  `ns_punexp') ///
					                    srrcd(`name_dist_rrcd'  `ns_rrcd') sorce(`name_dist_orce'  `ns_orce') ///
								  apprr(`arrdx') applb(`lbarr') appub(`ubarr') obs(`ndraw')  studytype(`type') scorrprev(`corrprev') 
}
else {
simulate adjrruncsys =r(adj_rr_unc) adj_fac_unc = r(adj_factor_unc) perc_bias_unc = r(perc_bias)  pc0 = r(pc0) rrcd = r(rrcd) orce = r(orce) ///
            , reps(`reps') seed(`seed') nolegend `nodots' saving(`saving') : ///
            episens_mcsa_unc `a'  `b'  `c'  `d' , spexp(`name_dist_pexp'  `ns_pexp') spunexp(`name_dist_punexp'  `ns_punexp') ///
					                    srrcd(`name_dist_rrcd'  `ns_rrcd') sorce(`name_dist_orce'  `ns_orce') ///
								  apprr(`arrdx') applb(`lbarr') appub(`ubarr') obs(`ndraw')  studytype(`type') scorrprev(`corrprev') 

}

	qui gen double adjrrunctot = exp(log(adjrruncsys) - invnorm(uniform())*[ (log(`ubarr')-log(`lbarr'))/(invnorm(.975)*2) ])
 
* Display results
 
	di  _col(40)  as text "Percentiles" _col(60) "Ratio"
	di _col(1) as text  _col(30) "2.5" _col(40) "50" _col(50) "97.5" _col(60) "97.5/2.5"
	di _col(30) _dup(40) "-"
	di    _col(1) as text  "Conventional " as res _col(30) `fmt'  `lbarr'  _col(40) `fmt'  `arrdx'     _col(50) `fmt' `ubarr'  _col(60) `fmt' `ubarr'/`lbarr'

	_pctile adjrruncsys, percentiles(2.5 50 97.5)
	di    _col(1) as text  "Systematic error " as res _col(30) `fmt' r(r1)   _col(40) `fmt' r(r2)    _col(50) `fmt' r(r3)  _col(60) `fmt' r(r3)/r(r1)

	_pctile  adjrrunctot , percentiles(2.5 50 97.5)
	di    _col(1) as text  "Systematic and random error " as res  _col(30) `fmt' r(r1)   _col(40) `fmt' r(r2)    _col(50) `fmt' r(r3)  _col(60) `fmt' r(r3)/r(r1)

	// Saved results
	return scalar rrdx_unc_plb = r(r1)
	return scalar rrdx_unc_pm = r(r2)
	return scalar rrdx_unc_pub = r(r3)

	gen sim_n = _n
	order sim_n adjrruncsys adjrrunctot
	label var adjrruncsys "RR adjusted for systematic error"
	label var adjrrunctot "RR adjusted for systematic and random error"
	label var sim_n "Simulation number"

	if ("`saving'"!="") qui save `dataname' , replace

// Graph

	if "`grprior'" != "" {

	if ("`name_dist_pexp'"!= "") & ("`name_dist_punexp'"!= "") & ("`name_dist_rrcd'"!= "")  {
             qui hist pc1 , name(pc1, replace) frequency xtitle("Prevalence confounder exposed")
		qui hist pc0 , name(pc0 , replace) frequency xtitle("Prevalence confounder unexposed")
		qui hist rrcd , name(rrcd, replace) frequency xtitle("Confounder-Disease RR") 
		gr combine   pc1  pc0   rrcd  , name(priors_unmeasured_confounding, replace)
		gr drop  pc1  pc0   rrcd
	}
	else {
             qui hist orce , name(orce, replace) frequency xtitle("Confounder-Exposure OR")
		qui hist pc0 , name(pc0 , replace) frequency xtitle("Prevalence confounder unexposed")
		qui hist rrcd , name(rrcd, replace) frequency xtitle("Confounder-Disease RR") 
		gr combine  orce  pc0   rrcd, name(priors_unmeasured_confounding, replace)
		gr drop  orce  pc0   rrcd 
	}
	
	}

	if "`grarrsys'" != "" {
		qui hist adjrruncsys , name(adjrruncsys, replace)  frequency  xtitle("Simulated RR adjusted for confounding")	
	}
	
	if "`grarrtot'" != "" {
		qui hist adjrrunctot , name(adjrrunctot, replace)  frequency  xtitle("Simulated RR adjusted for confounding and random error")	
	}

}

* here

// Combined probabilistic sensitivity analysis

if  ( ("`probmie'"=="Yes") | ("`probsel'"=="Yes") | ("`probunc'"=="Yes") ) & ("`combined'" != "")  {

di _n as text "Probabilistic sensitivity analysis - Combined corrections"

if  ("`probmie'"=="Yes") di _col(5) "Misclassification of the exposure"
if  ("`probsel'"=="Yes") di _col(5) "Selection bias"
if  ("`probunc'"=="Yes") di _col(5) "Unmeasured confounding"

if  ("`probmie'"=="Yes")  global title = "misclassification"
if  ("`probsel'"=="Yes")  global title = "$title, selection bias"
if  ("`probunc'"=="Yes")  global title = "$title, confounding"

simulate adjrrallsys =r(adj_rr_all) perc_bias_all = r(perc_bias)   ///
pseca=r(pseca) psenc=r(psenc) pspca=r(pspca) pspnc=r(pspnc)  ///
rhose = r(rhose) rhosp= r(rhosp) ///
pscex = r(pscex) pscun = r(pscun) psnex = r(psnex) psnun = r(psnun) sbfactor = r(sbf) ///
pc1 = r(pc1) pc0 = r(pc0) rrcd = r(rrcd) orce = r(orce) rhoprev = r(rhoprev) ///
                       , reps(`reps') seed(`seed') nolegend `nodots' saving(`saving') :  ///
                         episens_mcsa_all `a'  `b'  `c'  `d' , ///
				sseca(`name_dist_seca'  `ns_seca') sspca(`name_dist_spca'  `ns_spca') ///
 				ssenc(`name_dist_senc'  `ns_senc') sspnc(`name_dist_spnc'  `ns_spnc') ///
				scorrsens(`corrsens') scorrspec(`corrspec') ///
				spscex(`name_dist_pscex'  `ns_pscex') spscun(`name_dist_pscun'  `ns_pscun') ///
				spsnex(`name_dist_psnex'  `ns_psnex') spsnun(`name_dist_psnun'  `ns_psnun') ssbfactor(`name_dist_sbfactor'  `ns_sbfactor') ///
				spexp(`name_dist_pexp'  `ns_pexp') spunexp(`name_dist_punexp'  `ns_punexp') ///
				srrcd(`name_dist_rrcd'  `ns_rrcd') sorce(`name_dist_orce'  `ns_orce') scorrprev(`corrprev') ///
				apprr(`arrdx') applb(`lbarr') appub(`ubarr') obs(`ndraw')  studytype(`type')  
 
qui gen double adjrralltot = exp(log(adjrrallsys) - invnorm(uniform())*[ (log(`ubarr')-log(`lbarr'))/(invnorm(.975)*2) ])

* Display results
 
	di  _col(40)  as text "Percentiles" _col(60) "Ratio"
	di _col(1) as text  _col(30) "2.5" _col(40) "50" _col(50) "97.5" _col(60) "97.5/2.5"
	di _col(30) _dup(40) "-"
	di    _col(1) as text  "Conventional " as res _col(30) `fmt'  `lbarr'  _col(40) `fmt'  `arrdx'     _col(50) `fmt' `ubarr'  _col(60) `fmt' `ubarr'/`lbarr'

	_pctile adjrrallsys, percentiles(2.5 50 97.5)
	di    _col(1) as text  "Systematic error " as res _col(30) `fmt' r(r1)   _col(40) `fmt' r(r2)    _col(50) `fmt' r(r3)  _col(60) `fmt' r(r3)/r(r1)

	_pctile  adjrralltot , percentiles(2.5 50 97.5)
	di    _col(1) as text  "Systematic and random error " as res  _col(30) `fmt' r(r1)   _col(40) `fmt' r(r2)    _col(50) `fmt' r(r3)  _col(60) `fmt' r(r3)/r(r1)

	// Saved results
	return scalar rrdx_all_plb = r(r1)
	return scalar rrdx_all_pm = r(r2)
	return scalar rrdx_all_pub = r(r3)

	if "`name_dist_pscex'" == "" drop pscex pscun psnex psnun
	if "`name_dist_sbfactor'" == "" drop sbfactor
	if "`name_dist_pexp'" == "" drop pc1
	if "`name_dist_orce'" == "" drop orce

	gen sim_n = _n
	order sim_n adjrrallsys adjrralltot
	label var adjrrallsys "RR adjusted for systematic error"
	label var adjrralltot "RR adjusted for systematic and random error"
	label var sim_n "Simulation number"
	if ("`saving'"!="") qui save `dataname' , replace

// Graph

if ("`grprior'" != "") {

	if ("`probmie'"=="Yes") {
			
	        qui hist pseca if (pseca >= `a'/`m1')  , name(pseca, replace) frequency xtitle("Sensitivity Cases")
 	       qui hist psenc if (psenc >= `c'/`m0')  , name(psenc, replace) frequency xtitle("Sensitivity Noncases")
	        qui hist pspca if (pspca >= `b'/`m1') , name(pspca, replace) frequency xtitle("Specificity Cases")
 	       qui hist pspnc if (pspnc >= `d'/`m0') , name(pspnc, replace) frequency xtitle("Specificity Noncases")
		gr combine pseca  psenc  pspca  pspnc, name(priors_misclassification, replace)
		gr drop pseca  psenc  pspca  pspnc
      } 

	if ("`probsel'"=="Yes") {

	if ("`name_dist_pscex'"!= "") & ("`name_dist_pscun'"!= "") & ("`name_dist_psnex'"!= "") & ("`name_dist_psnun'"!= "") {
             qui hist pscex , name(pscex, replace) frequency xtitle("Selection Cases Exposed")
		qui hist pscun , name(pscun , replace) frequency xtitle("Selection Cases Unexposed")
		qui hist psnex , name(psnex, replace) frequency xtitle("Selection Noncases Exposed")
		qui hist psnun , name(psnun, replace) frequency xtitle("Selection Noncases Unxposed")
		gr combine   pscex  pscun   psnex  psnun , name(priors_selection, replace)
		gr drop pscex  pscun   psnex  psnun
	}
	else {
             qui hist sbfactor , name(sbsfactor, replace) frequency xtitle("Selection bias factor")
	}	

  	}

	if ("`probunc'"=="Yes") {

	if ("`name_dist_pexp'"!= "") & ("`name_dist_punexp'"!= "") & ("`name_dist_rrcd'"!= "")  {
             qui hist pc1 , name(pc1, replace) frequency xtitle("Prevalence confounder exposed")
		qui hist pc0 , name(pc0 , replace) frequency xtitle("Prevalence confounder unexposed")
		qui hist rrcd , name(rrcd, replace) frequency xtitle("Confounder-Disease RR") 
		gr combine   pc1  pc0   rrcd  , name(priors_confounding, replace)
		gr drop  pc1  pc0   rrcd
	}
	else {
             qui hist orce , name(orce, replace) frequency xtitle("Confounder-Exposure OR")
		qui hist pc0 , name(pc0 , replace) frequency xtitle("Prevalence confounder unexposed")
		qui hist rrcd , name(rrcd, replace) frequency xtitle("Confounder-Disease RR") 
		gr combine  orce  pc0   rrcd, name(priors_confounding, replace)
		gr drop  orce  pc0   rrcd 
	}
	
 	}


}

	local list = "$title"

	if "`grarrsys'" != "" {
		qui su adjrrallsys, d
		local p1 = r(p1)
		local p99 = r(p99)
		qui hist adjrrallsys if inrange(adjrrallsys, `p1', `p99') , name(adjrrallsys, replace)  frequency  xtitle("Simulated RR adjusted for `list'")	
	}
	
	if "`grarrtot'" != "" {
		qui su adjrralltot, d
		local p1 = r(p1)
		local p99 = r(p99)
		qui hist adjrralltot  if inrange(adjrralltot, `p1', `p99'), name(adjrralltot, replace)  frequency  xtitle("Simulated RR adjusted for `list', random error")	
	}

}

restore

end

// Sub-programs 

capture program drop episens_mie
program episens_mie, rclass
syntax [ anything ] [ ,  seec(string) spec(string)  seeo(string) speo(string) arrdx(string)  type(string) ]

	gettoken a 0 : 0, parse(" ,")
	gettoken b 0 : 0, parse(" ,")
	gettoken c 0 : 0, parse(" ,")
	gettoken d 0 : 0, parse(" ,")

	tempname fnec fpec fneo fpeo

	scalar `fnec' = 1-`seec'
	scalar `fpec' = 1-`spec'
	scalar `fneo' = 1-`seeo'
	scalar `fpeo' = 1-`speo'

// Sensitivity analysis for missclassification of the exposure
 
	tempname b1s b0s m0 b0 b1 a1 a0 rrdx bias

	scalar `b1' = (`speo'*`c'-`fpeo'*`d')/(`seeo'*`speo'-`fneo'*`fpeo')
	scalar `b0' = (`c'+`d'-`b1')
	scalar `a1' = (`spec'*`a'-`fpec'*`b')/(`seec'*`spec'-`fnec'*`fpec')
	scalar `a0' = (`a'+`b')-`a1'

	if "`type'" == "cc"  scalar `rrdx' = (`a1'*`b0')/(`b1'*`a0')  
	if "`type'" == "ir"  scalar `rrdx' = (`a1'/`b1')/(`a0'/`b0')  
	if "`type'" == "cs"  scalar `rrdx' = (`a1'/(`a1'+`b1'))/(`a0'/(`a0'+`b0'))

	scalar `bias' = (`arrdx'-`rrdx')/(`rrdx')*100  

* There are situations, depending mostly on the prevalence of the exposure, where you can get negative cell counts, and therefore negative RR
* In such situation the ranges of sens and spec among cases and non-cases are limited.

	if `rrdx' < 0 {
		di as err "Negative cell counts. Change sensitivity and specificity."
		exit 198
	}

* di `seeo' "  " `speo' "  " `fneo' "   "   `fpeo'
* di `seec' "  " `spec' "  " `fnec' "   "   `fpec'
* di  `a' " " `b' " "  `c' "  "  `d'
* di `a1' "  " `a0' "  " `b1' "  " `b0'
 
// Saved results

 	return scalar a1 = `a1'
	return scalar b1 = `a0'
	return scalar c1 = `b1'
	return scalar d1 = `b0'
	return scalar rrdx_mie = `rrdx'
	return scalar bias_mie = `bias'
end


capture program drop episens_sel
program episens_sel, rclass
version 9.2
syntax [anything]  [ ,  spscex(string) spscun(string)  spsnex(string) spsnun(string) ssbfactor(string) arrdx(string)  type(string) ]

	gettoken a 0 : 0, parse(" ,")
	gettoken b 0 : 0, parse(" ,")
	gettoken c 0 : 0, parse(" ,")
	gettoken d 0 : 0, parse(" ,")
 	
 	tempname sel_bias_factor rrdx bias
	
	if ("`ssbfactor'" == "") scalar `sel_bias_factor' = (`spscex'*`spsnun')/(`spscun'*`spsnex')
	else 	scalar `sel_bias_factor' = `ssbfactor'
	
	scalar `rrdx' = `arrdx'/`sel_bias_factor' 
	scalar `bias' = (`arrdx'-`rrdx')/(`rrdx')*100  
 
// Saved results

	return scalar rrdx_sel = `rrdx'
	return scalar bias_sel = `bias'
	return scalar sel_bf = `sel_bias_factor' 
end

capture program drop episens_unc
program episens_unc, rclass
version 9.2
syntax  [anything]  [ ,  prz1(string)  rrdz(string)   arrdx(string)  type(string) prz0(string) orze(string) ordered ]

	gettoken a 0 : 0, parse(" ,")
	gettoken b 0 : 0, parse(" ,")
	gettoken c 0 : 0, parse(" ,")
	gettoken d 0 : 0, parse(" ,")
 
	tempname  rrdx rrxz  bias id b11 b01 a11 a01  
   
if "`orze'" != "" {	
  	 scalar `rrdx' = `arrdx'/[ (`rrdz'*`orze'*`prz0'+1-`prz0') / ( (`rrdz'*`prz0'+1-`prz0')*( `orze'*`prz0'+1-`prz0') ) ]
}

/*
	 // To be able to re-calculate the cell counts we need to back-calculate the prevalence of the confounder among the exposed - prz1
	 // I use a simple iterative method  

	 tempname oz1 oz0  
	 scalar `oz0' = [`prz0'/(1-`prz0')]	
       local prz1 = .

	 forv i = 0(.01)1 {
		   scalar `oz1' = [`i'/(1-`i')]
		  * di "prz1 = " `i'  "    Diff =  " abs(`oz1' - (`orze'*`oz0') )
		   if abs(`oz1' - (`orze'*`oz0') ) < 1e-2  {
				 local prz1 = `i'
				 continue, break
		   }
	 }

	 if `prz1' == . {
		di as err "Not able to back-calculate the Pr(c=1|e=1)"
		exit 198
	}	

*/

 if "`prz1'" != "" & "`orze'" == "" & "`ordered'" == "" {	
  	 scalar `rrxz' = [(`prz1')*(1-`prz0')]/[(1-`prz1')*(`prz0')] 
 	 scalar `b11' = `prz1' * `c'  
	 scalar `b01' = `prz0' * `d'  
	 scalar `a11' = (`rrdz'*`a'*`b11')/(`rrdz'*`b11' +`c'-`b11')  
	 scalar `a01' = (`rrdz'*`b'*`b01')/(`rrdz'*`b01'+`d'-`b01') 

	if "`type'" == "cc"  scalar `rrdx' = (`a11'*`b01')/(`b11'*`a01')  
	if "`type'" == "ir"  scalar `rrdx' = (`a11'/`b11')/(`a01'/`b01')  
	if "`type'" == "cs"  scalar `rrdx' = (`a11'/(`a11'+`b11'))/(`a01'/(`a01'+`b01'))

 	return scalar a1 = `a11'
	return scalar b1 = `a01'
	return scalar c1 = `b11'
	return scalar d1 = `b01'
 }

if "`prz1'" != "" & "`orze'" == "" & "`ordered'" != "" {	
	 scalar `rrdx' =  `arrdx' / [ (`prz1'*(`rrdz'-1)+1 )/(`prz0'*(`rrdz'-1)+1 ) ]  
}


// Saved results

	scalar `bias' = (`arrdx'-`rrdx')/(`rrdx')*100  
	return scalar rrdx_unc = `rrdx'
	return scalar bias_unc = `bias'
end

capture program drop check_dist_bp
program check_dist_bp, rclass
version 9.2

syntax [ anything ] [, dist(string)]   

gettoken name_dist numb_dist:  dist   	  , parse("(") match(par)  
gettoken numb_dist 	     :  numb_dist   , parse("(") match(par)  

* di in y  "`dist'"
*di as text "`name_dist'"
*di as text "`numb_dist'"

local wn : word count `numb_dist' 

tokenize `numb_dist'

if substr("`name_dist'",1,1) == "c" {
			local distribution_bp = "Constant"
			return scalar c = `1'
			return local distribution_ns =  "`1'"
}

if substr("`name_dist'",1,3) == "uni" {
 
	if `wn' != 2 {
	  		di as err "Specify correctly the parameters of the distribution"
	 	 	exit 198
	} 
	
			local distribution_bp = "Uniform"
			local a = `1'
			local b = `2'
		
			if `a' >= `b' {
					di as err "Choose a Uniform with a < b"
					exit 198
			}

	return scalar a = `a'
	return scalar b = `b'
	return local distribution_ns =  "`a' `b'"
}

if substr("`name_dist'",1,3) == "tri" {

	if `wn' != 3 {
	  		di as err "Specify correctly the parameters of the distribution"
	 	 	exit 198
	} 

			local distribution_bp = "Triangular"
			local a = `1'
			local b = `2'
			local c = `2'
			local d = `3'

			if inrange(`b', `a', `d')!= 1 {
					di as err "Choose a Triangular with a < b < c"
					exit 198
			}

	return scalar a = `a'
	return scalar b = `b'
	return scalar c = `c'
	return scalar d = `d'	
	return local distribution_ns = "`a' `b' `c' `d'"
}
			
if substr("`name_dist'",1,3) == "tra" {

	if `wn' != 4 {
	  		di as err "Specify correctly the parameters of the distribution"
	 	 	exit 198
	} 
			local distribution_bp = "Trapezoidal"
			local a = `1'
			local b = `2'
			local c = `3'
			local d = `4'

			if inrange(`b', `a', `d')!= 1 {
					di as err "Choose a Trapezoidal with a < b < c < d"
					exit 198
			}

	return scalar a = `a'
	return scalar b = `b'
	return scalar c = `c'
	return scalar d = `d'	
	return local distribution_ns = "`a' `b' `c' `d'"
}

if substr("`name_dist'",1,5) == "logis" {
 
	if `wn' != 2 {
	  		di as err "Specify correctly the parameters of the distribution"
	 	 	exit 198
	} 
	
			local distribution_bp = "Logistic"
			return scalar m = `1'
			return scalar s = `2'
			return local distribution_ns = "`1' `2'"
}

if substr("`name_dist'",1,7) == "logit-n" {
 
	if inlist(`wn',2,4) != 1 {
	  		di as err "Specify correctly the parameters of the distribution"
	 	 	exit 198
	} 	
			local distribution_bp = "Logit-Normal"
			return scalar m = `1'
			return scalar s = `2'
			return scalar boundaries = 0
			return scalar lb = 0
			return scalar ub = 1
			return local distribution_ns = "`1' `2' 0 1"

	if `wn' == 4 {
		return scalar boundaries = 1

		if inrange(`3',0,1) == 1  & inrange(`4',0,1) {
			return scalar lb = `3' 
			return scalar ub = `4'
			return local distribution_ns = "`1' `2' `3' `4'"
		}
		else {
			di as err "Specify correctly the parameters of the distribution"
	 	 	exit 198
		}
			
	}

}

if substr("`name_dist'",1,7) == "logit-l" {
 
	if inlist(`wn',2,4) != 1 {
	  		di as err "Specify correctly the parameters of the distribution"
	 	 	exit 198
	} 
	
			local distribution_bp = "Logit-Logistic"
			return scalar m = `1'
			return scalar s = `2'
			return scalar boundaries = 0
			return scalar lb = 0
			return scalar ub = 1
			return local distribution_ns = "`1' `2' 0 1"

	if `wn' == 4 {
		return scalar boundaries = 1

		if inrange(`3',0,1) == 1  & inrange(`4',0,1) {
			return scalar lb = `3' 
			return scalar ub = `4'
			return local distribution_ns = "`1'  `2' `3' `4'"
		}
		else {
			di as err "Specify correctly the parameters of the distribution"
	 	 	exit 198
		}
			
	}
	
}

if substr("`name_dist'",1,5) == "log-l" {
 
	if `wn' != 2 {
	  		di as err "Specify correctly the parameters of the distribution"
	 	 	exit 198
	} 
	
			local distribution_bp = "Log-Logistic"
			return scalar m = `1'
			return scalar s = `2'
			return local distribution_ns = "`1' `2'"
}

if substr("`name_dist'",1,5) == "log-n" {
 
	if inlist(`wn',2) != 1 {
	  		di as err "Specify correctly the parameters of the distribution"
	 	 	exit 198
	} 
	
			local distribution_bp = "Log-Normal"
			return scalar m = `1'
			return scalar s = `2'
			return local distribution_ns =  "`1' `2'"
}

* Return the understood distribution of the bias parameter

return local distribution_bp =  "`distribution_bp'" 
end
