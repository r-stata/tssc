***************************************************************************
*! ggtax: Command for identifying your most suitable GG family model
* A tribute to Professor Álvaro Muñoz, in gratitude for his visit to Bogotá
* ado by Andrés González Rangel
* andres.gonzalez@iecas.org
*! version 0.9 17may2013
***************************************************************************

program ggtax
	version 11.0
	syntax

* 1. Quality check
if regexm(e(cmd),"gamma") == 0 {
	di as error "You must run a gamma model, see help streg for more details"
	exit
}

* 2. Obtaining coefficients
local kapco = e(kappa)
local kapub = e(kappa)+(_se[kappa:_cons]*invnorm(1-(1-c(level)/100)/2))
local kaplb = e(kappa)-(_se[kappa:_cons]*invnorm(1-(1-c(level)/100)/2))
local sigco = e(sigma)
local sigub = exp(_b[ln_sig:_cons]+(_se[ln_sig:_cons]*invnorm(1-(1-c(level)/100)/2)))
local siglb = exp(_b[ln_sig:_cons]-(_se[ln_sig:_cons]*invnorm(1-(1-c(level)/100)/2)))

* 3. Text output
di "Taxonomy of hazard functions for the generalized gamma distribution" _n ///
"Cox C, Chu H, Schneider MF, Muñoz A. Stat Med. 2007 Oct 15;26(23):4352-74" _n(2) ///
"Locate your model in the GG family map: kappa and sigma coefficients with their confidence intervals are plotted" _n ///
"Reference lines for nested distributions are provided. See help ggtax for more information" _n(2)

di as text "Please wait for graph"

* 4. Making graph
quietly {
	preserve
	clear
	set obs 3000
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
	line gamma invgamma ammag invammag weibull invweibull lognormal s ///
		, xtitle("Scale") ytitle("Shape", margin(right)) ylabel(, nogrid) aspectratio(.75) ///
		title("Taxonomy of hazard functions", span) subtitle("for the generalized gamma distribution", margin(bottom) span) ///
		note("Cox C, Chu H, Schneider MF, Muñoz A. Stat Med. 2007 Oct 15;26(23):4352-74") ///
		lpattern(solid shortdash solid shortdash dash shortdash dash) ///
		lcolor(navy navy green green red red gold) ///
		legend(symxsize(*.5) cols(1) position(3) size(vsmall) order(10 1 2 3 4 5 6 7 8 9) ///
		label(1 "Standard Gamma") label(2 "Inverse Gamma") ///
		label(3 "Ammag®") label(4 "Inverse Ammag®") ///
		label(5 "Weibull") label(6 "Inverse Weibull") ///
		label(7 "Lognormal") label(8 "Kappa CI") ///
		label(9 "Sigma CI") label(10 "You are here")) ///
		|| line shape sigva, lcolor(gs3) ///
		|| line kapva scale, lcolor(gs8) ///
		|| scatter kapva sigva, mcolor(black) msymbol(Oh) mlabel(sigkap) mlabposition(4)
	restore
}

end
