**********************************************************************************************
* Human Opportunity Index                                                    			     *
*! v 1.7   26mar2011               Por Samuel Franco, Joao Pedro Azevedo & Alejandro Hoyos   *
* asis option - manage covariates that predicts failure perfectly
*! v 1.6   14mar2011               Por Samuel Franco, Joao Pedro Azevedo & Alejandro Hoyos   *
*! v 1.5   02feb2011               Por Samuel Franco, Joao Pedro Azevedo & Alejandro Hoyos   *
* Estimation using the geometric mean                                                        *
*! v 1.4   19oct2010               Por Joao Pedro Azevedo & Alejandro Hoyos   		         *
*! v 1.3   12oct2010               Por Joao Pedro Azevedo & Alejandro Hoyos                  *
*! v 1.2   10oct2010               Por Joao Pedro Azevedo & Alejandro Hoyos                  *
* Correction to the estimation of std deviation of the HOI                                   *
* Decomposition 2                                                                            *
*! v 1.1   10jul2010               Por Joao Pedro Azevedo                     		         *
* no weights                                                                                 *
* nose with no by varialbe                                                                   *
*! v 1.0   27may2010               Por Joao Pedro Azevedo & Samuel Franco    			     *
**********************************************************************************************
capture program drop hoi
program define hoi, rclass

    version 8.0

    syntax varlist(min=1)                           ///
                 [in] [if]                          ///
                 [aweight fweight iweight]          ///
                 [,                                 ///
                         BY(string)                 ///
                         BASE(real -99)             ///
                         Level(real 95)             ///
                         FORmat(string)             ///
                         ESTimates                  ///
                         adjust1(string)            ///
                         KEEP                       ///
                         NOSE                       ///
                         SIMPLE                     ///
                         COEF(string)               ///
                         MIXCOEF(string)            ///
                         decomp1                    ///
                         decomp2                    ///
                         NOWARning                  ///
				         GEOmetric			        ///
                         ASIS                       ///
                     ]


quietly {

/* temp variables */

    tempvar count countmark

/* temp names   */

    tempname temp touse tmptmp temptemp final_ineqreduc final_growth final_growth_ineq valnum
    tempname p1 D1 D1_ p1_ sum_abs1 OI1 pseudo nlogit ommega final

/* weights - 19/07/2010 */

    if ("`weight'" == "") {
        tempname wtg
        gen `wtg' = 1
        loc weight "fw"
        loc exp    "=`wtg'"
    }

/* mark observations  */

    qui logit `varlist' `if' `in' [`weight'`exp'], `asis'

    gen `countmark' = 1
    if ("`if'" == "") {
        loc ifmark " if `countmark' == 1 & e(sample) "
    }
    else {
        loc ifmark " if e(sample) "
    }

    mark `touse' `ifmark' `in' [`weight'`exp']
    markout `touse' `varlist'

    local exp2 = subinstr("`exp'","=","",.)

/* idetify outcome variable  */

    tokenize `varlist'
    local vardep `1'
    macro shift
    local varindep `*'

/* generate temp variable  */

    gen `count' = 1
    if ("`if'" == "") {
        loc if " if `count' == 1"
    }

/* set default options */

    if ("`format'" == "") {
        loc format "%16.4fc"
    }

    if ("`estimates'" != "") {
        loc noi noisily
    }

/* Flow control */
/** by option error messages */

    loc flag = 1

    if ("`by'" != "") {

        _pecats2 `by' if `touse'
        local nrows = r(numcats)
        local c = r(catvals)
        local labcat = r(catnms8)

        if (`nrows' < 2)  {                             /* JPA 04/02/2010 */
        	di _n in y " by " in g " variable needs to have at least two values"
        	exit 498
        }
        if (`base' != -99) {
            local c = subinword("`c'",string(`base'),"",.)
        }
        if (`base' == -99) {
            local base = word("`c'",1)
            local c = subinword("`c'","`base'","",.)
        }
        loc k = 0
        foreach num in `base' `c' {
            loc by`k' = `num'
            loc k = `k'+1
        }
        loc k = 0
        foreach num in `base' `c' {
            loc lab_by`k' : label  (`by')  `num'
            loc k = `k'+1
        }

        loc flag = 2
    }

/* if the by IS NOT enabled  */

    if ("`by'" == "") & (`flag' == 1) {

        loc vk = 1

        tempvar by varname
        gen double `by' = 1
        loc by1 = 1
        loc lab_`by1' = 1

        tempvar varp`by1' varabs`by1' varD`by1' varD`by1'_ count`by1'

        gen `count`by1'' = 1

/* generate stats on outcome variable */

        qui sum `vardep' `if' & `by' == `by1'
        loc depobs1`by1' = r(N)
        qui sum `vardep' if `touse' & `by' == `by1'
        loc depobs2`by1' = r(N)
        loc loss`by1' = 100*(1-(`depobs2`by1''/`depobs1`by1''))

        qui sum `vardep' `if' & `by' == `by1'  [`weight'`exp']
        loc mean1`by1' = r(mean)
        qui sum `vardep'  if `touse' & `by' == `by1'  [`weight'`exp']
        loc mean2`by1' = r(mean)

        *** CÁLCULO DESIGUALDAD ***
        * Step one: estimating D is to fit the following logistic regression
* check it coverage is 100 if  `by' == `by1'        /* JPA 04/02/2010 */

        tempname variable value type
        gen `type' = .
        gen `variable' = .
        gen `value' = .
        lab var `type'      "Type"
        lab var `variable'  "Variable"
        lab var `value'     "Value"
        lab define __variable 1 "Coverage (C)" 2 "Dissemilarity (D)" 3 "Human Opportunity Index (HOI)" 4 "Pseudo R2" 5 "Obs Logit" 6 "Obs" 7 "Wtg Pop" 8 "Vulnerable Pop" 9 "Vulnerable (%)" 10 "Obs 1" 11 "Obs 2" 12 "Loss (%)", add modify
        lab value `variable' __variable
        lab define __type 1 "Values" 2 "Std Error" 3 "LB (`level')" 4 "UB (`level')", add modify
        lab value `type' __type

        if (`mean1`by1'' == 1) | (`mean2`by1'' == 1) {

            loc p`by1'_    = 1
            loc D`by1'     = 0
            loc OI`by1'    = 100
            loc pseudo`by1' = -99
            loc nlogit`by1' = -99
            loc obs`by1'    = -99

            loc v = 1
            foreach num in `p`by1'_'  `D`by1''  `OI`by1''  `pseudo`by1''  `nlogit`by1''  `obs`by1''  `wpop`by1''  `vulnpop`by1''  `vuln`by1''  `depobs1`by1''  `depobs2`by1''  `loss`by1'' {
                loc lab = word("p d hoi pseudo nlogit obs wpop vulnpop vuln deobs1 deobs2 loss", `v')
                replace `type'      = 1     in `vk'
                replace `variable'  = `v'   in `vk'
                replace `value'     = `num' in `vk'
                return local `lab'_`by1' = `num'
                loc vk = `vk'+1
                loc v = `v'+1
            }
            noi tabdisp `variable' if `value' != ., cell(`value') format(`format')
        }


* check it coverage is 0    if  `by' == `by1'        /* JPA 04/02/2010 */

        if (`mean1`by1'' == 0) | (`mean2`by1'' == 0) {

            loc p`by1'_        = 0
            loc D`by1'         = 0
            loc OI`by1'        = 0
            loc pseudo`by1'     = -99
            loc nlogit`by1'     = -99
            loc obs`by1'        = -99

            loc v = 1
            foreach num in `p`by1'_'  `D`by1''  `OI`by1''  `pseudo`by1''  `nlogit`by1''  `obs`by1''  `wpop`by1''  `vulnpop`by1''  `vuln`by1''  `depobs1`by1''  `depobs2`by1''  `loss`by1'' {
                loc lab = word("p d hoi pseudo nlogit obs wpop vulnpop vuln deobs1 deobs2 loss", `v')
                replace `type'      = 1     in `vk'
                replace `variable'  = `v'   in `vk'
                replace `value'     = `num' in `vk'
                return local `lab'_`by1' = `num'
                loc vk = `vk'+1
                loc v = `v'+1
            }
            noi tabdisp `variable' if `value' != ., cell(`value') format(`format')
        }

* Estimando los parametros en la regresion logistica

        if (`mean1`by1'' != 0) & (`mean2`by1'' != 0) & (`mean1`by1'' != 1) & (`mean2`by1'' != 1) {

            tempname col
            loc wcount1`by1' = wordcount("`varindep'")

            `noi' logit `vardep' `varindep'  if `by' == `by1'  & `touse'  [pw=`exp2'], `asis'
            mat `col' = colsof(e(b))
            local n = `col'[1,1]
            loc pseudo`by1' = e(r2_p)
            loc nlogit`by1' = e(N)
            mat `ommega' = e(V)

            indeplist , local
            loc wcount2`by1' = wordcount("`X'")
		
		if("`geometric'"==""){
	            tempvar interc1 pred1_`by1' pred2_`by1' estim1_`by1' estim2_`by1'
		}
		if("`geometric'"!=""){
	            tempvar interc1 pred1_`by1' pred2_`by1' estim1_`by1' estim2_`by1' lpred1_`by1' lpred2_`by1'
		}

            tempname matcoef1 matcoef2 final_`by1'

            /* Step two: obtain for each individual in our universe his/her
              predicted probability of access to the opportunity in consideration
             P^ = Exp(B^i + Suma(Xki*B^k)) / (1 + Exp(B^i + Suma(Xki*B^k))) */

*            qui adjust `adjust1'                     , xb gen(`estim1_`by1'')
            qui adjust `adjust1'  if e(sample)       , pr gen(`pred1_`by1'')
*            qui adjust `adjust2'                     , xb gen(`estim2_`by1'')
*            qui adjust `adjust2'  if e(sample)       , pr gen(`pred2_`by1'')

            * Step three: compute
            * P_promedio = Suma_n (Wi*P^i)

            qui sum `pred1_`by1''  [`weight'`exp']
            loc p`by1' = r(mean)
            gen double `varp`by1'' = (`p`by1'') if `pred1_`by1'' != .

            * compute vulnerable population
            qui sum `count`by1''                 if `pred1_`by1'' != .
            loc obs`by1' = r(N)
            qui sum `count`by1'' [`weight'`exp'] if `pred1_`by1'' != .
            loc wpop`by1' = r(sum_w)
            qui sum `count`by1'' [`weight'`exp'] if `pred1_`by1'' <= `p`by1'' & `pred1_`by1'' != .
            loc vulnpop`by1' = r(sum_w)
            loc vuln`by1' = (`vulnpop`by1''/`wpop`by1'')*100

            * D^ = (1/2) * (1/P_promedio) * Suma_n(Wi * |P^i - P_promedio|)
		
		if("`geometric'"==""){
	            gen double `varabs`by1'' = abs(`pred1_`by1'' - `p`by1'') if `pred1_`by1'' != .
      	      qui sum `varabs`by1'' if `pred1_`by1'' != .  [`weight'`exp']
            	loc sum_abs`by1' = r(mean)

	            gen double `varD`by1'' = 0.5 * (1/(`p`by1'')) * (`sum_abs`by1'') if `pred1_`by1'' != .
	            qui sum `varD`by1'' if `pred1_`by1'' != .  [`weight'`exp']
	            loc D`by1' = r(mean)*100

      	      gen double `varD`by1'_' = 1 - `varD`by1'' if `pred1_`by1'' != .
            	qui sum `varD`by1'_' if `pred1_`by1'' != .  [`weight'`exp']
	            loc D`by1'_ = r(mean) *100

      	      qui sum `pred1_`by1''  [`weight'`exp']
            	loc p`by1'_ = r(mean)*100

	            loc OI`by1' = `p`by1'_' * `D`by1'_' / 100
		}

		if("`geometric'"!=""){
			*HOI geometric sensitive
			gen `lpred1_`by1''=ln(`pred1_`by1'')
      	      qui sum `pred1_`by1''  [`weight'`exp']
            	loc p`by1'_ = r(mean)*100
	            qui sum `lpred1_`by1'' if `pred1_`by1'' != .  [`weight'`exp']
	            loc lp`by1'_ = r(mean)
	            loc OI`by1' = 100*exp(`lp`by1'_')
			
	            loc D`by1'_ = 100*(1-`OI`by1''/(`p`by1'_'))
			loc D`by1'=`D`by1'_'
			gen double `varD`by1''=`D`by1''
		}

		if("`geometric'"==""){
            ********************************************************
            *** Variance   ***
            ********************************************************
            * (P)  var = Theta * Ommega * Theta'
            ********************************************************

            tempvar l
            tempname theta var_p`by1'

            sum `exp2' if `pred1_`by1'' != .	
            loc m = r(mean)

            gen     `l' = 1 if `pred1_`by1'' <= `p`by1'' & `pred1_`by1'' != .
            replace `l' = 0 if `pred1_`by1'' > `p`by1''  & `pred1_`by1'' != .

            loc j=0

            qui foreach x in `X' cons { 								/*SAM - contante depois das variáveis, mantendo a ordem do resultado na matriz Ommega*/
                tempvar z`j'
                if ("`x'" == "cons") {
                    gen double `z`j'' = `pred1_`by1''*(1-`pred1_`by1'')*1
                }
                else {
                    gen double `z`j'' = `pred1_`by1''*(1-`pred1_`by1'')*`x'
                }
                sum `z`j'' if (`l' == 1 | `l' == 0) [`weight'`exp']
                loc wp1px = r(mean)
                loc g3 = `wp1px'
                mat `theta' = nullmat(`theta'), `g3'
                loc j = `j'+1
            }

            mat `var_p`by1'' = `theta' * `ommega' * `theta''

            loc var_p`by1' = `var_p`by1''[1,1]
            loc se_p`by1' = 100*((`var_p`by1'')^.5)

            ********************************************************
            * (D)  var = Gamma * Ommega * Gamma'
            ********************************************************

            tempvar l
            tempname gamma var_d`by1'

            sum `exp2' if `pred1_`by1'' != .	
            loc m = r(mean)

            gen     `l' = 1 if `pred1_`by1'' <= `p`by1'' & `pred1_`by1'' != .
            replace `l' = 0 if `pred1_`by1'' > `p`by1''  & `pred1_`by1'' != .

            loc j=0

            qui foreach x in `X' cons { 								/*SAM - contante depois das variáveis, mantendo a ordem do resultado na matriz Ommega*/

                tempvar z`j'
                if ("`x'" == "cons") {
                    gen double `z`j'' = `pred1_`by1''*(1-`pred1_`by1'')*1
                }
                else {
                    gen double `z`j'' = `pred1_`by1''*(1-`pred1_`by1'')*`x'
                }

                sum `pred1_`by1'' if `l' == 1  [`weight'`exp']
                loc wpl = r(mean)

                sum `pred1_`by1'' if `l' == 0  [`weight'`exp']
                loc wpu = r(mean)

                sum `z`j'' if `l' == 1  [`weight'`exp']
                loc wp1pxl = r(mean)

                sum `z`j'' if `l' == 0  [`weight'`exp']
                loc wp1pxu = r(mean)

                loc g = (1/(`p`by1''^2)) * ((`wpl' * `wp1pxu') - (`wpu' * `wp1pxl'))

                mat `gamma' = nullmat(`gamma'), `g'

                loc j = `j'+1

            }

            mat `var_d`by1'' = `gamma' * `ommega' * `gamma''

            loc var_d`by1' = `var_d`by1''[1,1]
            loc se_d`by1' = 100*((`var_d`by1'')^.5)

            *************************************************
            * (OI)  var = Gamma2 * Ommega * Gamma2'
            *************************************************

            tempvar l count
            tempname gamma2 var_o`by1'

            gen     `l' = 1 if `pred1_`by1'' <= `p`by1'' & `pred1_`by1'' != .
            replace `l' = 0 if `pred1_`by1'' > `p`by1'' & `pred1_`by1'' != .

            gen `count' = 1 if `pred1_`by1'' != .								/*SAM - count apenas quando o predito for diferente de missing*/
            sum `count' if `l' == 0  [`weight'`exp']
            loc s = r(sum)
            sum `count'  [`weight'`exp']
            loc n = r(sum)
            loc alpha = `s'/`n'

            loc j=0

            qui foreach x in `X' cons { 								/*SAM - contante depois das variáveis, mantendo a ordem do resultado na matriz Ommega*/

                tempvar z`j'
                if ("`x'" == "cons") {
                    gen double `z`j'' = `pred1_`by1''*(1-`pred1_`by1'')*1
                }
                else {
                    gen double `z`j'' = `pred1_`by1''*(1-`pred1_`by1'')*`x'
                }

                sum `z`j'' if `l' == 1  [`weight'`exp']
                loc wp1pxl = r(sum)

                sum `z`j'' if `l' == 0  [`weight'`exp']
                loc wp1pxu = r(sum)

                loc g2 = (((1+`alpha')/`n') * `wp1pxl') + ((`alpha'/`n') * `wp1pxu')

                mat `gamma2' = nullmat(`gamma2'), `g2'

                loc j = `j'+1

            }

            mat `var_o`by1'' = `gamma2' * `ommega' * `gamma2''

            loc var_o`by1' = `var_o`by1''[1,1]
            loc se_o`by1' = 100*((`var_o`by1'')^.5)
		}

            *** Guardando resultados ***

            loc v = 1
            foreach num in `p`by1'_'  `D`by1''  `OI`by1''  `pseudo`by1''  `nlogit`by1''  `obs`by1''  `wpop`by1''  `vulnpop`by1''  `vuln`by1''  `depobs1`by1''  `depobs2`by1''  `loss`by1'' {

                loc lab = word("p d hoi pseudo nlogit obs wpop vulnpop vuln deobs1 deobs2 loss", `v')

                replace `type'      = 1     in `vk'
                replace `variable'  = `v'   in `vk'
                replace `value'     = `num' in `vk'

                if (`v' <= 3) {
                    return scalar `lab'_`mixlab'`by1' = `num'
                }
                else {
                    return local `lab'_`mixlab'`by1' = `num'
                }

                loc vk = `vk'+1
                loc v = `v'+1
            }

		if("`geometric'"==""){
	            loc v = 1
      	      foreach num in `se_p`by1'' `se_d`by1'' `se_o`by1''  {

            	    loc lab = word("se_p se_d se_oi", `v')

	                replace `type'      = 2     in `vk'
      	          replace `variable'  = `v'   in `vk'
            	    replace `value'     = `num' in `vk'

	                return local `lab'_`by1' = `num'

      	          loc vk = `vk'+1
            	    loc v = `v'+1
	            }

	            foreach num in 1 2 3 {
      	          loc m  = word("`p`by1'_'  `D`by1''  `OI`by1''", `num')
	      	    loc se = word("`se_p`by1'' `se_d`by1'' `se_o`by1''", `num')
			    replace `type'      = 3     in `vk'
	                replace `variable'  = `num'   in `vk'
	                replace `value'     = `m' - (`se'*invnormal((100-(100-`level')/2)/100)) in `vk'
	                loc vk = `vk'+1
      	      }

	            foreach num in 1 2 3 {
      	          loc m  = word("`p`by1'_'  `D`by1''  `OI`by1''", `num')
            	    loc se = word("`se_p`by1'' `se_d`by1'' `se_o`by1''", `num')
	                replace `type'      = 4     in `vk'
	                replace `variable'  = `num'   in `vk'
	                replace `value'     = `m' + (`se'*invnormal((100-(100-`level')/2)/100)) in `vk'
	                loc vk = `vk'+1
      	      }
		}

            if ("`simple'" == "") & ("`nose'" == "") {
                noi tabdisp  `variable' `type' if `value' != ., cell(`value') format(`format')
            }
            if ("`simple'" != "") & ("`nose'" == "") {
                noi tabdisp  `variable' `type' if `value' != . & `variable' <= 3, cell(`value') format(`format')
            }

            if ("`simple'" == "") & ("`nose'" != "") {
                noi tabdisp  `variable' `type' if `value' != . & `type' == 1, cell(`value') format(`format')
            }
            if ("`simple'" != "") & ("`nose'" != "") {
                noi tabdisp  `variable' `type' if `value' != . & `variable' <= 3 & `type' == 1, cell(`value') format(`format')
            }
		if("`geometric'"!=""){
			noisily display in green "Note: The estimation corresponds to the geometric version of the HOI"	
		}

            if (`wcount1`by1'' != `wcount2`by1'') & ("`nowarning'" == "") {
                noi di in r "WARNING " in g ": " in y `wcount1`by1''-`wcount2`by1'' in g " initially selected circunstances were not used to estimate Pi. Consider using the asis option."
            }

            if ("`keep'" != "") {
                gen double pred_`by1' = `pred1_`by1''
            }

        }

    }

/* if the BY IS enabled  */

    loc mixnumb 1

    if ("`by'" != "")  & (`flag' == 2) {

        return local byvalues = "`base' `c'"
        return local bybase = "`base'"

        loc vk = 1

        tempname variable value type byvar mixvar decomp1var decomp2var
        gen `type'              = .
        gen `variable'          = .
        gen `value'             = .
        gen `byvar'             =.
        gen `mixvar'            =.
        gen `decomp1var'        =.
        gen `decomp2var'        =.
        lab var `type'          "Type"
        lab var `variable'      "Variable"
        lab var `value'         "Value"
        lab var `byvar'         "By: `by'"
        lab var `mixvar'        "Round"
        lab var `decomp1var'    "Decomposition 1: Scale and Distribution effects"
        lab var `decomp2var'    "Decomposition 2: Composition, Equalizatio and Scale effects"
        lab define __variable ///
                1 "Coverage (C)" ///
                2 "Dissemilarity (D)" ///
                3 "Human Opportunity Index (HOI)" ///
                4 "Pseudo R2" ///
                5 "Obs Logit" ///
                6 "Obs" ///
                7 "Wtg Pop" ///
                8 "Vulnerable Pop" ///
                9 "Vulnerable (%)" ///
                10 "Obs 1" ///
                11 "Obs 2" ///
                12 "Loss (%)" ///
                13 "Change (p.p.)" ///
                14 "Scale (%)" ///
                15 "Distribution (%)" ///
                16 "Change (p.p.)" ///
                17 "Composition (p.p.)" ///
                18 "Scale (p.p.)" ///
                19 "Equalization (p.p.)" ///
                20 "Composition (%)" ///
                21 "Scale (%)" ///
                22 "Equalization (%)" ///
                    , add modify
        lab value `variable' __variable
        lab define __type 1 "Values" 2 "Std Error" 3 "LB (`level')" 4 "UB (`level')", add modify
        lab value `type' __type
        lab define ___decomp1var 1 "Original" 2 "Decomposition", add modify
        lab value `decomp1var' ___decomp1var
        lab define ___decomp2var 1 "Original" 2 "Decomposition (p.p.)" 3 "Decomposition (%)", add modify
        lab value `decomp2var' ___decomp2var

        foreach mixval in `mixnumb' {

            if (`mixval' != 1) {
                loc mixlab "`mixval'_"
            }

            tempname col

            tempvar mix_pred1_all

            foreach by1 in `base' `c' {

    /* tempvar  */

	if("`geometric'"==""){
            tempvar interc1 pred1_`by1' mix_pred1_`by1' pred2_`by1' estim1_`by1' estim2_`by1' varp`by1' varabs`by1'
	}
	if("`geometric'"!=""){
            tempvar interc1 pred1_`by1' lpred1_`by1' mix_pred1_`by1' mix_lpred1_`by1' pred2_`by1' estim1_`by1' estim2_`by1' varp`by1' varabs`by1'
	}
	
	tempvar varp`by1' varabs`by1' varD`by1' varD`by1'_ count`by1'


    /* generate variables  */

                gen `count`by1'' = 1

    /* generate stats on outcome variable */

                qui sum `vardep' `if' & `by' == `by1'
                loc depobs1`by1' = r(N)
                qui sum `vardep' if `touse' & `by' == `by1'
                loc depobs2`by1' = r(N)
                loc loss`by1' = 100*(1-(`depobs2`by1''/`depobs1`by1''))

                qui sum `vardep' `if' & `by' == `by1'  [`weight'`exp']
                loc mean1`by1' = r(mean)
                qui sum `vardep'  if `touse' & `by' == `by1'  [`weight'`exp']
                loc mean2`by1' = r(mean)

                *** CÁLCULO DESIGUALDAD ***
                * Step one: estimating D is to fit the following logistic regression
        * check it coverage is 100 if  `by' == `by1'        /* JPA 04/02/2010 */

                if (`mean1`by1'' == 1) | (`mean2`by1'' == 1) {

                    loc p`by1'_    = 1
                    loc D`by1'     = 0
                    loc OI`by1'    = 100
                    loc pseudo`by1' = -99
                    loc nlogit`by1' = -99
                    loc obs`by1'    = -99

                    loc v = 1
                    foreach num in `p`by1'_'  `D`by1''  `OI`by1''  `pseudo`by1''  `nlogit`by1''  `obs`by1''  `wpop`by1''  `vulnpop`by1''  `vuln`by1''  `depobs1`by1''  `depobs2`by1''  `loss`by1'' {
                        loc lab = word("p d hoi pseudo nlogit obs wpop vulnpop vuln deobs1 deobs2 loss", `v')
                        replace `byvar'     = `by1' in `vk'
                        replace `type'      = 1     in `vk'
                        replace `variable'  = `v'   in `vk'
                        replace `value'     = `num' in `vk'
                        return local `lab'_`by1' = `num'
                        loc vk = `vk'+1
                        loc v = `v'+1
                    }
                }


        * check it coverage is 0    if  `by' == `by1'        /* JPA 04/02/2010 */

                if (`mean1`by1'' == 0) | (`mean2`by1'' == 0) {

                    loc p`by1'_        = 0
                    loc D`by1'         = 0
                    loc OI`by1'        = 0
                    loc pseudo`by1'     = -99
                    loc nlogit`by1'     = -99
                    loc obs`by1'        = -99

                    loc v = 1
                    foreach num in `p`by1'_'  `D`by1''  `OI`by1''  `pseudo`by1''  `nlogit`by1''  `obs`by1''  `wpop`by1''  `vulnpop`by1''  `vuln`by1''  `depobs1`by1''  `depobs2`by1''  `loss`by1'' {
                        loc lab = word("p d hoi pseudo nlogit obs wpop vulnpop vuln deobs1 deobs2 loss", `v')
                        replace `byvar'     = `by1' in `vk'
                        replace `type'      = 1     in `vk'
                        replace `variable'  = `v'   in `vk'
                        replace `value'     = `num' in `vk'
                        return local `lab'_`by1' = `num'
                        loc vk = `vk'+1
                        loc v = `v'+1
                    }
                }

        * Estimando los parametros en la regresion logistica

                if (`mean1`by1'' != 0) & (`mean2`by1'' != 0) & (`mean1`by1'' != 1) & (`mean2`by1'' != 1) {

        /* coef option  */

                    if (`mixval' == 1) {
                        if ("`coef'" != "") {
                            if ("`coef'" == "all") {
                                `noi' logit `vardep' `varindep'  if `touse'  [pw=`exp2'], `asis'
                                if (`by1' == `base') {
                                    loc wcount1`by1' = wordcount("`varindep'")
                                    mat `col' = colsof(e(b))
                                    local n = `col'[1,1]
                                    loc pseudo`by1' = e(r2_p)
                                    loc nlogit`by1' = e(N)
                                    mat `ommega' = e(V)
                                    indeplist , local
                                    loc wcount2`by1' = wordcount("`X'")
                                    qui adjust `adjust1' if e(sample) , pr gen(`pred1_`by1'')     /* Step two: obtain for each individual in our universe his/her predicted probability of access to the opportunity in consideration P^ = Exp(B^i + Suma(Xki*B^k)) / (1 + Exp(B^i + Suma(Xki*B^k))) */
                                }
                                else {
                                    loc wcount1`by1' = `wcount1`base''
                                    loc pseudo`by1'  = `pseudo`base''
                                    loc nlogit`by1'  = `nlogit`base''
                                    loc wcount2`by1' = `wcount2`base''
                                    gen double `pred1_`by1'' = `pred1_`base''
                                }
                            }
                            else {
                                `noi' logit `vardep' `varindep'  if `by' == `base'  & `touse'  [pw=`exp2'], `asis'
                                if (`by1' == `base') {
                                    loc wcount1`by1' = wordcount("`varindep'")
                                    mat `col' = colsof(e(b))
                                    local n = `col'[1,1]
                                    loc pseudo`by1' = e(r2_p)
                                    loc nlogit`by1' = e(N)
                                    mat `ommega' = e(V)
                                    indeplist , local
                                    loc wcount2`by1' = wordcount("`X'")
                                    qui adjust `adjust1' if `by' == `base'  & `touse' , pr gen(`pred1_`by1'')     /* Step two: obtain for each individual in our universe his/her predicted probability of access to the opportunity in consideration P^ = Exp(B^i + Suma(Xki*B^k)) / (1 + Exp(B^i + Suma(Xki*B^k))) */
                                }
                                else {
                                    loc wcount1`by1' = `wcount1`base''
                                    loc pseudo`by1'  = `pseudo`base''
                                    loc nlogit`by1'  = `nlogit`base''
                                    loc wcount2`by1' = `wcount2`base''
                                    gen double `pred1_`by1'' = `pred1_`base''
                                }
                            }
                        }
                        if ("`coef'" == "")  {
                            `noi' logit `vardep' `varindep'  if `by' == `by1'  & `touse'  [pw=`exp2'], `asis'
                            loc wcount1`by1' = wordcount("`varindep'")
                            mat `col' = colsof(e(b))
                            local n = `col'[1,1]
                            loc pseudo`by1' = e(r2_p)
                            loc nlogit`by1' = e(N)
                            mat `ommega' = e(V)
                            indeplist , local
                            loc wcount2`by1' = wordcount("`X'")
                            qui adjust `adjust1' if e(sample) , pr gen(`pred1_`by1'')     /* Step two: obtain for each individual in our universe his/her predicted probability of access to the opportunity in consideration P^ = Exp(B^i + Suma(Xki*B^k)) / (1 + Exp(B^i + Suma(Xki*B^k))) */
                        }
                    }
                    if ("`decomp2'" != "") {
                        if ("`mixcoef'" != "") {
                            if ("`mixcoef'" == "all") {
                                `noi' logit `vardep' `varindep'  if `touse'  [pw=`exp2']logit opp x1 x2, `asis'
logit opp x2
logit opp x1 x2, asis

                                if (`by1' == `base') {
                                    qui adjust `adjust1' if  e(sample), pr gen(`mix_pred1_all')     /* Step two: obtain for each individual in our universe his/her predicted probability of access to the opportunity in consideration P^ = Exp(B^i + Suma(Xki*B^k)) / (1 + Exp(B^i + Suma(Xki*B^k))) */
                                    gen double `mix_pred1_`base'' = `mix_pred1_all'  if `by' == `base'  & `touse'
                                }
                                else {
                                    gen double `mix_pred1_`by1'' = `mix_pred1_all'  if `by' == `by1'  & `touse'
                                }
                            }
                            else {
                                `noi' logit `vardep' `varindep'  if `by' == `base'  & `touse'  [pw=`exp2'], `asis'
                                if (`by1' == `base') {
                                    qui adjust `adjust1' if `by' == `by1'  & `touse' , pr gen(`mix_pred1_`base'')     /* Step two: obtain for each individual in our universe his/her predicted probability of access to the opportunity in consideration P^ = Exp(B^i + Suma(Xki*B^k)) / (1 + Exp(B^i + Suma(Xki*B^k))) */
                                }
                                else {
                                    gen double `mix_pred1_`by1'' = `mix_pred1_`base''
                                }
                            }
                        }
                         if ("`mixcoef'" == "")  {
                            `noi' logit `vardep' `varindep'  if `by' == `base'  & `touse'  [pw=`exp2'], `asis'
                            qui adjust `adjust1' if `by' == `by1'  & `touse', pr gen(`mix_pred1_`by1'')     /* Step two: obtain for each individual in our universe his/her predicted probability of access to the opportunity in consideration P^ = Exp(B^i + Suma(Xki*B^k)) / (1 + Exp(B^i + Suma(Xki*B^k))) */
                        }
                    }

                    * Step three: compute
                    * P_promedio = Suma_n (Wi*P^i)

                    qui sum `pred1_`by1''  [`weight'`exp']  if `by' == `by1'
                    loc p`by1' = r(mean)
                    gen double `varp`by1'' = (`p`by1'')     if `by' == `by1' & `pred1_`by1'' != .

                    * compute vulnerable population
                    qui sum `count`by1''                     if `pred1_`by1'' != . &  `by' == `by1'
                    loc obs`by1' = r(N)
                    qui sum `count`by1'' [`weight'`exp']     if `pred1_`by1'' != . &  `by' == `by1'
                    loc wpop`by1' = r(sum_w)
                    qui sum `count`by1'' [`weight'`exp']     if `pred1_`by1'' <= `p`by1'' & `pred1_`by1'' != . &  `by' == `by1'
                    loc vulnpop`by1' = r(sum_w)
                    loc vuln`by1' = (`vulnpop`by1''/`wpop`by1'')*100
                    qui di `vuln`by1''

                    * D^ = (1/2) * (1/P_promedio) * Suma_n(Wi * |P^i - P_promedio|)

			  if("`geometric'"!=""){
				gen `lpred1_`by1''=ln(`pred1_`by1'')
				qui sum `pred1_`by1''  [`weight'`exp'] if `by' == `by1' & `pred1_`by1'' != .
				loc p`by1'_ = r(mean)*100
				qui sum `lpred1_`by1'' if `by' == `by1' & `pred1_`by1'' != . [`weight'`exp']
				loc lp`by1'_ = r(mean)
				loc OI`by1' = 100*exp(`lp`by1'_')
				
				loc D`by1'_ = 100*(1-`OI`by1''/(`p`by1'_'))
				loc D`by1'=`D`by1'_'
				gen double `varD`by1''=`D`by1''
			  }

			  if("`geometric'"==""){
                    gen double `varabs`by1'' = abs(`pred1_`by1'' - `p`by1'')            if `by' == `by1' & `pred1_`by1'' != .
                    qui sum `varabs`by1''  [`weight'`exp']                              if `by' == `by1' & `pred1_`by1'' != .
                    loc sum_abs`by1' = r(mean)

                    gen double `varD`by1'' = 0.5 * (1/(`p`by1'')) * (`sum_abs`by1'')    if `by' == `by1' & `pred1_`by1'' != .
                    qui sum `varD`by1''  [`weight'`exp']                                if `by' == `by1' & `pred1_`by1'' != .
                    loc D`by1' = r(mean)*100

                    gen double `varD`by1'_' = 1 - `varD`by1''                           if `by' == `by1' & `pred1_`by1'' != .
                    qui sum `varD`by1'_'  [`weight'`exp']                               if `by' == `by1' & `pred1_`by1'' != .
                    loc D`by1'_ = r(mean) *100

                    qui sum `pred1_`by1''  [`weight'`exp']                              if `by' == `by1' & `pred1_`by1'' != .
                    loc p`by1'_ = r(mean)*100

                    loc OI`by1' = `p`by1'_' * `D`by1'_' / 100
			
                    ********************************************************
                    *** Variance   ***
                    ********************************************************
                    * (P)  var = Theta * Ommega * Theta'
                    ********************************************************

                    tempvar l
                    tempname theta var_p`by1'

                    sum `exp2' if `by' == `by1' &  `pred1_`by1'' != .	
                    loc m = r(mean)

                    gen     `l' = 1 if `pred1_`by1'' <= `p`by1'' & `pred1_`by1'' != . & `by' == `by1'
                    replace `l' = 0 if `pred1_`by1'' > `p`by1''  & `pred1_`by1'' != . & `by' == `by1'

                    loc j=0

                    qui foreach x in `X' cons { 								/*SAM - contante depois das variáveis, mantendo a ordem do resultado na matriz Ommega*/
                        tempvar z`j'
                        if ("`x'" == "cons") {
                            gen double `z`j'' = `pred1_`by1''*(1-`pred1_`by1'')*1   if  `by' == `by1'
                        }
                        else {
                            gen double `z`j'' = `pred1_`by1''*(1-`pred1_`by1'')*`x' if  `by' == `by1'
                        }
                        sum `z`j'' if (`l' == 1 | `l' == 0) & `by' == `by1'  [`weight'`exp']
                        loc wp1px = r(mean)
                        loc g3 = `wp1px'
                        mat `theta' = nullmat(`theta'), `g3'
                        loc j = `j'+1
                    }

                    mat `var_p`by1'' = `theta' * `ommega' * `theta''

                    loc var_p`by1' = `var_p`by1''[1,1]
                    loc se_p`by1' = 100*((`var_p`by1'')^.5)

                    ********************************************************
                    * (D)  var = Gamma * Ommega * Gamma'
                    ********************************************************

                    tempvar l
                    tempname gamma var_d`by1'

                    sum `exp2' if `pred1_`by1'' != .	 & `by' == `by1'
                    loc m = r(mean)

                    gen     `l' = 1 if `pred1_`by1'' <= `p`by1'' & `pred1_`by1'' != . & `by' == `by1'
                    replace `l' = 0 if `pred1_`by1'' > `p`by1''  & `pred1_`by1'' != . & `by' == `by1'

                    loc j=0

                    qui foreach x in `X' cons { 								/*SAM - contante depois das variáveis, mantendo a ordem do resultado na matriz Ommega*/

                        tempvar z`j'
                        if ("`x'" == "cons") {
                            gen double `z`j'' = `pred1_`by1''*(1-`pred1_`by1'')*1   if  `by' == `by1'
                        }
                        else {
                            gen double `z`j'' = `pred1_`by1''*(1-`pred1_`by1'')*`x' if  `by' == `by1'
                        }

                        sum `pred1_`by1'' if `l' == 1 & `by' == `by1' [`weight'`exp']
                        loc wpl = r(mean)

                        sum `pred1_`by1'' if `l' == 0 & `by' == `by1' [`weight'`exp']
                        loc wpu = r(mean)

                        sum `z`j'' if `l' == 1 & `by' == `by1' [`weight'`exp']
                        loc wp1pxl = r(mean)

                        sum `z`j'' if `l' == 0 & `by' == `by1' [`weight'`exp']
                        loc wp1pxu = r(mean)

                        loc g = (1/(`p`by1''^2)) * ((`wpl' * `wp1pxu') - (`wpu' * `wp1pxl'))

                        mat `gamma' = nullmat(`gamma'), `g'

                        loc j = `j'+1

                    }

                    mat `var_d`by1'' = `gamma' * `ommega' * `gamma''

                    loc var_d`by1' = `var_d`by1''[1,1]
                    loc se_d`by1' = 100*((`var_d`by1'')^.5)

                    *************************************************
                    * (OI)  var = Gamma2 * Ommega * Gamma2'
                    *************************************************

                    tempvar l count
                    tempname gamma2 var_o`by1'

                    gen     `l' = 1 if `pred1_`by1'' <= `p`by1'' & `pred1_`by1'' != .   & `by' == `by1'
                    replace `l' = 0 if `pred1_`by1'' > `p`by1'' & `pred1_`by1'' != .    & `by' == `by1'

                    gen `count' = 1 if `pred1_`by1'' != .   & `by' == `by1'								/*SAM - count apenas quando o predito for diferente de missing*/
                    sum `count' if `l' == 0 & `by' == `by1' [`weight'`exp']
                    loc s = r(sum)
                    sum `count'  [`weight'`exp'] if `by' == `by1'
                    loc n = r(sum)
                    loc alpha = `s'/`n'

                    loc j=0

                    qui foreach x in `X' cons { 								/*SAM - contante depois das variáveis, mantendo a ordem do resultado na matriz Ommega*/

                        tempvar z`j'
                        if ("`x'" == "cons") {
                            gen double `z`j'' = `pred1_`by1''*(1-`pred1_`by1'')*1   if `by' == `by1'
                        }
                        else {
                            gen double `z`j'' = `pred1_`by1''*(1-`pred1_`by1'')*`x' if `by' == `by1'
                        }

                        sum `z`j''              if `l' == 1 & `by' == `by1' [`weight'`exp']
                        loc wp1pxl = r(sum)

                        sum `z`j''              if `l' == 0 & `by' == `by1' [`weight'`exp']
                        loc wp1pxu = r(sum)

                        loc g2 = (((1+`alpha')/`n') * `wp1pxl') + ((`alpha'/`n') * `wp1pxu')

                        mat `gamma2' = nullmat(`gamma2'), `g2'

                        loc j = `j'+1

                    }

                    mat `var_o`by1'' = `gamma2' * `ommega' * `gamma2''

                    loc var_o`by1' = `var_o`by1''[1,1]
                    loc se_o`by1' = 100*((`var_o`by1'')^.5)
			  }

                    *** Guardando resultados ***

                    loc v = 1
                    foreach num in `p`by1'_'  `D`by1''  `OI`by1''  `pseudo`by1''  `nlogit`by1''  `obs`by1''  `wpop`by1''  `vulnpop`by1''  `vuln`by1''  `depobs1`by1''  `depobs2`by1''  `loss`by1'' {

                        loc lab = word("p d hoi pseudo nlogit obs wpop vulnpop vuln deobs1 deobs2 loss", `v')

                        replace `byvar'     = `by1'         in `vk'
                        replace `type'      = 1             in `vk'
                        replace `mixvar'    = `mixval'      in `vk'
                        replace `variable'  = `v'           in `vk'
                        replace `value'     = `num'         in `vk'
                        if (`v' <= 3) {
                            replace `decomp1var' = 1             in `vk'
                            replace `decomp2var' = 1             in `vk'
                            return scalar `lab'_`mixlab'`by1' = `num'
                        }
                        else {
                            replace `decomp1var' = .             in `vk'
                            replace `decomp2var' = .             in `vk'
                            return local `lab'_`mixlab'`by1' = `num'
                        }

                        loc vk = `vk'+1
                        loc v = `v'+1
                    }
			  if("`geometric'"==""){
                    loc v = 1
                    foreach num in `se_p`by1'' `se_d`by1'' `se_o`by1''  {

                        loc lab = word("se_p se_d se_oi", `v')

                        replace `byvar'     = `by1'         in `vk'
                        replace `type'      = 2             in `vk'
                        replace `mixvar'    = `mixval'      in `vk'
                        replace `variable'  = `v'           in `vk'
                        replace `value'     = `num'         in `vk'
                        replace `decomp1var'= .             in `vk'

                        return local `lab'_`mixlab'`by1' = `num'

                        loc vk = `vk'+1
                        loc v = `v'+1
                    }

                    foreach num in 1 2 3 {

                        loc m  = word("`p`by1'_'  `D`by1''  `OI`by1''", `num')
                        loc se = word("`se_p`by1'' `se_d`by1'' `se_o`by1''", `num')

                        replace `byvar'     = `by1'             in `vk'
                        replace `type'      = 3                 in `vk'
                        replace `mixvar'    = `mixval'          in `vk'
                        replace `variable'  = `num'             in `vk'
                        replace `value'     = `m' - (`se'*invnormal((100-(100-`level')/2)/100)) in `vk'
                        replace `decomp1var'= .                 in `vk'
                        loc vk = `vk'+1
                    }

                    foreach num in 1 2 3 {

                        loc m  = word("`p`by1'_'  `D`by1''  `OI`by1''", `num')
                        loc se = word("`se_p`by1'' `se_d`by1'' `se_o`by1''", `num')

                        replace `byvar'     = `by1'             in `vk'
                        replace `type'      = 4                 in `vk'
                        replace `mixvar'    = `mixval'          in `vk'
                        replace `variable'  = `num'             in `vk'
                        replace `value'     = `m' + (`se'*invnormal((100-(100-`level')/2)/100)) in `vk'
                        replace `decomp1var'= .                 in `vk'
                        loc vk = `vk'+1
                    }
			  }
                    if ("`keep'" != "") {
                        gen double pred_`by1' = `pred1_`by1''
                    }

                }
                if (`wcount1`by1'' != `wcount2`by1'')  & ("`nowarning'" == "") {
                    noi di in r "WARNING" in g " : " in y " `by' = `by1'" in y "`all'"in g " : " in y `wcount1`by1''-`wcount2`by1'' in g " initially selected circunstances were not used to estimate Pi."
                }

            }

            if ("`decomp1'" != "") {
                foreach by1 in `base' `c' {

                    loc change`by1' = `OI`by1'' - `OI`base''
                    loc scale`by1'  = 100*(((`p`by1'_'/100)*(1-(`D`base''/100)))-((`p`base'_'/100)*(1-(`D`base''/100))))/(`change`by1''/100)
                    loc distr`by1'  = 100*(((`p`by1'_'/100)*(1-(`D`by1''/100)))-((`p`by1'_'/100)*(1-(`D`base''/100))))/(`change`by1''/100)

                    return local change_`mixlab'`by1'   = `change`by1''
                    return local scale_`mixlab'`by1'    = `scale`by1''
                    return local distr_`mixlab'`by1'    = `distr`by1''

                    loc v = 13
                    foreach num in `change`by1'' `scale`by1'' `distr`by1''  {

                        replace `byvar'     = `by1'         in `vk'
                        replace `type'      = 1             in `vk'
                        replace `mixvar'    = `mixval'      in `vk'
                        replace `variable'  = `v'           in `vk'
                        replace `value'     = `num'         in `vk'

                        replace `decomp1var'= 2             in `vk'

                        loc v = `v'+1
                        loc vk = `vk'+1

                    }

                }
            }

            if ("`decomp2'" != "") {
                foreach by1 in `c' {
        			  tempvar _auxby _predprob_mix _reldev_mix _lpredprob_mix
        			  gen `_auxby' = `by'
        			  tostring `_auxby', replace

                      gen double `_predprob_mix' = `mix_pred1_`by1''
        			  sum `_predprob_mix' [`weight'`exp'] if `touse' & `_auxby'=="`by1'"
           			  local _pcove_mix= r(mean)
        			  gen `_reldev_mix'=abs(`_predprob_mix'-`_pcove_mix') if `touse' & `_auxby'=="`by1'"
				
				  if("`geometric'"!=""){
				  	gen double `_lpredprob_mix' = ln(`mix_pred1_`by1'')
				  	qui sum `_lpredprob_mix' [`weight'`exp'] if `touse' & `_auxby'=="`by1'"
				  	loc _lpcove_mix = r(mean)
				  	loc _hoi_mix = exp(`_lpcove_mix')
				  	loc _Dindex_mix = (1-`_hoi_mix'/(`_pcove_mix'))
				  }
				
				  if("`geometric'"==""){
	        			  sum `_reldev_mix' [`weight'`exp'] if `touse' & `_auxby'=="`by1'"
      	  			  local _penaltyhoi_mix = r(mean)
        				  local _penaltyhoi_mix = `_penaltyhoi_mix'/2
        		
        				  local _hoi_mix = `_pcove_mix' - `_penaltyhoi_mix'
         				  local _Dindex_mix = `_penaltyhoi_mix'/`_pcove_mix'
				  }
				
                      local change`by1' = (`OI`by1'' - `OI`base'')
         	  		  local _composition`by1'     = (100*(`_hoi_mix'))-`OI`base''
          			  local _scale`by1'		      = 100*(((`p`by1'_'/100)*(1-`_Dindex_mix'))-(`_hoi_mix'))
        	      	  local _equalization`by1'	  = 100*((`OI`by1''/100)-((`p`by1'_'/100)*(1-`_Dindex_mix')))
         	  		  local _shr_composition`by1' = 100*(`_composition`by1'' / `change`by1'')
          			  local _shr_scale`by1'		  = 100*(`_scale`by1'' / `change`by1'')
        	      	  local _shr_equalization`by1'= 100*(`_equalization`by1'' / `change`by1'')

                      return local change_`mixlab'`by1'   	   = `change`by1''
                      return local composition_`mixlab'`by1'   = `_composition`by1''
                      return local scale_`mixlab'`by1'    	   = `_scale`by1''
                      return local equalization_`mixlab'`by1'  = `_equalization`by1''

                      loc v = 16
                      foreach num in `change`by1'' `_composition`by1'' `_scale`by1'' `_equalization`by1'' {

                          replace `byvar'     = `by1'         in `vk'
                          replace `type'      = 1             in `vk'
                          replace `mixvar'    = `mixval'      in `vk'
                          replace `variable'  = `v'           in `vk'
                          replace `value'     = `num'         in `vk'

                          replace `decomp2var'= 2             in `vk'

                          loc v = `v'+1
                          loc vk = `vk'+1

                      }
                      foreach num in `_shr_composition`by1'' `_shr_scale`by1'' `_shr_equalization`by1'' {

                          replace `byvar'     = `by1'         in `vk'
                          replace `type'      = 1             in `vk'
                          replace `mixvar'    = `mixval'      in `vk'
                          replace `variable'  = `v'           in `vk'
                          replace `value'     = `num'         in `vk'

                          replace `decomp2var'= 3             in `vk'

                          loc v = `v'+1
                          loc vk = `vk'+1

                      }
                }
            }
	  }

        if ("`mix'" == "") {
            if ("`simple'" == "") & ("`nose'" == "") {
                noi tabdisp  `variable' `type' if `value' != . & `variable' <= 12, cell(`value') format(`format') by(`byvar')
            }
            if ("`simple'" != "") & ("`nose'" == "")  {
                noi tabdisp  `variable' `type' if `value' != . & `variable' <= 3, cell(`value') format(`format') by(`byvar')
            }
            if ("`simple'" == "") & ("`nose'" != "") {
                noi tabdisp  `variable' `byvar' if `value' != . & `variable' <= 12 & `type' == 1, cell(`value') format(`format')
            }
            if ("`simple'" != "") & ("`nose'" != "")  {
                noi tabdisp  `variable' `byvar' if `value' != . & `variable' <= 3 & `type' == 1, cell(`value') format(`format')
            }
        }
        if ("`mix'" != "") {
            if ("`simple'" == "") & ("`nose'" == "") {
                noi tabdisp  `variable' `mixvar' if `value' != . & `variable' <= 12, cell(`value') format(`format') by(`byvar')
            }
            if ("`simple'" != "") & ("`nose'" == "")  {
                noi tabdisp  `variable' `byvar' if `value' != . & `variable' <= 3, cell(`value') format(`format') by(`mixvar')
            }
        }
        if ("`decomp1'" != "") {
            noi tabdisp  `variable' `byvar' if `value' != . & (`decomp1var' != .) , cell(`value') format(`format') by(`decomp1var')  concise
        }
        if ("`decomp2'" != "")  {
            noi tabdisp  `variable' `byvar' if `value' != . & (`decomp2var' != .) , cell(`value') format(`format') by(`decomp2var')  concise
        }
        if("`geometric'"!=""){
		noisily display in green "Note: The estimation corresponds to the geometric version of the HOI"	
	  }
    }
}


end
