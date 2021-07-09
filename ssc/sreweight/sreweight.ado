*! sreweight 11.2 - Revised June 2013
*! Author: Daniele Pacifico, daniele.pacifico@tesoro.it

program sreweight, sortpreserve rclass
	version 12.0

syntax varlist [in] [if], 								///
	SWeight(string) 									///
	NWeight(string) 									///
	TOTal(string) 										///
	DFunction(string) [									///
	TOLerance(real 0.000001) 							///
	NITer(int 50)										///
	UPBound(real 4)										///
	LOWBound(real 0.2) 									///
	RLOWBound(numlist min=2 max=2 ascending sort >0 <1) ///
	RUPBound(numlist min=2 max=2 ascending sort >1) 	///
	RBounds(real 0)										///
	NTries(int 0)										///
	SValues(string) 									///
	]

tempname missing  id tp ttp tpm t difft X m lm u w x s nvar nro nco N err fun cfun fun_o too okay tot results xlmga llb ulb lub uub
marksample touse
markout `touse' `varlist' `sweight'

*--------------------------------
*	Start preliminary checks	|
*--------------------------------
confirm integer number `niter'
confirm integer number `ntries'
cap confirm matrix `total'
if _rc!=0	{
display in re  "Total should contain a Stata Matrix with the new population totals"
exit
			}
*
cap confirm numeric variable `varlist'
if _rc!=0	{
display in re  "Calibrating variables should be numeric"
exit
			}
*
cap confirm numeric variable `sweight'
if _rc!=0	{
display in re  "Survey weights should be numeric"
exit
			}
*
if 	"`dfunction'" != "" 		& ///
	"`dfunction'" != "chi2" 	& ///
	"`dfunction'" != "mchi2"	& ///
	"`dfunction'" != "a"		& ///
	"`dfunction'" != "b"		& ///
	"`dfunction'" != "c"		& ///
	"`dfunction'" != "ds" 		{
	display in red 	"Only the functions named chi2, mchi2, a, b, c and ds are allowed for DFunction(). See the help for references"
	exit 
						}
*
capture assert (`rbounds'== 0 | `rbounds'==1) 
if _rc!=0	{
display in red "The arguments of rbounds() can be 0 or 1"
exit
			}
if ("`dfunction'"=="mchi2") & (`ntries'>0) {
 display in gr "Note: with this distance function, rbounds() is automatically set to 1 if the argument of ntries() is >0"
											}
*
if (`lowbound'<=0 |`lowbound'>=1 | `upbound'<=1) 	{
display in red "lowbound should be between 0-1 and upbound must be bigger than 1"
exit
													}
*
capture assert (`sweight'>=0)
if _rc!=0	{
display in red  "`sweight' should not be negative"
exit
			}
*
if ("`rlowbound'"!="") {
gettoken llb ulb: rlowbound, parse(" ")
}
if ("`rlowbound'"=="") {
local llb=0.1
local ulb=0.7
}
if ("`rupbound'"!="") {
gettoken lub uub: rupbound, parse(" ")
}
if ("`rupbound'"=="") {
local lub=1.5
local uub=6
}
*
*check conformability of entry matrices:
local nvar: word count `varlist' 
scalar `nro'=rowsof(`total')
scalar `nco'=colsof(`total')
if (`nro'!=`nvar' | `nco'!=1)	{
display in red  "matrix `total' must be a column vector with as many rows as the number of calibrating variables"
exit
								}
if "`svalues'" != "" {
confirm matrix `svalues'
scalar `nro'=rowsof(`svalues')
scalar `nco'=colsof(`svalues')							
	if (`nro'!=`nvar' | `nco'!=1)	{
	display in red  "matrix `svalues' must be a column vector with as many rows as the number of calibrating variables"
	exit
									}								
						}	
** Check if there are missing values and do not consider these observations during the estimation**
qui su `touse'
if r(mean) != 1 {
	di in g "Note: missing values encountered. Rows with missing values are not included in the calibration procedure"
				}
*----------------------------
*	end preliminary checks	|
*----------------------------
						

*--------------------
*	define setup	|
*--------------------
*number of relevant observations:
qui count if `touse'
local N=r(N)
*generate a mata vector containing values that uniquely identify the observations in stata (by row):
gen `id'=_n
qui putmata `id' if `touse', replace

*create a mata matrix with the known totals
mata: `t'=st_matrix("`total'")
*X=matrix of variables to be calibrated
qui putmata `X'=(`varlist') if `touse', replace
*s=vector of survey weights
qui putmata `s'=(`sweight') if `touse', replace
**Compute survey totals using survey weights
mata `tp'=`X''*`s'
**compute the vector of differences**
mata: `difft'=(`t'-`tp')

*------------------------------------
*	Chi-square distance function	|
*------------------------------------
if ("`dfunction'" =="chi2") {
mata: `m'=(`X'':*`s'')*`X'
mata: `lm'=qrinv(`m')*`difft'
mata: `u'=(`lm''*`X'')
**w=matrix of new weight
mata: `w'=`s':*(1:+(`u''))
qui getmata `nweight'=`w', id(`id') replace
							}

*--------------------------------
*	Other distance functions	|
*--------------------------------
if (("`dfunction'" =="ds") | ("`dfunction'" =="a") | ("`dfunction'" =="b") | ("`dfunction'" =="c") | ("`dfunction'"=="mchi2"))	{ 
tempname alpha num den g dg H G lm last xlmh xlmg nc pw to ok lmp lma lms w1 w0 w mlowb mupb to vfun
*generate starting values from the chi-squared distance function if no starting values have been specified*
if ("`svalues'" == "") {
	mata: `m'=(`X'':*`s'')*`X'
	mata: `lmp'=qrinv(`m')*`difft'
						}				
else 	{
	mata: `lmp'=st_matrix("`svalues'")
		}
	*save starting values:
	mata `lms'=`lmp'	
*
local i=1
local nt=0
mata: `fun'=0

if ("`dfunction'" =="mchi2") {
	mata: `w'=`s'
	mata: `xlmh'=1
	mata: `to'=`tp'
	mata: `m'=(`X'':*`s'')*`X'
	mata: `lmp'=qrinv(`m')*`difft'
	mata: `mlowb'=`s':*`lowbound'
	mata: `mupb'=`s':*`upbound'
							}
*	
	while `i'<=`niter'			{
*
		if ("`dfunction'" =="ds") 			{ 
			local alpha=(`upbound'-`lowbound')/(`upbound'-`upbound'*`lowbound')
			mata: `num'=`lowbound'*(`upbound'-1):+`upbound'*(1-`lowbound')*exp((`X'*`lmp')*`alpha')
			mata: `den'=(`upbound'-1):+(1-`lowbound')*exp((`X'*`lmp')*`alpha')
			mata: `g'=`num':/`den'
			mata: `dg'=`g':*(`upbound':-`g'):*((1-`lowbound')*`alpha'*exp((`X'*`lmp')*`alpha'):/`den')
			mata: `H'=-(`X'':*(`s'':*`dg''))*`X'
			mata: `G'=`X''*(`s':*(`g':-1))
			mata: `lma'=`lmp'-qrinv(`H')*(`difft'-`G')
			mata  `lmp'=`lma'
			mata: `w'=`g':*`s'
			mata: `fun_o'=`fun'
			mata: `fun'=(`upbound' :-`g'):*(ln((`upbound' :-`g'):/(`upbound'-1)))+(`g':-`lowbound'):*(ln((`g':-`lowbound'):/(1-`lowbound')))
											}
									
		if ("`dfunction'" =="a") 			{ 
			mata: `xlmh'=((1:-((`X'*`lmp'):/2)):^(-3))
			mata: `H'=-(`X'':*(`s'':*`xlmh''))*`X'
			mata: `xlmg'=((1:-((`X'*`lmp'):/2)):^(-2)):-1
			mata: `G'=`X''*(`s':*`xlmg')
			mata: `lma'=`lmp'-qrinv(`H')*(`difft'-`G')
			mata  `lmp'=`lma'
			mata: `w'=((1:-((`X'*`lma'):/2)):^(-2)):*`s'
			mata: `fun_o'=`fun'
			mata: `fun'=2:*(sqrt(`w')-sqrt(`s')):^(2)
										}

	
		if ("`dfunction'" =="b") 			{ 
			mata: `xlmh'=((1:-(`X'*`lmp')):^(-2))
			mata: `H'=-(`X'':*(`s'':*`xlmh''))*`X'
			mata: `xlmg'=((1:-(`X'*`lmp')):^(-1)):-1
			mata: `G'=`X''*(`s':*`xlmg')
			mata: `lma'=`lmp'-qrinv(`H')*(`difft'-`G')
			mata  `lmp'=`lma'
			mata: `w'=((1:-(`X'*`lma')):^(-1)):*`s'
			mata: `fun_o'=`fun'
			mata: `fun'=-`s':*log(`w':/`s')+`w'-`s'			
											}
									
		
		if ("`dfunction'" =="c") 			{ 
			mata: `xlmh'=exp(`X'*`lmp')
			mata: `H'=-(`X'':*(`s'':*`xlmh''))*`X'
			mata: `xlmg'=(exp(`X'*`lmp')):-1
			mata: `G'=`X''*(`s':*`xlmg')
			mata: `lma'=`lmp'-qrinv(`H')*(`difft'-`G')
			mata  `lmp'=`lma'
			mata: `w'=`s':*exp(`X'*`lma')
			mata: `fun_o'=`fun'
			mata: `fun'=`w':*log(`w':/`s')-`w'+`s'			
											}

		if ("`dfunction'" =="mchi2")	{ 
			mata: `w0'=`w' 	
			mata: `tp'=`X''*`w0'
			mata: `difft'=`t'-`tp'

			mata: `xlmg'=(1:+(`X'*`lmp'):*`xlmh'):-1
			mata: `H'=-(`X'':*(`w0':*`xlmh')')*`X'
			mata: `G'=`X''*((`w0':*`xlmh'):*`xlmg')
			mata: `lma'=`lmp'-qrinv(`H')*(`difft'-`G')
			mata  `lmp'=`lma'
			mata: `w'=(1:+((`X'*`lmp'):*`xlmh')):*`w0'

			mata: `xlmh'=0*(`w':<`mlowb') + 0*(`w':>`mupb')+(`w':>=`mlowb':&`w':<=`mupb'):*1			
			mata: `w'=`mlowb':*(`w':<`mlowb')+`mupb':*(`w':>`mupb')+(`w':>=`mlowb' :& `w':<=`mupb'):*`w'
			*the second criterion to asses convergence is not active for the modified chi-squared:
			mata: `fun'=1
			mata `okay'=1
			}
						
	*----------------------------
	*	check for convergence	|
	*----------------------------
		*1) Calibrated totals must be (almost) the same as the external ones (the difference depends on the tolerance level)
		*vector of new totals:
		mata `pw'=`X''*`w'
		*vector of differeces between the estimated totals and the external totals
		mata `err'=`t'-`pw'
		*vector with the tolerance level
		mata `to'=J(`nvar',1,`tolerance')
		*ok is scalar indicating the number of estimated totals whose difference with respect to the external totals is lower than the tolerance level
		mata `ok'=(((abs(`err'):<=`to')'*(abs(`err'):<=`to')):==`nvar')

		*2) For each observation the absolute variation of the distance function between 2 iterations has to be lower than the tolerance level
		if ("`dfunction'" !="mchi2") {		
		mata `too'=J(`N',1,`tolerance')
		mata `cfun'=abs((`fun':-`fun_o'))
		mata `okay'=(((`cfun':<=`too')'(`cfun':<=`too')):==`N')
									}
		mata: st_numscalar("`ok'",`ok')
		mata: st_numscalar("`okay'",`okay')
		
		if (`ok'==1) &  (`okay'==1) & (`nt'==0) {
		display in gr  "Iteration " in yel `i' in gr " - Converged"
		scalar `last'=`i'
		scalar `nc'=0
		continue, break
												}
	
		if (`ok'==1) &  (`okay'==1) & (`nt'>0) {
		display in gr "Converged, new starting values saved in the return list"
		scalar `last'=`i'
		scalar `nc'=0
		continue, break
							}
							
		if (`i'==`niter') & (`nt'<=`ntries') & (`nt'==0) & (`ntries'>0) & (("`dfunction'" =="a") | ("`dfunction'" =="b") | ("`dfunction'" =="c") | ("`dfunction'" =="ds" & `rbounds'==0))	{
		display in gr  "Iteration " in yel `i' in gr " Not Converged within the maximum number of iterations, the algorithm now tries with new starting values up to " in yel `ntries' in gr " times:"
															}
		if (`i'==`niter') & (`nt'<=`ntries') & (`nt'==0) & (`ntries'>0) & (("`dfunction'" =="mchi2") | ("`dfunction'" =="ds" & `rbounds'==1))	{
		display in gr  "Iteration " in yel `i' in gr " Not Converged within the maximum number of iterations, the algorithm now tries with new random bounds up to " in yel `ntries' in gr " times:"
																																				}
		if (`i'==`niter') & (`nt'>=`ntries') & (`nt'!=0) & (`ntries'>0) & ("`dfunction'" =="ds" & `rbounds'==0) {
		display in red "Not Converged within the maximum number of tries. Try to: activate the rbounds() option, increase the number of maximum tries or the number of maximum iterations"
		scalar `nc'=1
		continue, break
																												}
		if (`i'==`niter') & (`nt'>=`ntries') & (`nt'!=0) & (`ntries'>0) {
		display in red "Not Converged within the maximum number of tries. Try to increase the number of maximum tries and/or the number of maximum iterations"
		scalar `nc'=1
		continue, break
									}
									
		if (`i'==`niter') & (`nt'>=`ntries') & (`nt'==0) & (`ntries'==0) {
			display in gr  "Iteration " in yel `i'	
			display in red "Not Converged within the maximum number of iterations. Try to use the NTRIES option"
			scalar `nc'=1
			continue, break
									}

		if (`i'==`niter') & (`nt'<=`ntries')	{
			local nt=`nt'+1
			if ("`dfunction'" !="ds" & "`dfunction'" !="mchi2") {			
			display in gr  "try number " in ye `nt'
			}
			local i=1
			*New starting values are a random function of the chi-squared lagrange multiplayers 
			mata: `lmp'=`lms':*(1:+((-1:+((2):*uniform(`nvar',1)))))

			if ("`dfunction'" =="ds" & `rbounds'==1) {
				local lowbound=`llb'+(`ulb'-`llb')*runiform()
				local upbound= `lub'+(`uub'-`lub')*runiform()
				display in gr  "try number " in ye `nt' in gr  " current bounds " in ye round(`lowbound',.001) in gr " - " in ye round(`upbound', .001)
													}
			if ("`dfunction'" =="ds" & `rbounds'==0) {
			display in gr  "try number " in ye `nt'			
													}
			if ("`dfunction'" =="mchi2") 	{
				local lowbound=`llb'+(`ulb'-`llb')*runiform()
				local upbound= `lub'+(`uub'-`lub')*runiform()
				mata: `tp'=`X''*`s'
				mata: `difft'=`t'-`tp'
				mata: `xlmh'=1
				mata: `m'=(`X'':*`s'')*`X'
				mata: `lmp'=luinv(`m')*`difft'
				mata: `w'=`s'
				mata: `mlowb'=`s':*`lowbound'
				mata: `mupb'=`s':*`upbound'
				display in gr  "try number " in ye `nt' in gr  " current bounds " in ye round(`lowbound',.001) in gr " - " in ye round(`upbound', .001)
										}
													}
												
									
		if (`i'<=`niter') & (`nt'==0) & ("`dfunction'"!="mchi2") {
		display in gr  "Iteration " in yel `i'
		}
		if (`i'<=`niter') & (`nt'==0) & ("`dfunction'" =="mchi2") {
		display in gr  "Iteration " in yel `i'
		}		
		if `i'<`niter' {
		local i=`i'+1
						}
														}
}
*------------------
* end of the loop |
*------------------ 
if ("`dfunction'" =="mchi2") {
		if `nc'!=1 	{
			qui getmata `nweight'=`w', id(`id') replace
			*display results:
			mata `ttp'=`X''*`w'
			mata `tp'=`X''*`s'
			mata: st_matrix("`ttp'", `ttp')
			mata: st_matrix("`lmp'", `lmp')
			mata: st_matrix("`tp'", `tp')
			matrix `results'=[`tp', `ttp']
			matrix rownames `results'=`varlist'
			matrix colnames `results'=Original New
			display ""
			display as ye "Survey and calibrated totals"
			matlist `results', format(%15.0f) rowtitle(Variable) border(top bottom) noblank  
			display as ye "Note: Modified Chi-Squared distance function used"
			display as green "Current bounds: upper=" as ye round(`upbound', .0001) as gr " - lower=" as ye round(`lowbound', .0001)
			*fill in return list:
			mata: st_rclear()
			return matrix NewTotals=`ttp'
			return matrix lm=`lmp'
			return matrix SurveyTotals=`tp'
			return scalar nobs=`N'
			return scalar lowbound=`lowbound'
			return scalar upbound=`upbound'
			return local var "`varlist'"
			return local dfunction "`dfunction'"
			return local command "sreweight"
					}
	if `nc'==1  {
			mata: st_matrix("`tp'", `tp')
			mata: st_rclear()
			mata `tp'=`X''*`s'
			return matrix SurveyTotals=`tp'
			return scalar ntries = `nt'
			return local converged "no"
			return local var "`varlist'"
			return local dfunction "`dfunction'"
			return local command "sreweight"
				}
							}
if ("`dfunction'" =="chi2") {
	*display results:
	qui su `nweight'
		if r(min)<0{
			display as re "New weights obtained from the `dfunction' distance function are negative, try with other distance functions"
			*fill in return list:
			return local negative "yes"
					}
		if r(min)>=0{
			*display results:
			mata `ttp'=`X''*`w'
			mata: st_matrix("`ttp'", `ttp')
			mata: st_matrix("`lm'", `lm')
			mata: st_matrix("`tp'", `tp')
			matrix `results'=[`tp', `ttp']
			matrix rownames `results'=`varlist'
			matrix colnames `results'=Original New
			display ""
			display as ye "Survey and calibrated totals"
			matlist `results', format(%15.0f) rowtitle(Variable) border(top bottom) noblank  
			display as ye "Note: Chi-Squared distance function used"
			
			*fill in return list:
			mata: st_rclear()
			return matrix NewTotals=`ttp'
			return matrix lm=`lm'
			return matrix SurveyTotals=`tp'
			return scalar nobs=`N'
			return local negative "no"
			return local var "`varlist'"
			return local dfunction "`dfunction'"
			return local command "sreweight"
					}
							}

if ("`dfunction'" =="a") | ("`dfunction'" =="b") | ("`dfunction'" =="c") | ("`dfunction'" =="ds") {
		if `nc'!=1 	{
			qui getmata `nweight'=`w', id(`id') replace
			*display results:
			mata `ttp'=`X''*`w'
			mata: st_matrix("`ttp'", `ttp')
			mata: st_matrix("`lms'", `lms')
			mata: st_matrix("lma", `lma')
			mata: st_matrix("`tp'", `tp')
			matrix `results'=[`tp', `ttp']
			matrix rownames `results'=`varlist'
			matrix colnames `results'=Original New
			display ""
			display as ye "Survey and calibrated totals"
			matlist `results', format(%15.0f) rowtitle(Variable) border(top bottom) noblank  
			display as ye "Note: type-`dfunction' distance function used"
				if ("`dfunction'" =="ds") 	{ 
					display as green "Current bounds: upper=" as ye round(`upbound', .0001) as gr " - lower=" as ye round(`lowbound', .0001)
											}
			*fill in return list:
			mata: st_rclear()				
			return matrix lm=lma
			return matrix SurveyTotals=`tp'
			return matrix NewTotals=`ttp'
			return matrix StartingValues=`lms'
			return scalar nlast_iter = `last'
			return scalar nmaxiter = `niter'
			return scalar nobs=`N'
				if ("`dfunction'" =="ds")	{ 
					return scalar lowbound=`lowbound'
					return scalar upbound=`upbound'
											}
			return local var "`varlist'"
			return local dfunction "`dfunction'"
			return local converged "yes"
			return local command "sreweight"
							}				
		if `nc'==1  {
			mata: st_matrix("`tp'", `tp')
			mata: st_rclear()
			return matrix SurveyTotals=`tp'
			return scalar ntries = `nt'
			return local converged "no"
			return local var "`varlist'"
			return local dfunction "`dfunction'"
			return local command "sreweight"
					}
}
end
