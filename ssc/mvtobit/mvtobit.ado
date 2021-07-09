*! version 1.3  July 2015 by Mikkel Barslund
*! Fixed another problem with no constant option (thanks to Patrick M Fleming)
*! version 1.2  August 2013 by Mikkel Barslund
*! Fixed problem with no constant option (thanks to Gaston Luis Repetto)
*! Fixed problem related to the generation of starting values and ther risk of non positive-definite covariance matrix (thanks to Melanie Kuhn-Le-Braz) 
*! version 1.1  October 2009 by Mikkel Barslund
*! Help file modified to alert users to -cmp-
*! Fixed: seed() option is now passed correctly to mdraws (Thanks to Christian Kuhlgatz)
*! Improved generation of starting values
*! Added: capability for mixing tobit and continuous models
*! version 1.0  August 2007 
*! Multivariate tobit by method of MSL.  

program define mvtobit, eclass byable(onecall) sortpreserve
    version 8.2
    if replay() {
        if "`e(cmd)'" != "mvtobit" {
            di as error "results for mvtobit not found"
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

program define Estimate, eclass byable(recall)

		
        /* Check version and if applicable alert to -cmp-  */

	if c(stata_version) >= 9 {
		di _n
	    di in green "Running Stata version 9 or higher. You should consider installing {stata findit cmp:cmp}." _n
	}

        /* First parse the equation stuff into constituent 
           components and thereby get the number of equations.
           Completely hacked from -mvprobit-.
        */

    loc i = 1
    loc paren "("

    while "`paren'" == "(" {    
        gettoken e`i' 0:0, parse(" ,[") match(paren)
        loc left "`0'"
        loc junk: subinstr loc e`i' ":" ":", count(loc number)
        if "`number'" == "1" {
            gettoken dep`i'n  e`i':  e`i', parse(":")
            gettoken junk  e`i':  e`i', parse(":")
        }
        loc  e`i' : subinstr loc  e`i' "=" " "
        gettoken dep`i' 0:  e`i', parse(" ,[") 
        unab dep`i': `dep`i'' 

            /* collecting together -- for e.g. marking sample */
        loc deps "`deps' `dep`i''"
        confirm variable `dep`i''
        if "`dep`i'n'" == "" {
            loc dep`i'n "`dep`i''"
        }
        syntax [varlist(default=none)] [, noCONstant]
        loc ind`i' `varlist'        
        loc ninds`i' : word count `ind`i''
        if "`constant'" == "" {
            loc ninds`i' = `ninds`i'' + 1
        }
        loc inds "`inds' `ind`i''"
        loc nc`i' `constant'
        loc  0 "`left'"
            /* reset `paren' to empty when thru eqns */
        gettoken check : left, parse(" ,[") match(paren)
        loc i = `i' + 1
    }

        
            /* Clear (permanent) variables for future use - only X_MVT_index is affected */
    cap drop  X_MVT_index
    
            /* Ensure globals used later are already clear */
            /* Using horrible prefix reduces chance of overwriting */
    foreach g in X_MVT_i X_MVT_D X_MVT_atrho X_MVT_slatrho X_MVT_std ///
                 X_MVT_eqs X_MVT_slstd X_MVT_prefix S_MVT_rho { 
            glo `g' 
    } 

            /* number of equations */
    glo X_MVT_NOEQ = `i' - 1

    if $X_MVT_NOEQ < 2 { 
        di as error "More than 1 equation required (Use -Tobit- or -regress- for single equation)." 
        exit 198
    }

            /* remaining options in command line */
    loc 0 "`left'"
    syntax [if] [in] [pw fw iw aw] [, DRaws(integer 5)  Robust Cluster(varname)      ///
           Level(integer $S_level) Beta0  Seed(integer 123456789)                    ///
           ATRho0(string) AN PREfix(string) BUrn(integer 0) RANdom HRANdom SHuffle   ///
           ADOONly PRIMes(string) INIT(string) noLOG MLOpts(string) * ]

            /* Set various options */
    loc draws "`draws'"
    glo X_MVT_D = `draws'

    glo X_MVT_prefix "X_MVT" 
    if "`prefix'" != ""  glo X_MVT_prefix "`prefix'"

    glo X_MVT_adoonly = "`adoonly'"

    
    if "`primes'" != "" loc primes "primes(`primes')"

    set seed `seed'

    loc option0 `options'
    marksample touse
    markout `touse' `deps' `inds'   

    loc wtype `weight'
    loc wtexp `"`exp'"'
    if "`weight'" != "" { 
        loc wgt `"[`weight'`exp']"'  
    }
    if "`weight'" == "pweight" | "`cluster'" != "" {
            loc robust "robust"
    }

    if "`cluster'" ! = "" { 
        loc clopt "cluster(`cluster')" 
    }
    mlopts stdopts, `option0'

    if "`level'" != "" {
        loc level "level(`level')"
    }
        

    if "`log'" == "" {
                loc log "noisily"
        }
        else   {
         loc log "quietly"
    }

    loc log2 = cond("`beta0'" == "", "quietly", "noisily")


            /*  Checking of depvars etc. */
    quietly {
        count if `touse' 
        if r(N) == 0 { 
            di as error "no valid observations"
            error 2000
        }
        loc N = r(N)
    }

    tempname C
    glo X_MVT_C "`C'"  /* used for matrix name in evaluation program */

        /*  Get starting values from marginal univariate tobits or ols 
            check collinearities among RHS vbles 
            create macros containing bits of syntax for parsing to -ml- evaluator
            Fitting univariate Tobits even when starting values are specified to get
            comparison likelihood value                                                 */
        
    tempname b0 std0   

    di _n
    di in green "Fitting univariate models (Tobit or continuous) to get starting values" _n
    forval i = 1/$X_MVT_NOEQ {

        tempvar y0 e0`i' xb0 
        _rmcoll `ind`i'' `wgt' if `touse', `nc`i''
        loc ind`i' "`r(varlist)'"
        qui gen double `y0' = `dep`i''
        qui replace `y0' = . if `dep`i''==0

		`log2' intreg `y0' `dep`i''  `ind`i'' `wgt' if `touse', `nc`i''

        tempname beta`i' std`i'	
        mat `beta`i'' = e(b)
        mat coleq `beta`i'' = `dep`i'n'
        loc columns = colsof(`beta`i'')
        mat `std`i'' = `beta`i''[1,`=`columns'']
        mat colnames `std`i'' = lnsigma`i':_cons
        if `i' == 1 {
            mat `b0' = `beta`i''[1,1..`=`columns'-1']
            mat `std0' = `std`i''
            loc ll0 = e(ll)
        }
        if `i' > 1  {
            mat `b0' = `b0', `beta`i''[1,1..`=`columns'-1']
            mat `std0' = `std0', `std`i''
            loc ll0 = e(ll) + `ll0'   /* logL for comparison model */
        }

		predict double `xb0', xb
		qui gen double `e0`i'' = `dep`i'' - `xb0' if `dep`i''!=0

        glo X_MVT_eqs "$X_MVT_eqs (`dep`i'n': `dep`i'' = `ind`i'', `nc`i'') "
        glo X_MVT_i "$X_MVT_i xb`i' "

        glo X_MVT_std "$X_MVT_std lnsigma`i' "
        glo X_MVT_slstd "$X_MVT_slstd /lnsigma`i' "
        
        forval j = `=`i'+1'/$X_MVT_NOEQ {
            glo X_MVT_atrho "$X_MVT_atrho atrho`i'`j'"
            glo X_MVT_slatrho "$X_MVT_slatrho /atrho`i'`j'"
            glo S_MVT_rho "$S_MVT_rho rho`i'`j' ="
        }
        drop `y0' `xb0'
    }

    loc s = colsof(`b0')
    mat `b0' = `b0', `std0'

    if "`atrho0'" != "" {
        mat `b0' = `b0'[1,1..`s'], `atrho0'
    }

	/* else construct empirical starting value covariance matrix */

	else {
		forvalues i = 1/$X_MVT_NOEQ {
			 forvalues j = `=`i'+1'/$X_MVT_NOEQ {
				cap corr `e0`i'' `e0`j''
				tempname atrho0`i'`j' atrho0	
				if _rc==0 {
					mat `atrho0`i'`j'' = atanh(r(rho))
	        	 	mat colnames `atrho0`i'`j'' = atrho`i'`j':_cons
				}
				else {
	 				mat `atrho0`i'`j'' = 0
	        	 	mat colnames `atrho0`i'`j'' = atrho`i'`j':_cons
				}
	    	 }	
		}
		forvalues i = 1/$X_MVT_NOEQ {
			 forvalues j = `=`i'+1'/$X_MVT_NOEQ {
				if `i'==1 & `j'==2 {
					mat `atrho0' = `atrho0`i'`j''
				}
				else {
					mat `atrho0' = `atrho0', `atrho0`i'`j''
				}	
			 }
		}	 

		/* check if empirical covariance matrix is  positive definite */

		 tempname cmat comat o atrho00
		 local  p = 1
		 mat `cmat' = J($X_MVT_NOEQ,$X_MVT_NOEQ,0)
		 forvalues i = 1/$X_MVT_NOEQ {
			 	mat `cmat'[`i',`i'] = exp(`std0'[1,`i'])^2
		 }
			forvalues i = 1/$X_MVT_NOEQ {
				 forvalues j = `=`i'+1'/$X_MVT_NOEQ {
				 	mat `cmat'[`i',`j'] = tanh(`atrho0'[1,`p']) * sqrt(`cmat'[`i',`i']) * sqrt(`cmat'[`j',`j'])
					mat `cmat'[`j',`i']	= `cmat'[`i',`j']
					local ++p
				 }
			}

		scalar `o' = 0
		loc count = 0	   
		loc broken = 0
		cap mat `atrho00' = cholesky(`cmat')
			while _rc!=0 {
				sca `o'	= `o' + 0.01
				mat `comat' = `cmat' + `o' * I($X_MVT_NOEQ)
				loc ++count
				if `count' > 100 {
					loc broken = 1
					continue, break
				}	
				cap mat `atrho00' = cholesky(`comat')		
				/* set cmat equal to comat */
				mat `cmat' = `comat' 
			}

			
		if `broken' == 1 {
			mat `atrho0' = `atrho0' * 0 
			mat `b0' = `b0'[1,1..`=`s'+$X_MVT_NOEQ'], `atrho0'
		}

		if `broken' == 0 {
			loc count = 1
			forvalues i = 1/$X_MVT_NOEQ {
				mat `b0'[1,`=`s'+`i''] = ln(sqrt(`cmat'[`i',`i']))
			}
			forvalues i = 1/$X_MVT_NOEQ {
				 forvalues j = `=`i'+1'/$X_MVT_NOEQ {
						mat `atrho0'[1,`count'] = atanh(`cmat'[`i',`j']/sqrt(`cmat'[`i',`i'])/sqrt(`cmat'[`j',`j'])) 
						loc ++count
				}	
			}
			mat `b0' = `b0'[1,1..`=`s'+$X_MVT_NOEQ'], `atrho0'
		}				

	}


	
			/* Init overwrites atrho0 */
    if "`init'" != "" {
        loc init "init(`init')"
    }
    else {
        loc init "init(`b0')"
    }

            /* New stuff */
    qui {
    

            /* Find max censored equations */
        loc consstr = ""
        forval i=1/$X_MVT_NOEQ {
            tempvar i`i'
            gen `i`i'' = (`dep`i''!=0) if `touse'
            loc consstr = "`consstr' " + "`i`i'' "
        }
        tempvar cons noncons
        egen `cons' = rsum(`consstr') if `touse'
    
        gen `noncons' = $X_MVT_NOEQ-`cons' if `touse'
        sum `cons'  if `touse'
        glo X_MVT_maxcen = $X_MVT_NOEQ - r(min)
    
            /*  General principle:
                A permanent variable (X_MVT_index) holds a unique number for each censoring scheme.
                For each censoring scheme - i.e. each unique value of X_MVT_index there are 3 global string
                variables: ordstr,  unordstr  and resstr.
                    * ordstr(X_MVT_index) - contains ordered (numbers for ) non-censored equations for indeks value = indeks
                    * resstr(X_MVT_index) - contains ordered residuals for non-censored equations   - :: -
                    * unordstr(X_MVT_index) - contains ordered (numbers for) censored equations   - :: -                            */  
    
                /* Make strings with censoring pattern */
        tempvar indexstr 
        gen `indexstr'=""  if `touse'
        forval j=1/$X_MVT_NOEQ {
            replace `indexstr' = `indexstr' + " 1" if `dep`j''==0 & `touse'
            replace `indexstr' = `indexstr' + " 0" if `dep`j''>0  & `touse'
        }
        replace `indexstr' = trim(`indexstr') if `touse'
    
                /* Assign unique value to each censoring pattern */
        egen X_MVT_index = group(`indexstr') if `touse'
        sum X_MVT_index if `touse'
        loc i_min = r(min)
        loc i_max = r(max)
    
                /* Create: ordstr,  unordstr  and resstr */
        forval indeks = `i_min'/`i_max' {
            tempvar tempstr tempstr2
            glo ordstr`indeks' = ""
            glo unordstr`indeks' = ""
            glo resstr`indeks' = ""
    
            gen `tempstr2' = `indexstr' if X_MVT_index == `indeks' &  `touse'
            egen `tempstr' = mode(`tempstr2')
            loc seq = `tempstr'
            drop `tempstr' `tempstr2'
    
            forval j=1/$X_MVT_NOEQ {
                if word("`seq'",`j') == "1" {
                    glo unordstr`indeks' = "${unordstr`indeks'} " + "`j'"
                }
                else {
                     glo ordstr`indeks' = "${ordstr`indeks'} " + "`j'"
                     glo resstr`indeks' = "${resstr`indeks'} " + "e`j'"
                }
            }
        }
    }

            /* Create meta indices - indices constaining information on which
                index belongs to which censoring scheme  */

    forval y=0/$X_MVT_NOEQ {
        glo indeks`y' = ""
        forval indeks = `i_min'/`i_max' {
            qui count if X_MVT_index == `indeks' & `cons' == $X_MVT_NOEQ-`y' & `touse'
            if r(N)~=0 {
                glo indeks`y' = "${indeks`y'} " + "`indeks'"
            }
        }
    }

            /* Random drawing using -mdraws- */

			
    if $X_MVT_maxcen<=2 {
        di in green "Maximum # of censored equations is $X_MVT_maxcen <= 2. Simulations are not needed." _n
        di in green "Continues with conventional ML" _n
    }
    else {
        di in green "Maximum # of censored equations is $X_MVT_maxcen" _n
        di in green "Draws (Halton/pseudo random) are being made:" _n
    
        mdraws if `touse', draws($X_MVT_D) neq($X_MVT_maxcen) prefix($X_MVT_prefix) `an' burn(`burn') ///
            `random' `primes' `hrandom' `shuffle' replace seed(`seed')

        * Double number of draws if antithetic is on
        if "`an'" != ""  glo X_MVT_D = 2*$X_MVT_D
    }

    if $X_MVT_maxcen<=2 {
        loc title "Multivariate Tobit/mixed model"
    }
    else {
        loc title "Multivariate Tobit/mixed model (MSL,# draws = $X_MVT_D)"
    }



            /* Estimate model */

    if $X_MVT_maxcen==2 & $X_MVT_NOEQ==2 {
            
        `log' ml model lf mvtobit_2ll $X_MVT_eqs $X_MVT_slstd $X_MVT_slatrho `wgt' if `touse', maximize ///
                collinear wald(-$X_MVT_NOEQ) `init' title(`title') `robust'                             ///
                search(off) `clopt' `level' `mlopts' `stdopts'
    }
    else {
    
        `log' ml model lf mvtobit_ll $X_MVT_eqs $X_MVT_slstd $X_MVT_slatrho `wgt' if `touse', maximize  ///
               collinear wald(-$X_MVT_NOEQ) `init' title(`title') `robust'                              ///
               search(off) `clopt' `level' `mlopts' `stdopts'
    }
            
            /* drop variables used for random draws */
    cap drop ${X_MVT_prefix}*

            /* Prepare output - again mostly taken from -mvprobit */
    eret scalar neqs = $X_MVT_NOEQ
    eret scalar draws = $X_MVT_D
    eret scalar seed = `seed'
    eret scalar ll0 = `ll0'
    eret scalar chi2_c = abs(-2*(e(ll0)-e(ll)))
    eret scalar nrho = (e(neqs)-1)*e(neqs)/2
    eret loc an no
    if "`an'" != "" {
        eret loc an yes
    }

    eret loc cmd "mvtobit"

    forval i = 1/$X_MVT_NOEQ {
        eret loc rhs`i' "`ind`i''"
        eret loc nrhs`i' "`ninds`i''"
        loc t = [lnsigma`i']_b[_cons]
        loc tse = [lnsigma`i']_se[_cons]
        eret scalar sigma`i' =  exp(`t')
        eret scalar sesigma`i' = `tse'*exp(`t')

        forval j = `=`i'+1'/$X_MVT_NOEQ { 
            loc t = [atrho`i'`j']_b[_cons]
            loc tse = [atrho`i'`j']_se[_cons]
            eret scalar rho`i'`j' =     (exp(2*`t')-1) / (exp(2*`t')+1) 
            eret scalar serho`i'`j' = `tse'*4*(exp(2*`t')) / (exp(2*`t')+1)^2
        }
    }

    Display, `level' 

    /* Taken entirely from mvprobit:
        don't report LR test of "every rho = 0" for models 
       with constraints imposed: (i) constraints on coeffs can't be 
       imposed on the initial -probit- models. (ii) test has no sense 
       if constraints are placed on rhos 
       ==> report test only if no constraints (in which case "Cns" exists)
    */

    tempname c
    capture mat `c' = get(Cns)
    if (_rc != 0 & $X_MVT_NOEQ > 1 ) {
                    /* LR test of models without & without rhos */
        di as txt "Likelihood ratio test of $S_MVT_rho 0:  " 
        di as txt "             chi2(" as res "`e(nrho)'" as txt ") = " /*
            */ as res %8.0g e(chi2_c) _c
        di as txt "   Prob > chi2 = " as res %6.4f /*
            */ chiprob(`e(nrho)', e(chi2_c))
    }

                    /* clear up globals no longer needed */
    foreach g in X_MVT_i X_MVT_C S_MLE_I S_MLE_tvar S_MLE_rho S_MLE_atrho X_MVT_slatrho  { 
            glo `g' 
    } 
    capture macro drop S_MLE_z* 
end


program define Display
    syntax [,Level(int $S_level)]
    ml display, level(`level') neq($X_MVT_NOEQ) plus

    forval i = 1/$X_MVT_NOEQ {
            DispA lnsigma`i' /lnsigma`i' `level'            
    }
    
    forval i = 1/$X_MVT_NOEQ {
        forval j = `=`i'+1'/$X_MVT_NOEQ {
            DispA atrho`i'`j' /atrho`i'`j' `level'
        }
    }
        
    forval i = 1/$X_MVT_NOEQ {
            DispB lnsigma`i' sigma`i' `level'           
    }

    forval i = 1/$X_MVT_NOEQ {
        forval j = `=`i'+1'/$X_MVT_NOEQ {
            DispC atrho`i'`j' rho`i'`j' `level'
        }
    }

end


program define DispA
    loc level = `3'
    _diparm `1', level(`level') label("`2'") prob
    di in smcl as txt "{hline 13}{c BT}{hline 64}"
end

program define DispB
    loc level = `3'
    _diparm `1', level(`level') exp label("`2'") prob
    di in smcl as txt "{hline 13}{c +}{hline 64}"
end

program define DispC
    loc level = `3'
    _diparm `1', level(`level') tanh label("`2'") prob
    di in smcl as txt "{hline 13}{c +}{hline 64}"
end
