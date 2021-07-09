
cap prog drop mmeiv
program mmeiv , eclass sortpreserve

syntax anything [if] [in] [fweight aweight pweight iweight] [, XKnots(numlist) WKnots(numlist) VCE(string) PREDICT PLOT GRAPHOPtions(string) ]
capture noisily { 
qui{
										// checking version
version 10.0 
										// Decoding syntax
if "`anything'" == "" error 102
gettoken Y anything : anything
local lpar 	= strpos("`anything'","(")
local rpar 	= strpos("`anything'",")")
local Zc = trim(trim(substr("`anything'",1,`lpar'-1))+" "+trim(substr("`anything'",`rpar'+1,.)))
local inpar = trim(substr("`anything'",`lpar'+1,`rpar'-`lpar'-1))
local eqpos = strpos("`inpar'","=")
local X  = trim(substr("`inpar'",1,`eqpos'-1))
local rinpar  = trim(substr("`inpar'",`eqpos'+1,.))
local lcurly 	= strpos("`rinpar'","{")
local rcurly 	= strpos("`rinpar'","}")
local T = trim(substr("`rinpar'",1,`lcurly'-1))+" "+trim(substr("`rinpar'",`rcurly'+1,.))
local W = trim(substr("`rinpar'",`lcurly'+1,`rcurly'-`lcurly'-1))

if "`weight'"~= "" local weight [`weight'`exp']
										// Checking syntax
if `lpar' == 0 |`rpar' == 0 | `eqpos' == 0 | `lcurly'==0 | `rcurly'==0  error 197
if "`X'"  == "" error 102
if "`W'"  == "" error 102
if "`Y'"  == "" error 102
if "`T'"  == "" error 102
if word("`T'",2) ~= "" error 198
confirm numeric variable `Y' `X' `Zc' `W' `T'
										// checking  knots specification 
if wordcount("`X'") > wordcount("`xknots'") & "`xknots'" ~= "" error 122
if wordcount("`W'") > wordcount("`wknots'") & "`wknots'" ~= "" error 122
	
local xtotal = 0
foreach xk in `xknots' {
if `xk' <  0 error 125 
local xtotal = `xtotal' + `xk'
}
if `xtotal' == 0 local xknots = ""

local wtotal = 0
foreach wk in `wknots' {
if `wk' <  0 error 125 
local wtotal = `wtotal' + `wk'
}
if `wtotal' == 0 local wknots = ""
//  make sure to adjust if numlists " 0 0 0 " or negative vals 
										// (Checking generate option)
if "`generate'" ~= "" {		
confirm new variable `generate'	
local count =0
foreach xvar in `X' {
local ++count 
}
local countgen =0 
foreach xvar in `generate' {
local ++countgen
}
if `countgen'/2 ~= `count' error 198
}
if "`wknots'" ~= "" {						// Generating W variable(s) splines
tokenize `wknots' 
local count = 1
foreach wvar of varlist `W' {
	// if specific var is nonlinear
if ``count'' ~= 0 {
local wknotsp1 = ``count''+1
mkspline _CEtempwsp`count'_ `wknotsp1' = `wvar' , pctile 
mat wknots_`wvar' = r(knots)
}
	// otherwise
else gen _CEtempwsp`count' = `wvar' 
local ++count
}
local Wlist _CEtempwsp* 
}
else local Wlist `W' 

local count = 1 
foreach wvar of varlist `Wlist' {		// Generating W*T interactions
gen _CEtempwtint`count' = `wvar'*`T'
local ++count
}
local WTlist _CEtempwtint*

if "`xknots'" ~= "" {						// ( Generating X variable(s) splines)
tokenize `xknots'
local count = 1
foreach xvar of varlist `X' {
	// if specific var is nonlinear
if ``count'' ~= 0 {
local xknotsp1 = ``count''+1
mkspline _CEtempxsp`count'_ `xknotsp1' = `xvar' , pctile 
mat xknots_`xvar' = r(knots)
}
	// otherwise
else gen _CEtempxsp`count' = `xvar' 
local ++count
}
local Xlist _CEtempxsp* 
}
else local Xlist `X'

										// Running regression
if "`vce'" == "" local vce una
ivregress 2sls `Y' `Zc' `Wlist' ( `Xlist' = `T' `WTlist') `if' `in' `weight' , vce(`vce')
}
										// Posting results
ereturn local cmd "mmeiv"
ereturn local title "Multiple Marginal Effects IV Estimation"

										// Displaying output
unab Xlist: `Xlist'
if "`wknots'" ~= "" | "`xknots'" ~= "" {
di _newline
						// calculating maximum number of knots used 
local maxk = 0
if "`wknots'" ~= "" { 
foreach k in `wknots' {
if `k' > `maxk' local maxk = `k' 
}
}
if "`xknots'" ~= "" { 
foreach k in `xknots' {
if `k' > `maxk' local maxk = `k' 
}
}

di as text "Linear spline knots"
local knots1 = `maxk' 
forval i=1/`knots1' {
local heading "`heading' "      " %10s "knot `i'""
foreach wvar of varlist `W' { 
local content_`wvar' "`content_`wvar'' "      " %10.0g wknots_`wvar'[1,`i']" 
}
foreach xvar of varlist `X' { 
local content_`xvar' "`content_`xvar'' "      " %10.0g xknots_`xvar'[1,`i']" 
}
}
local linelength = `knots1'*11
di as text "{hline 13}{c TT}{hline `linelength'}"
di as text "{col 14}{c |}" `heading'
di as text "{hline 13}{c +}{hline `linelength'}"
if "`wknots'" ~="" {
tokenize `wknots'
local count =1 
foreach wvar of varlist `W' { 
if ``count'' > 0 di as text %12s abbrev("`wvar'",12) " {c |}" `content_`wvar''
local ++count
}
local wnote "(in linear splines)" 
}
if "`xknots'" ~= "" { 
tokenize `xknots'
local count = 1 
foreach xvar of varlist `X' { 
if ``count'' > 0 di as text %12s abbrev("`xvar'",12) " {c |}" `content_`xvar''
local ++count
}
local xnote "(in linear splines)"
}
di as text "{hline 13}{c BT}{hline `linelength'}"
}

di _newline
di as text "Multiple Marginal Effects IV Estimation"
di as text "{col 52} Number of obs = " %10s " `e(N)'"
if `e(df_m)' < 10 di as text "{col 52} Wald chi2(`e(df_m)')  = " %10.2f `e(chi2)'
else di as text "{col 52} Wald chi2(`e(df_m)') = " %10.2f `e(chi2)'
di as text "{col 52} Prob > chi2   = " %10.4f  chi2tail(`e(df_m)',`e(chi2)')
di as text "{col 52} Root MSE	   = " %10.4f  `e(rmse)'

di as text "{hline 13}{c TT}{hline 64}"
di as text %12s abbrev("`Y'",12) " {c |} " %10s "Coef." "   " %9s "Std. Err." /*
*/ 	"    " %5s "z  " " " %6s	"P>|z|"	"     " %16s "[95% Conf. Interval]"
di as text "{hline 13}{c +}{hline 64}"

if "`xknots'" ~= "" {
local count = 1
tokenize `xknots'
foreach xvar in `X' {
if `count' > 1 di as text "{col 14}{c |}"
if ``count'' ~= 0 {
di as text %12s abbrev("`xvar':",12) "{col 14}{c |}"
local xknotsp1 = ``count''+1
local i = 1 
forval i=1/`xknotsp1' {
if ``count'' ~= 0 {
di as text %12s "spline `i'" " {c |}  " as result %9.0g _b[_CEtempxsp`count'_`i'] /*
*/ "  " %9.0g _se[_CEtempxsp`count'_`i'] "    " %5.2f _b[_CEtempxsp`count'_`i']/_se[_CEtempxsp`count'_`i'] /*
*/ "   " %4.3f 2*normal(-abs(_b[_CEtempxsp`count'_`i']/_se[_CEtempxsp`count'_`i'])) /*
*/ "    " %9.0g _b[_CEtempxsp`count'_`i']-1.95996*_se[_CEtempxsp`count'_`i'] /*
*/ "   " %9.0g _b[_CEtempxsp`count'_`i']+1.95996*_se[_CEtempxsp`count'_`i']
}
}
}
else {
di as text %12s abbrev("`xvar'",12) " {c |}  " as result %9.0g _b[_CEtempxsp`count'] /*
*/ "  " %9.0g _se[_CEtempxsp`count'] "    " %5.2f _b[_CEtempxsp`count']/_se[_CEtempxsp`count'] /*
*/ "   " %4.3f 2*normal(-abs(_b[_CEtempxsp`count']/_se[_CEtempxsp`count'])) /*
*/ "    " %9.0g _b[_CEtempxsp`count']-1.95996*_se[_CEtempxsp`count'] /*
*/ "   " %9.0g _b[_CEtempxsp`count']+1.95996*_se[_CEtempxsp`count']
}
local ++count
}
}


else {
foreach xvar in `X' {
di as text %12s abbrev("`xvar'",12) " {c |}  " as result %9.0g _b[`xvar'] /*
*/ "  " %9.0g _se[`xvar'] "    " %5.2f _b[`xvar']/_se[`xvar'] /*
*/ "   " %4.3f 2*normal(-abs(_b[`xvar']/_se[`xvar'])) /*
*/ "    " %9.0g _b[`xvar']-1.95996*_se[`xvar'] /*
*/ "   " %9.0g _b[`xvar']+1.95996*_se[`xvar']
}
}
if "`Zc'"~="" {
di as text "{col 14}{c |}"
unab Zc: `Zc'
foreach zc in `Zc' { 
di as text %12s abbrev("`zc'",12) " {c |}  " as result %9.0g _b[`zc'] /*
*/ "  " %9.0g _se[`zc'] "    " %5.2f _b[`zc']/_se[`zc'] /*
*/ "   " %4.3f 2*normal(-abs(_b[`zc']/_se[`zc'])) /*
*/ "    " %9.0g _b[`zc']-1.95996*_se[`zc'] /*
*/ "   " %9.0g _b[`zc']+1.95996*_se[`zc']
}
}
di as text "{hline 13}{c BT}{hline 64}"
di as text "Instrumented (X): `X' `xnote'"
di as text "Instrument (T): `T'"
di as text "Separable covariates (W1): `W' `wnote'" 
di as text "Exogenous covariates (W2): `Zc'" 

										// (Generating predictions)
									
local count = 1 
foreach xvar of varlist `X' {
local ghatsum_`xvar' 0
local gsesum_`xvar' 0
if "`xknots'" ~= "" {
foreach xsp of varlist _CEtempxsp`count'* {
local ghatsum_`xvar'  "`ghatsum_`xvar'' + _b[`xsp']*`xsp'"
}
}
else {
local ghatsum_`xvar'  "`ghatsum_`xvar'' + _b[`xvar']*`xvar'"
}
if "`predict'" ~= "" { 				
cap noisily predictnl double _`xvar'_est = (`ghatsum_`xvar'') , se(_`xvar'_se)
label var _`xvar'_est "`xvar' Marginal Effect Estimate"
label var _`xvar'_se "`xvar' Marginal Effect Standard Error"

macro shift 2 
}
local ++count
}
										// (Plotting)
qui{										
if "`plot'" ~= "" {
local count = 1 
foreach xvar of varlist `X' { 
predictnl double _CEtempghat = (`ghatsum_`xvar'') , se(_CEtempgse)
gen _CEtempghatup = _CEtempghat + 1.96*_CEtempgse
gen _CEtempghatlw = _CEtempghat - 1.96*_CEtempgse
sort `xvar'
tw ( rarea _CEtempghatup _CEtempghatlw `xvar', color(gs12) lc(gs12)  ) (line _CEtempghat `xvar', lc(black) ), legend(lab( 1 "95% CI") lab(2 "Marginal effect estimate")) name(`xvar', replace) `graphoptions'
cap drop _CEtempghatup _CEtempghatlw _CEtempghat _CEtempgse
}
}
}
}
										// Cleaning
cap drop _CEtemp*
end
