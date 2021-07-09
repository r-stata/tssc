********************************************************************************************************************************
* pbreg fits the Preece and Baines 1978 family of growth curves.
* version 1.0
* Author: Adrian Sayers
* Date: 06.03.2013
*
********************************************************************************************************************************

prog define pbreg , rclass
version 9.2
syntax varlist(min=2 max=2 numeric) [if] [in] , 	[ 		Model(integer 1)		///
															h1( real 0)				///
															HTheta(real 0)			///
															s0(real 0)				///
															s1(real 0)				///
															THeta(real 0)			///
															GAmma(real 1)			///
															p0(real 0)				///
															p1(real 0)				///
															q1(real 0)				///
															level(real 95) 			///
															nolog					///
															trace					///
															iterate(integer 10000)  ///
															grid					///
															GRIDSPace(integer 5)    ///
															bestvals(integer 5) 	///
															cdif					///
															eps(real 1e-5)			///
													]

tokenize `varlist'
	tempname outcome time
		gen `outcome' = `1'
		gen `time' = `2'

*********************************************************************************************
* Speed Model convergence, zero data, starting values and grid search
*********************************************************************************************
quietly { // find initial values.

if "`cdif'"!="" { // Calculate first central difference derivative as starting values.
	tempvar vel

	sort `time'
		gen `vel' = (`outcome'[_n+1] - `outcome'[_n-1]) / (`time'[_n+1] -`time'[_n-1])
			su `vel' , meanonly
				local phv =r(max)
			su `outcome' , meanonly
				local h1  = r(max)
				su `outcome' if `vel'>`phv'-0.000001  & `vel'<`phv'+0.000001 , meanonly
					local htheta = r(mean)
				su `time' if `vel'>`phv'-0.000001  & `vel'<`phv'+0.000001 , meanonly
					local theta = r(mean)
					local s0 = 1
					local s1 = 0.1
				} // end cdif starting values.


if "`grid'" != "" { // Grid Search for starting values.
	tempfile start_values

	cap postclose sv
		postfile sv rss h1 htheta theta using `start_values' , replace

	// Use tokens
	 su `outcome'
		local min_ht = r(min)
		local max_ht = r(max)
		local grid_ht = (r(max) - r(min))/`gridspace'
	 su `time'
		local min_age = r(min)
		local max_age = r(max)
		local grid_age  = (r(max) - r(min))/`gridspace'
	noisily di "Conducting grid search"
	forvalues h1 = `min_ht'(`grid_ht')`max_ht'  {
		forvalues htheta = `min_ht'(`grid_ht')`max_ht'  {
			forvalues theta = `min_age'(`grid_age')`max_age'  {
				capture pbreg `outcome' `time' , model(1) h1(`h1') htheta(`htheta') theta(`theta') s0(1) s1(0) iterate(1)
					post sv (`e(rss)' ) ( `h1') (`htheta') (`theta')
					 noisily di "*" _c
			}
		}
	}
	postclose sv

	// Store the best 5 starting values
		preserve
			use  `start_values' , clear
				sort  rss
				 noisily di _n "Preserving best starting values" _n
					forvalues  i = 1 / `bestvals' {
						local h1_`i'		= h1[`i']
							local htheta_`i' 	= htheta[`i']
								local theta_`i'		= theta[`i']
									noisily di "*" _c
										}
		restore

	// Try 5 of the best to completeion
	local minssr = .
	local best_h1 = .
	local best_htheta = .
	local best_theta = .


noisily di _n "Trying best starting values" _n
	forvalues i = 1 / `bestvals' {
	capture  pbreg `outcome' `time' , model(1) h1(`h1_`i'') htheta(`htheta_`i'') theta(`theta_`i'') s0(1) s1(0) iterate(`iterate')
		if e(rss)  <`minssr' {
			local best_h1 = `h1_`i''
			local best_htheta = `htheta_`i''
			local best_theta = `theta_`i''
			local minssr = e(rss)
							} // end if rss is smaller
					noisily di "*" _c
						}

	// Initial Values

	local h1		=_b[/h1]
	local htheta    =_b[/htheta]
	local theta		=_b[/theta]
	local s0        =_b[/s0]
	local s1        =_b[/s1]
 } // End Grid Search

 } // end quietly find iinitial values.

if `model'==1 local initial "h1 `h1'  htheta `htheta' s0 `s0' s1 `s1' theta `theta'"
if `model'==2 local initial "h1 `h1'  htheta `htheta' s0 `s0' s1 `s1' theta `theta' ga `gamma'"
if `model'==3 local initial "h1 `h1'  htheta `htheta' P0 `p0' P1 `p1' theta `theta' Q1 `q1'"


*********************************************************************************************
* Fit the Models
*********************************************************************************************
capture noisily  {
*********************************************************************************************
// Model 1
*********************************************************************************************

if `model' ==1 {
	 nl (`outcome' = {h1} -  ((2*({h1}-{htheta})) / ( exp({s0}*(`time'-{theta})) + exp({s1}*(`time'-{theta}))))) `if' `in' , ///
		initial(`initial' ) level(`level') iterate(`iterate') eps(`eps')   `log' `trace'
				} // end model 1

*********************************************************************************************
// Model 2
*********************************************************************************************

if `model' ==2 {
nl 	(`outcome' = {h1} - (({h1}-{htheta}) / (((0.5*exp(({ga}*{s0})	*(`time'-{theta}))) + (0.5*exp(	({ga}*{s1}) * 	(`time'-{theta}))))^(1/{ga})))) `if' `in' , initial(`initial' )  level(`level')  iterate(`iterate')
				} // end model 2

*********************************************************************************************
// Model 3
*********************************************************************************************

if `model' ==3 {
nl 	(`outcome' = {h1} - ((4*({h1}-{htheta})) /  ((exp({P0}*(`time'-{theta})) +  exp({P1}*(`time'-{theta})))* (1+ exp({Q1}*(`time'-{theta})))))) `if' `in' , initial(`initial' ) level(`level')
       			} // end model 3

       			}
if _rc != 0 {
	 di as err "PB Model Failure "
	 exit _rc
	 		}


end
