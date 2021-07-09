*! version 0.1.0, Brent McSharry, 12july2013
* Risk adjusted exponentially weighted moving average chart
program define raewma, sortpreserve
version 10.1
syntax varlist(min=2 max=2 numeric) [if] [in] , Predicted(varname numeric) STartest(real) /*
		*/ [SMooth(real 0.01) Alpha1(real 0.05) Alpha2(real 0.01) XLABEL(passthru) YTITLE(passthru) YLABEL(passthru) LEGEND(passthru) RESolution(real 0.0000125)] 
	tempvar ewma_o ewma_p ewma_se cl1_ub cl1_lb cl2_ub cl2_lb cl touse
	mark `touse' `if' `in'
	markout `touse' `varlist' `predicted'
	local observed:word 1 of `varlist'
	local timevar:word 2 of `varlist'
	
	if (`smooth'<=0 | `smooth'>1) {
		di as error "smooth option must be (0,1]"
		return 125
	}
	if (`resolution'<0 | `resolution'>0.01) {
		di as error "resolution option must be [0,0.01]"
		return 125
	}
	if (`startest'<0 | `startest'>1) {
		di as error "smooth option must be [0,1]"
		return 125
	}
	qui count if `touse'
	local nobs `r(N)'
	if (`nobs'==0) {
		di as error "nobs observed"
		return 2000
	}
	gsort -`touse' `timevar'
	
	mata: getRaewma("`predicted'","`observed'",`nobs',`smooth',`startest',"`ewma_o'","`ewma_p'","`ewma_se,'", `resolution')
	qui {
	local z=invnormal(1-(`alpha2'/2))
		gen `cl' = `z'*`ewma_se'
		gen `cl2_ub' = `ewma_p' + `cl'
		gen `cl2_lb' = `ewma_p' - `cl'
		
		local z=invnormal(1-(`alpha1'/2))
		replace `cl' = `z'*`ewma_se'
		gen `cl1_ub' = `ewma_p' + `cl'
		gen `cl1_lb' = `ewma_p' - `cl'
	}
	list `cl2_ub' if `touse' & _n>5380
	twoway (rarea `cl2_lb' `cl2_ub' `timevar' if `touse', color(gs11)) /*
	*/ (rarea `cl1_lb' `cl1_ub' `timevar' if `touse', color(gs13)) /*
	*/ (line `ewma_o' `timevar' if `touse', pstyle(p1)) /*
	*/ , `xlabel' `ytitle' `ylabel' legend(rows(1) order(3 2 1) label(1 "`=100-`alpha2'*100'% CI") label(2 "`=100-`alpha1'*100'% CI") label(3 "Observed") `legend')
end

mata:
void getRaewma(string scalar expectVarname, 
	string scalar obsVarname,
	real scalar usedNobs,
	real scalar smooth,
	real scalar startVal,
	string scalar emwaObsName,
	string scalar emwaExpectName,
	string scalar emwaSeName,
	real scalar resolution)
{

	real colvector ewmaExp, ewmaObs, ewmaSe
	real rowvector smoothPow,usedPow
	real vector expectVar, colIndices
	real scalar oneMinusSm, j, k, len, currExp, currObs, expectJ, cumSeCalc, oIndx, eIndx, endPow, startExpect
	oneMinusSm = 1 - smooth
	oIndx = st_varindex(obsVarname)
	eIndx = st_varindex(expectVarname)
	smoothPow = getSmoothPow(smooth, usedNobs, resolution)
	endPow = cols(smoothPow)
	startExpect = 1
	len = st_nobs() 
	ewmaExp = J(len,1,.)
	ewmaObs = J(len,1,.)
	ewmaSe = J(len,1,.)
	expectVar = J(usedNobs,1,.)
	currExp = currObs = startVal
	for (j=1;j<=usedNobs;j++) 
	{
		currObs = ewmaObs[j,1] = _st_data(j,oIndx)*smooth + currObs *oneMinusSm
		expectJ = _st_data(j,eIndx)
		currExp = ewmaExp[j,1] = expectJ*smooth + currExp *oneMinusSm
		cumSeCalc = expectVar[j] = expectJ*(1-expectJ)
		
		if (j<=endPow) {
			usedPow = smoothPow[|1,(endPow+1-j) \ 1,endPow|]
		} 
		else {
			++startExpect
		}
		ewmaSe[j,1] = smooth*sqrt( usedPow * expectVar[|startExpect,1 \ j,1|])
	}
	(void) setbreakintr(0)
	colIndices = st_addvar("double", (emwaExpectName, emwaObsName, emwaSeName), 1)
	st_store(.,colIndices[1],ewmaExp)
	st_store(.,colIndices[2],ewmaObs)
	st_store(.,colIndices[3],ewmaSe)
	(void) setbreakintr(1)
}

//build lookup for power calculations (which tend to be computationally expensive)
real rowvector function getSmoothPow(real scalar smooth, real scalar length, real scalar resolution)
{
	real scalar i, oneMinusSm, oneMinusSmSq, currPow, nocols
	real rowvector returnVar
	
	oneMinusSm = (1-smooth)
	oneMinusSmSq = oneMinusSm^2
	nocols = ceil(ln(1-(1-resolution)^2*(1-oneMinusSmSq^(length+1)))/ln(oneMinusSmSq))-1
	if (nocols > length) {
		nocols = length
	}
	returnVar = J(1,nocols,.)
	currPow = returnVar[1,nocols] = 1
	for (i=nocols-1;i>0;i--) 
	{
		returnVar[1,i] = currPow = oneMinusSmSq * currPow
	}
	return(returnVar)
}
end
