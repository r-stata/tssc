*! version 2.0 updated 4-21-14
// This procedure estimates the robust standard errors for meta regressions by way of various weighting schemes
// Program by Eric Hedberg (eric.hedberg@me.com) based on
// Hedges, Larry V., Elizabeth Tipton, and Matthew C. Johnson. 2010. Robust variance estimation
//     in meta-regression with dependent effect size estimates. Research Synthesis Methods.
//     (www.interscience.wiley.com) DOI: 10.1002/jrsm.5
//and
//Tipton, E. (in press) Small sample adjustments for robust variance estimation with meta-regression. Forthcoming in Psychological Methods.

program robumeta, eclass byable(recall)
    version 13

    local obs = _N

    set matsize `obs'

	set type double
    syntax varlist(min=1 numeric) [if] [in],  ///
    [study(varlist max=1 numeric)]  ///
    [weighttype(string)] ///
    [variance(varlist max=1 numeric)]  ///
    [uweights(varlist max=1 numeric)]   ///
    [Level(cilevel)]  ///
    [rho(numlist max = 1 < 1)] ///
    [rhoforweights] [eform] [NOSmallsample]

    preserve

    *mark sample
    marksample touse

    *create macros of variables
    tokenize `varlist'
    local t `1'
    macro shift
    local x `*'

    *specify the temporary variables used in the program
    tempvar keepers cons w wh wfinal prelim_hat prelim_resid  ///
    prime_hat prime_resid v_mean v_n studyweight studynumber 
   

    *specifiy the temporary scalars and matrixes
    tempname A1  A2  b   B1  B2  C1  C2  D   e   E   F   I   J    ///
	k   kw  kXJWX   kXWJX   omega_squared   omega_squared_o      ///
	Q1  QE  QR  sigmahat  min_n max_n sumk    sumk2   T   T_XB    T_XBJT_XB    ///
	tau_squared tau_squared_o trW trW_1  TWT     TWX     V   VkXJWX  VkXWJX   ///
	Vw2XJX  VwkXJX_XX   VwkXX   VXJWX   VXJX    VXJXVXW2X    ///
	VXJXVXWJWX  VXW2X   VXW2X   VXWJWX  VXWJWX  VXWJX   W    ///
	w_k     w2  w2XJX   wkXJX_XX    wkXX    wXX     X   XB   ///
	XJWX    XJX     XJX     XW2X    XW2X    XWeeWX  XWJWX   XWJX     ///
	XWT     XWX     XX

    *generate constant term
    quietly : gen double `cons' = 1 if `touse'

    *listwise mark and count obs
    quietly : egen double `keepers' = rowmiss(`t' `x') if `touse'
    quietly : replace `touse' = 0 if `keepers' > 0


    *knock out cases that are not used, sort on id list 

    quietly : keep if `touse'

    local nobs = _N

    capture confirm existence `study'
    if _rc == 6 {
        quietly : gen double `studynumber' = _n if `touse'
    }
    else {
        quietly : gen double `studynumber' = `study' if `touse'
    }

    quietly sort `studynumber'

    tempvar index
    quietly : gen `index' = _n

    *capture ids
    quietly : levelsof `studynumber', local(idlist)

    *count ids, create macro m
    local m = 0
    foreach j in `idlist' {
        local ++m
    }

    *set up iccs for later
    capture confirm existence `rho'
    if _rc != 6 {
        local rhot = `rho'
        capture confirm existence `rhoforweights'
        if _rc != 6 {
            local rhow = `rho'
        }
    }
	
    *check logic of icc options
    capture confirm existence `rhoforweights'
    if _rc != 6 {
        capture confirm existence `rho'
        if _rc == 6 {
            display as error "must specify a value of rho if you want to use rho for weights"
            exit
        }
    }

    *defualt is random weights, set if necessary
    capture confirm existence `weighttype'
    if _rc == 6 {
        local weighttype "random"
    }
    *if uweights are specified, make sure fixed is used
    capture confirm existence `uweights'
    if _rc != 6 {
    	if "`weighttype'" == "fixed" {
    		*ok
    	}
    	else {
    		di as error "need to use fixed weighing scheme for user weights"
    		exit 9	
    	}
    }	
    *figure out how user specified the weights, check arguments,
    if "`weighttype'" == "random" | "`weighttype'" == "hierarchical" {
        capture confirm existence `variance'
        if _rc == 6 {
            display as error "you must specify the variance estimation with a `weighttype' weighting scheme"
            exit
        }
        else {
            *study average variance
            quietly : by `studynumber', sort rc0: egen double `v_mean' = mean(`variance') if `touse'
            *number of cases per study
            quietly : by `studynumber', sort rc0: egen double `v_n' = count(`variance') if `touse'
			quietly sum `v_n'
			scalar `min_n' = r(min) 
			scalar `max_n' = r(max)
            *study constant weight
            quietly : gen double `studyweight' = 1 /(`v_n' * `v_mean') if `touse'
        }
    }
    else if "`weighttype'" == "fixed" {
        capture confirm existence `variance'
        if _rc == 6 {
            capture confirm existence `uweights'
            if _rc != 6 {
                capture confirm existence `rhow'
                if _rc != 6 {
                    display as error "cannot specify rho for weights with user weights"
                    exit
                }
                quietly : gen double `studyweight' = `uweights' if `touse'
                quietly : by `studynumber', sort rc0: egen double `v_n' = count(`uweights') if `touse'
				*number of cases per study
				quietly sum `v_n'
				scalar `min_n' = r(min) 
				scalar `max_n' = r(max)
			}
            else {
                display as error "you must specify the variance estimation or user weights with a `weighttype' weighting scheme"
                exit
            }
        }
        else {
            *study average variance
            quietly : by `studynumber', sort rc0: egen double `v_mean' = mean(`variance') if `touse'
            *number of cases per study
            quietly : by `studynumber', sort rc0: egen double `v_n' = count(`variance') if `touse'
            *study constant weight
            quietly : gen double `studyweight' = 1 /(`v_n' * `v_mean') if `touse'
            quietly sum `v_n'
			scalar `min_n' = r(min) 
			scalar `max_n' = r(max)
        }
    }
    else {
        display as error "unknown weight specification `weighttype'"
        exit
    }

    *collinearity 

    local olist "`x'"
    _rmcoll `x'
    local x = r(varlist)
    foreach v in `olist' {
        local x = regexr("`x'","o\.`v'","")
    }

    if "`x'" == "." local x ""

     *count predictors, create macro p for number of predictors
    local p = 0
    foreach v in `x' cons {
        local ++p
    }

    *Calculate fixed weights, random effects weights, hierarchical weights
    
    /*****************/
    /*    Fixed      */
    /*****************/
    if "`weighttype'" == "fixed" {
        capture confirm existence `rho'
        if _rc == 6 {
            quietly : gen double `wfinal' = `studyweight' if `touse'
        }
        else {
            quietly : gen double `wfinal' = 1/((1 + ((`v_n' - 1) * `rho')) * `v_mean')
        }
        tempvar wfinalmean
        quietly : bysort `studynumber' : egen `wfinalmean' = mean(`wfinal') if `touse'
    }
    /*****************/
    /*  Hierarchical */
    /*****************/
    else if "`weighttype'" == "hierarchical" {
	
		capture confirm existence `rhot'`rhow'
        if _rc != 6 {
            display as error "rho has no impact on this procedure"
            exit
        }
        *calculate slopes for Q1

        quietly : gen double `wh' = 1/`variance' if `touse'

        mkmat `wh' if `touse', matrix(`W')
        matrix `W' = diag(`W')
        mkmat `t' if `touse', matrix(`T')
        matrix colnames `T' = `t'
        mkmat `x' `cons' if `touse', matrix(`X')
		
        matrix `b' = inv(`X''*`W'*`X') * `X''*`W'*`T'		
		
        matrix `XWX' = `X'' * `W' * `X'
        matrix `V' = inv(`XWX')

        *calculate matrix quantities

        matrix `TWT' = J(1, 1, 0)
        matrix `TWX' = J(1, `p', 0)
        matrix `XWX' = J(`p', `p', 0)
        matrix `XWT' = J(`p', 1, 0)

        matrix `XWJWX' = J(`p', `p', 0)
        matrix `kXJWX' = J(`p', `p', 0)
        matrix `kXWJX' = J(`p', `p', 0)
        matrix `XJX' = J(`p', `p', 0)
        matrix `XJWX' = J(`p', `p', 0)
        matrix `XWJX' = J(`p', `p', 0)
        matrix `XW2X' = J(`p',`p',0)

        matrix `T_XBJT_XB' = J(1, 1, 0)

        scalar `sumk' = 0
        scalar `sumk2' = 0

        foreach j in `idlist' {
            *different weights for each type

            mkmat `wh' if `touse' & `studynumber' == `j', matrix(`W')
            matrix `W' = diag(`W')


            quietly : levelsof `studyweight' if `touse' & `studynumber' == `j', local(sw)
            quietly : levelsof `v_n' if `touse' & `studynumber' == `j', local(sn)

            scalar `k' = `sn'
            scalar `sumk' = `k' + `sumk'
            scalar `sumk2' = (`k' * `k') + `sumk2'


            mkmat `t' if `touse' & `studynumber' == `j', matrix(`T')
            matrix colnames `T' = `t'
            mkmat `x' `cons' if `touse' & `studynumber' == `j', matrix(`X')
            matrix colnames `X' = `x' _cons
            matrix `J' = J(`sn', `sn', 1)

            matrix `TWT' = (`T'' * `W' * `T') + `TWT'
            matrix `TWX' = (`T'' * `W' * `X') + `TWX'
            matrix `XWX' = (`X'' * `W' * `X') + `XWX'
            matrix `XWT' = (`X'' * `W' * `T') + `XWT'
            matrix `XWJWX' = (`X'' * `W' * `J' * `W' * `X') + `XWJWX'
            matrix `XW2X' = (`X'' * `W' * `W' * `X') + `XW2X'

            matrix `XJWX' = (`X''*`J'*`W'*`X') + `XJWX'
            matrix `XWJX' = (`X''*`W'*`J'*`X') + `XWJX'

            matrix `kXJWX' = (`k' * (`X''*`J'*`W'*`X')) + `kXJWX'
            matrix `kXWJX' = (`k' * (`X''*`W'*`J'*`X')) + `kXWJX'

            matrix `XJX' = (`X'' * `J' * `X') + `XJX'

            matrix `XB' = `X'*`b'
            matrix `T_XB' = `T' - `XB'
            matrix `T_XBJT_XB' = (`T_XB'' * `J' * `T_XB') + `T_XBJT_XB'
        }

        *Calcuate parameters for tau and omega

        matrix `QE' = `TWT' - (`TWX' * inv(`XWX') * `XWT')
        scalar `QE' = `QE'[1,1]

        scalar `Q1' = `T_XBJT_XB'[1,1]


        matrix `VkXJWX' = `V' * `kXJWX'
        matrix `VkXWJX' = `V' * `kXWJX'
        matrix `VXJX' = `V' * `XJX'
        matrix `VXWJWX' = `V' * `XWJWX'
        matrix `VXJWX' = `V' * `XJWX'
        matrix `VXWJX' = `V' * `XWJX'
        matrix `VXW2X' = `V' * `XW2X'

        matrix `VXJXVXWJWX' = `VXJX' * `VXWJWX'

        matrix `VXJXVXW2X' = `VXJX' * `VXW2X'

        scalar `A1' = `sumk2' - trace(`VkXJWX') - trace(`VkXWJX') + trace(`VXJXVXWJWX')
        scalar `B1' = `sumk' - trace(`VXJWX') - trace(`VXWJX') + trace(`VXJXVXW2X')
        quietly : sum `variance'
        scalar `trW_1' = r(sum)
        scalar `C1' = `trW_1' - trace(`VXJX')

        quietly : sum `wh'
        scalar `trW' = r(sum)
        scalar `A2' = `trW' - trace(`VXWJWX')
        scalar `B2' = `trW' - trace(`VXW2X')
        scalar `C2' = `sumk' - `p'

        *tau and omega

        scalar `omega_squared' = ((`A2'*(`Q1'-`C1')) - (`A1'*(`QE'-`C2')))/((`B1'*`A2') - (`B2'*`A1'))

        if `omega_squared' < 0 {
            scalar `omega_squared_o' = `omega_squared'
            scalar `omega_squared' = 0
        }
		else {
			scalar `omega_squared_o' = `omega_squared'
		}
		scalar `tau_squared' =   ((`QE'-`C2')/`A2')-(`omega_squared'*(`B2'/`A2'))

        if `tau_squared' < 0 {
            scalar `tau_squared_o' = `tau_squared'
            scalar `tau_squared' = 0
        }
		else {
			scalar `tau_squared_o' = `tau_squared'
		}

        *Calcuate weights
		
        quietly : gen double `wfinal' = 1/(`variance' + `omega_squared' + `tau_squared')
				
    }
    /*****************/
    /*    Random     */
    /*****************/
    else if "`weighttype'" == "random" {
        *if no rho is specified, value of 1 is assumed
        capture confirm existence `rho'
        if _rc == 6 {
            local rhot = 1
        }
        capture confirm existence `rhow'
        if _rc == 6 {
            quietly : gen double `w' = `studyweight' if `touse'
        }
        else {
            quietly : gen double `w' = 1/((1 + ((`v_n' - 1) * `rhow')) * `v_mean') if `touse'
        }

        *calculate matrix quantities

        matrix `TWT' = J(1, 1, 0)
        matrix `wXX' = J(`p', `p', 0)
        matrix `TWX' = J(1, `p', 0)
        matrix `XWX' = J(`p', `p', 0)
        matrix `XWJWX' = J(`p', `p', 0)
        matrix `XW2X' = J(`p',`p',0)
        matrix `XWT' = J(`p', 1, 0)
        matrix `wkXX' = J(`p',`p',0)
        matrix `wkXJX_XX' = J(`p', `p', 0)
        matrix `w2XJX' = J(`p', `p', 0)
        scalar `kw' = 0

        foreach j in `idlist' {
            mkmat `w' if `touse' & `studynumber' == `j', matrix(`W')
            quietly : levelsof `studyweight' if `touse' & `studynumber' == `j', local(sw)
            quietly : levelsof `v_n' if `touse' & `studynumber' == `j', local(sn)

            scalar `w_k' = `sw' / `sn'
            scalar `w2' = `sw'^2

            mkmat `t' if `touse' & `studynumber' == `j', matrix(`T')
            matrix colnames `T' = `t'
            mkmat `x' `cons' if `touse' & `studynumber' == `j', matrix(`X')
            matrix colnames `X' = `x' _cons
            matrix `J' = J(`sn', `sn', 1)
            matrix `W' = diag(`W')
            matrix `TWX' = (`T'' * `W' * `X') + `TWX'
            matrix `TWT' = (`T'' * `W' * `T') + `TWT'
            matrix `wXX' = (`sw' * `X'' * `X') + `wXX'
            matrix `XWX' = (`X'' * `W' * `X') + `XWX'
            matrix `XWT' = (`X'' * `W' * `T') + `XWT'
            matrix `XWJWX' = (`X'' * `W' * `J' * `W' * `X') + `XWJWX'
            matrix `XW2X' = (`X'' * `W' * `W' * `X') + `XW2X'
            matrix `wkXX' = (`w_k' * (`X'' * `X')) + `wkXX'
            matrix `wkXJX_XX' = (`w_k' * ((`X'' * `J' * `X') - (`X'' * `X'))) + `wkXJX_XX'
            matrix `w2XJX' = (`w2' * `X'' * `J' * `X' ) + `w2XJX'
            scalar `kw' = (`sw' * `sn') + `kw'
        }

        *Calcuate parameters for tau

        matrix `V' = inv(`XWX')

        matrix `QE' = `TWT' - (`TWX' * inv(`XWX') * `XWT')
        scalar `QE' = `QE'[1,1]

        matrix `Vw2XJX' = `V' * `w2XJX'
        scalar `D' = trace(`Vw2XJX')

        matrix `VwkXX' = `V' * `wkXX'
        scalar `E' = trace(`VwkXX')

        matrix `VwkXJX_XX' = `V' * `wkXJX_XX'
        scalar `F' = trace(`VwkXJX_XX')

        *Calcuate weights

        scalar `tau_squared' = (`QE' - `m' + `E' + (`rhot' * `F')) / (`kw' - `D')
        if `tau_squared' < 0 {
            scalar `tau_squared_o' = `tau_squared'
            scalar `tau_squared' = 0
        }
		else {
			scalar `tau_squared_o' = `tau_squared'
		}
        quietly : gen double `wfinal' = 1/(`v_n' * (`v_mean' + `tau_squared'))
    }


    /*****************/
    /*    Slopes     */
    /*****************/
    matrix `XWX' = J(`p', `p', 0)
    matrix `XWT' = J(`p', 1, 0)

    foreach j in `idlist' {
        mkmat `t' if `touse' & `studynumber' == `j', matrix(`T')
        matrix colnames `T' = `t'
        mkmat `x' `cons' if `touse' & `studynumber' == `j', matrix(`X')
        matrix colnames `X' = `x' _cons
        mkmat `wfinal' if `touse' & `studynumber' == `j', matrix(`W')
        matrix `W' = diag(`W')
        matrix `XWX' = (`X'' * `W' * `X') + `XWX'
        matrix `XWT' = (`X'' * `W' * `T') + `XWT'
    }
	
    matrix `b' = (inv(`XWX') * `XWT')'
    matrix colnames `b' = `x' _cons
    matrix score double `prime_hat' = `b'
	
    gen double `prime_resid' = `t' - `prime_hat'

	
	/********************************************************************/
    /*    Variance covariance matrix estimation for standard errors     */
    /********************************************************************/

	tempname XWAeeAWX
    matrix `XWAeeAWX' = J(`p', `p', 0)
	
	*Q parameter 
	tempname Q
	mkmat `x' `cons' if `touse', matrix(`X')
	mkmat `wfinal' if `touse', matrix(`W')
	matrix `W' = diag(`W')
	matrix `Q' = inv(`X'' * `W' * `X')
	
	matrix `XWX' = J(`p', `p', 0)	
		
	tempname I_H_overall
	matrix `I_H_overall' = (I(rowsof(`X'*`Q'*`X''*`W'))-(`X'*`Q'*`X''*`W'))	

    foreach v in `x' cons {
        tempname g_`v'
        matrix `g_`v'' = J(_N, _N, 0)   
    }

	tempname blockW

    tempvar lmat
    quietly : gen `lmat' = .

    foreach j in `idlist' {
	
		*A parameter 
		
		if "`weighttype'" == "hierarchical" {
		
			mkmat `wfinal' if `touse' & `studynumber' == `j', matrix(`W')
			matrix `W' = diag(`W')	

            mkmat `x' `cons' if `touse' & `studynumber' == `j', matrix(`X')
		
			tempvar wfinal_12
			quietly : gen double `wfinal_12' = `wfinal'^(-1/2) if `touse' & `studynumber' == `j'
			tempname W_12
			mkmat `wfinal_12' if `touse' & `studynumber' == `j', matrix(`W_12')
			matrix `W_12' = diag(`W_12')
			tempvar wfinal_32
			quietly : gen double `wfinal_32' = `wfinal'^(-3/2) if `touse' & `studynumber' == `j'
			tempname W_32
			mkmat `wfinal_32' if `touse' & `studynumber' == `j', matrix(`W_32')
			matrix `W_32' = diag(`W_32')
			
			matrix `XWX' = `X'' * `W' * `X' + `XWX'
			
			tempname Hjj 
			matrix `Hjj' = `X'*`Q'*`X''*`W'
			
			tempname W_12I_HjjW_32
			
			matrix `W_12I_HjjW_32' = `W_12'*(I(rowsof(`Hjj'))-`Hjj')*`W_32'
			
			if rowsof(`W_12I_HjjW_32') == 1 & colsof(`W_12I_HjjW_32') == 1 {
				tempname alterW_12I_HjjW_32
				scalar `alterW_12I_HjjW_32' = `W_12I_HjjW_32'[1,1]
				scalar `alterW_12I_HjjW_32' = `alterW_12I_HjjW_32'^(-1/2)
				tempname W_12I_HjjW_32_12
				matrix `W_12I_HjjW_32_12' = [`alterW_12I_HjjW_32']
				
			}
			else {
				tempname P L
				matrix symeigen `P' `L' = `W_12I_HjjW_32'
				matrix `L' = diag(`L')

				tempname L_12
				local rows = rowsof(`L')
				matrix `L_12' = `L'
				forvalues i = 1/`rows' {
					matrix `L_12'[`i',`i'] = `L'[`i',`i']^(-1/2)
				}
				tempname W_12I_HjjW_32_12
				matrix `W_12I_HjjW_32_12' = `P'*`L_12'*`P''
			}
			
			tempname A
			
			matrix `A' = `W_12'*`W_12I_HjjW_32_12'*`W_12'
			
		}
		
		else if ("`weighttype'" == "random" | "`weighttype'" == "fixed") & "`uweights'" == "" {
		
			mkmat `wfinal' if `touse' & `studynumber' == `j', matrix(`W')
			matrix `W' = diag(`W')	
			
			mkmat `x' `cons' if `touse' & `studynumber' == `j', matrix(`X')
			
			matrix `XWX' = `X'' * `W' * `X' + `XWX'
			
			tempname Hjj 
			matrix `Hjj' = `X'*`Q'*`X''*`W'
			
			tempname I_Hjj
			
			matrix `I_Hjj' = (I(rowsof(`Hjj'))-`Hjj')
			
			if rowsof(`I_Hjj') == 1 & colsof(`I_Hjj') == 1 {
				tempname alterI_Hjj
				scalar `alterI_Hjj' = `I_Hjj'[1,1]
				scalar `alterI_Hjj' = `alterI_Hjj'^(-1/2)
				tempname I_Hjj_12
				matrix `I_Hjj_12' = `alterI_Hjj'
			}
			else {
				tempname P L
				matrix symeigen `P' `L' = `I_Hjj'
				matrix `L' = diag(`L')

				tempname L_12
				local rows = rowsof(`L')
				matrix `L_12' = `L'
				forvalues i = 1/`rows' {
					matrix `L_12'[`i',`i'] = `L'[`i',`i']^(-1/2)
				}
				tempname I_Hjj_12
				matrix `I_Hjj_12' = `P'*`L_12'*`P''
				
			}
			
			tempname A
			matrix `A' = `I_Hjj_12'

		}
		
		else if "`weighttype'" == "fixed" & "`uweights'" != "" {

            mkmat `wfinal' if `touse' & `studynumber' == `j', matrix(`W')
            matrix `W' = diag(`W')  
            
            mkmat `x' `cons' if `touse' & `studynumber' == `j', matrix(`X')

            matrix `XWX' = `X'' * `W' * `X' + `XWX'

			sum `wfinal' if `touse' & `studynumber' == `j', meanonly
			
			local meanweight = r(mean)
			
			sum `touse', meanonly
			local cases = r(N)

			tempname meanV

            *******************

            tempname blockmeans
            mkmat `wfinalmean' if `touse', matrix(`blockmeans') 

            matrix `meanV' = diag(`blockmeans')

            *******************

            sum `touse' if `studynumber' == `j', meanonly
            local studycases = r(sum)

            tempname Vblock
            matrix `Vblock' = I(`studycases')*`meanweight'
			
			sum `index' if `touse' & `studynumber' == `j', meanonly
			local first = r(min)
			local last = r(max)
			
			tempname I_Hj
			
			matrix `I_Hj' = `I_H_overall'[`first'..`last',.]
			
			tempname I_HjVI_Hj
			matrix `I_HjVI_Hj' = `I_Hj'*`meanV'*`I_Hj''
		

			if rowsof(`I_HjVI_Hj') == 1 & colsof(`I_HjVI_Hj') == 1 {
				tempname alterI_HjVI_Hj
				scalar `alterI_HjVI_Hj' = `I_HjVI_Hj'[1,1]
				scalar `alterI_HjVI_Hj' = `alterI_HjVI_Hj'^(-1/2)
				tempname I_HjVI_Hj_12
				matrix `I_HjVI_Hj_12' = `alterI_HjVI_Hj'
			}
			else {
				tempname P L
				matrix symeigen `P' `L' = `I_HjVI_Hj'
				matrix `L' = diag(`L')
				tempname L_12
				local rows = rowsof(`L')
				matrix `L_12' = `L'
				forvalues i = 1/`rows' {
					matrix `L_12'[`i',`i'] = `L'[`i',`i']^(-1/2)
				}
				tempname I_HjVI_Hj_12
				matrix `I_HjVI_Hj_12' = `P'*`L_12'*`P''
			}
			
			tempname A
			matrix `A' = (`meanweight'^.5)*`I_HjVI_Hj_12'
		}
        

        matrix colnames `X' = `x' _cons
        mkmat `prime_resid' if `touse' & `studynumber' == `j', matrix(`e')

        matrix `XWAeeAWX' = (`X'' * `W' * `A' * `e' * `e'' * `A' * `W' * `X') + `XWAeeAWX'

        sum `index' if `touse' & `studynumber' == `j', meanonly
        local first = r(min)
        local last = r(max)

        tempname I_Hj
            
        matrix `I_Hj' = `I_H_overall'[`first'..`last',.]

        tempname g`j'

        matrix `g`j'' = (`I_Hj''*`A'*`W'*`X'*`Q')

        local varnum : word count `x' cons
        local i = 1
        foreach v in `x' cons {
            quietly : replace `lmat' = .
            forvalues q = 1/`varnum' {
                if `q' != `i' {
                    quietly : replace `lmat' = 0 if _n == `q'
                }
                else {
                    quietly : replace `lmat' = 1 if _n == `q'
                }
            }
            tempname l_`v'
            mkmat `lmat' if _n <= `varnum', matrix(`l_`v'')

            tempname gk
            matrix `gk' = `g`j''*`l_`v''

            matrix `g_`v'' = `g_`v'' + (`gk'*`gk'')
            local ++i
        }
        

        if "`weighttype'" == "fixed" & "`uweights'" != "" {
            mata: st_matrix( "`blockW'", blockdiag( st_matrix( "`blockW'"), st_matrix( "`Vblock'")))

        }
        else {
            mata: st_matrix( "`blockW'", blockdiag( st_matrix( "`blockW'"), st_matrix( "`W'")))
        }

    }

    matrix `V' = inv(`XWX') * `XWAeeAWX' * inv(`XWX')

    forvalues i = 1/`nobs' {
        matrix `blockW'[`i',`i'] = `blockW'[`i',`i']^(-1/2)
    }

    foreach v in `x' cons {
        tempname lambda_`v'
        tempname lambda2_`v'
        scalar `lambda_`v'' = 0
        scalar `lambda2_`v'' = 0

    }   

    foreach v in `x' cons {
        tempname forlambda_`v'
        matrix `forlambda_`v'' = `blockW'*(`g_`v'')*`blockW'
        tempname part1 part2
        matrix symeigen  `part1' `part2' = `forlambda_`v''
        tempname a
        matrix `a' = `part2''
        svmat `a'
        gen `a'2 = `a'1^2
        sum `a'1, meanonly
        tempname l
        scalar `l' = r(sum)^2
        sum `a'2 , meanonly
        tempname df_`v' 
        scalar `df_`v'' = `l'/r(sum)
        drop `a'1 `a'2 
    }

    local dflist ""

    foreach v in `x' cons {
    	if "`nosmallsample'" == "" {
    		tempvar _df_`v'
        	quietly : gen `_df_`v'' = `df_`v'' if _n == 1
        	local dflist "`dflist' `_df_`v''"
    	}
        else {
        	tempvar _df_`v'
        	quietly : gen `_df_`v'' = `m'-`p' if _n == 1
        	local dflist "`dflist' `_df_`v''"
        	matrix `V' = `V' * (`m'/(`m'-`p'))
        }
    }

    tempname _dfs 

    mkmat `dflist' if _n == 1, matrix(`_dfs') 

    display _newline
    display as text "Robust standard error estimation using " as result "`weighttype'" as text " model weights"


    *name the rows and columns of the matrixes

    matrix colnames `V' = `x' _cons
    matrix rownames `V' = `x' _cons
    matrix colnames `_dfs' = `x' _cons

    *post results
    
    ereturn local depvar "`t'"
    ereturn local cmd "gmeta"
    ereturn scalar N_g = `m'

    /*********************/
    /*  Display results  */
    /*********************/

    display _col(55) as text "N Level 1" _col(69) "=" _col(69) as result %9.0f `nobs'
    display _col(55) as text "N Level 2" _col(69) "=" _col(69) as result %9.0f `m'
	display _col(55) as text "Min Level 1 n" _col(69) "=" _col(69) as result %9.0f `min_n'
	display _col(55) as text "Max Level 1 n" _col(69) "=" _col(69) as result %9.0f `max_n'
    display _col(55) as text _col (5) "Average" _col(69) "=" _col(69) as result  %9.2f `nobs' / `m'

    capture confirm existence `rho'
    if _rc != 6 {
        display _col(55) as text  "Assumed rho" _col(69) "=" _col(69) as result  %9.2f `rhot'
    }

    if "`weighttype'" == "fixed" {
    }
    else if "`weighttype'" == "random" {
        display _col(55) as text  "tau-squared" _col(69) "=" _col(69) as result  %9.4f `tau_squared'
    }
    else if "`weighttype'" == "hierarchical" {
        display _col(55) as text  "tau-squared" _col(69) "=" _col(69) as result  %9.4f `tau_squared'
        display _col(55) as text  "omega-squared" _col(69) "=" _col(69) as result  %9.4f `omega_squared'
    }

    *post values of rho
    capture confirm existence `rho'
    if _rc != 6 {
        ereturn scalar rho = `rho'
    }

    display as text  "{hline 13}" "{c TT}" "{hline 64}"

    display %12s abbrev("`t'",12)   _col(14) "{c |}" ///
                                    _col(21) "Coef." ///
                                    _col(29) "Std. Err." ///
                                    _col(40) "dfs" ///
                                    _col(50) "p-value" ///
                                    _col(60) "[" `level' "%Conf. Interval]"

    display as text  "{hline 13}" "{c +}" "{hline 64}"                            

    tempname prob
    scalar `prob' = 0

    local i = 1
    foreach v in `x' _cons {
        tempname effect variance dof
        scalar `effect' = `b'[1,`i']
        scalar `variance' = `V'[`i',`i']
        scalar `dof' = `_dfs'[1,`i']

        if `dof' < 4 {
            local problem "!"
            scalar `prob' = 1
        }
        else {
            local problem ""
        }

        display %12s abbrev("`v'",12)   _col(14) "{c |}" ///
                                        _col(16) "`problem'" ///
                                        _col(21) %5.4f `effect' ///
                                        _col(29) %5.4f sqrt(`variance') ///
                                        _col(40) %5.4f `dof' ///
                                        _col(50) %5.4f 2*ttail(`dof',abs(`effect'/sqrt(`variance'))) ///
                                        _col(60) %5.4f `effect' - invttail(`dof',((100-`level')/100)/2)*sqrt(`variance') ///
                                        _col(70) %5.4f `effect' + invttail(`dof',((100-`level')/100)/2)*sqrt(`variance')
        local ++i
    }

    display as text  "{hline 13}" "{c BT}" "{hline 64}" 

    if `prob' == 1 {
        di as error "! dof is less than 4, p-value untrustworthy"
        di as error "see Tipton, E. (in press) Small sample adjustments for robust variance"
        di as error "estimation with meta-regression. Forthcoming in Psychological Methods."
    }

    ereturn post `b' `V', obs(`nobs') depname(`t') esample(`touse')
    ereturn matrix dfs = `_dfs'

	if "`weighttype'" == "fixed" {
    }
    else if "`weighttype'" == "random" {
        ereturn scalar tau2 = `tau_squared'
        ereturn scalar tau2o = `tau_squared_o'
        ereturn scalar QE = `QE'
    }
    else if "`weighttype'" == "hierarchical" {
        ereturn scalar tau2 = `tau_squared'
        ereturn scalar tau2o = `tau_squared_o'
        ereturn scalar omega2 = `omega_squared'
        ereturn scalar omega2o = `omega_squared_o'
        ereturn scalar QE = `QE'
        ereturn scalar Q1 = `Q1'
    }
end
