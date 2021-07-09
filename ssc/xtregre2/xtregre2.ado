*! version 1.0.0  24feb1997
*! Altered saved results 11/28/2005, SM

program define xtregre2, eclass
        version 9.1
        if replay() {
		if `"`e(cmd)'"'==`"xtregre2"' {
			if _by() { error 190 }
			xtregre2_`e(model)' `0'
			exit `e(rc)'
		}
		else if `"`e(cmd2)'"' == "xtregre2" {
			if _by() { error 190 }
			`e(cmd)' `0'
			exit `e(rc)'
		}
		error 301
		/*NOTREACHED*/
	}
	
	syntax varlist(ts) [if] [aw] [,	I(varname) theta]
	
	tsunab varlist : `varlist'
	tokenize `varlist'
	macro shift
	local xvars "`*'"
	xt_iis `i'
	local ivar "`s(ivar)'"
	capture tsset
	if _rc == 0 {
			local ivar `r(panelvar)'
			local tvar `r(timevar)'
	}
	
	
       local weight "aweight"
       
       if "`exp'" == "" {
       		local exp  "=1"
       		}
     
       *tempname T Tbar s_e s_u theta Bf VCEf n T_new rmse
       *tempvar touse dup T_i XB U tmp theta
       
       tempname T Tbar s_e s_u thetav Bf VCEf n T_new N_clust rmse
       tempvar touse dup T_i XB U tmp tv

       mark `touse' [`weight'`exp'] `if'
       markout `touse' `varlist' `ivar'
       qui count if `touse'
       if _result(1)<3 {
               error cond(_result(1)==0,2000,2001)
               /*NOTREACHED*/
       }
       
       noi _rmcoll `varlist'
       local varlist "`r(varlist)'"
	
	local oldvars `varlist'
	tsrevar `varlist'
	local varlist `r(varlist)'
	local tmpdep : word 1 of `varlist'


        if "`weight'"!="" {
                        tempvar w
                        qui gen double `w' `exp'
                        local origexp "`exp'"
                       local exp "=`w'"
                }
                else {
                        local w 1
                 
                }

	sort `ivar' `tvar' `touse'
	preserve
	quietly  {
		tempname sa_N sa_n sa_K
	
		/* obtain fixed-effects estimates */
		keep if `touse'
		keep `varlist' `ivar' `cluster' `w'
		ffxreg2 `varlist' [`weight'`exp'], i(`ivar') 
		scalar `sa_N'=e(N)
		scalar `s_e' = sqrt(e(sse)/e(df_t))
		matrix `Bf' = get(_b)
		matrix `VCEf' = get(VCE)
		restore, preserve
		keep if `touse'
		
                if "`weight'"!="" {
                                tempvar w
                                gen double `w' `origexp'
                                local exp "=`w'"
                                keep `varlist' `ivar' `w' `touse' `cluster'
                        }
                        else {
                                keep `varlist' `ivar' `touse' `cluster'
                                local w 1
                        }



                                                /* count T_i            */
                        by `ivar': gen long `T_i'=_N if _n==_N
                        summ `T_i'
                        scalar `T' = r(max)
                        
                        local g1 = r(min)
			local g2 = r(mean)
			local g3 = r(max)

		if "`old'"!="" {
			scalar `Tbar' = r(mean)
		}
                
                if `T'==r(min) {            /* min=max, constant */
                	local T_cons 1
                	local consopt "hascons"
                        drop `T_i'
                }
                        
                else {
                        local T_cons 0
                        local consopt "nocons"
                        by `ivar': replace `T_i'=_N
                }

		if "`old'"=="" {
			by `ivar' : gen double `T_new' = 1/_N if _n==_N
			summ `T_new'
			scalar `Tbar' =  1/r(mean)
			drop `T_new'
		}

                                               /* create averages      */
                by `ivar': gen byte `dup' = cond(_n==_N,2,1)
                expand `dup'
                sort `ivar' `dup'
                by `ivar': replace `dup'=cond(_n<_N,0,1)
                                                /* dup=0,1; 1->mean obs */


		tokenize `varlist'
		local i 1
		while "``i''"!="" {
			if "`weight'"!="" {
				by `ivar': gen double `tv' = cond(`dup',sum(`w'[_n-1]*``i''[_n-1]) /sum(`w'[_n-1]),``i'')
                        }
                                
                        else {
                        	by `ivar': gen double  `tv' = cond(`dup',sum(``i''[_n-1])/(_n-1),``i'')
                        }
   			
   			drop ``i''
			rename `tv' ``i''
   			local i=`i'+1
                        }

                                        /* obtain between-effects estimates */
                        regress `varlist' if `dup'
                        scalar `n' = e(N)
                        scalar `s_u' = sqrt((e(rmse)^2) -`s_e'^2/`Tbar')
                        
                                        /* obtain theta                   */
                        if `s_u'==. {
                                scalar `s_u' = 0
                                if `T_cons' {
                                        scalar `thetav' = 0
                                }
                                else    gen byte `thetav' = 0
                        }
                        else {
                                if `T_cons' {
                                        scalar `thetav' = 1-`s_e'/sqrt(`T'*`s_u'^2+`s_e'^2)
                                }
                                else {
                                        by `ivar': gen double `thetav' = 1-`s_e'/sqrt(`T_i'*`s_u'^2+`s_e'^2) if !`dup'
                                }
                        }

                                /* obtain random-effects estimates      */
                        local i 1
                        while "``i''"!="" {
                                by `ivar': replace ``i''=  ``i''-`thetav'*``i''[_N] if !`dup'
                                local i=`i'+1
                        }
                        drop if `dup'
                        tempvar cons
                        gen double `cons' = 1-`thetav'
                        
			if "`cluster'" != "" {
				if "`nonest'" == "" {
					if _caller() < 9.1 {
						_xtreg_chk_cl `cluster' `ivar'
					}
					else {
						_xtreg_chk_cl2 `cluster' `ivar'
					}
				}	
				local clopt "cluster(`cluster')"
			}                        
                        
                        regress `varlist' `cons' [`weight'`exp'], `consopt' `robust' `clopt'
			scalar `rmse' = e(rmse)
			scalar `N_clust' = e(N_clust)                        
                }
                
                
                
                tempname mdf chi2 B V

		local   depv  = "`1'"
		local   nobs  = e(N)
		scalar `mdf'  = e(df_m) - cond(`T_cons',0,1)
		scalar `chi2' = e(F) * `mdf'

                mat `B' = get(_b)
                mat `V' = get(VCE)
                if `T_cons'==1 {
                        local cols = colsof(`B') - 1
                        mat `B' = `B'[1,1..`cols']
                        mat `V' = `V'[1..`cols',1..`cols']
                }
                else    local cols = colsof(`B')
		loc depname : word 1 of `oldvars'
		loc rhsname : subinstr local oldvars "`depname'" ""
		mat colnames `B' = `rhsname' _cons
		mat rownames `V' = `rhsname' _cons
		mat colnames `V' = `rhsname' _cons
		ereturn post `B' `V', depname(`depname') obs(`nobs')

		if `T_cons'==0 & 0`:word count `varlist'' > 1 {
			tokenize `oldvars'
			mac shift
			qui test `*'
			scalar `chi2' = r(chi2)
		}

		ereturn  mat bf `Bf'
		ereturn mat VCEf `VCEf'

		local `cols'
		global S_E_vl `*'  /* double save */
		local names

		ereturn local depvar `depname'

		global S_E_depv "`depname'"   /* double save */
		global S_E_if `"`if'"'

		ereturn scalar sigma_u = `s_u'
		ereturn scalar sigma_e = `s_e'
		ereturn scalar sigma   = sqrt(`s_u'^2+`s_e'^2)
		ereturn scalar rho     = `s_u'^2/(`s_u'^2+`s_e'^2)
		ereturn scalar rmse    = `rmse'
		ereturn local ivar `ivar'

		scalar S_E_ui = `s_u'        /* double save */
		scalar S_E_eit = `s_e'
		global S_E_ivar "`ivar'"

		ereturn scalar N = `nobs'
		*ereturn scalar T = `T'
		ereturn scalar Tbar = `Tbar'
		ereturn scalar Tcon = `T_cons'
		ereturn scalar N_g = `n'
		ereturn scalar df_m = `mdf'
		ereturn scalar chi2 = `chi2'
		ereturn local chi2type "Wald"
		ereturn local sa "`sa'`saf'"

		ereturn scalar g_min = `g1'
		ereturn scalar g_avg = `g2'
		ereturn scalar g_max = `g3'

		scalar S_E_nobs = `nobs'     /* double save */
		scalar S_E_T = `T'
		scalar S_E_Tbar = `Tbar'
		global S_E_Tcon   `T_cons'
		scalar S_E_n = `n'
		scalar S_E_mdf = `mdf'
		scalar S_E_chi2 = `chi2'


		if e(Tcon) { 
			ereturn scalar theta = `thetav'
			scalar S_E_thta = `thetav'   /* double save */
		}
		else quietly {
			by `ivar': replace `thetav'=. if _n!=_N
			summ `thetav', d
			ereturn scalar thta_min = r(min)
			ereturn scalar thta_5   = r(p5)
			ereturn scalar thta_50  = r(p50)
			ereturn scalar thta_95  = r(p95)
			ereturn scalar thta_max = r(max)
			tempname myth
			mat `myth' = (r(min), r(p5), r(p50), r(p95), r(max))
			ereturn mat theta `myth'
		}
		restore
		quietly {
			if "`weight'"!="" {
                	        tempvar w
                	        gen double `w' `origexp'
                	        local exp "=`w'"
                        }
                        else {
                                local w 1
                        }
                        
                        tempvar mysamp sumxb sumtdep last
			gen byte `mysamp' = `touse'
			ereturn repost, esample(`mysamp')
			local ncnsmod = 1

                                        /* obtain R^2 overall   */
                        predict double `XB' if `touse'
                        
                        if (r(sd)<1e-8) {
				ereturn scalar r2_o = 0
				local ncnsmod = 0
			}
				else {
				corr `XB' `tmpdep' [`weight'`exp']
				ereturn scalar r2_o = r(rho)^2
			}
			sort `ivar' `touse'
			
			
					/* obtain R^2 between */

			by `ivar' `touse': gen `last' = cond(_n==_N & `touse',1,0) 

			by `ivar' `touse': gen double `sumxb' = sum(`w'*`XB')/sum(`w')
			sum `sumxb' if `last'

			if (r(sd)<1e-8) {
				local ncnsmod = 0
			}	


			by `ivar' `touse': gen double `sumtdep' = sum(`w'*`tmpdep')/sum(`w') 

			sum `sumtdep' if `last'
			if (r(sd)<1e-8) {
				local ncnsmod = 0
			}	

			by `ivar' `touse': gen double `U' =  cond(_n==_N & `touse', `sumxb', . )

			by `ivar' `touse': gen double `tmp' =  cond(_n==_N & `touse', `sumtdep', .)

			if (`ncnsmod') {
				corr `U' `tmp'
				ereturn scalar r2_b = r(rho)^2
			}
			else {
				ereturn scalar r2_b = 0
			}
			
		
                                /* obtain R^2 within */
			by `ivar' `touse': replace `U' = `XB'-`U'[_N]
			by `ivar' `touse': replace `tmp'=`tmpdep'-`tmp'[_N]
			if (`ncnsmod') {
				corr `U' `tmp' [`weight'`exp']
				ereturn scalar r2_w = r(rho)^2
			}
			else {
				ereturn scalar r2_w = 0
			}
			scalar S_E_r2w = e(r2_w)    /* double save */

			drop `U' `tmp'
			
                }
		if "`robust'" != "" | "`cluster'" != "" {
			ereturn local vcetype "Robust"
			ereturn local vce robust
		}
		if "`cluster'" != "" {
			ereturn local clustvar "`cluster'"
			ereturn scalar N_clust = `N_clust'
		}

		ereturn local ivar "`ivar'"
		ereturn local model re
		ereturn local predict "xtrere_p"
		ereturn local cmd "xtregre2"
		global S_E_cmd2 "xtregre2"    /* double save */
		global S_E_cmd "xtregre2"
	*}

	if e(Tcon) {
		local Twrd "    T"
	}
	else	local Twrd "T-bar"

	#delimit ;
	di _n in gr "Random-effects GLS regression" 
		_col(49) in gr "Number of obs" _col(68) "=" 
		_col(70) in ye %9.0f e(N) ;
	di in gr "Group variable (i): " in ye abbrev("`e(ivar)'",12) in gr
		_col(49) "Number of groups" _col(68) "="
		_col(70) in ye %9.0g e(N_g) _n ;
	di in gr "R-sq:  within  = " in ye %6.4f e(r2_w)
		_col(49) in gr "Obs per group: min" _col(68) "="
		_col(70) in ye %9.0g e(g_min) ;
	di in gr "       between = " in ye %6.4f e(r2_b)
		_col(64) in gr "avg" _col(68) "="
		_col(70) in ye %9.1f e(g_avg) ;
	di in gr "       overall = " in ye %6.4f e(r2_o)
		_col(64) in gr "max" _col(68) "="
		_col(70) in ye %9.0g e(g_max) _n ;

	if !missing(e(chi2)) | missing(e(df_r)) { ;
		di in gr "Random effects u_i ~ " in ye "Gaussian" in gr 
			_col(49) "`e(chi2type)' chi2(" 
				in ye e(df_m) in gr ")" _col(68) "="
			_col(70) in ye %9.2f e(chi2) ;
		di in gr "corr(u_i, X)" _col(20) "= " in ye "0"
			in gr " (assumed)" _col(49) "Prob > chi2" _col(68) "="
			_col(73) in ye %6.4f chiprob(e(df_m),e(chi2)) ;
	} ;
	else { ;
		di in gr "Random effects u_i ~ " in ye "Gaussian" in gr 
			_col(49) "F(" in ye e(df_m) in gr "," in ye e(df_r)
			in gr ")" _col(68) "=" _col(70) in ye %9.2f e(F) ;
		di in gr "corr(u_i, X)" _col(20) "= " in ye "0"
			in gr " (assumed)" _col(49) "Prob > F" _col(68) "="
			_col(73) in ye %6.4f fprob(e(df_m),e(df_r),e(F)) ;
	} ;
	#delimit cr

	if "`theta'" != "" {
		if e(Tcon) {
			di in gr "theta" _col(20) "= " in ye e(theta)
		}
		else {
			di in gr _n _dup(19) "-" " theta " _dup(20) "-"
			di in gr "  min      5%       median        95%" /*
				*/ "      max" 
			di in ye %6.4f e(thta_min) %9.4f e(thta_5) /*
				*/ %11.4f e(thta_50) %11.4f e(thta_95) /*
				*/ %9.4f e(thta_max) 

		}
	}
	display

	ereturn di, level(`level') plus
	di in smcl in gr "     sigma_u {c |} " in ye %10.0g e(sigma_u)
	di in smcl in gr "     sigma_e {c |} " in ye %10.0g e(sigma_e)
	di in smcl in gr "         rho {c |} " in ye %10.0g e(rho) /*
		*/ in gr "   (fraction of variance due to u_i)"
	di in smcl in gr "{hline 13}{c BT}{hline 64}"
end



/*
        ffxreg2:
                ffxreg2 varlist, i(ivar)
                defines mse, b and covariance matrix
                no syntax checking
                may corrupt data in memory.
*/
program define ffxreg2, eclass
	syntax varlist [aw] [, I(varname)]
	
	tokenize `varlist'
	local ivar `i'
	tempvar x tmp w
	tempname sst sse

        local weight "aweight"

        if "`weight'"!="" {
                gen double `w' `exp'
        }
        else {
                local w 1
        }

        quietly {
                sort `ivar'

                summ `1' [`weight'`exp']
                scalar `sst' = (r(N)-1)*r(Var)

                while ("`1'"!="") {
                        by `ivar': gen double `x' = sum(`w'*`1')/sum(`w')
                        summ `1' [`weight'`exp']
                        by `ivar': replace `x' = `1' - `x'[_N] + r(mean)
                        drop `1'
                        rename `x' `1'
                        mac shift
                }

                count if `ivar'!=`ivar'[_n-1]
                local dfa = r(N)-1


		est clear
		regress `varlist' [`weight'`exp']
		local nobs = e(N)
		local dfb = e(df_m)
		scalar `sse' = e(rss)
		local dfe = e(df_r) - `dfa'
		if `dfe'<=0 | `dfe'>=. {
			noi error 2001
			} 

		* we could avoid this if only we knew dfe in advance
		regress `varlist' [`weight'`exp'], dof(`dfe')
		ereturn scalar sse = `sse'
		ereturn scalar df_m = `dfa' + `dfb'
		ereturn scalar df_t = `nobs' - 1 - e(df_m)
		ereturn scalar N = e(N)
	}
end                

 
