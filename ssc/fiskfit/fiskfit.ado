*! version 1.0.0 MLB 29Dec2007
*! based on dagumfit by Stephen P. Jenkins
*! Fit Fisk or log-logistic distribution by ML to unit record data


/*------------------------------------------------ playback request */
 
program define fiskfit, eclass byable(onecall)
        version 8.2
        if replay() {
                if "`e(cmd)'" != "fiskfit" {
                        noi di as error "results for fiskfit not found"
                        exit 301
                }
                if _by() { 
                        error 190 
                } 
                Display `0'
                exit `rc'
        }
        if _by() {
                by `_byvars'`_byrc0': Estimate `0'
        }
        else    Estimate `0'
end

/*------------------------------------------------ estimation */

program define Estimate, eclass byable(recall)

        syntax varlist(max=1) [if] [in] [aw fw pw iw] [,  ///
                Avar(varlist numeric) Bvar(varlist numeric) ///
                AB(varlist numeric) CDF(namelist max=1) PDF(namelist max=1) POORfrac(real 0) ///
                Robust Cluster(varname) SVY STats  From(string)  ///
                Level(integer $S_level)    ///
                noLOG  * ]

        local title "ML fit of Fisk distribution"

        local inc "`varlist'"
        
        if "`ab'" != "" & "`avar'`bvar'"!="" {
                di as error "Cannot use ab(.) option in conjunction with avar(.), and bvar(.) options"
                exit 198
        }

        if "`ab'" != "" {
                local avar "`abp'"
                local bvar "`abp'"
        }

        local na : word count `avar'
        local nb : word count `bvar'

        if "`avar'`bvar'"!="" {
                if ("`stats'"!= "") {
                        noi di as error "stats option not available for model with covariates"
                        exit 198
                }       
                if ("`poorfrac'"!="") & `poorfrac' > 0   {
                        noi di as error "poorfrac option not available for model with covariates"
                        exit 198
                }
                if ("`pdf'"!="") {
                        noi di as error "pdf option not available for model with covariates"
                        exit 198
                }
                if ("`cdf'"!="") {
                        noi di as error "cdf option not available for model with covariates"
                        exit 198
                }
        }

        if "`cdf'" != "" {
                confirm new variable `cdf' 
        }
        if "`pdf'" != "" {
                confirm new variable `pdf' 
        }

        if  (`poorfrac' < 0)  {
                di as error "poorfrac value must be positive"
                exit 198
        }

        local option0 `options'

        local wtype `weight'
        local wtexp `"`exp'"'
        if "`weight'" != "" { 
                local wgt `"[`weight'`exp']"'  
        }

        if "`weight'" == "pweight" & "`svy'" == "" {
                di as error "To use pweights, -svyset- your data, and use -svy- option"
                exit
        }

        if "`weight'" == "pweight" | "`cluster'" != "" {
                local robust "robust"
        }

        if "`cluster'" ! = "" { 
                local clopt "cluster(`cluster')" 
        }

        if "`level'" != "" {
                local level "level(`level')"
        }

        local log = cond("`log'" == "", "noisily", "quietly") 
        
        marksample touse 
        markout `touse' `varlist' `avar' `bvar' `cluster'
        if "`svy'" != "" {
                svymarkout `touse'
                svyopts modopts diopts options, `option0'

                eret local diopts "`diopts'"
        }
        mlopts mlopts, `options'


        quietly {

          count if `inc' < 0 & `touse'
          local ct =  r(N) 
          if `ct' > 0 {
                noi di " "
                noi di as txt "Warning: {res:`inc'} has `ct' values < 0." _c
                noi di as text " Not used in calculations"
                }

          count if `inc' == 0 & `touse'
          local ct =  r(N) 
          if `ct' > 0 {
                noi di " "
                noi di as txt "Warning: {res:`inc'} has `ct' values = 0." _c
                noi di as text " Not used in calculations"
                }

          replace `touse' = 0 if `inc' <= 0

        }

        qui count if `touse' 
        if r(N) == 0 {
                error 2000 
        }

	global S_mlinc "`inc'"
        if "`from'" != ""  {
                local b0 "`from'"
        }
	else {
		Init `wgt' if `touse'	        
	        tempname b0
	        matrix `b0' = `r(a)', `r(b)'
	        matrix colnames `b0' = a:_cons b:_cons
	}        

        `log' ml model lf fiskfit_lf (a: `avar') (b: `bvar')       ///
                `wgt' if `touse' , maximize                                     ///
                collinear title(`title') `robust' `svy' init(`b0')      ///
                search(off) `clopt' `level' `mlopts' `stdopts' `modopts'


        eret local cmd "fiskfit"
        eret local depvar "`inc'"

        tempname b ba bb
        mat `b' = e(b)
        mat `ba' = `b'[1,"a:"] 
        mat `bb' = `b'[1,"b:"]

        eret matrix b_a = `ba'
        eret matrix b_b = `bb'
        eret scalar length_b_a = 1 + `na'
        eret scalar length_b_b = 1 + `nb'

        if "`avar'`bvar'"!="" {
                eret scalar nocov = 0
        }

        if "`avar'`bvar'"==""  {

                tempname e              

                mat `e' = e(b)
                local a = `e'[1,1]
                local b = `e'[1,2]

                eret scalar ba = `a'
                eret scalar bb = `b'
        
                eret scalar nocov = 1

                        /* Estimated Dagum c.d.f. */

                if "`cdf'" ~= "" {
                        qui ge `cdf' = (1 + (`b'/`inc')^`a')^(-1)  if `touse'
                        eret local cdfvar "`cdf'"
                }


                        /* Estimated Dagum p.d.f. */
        
                if "`pdf'" ~= "" {
                        qui ge `pdf' = (`a'*(`b')^`a')* `inc'^-(`a'+1)  ///
                                 * ( (1 + (`b'/`inc')^`a')^-(2) ) ///
                                 if `touse'
                        eret local pdfvar "`pdf'"
                }

                        /* selected quantiles predicted from Dagum model */
                        /* Lorenz curve ordinates at selected quantiles */

                if "`stats'" ~= "" {
                        eret scalar mean = `b'*exp(lngamma(1-1/`a'))                    ///
                                           *exp(lngamma(1+1/`a'))/exp(lngamma(1)) 
                        eret scalar mode = cond(`a'>1,`b'*(((`a'-1)/(`a'+1))^(1/`a')),0,.)
                        eret scalar var = `b'*`b'*exp(lngamma(1-2/`a'))                 ///
                                        *exp(lngamma(1+2/`a'))/exp(lngamma(1))      ///
                                        - (`e(mean)'*`e(mean)')
                        eret scalar sd = sqrt(`e(var)')
                        eret scalar i2 = .5*`e(var)'/(`e(mean)'*`e(mean)')
                        eret scalar gini = -1 + (exp(lngamma(1))*exp(lngamma(2*+1/`a'))  ///
                                            / (exp(lngamma(1+1/`a'))*exp(lngamma(2))))
                        local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
                        foreach x of local ptile {      
                                eret scalar p`x' = `b' * ( (`x'/100)^(-1) - 1 )^(-1/`a') 
                                eret scalar Lp`x' = ibeta(1+1/`a',1- 1/`a',(`x'/100))
                        }
                }

                        /* Fraction with income below given level */
        
                if "`poorfrac'" ~= "" & `poorfrac' > 0 {
                        eret scalar poorfrac = (1 + (`b'/`poorfrac')^`a')^(-1)
                        eret scalar pline = `poorfrac'
                }


        }


        if "`poorfrac'" ~= "" & `poorfrac' > 0 {
                local pfrac "poorfrac(`poorfrac')"
        }


        Display, `level' `pfrac'  `diopts'

end

*! MLB 1.0.0 23Dec2007
program Init, rclass sortpreserve
	syntax [if] [aw fw pw iw /] 
	marksample touse
	
	tempvar i mrank y x
	sort `touse' $S_mlinc
	
	if "`weight'" == "" {
		qui count if `touse'
		local nobs = r(N)
		qui by `touse' ($S_mlinc) : gen long `i' = _n if `touse'
		qui bys `touse' $S_mlinc (`i') : replace `i' = `i'[_N] if _N > 1 & `touse'
		qui gen double `mrank' = (`i' - .3)/(`nobs' + .4) if `touse'
	}
	else {
		sum `exp' if `touse', meanonly
		local nobs = r(sum)
		qui by `touse' ($S_mlinc) : gen double `i' = sum(`exp') if `touse'
		qui bys `touse' $S_mlinc (`i') : replace `i' = `i'[_N] if _N > 1 & `touse'
		qui gen double `mrank' = (`i' - .3)/(`nobs' + .4) if `touse'
	}
	qui gen double `y' = ln(1/(`mrank') - 1)
	qui gen double `x' = ln($S_mlinc)
	qui reg `y' `x' if `touse'
	return scalar a = -_b[`x']
	return scalar b = exp(_b[_cons]/(-_b[`x']))
end


program define Display
        syntax [,Level(int $S_level) POORfrac(real 0)  *]
        local diopts "`options'"
        ml display, level(`level') `diopts'
        if `level' < 10 | `level' > 99 {
                local level = 95
                }

        if `poorfrac' > 0 & (`e(nocov)' == 0) {
                di as error "poorfrac option not available (model was specified with covariates)"
                exit
        }

        if `poorfrac' > 0 & (`e(nocov)' == 1) {
                di " "
                di "Fraction with {res: `e(depvar)'} < `poorfrac' = " as res %9.5f (1 + (`e(bb)'/`poorfrac')^`e(ba)')^(-`e(bp)')       
                di " "
        }

        if "`e(mean)'" != "" {

                di as txt "{hline 60}"
                di as txt  _col(6) "Quantiles" _col(22) "Cumulative shares of" 
                di as txt  _col(22) "total `e(depvar)' (Lorenz ordinates)"
                di as txt "{hline 60}"
                di as txt  " 1%" _col(6) as res %9.5f `e(p1)' _col(20) %9.5f `e(Lp1)'
                di as txt  " 5%" _col(6) as res %9.5f `e(p5)' _col(20) %9.5f `e(Lp5)'
                di as txt  "10%" _col(6) as res %9.5f `e(p10)' _col(20) %9.5f `e(Lp10)'
                di as txt  "20%" _col(6) as res %9.5f `e(p20)' _col(20) %9.5f `e(Lp20)'
                di as txt  "25%" _col(6) as res %9.5f `e(p25)' _col(20) %9.5f `e(Lp25)'
                di as txt  "30%" _col(6) as res %9.5f `e(p30)' _col(20) %9.5f `e(Lp30)'
                di as txt  "40%" _col(6) as res %9.5f `e(p40)' _col(20) %9.5f `e(Lp40)' _c
                di as txt  _col(30) "Mode" _col(42) as res %9.5f `e(mode)'
                di as txt  "50%" _col(6) as res %9.5f `e(p50)' _col(20) %9.5f `e(Lp50)' _c
                di as txt  _col(30) "Mean" _col(42) as res %9.5f `e(mean)'
                di as txt  "60%" _col(6) as res %9.5f `e(p60)' _col(20) %9.5f `e(Lp60)' _c
                di as txt  _col(30) "Std. Dev." _col(42) as res %9.5f `e(sd)'
                di as txt  "70%" _col(6) as res %9.5f `e(p70)' _col(20) %9.5f `e(Lp70)'
                di as txt  "75%" _col(6) as res %9.5f `e(p75)' _col(20) %9.5f `e(Lp75)' _c
                di as txt  _col(30) "Variance" _col(42) as res %9.5f `e(var)'
                di as txt  "80%" _col(6) as res %9.5f `e(p80)' _col(20) %9.5f `e(Lp80)' _c
                di as txt  _col(30) "Half CV^2" _col(42) as res %9.5f `e(i2)'
                di as txt  "90%" _col(6) as res %9.5f `e(p90)' _col(20) %9.5f `e(Lp90)' _c
                di as txt  _col(30) "Gini coeff." _col(42) as res %9.5f `e(gini)'
                di as txt  "95%" _col(6) as res %9.5f `e(p95)' _col(20) %9.5f `e(Lp95)' _c
                di as txt  _col(30) "p90/p10" _col(42) as res %9.5f `e(p90)'/`e(p10)'
                di as txt  "99%" _col(6) as res %9.5f `e(p99)' _col(20) %9.5f `e(Lp99)' _c
                di as txt  _col(30) "p75/p25" _col(42) as res %9.5f `e(p75)'/`e(p25)'
                di as txt "{hline 60}"

        } 


end



