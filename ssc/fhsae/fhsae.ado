*! fhsae April 28, 2018
* Translated into Stata from R's SAE package by Molina and Marhuenda 
* Paul Corral (World Bank Group - Poverty and Equity Global Practice)
* William Seitz (World Bank Group - Poverty and Equity Global Practice)
* Joao Pedro de Azevedo (World Bank Group - Poverty and Equity Global Practice)
* Minh Cong Nguyen (World Bank Group - Poverty and Equity Global Practice)


* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.


cap set matastrict off
clear mata
program define fhsae, eclass
	version 11.2
	#delimit ;
	syntax varlist (min=1 numeric fv) [if] [in],
	REvar(varlist max=1 numeric) method(string)
	[FHpredict(string)
	 precision(real 1e-15)
	 maxiter(int 100)
	 FHSEpredict(string)
	 FHCVpredict(string)
	 DSEpredict(string)
	 DCVpredict(string)
	 AREApredict(string)
	 GAMMApredict(string)
	 OUTsample
	 NONEGative];
#delimit cr		
set more off

if upper("`method'")=="CHANDRA"{
	_fAyHeRRiot `varlist', revar(`revar') fhpredict(`fhpredict') fhsepredict(`fhsepredict') ///
	fhcvpredict(`fhcvpredict') dsepredict(`dsepredict') dcvpredict(`dcvpredict') ///
	gammapredict(`gammapredict') `outsample' `nonegative' areapredict(`areapredict')
}
else{
marksample touse11
tokenize `varlist'
local depvar `1'
macro shift
local indeps `*'

//TEMP VARS AND NAMES
tempname beta vcov tomata s2u loglike aic bic numobs aicc
tempvar lev yhat res touse out

//Create variable for out of sample prediction
if("`outsample'"!=""){
	qui:gen `out' = `depvar'==.
	foreach x of local indeps{
		qui:replace `out' = 0 if `x' == .
	}
}



//Remove collinear variables
_rmcoll `indeps', forcedrop
local indeps `r(varlist)'

local methods FH REML ML
local method = upper(trim("`method'"))

local okmethod: list methods & method
if ("`okmethod'"==""){
	dis as error "Option given under method, not valid" ///
	"Valid methods: `methods'; chandra"
	error 345566
}

//regression
noi: dis in green "======================================================================================"
noi: dis in yellow "Fay-Herriot Small Area Estimation" 
noi: dis in green "======================================================================================"

//Send vectors to mata
qui:sum `revar', d
local p50=r(p50)
local `tomata' revar region depvar indeps

foreach x of local `tomata'{
		mata:st_view(`x'=.,.,"``x''", "`touse11'")	
	}

mata: _Fh=_fhmoment(depvar,indeps,revar,`p50')
mata: st_matrix("`beta'",*(_Fh[1,1]))
mata: st_matrix("`vcov'",*(_Fh[1,2]))
mata: fh = *(_Fh[1,3])
mata: dse= sqrt(revar)
mata: dcv= 100*(dse:/depvar)
mata: st_matrix("`loglike'",*(_Fh[1,4]))
mata: st_matrix("`aic'",*(_Fh[1,5]))
mata: st_matrix("`aicc'",*(_Fh[1,11]))
mata: st_matrix("`bic'",*(_Fh[1,6]))
mata: fhse = sqrt(*(_Fh[1,7]))
mata: fhcv = 100*(fhse:/fh)
mata: gamma = *(_Fh[1,8])
mata: st_matrix("`s2u'", *(_Fh[1,9]))
mata: st_matrix("`numobs'", *(_Fh[1,10]))


noi{
	 mat rownames `beta' = `indeps' _cons
	 mat `beta' = `beta''
	 mat rownames `vcov' = `indeps' _cons
	 mat colnames `vcov' = `indeps' _cons
}
 
	if("`outsample'"!=""){
		mata: st_view(_x1=.,., "`indeps'","`out'")
		noi:mata: _out = _fhout(_x1,*(_Fh[1,1]),*(_Fh[1,2]),*(_Fh[1,9]))
		mata: fh_out      = *(_out[1,1])
		mata: fhse_out    = *(_out[1,2])
		mata: fhcv_out    = *(_out[1,3])
	 }
	 
	 local predicts fh fhse fhcv dse dcv gamma
	 foreach x of local predicts{
		if("``x'predict'"!=""){
			local nm: list sizeof `x'predict
			if (`nm'>1){
				display as error "Only one variable name for option `x'predict"
				error 202020202
			}
			qui:gen ``x'predict' = .
			mata: st_store(.,tokens("``x'predict'"),"`touse11'",`x')

			if(("`x'"=="fh"|"`x'"=="fhse"|"`x'"=="fhcv") & "`outsample'"!=""){
				mata: st_store(.,tokens("``x'predict'"),"`out'",`x'_out)
			}	
		}	 
	 }


//POST RESULTS
ereturn post `beta' `vcov', depname(`depvar') esample(`touse11')

noi ereturn display

// E returns
ereturn scalar N           = `numobs'[1,1]
ereturn scalar sigma2u     = `s2u'[1,1]
ereturn scalar loglike     = `loglike'[1,1]
ereturn scalar aic         = `aic'[1,1]
ereturn scalar aicc        = `aicc'[1,1]
ereturn scalar bic         = `bic'[1,1]

di as text "{hline 61}"
display in ye "`method' Model diagnostics"
di as text "{hline 61}"
display in gr "Number of observations" _col(45) in gr "=" _col(50) in ye  e(N)
display in gr "Estimated random effects variance" _col(45) in gr "=" _col(50) in ye e(sigma2u)
display in gr "Log Likelihood" _col(45) in gr "=" _col(50) in ye e(loglike)
display in gr "AIC" _col(45) in gr "=" _col(50) in ye e(aic)
display in gr "AICc" _col(45) in gr "=" _col(50) in ye e(aicc)
display in gr "BIC" _col(45) in gr "=" _col(50) in ye e(bic)
di as text "{hline 61}"
}
end

program define _fAyHeRRiot, eclass
	version 11.2
	#delimit ;
	syntax varlist (min=1 numeric fv) [if] [in],
	REvar(varlist max=1 numeric)
	[FHpredict(string)
	FHSEpredict(string)
	FHCVpredict(string)
	DSEpredict(string)
	DCVpredict(string)
	AREApredict(string)
	GAMMApredict(string)
	OUTsample
	NONEGative];
#delimit cr		
set more off

marksample touse11
tokenize `varlist'
local depvar `1'
macro shift
local indeps `*'

//TEMP VARS AND NAMES
tempname beta vcov tomata s2u
tempvar lev yhat res touse out

//Create variable for out of sample prediction
if("`outsample'"!=""){
	qui:gen `out' = `depvar'==.
	foreach x of local indeps{
		qui:replace `out' = 0 if `x' == .
	}
}



//Remove collinear variables
_rmcoll `indeps', forcedrop
local indeps `r(varlist)'



//regression
noi: dis in green "=============================================================================="
noi: dis in yellow "Fay-Herriot Model" 
noi: dis in green "=============================================================================="

noi: regress	`depvar'  `indeps' if `touse11'==1
scalar er2a=e(r2_a)
scalar er2=e(r2)
scalar ef = e(F)
scalar enum = e(N)

	
//Predict vectors
qui{
gen `touse'=e(sample)
predict `lev', hat
predict `yhat', xb
predict `res', res

local `tomata' lev res revar region depvar indeps

	foreach x of local `tomata'{
		mata:st_view(`x'=.,.,"``x''", "`touse'")	
	}
	
	//Send to mata for FH
	noi{
	mata: _Fh = _fh(depvar, indeps, revar, res, lev)
	mata: fhse     = *(_Fh[1,1])
	mata: fhcv     = *(_Fh[1,2]) 
	mata: dse      = *(_Fh[1,3]) 
	mata: dcv      = *(_Fh[1,4]) 
	mata: st_matrix("`beta'",*(_Fh[1,5]))
	mata: st_matrix("`vcov'",*(_Fh[1,6]))
	mata: fh      = *(_Fh[1,7])
	mata: area    = *(_Fh[1,8]) 
	mata: st_matrix("`s2u'", *(_Fh[1,9]))
	mata: gamma   = *(_Fh[1,10])
	}
	 
	 noi{
	 mat rownames `beta' = `indeps' _cons
	 mat `beta' = `beta''
	 mat rownames `vcov' = `indeps' _cons
	 mat colnames `vcov' = `indeps' _cons
	 }
	
	if("`outsample'"!=""){
		mata: st_view(_x1=.,., "`indeps'","`out'")
		noi:mata: _out = _fhout(_x1,*(_Fh[1,5]),*(_Fh[1,6]),*(_Fh[1,9]))
		mata: fh_out      = *(_out[1,1])
		mata: fhse_out    = *(_out[1,2])
		mata: fhcv_out    = *(_out[1,3])
	 }
	 
	 local predicts fh fhse fhcv dse dcv area gamma
	 foreach x of local predicts{
		if("``x'predict'"!=""){
			local nm: list sizeof `x'predict
			if (`nm'>1){
				display as error "Only one variable name for option `x'predict"
				error 202020202
			}
			gen ``x'predict' = .
			mata: st_store(.,tokens("``x'predict'"),"`touse'",`x')

			if(("`x'"=="fh"|"`x'"=="fhse"|"`x'"=="fhcv") & "`outsample'"!=""){
				mata: st_store(.,tokens("``x'predict'"),"`out'",`x'_out)
			}	
		}	 
	 }
	 	
	 ereturn post `beta' `vcov', depname(`depvar') esample(`touse')
	 noi display in yellow "GLS coefficients"
	 noi ereturn display
	 ereturn scalar sigma2u = `s2u'[1,1]	 
	 ereturn scalar r2_a = er2a
	 ereturn scalar r2   = er2
	 ereturn scalar F    = ef
	 ereturn scalar N    = enum
	 
}
end


mata

function _fhmoment(y, x, sigma2, Aes){
	pointer(real matrix) rowvector _fhval
	_fhval = J(1,11,NULL)
	x=x,J(rows(x),1,1)
	noneg = (st_local("nonegative")!="")
	method = st_local("method")
	
	if (method=="FH") xb = _fhopti(y,x,sigma2,Aes)
	if (method=="ML") xb = _mlopti(y,x,sigma2,Aes)
	if (method=="REML") xb = _remlopti(y,x,sigma2,Aes)
	_beta    = *xb[1,1]
	_varbeta = *xb[1,2]
	Aes      = *xb[1,3]
	
	yhat     = quadcross(x',_beta)
	if (noneg==1) yhat = yhat:*(yhat:>0)	 
	resi     = y-yhat	
	_eblup   = yhat + (Aes:*(1:/(Aes:+sigma2)):*resi)

	//Goodness of fit
	m = rows(y)
	p = cols(x)
	_loglike = (-.5)*quadsum(log(2*pi()*(Aes:+sigma2))+((resi:^2):/(Aes:+sigma2)))
	_aic     = (-2)*_loglike+2*(p+1)
	_bic     = (-2)*_loglike+(p+1)*log(m)
	_aicc    = _aic + (2*(p^2)+2*p)/(m-p-1)

	//MSE
	vi = (1:/(Aes:+sigma2))
	bd = (sigma2:/(Aes:+sigma2))
	sumad2 = quadsum(vi:^2)
	sumad  = quadsum(vi)
	
	if (method=="FH"){		
		vara   = 2*m/(sumad^2)
		b      = 2*(m*sumad2 -(sumad^2))/(sumad^3)
	
		g1d = sigma2:*(1:-bd)
		g2d = (bd:^2):*quadrowsum((quadcross(x',(_varbeta)):*x))
		g3d = (bd:^2):*(vara:/(Aes:+sigma2))
		
		_mse = g1d + g2d + 2*g3d - b*(bd:^2)
	}
	if (method=="ML"){
		vara    = 2/sumad2	
		b       = (-1)*quadsum(diagonal(quadcross(_varbeta,quadcross(x,(vi:^2),x))))/sumad2
		g1d     = sigma2:*(1:-bd)	
		g2d     = (bd:^2):*quadrowsum((quadcross(x',(_varbeta)):*x))
		g3d     = (bd:^2):*(vara:/(Aes:+sigma2))
		
		_mse    = g1d + g2d + 2*g3d - b*(bd:^2)
	}
	if (method=="REML"){
		vara = 2/sumad2
		g1d  = sigma2:*(1:-bd)
		g2d  = (bd:^2):*quadrowsum((quadcross(x',(_varbeta)):*x))
		g3d  = (bd:^2):*(vara:/(Aes:+sigma2))
		
		_mse    = g1d + g2d + 2*g3d
	}
	_fhval[1,1] = &(_beta)    //beta
	_fhval[1,2] = &(_varbeta) //vcov
	_fhval[1,3] = &(_eblup)   //eblup fh estimates
	_fhval[1,4] = &(_loglike) //loglikelihood
	_fhval[1,5] = &(_aic)     //AIC
	_fhval[1,6] = &(_bic)     //BIC
	_fhval[1,7] = &(_mse)     //MSE
	_fhval[1,8] = &(bd)       //Gamma
	_fhval[1,9] = &(Aes)      //sigma2u
	_fhval[1,10] = &(m)       //Num obs
	_fhval[1,11] = &(_aicc)   //AICc
	
	return(_fhval)
}

function _fhout(_x1,_bgls,_vcovgls,sigma2u){
	pointer(real matrix) rowvector _fhout1
	_fhout1 = J(1,3,NULL)
	_x1 = _x1,J(rows(_x1),1,1)
	noneg = (st_local("nonegative")~="")
	
	yhat = quadcross(_x1',_bgls)
	
	if (noneg==1) yhat = yhat:*(yhat:>0)
	
	_fhout1[1,1] = &(yhat)	
	_fhout1[1,2] = &(sqrt(quadrowsum((quadcross(_x1',(_vcovgls)):*_x1)):+ sigma2u))
	_fhout1[1,3] = &(100*((*_fhout1[1,2]):/(*_fhout1[1,1])))	
		
	return(_fhout1)
}

function _fhopti(y,x,sigma2,Aes){
	pointer(real matrix) rowvector _fhout
	_fhout = J(1,3,NULL)

	prec = strtoreal(st_local("precision"))
	diff = prec + 1
	m = rows(y)
	p = cols(x)
	maxiter = strtoreal(st_local("maxiter"))
	k=0

	while((diff>prec) &(k<maxiter)){
		k=k+1
		_varbeta = invsym(quadcross(x,(1:/(Aes[k]:+sigma2)),x))
		_beta    = quadcross(_varbeta,quadcross(x,(1:/(Aes[k]:+sigma2)),y))		
		resi     = y-quadcross(x',_beta)		
		s        = quadsum((resi:^2):*(1:/(Aes[k]:+sigma2))) - (m - p)
		F        = quadsum((1:/(Aes[k]:+sigma2)))
		Aes  = Aes,(Aes[k] +s/F)
		diff = abs((Aes[k+1] - Aes[k])/Aes[k])
	}
	if (diff>prec) display("CAUTION: Convergence not achieved")
	k=k+1
	Aes = max((Aes[k],0))
	_varbeta = invsym(quadcross(x,(1:/(Aes:+sigma2)),x))
	_beta    = quadcross(_varbeta,quadcross(x,(1:/(Aes:+sigma2)),y))
		
	_fhout[1,1] = &(_beta)
	_fhout[1,2] = &(_varbeta)
	_fhout[1,3] = &(Aes)
	return(_fhout)
}

function _mlopti(y,x,sigma2,Aes){
	pointer(real matrix) rowvector _fhout
	_fhout = J(1,3,NULL)

	prec = strtoreal(st_local("precision"))
	diff = prec + 1
	m = rows(y)
	p = cols(x)
	maxiter = strtoreal(st_local("maxiter"))
	k=0

	while((diff>prec) &(k<maxiter)){
		k=k+1
		vi = 1:/(Aes[k]:+sigma2)
		_varbeta = invsym(quadcross(x,(1:/(Aes[k]:+sigma2)),x))
		P  = diag(vi) -quadcross(quadcross(quadcross(x,diag(vi)),_varbeta)',quadcross(x,diag(vi)))
		Py = quadcross(P,y)
		s = (-.5)*quadsum(vi) + 0.5*quadcross(Py,Py)
		F = 0.5*quadsum(vi:^2)
		Aes = Aes,(Aes[k] +s/F)
		diff = abs((Aes[k+1] - Aes[k])/Aes[k])
	}
	if (diff>prec) display("CAUTION: Convergence not achieved")
	k=k+1
	Aes = max((Aes[k],0))
	_varbeta = invsym(quadcross(x,(1:/(Aes:+sigma2)),x))
	_beta    = quadcross(_varbeta,quadcross(x,(1:/(Aes:+sigma2)),y))

	_fhout[1,1] = &(_beta)
	_fhout[1,2] = &(_varbeta)
	_fhout[1,3] = &(Aes)
	return(_fhout)
}

function _remlopti(y,x,sigma2,Aes){
	pointer(real matrix) rowvector _fhout
	_fhout = J(1,3,NULL)

	prec = strtoreal(st_local("precision"))
	diff = prec + 1
	m = rows(y)
	p = cols(x)
	maxiter = strtoreal(st_local("maxiter"))
	k=0
	while((diff>prec) &(k<maxiter)){
		k=k+1
		vi = 1:/(Aes[k]:+sigma2)
		_varbeta = invsym(quadcross(x,(1:/(Aes[k]:+sigma2)),x))
		P  = diag(vi) -quadcross(quadcross(quadcross(x,diag(vi)),_varbeta)',quadcross(x,diag(vi)))
		Py = quadcross(P,y)
		
		s = (-.5)*quadsum(diag(P)) + 0.5*quadcross(Py,Py)
		F = 0.5*quadsum(diag(quadcross(P',P)))
		Aes = Aes,(Aes[k] +s/F)
		diff = abs((Aes[k+1] - Aes[k])/Aes[k])
	}
	if (diff>prec) display("CAUTION: Convergence not achieved")
	k=k+1
	Aes = max((Aes[k],0))
	_varbeta = invsym(quadcross(x,(1:/(Aes:+sigma2)),x))
	_beta    = quadcross(_varbeta,quadcross(x,(1:/(Aes:+sigma2)),y))

	_fhout[1,1] = &(_beta)
	_fhout[1,2] = &(_varbeta)
	_fhout[1,3] = &(Aes)
	
	return(_fhout)
}

function _fh(y, x, sigma2, eps, lv){
	pointer(real matrix) rowvector _fhval
	_fhval = J(1,10,NULL)
	x=x,J(rows(x),1,1)
	dof1 = cols(x)
	
	noneg = (st_local("nonegative")~="")

	//The shrinkage component
	delta = quadsum(eps:^2) - quadsum((sigma2:*(1:-lv)))
	sigma2u = delta/(rows(x)-dof1)
	if (sigma2u<0){
		sigma2u=0
		V=sigma2
	}
	else{
		V = sigma2:+sigma2u
	}
	b_gls    = _fheblup(V,x,y)
	_beta    = *b_gls[1,1]
	_varbeta = *b_gls[1,2]
	yhat     =  quadcross(x',_beta)
	if (noneg==1) yhat = yhat:*(yhat:>0)	

	//shrinkage estimator
	gamma = sigma2u:/(V)
	//EBLUP
	FH = (gamma:*y)+((1:-gamma):*yhat)
	//Random area effects
	a_eff = gamma:*(y-yhat)
	
	//MSE-estimate
	g1 = gamma:*sigma2
		
	g2 = ((1:-gamma):^2):*quadrowsum((quadcross(x',(_varbeta)):*x))
		vsig = 2*rows(x)/(quadsum(1:/V)^2)
	g3 = vsig:*((sigma2:^2):/(V:^3))
	
	mse_fh = g1+g2+(2:*g3)

	//FHSE
	_fhval[1,1] = &(sqrt(mse_fh))
	//FHCV
	_fhval[1,2] = &(100:*(sqrt(mse_fh):/FH))
	//DIRECT SE
	_fhval[1,3] = &(sqrt(sigma2))
	//DIRECT CV
	_fhval[1,4] = &(100:*(sqrt(sigma2):/y))
	//Betas
	_fhval[1,5] = &(_beta)
	//VCOV
	_fhval[1,6] = &(_varbeta)
	//FH
	_fhval[1,7] = &(FH)
	//Area effect
	_fhval[1,8] = &(a_eff)
	//Sigma2u
	_fhval[1,9] = &(sigma2u)
	//gamma
	_fhval[1,10] = &(gamma)
	
	return(_fhval)
}

function _fheblup(_v,_x,_y){
	pointer(real matrix) rowvector fhout
	fhout = J(1,2,NULL)

	_varbeta = invsym(quadcross(_x,(1:/_v),_x))
	_beta    = quadcross(_varbeta,quadcross(_x,(1:/_v),_y))
	
	fhout[1,1] = &(_beta)
	fhout[1,2] = &(_varbeta)
	return(fhout)
}


end
