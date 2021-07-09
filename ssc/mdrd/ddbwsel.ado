*!version 26May2017, Rafael Ribas

capture program drop ddbwsel
program define ddbwsel, eclass
	version 12
	syntax varlist(min=2 num ts) [if] [in] [aweight/], [ Time(varname numeric) ///
		nocut c(real 0) Deriv(integer 0) p(integer 1) q(integer 0) KERnel(string) ///
		HETer(varlist numeric ts) at(numlist) BWSelect(string) rho(real 0) ///
		vce(string) Matches(integer 3) SCALERegul(real 1) ///
		all NOWARNing control(varlist numeric fv ts) precalc ]
		
	local kernel = lower("`kernel'")
	local bwselect = upper("`bwselect'")
	local vce = lower("`vce'")

	marksample touse

	if ("`control'" != "") {
		qui foreach v of varlist `control' {
			replace `touse'=0 if `v'==.
        }
    }
	if ("`time'" != "") qui replace `touse'=0 if `time'==.
	if ("`heter'" != "") {
		qui foreach v of varlist `heter' {
			replace `touse'=0 if `v'==.
        }
    }

	preserve
	qui keep if `touse'
	tokenize "`varlist'"
	local y `1'
	local x `2'

	* Hetervar dimension
	if ("`heter'" != "") loc hdim = wordcount("`heter'")
	else loc hdim = 0
	
    if ("`precalc'"=="") {

        * Time != {0,1}
        if ("`time'" != "") {
            qui drop if `time'==.
    
            tempname A
            cap qui ta `time', matrow(`A')
            if (_rc==0 & r(r)<=2) { 
                if ((`A'[1,1]!=0 & `A'[1,1]!=1) | (`A'[2,1]!=1 & `A'[2,1]!=.)) {
                    di "{err}{cmd:time()} should have values 0 and 1"  
                    exit 125
                }
            }
            else {
                di "{err}{cmd:time()} should have values 0 and 1"  
                exit 125
            }
        }
		
		* #Hetervars = #at points
		if ("`heter'" != "") {
			if "`at'" == "" {
				forvalues i = 1/`hdim' {
					local at "`at' 0"
				}
			}
			if (`hdim' < wordcount("`at'")) {
				di "{err}More points in {command}at() {err}than {inp:{it:hetervars}}"
				exit 102
			}
			if (`hdim' > wordcount("`at'")) {
				di "{err}Less points in {command}at() {err}than {inp:{it:hetervars}}"
				exit 103
			}
		}
    }
	
	* Heter points matrix
	if ("`heter'" != "") {
        tempname AT
        mat `AT' = real(word("`at'",1))
		if `hdim' > 1 {
			forvalues i = 2/`hdim' {
				mat `AT' = `AT', real(word("`at'",`i'))
			}
		}
	}
    
	* Sample weight
	tempvar wgt
	if ("`exp'"=="") { 
		g `wgt' = 1
	}
	else {
		qui su `exp' if `exp'>0
		qui g `wgt' = `exp'/r(mean) if `exp'>0
	}

	tempvar x_l0 x_r0 x_l1 x_r1 axc
	local b_calc = 0

	if (`rho'==0){
		local b_calc = 1
		local rho = 1
	}
	g `axc' = abs(`x' - `c')
	
    if ("`time'"!="") {
        if ("`cut'"=="") {
            qui su `axc' if `x'<`c' & `time'==0 [aw=`wgt'], d
            local medX_l0 = r(p50)
            qui su `axc' if `x'>=`c' & `time'==0 [aw=`wgt'], d
            local medX_r0 = r(p50)

            qui su `axc' if `x'<`c' & `time'==1 [aw=`wgt'], d
            local medX_l1 = r(p50)
            qui su `axc' if `x'>=`c' & `time'==1 [aw=`wgt'], d
            local medX_r1 = r(p50)

            qui gen `x_l0' = `x' if `x'<`c' & `time'==0
            qui gen `x_r0' = `x' if `x'>=`c' & `time'==0

            qui gen `x_l1' = `x' if `x'<`c' & `time'==1
            qui gen `x_r1' = `x' if `x'>=`c' & `time'==1
        }
        else {
            qui su `axc' if `time'==0 [aw=`wgt'], d
            local medX_r0 = r(p50)

            qui su `axc' if `time'==1 [aw=`wgt'], d
            local medX_r1 = r(p50)

            qui gen `x_r0' = `x' if `time'==0
            qui gen `x_r1' = `x' if `time'==1

            local medX_l1 = 0
            local medX_l0 = 0
        }
    }
    else {
        qui su `axc' if `x'<`c' [aw=`wgt'], d
        local medX_l1 = r(p50)
        qui su `axc' if `x'>=`c' [aw=`wgt'], d
        local medX_r1 = r(p50)

        qui gen `x_l1' = `x' if `x'<`c'
        qui gen `x_r1' = `x' if `x'>=`c'

        local medX_r0 = 0
        local medX_l0 = 0
    }

	qui su `x_r1'
	local N_r1 = r(N)
	local range_r1 = abs(r(max)-r(min))

    local N = `N_r1'
    local N_r0 = 0
    local N_l0 = 0
    local N_l1 = 0
    local range_r0 = `range_r1'
    local range_l0 = `range_r1'
    local range_l1 = `range_r1'

    if ("`time'"!="") {
        qui su `x_r0'
        local N_r0 = r(N)
        local range_r0 = abs(r(max)-r(min))
        local N = `N' + `N_r0'

        if ("`cut'"=="") {
            qui su `x_l0'
            local N_l0 = r(N)
            local range_l0 = abs(r(max)-r(min))
            local N = `N' + `N_l0'
        }
    }
    if ("`time'"=="" | "`cut'"=="") {
        qui su `x_l1'
        local N_l1 = r(N)
        local range_l1 = abs(r(max)-r(min))
        local N = `N' + `N_l1'
    }

	if ("`precalc'"=="") {
	
		* Heterogeneity at at()
		if ("`heter'" != "") {
			forvalues i = 1/`hdim' {
				tempname h`i'
				loc hh = word("`heter'",`i')
				g `h`i'' = `hh'
				qui su `h`i''
				loc h_min = r(min)
				loc h_max = r(max)
				loc h_sd = r(sd)
				loc hsd`i' = max((`h_min' - `AT'[1,`i']), max(0,(`AT'[1,`i']- `h_max')))/`h_sd'
			}	
		}
	
        qui su `x'
        local x_min = r(min)
        local x_max = r(max)
    
        if (`deriv'>0 & `p'==1 & `q'==0){
            local p = `deriv'+1
        }
    
        if (`q'==0) {
            local q = `p'+1
        }
    
        **************************** ERRORS
        if ((`c'<=`x_min' | `c'>=`x_max') & "`cut'"==""){
            di "{err}{cmd:c()} should be set within the range of `x'"  
            exit 125
        }
    
        if ((`N_l0'>0 & `N_l0'<10) | (`N_r0'>0 & `N_r0'<10) | (`N_l1'>0 & `N_l1'<10) | ///
			(`N_r1'>0 & `N_r1'<10)) {
            di "{err}Not enough observations to perform calculations"  
            exit 2001
        }
    
        if (`p' > 8){
            di "{err}{cmd:p()} should be less or equal than 8 for this version of the software package"  
            exit 125
        }
    
        if ("`kernel'"~="uni" & "`kernel'"~="uniform" & "`kernel'"~="tri" & ///
			"`kernel'"~="triangular" & "`kernel'"~="epa" & "`kernel'"~="epanechnikov" & "`kernel'"~="" ){
            di "{err}{cmd:kernel()} incorrectly specified"  
            exit 7
        }
    
        if ("`bwselect'"~="CCT" & "`bwselect'"~="IK" & "`bwselect'"~=""){
            di "{err}{cmd:bwselect()} incorrectly specified"  
            exit 7
        }
    
        if ("`vce'"~="resid" & "`vce'"~="nn" & "`vce'"~=""){ 
            di "{err}{cmd:vce()} incorrectly specified"  
            exit 7
        }

        if (`p'<0 | `q'<=0 | `deriv'<0 | `matches'<=0 | `scaleregul'<0) {
            di "{err}{cmd:p()}, {cmd:q()}, {cmd:deriv()}, {cmd:matches()} and {cmd:scaleregul()} should be positive"  
            exit 411
        }
    
        if (`p'>=`q' & `q'>0){
            di "{err}{cmd:q()} should be greater than {cmd:p()}"  
            exit 125
        }
    
        if (`deriv'>`p' & `deriv'>0){
            di "{err}{cmd:deriv()} cannot be greater than {cmd:p()}"  
            exit 125
        }
    
        if (`rho'>1 | `rho'<0){
            di "{err}{cmd:rho()}should be set between 0 and 1"  
            exit 125
        }

        if ("`kernel'"=="epanechnikov" | "`kernel'"=="epa") {
            local kernel_type = "Epanechnikov"
        }
        else if ("`kernel'"=="uniform" | "`kernel'"=="uni") {
            local kernel_type = "Uniform"
        }
        else  {
            local kernel_type = "Triangular"
        }
    }
    
    * Constant
	local p1 = `p' + 1
	local q1 = `q' + 1

	if ("`kernel'"=="epanechnikov" | "`kernel'"=="epa") {
			local kid = 3
			local C_pilot = 2.34
	}
	else if ("`kernel'"=="uniform" | "`kernel'"=="uni") {
			local kid = 2
			local C_pilot = 1.84
	}
	else  {
			local kid = 1
			local C_pilot = 2.58
	}

	kconst `p' `deriv' `kid'
	local C1_h = e(C1)
	local C2_h = e(C2)
	kconst `q' `q' `kid'
	local C1_b = e(C1)
	local C2_b = e(C2)
	kconst `q1' `q1' `kid'
	local C1_q = e(C1)
	*local C2_q = e(C2)

	kconst `q' `q' 2
	local C1_b_uni = e(C1)
	local C2_b_uni = e(C2)
	kconst `q1' `q1' 2
	local C1_q_uni = e(C1)
	local C2_q_uni = e(C2)

	qui su `x' [aw=`wgt'], d
	local h_pilot_CCT = `C_pilot'*min(r(sd),(r(p75)-r(p25))/1.349)*r(N)^(-1/5)
	
	** MATA function

	mata bwselect("`y'", "`x'", "`wgt'", "`time'", "`cut'", "`heter'", "`AT'", `c', `deriv', ///
		`p', `q', `h_pilot_CCT', `C1_h', `C2_h', `C1_b', `C2_b', `C1_q', `C1_b_uni', ///
		`C2_b_uni', `C1_q_uni', `C2_q_uni', `N_l0', `N_r0', `N_l1', `N_r1', `N', `matches', ///
		"`vce'", "`kernel'", `scaleregul', `b_calc', `rho', "`bwselect'", ///
		"`all'", `medX_r1', `medX_l1', `medX_r0', `medX_l0')

	restore

	*******************************************************************************
	
	if ("`exp'"!="") ereturn post [aw=`exp'], esample(`touse') obs(`N')
	else 			 ereturn post, esample(`touse') obs(`N')
	
	loc cr = string(`c',"%7.0g")
	
	disp ""
	if (`deriv'>0) disp in smcl in gr "Bandwidth estimators for local polynomial regression. Derivative of order `deriv'." 
	else disp in smcl in gr "Bandwidth estimators for local polynomial regression" 
	disp ""
	disp ""
    if ("`time'"=="") {
        disp in smcl in gr "{ralign 21: Cutoff c = `cr'}"      _col(22) " {c |} " _col(23) in gr "{ralign 10: Left of c}" _col(36) in gr "{ralign 10: Right of c}" _col(61) in gr "Number of obs  = "  in yellow %10.0f `N'

        if ("`all'"!="" | "`bwselect'"=="CCT") {
		   disp in smcl in gr "{hline 22}{c +}{hline 22}"                                                                                  						  _col(61) in gr "NN matches     = "  in yellow %10.0f `matches'
           disp in smcl in gr "{ralign 21:Number of obs}"     _col(22) " {c |} " _col(23) as result %9.0f `N_l1'   _col(37) %9.0f  `N_r1'                         _col(61) in gr "Kernel type    = "  in yellow "{ralign 10:`kernel_type'}" 
        }
		else {
		   disp in smcl in gr "{hline 22}{c +}{hline 22}"                                                                                  						  _col(61) in gr "Kernel type    = "  in yellow "{ralign 10:`kernel_type'}" 
           disp in smcl in gr "{ralign 21:Number of obs}"     _col(22) " {c |} " _col(23) as result %9.0f `N_l1'   _col(37) %9.0f  `N_r1'
		}
		
		disp in smcl in gr "{ralign 21:Order loc. poly. (p)}" _col(22) " {c |} " _col(23) as result %9.0f `p'        _col(37) %9.0f  `p'                              
        disp in smcl in gr "{ralign 21:Order bias (q)}"       _col(22) " {c |} " _col(23) as result %9.0f `q'        _col(37) %9.0f  `q'  
        disp in smcl in gr "{ralign 21:Range of `x'}"         _col(22) " {c |} " _col(23) as result %9.0g `range_l1'  _col(37) %9.0g  `range_r1'

        ereturn scalar N_l = `N_l1'
        ereturn scalar N_r = `N_r1'
		ereturn scalar range_l = `range_l1'
        ereturn scalar range_r = `range_r1'
    }
    if ("`time'"!="" & "`cut'"!="") {
        disp in smcl in gr "{ralign 21: Reference c = `cr'}"   _col(22) " {c |} " _col(23) in gr "{ralign 10: Time 0}" _col(36) in gr "{ralign 10: Time 1}" _col(61) in gr "Number of obs  = "  in yellow %10.0f `N'

		if ("`all'"!="" | "`bwselect'"=="CCT") {
            disp in smcl in gr "{hline 22}{c +}{hline 22}"                                                                                                 _col(61) in gr "NN matches     = "  in yellow %10.0f `matches'
            disp in smcl in gr "{ralign 21:Number of obs}"    _col(22) " {c |} " _col(23) as result %9.0f `N_r0'   _col(37) %9.0f  `N_r1'                  _col(61) in gr "Kernel type    = "  in yellow "{ralign 10:`kernel_type'}" 
		}
		else {
            disp in smcl in gr "{hline 22}{c +}{hline 22}"                                                                                                 _col(61) in gr "Kernel type    = "  in yellow "{ralign 10:`kernel_type'}" 
            disp in smcl in gr "{ralign 21:Number of obs}"    _col(22) " {c |} " _col(23) as result %9.0f `N_r0'   _col(37) %9.0f  `N_r1'
		}

        disp in smcl in gr "{ralign 21:Order loc. poly. (p)}" _col(22) " {c |} " _col(23) as result %9.0f `p'        _col(37) %9.0f  `p'
        disp in smcl in gr "{ralign 21:Order bias (q)}"       _col(22) " {c |} " _col(23) as result %9.0f `q'        _col(37) %9.0f  `q'
        disp in smcl in gr "{ralign 21:Range of `x'}"         _col(22) " {c |} " _col(23) as result %9.0g `range_r0'  _col(37) %9.0g  `range_r1'

        ereturn scalar N_0 = `N_r0'
        ereturn scalar N_1 = `N_r1'
		ereturn scalar range_0 = `range_r0'
        ereturn scalar range_1 = `range_r1'
    }
    if ("`time'"!="" & "`cut'"=="") {
        disp in smcl in gr "{ralign 21: Cutoff c = `cr'}"   _col(22) " {c |} " _col(23) in gr "{ralign 10: Left of c}" _col(36) in gr "{ralign 10: Right of c}" _col(61) in gr "Number of obs  = "  in yellow %10.0f `N'

		if ("`all'"!="" | "`bwselect'"=="CCT") {
			disp in smcl in gr "{hline 22}{c +}{hline 22}"                                                                                                     _col(61) in gr "NN matches     = "  in yellow %10.0f `matches'
			disp in smcl in gr "{ralign 21:Number of obs, t = 0}" _col(22) " {c |} " _col(23) as result %9.0f `N_l0'   _col(37) %9.0f  `N_r0'                  _col(61) in gr "Kernel type    = "  in yellow "{ralign 10:`kernel_type'}" 
		}
		else {
			disp in smcl in gr "{hline 22}{c +}{hline 22}"                                                                                                     _col(61) in gr "Kernel type    = "  in yellow "{ralign 10:`kernel_type'}"
			disp in smcl in gr "{ralign 21:Number of obs, t = 0}" _col(22) " {c |} " _col(23) as result %9.0f `N_l0'   _col(37) %9.0f  `N_r0'
		}
        disp in smcl in gr "{ralign 21:Number of obs, t = 1}" _col(22) " {c |} " _col(23) as result %9.0f `N_l1'   _col(37) %9.0f  `N_r1' 
        disp in smcl in gr "{ralign 21:Order loc. poly. (p)}" _col(22) " {c |} " _col(23) as result %9.0f `p'        _col(37) %9.0f  `p'
        disp in smcl in gr "{ralign 21:Order bias (q)}"       _col(22) " {c |} " _col(23) as result %9.0f `q'        _col(37) %9.0f  `q'  
        disp in smcl in gr "{ralign 21:Range of `x', t = 0}"  _col(22) " {c |} " _col(23) as result %9.0g `range_l0'  _col(37) %9.0g  `range_r0'
        disp in smcl in gr "{ralign 21:Range of `x', t = 1}"  _col(22) " {c |} " _col(23) as result %9.0g `range_l1'  _col(37) %9.0g  `range_r1'

        ereturn scalar N_l0 = `N_l0'
        ereturn scalar N_r0 = `N_r0'
        ereturn scalar N_l1 = `N_l1'
        ereturn scalar N_r1 = `N_r1'
		ereturn scalar range_l0 = `range_l0'
		ereturn scalar range_r0 = `range_r0'
        ereturn scalar range_l1 = `range_l1'
        ereturn scalar range_r1 = `range_r1'
    }
	disp ""
	disp in smcl in gr "{hline 10}{c TT}{hline 35}" 
	disp in smcl in gr "{ralign 9:Method}"   _col(10) " {c |} " _col(18) "{ralign 3:h}" _col(30) "{ralign 3:b}" _col(41) "{ralign 6: rho}" _n  "{hline 10}{c +}{hline 35}"
	if ("`bwselect'"=="IK" & "`all'"=="")  {
		disp in smcl in gr "{ralign 9:IK}"      _col(10) " {c |} " _col(11) in ye %9.0g h_IK  _col(25) in ye %9.0g b_IK  _col(38) in ye %9.0g h_IK/b_IK
	}
	if ("`all'"~="") {
		disp in smcl in gr "{ralign 9:CCT}"     _col(10) " {c |} " _col(11) in ye %9.0g h_CCT _col(25) in ye %9.0g b_CCT _col(38) in ye %9.0g h_CCT/b_CCT
		disp in smcl in gr "{ralign 9:IK}"      _col(10) " {c |} " _col(11) in ye %9.0g h_IK  _col(25) in ye %9.0g b_IK  _col(38) in ye %9.0g h_IK/b_IK
	}
	if (("`bwselect'"=="" | "`bwselect'"=="CCT") & "`all'"=="") {
		disp in smcl in gr "{ralign 9:CCT}"      _col(10) " {c |} " _col(11) in ye %9.0g h_CCT _col(25) in ye %9.0g b_CCT _col(38) in ye %9.0g h_CCT/b_CCT
	}
	disp in smcl in gr "{hline 10}{c BT}{hline 35}"
	
	if ("`heter'"!="") {
		loc a = `AT'[1,1]
		loc aa = word("`heter'",1)
		local hvars "Bandwidths for effect at `aa' = `a'"
		if `hdim' > 1 {
			forvalues i = 2/`hdim' {
				loc a = `AT'[1,`i']
				loc aa = word("`heter'",`i')
				local hvars "`hvars', `aa' = `a'"
			}
		}
		loc hvars "`hvars'."
		disp in yellow  "`hvars'" 
	}

	if ("`warning'"=="" & "`precalc'"=="") {
		if ("`control'"!="") {
			disp in ye "WARNING: The estimated bandwidths do not control for `control'."
		}
		if ("`heter'"!="") {
			forvalues i = 1/`hdim' {
				loc a = `AT'[1,`i']
				loc aa = word("`heter'",`i')
				if (`hsd`i''>=1) disp in red "WARNING: {cmd:at(}{inp:`a'}{cmd:)} is `hsd`i'' std. dev. out of {inp:`aa'} range."
				else if (`hsd`i''>0) disp in ye "WARNING: {cmd:at(}{inp:`a'}{cmd:)} is `hsd`i'' std. dev. out of {inp:`aa'} range."
			}
		}
		
	}	

	ereturn scalar c = `c'
	ereturn scalar p = `p'
	ereturn scalar q = `q'
	ereturn scalar deriv = `deriv'
	if ("`heter'" != "") {
		if (`hdim'>1) {
			mat rown `AT' = at
			mat coln `AT' = `heter'
			ereturn matrix at = `AT'
		}
		else	ereturn scalar at = `AT'[1,1]
	}
	
	loc bw
	if ("`bwselect'"=="CCT" | "`bwselect'"=="" | "`all'"~="") {
		loc bw "CCT"
		ereturn scalar matches = `matches'
		ereturn scalar h_CCT = h_CCT
		ereturn scalar b_CCT = b_CCT
		ereturn scalar rho_CCT = h_CCT/b_CCT
	}
	if ("`bwselect'"=="IK" | "`all'"~="") {
		loc bw = trim("`bw' IK")
		ereturn scalar h_IK   = h_IK
		ereturn scalar b_IK   = b_IK
		ereturn scalar rho_IK = h_IK/b_IK
	}
	ereturn local kernel "`kernel_type'"
	ereturn local bwselect "`bw'"

	if ("`vce'" == "resid") ereturn local vce "resid"
	else 					ereturn local vce "nn"

	if ("`heter'"   != "") ereturn local heter     "`heter'"
	if ("`time'"    != "") ereturn local time 	   "`time'"

	ereturn local runningvar "`x'"
	ereturn local depvar 	"`y'"

	mata rmexternal("bwselect")

end

cap mata: mata drop bwselect()
mata 
void bwselect(y, x, wgt, time, cut, heter, at, c, deriv, p, q, h_pilot_CCT, ///
	C1_h, C2_h, C1_b, C2_b, C1_q, C1_b_uni, C2_b_uni, C1_q_uni, ///
	C2_q_uni, N_l0, N_r0, N_l1, N_r1, N, matches, vce, kernel, scaleregul, ///
	b_calc, rho, bwselect, all, medX_r1, medX_l1, medX_r0, medX_l0)
{
	p1 = p+1;	q1 = q+1;	p2 = p+2;	q2 = q+2;	q3 = q+3
	Y = st_data(.,(y), 0);	X = st_data(.,(x), 0)
	W = st_data(.,(wgt), 0)

	if (heter != "") {
		H = st_data(.,(heter), 0)
        At = st_matrix(at)
		H = H :- At
		Hk = cols(H)
	}
	else Hk = 0
	
	if (time != "") {
		T = st_data(.,(time),0)
	}
	else {
		T = J(length(X),1,1)
	}
	if (cut == "" | time == "") {
		R = X:>=c
	}
	else {
		R = J(length(X),1,1)
	}
	
	/***********************************************************************
	**************************** CCT Approach
	***********************************************************************/

	if (bwselect =="CCT" | bwselect =="" | all !="") {

		display("Computing CCT bandwidth selector.")

		//*** Step 1: q_CCT
		V_m0_pilot_CCT = 0
		V_m2_pilot_CCT = 0
		V_m3_pilot_CCT = 0
		D_q_CCT = 0

		Y_r = J(0,1,.)
		X_r = J(0,cols(X),.)
		W_r = J(0,cols(W),.)
		if (heter != "") H_r = J(0,cols(H),.)
		X_q = J(0, q1+Hk, .)
		X_q1 = J(0, q2+Hk, .)
		sigma_pilot = J(0,1,.)
		St = J(2,2,0)
		Ed = J(2,2,0)
		lgth = 0
		
		for (m=0; m<=1; m++) {
			for (n=0; n<=1; n++) {

				Y_l = select(Y[,1], (T:==m):*(R:==n):==1)
				N_l = length(Y_l)

				if (N_l>0) {
				
					St[m+1,n+1] = lgth + 1
					Ed[m+1,n+1] = N_l + lgth

					X_l = select(X, (T:==m):*(R:==n):==1)
					W_l = select(W, (T:==m):*(R:==n):==1)
					if (heter != "") H_l = select(H, (T:==m):*(R:==n):==1)

					X_lq2 = J(N_l, q+3, .)

					for (j=1; j<=q3; j++) {
						X_lq2[.,j] = (X_l:-c):^(j-1)
					}
					
					X_lq1 = X_lq2[.,1::q2]
					X_lq  = X_lq2[.,1::q1]

					if (heter != "") {
						for (i=1; i<=cols(H); i++) {
							X_lq2 = X_lq2, X_lq2[,1::(deriv+1)]:*H_l[,i]
							X_lq1 = X_lq1, X_lq1[,1::(deriv+1)]:*H_l[,i]
							X_lq = X_lq, X_lq[,1::(deriv+1)]:*H_l[,i]
						}
					}

					w_pilot_l = W_l:*kweight(X_l,c,h_pilot_CCT, kernel)

					Gamma_pilot_lq1 = cross(X_lq1, w_pilot_l, X_lq1)
					invGamma_pilot_lq1 = invsym(Gamma_pilot_lq1)

					Gamma_pilot_lq = Gamma_pilot_lq1[1::q1,1::q1]
					invGamma_pilot_lq  = invsym(Gamma_pilot_lq)

					Gamma_pilot_lp = Gamma_pilot_lq1[1::p1, 1::p1]
					invGamma_pilot_lp  = invsym(Gamma_pilot_lp)

					if ("`heter'"=="") {
						sigma_l_pilot = rdvcew(X_l, Y_l, Y_l, c, p, h_pilot_CCT, matches, vce, kernel, W_l)
					}
					else {
						sigma_l_pilot = rdvcew2(X_l, H_l, Y_l, Y_l, c, p, h_pilot_CCT, matches, vce, kernel, W_l)
					}

					Psi_pilot_lq1 = cross(X_lq1, w_pilot_l:*sigma_l_pilot:*w_pilot_l, X_lq1)
					Psi_pilot_lq  = Psi_pilot_lq1[1::q1,1::q1]
					Psi_pilot_lp  = Psi_pilot_lq1[1::p1,1::p1]
	
					m4_l_pilot_CCT = (invsym(cross(X_lq2,W_l,X_lq2))*cross(X_lq2,W_l,Y_l))[q3,1]

					V_m0_pilot_CCT = V_m0_pilot_CCT + (invGamma_pilot_lp*Psi_pilot_lp*invGamma_pilot_lp)[deriv+1,deriv+1]
					V_m2_pilot_CCT = V_m2_pilot_CCT + (invGamma_pilot_lq*Psi_pilot_lq*invGamma_pilot_lq)[q1,q1]
					V_m3_pilot_CCT = V_m3_pilot_CCT + (invGamma_pilot_lq1*Psi_pilot_lq1*invGamma_pilot_lq1)[q2, q2]

					if (m!=n)   D_q_CCT = D_q_CCT - ((-1)^(deriv+q))*m4_l_pilot_CCT
					else        D_q_CCT = D_q_CCT + m4_l_pilot_CCT

					Y_r = Y_r \ Y_l
					X_r = X_r \ X_l
					W_r = W_r \ W_l
					if (heter != "") H_r = H_r \ H_l
					X_q = X_q \ X_lq
					X_q1 = X_q1 \ X_lq1
					sigma_pilot = sigma_pilot \ sigma_l_pilot
					lgth = lgth + N_l
				}   
			}
		}   

		//* Numerator
		N_q_CCT=(2*q+3)*N*h_pilot_CCT^(2*q+3)*V_m3_pilot_CCT

		//* Denominator
		D_q_CCT = 2*(C1_q*D_q_CCT)^2

		//* Final
		q_CCT = (N_q_CCT/(N*D_q_CCT))^(1/(2*q+5))


		//*** Step 2: b_CCT
		V_m3_q_CCT = 0
		D_b_CCT = 0

		for (m=0; m<=1; m++) {
			for (n=0; n<=1; n++) {

				s = St[m+1,n+1]
				e = Ed[m+1,n+1]

				if (e>0) {

					if ("`heter'"=="") {
						sigma_l_pilot = rdvcew(X_r[s::e,], Y_r[s::e], Y_r[s::e], c, p, q_CCT, matches, vce, kernel, W_r[s::e])
					}
					else {
						sigma_l_pilot = rdvcew2(X_r[s::e,], H_r[s::e,], Y_r[s::e], Y_r[s::e], c, p, q_CCT, matches, vce, kernel, W_r[s::e])
					}
				
					w_q_l = W_r[s::e,]:*kweight(X_r[s::e,],c,q_CCT, kernel)
					invGamma_q_lq1_CCT = invsym(cross(X_q1[s::e,], w_q_l, X_q1[s::e,]))
					
					Psi_q_lq1_CCT = cross(X_q1[s::e,], w_q_l:*sigma_l_pilot:*w_q_l, X_q1[s::e,])
					
					m3_l_CCT = (invsym(cross(X_q1[s::e,], w_q_l, X_q1[s::e,]))*cross(X_q1[s::e,], w_q_l, Y_r[s::e,]))[q2,1]
					V_m3_q_CCT = V_m3_q_CCT + (invGamma_q_lq1_CCT*Psi_q_lq1_CCT*invGamma_q_lq1_CCT)[q2,q2]

					if (m!=n)   D_b_CCT = D_b_CCT - ((-1)^(deriv+q+1))*m3_l_CCT
					else        D_b_CCT = D_b_CCT + m3_l_CCT
				}   
			}
		}   

		//* Numerator
		N_b_CCT = (2*p+3)*N*h_pilot_CCT^(2*p+3)*V_m2_pilot_CCT

		//* Denominator
		D_b_CCT = 2*(q-p)*(C1_b*D_b_CCT)^2

		//* Regul
		R_b_CCT = scaleregul*2*(q-p)*C1_b^2*3*V_m3_q_CCT

		//* Final
		b_CCT = (N_b_CCT / (N*(D_b_CCT + R_b_CCT)))^(1/(2*q+3))


		//*** Step 3: h_CCT
//		V_m0_pilot_CCT = 0
		V_m2_b_CCT = 0
		D_h_CCT = 0

		for (m=0; m<=1; m++) {
			for (n=0; n<=1; n++) {

				s = St[m+1,n+1]
				e = Ed[m+1,n+1]

				if (e>0) {

					if ("`heter'"=="") {
						sigma_l_pilot = rdvcew(X_r[s::e,], Y_r[s::e], Y_r[s::e], c, p, b_CCT, matches, vce, kernel, W_r[s::e])
					}
					else {
						sigma_l_pilot = rdvcew2(X_r[s::e,], H_r[s::e,], Y_r[s::e], Y_r[s::e], c, p, b_CCT, matches, vce, kernel, W_r[s::e])
					}

					w_b_l = W_r[s::e,]:*kweight(X_r[s::e,], c, b_CCT, kernel)
					invGamma_b_lq_CCT = invsym(cross(X_q[s::e,], w_b_l, X_q[s::e,]))
					Psi_b_lq_CCT = cross(X_q[s::e,], w_b_l:*sigma_l_pilot:*w_b_l, X_q[s::e,])
					m2_l_CCT = (invsym(cross(X_q[s::e,], w_b_l, X_q[s::e,]))*cross(X_q[s::e,], w_b_l, Y_r[s::e,]))[p2,1]
					V_m2_b_CCT = V_m2_b_CCT + (invGamma_b_lq_CCT*Psi_b_lq_CCT*invGamma_b_lq_CCT)[p2,p2]

					if (m!=n)   D_h_CCT = D_h_CCT - ((-1)^(deriv+p1))*m2_l_CCT
					else        D_h_CCT = D_h_CCT + m2_l_CCT
				}   
			}
		}   

		//* Numerator
		N_h_CCT = (2*deriv+1)*N*h_pilot_CCT^(2*deriv+1)*V_m0_pilot_CCT

		//* Denominator
		D_h_CCT = 2*(p+1-deriv)*(C1_h*D_h_CCT)^2

		//* Regul
		R_h_CCT = scaleregul*2*(p1-deriv)*C1_h^2*3*V_m2_b_CCT

		//* Final
		h_CCT = (N_h_CCT / (N*(D_h_CCT+R_h_CCT)))^(1/(2*p+3))


		//* Store results
		st_numscalar("h_CCT",h_CCT)
		st_numscalar("q_CCT",q_CCT)

		if (b_calc==0) {
			b_CCT = h_CCT/rho
		}
		st_numscalar("b_CCT",b_CCT)


/* Controls

		if (control != "") {
			XX   = st_data(.,(control),   0)
			nk = cols(XX)
		
		} */
	}


	/*****************************************************
	******************** IK
	*****************************************************/

	if (bwselect=="IK" | all!="") {

		display("Computing IK bandwidth selector.")

		h_pilot_IK = 1.84*sqrt(variance(X, W))*length(X)^(-1/5)

		Y_l0 = select(Y, (T:==0):*(R:==0):==1)
		Y_r0 = select(Y, (T:==0):*(R:==1):==1)
		Y_l1 = select(Y, (T:==1):*(R:==0):==1)
		Y_r1 = select(Y, (T:==1):*(R:==1):==1)

		W_l0 = select(W, (T:==0):*(R:==0):==1)
		W_r0 = select(W, (T:==0):*(R:==1):==1)
		W_l1 = select(W, (T:==1):*(R:==0):==1)
		W_r1 = select(W, (T:==1):*(R:==1):==1)

		X_l0 = select(X, (T:==0):*(R:==0):==1)
		X_r0 = select(X, (T:==0):*(R:==1):==1)
		X_l1 = select(X, (T:==1):*(R:==0):==1)
		X_r1 = select(X, (T:==1):*(R:==1):==1)

		if (heter != "") {
			H_l0 = select(H, (T:==0):*(R:==0):==1)
			H_r0 = select(H, (T:==0):*(R:==1):==1)
			H_l1 = select(H, (T:==1):*(R:==0):==1)
			H_r1 = select(H, (T:==1):*(R:==1):==1)
		}

		N_l0 = length(X_l0)
		N_r0 = length(X_r0)
		N_l1 = length(X_l1)
		N_r1 = length(X_r1)

		n_l0_h1 = length(select(X_l0, abs(X_l0:-c):<=h_pilot_IK))
		n_r0_h1 = length(select(X_r0, abs(X_r0:-c):<=h_pilot_IK))
		n_l1_h1 = length(select(X_l1, abs(X_l1:-c):<=h_pilot_IK))
		n_r1_h1 = length(select(X_r1, abs(X_r1:-c):<=h_pilot_IK))

		f0_pilot=(n_r0_h1+n_l0_h1+n_r1_h1+n_l1_h1)/(2*N*h_pilot_IK)

		f=0
		if (n_l0_h1>0) {
			X_l0q2 = J(N_l0, q+3, .)
			for (j=1; j<=q3; j++) {
				X_l0q2[.,j] = (X_l0:-c):^(j-1)
			}
			X_l0q1 = X_l0q2[.,1::q2]
			X_l0q  = X_l0q2[.,1::q1]

			if (heter != "") {
				for (i=1; i<=cols(H); i++) {
					X_l0q2 = X_l0q2, X_l0q2[,1::(deriv+1)]:*H_l0[,i]
					X_l0q1 = X_l0q1, X_l0q1[,1::(deriv+1)]:*H_l0[,i]
					X_l0q = X_l0q, X_l0q[,1::(deriv+1)]:*H_l0[,i]
				}
			}

			s2_l0_pilot = variance(select(Y_l0,abs(X_l0:-c):<=h_pilot_IK),select(W_l0,abs(X_l0:-c):<=h_pilot_IK))
			if (s2_l0_pilot==0) f=1
		}
		if (n_r0_h1>0) {
			X_r0q2 = J(N_r0, q+3, .)
			for (j=1; j<=q3; j++) {
				X_r0q2[.,j] = (X_r0:-c):^(j-1)
			}
			X_r0q1 = X_r0q2[.,1::q2]
			X_r0q  = X_r0q2[.,1::q1]
			
			if (heter != "") {
				for (i=1; i<=cols(H); i++) {
					X_r0q2 = X_r0q2, X_r0q2[,1::(deriv+1)]:*H_r0[,i]
					X_r0q1 = X_r0q1, X_r0q1[,1::(deriv+1)]:*H_r0[,i]
					X_r0q = X_r0q, X_r0q[,1::(deriv+1)]:*H_r0[,i]
				}
			}

			s2_r0_pilot = variance(select(Y_r0,abs(X_r0:-c):<=h_pilot_IK),select(W_r0,abs(X_r0:-c):<=h_pilot_IK))
			if (s2_r0_pilot==0) f=1
		}
		if (n_l1_h1>0) {
			X_l1q2 = J(N_l1, q+3, .)
			for (j=1; j<=q3; j++) {
				X_l1q2[.,j] = (X_l1:-c):^(j-1)
			}
			X_l1q1 = X_l1q2[.,1::q2]
			X_l1q  = X_l1q2[.,1::q1]

			if (heter != "") {
				for (i=1; i<=cols(H); i++) {
					X_l1q2 = X_l1q2, X_l1q2[,1::(deriv+1)]:*H_l1[,i]
					X_l1q1 = X_l1q1, X_l1q1[,1::(deriv+1)]:*H_l1[,i]
					X_l1q = X_l1q, X_l1q[,1::(deriv+1)]:*H_l1[,i]
				}
			}

			s2_l1_pilot = variance(select(Y_l1,abs(X_l1:-c):<=h_pilot_IK),select(W_l1,abs(X_l1:-c):<=h_pilot_IK))
			if (s2_l1_pilot==0) f=1
		}
		if (n_r1_h1>0) {
			X_r1q2 = J(N_r1, q+3, .)
			for (j=1; j<=q3; j++) {
				X_r1q2[.,j] = (X_r1:-c):^(j-1)
			}
			X_r1q1 = X_r1q2[.,1::q2]
			X_r1q  = X_r1q2[.,1::q1]
			
			if (heter != "") {
				for (i=1; i<=cols(H); i++) {
					X_r1q2 = X_r1q2, X_r1q2[,1::(deriv+1)]:*H_r1[,i]
					X_r1q1 = X_r1q1, X_r1q1[,1::(deriv+1)]:*H_r1[,i]
					X_r1q = X_r1q, X_r1q[,1::(deriv+1)]:*H_r1[,i]
				}
			}

			s2_r1_pilot = variance(select(Y_r1,abs(X_r1:-c):<=h_pilot_IK),select(W_r1,abs(X_r1:-c):<=h_pilot_IK))
			if (s2_r1_pilot==0) f=1
		}

		if (f==1) {
			if (n_l0_h1>0) s2_l0_pilot = variance(select(Y_l0,abs(X_l0:-c):<=2*h_pilot_IK),select(W_l0,abs(X_l0:-c):<=2*h_pilot_IK))
			if (n_r0_h1>0) s2_r0_pilot = variance(select(Y_r0,abs(X_r0:-c):<=2*h_pilot_IK),select(W_r0,abs(X_r0:-c):<=2*h_pilot_IK))
			if (n_l1_h1>0) s2_l1_pilot = variance(select(Y_l1,abs(X_l1:-c):<=2*h_pilot_IK),select(W_l1,abs(X_l1:-c):<=2*h_pilot_IK))
			if (n_r1_h1>0) s2_r1_pilot = variance(select(Y_r1,abs(X_r1:-c):<=2*h_pilot_IK),select(W_r1,abs(X_r1:-c):<=2*h_pilot_IK))
		}

		s2_pilot = 0
		if (n_l0_h1>0) {
			s2_pilot = s2_pilot + s2_l0_pilot
			N_q_l0_pilot_IK = (2*q+3)*C2_q_uni*(s2_l0_pilot/f0_pilot)
			N_b_l0_pilot_IK = (2*p+3)*C2_b_uni*(s2_l0_pilot/f0_pilot)
		}
		if (n_r0_h1>0) {
			s2_pilot = s2_pilot + s2_r0_pilot
			N_q_r0_pilot_IK = (2*q+3)*C2_q_uni*(s2_r0_pilot/f0_pilot)
			N_b_r0_pilot_IK = (2*p+3)*C2_b_uni*(s2_r0_pilot/f0_pilot)
		}
		if (n_l1_h1>0) {
			s2_pilot = s2_pilot + s2_l1_pilot
			N_q_l1_pilot_IK = (2*q+3)*C2_q_uni*(s2_l1_pilot/f0_pilot)
			N_b_l1_pilot_IK = (2*p+3)*C2_b_uni*(s2_l1_pilot/f0_pilot)
		}
		if (n_r1_h1>0) {
			s2_pilot = s2_pilot + s2_r1_pilot
			N_q_r1_pilot_IK = (2*q+3)*C2_q_uni*(s2_r1_pilot/f0_pilot)
			N_b_r1_pilot_IK = (2*p+3)*C2_b_uni*(s2_r1_pilot/f0_pilot)
		}

		V_IK_pilot = s2_pilot/f0_pilot
		Vm0_pilot_IK = C2_h*V_IK_pilot
		Vm2_pilot_IK = C2_b*V_IK_pilot
		//*Vm3_pilot_IK = C2_q*V_IK_pilot

		//* Select Median Sample to compute derivative (as in IK code)
		x_IK_med_r1 = select(X_r1, abs(X_r1:-c):<=medX_r1)
		x_IK_med = x_IK_med_r1

		y_IK_med_r1 = select(Y_r1, abs(X_r1:-c):<=medX_r1)
		y_IK_med = y_IK_med_r1

		w_IK_med_r1 = select(W_r1, abs(X_r1:-c):<=medX_r1)
		w_IK_med = w_IK_med_r1
		
		if (heter != "") {
			H_IK_med_r1 = select(H_r1, abs(X_r1:-c):<=medX_r1)
			H_IK_med = H_IK_med_r1
		}

		D = J(length(x_IK_med_r1),2,1)

		if (n_l1_h1>0) {
			x_IK_med_l1 = select(X_l1, abs(X_l1:-c):<=medX_l1)
			x_IK_med = x_IK_med \ x_IK_med_l1

			y_IK_med_l1 = select(Y_l1, abs(X_l1:-c):<=medX_l1)
			y_IK_med = y_IK_med \ y_IK_med_l1

			w_IK_med_l1 = select(W_l1, abs(X_l1:-c):<=medX_l1)
			w_IK_med = w_IK_med \ w_IK_med_l1
			
			if (heter != "") {
				H_IK_med_l1 = select(H_l1, abs(X_l1:-c):<=medX_l1)
				H_IK_med = H_IK_med \ H_IK_med_l1
			}

			D = D \ J(length(x_IK_med_l1),1,(0,1))
		}
		if (n_r0_h1>0) {
			x_IK_med_r0 = select(X_r0, abs(X_r0:-c):<=medX_r0)
			x_IK_med = x_IK_med \ x_IK_med_r0

			y_IK_med_r0 = select(Y_r0, abs(X_r0:-c):<=medX_r0)
			y_IK_med = y_IK_med \ y_IK_med_r0

			w_IK_med_r0 = select(W_r0, abs(X_r0:-c):<=medX_r0)
			w_IK_med = w_IK_med \ w_IK_med_r0
			
			if (heter != "") {
				H_IK_med_r0 = select(H_r0, abs(X_r0:-c):<=medX_r0)
				H_IK_med = H_IK_med \ H_IK_med_r0
			}

			D = D \ J(length(x_IK_med_r0),1,(1,0))
		}
		if (n_l0_h1>0) {
			x_IK_med_l0 = select(X_l0, abs(X_l0:-c):<=medX_l0)
			x_IK_med = x_IK_med \ x_IK_med_l0

			y_IK_med_l0 = select(Y_l0, abs(X_l0:-c):<=medX_l0)
			y_IK_med = y_IK_med \ y_IK_med_l0

			w_IK_med_l0 = select(W_l0, abs(X_l0:-c):<=medX_l0)
			w_IK_med = w_IK_med \ w_IK_med_l0
			
			if (heter != "") {
				H_IK_med_l0 = select(H_l0, abs(X_l0:-c):<=medX_l0)
				H_IK_med = H_IK_med \ H_IK_med_l0
			}

			D = D \ J(length(x_IK_med_l0),2,0)
		}

		sample_IK = length(x_IK_med)
		X_IK_med_q2 = J(sample_IK, q3, .)
		for (j=1; j<= q3 ; j++) {
			X_IK_med_q2[.,j] = (x_IK_med:-c):^(j-1)
		}
		X_IK_med_q1 = X_IK_med_q2[.,1::q2]
		
		if (heter != "") {
			for (i=1; i<=cols(H); i++) {
				X_IK_med_q2 = X_IK_med_q2, X_IK_med_q2[,1::(deriv+1)]:*H_IK_med[,i]
				X_IK_med_q1 = X_IK_med_q1, X_IK_med_q1[,1::(deriv+1)]:*H_IK_med[,i]
			}
		}

		//* Add cutoff dummy
		X_IK_med_q2 = X_IK_med_q2, D
		X_IK_med_q1 = X_IK_med_q1, D

		//*** Compute b_IK
		//* Pilot Bandwidth
		m4_pilot_IK = (invsym(cross(X_IK_med_q2,w_IK_med,X_IK_med_q2))*cross(X_IK_med_q2,w_IK_med,y_IK_med))[q+3,1]
		D_q_pilot_IK = 2*(C1_q_uni*m4_pilot_IK)^2

		D_b_IK = 0
		R_b_IK = 0
		temp = regconst(q1,1)
		con = temp[q2, q2]

		if (n_r1_h1>0) {
			h3_r1_pilot_IK = (N_q_r1_pilot_IK / (N_r1*D_q_pilot_IK))^(1/(2*q+5))

			X_r1q_IK_h3=select(X_r1q1, abs(X_r1:-c):<= h3_r1_pilot_IK)
			Y_r1_IK_h3 =select(Y_r1,   abs(X_r1:-c):<= h3_r1_pilot_IK)
			W_r1_IK_h3 =select(W_r1, abs(X_r1:-c):<=h3_r1_pilot_IK)

			m3_r1_IK = (invsym(cross(X_r1q_IK_h3,W_r1_IK_h3,X_r1q_IK_h3))*cross(X_r1q_IK_h3,W_r1_IK_h3,Y_r1_IK_h3))[q+2,1]
			D_b_IK = D_b_IK + m3_r1_IK

			n_r1_h3 = length(Y_r1_IK_h3)
			r_r1_b = (con*s2_r1_pilot)/(n_r1_h3*h3_r1_pilot_IK^(2*q1))
			R_b_IK = R_b_IK + r_r1_b
		}
		if (n_l1_h1>0) {
			h3_l1_pilot_IK = (N_q_l1_pilot_IK / (N_l1*D_q_pilot_IK))^(1/(2*q+5))

			X_l1q_IK_h3=select(X_l1q1, abs(X_l1:-c):<= h3_l1_pilot_IK)
			Y_l1_IK_h3 =select(Y_l1,   abs(X_l1:-c):<= h3_l1_pilot_IK)
			W_l1_IK_h3 =select(W_l1, abs(X_l1:-c):<=h3_l1_pilot_IK)

			m3_l1_IK = (invsym(cross(X_l1q_IK_h3,W_l1_IK_h3,X_l1q_IK_h3))*cross(X_l1q_IK_h3,W_l1_IK_h3,Y_l1_IK_h3))[q+2,1]
			D_b_IK = D_b_IK - (-1)^(deriv+q1)*m3_l1_IK

			n_l1_h3 = length(Y_l1_IK_h3)
			r_l1_b = (con*s2_l1_pilot)/(n_l1_h3*h3_l1_pilot_IK^(2*q1))
			R_b_IK = R_b_IK + r_l1_b
		}
		if (n_r0_h1>0) {
			h3_r0_pilot_IK = (N_q_r0_pilot_IK / (N_r0*D_q_pilot_IK))^(1/(2*q+5))

			X_r0q_IK_h3=select(X_r0q1, abs(X_r0:-c):<= h3_r0_pilot_IK)
			Y_r0_IK_h3 =select(Y_r0,   abs(X_r0:-c):<= h3_r0_pilot_IK)
			W_r0_IK_h3 =select(W_r0, abs(X_r0:-c):<=h3_r0_pilot_IK)

			m3_r0_IK = (invsym(cross(X_r0q_IK_h3,W_r0_IK_h3,X_r0q_IK_h3))*cross(X_r0q_IK_h3,W_r0_IK_h3,Y_r0_IK_h3))[q+2,1]
			D_b_IK = D_b_IK - (-1)^(deriv+q1)*m3_r0_IK

			n_r0_h3 = length(Y_r0_IK_h3)
			r_r0_b = (con*s2_r0_pilot)/(n_r0_h3*h3_r0_pilot_IK^(2*q1))
			R_b_IK = R_b_IK + r_r0_b
		}
		if (n_l0_h1>0) {
			h3_l0_pilot_IK = (N_q_l0_pilot_IK / (N_l0*D_q_pilot_IK))^(1/(2*q+5))

			X_l0q_IK_h3=select(X_l0q1, abs(X_l0:-c):<= h3_l0_pilot_IK)
			Y_l0_IK_h3 =select(Y_l0,   abs(X_l0:-c):<= h3_l0_pilot_IK)
			W_l0_IK_h3 =select(W_l0, abs(X_l0:-c):<=h3_l0_pilot_IK)

			m3_l0_IK = (invsym(cross(X_l0q_IK_h3,W_l0_IK_h3,X_l0q_IK_h3))*cross(X_l0q_IK_h3,W_l0_IK_h3,Y_l0_IK_h3))[q+2,1]
			D_b_IK = D_b_IK + m3_l0_IK

			n_l0_h3 = length(Y_l0_IK_h3)
			r_l0_b = (con*s2_l0_pilot)/(n_l0_h3*h3_l0_pilot_IK^(2*q1))
			R_b_IK = R_b_IK + r_l0_b
		}

		D_b_IK = 2*(q-p)*(C1_b*D_b_IK)^2
		N_b_IK = (2*p+3)*Vm2_pilot_IK

		//* Regularization
		R_b_IK = scaleregul*2*(q-p)*C1_b^2*3*R_b_IK

		//* Final bandwidth:
		b_IK   = (N_b_IK / (N*(D_b_IK + R_b_IK)))^(1/(2*q+3))

		//*** Compute h_IK
		//* Pilot Bandwidth
		m3_pilot_IK = (invsym(cross(X_IK_med_q1,w_IK_med,X_IK_med_q1))*cross(X_IK_med_q1,w_IK_med,y_IK_med))[q+2,1]
		D_b_pilot_IK = 2*(q-p)*(C1_b_uni*m3_pilot_IK)^2

		D_h_IK = 0
		R_h_IK = 0

		temp = regconst(p1,1)
		con = temp[p2, p2]

		if (n_r1_h1>0) {
			h2_r1_pilot_IK  = (N_b_r1_pilot_IK / (N_r1*D_b_pilot_IK))^(1/(2*q+3))

			X_r1q_IK_h2=select(X_r1q, abs(X_r1:-c):<=h2_r1_pilot_IK)
			Y_r1_IK_h2 =select(Y_r1, abs(X_r1:-c):<=h2_r1_pilot_IK)
			W_r1_IK_h2 =select(W_r1, abs(X_r1:-c):<=h2_r1_pilot_IK)

			m2_r1_IK = (invsym(cross(X_r1q_IK_h2,W_r1_IK_h2,X_r1q_IK_h2))*cross(X_r1q_IK_h2,W_r1_IK_h2,Y_r1_IK_h2))[p+2,1]

			D_h_IK = D_h_IK + m2_r1_IK

			n_r1_h2 = length(Y_r1_IK_h2)
			r_r1_h = (con*s2_r1_pilot)/(n_r1_h2*h2_r1_pilot_IK^(2*p1))
			R_h_IK = R_h_IK + r_r1_h
		}
		if (n_l1_h1>0) {
			h2_l1_pilot_IK  = (N_b_l1_pilot_IK / (N_l1*D_b_pilot_IK))^(1/(2*q+3))

			X_l1q_IK_h2=select(X_l1q, abs(X_l1:-c):<=h2_l1_pilot_IK)
			Y_l1_IK_h2 =select(Y_l1, abs(X_l1:-c):<=h2_l1_pilot_IK)
			W_l1_IK_h2 =select(W_l1, abs(X_l1:-c):<=h2_l1_pilot_IK)

			m2_l1_IK = (invsym(cross(X_l1q_IK_h2,W_l1_IK_h2,X_l1q_IK_h2))*cross(X_l1q_IK_h2,W_l1_IK_h2,Y_l1_IK_h2))[p+2,1]

			D_h_IK = D_h_IK - (-1)^(deriv+p+1)*m2_l1_IK

			n_l1_h2 = length(Y_l1_IK_h2)
			r_l1_h = (con*s2_l1_pilot)/(n_l1_h2*h2_l1_pilot_IK^(2*p1))
			R_h_IK = R_h_IK + r_l1_h
		}
		if (n_r0_h1>0) {
			h2_r0_pilot_IK  = (N_b_r0_pilot_IK / (N_r0*D_b_pilot_IK))^(1/(2*q+3))

			X_r0q_IK_h2=select(X_r0q, abs(X_r0:-c):<=h2_r0_pilot_IK)
			Y_r0_IK_h2 =select(Y_r0, abs(X_r0:-c):<=h2_r0_pilot_IK)
			W_r0_IK_h2 =select(W_r0, abs(X_r0:-c):<=h2_r0_pilot_IK)

			m2_r0_IK = (invsym(cross(X_r0q_IK_h2,W_r0_IK_h2,X_r0q_IK_h2))*cross(X_r0q_IK_h2,W_r0_IK_h2,Y_r0_IK_h2))[p+2,1]

			D_h_IK = D_h_IK - (-1)^(deriv+p1)*m2_r0_IK

			n_r0_h2 = length(Y_r0_IK_h2)
			r_r0_h = (con*s2_r0_pilot)/(n_r0_h2*h2_r0_pilot_IK^(2*p1))
			R_h_IK = R_h_IK + r_r0_h
		}
		if (n_l0_h1>0) {
			h2_l0_pilot_IK  = (N_b_l0_pilot_IK / (N_l0*D_b_pilot_IK))^(1/(2*q+3))

			X_l0q_IK_h2=select(X_l0q, abs(X_l0:-c):<=h2_l0_pilot_IK)
			Y_l0_IK_h2 =select(Y_l0, abs(X_l0:-c):<=h2_l0_pilot_IK)
			W_l0_IK_h2 =select(W_l0, abs(X_l0:-c):<=h2_l0_pilot_IK)

			m2_l0_IK = (invsym(cross(X_l0q_IK_h2,W_l0_IK_h2,X_l0q_IK_h2))*cross(X_l0q_IK_h2,W_l0_IK_h2,Y_l0_IK_h2))[p+2,1]

			D_h_IK = D_h_IK + m2_l0_IK

			n_l0_h2 = length(Y_l0_IK_h2)
			r_l0_h = (con*s2_l0_pilot)/(n_l0_h2*h2_l0_pilot_IK^(2*p1))
			R_h_IK = R_h_IK + r_l0_h
		}

		D_h_IK = 2*(p1-deriv)*(C1_h*D_h_IK)^2
		N_h_IK = (2*deriv+1)*Vm0_pilot_IK

		//* Regularization
		R_h_IK = scaleregul*2*(p1-deriv)*C1_h^2*3*R_h_IK

		//* Final bandwidth
		h_IK  = (N_h_IK / (N*(D_h_IK + R_h_IK)))^(1/(2*p+3))

		st_numscalar("h_IK", h_IK)
		st_numscalar("b_IK", b_IK)

		if (b_calc==0) {
			b_IK = h_IK/rho
		}
		st_numscalar("b_IK",b_IK)
	}
}
end
