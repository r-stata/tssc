// Author: Hong Il Yoo (h.i.yoo@durham.ac.uk) 
// HIY 1.0.0 08 April 2016
program bineq
	version 12.1
	if replay() {
		if (`"`e(cmd)'"' != "bineq") error 301
		Replay `0'
	}
	else Estimate `0'
end

program define Estimate, eclass 
	version 12.1
	syntax varlist(numeric min=2 max=2) [if] [in] [, Alpha(real -1) Beta(real -1) Type(string) Level(cilevel)] 
	
	//define temporary variables and matrices
	tempname stats covdelta
	
	//initialize index type 
	if ("`type'" == "") local type aks
	if ("`type'" != "aks") & ("`type'" != "mld") {
		di as error "type(`type') must be either aks or mld."
		exit 198
	}
	
	//check alpha and beta for AKS are within the allowed range
	if (`alpha' == 0) | (`beta' == 0) {
		di as error "neither alpha(`alpha') nor beta(`beta') can be 0."
		exit 197
	}
	if (`alpha' > 0 & `beta' < 0) | (`alpha' < 0 & `beta' > 0) {
		di as error "alpha(`alpha') and beta(`beta') must have the same sign."
		exit 197	
	}
	if ("`type'" == "aks") {
		if (`=`alpha' + `beta'' > 1 ) {
			di as error "AKS index: alpha(`alpha') + beta(`beta') must not exceed 1."
			exit 197	
		}
	}
	if ("`type'" == "mld") {
		if (`alpha' < 0) | (`beta' < 0) {
			di as error "MLD index: both alpha(`alpha') and beta(`beta') must be positive."
			if (`alpha' < 0) {
				di as error "alpha(`alpha') is reset to alpha(`=abs(`alpha')')."	
				local alpha = abs(`alpha')
			}
			if (`beta' < 0) {
				di as error "beta(`beta') is reset to beta(`=abs(`beta')')."	
				local beta = abs(`beta')	
			}
		}
	}	
	
	//define the estimation sample
	marksample touse
	markout `touse' `varlist'
	
	//define macros for two attributes (x1 x2)
	gettoken x y: varlist		
		
	//compute inequality indices and covariance matrix
	preserve
	qui keep if `touse'
	if ("`type'" == "aks") {
		mata: aks()
		matrix colnames `stats' = `x' `y' kappa
		matrix rownames `covdelta' = `x' `y' kappa
		matrix colnames `covdelta' = `x' `y' kappa
	}
	if ("`type'" == "mld") {
		mata: mld()
		matrix colnames `stats' = `x' `y' 
		matrix rownames `covdelta' = `x' `y' 
		matrix colnames `covdelta' = `x' `y' 		
	}
	restore
	
	//return estimation results
	ereturn post `stats' `covdelta', esample(`touse')
	qui count if e(sample) 
	ereturn scalar N = r(N)
	ereturn scalar alpha = `alpha'
	ereturn scalar beta = `beta'	
	ereturn local cmd bineq
	ereturn local alphavar `x'
	ereturn local betavar `y'	
	if ("`type'" == "aks") ereturn local type aks
	if ("`type'" == "mld") ereturn local type mld		
	
	//report estimation results
	Replay, level(`level')
end

//Display results in Stata format
program Replay
	syntax [, Level(cilevel)]	
	local a = e(alpha)
	local b = e(beta)
	local ab = `a' + `b'	
 	di as text "Decomposition of Bidimensional `=strupper("`e(type)'")' Index (alpha = `=e(alpha)', beta = `=e(beta)', obs = `=e(N)')"
	if ("`e(type)'" == "aks") { 
		local overall 1-exp((`a'/`ab')*ln(1-_b[`e(alphavar)']) + (`b'/`ab')*ln(1-_b[`e(betavar)']) + (1/`ab')*ln(_b[kappa]))
		nlcom (`e(alphavar)': _b[`e(alphavar)']) (`e(betavar)': _b[`e(betavar)']) (kappa: _b[kappa]) (overall: `overall'), noheader level(`level')
	}
	else {
		local overall 1-exp((`a'/`ab')*ln(1-_b[`e(alphavar)']) + (`b'/`ab')*ln(1-_b[`e(betavar)'])) 
		nlcom (`e(alphavar)': _b[`e(alphavar)']) (`e(betavar)': _b[`e(betavar)']) (overall: `overall'), noheader level(`level')
	}
	di as text "`e(alphavar)' (`e(betavar)') is the unidimensional `=strupper("`e(type)'")' index of inequality in the namesake variable."
	if ("`e(type)'" == "aks") di as text "kappa is a measure of association between the two attributes." 
	di as text "overall is the bidmensional `=strupper("`e(type)'")' index of inequality that aggregates the above components." 
end

//AKS program 
version 12.1
mata: 
function aks() 
{
//read things from Stata
st_view(x,.,st_local("x"))
st_view(y,.,st_local("y"))
alpha = strtoreal(st_local("alpha"))
beta = strtoreal(st_local("beta"))

//weight x and y by inequality aversion, and interact the weighted x and y 
xa = x :^ alpha
yb = y :^ beta
xayb = xa :* yb

//compute sample moments
mux = mean(x)
muy = mean(y)
muxa = mean(xa)
muyb = mean(yb)
muxayb = mean(xayb)

//store sample moments in row vector s
s = mux, muy, muxayb, muxa, muyb 

//compute equality indices and measure of association
delta = s[4]^(1/alpha)/s[1] \ ///
		s[5]^(1/beta)/s[2] \ /// 
		s[3]/(s[4]*s[5])

//compute inequality indices and measure of association
ineq = 1-delta[1] \ 1-delta[2] \ delta[3]

//compute variance-covariances of sample moments
Z1 = x :- mux
Z2 = y :- muy
Z3 = xayb :-muxayb
Z4 = xa :- muxa
Z5 = yb :- muyb
Z = Z1, Z2, Z3, Z4, Z5
n = rows(x)
C = Z'*Z / n

//evaluate Jacobian
J=J(3,5,0)
J[1,1] = -(s[4]^(1/alpha))/( s[1]^2)
J[1,4] =  ( s[4]^( (1/alpha) - 1))/(alpha*s[1]) 
J[2,2] = -(s[5]^(1/beta))/( s[2]^2)
J[2,5] =  ( s[5]^( (1/beta) - 1))/(beta*s[2]) 
J[3,3] = (s[4]*s[5])^(-1)
J[3,4] = -s[3]/ ( s[4]*s[4]*s[5] )
J[3,5] = -s[3]/ ( s[4]*s[5]*s[5] )

//compute covariance matrix of indices and measure of association
covdelta = J*C*J' / n

//report results as Stata matrices
st_matrix(st_local("stats"), ineq')
st_matrix(st_local("covdelta"), covdelta)
}
end 

//Mean logarithmic deviation program 
version 12.1
mata: 
function mld() 
{
//read things from Stata
st_view(x,.,st_local("x"))
st_view(y,.,st_local("y"))

//compute sample moments
lnx = ln(x)
lny = ln(y)
mux = mean(x)
muy = mean(y)
mulnx = mean(lnx)
mulny = mean(lny)

//store sample moments in row vector s
s = mux, muy, mulnx, mulny 

//compute equality indices 
delta = exp(s[3] - ln(s[1])) \ exp(s[4] - ln(s[2])) 

//compute inequality indices
ineq = 1-delta[1] \ 1-delta[2] 

//compute variance-covariances of sample moments
Z1 =   x :- mux
Z2 =   y :- muy
Z3 = lnx :- mulnx
Z4 = lny :- mulny
Z = Z1, Z2, Z3, Z4
n = rows(x)
C = Z'*Z / n

//evaluate Jacobian
J=J(2,4,0)
J[1,1] = -exp(s[3] - ln(s[1])) / s[1]
J[1,3] =  exp(s[3] - ln(s[1]))
J[2,2] = -exp(s[4] - ln(s[2])) / s[2]
J[2,4] =  exp(s[4] - ln(s[2]))

//compute covariance matrix of indices
covdelta = J*C*J' / n

//report results as Stata matrices
st_matrix(st_local("stats"), ineq')
st_matrix(st_local("covdelta"), covdelta)
}
end

exit
