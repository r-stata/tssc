*! version 1.0.3     20071008     Piotr Lewandowski
*! Inspired by C. F. Baum's & F. Bornhorst's -ipshin-
*! Critical values matrices expanded to 9x9 dimension, thanks to Werner Hoelzl

program define pescadf, rclass
	version 8.2
	syntax varname(ts) [if] [in] , Lags(numlist int >=0) [ Trend noDemean trunoff ]  
/* number of lags can be estimated using model selection criteria such as Akaike or Schwartz
applied as usual to the underlying time series specification. 
PESARAN (2003),note 12    
*/
	qui tsset
	local id `r(panelvar)'
	local time `r(timevar)'
 	tempname Matkat _tst
 	tempvar y ybar nobs 

    local option 2
    local text "constant"
	local K1=-6.19
	local K2=2.61

    if  "`trend'" != "" { 
        	local option 3
        	local text "constant & trend"
		local K1=-6.42
		local K2=1.70
       	}
/* K1 and K2 are truncation values suggested by Pesaran (2003) to obtain finite first and second order moments of the CADF statistics. 
It allows to avoid size distortions, especially in the case of models with residual serial correlations and linear trends (Pesaran, 2003).
K1 and K2 are simulated respectively for 3 types of deterministics. 
 */	

  	marksample touse
	markout `touse' `time'
	tsreport if `touse', report panel

if r(N_gaps) {
		di in red "sample may not contain gaps"
		}

	qui xtsum `time' if `touse'


	local N `r(n)'
	local T `r(Tbar)'
	if int(`T')*`N' != r(N) {
/* panel is unbalanced */
		local unbalanced 1
		}
	else{
		local unbalanced 0
		}


	local tmin `r(min)'
	local tmax `r(max)'


	qui gen double `y' = `varlist' if `touse'
/* change the name of the variable tested   */

	if "`trend'" != "" {
		local trend "`time'"
		}

	if "`demean'" == "" {
		local dm "Cross-sectional average in first period extracted"
		qui sum `y' if `time'==`tmin' 
		scalar y0_av=r(mean)
		forv t = `tmin'/`tmax' {
			qui replace `y' = `y' - y0_av if `time' == `t' & `touse'
						}
		}
	else{
		local dm "Cross-sectional average in first period not extracted"
		}
/* In the case where T is fixed to ensure that the CADF statistics, ti (N, T) do not depend on the nuisance parameters 
the effect of the initial crosssection mean, y0bar, must also be eliminated. This can be achieved by applying the test to 
the deviations yit - y0_av. PESARAN (2003) 
*/
* display y0_av
* sum `y' if `touse'

if "`trunoff'" == "" {
		local tnc "extreme t-values truncated"
		local tnc_cv 0
		}
	else{
		local tnc "no truncation of extreme t-values"
		local tnc_cv 1
}


qui gen double `ybar'=0
forv t = `tmin'/`tmax' {
			qui {
					sum `y' if `time'==`t' & `touse'
					replace `ybar'=r(mean) if `time' == `t' & `touse'	
						}
				}

/* ybar will be used in the CADF regressions*/

	local listlag : word count `lags'

	local slags : list sort lags

	local maxlag : word `listlag' of `slags'

* di in r "listlag `listlag' maxlag `maxlag'"		
* di in r "slags `slags'"
	

di in gr _n  ///
"Pesaran's CADF test for " in ye "`varlist'"  /* 
    */  in gr _n "`dm' and `tnc'" /* 
    */ _n in gr "Deterministics chosen: " in ye "`text'"

    qui tab `id' if `touse', matrow(`Matkat') 

    local numkat = r(r)


    local i = 1
    while `i' <= `numkat' {
    	local kat = `Matkat'[`i',1]
    	local nkat "`nkat' `kat'"
    	local i = `i' + 1
    	}
	
	local Tpanel
	local p 
	scalar tbar = 0
	scalar nt = 0
	scalar Ztbar = 0
	scalar Zsigma = 0
	scalar lavg = 0
	local w=1
	foreach i of local nkat {
   	qui { 
if `listlag' == 1 {
			local nl`i' = `lags'
			local p "`p' `lags'"
			if `lags' > 0 {
				local tnl`i' "L(1/`lags')D.`y' L(1/`nl`i'')D.`ybar'"
				}
			scalar lavg = lavg + `nl`i''
		}

	else if `listlag' ~= `N' {
		di in r "Error: For `N' panel units, either 1 or `N' lag lengths must be specified"
		error 198
		}

	else {
			local nl`i' : word `w' of `lags'
			local p "`p' `lags'"
			if `nl`i'' > 0 {
				local tnl`i' "L(1/`nl`i'')D.`y' L(1/`nl`i'')D.`ybar'"			
				scalar lavg = lavg + `nl`i''
				}
			local w = `w' + 1
			}


* PESARAN (2003) eqn 3.6 OR 5.60 IN CASE OF AUTOCORRELATED ERRORS, I.E. LAGS INCLUDED

    		reg D.`y' L.`y' L.`ybar' D.`ybar' `tnl`i'' `trend' if `id' == `i' & `touse' 

    		mat b = e(b)
    		mat v = e(V)
    		scalar nt = nt + e(N)
    		scalar `_tst' = b[1,1]/sqrt(v[1,1])
*		local regressors: colnames e(b)
*		display in yellow "regressors: `regressors' number of regressors is " e(df_m) 

if "`trunoff'" == "" {
		scalar `_tst' = cond(`_tst'<`K2',max(`_tst',`K1'),`K2')
		}

 *   	noi	di in r "`i'  tstat "  `_tst'
    		scalar tbar = tbar + `_tst'
		
		qui sum `time' if `id' == `i' & `touse' 
		local nobs`i'=r(N)
		local Tpanel  "`Tpanel' `nobs`i''"


_PES_IND, option(`option') n(`N')  t(`nobs`i'') /* lags(`nl`i'')*/
		scalar Ztbar = Ztbar + (`_tst' - r(mu_ind))
		scalar Zsigma= Zsigma + r(sigma_ind)
scalar a1=r(mu_ind)
scalar a2=r(sigma_ind)

*noi di in gr "`i'  mu_ind "    a1
*noi di in gr "`i'  sigma_ind " a2

*noi	di in yel "`i'  Ztbar "  Ztbar

/* t-bar statistics can be standarized to obtain Z[t-bar] which has a normal distribution, and allows for unbalanced panels
see theorem 3.1 and remark 3.1 in Im, Pesaran, Shin (2003) */
   		}
	}

scalar Ztbar=Ztbar/sqrt(Zsigma)
/* standarized Ztbar is calculated*/
	scalar pval = norm(Ztbar)
/* rejection probability*/

	scalar tbar = tbar/`N'
	scalar lavg = lavg / `N'



/* FOR UNBALANCED PANEL ONLY ZTBAR IS DISPLAYED*/
if `unbalanced' {
di in gr "panel is unbalanced, only standarized Ztbar statistic can be calculated"
noi di in gr _n "Z[t-bar] test, (N,T1-T`N') = (`N',`Tpanel')" /*
    */ _n "Obs = " nt _col(15) "Augmented by " lavg " lags (average) " 
noi di in gr _n "    Z[t-bar]" _col(15) "P-value" 
noi di in ye %9.3f Ztbar _col(10) %9.3f pval 

}
else{
	_PES_TBAR, option(`option') tnc(`tnc_cv') n(`N')  t(`T') 
    noi di in gr _n "t-bar test, N,T = (`N',`T')" /*
    */ _col(35) "Obs = " nt _col(48) _n "Augmented by " lavg " lags (average) " 
    if (`maxlag' > 8) { 
    	noi di in r "IPS tables not applicable to lag > 8: W[t-bar] not reliable" 
    	}
    noi di in gr _n "    t-bar" _col(15) "cv10"  _col(25) "cv5"  _col(35) "cv1" /* 
    */ _col(41) "Z[t-bar]" _col(53) "P-value"
    noi di in ye %9.3f tbar _col(10) %9.3f r(cv10) _col(20) %9.3f r(cv5) _col(30) /*
	*/ %9.3f r(cv1) _col(39) %9.3f Ztbar _col(49) %9.3f pval 

}

	return local depvar `varlist'
	return scalar nobs=e(N)
	return scalar N=`N'
	return scalar T=`T'
	return scalar tbar=tbar
	return scalar cv10=r(cv10)
	return scalar cv5=r(cv5)
	return scalar cv1=r(cv1)
	return scalar Ztbar=Ztbar
	return scalar pval=pval
	return local lags `lags'
	return local Tpanel `Tpanel'
	return local determ `text'

	return scalar tnc_cv=`tnc_cv'
	
end		

 program define _PES_IND, rclass	
	version 7.0
 syntax , option(string) N(string) T(string)

/* PESARAN (2003) TABLE 2b-2c Summary Statistics of Individual Cross-Sectionally Augmented Dickey-Fuller
 _PES_IND PROVIDES SCALARS MU_IND I SIGMA_IND.*/

 tempname en te mu sd mu_ind sd_ind
    local capt `t'
    local capn `n'
	scalar `mu_ind' = 0
	scalar `sd_ind' = 0 
* N to kolumny, T to wiersze
	mat `en' = ( 10,15,20,30,50,70,100,200, 999)
	mat `te' = ( 10,15,20,30,50,70,100,200, 999)
if `option' == 2 {

mat `mu' = (-1.69	,	-1.69	,	-1.69	,	-1.69	,	-1.69	,	-1.69	,	-1.69	,	-1.69	,	-1.69	\ /*
	*/	-1.71	,	-1.73	,	-1.71	,	-1.72	,	-1.72	,	-1.72	,	-1.71	,	-1.71	,	-1.71	\ /*
	*/	-1.73	,	-1.75	,	-1.73	,	-1.74	,	-1.73	,	-1.73	,	-1.73	,	-1.74	,	-1.74	\ /*
	*/	-1.76	,	-1.77	,	-1.75	,	-1.75	,	-1.76	,	-1.75	,	-1.74	,	-1.76	,	-1.76	\ /*
	*/	-1.78	,	-1.77	,	-1.77	,	-1.77	,	-1.77	,	-1.77	,	-1.77	,	-1.78	,	-1.78	\ /*
	*/	-1.78	,	-1.78	,	-1.78	,	-1.78	,	-1.78	,	-1.78	,	-1.78	,	-1.78	,	-1.78	\ /*
	*/	-1.78	,	-1.78	,	-1.78	,	-1.79	,	-1.79	,	-1.78	,	-1.78	,	-1.78	,	-1.78	\ /*
	*/	-1.79	,	-1.79	,	-1.79	,	-1.79	,	-1.79	,	-1.79	,	-1.79	,	-1.79	,	-1.79	\ /*
	*/	-1.79	,	-1.79	,	-1.79	,	-1.79	,	-1.79	,	-1.79	,	-1.79	,	-1.79	,	-1.79	 )

mat `sd' = (1.35	,	1.34	,	1.34	,	1.34	,	1.33	,	1.33	,	1.35	,	1.34	,	1.34	\ /*
	*/	1.09	,	1.09	,	1.09	,	1.1	,	1.09	,	1.1	,	1.1	,	1.09	,	1.09	\ /*
	*/	1.03	,	1.02	,	1.02	,	1.02	,	1.02	,	1.02	,	1.03	,	1.02	,	1.02	\ /*
	*/	0.97	,	0.97	,	0.97	,	0.98	,	0.97	,	0.97	,	0.97	,	0.97	,	0.97	\ /*
	*/	0.94	,	0.94	,	0.94	,	0.94	,	0.94	,	0.94	,	0.94	,	0.94	,	0.94	\ /*
	*/	0.92	,	0.92	,	0.92	,	0.92	,	0.92	,	0.93	,	0.92	,	0.93	,	0.93	\ /*
	*/	0.91	,	0.91	,	0.91	,	0.92	,	0.92	,	0.92	,	0.91	,	0.92	,	0.92	\ /*
	*/	0.9	,	0.9	,	0.9	,	0.91	,	0.91	,	0.9	,	0.91	,	0.9	,	0.9	\ /*
	*/	0.9	,	0.9	,	0.9	,	0.91	,	0.91	,	0.9	,	0.91	,	0.9	,	0.9	)
}

if `option' == 3 {
mat `mu' = (-2.24	,	-2.24	,	-2.24	,	-2.24	,	-2.26	,	-2.23	,	-2.24	,	-2.25	,	-2.25 \ /*
	*/	-2.25	,	-2.26	,	-2.25	,	-2.26	,	-2.26	,	-2.26	,	-2.26	,	-2.25	,	-2.25 \ /*
	*/	-2.28	,	-2.28	,	-2.28	,	-2.29	,	-2.29	,	-2.28	,	-2.29	,	-2.29	,	-2.29	\ /*
	*/	-2.31	,	-2.32	,	-2.31	,	-2.31	,	-2.31	,	-2.31	,	-2.31	,	-2.32	,	-2.32 \ /*
	*/	-2.34	,	-2.34	,	-2.34	,	-2.34	,	-2.34	,	-2.33	,	-2.33	,	-2.34	,	-2.34 \ /*
	*/	-2.35	,	-2.34	,	-2.34	,	-2.34	,	-2.35	,	-2.35	,	-2.34	,	-2.35	,	-2.35 \ /*
	*/	-2.35	,	-2.35	,	-2.35	,	-2.35	,	-2.36	,	-2.36	,	-2.35	,	-2.35	,	-2.35	\ /*
	*/	-2.36	,	-2.36	,	-2.36	,	-2.36	,	-2.36	,	-2.36	,	-2.35	,	-2.36	,	-2.36	\ /*
	*/	-2.36	,	-2.36	,	-2.36	,	-2.36	,	-2.36	,	-2.36	,	-2.35	,	-2.36	,	-2.36	  )

mat `sd' =( 1.57	,	1.6	,	1.58	,	1.58	,	1.63	,	1.56	,	1.55	,	1.59	,	1.59 \ /*
	*/	1.11	,	1.11	,	1.11	,	1.12	,	1.11	,	1.11	,	1.13	,	1.11	,	1.11 \ /*
	*/	1.01	,	1	,	1.01	,	1.01	,	1.01	,	1.01	,	1.01	,	1.01	,	1.01 \ /*
	*/	0.93	,	0.93	,	0.93	,	0.93	,	0.93	,	0.93	,	0.93	,	0.93	,	0.93 \ /*
	*/	0.88	,	0.88	,	0.88	,	0.88	,	0.88	,	0.88	,	0.88	,	0.88	,	0.88 \ /*
	*/	0.86	,	0.86	,	0.86	,	0.86	,	0.86	,	0.86	,	0.86	,	0.86	,	0.86 \ /*
	*/	0.84	,	0.84	,	0.84	,	0.84	,	0.85	,	0.84	,	0.84	,	0.85	,	0.85 \ /*
	*/	0.83	,	0.83	,	0.83	,	0.83	,	0.83	,	0.83	,	0.84	,	0.83	,	0.83 \ /*
	*/	0.83	,	0.83	,	0.83	,	0.83	,	0.83	,	0.83	,	0.84	,	0.83	,	0.83)
}

forv p = 1/9 {
if `capn'<=`en'[1,`p'] {
    	forv q=1/9 {
    		if `capt' <= `te'[1,`q'] {
 					scalar `mu_ind' = `mu'[`q',`p' ]
    				 	scalar `sd_ind' = `sd'[`q',`p']
	    				continue,break
    					}
				}
    			continue,break
	}
}
 
return scalar mu_ind = `mu_ind'
return scalar sd_ind = `sd_ind'
return scalar sigma_ind = `sd_ind'^2

end


program define _PES_TBAR, rclass
	version 7.0
    syntax , Option(string) tnc(string) N(string) T(string) 
*           di in r "args `option' `n' `t' "  
    tempname en te crit1 crit5 crit10 
    local capt `t'
    local capn `n'
/* PESARAN (2003) Table 3b,3c, Critical Values of Average of Individual Cross-Sectionally Augmented Dickey-Fuller
PROGRAM _PES_IND PROVIDES SCALARS cv1, cv5, cv10
 */

	mat `en' = ( 10,15,20,30,50,70,100,200, 999)
	mat `te' = ( 10,15,20,30,50,70,100,200, 999)
* N to kolumny, T to wiersze
	if `option' == 2 {
if `tnc'==0{
/* TRUNCATED STATISTICS*/

mat `crit1' = (	-2.85	,	-2.66	,	-2.56	,	-2.44	,	-2.36	,	-2.32	,	-2.29	,	-2.25	,	-2.25	\ /*
		*/	-2.66	,	-2.52	,	-2.45	,	-2.34	,	-2.26	,	-2.23	,	-2.19	,	-2.16	,	-2.16	\ /*
		*/	-2.6	,	-2.47	,	-2.4	,	-2.32	,	-2.25	,	-2.2	,	-2.18	,	-2.14	,	-2.14	\ /*
		*/	-2.57	,	-2.45	,	-2.38	,	-2.3	,	-2.23	,	-2.19	,	-2.17	,	-2.14	,	-2.14	\ /*
		*/	-2.55	,	-2.44	,	-2.36	,	-2.3	,	-2.23	,	-2.2	,	-2.17	,	-2.14	,	-2.14	\ /*
		*/	-2.54	,	-2.43	,	-2.36	,	-2.3	,	-2.23	,	-2.2	,	-2.17	,	-2.14	,	-2.14	\ /*
		*/	-2.53	,	-2.42	,	-2.36	,	-2.3	,	-2.23	,	-2.2	,	-2.18	,	-2.15	,	-2.15	\ /*
		*/	-2.53	,	-2.43	,	-2.36	,	-2.3	,	-2.23	,	-2.21	,	-2.18	,	-2.15	,	-2.15	\ /*
		*/	-2.53	,	-2.43	,	-2.36	,	-2.3	,	-2.23	,	-2.21	,	-2.18	,	-2.15	,	-2.15	  )
mat `crit5' = (	-2.47	,	-2.35	,	-2.29	,	-2.22	,	-2.16	,	-2.13	,	-2.11	,	-2.08	,	-2.08	\ /*
		*/	-2.37	,	-2.28	,	-2.22	,	-2.17	,	-2.11	,	-2.09	,	-2.07	,	-2.04	,	-2.04	\ /*
		*/	-2.34	,	-2.26	,	-2.21	,	-2.15	,	-2.11	,	-2.08	,	-2.07	,	-2.04	,	-2.04	\ /*
		*/	-2.33	,	-2.25	,	-2.2	,	-2.15	,	-2.11	,	-2.08	,	-2.07	,	-2.05	,	-2.05	\ /*
		*/	-2.33	,	-2.25	,	-2.2	,	-2.16	,	-2.11	,	-2.1	,	-2.08	,	-2.06	,	-2.06	\ /*
		*/	-2.33	,	-2.25	,	-2.2	,	-2.15	,	-2.12	,	-2.1	,	-2.08	,	-2.06	,	-2.06	\ /*
		*/	-2.32	,	-2.25	,	-2.2	,	-2.16	,	-2.12	,	-2.1	,	-2.08	,	-2.07	,	-2.07	\ /*
		*/	-2.32	,	-2.25	,	-2.2	,	-2.16	,	-2.12	,	-2.1	,	-2.08	,	-2.07	,	-2.07	\ /*
		*/	-2.32	,	-2.25	,	-2.2	,	-2.16	,	-2.12	,	-2.1	,	-2.08	,	-2.07	,	-2.07	 )
mat `crit10' = (	-2.28	,	-2.2	,	-2.15	,	-2.1	,	-2.05	,	-2.03	,	-2.01	,	-1.99	,	-1.99	\ /*
		*/	-2.22	,	-2.16	,	-2.11	,	-2.07	,	-2.03	,	-2.01	,	-2	,	-1.98	,	-1.98	\ /*
		*/	-2.21	,	-2.14	,	-2.1	,	-2.07	,	-2.03	,	-2.01	,	-2	,	-1.99	,	-1.99	\ /*
		*/	-2.21	,	-2.14	,	-2.11	,	-2.07	,	-2.04	,	-2.02	,	-2.01	,	-2	,	-2	\ /*
		*/	-2.21	,	-2.14	,	-2.11	,	-2.08	,	-2.05	,	-2.03	,	-2.02	,	-2.01	,	-2.01	\ /*
		*/	-2.21	,	-2.15	,	-2.11	,	-2.08	,	-2.05	,	-2.03	,	-2.02	,	-2.01	,	-2.01	\ /*
		*/	-2.21	,	-2.15	,	-2.11	,	-2.08	,	-2.05	,	-2.03	,	-2.03	,	-2.02	,	-2.02	\ /*
		*/	-2.21	,	-2.15	,	-2.11	,	-2.08	,	-2.05	,	-2.04	,	-2.03	,	-2.02	,	-2.02	\ /*
		*/	-2.21	,	-2.15	,	-2.11	,	-2.08	,	-2.05	,	-2.04	,	-2.03	,	-2.02	,	-2.02	 )
}
if `tnc'==1{
/* NO TRUNCATION */
mat `crit1' = (	-2.97	,	-2.76	,	-2.64	,	-2.51	,	-2.41	,	-2.37	,	-2.33	,	-2.28	,	-2.28	\ /*
		*/	-2.66	,	-2.52	,	-2.45	,	-2.34	,	-2.26	,	-2.23	,	-2.19	,	-2.16	,	-2.16	\ /*
		*/	-2.6	,	-2.47	,	-2.4	,	-2.32	,	-2.25	,	-2.2	,	-2.18	,	-2.14	,	-2.14	\ /*
		*/	-2.57	,	-2.45	,	-2.38	,	-2.3	,	-2.23	,	-2.19	,	-2.17	,	-2.14	,	-2.14	\ /*
		*/	-2.55	,	-2.44	,	-2.36	,	-2.3	,	-2.23	,	-2.2	,	-2.17	,	-2.14	,	-2.14	\ /*
		*/	-2.54	,	-2.43	,	-2.36	,	-2.3	,	-2.23	,	-2.2	,	-2.17	,	-2.14	,	-2.14	\ /*
		*/	-2.53	,	-2.42	,	-2.36	,	-2.3	,	-2.23	,	-2.2	,	-2.18	,	-2.15	,	-2.15	\ /*
		*/	-2.53	,	-2.43	,	-2.36	,	-2.3	,	-2.23	,	-2.21	,	-2.18	,	-2.15	,	-2.15	\ /*
		*/	-2.53	,	-2.43	,	-2.36	,	-2.3	,	-2.23	,	-2.21	,	-2.18	,	-2.15	,	-2.15	  )
mat `crit5' = (	-2.52	,	-2.4	,	-2.33	,	-2.25	,	-2.19	,	-2.16	,	-2.14	,	-2.1	,	-2.1	\ /*
		*/	-2.37	,	-2.28	,	-2.22	,	-2.17	,	-2.11	,	-2.09	,	-2.07	,	-2.04	,	-2.04	\ /*
		*/	-2.34	,	-2.26	,	-2.21	,	-2.15	,	-2.11	,	-2.08	,	-2.07	,	-2.04	,	-2.04	\ /*
		*/	-2.33	,	-2.25	,	-2.2	,	-2.15	,	-2.11	,	-2.08	,	-2.07	,	-2.05	,	-2.05	\ /*
		*/	-2.33	,	-2.25	,	-2.2	,	-2.16	,	-2.11	,	-2.1	,	-2.08	,	-2.06	,	-2.06	\ /*
		*/	-2.33	,	-2.25	,	-2.2	,	-2.15	,	-2.12	,	-2.1	,	-2.08	,	-2.06	,	-2.06	\ /*
		*/	-2.32	,	-2.25	,	-2.2	,	-2.16	,	-2.12	,	-2.1	,	-2.08	,	-2.07	,	-2.07	\ /*
		*/	-2.32	,	-2.25	,	-2.2	,	-2.16	,	-2.12	,	-2.1	,	-2.08	,	-2.07	,	-2.07	\ /*
		*/	-2.32	,	-2.25	,	-2.2	,	-2.16	,	-2.12	,	-2.1	,	-2.08	,	-2.07	,	-2.07	 )
mat `crit10' = (	-2.31	,	-2.22	,	-2.18	,	-2.12	,	-2.07	,	-2.05	,	-2.03	,	-2.01	,	-2.01	\ /*
		*/	-2.22	,	-2.16	,	-2.11	,	-2.07	,	-2.03	,	-2.01	,	-2	,	-1.98	,	-1.98	\ /*
		*/	-2.21	,	-2.14	,	-2.1	,	-2.07	,	-2.03	,	-2.01	,	-2	,	-1.99	,	-1.99	\ /*
		*/	-2.21	,	-2.14	,	-2.11	,	-2.07	,	-2.04	,	-2.02	,	-2.01	,	-2	,	-2	\ /*
		*/	-2.21	,	-2.14	,	-2.11	,	-2.08	,	-2.05	,	-2.03	,	-2.02	,	-2.01	,	-2.01	\ /*
		*/	-2.21	,	-2.15	,	-2.11	,	-2.08	,	-2.05	,	-2.03	,	-2.02	,	-2.01	,	-2.01	\ /*
		*/	-2.21	,	-2.15	,	-2.11	,	-2.08	,	-2.05	,	-2.03	,	-2.03	,	-2.02	,	-2.02	\ /*
		*/	-2.21	,	-2.15	,	-2.11	,	-2.08	,	-2.05	,	-2.04	,	-2.03	,	-2.02	,	-2.02	\ /*
		*/	-2.21	,	-2.15	,	-2.11	,	-2.08	,	-2.05	,	-2.04	,	-2.03	,	-2.02	,	-2.02	 )
	}
}
    if `option' == 3 {
if `tnc'==0{
/* TRUNCATED STATISTICS*/

mat `crit1' = (	-3.51	,	-3.31	,	-3.2	,	-3.1	,	-3	,	-2.96	,	-2.93	,	-2.88	,	-2.88	\ /*		
		*/	-3.21	,	-3.07	,	-2.98	,	-2.88	,	-2.8	,	-2.76	,	-2.74	,	-2.7	,	-2.7	\ /*
		*/	-3.15	,	-3.01	,	-2.92	,	-2.83	,	-2.76	,	-2.72	,	-2.7	,	-2.65	,	-2.65	\ /*
		*/	-3.1	,	-2.96	,	-2.88	,	-2.81	,	-2.73	,	-2.69	,	-2.66	,	-2.63	,	-2.63	\ /*
		*/	-3.06	,	-2.93	,	-2.85	,	-2.78	,	-2.72	,	-2.68	,	-2.65	,	-2.62	,	-2.62	\ /*
		*/	-3.04	,	-2.93	,	-2.85	,	-2.78	,	-2.71	,	-2.68	,	-2.65	,	-2.62	,	-2.62	\ /*
		*/	-3.03	,	-2.92	,	-2.85	,	-2.77	,	-2.71	,	-2.68	,	-2.65	,	-2.62	,	-2.62	\ /*
		*/	-3.03	,	-2.91	,	-2.85	,	-2.77	,	-2.71	,	-2.67	,	-2.65	,	-2.62	,	-2.62	\ /*
		*/	-3.03	,	-2.91	,	-2.85	,	-2.77	,	-2.71	,	-2.67	,	-2.65	,	-2.62	,	-2.62	 )
mat `crit5' = (	-3.1	,	-2.97	,	-2.89	,	-2.82	,	-2.75	,	-2.73	,	-2.7	,	-2.67	,	-2.67	\ /*		
		*/	-2.92	,	-2.82	,	-2.76	,	-2.69	,	-2.64	,	-2.62	,	-2.59	,	-2.57	,	-2.57	\ /*
		*/	-2.88	,	-2.78	,	-2.73	,	-2.67	,	-2.62	,	-2.59	,	-2.57	,	-2.55	,	-2.55	\ /*
		*/	-2.86	,	-2.76	,	-2.72	,	-2.66	,	-2.61	,	-2.58	,	-2.56	,	-2.54	,	-2.54	\ /*
		*/	-2.84	,	-2.76	,	-2.71	,	-2.65	,	-2.6	,	-2.58	,	-2.56	,	-2.54	,	-2.54	\ /*
		*/	-2.83	,	-2.76	,	-2.7	,	-2.65	,	-2.61	,	-2.58	,	-2.57	,	-2.54	,	-2.54	\ /*
		*/	-2.83	,	-2.75	,	-2.7	,	-2.65	,	-2.61	,	-2.59	,	-2.56	,	-2.55	,	-2.55	\ /*
		*/	-2.83	,	-2.75	,	-2.7	,	-2.65	,	-2.61	,	-2.59	,	-2.57	,	-2.55	,	-2.55	\ /*
		*/	-2.83	,	-2.75	,	-2.7	,	-2.65	,	-2.61	,	-2.59	,	-2.57	,	-2.55	,	-2.55	  )
mat `crit10' = (	-2.87	,	-2.78	,	-2.73	,	-2.67	,	-2.63	,	-2.6	,	-2.58	,	-2.56	,	-2.56	\ /*		
		*/	-2.76	,	-2.68	,	-2.64	,	-2.59	,	-2.55	,	-2.53	,	-2.51	,	-2.5	,	-2.5	\ /*
		*/	-2.74	,	-2.67	,	-2.63	,	-2.58	,	-2.54	,	-2.53	,	-2.51	,	-2.49	,	-2.49	\ /*
		*/	-2.73	,	-2.66	,	-2.63	,	-2.58	,	-2.54	,	-2.52	,	-2.51	,	-2.49	,	-2.49	\ /*
		*/	-2.73	,	-2.66	,	-2.63	,	-2.58	,	-2.55	,	-2.53	,	-2.51	,	-2.5	,	-2.5	\ /*
		*/	-2.72	,	-2.66	,	-2.62	,	-2.58	,	-2.55	,	-2.53	,	-2.52	,	-2.5	,	-2.5	\ /*
		*/	-2.72	,	-2.66	,	-2.63	,	-2.59	,	-2.55	,	-2.53	,	-2.52	,	-2.5	,	-2.5	\ /*
		*/	-2.73	,	-2.66	,	-2.63	,	-2.59	,	-2.55	,	-2.54	,	-2.52	,	-2.5	,	-2.5	\ /*
		*/	-2.73	,	-2.66	,	-2.63	,	-2.59	,	-2.55	,	-2.54	,	-2.52	,	-2.5	,	-2.5	 )
}
if `tnc'==1{
/* NO TRUNCATION */
mat `crit1' = (	-3.88	,	-3.61	,	-3.46	,	-3.3	,	-3.15	,	-3.1	,	-3.05	,	-2.98	,	-2.98	\ /*		
		*/	-3.24	,	-3.09	,	-3	,	-2.89	,	-2.81	,	-2.77	,	-2.74	,	-2.71	,	-2.71	\ /*
		*/	-3.15	,	-3.01	,	-2.92	,	-2.83	,	-2.76	,	-2.72	,	-2.7	,	-2.65	,	-2.65	\ /*
		*/	-3.1	,	-2.96	,	-2.88	,	-2.81	,	-2.73	,	-2.69	,	-2.66	,	-2.63	,	-2.63	\ /*
		*/	-3.06	,	-2.93	,	-2.85	,	-2.78	,	-2.72	,	-2.68	,	-2.65	,	-2.62	,	-2.62	\ /*
		*/	-3.04	,	-2.93	,	-2.85	,	-2.78	,	-2.71	,	-2.68	,	-2.65	,	-2.62	,	-2.62	\ /*
		*/	-3.03	,	-2.92	,	-2.85	,	-2.77	,	-2.71	,	-2.68	,	-2.65	,	-2.62	,	-2.62	\ /*
		*/	-3.03	,	-2.91	,	-2.85	,	-2.77	,	-2.71	,	-2.67	,	-2.65	,	-2.62	,	-2.62	\ /*
		*/	-3.03	,	-2.91	,	-2.85	,	-2.77	,	-2.71	,	-2.67	,	-2.65	,	-2.62	,	-2.62	 )
mat `crit5' = (	-3.27	,	-3.11	,	-3.02	,	-2.94	,	-2.86	,	-2.82	,	-2.79	,	-2.75	,	-2.75	\ /*		
		*/	-2.93	,	-2.83	,	-2.77	,	-2.7	,	-2.64	,	-2.62	,	-2.6	,	-2.57	,	-2.57	\ /*
		*/	-2.88	,	-2.78	,	-2.73	,	-2.67	,	-2.62	,	-2.59	,	-2.57	,	-2.55	,	-2.55	\ /*
		*/	-2.86	,	-2.76	,	-2.72	,	-2.66	,	-2.61	,	-2.58	,	-2.56	,	-2.54	,	-2.54	\ /*
		*/	-2.84	,	-2.76	,	-2.71	,	-2.65	,	-2.6	,	-2.58	,	-2.56	,	-2.54	,	-2.54	\ /*
		*/	-2.83	,	-2.76	,	-2.7	,	-2.65	,	-2.61	,	-2.58	,	-2.57	,	-2.54	,	-2.54	\ /*
		*/	-2.83	,	-2.75	,	-2.7	,	-2.65	,	-2.61	,	-2.59	,	-2.56	,	-2.55	,	-2.55	\ /*
		*/	-2.83	,	-2.75	,	-2.7	,	-2.65	,	-2.61	,	-2.59	,	-2.57	,	-2.55	,	-2.55	\ /*
		*/	-2.83	,	-2.75	,	-2.7	,	-2.65	,	-2.61	,	-2.59	,	-2.57	,	-2.55	,	-2.55	 )
mat `crit10' = (	-2.98	,	-2.89	,	-2.82	,	-2.76	,	-2.71	,	-2.68	,	-2.66	,	-2.63	,	-2.63	\ /*		
		*/	-2.76	,	-2.69	,	-2.65	,	-2.6	,	-2.56	,	-2.54	,	-2.52	,	-2.5	,	-2.5	\ /*
		*/	-2.74	,	-2.67	,	-2.63	,	-2.58	,	-2.54	,	-2.53	,	-2.51	,	-2.49	,	-2.49	\ /*
		*/	-2.73	,	-2.66	,	-2.63	,	-2.58	,	-2.54	,	-2.52	,	-2.51	,	-2.49	,	-2.49	\ /*
		*/	-2.73	,	-2.66	,	-2.63	,	-2.58	,	-2.55	,	-2.53	,	-2.51	,	-2.5	,	-2.5	\ /*
		*/	-2.72	,	-2.66	,	-2.62	,	-2.58	,	-2.55	,	-2.53	,	-2.52	,	-2.5	,	-2.5	\ /*
		*/	-2.72	,	-2.66	,	-2.63	,	-2.59	,	-2.55	,	-2.53	,	-2.52	,	-2.5	,	-2.5	\ /*
		*/	-2.73	,	-2.66	,	-2.63	,	-2.59	,	-2.55	,	-2.54	,	-2.52	,	-2.5	,	-2.5	\ /*
		*/	-2.73	,	-2.66	,	-2.63	,	-2.59	,	-2.55	,	-2.54	,	-2.52	,	-2.5	,	-2.5	 )
	}
}

forv p = 1/9 {
if `capn'<=`en'[1,`p'] {
    	forv q=1/9 {
    		if `capt' <= `te'[1,`q'] {
 					return scalar cv1 = `crit1'[`q',`p']
    				 	return scalar cv5 = `crit5'[`q',`p']
	    				return scalar cv10 = `crit10'[`q',`p']
					continue,break
    					}
				}
    			continue,break
	}
}

end