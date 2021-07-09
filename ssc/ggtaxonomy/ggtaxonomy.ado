***************************************************************************
*! ggtaxonomy: Command for identifying your most suitable GG family model
* A tribute to Professor Álvaro Muñoz, in gratitude for his visit to Bogotá
* ado by Andrés González Rangel
* andres.gonzalez@iecas.org
* Updated version by Usama Bilal
* ubilal@jhmi.edu
*! version 0.9 17may2013
*! version 0.95 19aug2015
*! version 0.96 14sep2017 (ensuring backwards compatibility with STATA 15)
***************************************************************************

program define ggtaxonomy, nclass
	version 11.0
	syntax

* 1. Quality check
if regexm(e(cmd),"gamma") == 0 {
	di as error "You must run a gamma model, see help streg for more details"
	exit
}


* 2. Obtaining coefficients
matrix vcov=e(V)
matrix variances=vecdiag(vcov)

capture matrix kapvar=variances[1,"/:kappa"]
capture matrix kapvar=variances[1,"kappa:_cons"]
local kapse=sqrt(kapvar[1,1])
local kapco = e(kappa)
local kapub = e(kappa)+(`kapse'*invnorm(1-(1-c(level)/100)/2))
local kaplb = e(kappa)-(`kapse'*invnorm(1-(1-c(level)/100)/2))
local kapvar=(`kapse')^2

capture matrix sigvar=variances[1,"/:lnsigma"]
capture matrix sigvar=variances[1,"ln_sig:_cons"]
local sigse=sqrt(sigvar[1,1])
local sigco = e(sigma)
local sigub = exp(ln(e(sigma))+(`sigse'*invnorm(1-(1-c(level)/100)/2)))
local siglb = exp(ln(e(sigma))-(`sigse'*invnorm(1-(1-c(level)/100)/2)))
local lnsigco=ln(e(sigma))
local lnsigvar=(`sigse')^2

capture matrix cov=vcov["/:lnsigma","/:kappa"]
capture matrix cov=vcov["ln_sig:_cons","kappa:_cons"]
local cov=cov[1,1]
local corr=`cov'/(sqrt(`kapvar')*sqrt(`lnsigvar'))

* 3. Text output
di "Taxonomy of hazard functions for the generalized gamma distribution" _n ///
"Cox C, Chu H, Schneider MF, Muñoz A. Stat Med. 2007 Oct 15;26(23):4352-74" _n(2) ///
"Locate your model in the GG family map: kappa and sigma coefficients with their confidence intervals are plotted" _n ///
"Reference lines for nested distributions are provided. See help ggtaxonomy for more information" _n(2)

di as text "Please wait for graph"

* 4. Making graph
quietly {
	preserve
	clear
	set obs 3001
	gen s = (_n-1)/1000
	gen invweibull = -1
	gen invgamma = s*-1
	gen invammag = -1/s
	gen lognormal = 0
	gen weibull = 1
	gen ammag = 1/s
	gen gamma = s
	replace invammag = . if invammag < -1
	replace ammag = . if ammag > 3
	replace invgamma = . if invgamma < -1
	gen shape = .
	replace shape = `kaplb' in 1
	replace shape = `kapub' in 2
	gen scale = .
	replace scale = `siglb' in 1
	replace scale = `sigub' in 2
	gen kapva = `kapco' if scale != .
	gen sigva = `sigco' if shape != .
	gen sigkap = "("+string(round(`sigco',0.001)) + " , " + string(round(`kapco',0.001))+")"
	gen s2=s/3*2-1
	gen x2=`lnsigco'+sqrt(`lnsigvar')*sqrt(invchi2(2, .95))*s2
	gen z2=(x2-`lnsigco')/sqrt(`lnsigvar')
	gen radical=sqrt((1 - `corr'*`corr') * (invchi2(2, .95) - z2*z2))
	replace radical=0 in 1
	replace radical=0 in 3001
	gen z1p=`corr'*z2+radical
	gen z1m=`corr'*z2-radical
	gen x1p=`kapco' + sqrt(`kapvar')*z1p
	gen x1m=`kapco' + sqrt(`kapvar')*z1m 
	gen x2_exp=exp(x2)
	line gamma invgamma ammag invammag weibull invweibull lognormal s ///
		, xtitle("Scale") ytitle("Shape", margin(right)) ylabel(, nogrid) aspectratio(.75) ///
		title("Taxonomy of hazard functions", span) subtitle("for the generalized gamma distribution", margin(bottom) span) ///
		note("Cox C, Chu H, Schneider MF, Muñoz A. Stat Med. 2007 Oct 15;26(23):4352-74") ///
		lpattern(solid shortdash solid shortdash dash shortdash dash) ///
		lcolor(navy navy green green red red gold) ///
		legend(symxsize(*.5) cols(1) position(3) size(vsmall) order(1 2 3 4 5 6 7 8 9) ///
		label(1 "Standard Gamma") label(2 "Inverse Gamma") ///
		label(3 "Ammag®") label(4 "Inverse Ammag®") ///
		label(5 "Weibull") label(6 "Inverse Weibull") ///
		label(7 "Lognormal") label(9 "Kappa/Sigma CI") ///
		label(8 "You are here")) ///
		|| scatter kapva sigva, mcolor(red) fcolor(black) msymbol(plus) mlabel(sigkap) mlabcolor(black) mlabposition(3) ///
		|| line x1p x2_exp ,lcolor(black) || line x1m x2_exp ,lcolor(black)
	restore
}

end
