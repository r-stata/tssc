*! Version 1.0
*! Chris Nelson 19/May/2008

program strsrcs,  sortpreserve
	version 9.0
	if replay()   ///
	{
		syntax  [, DF(int 0) KNOTS(string) BHAZard(varname numeric) ORTHOG EForm *]
		if `df' > 0 | "`knots'" != "" | "`bhazard'" != "" ///
		{
			Estimate`0'
		}
		else if (`"`e(cmd)'"' != "strsrcs") error 301
		else Replay `0'
	}
	else Estimate `0'
end

program Estimate, eclass
	st_is 2 analysis
	syntax 	[varlist(default=empty)]  [if] [in] ///
		[, DF(int 0) KNOTS(string) SCale(string) BHAZard(varname numeric) STRATA(varlist) ORTHOG NOCONStant SNOCONStant INITS(name) EForm] ///
		[				///
		noLOg				/// -ml model- options
		noLRTEST			/// 
		Level(integer `c(level)')	/// -Replay- option
		*				/// -mlopts- options
	]
	tempvar lnt lnt0	
	tempname initmat

	marksample touse
	mlopts mlopts, `options'

	qui replace `touse' = 0  if _st==0

************ DROP EXISTING _RCS AND _D_RCS VARIABLES

capture drop _rcs* 
capture drop _d_rcs* 	
capture drop _s0_rcs*
  
************ CHECK IF DF OR KNOTS PRESENT

	if "`df'"== "0" & "`knots'" == "" ///
	{
		display as error "DF or KNOTS must be specified"
		exit
	}

************ CHECK BASELINE HAZARD IS SPECIFIED

	if "`bhazard'" == "" ///
	{
		display as error "The baseline hazard must be specified"
		exit
	}


************ CHECK FOR MISSING VALUES

	if `touse' & missing(`bhazard')==1 ///
	{
		display as error "The baseline hazard contains missing values"
		exit
	}


************ CHECK TIME ORIGIN FOR DELAYED ENTRY MODELS
				
	local del_entry = 0
	qui summ _t0 if `touse' , meanonly
	if r(max)>0 ///
	{
		display in green  "note: delayed entry models are being fitted"
		local del_entry = 1
	}


************ DEFINE KNOTS 

	gen `lnt' = ln(_t)
	tokenize `knots'
	local temp0 : word count `knots'

************ CHECK ONLY DF OR KNOTS IS SPECIFIED

	if `df'>0 & `temp0'>0 ///
	{
		display as error "Only one of DF OR KNOTS can be specified"
		exit
	}

************ CHECK SCALE OPTION SPECIFIED

	if "`scale'" =="" ///
	{
		display as error "The scale must be specified"
		exit
	}

************ DEFINE SCALE USING SUBSTR

	if substr("`scale'", 1, 1)=="h" ///
	{
		local _sc=`"Hazard"'
	}
	else if substr("`scale'", 1, 1)=="o" ///
	{
		local _sc=`"Odds"'
	}
************ CHECK SCALE OPTION SPECIFIED

	else ///
	{
		display as error "The scale must be specified as either hazard or odds"
		exit
	}

************ CALCULATE KNOT PLACEMENT

	if `temp0'==0 ///
	{
		if `df'==2 ///
		{
			qui centile `lnt' if `touse' & _d==1, centile(0 50 100) 
			local allknots  `r(c_1)' `r(c_2)' `r(c_3)' 
		}
		else if `df'==3 ///
		{
			qui centile `lnt' if `touse' & _d==1, centile(0 33 67 100) 
			local allknots  `r(c_1)' `r(c_2)' `r(c_3)' `r(c_4)' 
		}
		else if `df'==4 ///	
		{
			qui centile `lnt' if `touse' & _d==1, centile(0 25 50 75 100) 
			local allknots  `r(c_1)' `r(c_2)' `r(c_3)' `r(c_4)' `r(c_5)'
		}
		else if `df'==5 ///
		{
			qui centile `lnt' if `touse' & _d==1, centile(0 20 40 60 80 100) 
			local allknots  `r(c_1)' `r(c_2)' `r(c_3)' `r(c_4)' `r(c_5)' `r(c_6)'
		}

		else if `df'==6 ///
		{
			qui centile `lnt' if `touse' & _d==1, centile(0 17 33 50 67 83 100) 
			local allknots  `r(c_1)' `r(c_2)' `r(c_3)' `r(c_4)' `r(c_5)' `r(c_6)' `r(c_7)'
		}
		else ///
		{
			display as error "DF must be between 2 and 6"
			exit
		}
	}

	else ///
	{
		qui centile `lnt' if `touse' & _d==1, centile(0 `knots' 100)
		local temp1 = `temp0' + 2
		forvalues i = 1/`temp1' ///
		{
			local allknots "`allknots' `r(c_`i')'"
		}
	}	
  

************ CALL RCS AND RCSDERIV TO CALCULATE SPLINES

	if "`orthog'" != "" ///
	{
		rcs `lnt' if `touse', knots(`allknots') gen(_rcs) dgen(_d_rcs) orthog
	}

	if "`orthog'" == "" ///
	{
		rcs `lnt' if `touse', knots(`allknots') gen(_rcs) dgen(_d_rcs) 
	}

	if `del_entry' == 1 ///
	{
		qui gen `lnt0' = ln(_t0) if _t0>0
		qui rcs `lnt0', knots(`allknots') gen(_s0_rcs)
	}
	local nk : word count `allknots'
	local df = `nk' - 1


************ NOCONSTANT OPTION FOR LINEAR PREDICTOR AND FOR STRATA

	if "`noconstant'" != "" ///
	{
        	local xb_nocons = `", noconstant"'
	}

	if "`snoconstant'" != "" ///
	{
        	local strata_nocons = `", noconstant"'
        	local xb_nocons = `", noconstant"'
	}

************ DEFINE MODEL TERMS

	local loopmax = `nk' - 1
	forvalues i = 1/`loopmax' ///
	{
		local rcsterms "`rcsterms' _rcs`i'"
		local drcsterms "`drcsterms' _d_rcs`i'"
		local rcseq "`rcseq' (s`i': `strata' `strata_nocons')" 
	}

************ OBTAIN INITIAL VALUES 

	if "`_sc'" =="Hazard" ///
	{
		if "`inits'" == "" ///
		{
			display in green "Obtaining Initial Values"
			qui ml model lf strsrcs_mlh (xb: _rcs1 `bhazard' = `strata' `varlist' `xb_nocons') ///
			(s1: `strata' `strata_nocons') , `mlopts' maximize
			matrix `initmat' = e(b)
			display in green "Initial Values Obtained"
		}
		else matrix `initmat' = `inits'
	}
	else if "`_sc'" =="Odds" ///
	{
		if "`inits'" == "" ///
		{
			display in green "Obtaining Initial Values"
			qui ml model lf strsrcs_mlo (xb: _rcs1 `bhazard' = `strata' `varlist' `xb_nocons') ///
			(s1: `strata' `strata_nocons') , `mlopts' maximize
			matrix `initmat' = e(b)
			display in green "Initial Values Obtained"
		}
		else matrix `initmat' = `inits'
	}

************ FIT THE MODEL

	if "`_sc'" =="Hazard" ///
	{
	ml model lf strsrcs_mlh ///
		(xb:`rcsterms' `bhazard'=`strata' `varlist' `xb_nocons') `rcseq'  ///
		if `touse' ,  ///
		init(`initmat	') ///
		`mlopts' ///
		maximize 
	}
	else if "`_sc'" =="Odds" ///
	{
	ml model lf strsrcs_mlo ///
		(xb:`rcsterms' `bhazard'=`strata' `varlist' `xb_nocons') `rcseq'  ///
		if `touse' ,  ///
		init(`initmat	') ///
		`mlopts' ///
		maximize 
	}

	ereturn local rcs_xb `rcsterms'
	ereturn local drcs_xb `drcsterms'
	ereturn local knots `allknots'
	ereturn local df `df'
	ereturn local predict strsrcs_pred
	ereturn local cmd strsrcs
	ereturn local depvar "_d _t"
	ereturn local strata `strata'
	ereturn local varlist `varlist'
	ereturn local bhazard `bhazard'
	ereturn local scale `_sc'
	Replay, level(`level') `eform'
end

program Replay
	syntax [, Level(int `c(level)') EForm]
	ml display, level(`level') `eform'
end


