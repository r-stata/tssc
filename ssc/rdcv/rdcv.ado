/*change log
2014-06-03: noscatter added, help file edited, 
			warning added if -distinct- is not installed
2015-09-18: bug fix in case of discrete running variable
2015-10-04: include error message if moremata package is missing
2015-11-07: problem with small matsize fixed.
*/

program define rdcv, rclass
version 11.0
syntax varlist(numeric min=2 max=2) [in] [if] [aw fw /], ///
[THReshold(numlist max=1) NGrid(numlist max=1 >=3 int) ///
GRIDpoints(numlist >0) CVSample(numlist max=2 >0 <=100) ///
FASTcv(numlist max=1 >0 <=100) NOTRD ///
DEGree(numlist max=1 >=0 int) BWidth(numlist min=1 max=2 >0) Kernel(string) ///
GENerate(string) SE(string) AT(varname) N(numlist max=1 integer >3) ///
wide strict IKbwidth ROTbwidth SAMEbwidth NOGRaph NOSCatter  ///
ci level(numlist max=1 >=90 <100) vce(string) ///
lineopt(string asis) scatopt(string asis) ///
areaopt(string asis) gropt(string asis) ]
 
 
*----------------------------------------------
loc t1=string(  clock("$S_DATE $S_TIME", "DMYhms")/1000, "%14.0f"  )

* package requirement
capt findfile lmoremata.mlib
if _rc {
	di as error "-moremata- is required; type {stata ssc install moremata} and restart Stata."
	error 499
	exit
}
capt findfile distinct.ado
if _rc {
  	di as error "the package -distinct- is required; type {stata ssc install distinct}"
	error 499
	exit
}

* get dep var and indep var from varlist
gettoken (local) depvar (local) indepvar: varlist
* mark obs to be included by if/in
marksample touse

*two sample or one sample
tempvar group group0 group1
tempname N0 N1
*inequality
if "`strict'"=="" {
  loc above ">="
  loc below "<"
  }
else              {
  loc above ">"
  loc below "<="
  }
if "`threshold'"!="" {
	* generate treatment variable
	g double `group'=(`indepvar' `above' `threshold')
	* check whether it is valid
	qui distinct `group'
	if r(ndistinct)!=2 {
	di as err "threshold is not valid"
	exit
	}
	* generate samples of group=0 and group=1
	g `group0' = (`group'==0 & `touse')
	g `group1' = (`group'==1 & `touse')
	qui count if `group0'
	sca `N0'=r(N)
	qui count if `group1'
	sca `N1'=r(N)
	loc nsamp "0 1"
}
else {
	* one sample
	g `group0' = (`touse')
	qui count if `group0'
	sca `N0'=r(N)
	loc nsamp "0"
}

*----------------------------------------------
* generate weights variable
tempvar w
if "`weight'" != "" g double `w'=`exp'
else 				g `w'=1

* either RD or NOTRD
if ("`threshold'"=="" & "`notrd'"=="") | ("`threshold'"!="" & "`notrd'"!="") {
di as err "either specify threshold( ) for RD estimation or use option NOTRD"
exit
}
if ("`samebwidth'"!="" & "`notrd'"!="") {
di as err "samebwidth is only allowed with RD estimation"
exit
}

*gridpoint options
if "`ngrid'"!="" & "`gridpoints'"!="" {
	di as err "don't specify 'ngrid' and 'gridpoints' at the same time"
	exit
}
if "`kernel'"=="" 	loc kernname "tri"
else 				loc kernname "`kernel'"

*Bandwidth choice method
if ("`bwidth'"!="") & ("`ikbwidth'"!="" | "`rotbwidth'"!="") | ///
("`ikbwidth'"!="" & "`rotbwidth'"!="")  {
	di as err "Don't specify more than one out of the bwidth, rotbwidth and ikbwidth options"
exit
}
if ("`bwidth'"!="" | "`ikbwidth'"!="" | "`rotbwidth'"!="") &  /*
*/ ("`ngrid'"!="" | "`gridpoints'"!="" | "`fastcv'"!="" | "`cvsample'"!="") {
	di "`ngrid' and `gridpoints' and `fastcv' and `cvsample'"
	di as err "CV options ngrid, gridpoints, fastcv and cvsample cannot be " /*
	*/ "combined with bwidth, ikbwidth or rotbwidth"
exit
}
*Imbens-Kalyanaraman: only triangle and rectangle are allowed
if !inlist("`kernname'","tri","rec") & "`ikbwidth'"!="" {
	di as err "Imbens-Kalyanaraman bandwidth is only allowed with rectangle or triangle kernel"
exit
}
* at options
if "`n'"!="" & "`at'"!="" {
di as err "n( ) and at( ) may not be specified simultaneously"
exit
}
* error if user's values in at( ) are only on one side of threshold
if "`at'"!="" & "`threshold'"!="" {
	qui su `at'
	if (r(min)>=`threshold' | r(max)<=`threshold') {
	di as err "values in at( ) not valid"
	exit
	}
}
*-------------------------------------------------------

*degree
if "`degree'"=="" loc degree=1 /*default*/
*size of grid for grid search
if "`ngrid'"=="" loc ngrid=20 /*default*/
* confidence level
if "`level'"!="" loc mult=invnormal(`level'/100 + (100-`level')/200)
else loc mult=invnormal(0.975)
*VCE
if "`vce'"=="" loc vce "r"

if "`n'"!="" {
	*expand dataset if more bins requested than observations
	if `n'>_N {
		qui set obs `n'
		di as text " Note:  sample size was increased because the number in " /*
		*/ " n( ) was larger than the data set " 
		replace `touse'=0 if `touse'==.
		replace `group0'=0 if `group0'==.
		replace `group1'=0 if `group1'==.
	}
}
if "`n'"!="" {
	*create estimation points from number of bins
	qui su `indepvar' if `touse', d
	loc minx=r(p1)
	loc maxx=r(p99)
	tempvar binat
	qui g `binat'=.
	forv i=1/`n' {
		qui replace `binat'=`minx' + ((`maxx'-`minx')/(`n'-1))*(`i'-1) in `i'
	}
}


*----------------------------------------------------------------------

*bandwidth choice: crossvalidation procedure


*make a temporary copy of the data
sort `indepvar' /*!important! sort data*/
tempfile _tempdata
qui save `_tempdata', replace


/* if we want one bandwidth for below and above, we run the CV loop 
only once. the local nsamp will be reset after bandwidth choice is complete */
if "`samebwidth'"!="" loc nsamp "0"

*scalars for bandwidths
tempname s0 s1


if "`ikbwidth'`bwidth'`rotbwidth'"=="" { /*cross-validation*/

foreach T in `nsamp' {

	qui use `_tempdata', clear

	loc interior=0 	/*indicator for being in  the interior of grid*/
	loc witer=1		/*number of while-iterations*/
	loc flat=0		/*initialize indicator for flatness*/
	tempname cv_N`T'
	*di "{hline 40}" _n "`T'"
	
	if `T'==0 loc side "on the left of the threshold "
	if `T'==1 loc side "on the right of the threshold "
	if "`samebwidth'"!="" loc side "" 
	di _n "grid search `side'..."
	
	*choose whether observation should be cross-validated
	tempvar incl
	if "`fastcv'"!="" {
		qui g `incl'=(100*runiform()<`fastcv') ///
			if (_n>3+`degree' & _n<(_N-(3+`degree')) )
	}
	else {
		* leave out observations at the boundary of the support
		qui g `incl'=1 if (_n>10+`degree' & _n<(_N-(10+`degree')) )
	}
	* for discrete data: omit p+1 largest and smallest values
	qui su `indepvar'
	loc degree_plus1 = `degree' + 1
	forv i=1/`degree_plus1' {
	qui su `indepvar' if `indepvar'>r(min) & `indepvar'<r(max)
	}
	replace `incl'=0 if !inrange(`indepvar',r(min),r(max))
	

	*restrict sample to below or above
	if "`samebwidth'"=="" 	qui keep if `group`T''

	*CV subsample (option "cvsample")
	if "`cvsample'"!="" {
		*get range of sample to be cross-validated
		di "cvsample is `cvsample'"
		loc cvs1=real(word("`cvsample'",1))
		loc cvs2=real(word("`cvsample'", 2))
		if "`cvs2'"=="" loc cvs2 = `cvs1'
		 *su `indepvar'
		if `T'==0 {
			loc tau=100-`cvs1'
			_pctile `indepvar' if `indepvar' `below' `threshold', p(`tau')
			qui drop if `indepvar'<r(r1)
		}
		if `T'==1 {
			if "`cv2'"=="" 	loc tau=`cvs1'
			else 			loc tau=`cvs2'
			_pctile `indepvar' if `indepvar' `above' `threshold', p(`tau')
			qui drop if `indepvar'>r(r1)
		}
	*su `indepvar'
	}
	

	while `interior'!=1 {
		
		*(re-)set starting values for mse
		loc mse_lag1=10000000
		loc mse_lag2=10000001

		
		* user-specified grid:
		if "`gridpoints'"!="" {
			numlist "`gridpoints'"
			loc ngrid=wordcount("`gridpoints'")
			mat bw`T'=J(`ngrid',2,.)
			forvalues i=1/`ngrid' {
				mat bw`T'[`i',1]=real(word("`r(numlist)'",`i'))
			}
			loc gmin=bw`T'[1,1]
			/* if user specifies gridpoint, do not re-scale the grid. Just 
			pretend that an interior was found. Left to the user to adjust
			the grid */
			loc interior=1
		}
		* default grid:
		else {
			*first time: choose starting grid
			if `witer'==1 {
				*pilot bandwidth
				*di "no. of obs is " _N
				
				tempvar match
				g `match'=_n // matchvar for unique values of x

				* get list of unique values of x
				preserve
					qui keep if `group`T''
					keep `indepvar'
					qui duplicates drop `indepvar', force
					tempname rot_at
					rename `indepvar' `rot_at'
					g `match'=_n
					tempfile uniquex
					qui save `uniquex'
				restore
				* attach unique values of x as variable
				qui merge 1:1 `match' using `uniquex', nogen
				
				* estimate pilot bandwidth at unique values of x
				if "`samebwidth'"=="" {
				lpoly `depvar' `indepvar' if `group`T'', nogr deg(`degree') ///
					kernel(`kernname') at(`rot_at')
				}
				else {
				lpoly `depvar' `indepvar', nogr deg(`degree') ///
					kernel(`kernname') at(`rot_at')
				}
				*di "-----------------" _n "rot-bandwidth: " r(bwidth)
				*choose max and min of grid
				loc gmax=2   *r(bwidth)
				loc gmin=0.5 *r(bwidth)
				if "`wide'"=="wide" {
					loc gmax=4   * r(bwidth)
					loc gmin=0.25* r(bwidth)
				}
			}
			*define matrix with linear grid
			loc gnum=`ngrid'-2
			loc gint=(`gmax' - `gmin')/`gnum'
			loc gpoi=`gmin'
			cap mat drop bw`T'
			forvalues i=1/`ngrid' {
				mat bw`T'=nullmat(bw`T') \ [`gpoi',.]
				loc gpoi=`gpoi'+`gint'
			}
			*matlist bw`T'
		}
		
		*compute MSE of leave-out-out residuals across grid
		forvalues g=1/`ngrid' {
				
				qui {
		
		
				*get bandwidth from grid
				loc s=bw`T'[`g',1]
				tempname ssca
				sca `ssca'=`s'
				*fitted values
				tempvar yhat
				cap drop `yhat'
				qui g `yhat'=.

				*determine sample size for CV
				if "`samebwidth'"=="" 	qui count if `group`T''
				else 					qui count if `touse'
				sca `cv_N`T''=r(N)
				loc last=`cv_N`T''

				*iteration across observations
				forvalues i=1/`last' {
				if `incl'[`i']==1 {
				
					di "___________________________________"
					di "number of valid obs is `last'"
					di "at `indepvar'[`i']"
				
					
					*generate temp variables 
					tempvar x z wgt touse2
					
					g double `x'=`indepvar' - `indepvar'[`i']					/*center x-variable at obs i*/
					loc xpoly "`x'"
					g double `z'=`x' / `s'
					g double `wgt'=`w'
					*generate polynomials if specified: option "degree"
					if `degree'>1 {
						forv p=2/`degree' {
							tempvar x`p'
							g double `x`p'' = `x'^`p'
							loc xpoly "`xpoly' `x`p''"
						}
					}
					*if samebwidth requested, add interactions with treatment
					*indicator to covariate set
					if "`samebwidth'"!="" {
						*treatment dummy
						tempvar D
						g `D' = (`indepvar' `above' `threshold')
						*interactions with indepvar
						di -33
						di "`xpoly'"
						di wordcount("`xpoly'")
						forv p=1/`degree' {
							loc xterm = word("`xpoly'",`p')
							tempvar Dx`p'
							g double `Dx`p''=`D' * `xterm'
							loc xpoly "`xpoly' `Dx`p''"
						} /*end of v-loop*/
						loc xpoly "`xpoly' `D'"
						
					}

					*get kernel weights at obs. i
					g `touse2'=cond(`touse'==1 & _n!=`i',1,0) /*leave out obs i*/
					mata:x=st_data(.,"`xpoly'","`touse2'")
					mata:x=x,J(rows(x),1,1)
					mata:w_user=st_data(.,"`wgt'","`touse2'")
					mata:h=st_numscalar("`ssca'")
					mata:w=1/h * w_user :* mm_kern("`kernname'", x[.,1]/h)
					mata:st_store(.,"`wgt'","`touse2'",w)
					/* use asymmetric kernel weights to mimick estimation
					at the threshold */
					list `depvar' `x' `wgt' `touse2'
					if "`threshold'"!="" {
						if `T'==0 replace `wgt'=0 if `x' `above' 0
						if `T'==1 replace `wgt'=1 if `x' `below' 0
					}
					
					*save mean estimate at obs i
					mata:y=st_data(.,"`depvar'","`touse2'")
					mata:b=luinv(((x:*w)'*x))*(x:*w)'*y
					mata: st_store(`i',"`yhat'",b[rows(b),1])
					
					* drop temp variables after iteration is completed
					drop `x' `z' `touse2'
					cap drop `D'
					forv p=1/`degree' {
						cap drop `x`p'' 
						cap drop `Dx`p''
					}
					di "number of variables is " c(k)
					
					*** break off if not enough observations
					qui count if (`wgt'!=. & `wgt'>0)
					di r(N) " vs " 2+`degree'
					/* if we have too few observations with positive kernel weights
					but in the interior of the sample, execute break rule */
					if r(N)<2+`degree' & `i'/`last'>0.05 & `i'/`last'<0.95 {
						di "execute break rule"
						qui replace `yhat'=.
						continue, break
					}
					drop `wgt'
					***

				} /* end of if `incl'[`i']==1 */
				} /* end of forvalues i=1/`last' */
				
				* compute MSE for gridpoint g
				tempvar res2
				g `res2'=(`depvar' - `yhat')^2		/*squared residuals*/
				qui su `res2', meanonly				/*mean squared residuals*/
				loc mse_now=r(mean)
				mat bw`T'[`g',2]=r(mean)
				
				*drop temp variables
				drop `res2' `yhat'
				
				
				} /*end of quiet*/	
				
				di as text "iteration " `g' ";" _col(17) "bw=" %9.0g `s' ";" _col(35) "CV criterion=" %9.0g `mse_now' 
		
				*abortion rule if flat region encountered
				if abs(`mse_now'/`mse_lag1'-1)<0.00001 & `mse_now'<`mse_lag1'  {
				*di "flat area encountered"
				loc flat=1
				continue, break
				}
				*abortion if mimimum has been passed. 
				if `mse_now'>`mse_lag1' & `mse_lag1'>`mse_lag2' {
				*di as text "minimum surpassed"
				continue, break
				}

				*update lags for next loop
				loc mse_lag2=`mse_lag1'
				loc mse_lag1=`mse_now'
		
		} /*end of g grid loop*/
			
		*pick minimum bandwidth out of grid
		tempname minrow`T'
		mata:cv=st_matrix("bw`T'")
		mata:ssr=cv[.,2]
		mata:minssr=.
		mata:w=J(1,2,.)
		mata:minindex(ssr,1,minssr,w)
		mata:minssr=minssr[1,1]
		mata:s=cv[minssr,1]
		mata:st_numscalar("`s`T''", s)
		mata:st_numscalar("`minrow`T''", minssr)
		
		* warn user if minimum MSE is a grid corner
		if `minrow`T''==1  {
			di "minimum found in the left corner of the grid" _n "{hline 49}"
			loc gmin=bw`T'[1,1]*0.5
			loc gmax=bw`T'[3,1]
			di "new grid runs from `gmin' to `gmax'"
			loc witer=`witer'+1
		}
		else if (`minrow`T''==`ngrid') | (bw`T'[`minrow`T''+1,2]==. & !`flat')  {
			di "minimum found in the right corner of the grid" _n "{hline 49}"
			loc gmin=bw`T'[`ngrid'-1,1]
			loc gmax=bw`T'[`ngrid',1]*2
			di "new grid runs from `gmin' to `gmax'"
			loc witer=`witer'+1
		}
		else if `flat'==1 {
			di "minimum found in right corner" _n "{hline 49}"
			loc interior=1
		}
		else {
			di "minimum found in the interior" _n "{hline 49}"
			loc interior=1
		}
	
	
	} /*end of interior-while */	
		
	mat coln bw`T'=bandwidth IMSE
	
	
} /*end of forvalues T*/

if "`samebwidth'"!="" sca `s1' = `s0'

} /*end of loop "`ikbwidth'"=="" & "`bwidth'"=="" & "`rotbwidth'"=="" */


*----------------


* re-set the local nsamp
if "`samebwidth'"!="" & "`threshold'"!="" loc nsamp "0 1"


*load the data for estimation
qui use `_tempdata', clear

*ROT bandwidth (STATA default)
if "`rotbwidth'"!= "" {
		foreach T in `nsamp' {
			lpoly `depvar' `indepvar' if `group`T'', nogr deg(`degree')  kernel(`kernname')
			*ret list
			sca `s`T''=r(bwidth)
			if r(bwidth)==. sca `s`T''=1
		}
	if "`samebwidth'"!="" {
		sca `s0'=0.5 * (`s0' + `s1')
		sca `s1'=`s0'
	}
}
* User's bandwidth choice
else if "`bwidth'"!= "" {
	sca `s0'=real(word("`bwidth'",1))
	if "`threshold'"!="" {
		sca `s1'=real(word("`bwidth'",2))
		if scalar(`s1')==. sca `s1'=`s0'
	}
}
*choose Imbens-Kalyanamaran optimal bandwidths
if "`threshold'"!="" & "`ikbwidth'"!="" {
	ikbw `depvar' `indepvar', z0(`threshold') kernname2(`kernname') ///
	samp(`touse') wt(`exp') below(`below') above(`above')
	sca `s0'=r(hopt)
	sca `s1'=r(hopt)
}

* END OF BANDWIDTH SEARCH

*--------------------------------------------------------------------

loc ge_name "`generate'"
loc se_name  "`se'"

*local kernel regression


foreach T in `nsamp' {
	
	*write working bandwidth in local to be used in estimation below
	*di 50
	loc s`T'opt=`s`T''
	*di "s`T'opt is `s`T'opt'"

	
	*user chooses at- or n-option: specify internal at-variable
	if ("`at'"!="" | "`n'"!="") {
		* user specific at-variable
		if "`at'"!="" 			loc at_name	"`at'"
		* at-variable from bins
		if "`n'"!=""			loc	at_name	"`binat'"
		
		* specify internal at-variable
		if "`threshold'"=="" {
			if `T'==0 qui g iat0 = `at_name'
		}
		else {
			if `T'==0 qui g iat0 = `at_name' if `at_name' `below' `threshold'
			if `T'==1 qui g iat1 = `at_name' if `at_name' `above' `threshold'
		}
	}
	*else: default: at-variable corresponds to all unique values of indepvar
	tempvar match2
	g `match2'=_n // matchvar for unique values of x
	else {
		preserve
			keep `indepvar'
			qui duplicates drop `indepvar', force
			g `match2' = _n
			qui g iat`T' = `indepvar'
			tempfile xunique
			qui save `xunique'
		restore
		qui merge 1:1 `match2' using `xunique', keepus(iat`T') nogen
		if "`threshold'"!="" {
		if `T'==0 qui replace iat`T'=. if iat`T' `above' `threshold'
		if `T'==1 qui replace iat`T'=. if iat`T' `below' `threshold'
		}
	}
	
	*di "bw is `s`T'opt'"
	
	* run LPR
	qui lpoly `depvar' `indepvar' if `group`T'' [aw=`w'], ///
	bw(`s`T'opt') deg(`degree') k(`kernname')  ///
	gen(imu`T') at(iat`T') se(ise`T') nogr
	*compute CI if requested
	if "`ci'"=="ci" {
			qui g icil`T'=cond(iat`T'!=.,imu`T'-`mult'*ise`T',.)
			qui g iciu`T'=cond(iat`T'!=.,imu`T'+`mult'*ise`T',.)
	}
	else {
			qui g icil`T'=.
			qui g iciu`T'=.
	}
	
}
***

if "`threshold'"!="" {
		*computing boundary estimate
		tempvar bound_x bound_z bound_wgt bound_D bound_Dx bound_s
		*di "nsamp is `nsamp'" _n  "s0opt is `s0opt'" _n "s1opt is `s1opt'"
		
		* get kernel weights
		qui g `bound_wgt'=.
		qui g double `bound_x'=`indepvar' - `threshold'		/*center x-variable at obs i*/
		qui g double `bound_s'=cond(`bound_x'<0,`s0opt',`s1opt')
		qui g double `bound_z'=`bound_x'/`bound_s'
		mata:z=st_data(.,"`bound_z'","`touse'")
		mata:w_user=st_data(.,"`w'","`touse'")
		mata:h=st_data(.,"`bound_s'","`touse'")
		mata:w=(h:^(-1)) :* w_user :* mm_kern("`kernname'", z)
		mata:st_store(.,"`bound_wgt'","`touse'",w)
		qui g `bound_D'=(`bound_x' `above' 0)
		qui g double `bound_Dx' = `bound_x'*`bound_D'
		
		*generate polynomials if specified
		loc xpoly ""
		if `degree'>1 {
			forv p=2/`degree' {
				tempvar bound_x`p' bound_Dx`p'
				g double `bound_x`p'' = `bound_x'^`p'
				g double `bound_Dx`p'' = `bound_D' * `bound_x`p''
				loc xpoly "`xpoly' `bound_x`p'' `bound_Dx`p''"
			}
		}
		*di "`xpoly'"
		* estimate LPR
		qui reg `depvar' `bound_x' `bound_D' `bound_Dx' `xpoly' ///
			[pw=`bound_wgt'] if `touse', vce(`vce')
		qui lincom _b[_cons] + `bound_D'
		
		*obtain point estimates
		tempname b0 se0 b1 se1 jump jump_se
		sca `b0'	=	_b[_cons]
		sca `se0'	=	_se[_cons]
		sca `b1'	=	r(estimate)
		sca `se1'	=	r(se)
		sca `jump'	=	_b[`bound_D']
		sca `jump_se'=	_se[`bound_D']
}
**		

*user-specific at option: re-define group variables to match user's at-variable
if "`at_name'"!="" & "`threshold'"!="" {
	qui replace `group1'=(iat1 `above' `threshold') & iat1!=.
	qui replace `group0'=(iat0 `below' `threshold')
}
*merge internal 0/1-variables 
foreach v in imu ise iciu icil iat   {
		qui g _`v'=`v'0 if iat0!=.
		drop `v'0
		if "`threshold'"!="" {
			qui replace _`v'=`v'1 if iat1!=.
			drop `v'1
		}
}

*match estimates to the dataset
if "`at_name'"=="" {
	preserve
		keep _iat _imu _ise _iciu _icil
		qui duplicates drop _iat, force
		qui drop if _iat==.
		g _matchvar = float(_iat) /*use float precision for merge*/
		tempfile _tempdata2
		qui save `_tempdata2', replace
	restore
	drop _iat _imu _ise _iciu _icil
	g _matchvar = float(`indepvar') /*use float precision for merge*/
	qui merge m:1 _matchvar using `_tempdata2', nogen
}

*user-specific mean estimate
if "`ge_name'"!="" {
qui g `ge_name' = _imu
}
*user-specific st.err. estimate
if "`se_name'"!="" {
qui g `se_name' = _ise
}

*combined graph: design and features
if "`nograph'"=="" {

	if "`ci'"=="ci" loc cilab "lab(1 CI)" 	/*label for CI*/
	if "`ci'"=="ci" loc ciord "1"			/*include CI in legend*/
	*label axes
	loc xlab: var l `indepvar'
	loc ylab: var l `depvar'
	if "`xlab'"=="" loc xlab "`indepvar'"
	if "`ylab'"=="" loc ylab "`depvar'"
	*define graph options
	if "`gropt'"=="" {
		if "`threshold'"!="" loc gropt "scheme(s1mono) legend(order(`ciord' 4) `cilab' lab(4 mean estimate)) yti(`ylab') xti(`xlab') xli(`threshold', lp(dash))"
		else loc gropt "scheme(s1mono) legend(order(`ciord' 3) `cilab' lab(3 mean estimate)) yti(`ylab') xti(`xlab')"
	}
	*define component options
	if "`lineopt'"=="" loc lineopt "sort lc(navy)"
	if "`scatopt'"=="" loc scatopt "m(O) mc(green)"
	if "`areaopt'"=="" loc areaopt "sort lc(gs13) fc(gs13)"


	* GRAPHING
	*scatterplot yes no
	if "`noscatter'"!="" loc scat_com ""
	else loc scat_com "(scatter `depvar' `indepvar' if `touse' , `scatopt')"
	
	* for RD case
	if "`threshold'"!="" {
			twoway  (rarea _iciu _icil _iat if `group0', `areaopt') ///
					(rarea _iciu _icil _iat if `group1', `areaopt') `scat_com' ///
					(line _imu _iat if `group0', `lineopt') ///
					(line _imu _iat if `group1', `lineopt'), ///
					`gropt'

	}
	* for one sample case
	else {
			twoway  (rarea _iciu _icil _iat if `group0', `areaopt') `scat_com' ///
					(line _imu _iat if `group0', `lineopt'), ///
					`gropt'
	}

}
*drop internal variables
drop _iat _imu _ise _iciu _icil _matchvar

*----------------------------------------------


*RD: display results
loc rfo "as res %8.0g"
if "`threshold'"!="" {
di ""
di as text "{hline 65}" 

if "`ikbwidth'"!="" loc bwmethod "Imbens-Kalyanaraman"
else if "`rotbwidth'"!="" loc bwmethod "Plug-in Estimator (ROI)"
else if "`bwidth'"!="" loc bwmethod "User's Choice"
else loc bwmethod "Cross-Validation"
di as text "Bandwidth is determined by `bwmethod'"

di as text "Dependent variable:" 	_col(25) "`depvar'"
di as text "Forcing Variable:" 		_col(25) trim("`indepvar'")
di as text "Treatment:" 			_col(25) "D=(`indepvar' `above' `threshold' )"
if "`weight'" !="" di as text "Weights:" _col(25) "`exp'"
di as text "Polynomial Degree:"		_col(25) "`degree'"
di as text "Kernel"					_col(25) "`kernname'"
di as text " "
loc c1=20
loc c2=30
loc c3=40
loc c4=54
di as text _col(`c1') " estimate" _col(`c2') " st.err " _col(`c3') " bandwidth" _col(`c4') "sample size"
di as text "{hline 65}" 
di as text "below threshold" _col(`c1') `rfo' `b0' "" _col(`c2') `rfo' `se0' "" `rfo' _col(`c3') `s0opt' " " _col(`c4') `N0'
di as text "above threshold" _col(`c1') `rfo' `b1' "" _col(`c2') `rfo' `se1' "" `rfo' _col(`c3') `s1opt' " " _col(`c4') `N1'
di as text "{hline 65}" 
di as text "difference (jump)" _col(`c1') `rfo' `jump' "" _col(`c2') `rfo' `jump_se'
di as text "{hline 65}" 
}
*RD: save some stuff in r()
*one sample: save stuff in r()
if "`ikbwidth'"=="" & "`bwidth'"=="" & "`rotbwidth'"=="" ret mat cv_bw0=bw0
ret sca N0=`N0'
ret sca bw0=`s0opt'
ret loc depvar="`depvar'" 
ret loc indepvar="`indepvar'"
ret loc kernel = "`kernname'"
ret loc degree = "`degree'"
if "`threshold'"!="" {
	ret sca b0=`b0'
	ret sca b1=`b1'
	ret sca se0=`se0'
	ret sca se1=`se1'
	ret sca jump=`jump'
	ret sca se_jump=`jump_se'
	if "`ikbwidth'"=="" & "`bwidth'"=="" & "`rotbwidth'"=="" & "`samebwidth'"=="" ret mat cv_bw1=bw1
	ret sca N1=`N1'
	ret sca bw1=`s1opt'
	ret loc threshold=`threshold'
	mat R = `b0',`se0',`s0opt' ,`N0' \ `b1',`se1',`s1opt',`N1' \ `jump',`jump_se',.,.
	mat rown R=below above difference
	mat coln R=est se bandwidth obs
	ret mat R = R
}

loc t2=string(  clock("$S_DATE $S_TIME", "DMYhms")/1000, "%14.0f"  )
di "computation time was about " (`t2' - `t1') " sec."
di ""

*----------------------------------------------
end 
*----------------------------------------------



*----------------------------------------------
program define ikbw, rclass
syntax varlist(min=2 max=2), kernname2(string) z0(string) ///
[samp(string) wt(string) above(string) below(string)]
gettoken (local) yvar (local) xvar: varlist

 qui {

di "dep. variable: `yvar'"
di "x variable: `xvar'"
di "sample: `samp'"
di "weight: `wt'"
di "threshold: `z0'"
di "kernel: `kernname2'"
di "below: `below'"
di "above: `above'"

*define weights 
if "`wt'"!="" loc wt="[aw=`wt']"

tempvar cx
* generate centralized x-variable
qui g double `cx'=(`xvar'-`z0')
*---------
  
	   tempvar Y1 Y2 D z z2 z3
	   *Step 1: estimation of density and conditional variances 
	    su `cx' if `samp' `wt', d
	   loc Sx = r(sd)
	   loc N = r(N)
	   loc h1 = 1.84*`Sx'*(`N'^(-1/5)) /*pilot bandwidth*/
	   *1a) estimate the density f(threshold)
	   di 780
	   di "`below'"
	    su `yvar' if (-`h1'<=`cx' & `cx'`below' 0) & `samp' `wt', meanonly
		di 781
	   loc Yh1n = r(mean)
	   loc Nh1n = r(N)
	    su `yvar' if (`cx'`above'0 & `cx'<=`h1') & `samp' `wt', meanonly
	   loc Yh1p = r(mean)
	   loc Nh1p = r(N)
	   loc fxc = (`Nh1p'+`Nh1n')/(2*`N'*`h1') /*density estimate*/
	   *1b) conditional variance of Y given X=threshold, left and right
	   g double `Y1' =(`yvar'-`Yh1n')^2
	   su `Y1' if (-`h1'<=`cx' & `cx'`below'0) & `samp' `wt', meanonly
	   loc Y1sum =r(sum)
	   g double `Y2' =(`yvar'-`Yh1p')^2
	   su `Y2' if (`cx'`above'0 & `cx'<=`h1') & `samp' `wt', meanonly
	   loc Y2sum=r(sum)
	   di 20
	   * average variance
	   loc sigma2c=(`Y1sum'+`Y2sum')/(`Nh1p'+`Nh1n')
		/*  ------- not in paper */
		su `cx' if `cx'`above'0  & `samp' `wt', d
	   sca medXp = r(p50)
	   loc Np=r(N)
	   su `cx' if `cx'`below'0   & `samp' `wt', d
	   sca medXn = r(p50)
	   loc Nn=r(N)
	   *-------- not in paper */
	   *Step 2: 2nd derivatives
	   g byte `D'=(`cx'`above'0) if !mi(`cx') /*indicator for x>threshold*/
	   g double `z'=`cx'
	   g double `z2'=`cx'^2
	   g double `z3'=`cx'^3
	   * third order polynomial regression
	   di 30
	   regress `yvar' `D' `z' `z2' `z3' if (`cx' >= scalar(medXn) & `cx' <= scalar(medXp)) &  `samp' `wt'
	   di 31
	   * 3rd-order derivative
	   loc m3c=6*_b[`z3']
	   * pilot bandwidths
	   di 40
	   loc h2p=3.56*((`sigma2c'/(`fxc'*max((`m3c')^2, 0.01)))^(1/7))*(`Np'^(-1/7))
	   loc h2n=3.56*((`sigma2c'/(`fxc'*max((`m3c')^2, 0.01)))^(1/7))*(`Nn'^(-1/7))
	   di 42
	   * local quadratic fit
	   regress `yvar' `z' `z2' if 0<=`cx' & `cx'<=`h2p'  & `samp' `wt'
	   loc m2pc=2*_b[`z2'] /*2nd-order derivative above*/
	   loc N2p=e(N)
	   di 44
	   regress `yvar' `z' `z2' if -`h2n'<=`cx' & `cx'`below'0  & `samp' `wt'
	   loc m2nc=2*_b[`z2'] /*2nd-order derivative below*/
	   loc N2n=e(N)
	   di 46
	   * regularization terms
	   loc rp=(720*`sigma2c')/(`N2p'*((`h2p')^4))
	   loc rn=(720*`sigma2c')/(`N2n'*((`h2n')^4))
	   di 48
	   * determine constant depending on kernel
	   if "`kernname2'"=="rec" loc CK = 5.4/2
	   if "`kernname2'"=="tri" loc CK = 3.4375
	   * calculate optimal IK bandwidth
	   di `CK'
	   di `fxc'
	   di `sigma2c'
	   di `m2pc'
	   di `m2nc'
	   di `rp'
	   di `rn'
	   loc hopt= `CK'*(((2*`sigma2c')/(`fxc'*(((`m2pc'-`m2nc')^2)+(`rp'+`rn'))))^(1/5))*`N'^(-1/5)
	   di 7
	   ret sca hopt = `hopt'
	   di 8
} /* end of quiet*/
*---------------------------------
end

