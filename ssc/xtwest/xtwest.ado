*! xtwest 1.5 1Jul2010
*! Damiaan Persyn, LICOS centre for Development and Economic Performance www.econ.kuleuven.be/licos
*! Copyright Damiaan Persyn 2007-2008. 

* 1.5 June 2010
*	repaired an issue which caused the program to crash in stata 11
*     updated helpfile
* 1.4 July 2008
*	added reporting of mean group regression, request by Federico Podesta
* 1.3 June 2008
*	version control
* 1.2 May 2008, 
*	allow for 0 lags 
*	fixed touse problem for discontinuous series
* 1.1 April 2008
*	added check of time-series length
*	now prints info on average lag and lead length selected by the AIC
*	multiple small fixes
* 1.0 first release february 1, 2008

/* outline:
xtwest: does some input checking, then

-- with bootstrap option:
	* runs "WesterlundBootstrap" = prepare bootstrap data + run "WesterlundPlain" repeatedly with bootstrap sample
	* runs "WesterlundPlain" with normal data
-- without bootstrap option:
	* runs "WesterlundPlain" with normal data

Finally, runs "DisplayWesterlund" to display the results.
*/

program define xtwest, rclass 
version 8
syntax varlist(ts) [if] [in] [, MG DETREND DEBUG BOOTSTRAP(integer -1) CONSTANT TREND LAGS(numlist integer min=1 max=2 >=0) LEADS(numlist integer min=1 max=2 >=0) NOISILY LRWINDOW(integer 2) WESTERLUND] 

tokenize `varlist'
local yvar `1'
macro shift 
local xvars `*'
local nox:  word count `xvars'

if `nox' > 6 {
di as err "No more than 6 covariates can be specified."
exit 459
}

local withconstant = "`constant'"!=""
local withtrend = "`trend'"!=""
local withwesterlund = "`westerlund'"!=""

if `withwesterlund' {
if !`withconstant' & !`withtrend' {
di as err "if westerlund is specified, at least a constant must be added"
exit 459
}
if `nox' > 1 {
di as err "if westerlund is specified at most one x-variable may be included"
exit 459
}
}

if `withtrend' & !`withconstant' {
di as txt "If a trend is included, a constant must be included as well"
exit 459
}

qui tsset
local id `r(panelvar)'
local t `r(timevar)'
sort `id' `t'

if "`id'" == "" {
di as err "You must tsset the data and specify the panel and time variables."
exit 459
}
capture assert ! missing(`id')
if c(rc) {
di as err `"missing values in `id' `i' not allowed"'
exit 459
}

marksample touse
markout `touse' `id'

qui replace `touse' = 0 if `yvar' >= .
foreach x of varlist `xvars' {
qui replace `touse' = 0 if `x' >= .
}

preserve
tempvar diff 
foreach x of varlist `yvar' `xvars' {
qui drop if `x' >= .
}
qui by `id': gen `diff' = `t'-`t'[_n-1]
qui sum `diff' if `touse'
if r(max) > 1 {
di ""
di as err "Continuous time-series are required"
di ""
di as txt "Following series contain holes:"
di ""
table `id' if `diff' > 1 & `diff' < .
restore
exit 
}
restore

qui levels `id' if `touse' , local(levels)
local nobs: word count `levels'

if "`lags'" == "" {
di as err "The option lags has to be provided"
exit 459
}
local numlags : word count `lags'
if `numlags' > 1 {
tokenize `lags'
local minlag = `1'
local maxlag = `2'
if `minlag' > `maxlag' {
local temp = `maxlag'
local maxlag = `minlag'
local minlag = `temp'
}
}
else {
local minlag = `lags'
local maxlag = `lags'
}

if "`leads'" != "" {
local numleads : word count `leads'
if `numleads' > 1 {
tokenize `leads'
local minlead = `1'
local maxlead = `2'
if `minlead' > `maxlead' {
local temp = `maxlead'
local maxlead = `minlead'
local minlead = `temp'
}
}
else {
local minlead = `leads'
local maxlead = `leads'
}
}
else {
local minlead = 0
local maxlead = 0
}

local withtrend = "`trend'"!=""

local auto = (`minlead'!=`maxlead')|(`minlag'!= `maxlag')


tempvar one numbobs miss nonmiss
qui egen `miss' = rowmiss(`yvar' `xvars')
qui gen `nonmiss' = 1 if `miss' == 0
qui by `id': egen `numbobs' = sum(`nonmiss') if `touse'
local minobs = `maxlag' + `maxlead' + 1 + (`withconstant'+`withtrend') + 1 + `nox' + `maxlag' + `nox'*(`maxlag'+`maxlead'+1) + 1
*di "minobs: " `minobs'
qui sum `numbobs'
if r(min) < `minobs' {
di _con as err "With `maxlag' lag(s), `maxlead' lead(s)"
if `withconstant' {
di _con as err " and a constant"
}
if `withtrend' {
di _con as err " and a trend"
}
di as err " at least `minobs' observations are required."
di as err "Following series do not contain sufficient observations."
*di as err "The number of valid observations for each series is stored in _validobs"
*qui gen _validobs = `numbobs'
table `id' if (`numbobs' < `minobs') & `touse'
exit
}




if `bootstrap' > 0 {

tempname BOOTSTATS STATS

WesterlundBootstrap `0'

matrix `BOOTSTATS' = r(BOOTSTATS)

WesterlundPlain `0' bootno

matrix `STATS' = J(1,4,0)
matrix `STATS'[1,1] = r(Gt)
matrix `STATS'[1,2] = r(Ga)
matrix `STATS'[1,3] = r(Pt)
matrix `STATS'[1,4] = r(Pa)
local meanlag = r(meanlag)
local meanlead = r(meanlead)
local realmeanlag = r(realmeanlag)
local realmeanlead = r(realmeanlead)
local auto = r(auto)

DisplayWesterlund, stats(`STATS') bootstats(`BOOTSTATS') nobs(`nobs') nox(`nox') `constant' `trend' `westerlund' meanlag(`meanlag') meanlead(`meanlead') realmeanlag(`realmeanlag') realmeanlead(`realmeanlead')  auto(`auto')

return scalar pa_pvalboot = r(pa_pvalboot)
return scalar pt_pvalboot = r(pt_pvalboot)
return scalar ga_pvalboot = r(ga_pvalboot)
return scalar gt_pvalboot = r(gt_pvalboot)
return scalar pa_pval = r(pa_pval)
return scalar pt_pval = r(pt_pval)
return scalar ga_pval = r(ga_pval)
return scalar gt_pval = r(gt_pval)
return scalar pa_z = r(pa_z)
return scalar pt_z = r(pt_z)
return scalar ga_z = r(ga_z)
return scalar gt_z = r(gt_z)
return scalar pa = r(pa)
return scalar pt = r(pt)
return scalar ga = r(ga)
return scalar gt = r(gt)

} 
else {

WesterlundPlain `0' bootno 

tempname STATS
matrix `STATS' = J(1,4,0)
matrix `STATS'[1,1] = r(Gt)
matrix `STATS'[1,2] = r(Ga)
matrix `STATS'[1,3] = r(Pt)
matrix `STATS'[1,4] = r(Pa)
local meanlag = r(meanlag)
local meanlead = r(meanlead)
local realmeanlag = r(realmeanlag)
local realmeanlead = r(realmeanlead)
local auto = r(auto)

DisplayWesterlund, stats(`STATS') nobs(`nobs') nox(`nox') `constant' `trend' `westerlund' meanlag(`meanlag') meanlead(`meanlead') realmeanlag(`realmeanlag') realmeanlead(`realmeanlead') auto(`auto')

return scalar pa_pval = r(pa_pval)
return scalar pt_pval = r(pt_pval)
return scalar ga_pval = r(ga_pval)
return scalar gt_pval = r(gt_pval)
return scalar pa_z = r(pa_z)
return scalar pt_z = r(pt_z)
return scalar ga_z = r(ga_z)
return scalar gt_z = r(gt_z)
return scalar pa = r(pa)
return scalar pt = r(pt)
return scalar ga = r(ga)
return scalar gt = r(gt)
}

end



					*************************************************

program define WesterlundBootstrap, rclass 
version 8
syntax varlist(ts) [if] [in] [, MG DETREND DEBUG BOOTSTRAP(integer -1) CONSTANT TREND LAGS(numlist integer min=1 max=2 >=0) LEADS(numlist integer min=1 max=2 >=0) NOISILY LRWINDOW(integer 2) WESTERLUND] 

local constant = "`constant'"!=""
local trend = "`trend'"!=""
local demean = "`demean'"!=""	
local noisily = "`noisily'"!=""
local westerlund = "`westerlund'"!=""
local debug = "`debug'"!=""

di ""
di _con as txt "Bootstrapping critical values under H0" 

tokenize `varlist'
local yvar `1'
macro shift 
local xvars `*'
local nox:  word count `xvars'

qui tsset
local id `r(panelvar)'
local t `r(timevar)'
sort `id' `t'

marksample touse
markout `touse' `id'

qui replace `touse' = 0 if `yvar' >= .
foreach x of varlist `xvars' {
qui replace `touse' = 0 if `x' >= .
}

tempvar miss nonmiss ti
qui egen `miss' = rowmiss(`yvar' `xvars')
qui gen `nonmiss' = 1 if `miss' == 0
qui by `id': egen `ti' = sum(`nonmiss') if `touse'
qui sum `ti'
local meanbigT = r(mean)

local numlags : word count `lags'
local auto = 0

if `numlags' > 1 {
tokenize `lags'
local minlag = `1'
local maxlag = `2'
if `minlag' > `maxlag' {
local temp = `maxlag'
local maxlag = `minlag'
local minlag = `temp'
}
}
else {
local minlag = `lags'
local maxlag = `lags'
}

if "`leads'" != "" {
local numleads : word count `leads'
if `numleads' > 1 {
tokenize `leads'
local minlead = `1'
local maxlead = `2'
if `minlead' > `maxlead' {
local temp = `maxlead'
local maxlead = `minlead'
local minlead = `temp'
}
}
else {
local minlead = `leads'
local maxlead = `leads'
}
}
else {
local minlead = 0
local maxlead = 0
}

local auto = (`minlead'!=`maxlead')|(`minlag'!= `maxlag')

*** generate coefficients per individual (equation 9)

foreach x of varlist `xvars' {
forvalues lag = 0/`maxlag' {
tempvar __bL`lag'D`x'
qui gen  `__bL`lag'D`x'' = .
}
if `maxlead' > 0 {
forvalues lead = 1/`maxlead' {
tempvar __bF`lead'D`x'
qui gen  `__bF`lead'D`x'' = .
}
}
}

forvalues lag = 1/`maxlag' {
tempvar __bL`lag'D`yvar'
qui gen  `__bL`lag'D`yvar'' = .
}

tempvar e resid n_in
qui gen  `e' = .
qui gen `n_in' = _n

****
** individual regressions to determine optimal lag length per series
****

** loop over touse individuals
qui levels `id' if `touse' , local(levels)

foreach l of local levels {

** for each individual, consider only touse observations in firstob/lastob
qui sum `n_in' if `id' == `l' & `touse', meanonly
local firstob = r(min)
local lastob  = r(max)
qui sum `ti' in `firstob'/`lastob'
local thisti = r(mean)

tempvar tren cons
qui by `id': gen `tren' = `trend'*_n
qui gen `cons' = `constant'

if `auto' {
  local curroptic = .
  foreach currlag of numlist `maxlag'/`minlag' {
   foreach currlead of numlist `maxlead'/`minlead' {
if `currlag' > 0 {
qui   reg d.`yvar' `cons' `tren' L(1/`currlag')D.`yvar' L(-`currlead'/`currlag')D.(`xvars') in `firstob'/`lastob', nocons
   }
else {
qui   reg d.`yvar' `cons' `tren' L(-`currlead'/`currlag')D.(`xvars') in `firstob'/`lastob', nocons 
}
  if `westerlund' {
	local ic = log(e(rss)/(`thisti'-`currlag'-`currlead'-1)) + 2*(`currlag' + `currlead' + `cons' + `tren' + 1)/(`thisti'-`maxlag'-`maxlead')
    }
    else {
	qui estat ic
	matrix tmp = r(S)
	local ic = tmp[1,5]
**	local ic = log(e(rss)/(`thisti'-`currlag'-`currlead'-1)) + 2*(`currlag' + `currlead' + `cons' + `tren' + 1)/(`thisti'-`maxlag'-`maxlead')
    }
	if `ic' < `curroptic' {
	 local curroptic = `ic'
	 local curroptlag = `currlag'
	 local curroptlead = `currlead'
      }
   }
  }
local currlag = `curroptlag'
local currlead = `curroptlead'
} 
else {
  local currlag = `maxlag'
  local currlead = `maxlead'
}

** repeat optimal regression

if `currlag' > 0 {
qui reg d.`yvar' `cons' `tren' L(1/`currlag')D.`yvar' L(-`currlead'/`currlag')D.(`xvars') in `firstob'/`lastob', nocons 
   }
else {
qui   reg d.`yvar' `cons' `tren' L(-`currlead'/`currlag')D.(`xvars') in `firstob'/`lastob', nocons 
}




matrix b = e(b)
qui matrix score `e' = b in `firstob'/`lastob', replace
qui replace `e' = d.`yvar' - `e' in `firstob'/`lastob'

foreach x of varlist `xvars' {
forvalues lag = 0/`currlag' {
qui replace `__bL`lag'D`x'' = _b[l`lag'.d.`x'] in `firstob'/`lastob'
}
if `currlead' > 0 {
forvalues lead = 1/`currlead' {
qui replace `__bF`lead'D`x'' = _b[f`lead'.d.`x'] in `firstob'/`lastob'
}
}
}

forvalues lag = 1/`currlag' {
qui replace `__bL`lag'D`yvar'' = _b[l`lag'.d.`yvar'] in `firstob'/`lastob'
}

** end individual regressions.
}


if `debug' {
di ""
di "end individual regressions"
di ""
}

foreach x of varlist `xvars' {
forvalues lag = 0/`maxlag' {
qui qui replace `__bL`lag'D`x'' = 0 if `__bL`lag'D`x'' >= .
}
if `currlead' > 0 {
forvalues lead = 1/`currlead' {
qui replace `__bF`lead'D`x'' = 0 if `__bF`lead'D`x'' >= .
}
}
}
forvalues lag = 1/`maxlag' {
qui qui replace `__bL`lag'D`yvar'' = 0 if `__bL`lag'D`yvar'' >= .
}

local dxvars 
foreach x of varlist `xvars' {
tempvar d`x'
qui gen `d`x'' = d.`x' if `touse'
local dxvars `dxvars' d`x'
}

** demean
tempvar meane
qui by `id': egen  `meane' = mean(`e') if `touse'
qui replace `e' = `e' - `meane' if `touse'
foreach x of varlist `xvars' {
tempvar meand`x' centerd`x' boot`x'
qui gen  `boot`x'' = . 
local bootxvars `bootxvars' `boot`x''
qui by `id': egen  `meand`x'' = mean(`d`x'')  if `touse'
qui gen  `centerd`x'' = `d`x'' - `meand`x''  if `touse'
}
if `debug' {
di "calling westerlundplain from westerlundbootstrap"
}

tempname BOOTSTATS
matrix `BOOTSTATS' = J(`bootstrap',4,.)
tempvar newid newt booty expanded oldt newtt newttt tussent

** for easy comparison with westerlund code. 
local forward = `maxlag' + 1
*qui by `id' : replace `e' = f`forward'.`e' if _n <= `ti' - `maxlag' - `maxlead' - 1  & `touse'
*qui by `id' : replace `centerd`xvars'' = f.`centerd`xvars'' if _n <= `ti' - 1 & `touse'
*qui by `id' : replace `e' = . if _n > `ti' - `maxlag' - `maxlead' - 1 & `touse'
*qui by `id': replace `centerd`xvars'' = . if _n > `ti' - 1 & `touse'
qui by `id' : gen `oldt' = _n if `touse'

*** bootstrap loop
preserve
local counter 0
local dots 0
forvalues i = 1/`bootstrap' {
local counter = `counter' + 1
restore, preserve
qui expandcl 2, cluster(`id') gen(`expanded')
local counter = `counter' + 1

local bootstrapsize = `meanbigT' 
** set seed 123456
bsample if `e' < ., cluster(`t') 
qui gen `newttt' = ceil(uniform()*(`ti'-`maxlag'-`maxlead'-1)) 
sort `id', stable
qui by `id': gen `tussent' = _n
sort `tussent', stable
qui by `tussent': egen `newtt' = mean(`newttt')
sort `id' `newtt' , stable
qui by `id': keep if _n <= `ti' + `maxlag' + `maxlead' + 2
qui by `id': gen `newt' = _n
qui tsset `id' `newt'


*** e->u
tempvar u 
qui gen  `u' = `e' 
qui by `id': replace `u' = . if _n <  `maxlag' + 1
qui by `id': replace `u' = . if _n <  `maxlag' + 1
qui replace `u' = 0 if `u' >= .
foreach x of varlist `xvars' {
forvalues lag = 0/`maxlag' {
qui replace `u' = `u' + L`lag'.`centerd`x''*`__bL`lag'D`x''
}
if `currlead' > 0 {
forvalues lead = 1/`currlead' {
qui replace `u' = `u' + F`lead'.`centerd`x''*`__bF`lead'D`x''
}
}
} 

*** u->dy
tempvar dy
qui by `id': gen  `dy' = `u'
qui by `id': replace `dy' = 0 if `dy' >= .
local command "qui by `id': replace `dy' = `dy'"
forvalues lag = 1/`maxlag' {
local command "`command' + `dy'[_n-`lag']*`__bL`lag'D`yvar''"
}
local command "`command' if _n > `maxlag'"
*di "`command'"
qui `command'
qui by `id': replace `dy' = . if _n <= `maxlag' 

*** dy->booty
qui gen  `booty' = 0
qui by `id': replace `booty' = sum(`dy') 
qui by `id': replace `booty' = . if _n <= `maxlag' 
qui by `id': replace `booty' = . if _n > `ti' + `maxlag'

*** dx->bootx
foreach x of varlist `xvars' {
qui by `id': replace `boot`x'' = sum(`centerd`x'') if _n > `maxlag' 
qui by `id': replace `boot`x'' = . if _n <= `maxlag' 
qui by `id': replace `boot`x'' = . if _n > `ti' + `maxlag'
}

gettoken command options: 0, parse(",")

if `debug' {
di "voor plain in boot"
}

WesterlundPlain `booty' `bootxvars' `options'

if `debug' {
di "na plain in boot"
}

matrix `BOOTSTATS'[`i',1] = r(Gt)
matrix `BOOTSTATS'[`i',2] = r(Ga)
matrix `BOOTSTATS'[`i',3] = r(Pt)
matrix `BOOTSTATS'[`i',4] = r(Pa)

matrix BOOTSTATS = `BOOTSTATS'[1..`i',1..4]

*** end bootstrap loop
  if (`counter' > (`dots'*`bootstrap'/5)) {
    *** progress meter
    di as result _con "."
    local dots = `dots' + 1
  }
}

return matrix BOOTSTATS = `BOOTSTATS'

end




						**********************************************



program define WesterlundPlain, rclass 
version 8
syntax varlist(ts) [if] [in] [, MG DETREND DEBUG BOOTSTRAP(integer -1)  CONSTANT TREND LAGS(numlist integer min=1 max=2 >=0) LEADS(numlist integer min=1 max=2 >=0) NOISILY LRWINDOW(integer 2) AUTO WESTERLUND BOOTNO] 

tokenize `varlist'
local yvar `1'
macro shift 
local xvars `*'

tempvar count

qui tsset
local id `r(panelvar)'
local t `r(timevar)'

marksample touse
markout `touse' `id'

qui replace `touse' = 0 if `yvar' >= .
foreach x of varlist `xvars' {
qui replace `touse' = 0 if `x' >= .
}

tempvar miss nonmiss ti
qui egen `miss' = rowmiss(`yvar' `xvars')
qui gen `nonmiss' = 1 if `miss' == 0
qui by `id': egen `ti' = sum(`nonmiss') if `touse'
qui sum `ti'
local meanbigT = r(mean)

local nox:  word count `xvars'

local numlags : word count `lags'
local auto = 0

if `numlags' > 1 {
tokenize `lags'
local minlag = `1'
local maxlag = `2'
if `minlag' > `maxlag' {
local temp = `maxlag'
local maxlag = `minlag'
local minlag = `temp'
}
}
else {
local minlag = `lags'
local maxlag = `lags'
}

if "`leads'" != "" {
local numleads : word count `leads'
if `numleads' > 1 {
tokenize `leads'
local minlead = `1'
local maxlead = `2'
if `minlead' > `maxlead' {
local temp = `maxlead'
local maxlead = `minlead'
local minlead = `temp'
}
}
else {
local minlead = `leads'
local maxlead = `leads'
}
}
else {
local minlead = 0
local maxlead = 0
}

local auto = (`minlead'!=`maxlead')|(`minlag'!= `maxlag')

local debug = "`debug'"!=""
local bootno = "`bootno'"!=""
local constant = "`constant'"!=""
local trend = "`trend'"!=""
local demean = "`demean'"!=""	
local noisily = "`noisily'"!=""
local westerlund = "`westerlund'"!=""
local detrend = "`detrend'"!=""

if `bootno' {
di ""
di as txt _con "Calculating Westerlund ECM panel cointegration tests"
di as txt _con ""
}

tempvar dylrvar cons tren aonesemi ai seai u dytmp e lags leads tmpu dyresid yresid resid n_in projection

qui gen `cons' = `constant'
qui gen `tren' = `trend'*`t'
qui gen  `aonesemi' = .
qui gen `ai' = .
qui gen  `seai' = .
qui gen  `u' = .
qui gen  `dytmp' = .
qui gen  `e' = .
qui gen `lags' = .
qui gen `leads' = .
qui gen  `tmpu' = .
qui gen  `dyresid' = .
qui gen  `yresid' = .
qui gen  `resid' = .
qui gen `n_in' = _n
qui gen `dylrvar' = .
qui gen `projection' = .

if `debug' {
di ""
di "westerlundplain, looping over all subjects"
}

tempname b V mgb allb allorigb origb

** looping
qui levels `id' if `touse', local(levels)
local nobs: word count `levels'
local counter 0
local dots 0
foreach l of local levels {
local counter = `counter' + 1

qui sum `n_in' if `id'==`l' & `touse', meanonly
local firstob = r(min)
local lastob  = r(max)
qui sum `ti' in `firstob'/`lastob'
local thisti = r(mean)

*br `yvar' `cons' `tren' `xvars'

if `auto' {
  local curroptic = .
  foreach currlag of numlist `maxlag'/`minlag' {
   foreach currlead of numlist `maxlead'/`minlead' {
if `currlag' > 0 {
*di "id: `l'"
*list `yvar' `xvars' in `firstob'/`lastob'
qui  reg d.`yvar' `cons' `tren' l.`yvar' l.(`xvars') L(1/`currlag')D.`yvar' L(-`currlead'/`currlag')D.(`xvars') in `firstob'/`lastob', nocons
   }
else {
qui  reg d.`yvar' `cons' `tren' l.`yvar' l.(`xvars') L(-`currlead'/`currlag')D.(`xvars') in `firstob'/`lastob', nocons
}
  if `westerlund' {
	local ic = log(e(rss)/(`thisti'-`currlag'-`currlead'-1)) + 2*(`currlag' + `currlead' + `cons' + `tren' + 1)/(`thisti'-`maxlag'-`maxlead')
    }
    else {
	qui estat ic
	matrix tmp = r(S)
	local ic = tmp[1,5]
**	local ic = log(e(rss)/(`thisti'-`currlag'-`currlead'-1)) + 2*(`currlag' + `currlead' + `cons' + `tren' + 1)/(`thisti'-`maxlag'-`maxlead')
    }
      if `ic' < `curroptic' {
	local curroptic = `ic'
	local curroptlag = `currlag'
	local curroptlead = `currlead'
    }
   }
  }
local currlag = `curroptlag'
local currlead = `curroptlead'
} 
else {
  local currlag = `maxlag'
  local currlead = `maxlead'
}


** calculating long run variance of DY
qui replace `dytmp' = d.`yvar' 
if `westerlund' {
qui replace `dytmp' = . if l`currlag'.d.`yvar' >= .
qui replace `dytmp' = . if f`currlead'.d.`yvar' >= .
}


* DETRENDING DY
if !`westerlund' {
if `constant' & `trend' {
qui reg `dytmp' `cons'  in `firstob'/`lastob', nocons
mat b = e(b)
qui matrix score `projection' = b in `firstob'/`lastob', replace
qui replace `dytmp' = `dytmp' - `projection' in `firstob'/`lastob'
}
}

lrvar `dytmp' in `firstob'/`lastob', maxlag(`lrwindow') weighted nodemean
local wysq = r(lrvar) 

** repeat the optimal ECM regression
if `noisily' & `bootno'  {
di _con as txt " `id': `l'"
if `currlag' > 0 {
qui reg d.`yvar' l.(`xvars') `cons' `tren' l.`yvar' L(1/`currlag')D.`yvar' L(-`currlead'/`currlag')D.(`xvars') in `firstob'/`lastob', nocons
matrix `b' = e(b)
matrix `V' = e(V)
local names : colnames `b'
local names : subinstr local names "`cons'" "_cons"
local names : subinstr local names "`tren'" "trend"
matrix colnames `b' = `names'
matrix colnames `V' = `names'
matrix rownames `V' = `names'
xtwestregdisplay `b' `V'
qui reg d.`yvar' l.(`xvars') `cons' `tren' l.`yvar'  L(1/`currlag')D.`yvar' L(-`currlead'/`currlag')D.(`xvars') in `firstob'/`lastob', nocons
matrix `b' = e(b)
      }
else {
qui reg d.`yvar' l.(`xvars') `cons' `tren' l.`yvar' L(-`currlead'/`currlag')D.(`xvars') in `firstob'/`lastob', nocons
matrix `b' = e(b)
matrix `V' = e(V)
local names : colnames `b'
local names : subinstr local names "`cons'" "_cons"
local names : subinstr local names "`tren'" "trend"
matrix colnames `b' = `names'
matrix colnames `V' = `names'
matrix rownames `V' = `names'
xtwestregdisplay `b' `V'
qui reg d.`yvar' l.(`xvars') `cons' `tren' l.`yvar' L(-`currlead'/`currlag')D.(`xvars') in `firstob'/`lastob', nocons
matrix `b' = e(b)
}
di ""
}
else {
if `currlag' > 0 {
qui reg d.`yvar' l.(`xvars') `cons' `tren' l.`yvar' L(1/`currlag')D.`yvar' L(-`currlead'/`currlag')D.(`xvars') in `firstob'/`lastob', nocons
matrix `b' = e(b)
   }
else {
qui   reg d.`yvar' l.(`xvars') `cons' `tren' l.`yvar' L(-`currlead'/`currlag')D.(`xvars') in `firstob'/`lastob', nocons
matrix `b' = e(b)
}
}

qui matrix score `e' = `b' if e(sample), replace
qui replace `e' = d.`yvar' - `e' if e(sample)

qui replace `ai'   = _b[l.`yvar'] in `firstob'/`lastob'
qui replace `seai' = _se[l.`yvar'] in `firstob'/`lastob'
qui replace `lags' = `currlag' in `firstob'/`lastob'
qui replace `leads' = `currlead' in `firstob'/`lastob'

if "`mg'" ~= "" & `bootno' {
matrix `mgb' = `b'
matrix `origb' = `b'
forvalues x = 1/`nox' {
matrix `mgb'[1,`x'] = -`mgb'[1,`x']/_b[l.`yvar']
}
*** unlike xtpmg we also divide the constant and trend as they are part of the LR equilibrium
matrix `mgb'[1,`nox'+1] = -`mgb'[1,`nox'+1]/_b[l.`yvar']
matrix `mgb'[1,`nox'+2] = -`mgb'[1,`nox'+2]/_b[l.`yvar']
if `auto' {
matrix `mgb' = `mgb'[1,1..`nox'+3]
matrix `origb' = `origb'[1,1..`nox'+3]
}
matrix `allb' = nullmat(`allb') \ `mgb'
matrix `allorigb' = nullmat(`allorigb') \ `origb'
}


** calculating u 
qui replace `u' = d.`yvar'  - _b[`cons'] - _b[`tren']*`t' - l.`yvar'*`b'[1,`nox'+3] in `firstob'/`lastob'

forv j = 1/`nox' {
  local dezex: word `j' of `xvars'
  qui replace `u' = `u' - l.`dezex'*`b'[1,`j'] in `firstob'/`lastob'
}

if `currlag' > 0 {
forvalues v = 1/`currlag' {
  qui replace `u' = `u' - `b'[1,3+`nox'+`v']*L`v'D.`yvar' in `firstob'/`lastob'
}
}

qui replace `tmpu' = `u' in `firstob'/`lastob'
if `westerlund' {
qui replace `tmpu' = . if l`currlag'.d.`yvar' >= . in `firstob'/`lastob'
qui replace `tmpu' = . if f`currlead'.d.`yvar' >= . in `firstob'/`lastob'
}



lrvar `tmpu' in `firstob'/`lastob', maxlag(`lrwindow') weighted nodemean
local wusq = r(lrvar)

qui replace `aonesemi' = sqrt(`wusq'/`wysq') in `firstob'/`lastob'

if `debug' {
  *** show some info on the individual regressions
  di _cont as txt " wy-squared: " 
  di _cont as res `wysq'
  di _cont "    "
  di _cont as txt " wu-squared: " 
  di _cont as res `wusq'
  di _cont "    "
  di _cont as txt " aone-semiparametric: "  
  di as res %6.3f (`wusq'/`wysq')^(1/2)
  di ""

di "u:" 
list `tmpu' in `firstob'/`lastob' 

di "yvar"
list `dytmp' in `firstob'/`lastob' 

di "dlryvar:" 
list `dylrvar' in `firstob'/`lastob' 

di "e"
list `e' in `firstob'/`lastob' 

}
else {	
if `bootno' & !`noisily' {
  if `counter' > (`dots'*`nobs'/10)  {
    *** progress meter
    di as result _con "."
    local dots = `dots' + 1
  }
  }
  }

*** end individual time-series loop for G-stats
}


if "`mg'" ~= "" & `bootno' {
tempname dev bbb VVV  
local div = 1/`nobs'
matrix `bbb' = J(1,`nobs',1/`nobs')*`allb'
matrix `dev'=`allb'-(J(`nobs',1,1)#(J(1,`nobs',`div')*`allb'))
matrix `VVV'=`dev''*`dev'/(`nobs'*(`nobs'-1))
local names : colnames `bbb'
local names : subinstr local names "`cons'" "ec:_cons"
local names : subinstr local names "`tren'" "ec:trend"
local names : subinstr local names "L.`yvar'" "SR:_ec"
local names = subinstr("`names'","L.","ec:",.)
matrix colnames `bbb' = SR:
matrix colnames `VVV' = SR:
matrix rownames `VVV' = SR:
matrix colnames `bbb' = `names'
matrix colnames `VVV' = `names'
matrix rownames `VVV' = `names'

tempname dev2 bbb2 VVV2  
local div2 = 1/`nobs'
matrix `bbb2' = J(1,`nobs',1/`nobs')*`allorigb'
matrix `dev2'=`allorigb'-(J(`nobs',1,1)#(J(1,`nobs',`div')*`allorigb'))
matrix `VVV2'=`dev2''*`dev2'/(`nobs'*(`nobs'-1))
local names : colnames `bbb2'
local names : subinstr local names "`cons'" "_cons"
local names : subinstr local names "`tren'" "trend"
matrix colnames `bbb2' = _:
matrix colnames `VVV2' = _:
matrix rownames `VVV2' = _:
matrix colnames `bbb2' = :`names'
matrix colnames `VVV2' = :`names'
matrix rownames `VVV2' = :`names'

xtwestmgdisplay `bbb' `VVV' `bbb2' `VVV2' `auto'

}


if `debug' {
di "before calculation p-stats, in plain"
}

*** for p-stats, repeat calculation of aonesemi & work with average optimal lag/lead length determined above.
tempvar tag aonesemipool epool 
qui egen `tag' = tag(`ai')
qui gen `aonesemipool' = .
qui gen `epool' = .

qui sum `lags' if `tag' == 1, meanonly
local meanlag = int(r(mean))
local realmeanlag = r(mean)
qui sum `leads' if `tag' == 1, meanonly
local meanlead = int(r(mean))
local realmeanlead = r(mean)

qui replace `dytmp' = d.`yvar' 

if `westerlund' {
qui replace `dytmp' = . if l`meanlag'.d.`yvar' >= .
qui replace `dytmp' = . if f`meanlead'.d.`yvar' >= .
}


tempvar meandytmp

*** DETRENDING
if !`westerlund' {
if `constant' & `trend' {
egen `meandytmp' = mean(`dytmp'), by(`id')
qui replace `dytmp' = `dytmp' - `meandytmp'
}
}

qui levels `id' if `touse', local(levels)
foreach l of local levels {
qui sum `n_in' if `id'==`l' & `touse', meanonly
local firstob = r(min)
local lastob  = r(max)

lrvar `dytmp' in `firstob'/`lastob', maxlag(`lrwindow') weighted nodemean
local wysq = r(lrvar) 

if `meanlag' > 0 {
qui   reg d.`yvar' `cons' `tren' l.`yvar' l.(`xvars') L(1/`meanlag')D.`yvar' L(-`meanlead'/`meanlag')D.(`xvars') in `firstob'/`lastob', nocons
   }
else {
qui   reg d.`yvar' `cons' `tren' l.`yvar' l.(`xvars') L(-`meanlead'/`meanlag')D.(`xvars') in `firstob'/`lastob', nocons
}

mat b = e(b)
qui matrix score `e' = b if e(sample), replace
qui replace `epool' = d.`yvar' - `e' if e(sample)

qui replace `u' = d.`yvar'  - _b[`cons'] - _b[`tren']*`t' - l.`yvar'*b[1,3] in `firstob'/`lastob'
forv j = 1/`nox' {
  local dezex: word `j' of `xvars'
  qui replace `u' = `u' - l.`dezex'*b[1,3+`j'] in `firstob'/`lastob'
}
forvalues v = 1/`meanlag' {
  qui replace `u' = `u' - b[1,3+`nox'+`v']*L`v'D.`yvar' in `firstob'/`lastob'
}

qui replace `tmpu' = `u' in `firstob'/`lastob'
if `westerlund' {
qui replace `tmpu' = . if l`meanlag'.d.`yvar' >= . in `firstob'/`lastob'
qui replace `tmpu' = . if f`meanlead'.d.`yvar' >= . in `firstob'/`lastob'
}

lrvar `tmpu' in `firstob'/`lastob', maxlag(`lrwindow') weighted nodemean
local wusq = r(lrvar)
qui replace `aonesemipool' = sqrt(`wusq'/`wysq') in `firstob'/`lastob'


if `meanlag' > 0 {
qui   reg d.`yvar' `cons' `tren' l.(`xvars') L(1/`meanlag')D.`yvar' L(-`meanlead'/`meanlag')D.(`xvars') in `firstob'/`lastob', nocons
   }
else {
qui   reg d.`yvar' `cons' `tren' l.(`xvars') L(-`meanlead'/`meanlag')D.(`xvars') in `firstob'/`lastob', nocons
}
matrix b = e(b)
qui matrix score `dyresid' = b in `firstob'/`lastob', replace
qui replace `dyresid' = d.`yvar' - `dyresid' in `firstob'/`lastob'

                       
if `meanlag' > 0 {
qui   reg l.`yvar' `cons' `tren' l.(`xvars') L(1/`meanlag')D.`yvar' L(-`meanlead'/`meanlag')D.(`xvars') in `firstob'/`lastob', nocons
   }
else {
qui   reg l.`yvar' `cons' `tren' l.(`xvars') L(-`meanlead'/`meanlag')D.(`xvars') in `firstob'/`lastob', nocons
}
matrix b = e(b)
qui matrix score `yresid' = b in `firstob'/`lastob', replace
qui replace `yresid' = l.`yvar' - `yresid' in `firstob'/`lastob'
}

if `debug' {
di "regressions p-stats ok"
}

*****
** part 2: caculate the statistics 
*****

tempvar ainorm GT tnorm gai GA ganorm  gtnorm tnorm tnormwest tnormalt alttnorm
tempvar ptnorm panorm pooledalphatoptmp pooledalphabottomtmp pooledalphatop pooledalphabottom pooledalpha PA PT
tempvar sigmai sigmasqi esq si sisq se_pooledalpha alpha_PT

if `westerlund' {
qui gen `tnorm' = `ti' - `lags' - `leads' - 1
qui gen `alttnorm' = `ti' - `lags' - `leads' - 1 - (`constant'+`trend') - 1 - `nox' - `lags' - `nox'*(`lags'+`leads'+1) 
qui replace `seai' = `seai'*sqrt(`alttnorm')/sqrt(`tnorm')
}
else {
qui gen `tnorm' = `ti' - `lags' - `leads' - 1 - (`constant'+`trend') - 1 - `nox' - `lags' - `nox'*(`lags'+`leads'+1) 
qui gen `tnormwest' = `ti' - `lags' - `leads' - 1
}

*** GT statistic
qui gen `ainorm' = `ai'/`seai' 
qui egen `GT' = mean(`ainorm') if `tag' == 1
qui sum `GT', meanonly
local Gt = r(mean)

*** GA statistic
qui gen `gai' = `tnorm'*`ai'/`aonesemi'
qui egen `GA' = mean(`gai') 
qui sum `GA', meanonly
local Ga = r(mean)

*** Pooled statistics
qui gen `pooledalphatoptmp' = (1/`aonesemipool')*`yresid'*`dyresid'
qui egen `pooledalphatop' = sum(`pooledalphatoptmp') 
qui gen `pooledalphabottomtmp' = `yresid'^2
qui egen `pooledalphabottom' = sum(`pooledalphabottomtmp') 
qui gen `pooledalpha' = `pooledalphatop'/`pooledalphabottom'

** for the pooled estimator, we take the average lag length to normalise
if `westerlund' {
qui replace `tnorm' = `meanbigT' - `meanlag' - `meanlead' - 1
}
else {
qui replace `tnorm' = `meanbigT' - `meanlag' - `meanlead' - 1 - (`constant'+`trend') - 1 - `nox' - `meanlag' - `nox'*(`meanlag'+`meanlead'+1)
}

qui gen `esq' = `epool'*`epool'
qui by `id': egen `sigmasqi' = sum(`esq')
qui gen `sigmai' = sqrt(`sigmasqi'/`tnorm')
qui gen `si' = `sigmai' / `aonesemipool'
qui gen `sisq' = `si'*`si'
qui sum `sisq' if `tag' == 1, meanonly
qui gen `se_pooledalpha' = sqrt(r(mean))/sqrt(`pooledalphabottom')

*** PT statistic
qui gen `PT' = `pooledalpha'/`se_pooledalpha' 
qui sum `PT', meanonly
local Pt = r(mean)

*** PA statistic
qui gen `PA' = `tnorm'*`pooledalpha'
qui sum `PA', meanonly
local Pa = r(mean)

return scalar Gt = `Gt'
return scalar Ga = `Ga'
return scalar Pt = `Pt'
return scalar Pa = `Pa'
return scalar meanlag = `meanlag'
return scalar meanlead = `meanlead'
return scalar realmeanlag = `realmeanlag'
return scalar realmeanlead = `realmeanlead'
return scalar auto = `auto'

end



					**********************************************



program define DisplayWesterlund, rclass 
version 8
syntax [, mg stats(string) bootstats(string) nobs(integer -1) nox(integer -1) constant trend meanlag(integer -1) meanlead(integer -1) realmeanlag(real -1) realmeanlead(real -1) auto(integer -1) westerlund]

local constant = "`constant'"!=""
local trend = "`trend'"!=""
local westerlund = "`westerlund'"!=""

if "`stats'"!="" {
tempvar STATS
matrix `STATS' = `stats'
local gt = `STATS'[1,1] 
local ga = `STATS'[1,2] 
local pt = `STATS'[1,3] 
local pa = `STATS'[1,4] 
}

*** calculating z-stats.

di ""
di ""
di as txt "Results for H0: no cointegration"
if `nox' > 1 {
di as txt "With `nobs' series and `nox' covariates"
}
else {
di as txt "With `nobs' series and 1 covariate"
}
if `auto' {
local roundedrealmeanlag = round(`realmeanlag',0.01)
di as txt "Average AIC selected lag length: `roundedrealmeanlag'"
local roundedrealmeanlead = round(`realmeanlead',0.01)
di as txt "Average AIC selected lead length: `roundedrealmeanlead'"
}
di ""

if `westerlund' {
if !`trend' {
  local gtnorm = ( sqrt(`nobs')*`gt'-sqrt(`nobs')*(-1.793) ) / sqrt(0.7904)
  local ganorm = ( sqrt(`nobs')*`ga'-sqrt(`nobs')*(-7.2014) ) / sqrt(29.3677)
  local ptnorm = ( `pt' - sqrt(`nobs')*(-1.4746) ) / sqrt(1.0262)
  local panorm = ( sqrt(`nobs')*`pa'-sqrt(`nobs')*(-4.3559) ) / sqrt(21.0535)
}
else {
  local gtnorm = ( sqrt(`nobs')*`gt'-sqrt(`nobs')*(-2.356) ) / sqrt(0.6450)
  local ganorm = ( sqrt(`nobs')*`ga'-sqrt(`nobs')*(-11.8978) ) / sqrt(44.2471)
  local ptnorm = ( `pt' - sqrt(`nobs')*(-2.1128) ) / sqrt(0.7371)
  local panorm = ( sqrt(`nobs')*`pa'-sqrt(`nobs')*(-8.9536) ) / sqrt(35.6802)
}
}
else {
** matrices are of dimension 3X6, 3 "number of deterministic terms" rows, 6 "number of xvars" columns
matrix gtmean = (-0.9763,-1.3816,-1.7093,-1.9789,-2.1985,-2.4262\-1.7776,-2.0349,-2.2332,-2.4453,-2.6462,-2.8358\-2.3664,-2.5284,-2.7040,-2.8639,-3.0146,-3.1710)
matrix gamean = (-3.8022,-5.8239,-7.8108,-9.8791,-11.7239,-13.8581\-7.1423,-9.1249,-10.9667,-12.9561,-14.9752,-17.0673\-12.0116,-13.6324,-15.5262,-17.3648,-19.2533,-21.2479)
matrix ptmean = (-0.5105,-0.9370,-1.3169,-1.6167,-1.8815,-2.1256\-1.4476,-1.7131,-1.9206,-2.1484,-2.3730,-2.5765\-2.1124,-2.2876,-2.4633,-2.6275,-2.7858,-2.9537)
matrix pamean = (-1.0263,-2.4988,-4.2699,-6.1141,-8.0317,-10.0074\-4.2303,-5.8650,-7.4599,-9.3057,-11.3152,-13.3180\-8.9326,-10.4874,-12.1672,-13.8889,-15.6815,-17.6515)

matrix gtvar  = (1.0823,1.0981,1.0489,1.0576,1.0351,1.0409\0.8071,0.8481,0.8886,0.9119,0.9083,0.9236\0.6603,0.7070,0.7586,0.8228,0.8477,0.8599)
matrix gavar  = (20.6868,29.9016,39.0109,50.5741,58.9595,69.5967\29.6336,39.3428,49.4880,58.7035,67.9499,79.1093\46.2420,53.7428,64.5591,74.7403,84.7990,94.0024)
matrix ptvar  = (1.3624,1.7657,1.7177,1.6051,1.4935,1.4244\0.9885,1.0663,1.1168,1.1735,1.1684,1.1589\0.7649,0.8137,0.8857,0.9985,0.9918,0.9898)
matrix pavar  = (8.3827,24.0223,39.8827,53.4518,63.2406,76.6757\19.7090,31.2637,42.9975,57.4844,69.4374,81.0384\37.5948,45.6890,57.9985,74.1258,81.3934,91.2392)

local gtnorm = ( sqrt(`nobs')*`gt'-sqrt(`nobs')*(gtmean[`constant'+`trend'+1,`nox'])) / sqrt(gtvar[`constant'+`trend'+1,`nox'])
local ganorm = ( sqrt(`nobs')*`ga'-sqrt(`nobs')*(gamean[`constant'+`trend'+1,`nox'])) / sqrt(gavar[`constant'+`trend'+1,`nox'])
local ptnorm = ( `pt' - sqrt(`nobs')*(ptmean[`constant'+`trend'+1,`nox'])) / sqrt(ptvar[`constant'+`trend'+1,`nox'])
local panorm = ( sqrt(`nobs')*`pa'-sqrt(`nobs')*(pamean[`constant'+`trend'+1,`nox']) ) / sqrt(pavar[`constant'+`trend'+1,`nox'])
}

*** the stat option is given only after bootstrap completion 
*** its argument is a matrix containing the bootstrapped statistics

if "`bootstats'" == "" {
di in smcl as txt "{hline 11}{c TT}{hline 11}{c TT}{hline 11}{c TT}{hline 11}{c TRC}"
di in smcl as txt " Statistic {c |}   Value   {c |}  Z-value  {c |}  P-value  {c |}"
di in smcl as txt "{hline 11}{c +}{hline 11}{c +}{hline 11}{c +}{hline 11}{c RT}"
di "     Gt    {c | } " as res %8.3f `gt' as txt "  {c |} " as res %8.3f `gtnorm' as txt "  {c |}" as res %8.3f round(normal(`gtnorm'),0.0001) as txt "   {c |}"
di "     Ga    {c | } " as res %8.3f `ga' as txt "  {c |} " as res %8.3f `ganorm' as txt "  {c |}" as res %8.3f round(normal(`ganorm'),0.0001) as txt "   {c |}"
di "     Pt    {c | } " as res %8.3f `pt' as txt "  {c |} " as res %8.3f `ptnorm' as txt "  {c |}" as res %8.3f round(normal(`ptnorm'),0.0001) as txt "   {c |}"
di "     Pa    {c | } " as res %8.3f `pa' as txt "  {c |} " as res %8.3f `panorm' as txt "  {c |}" as res %8.3f round(normal(`panorm'),0.0001) as txt "   {c |}"
di in smcl as txt "{hline 11}{c BT}{hline 11}{c BT}{hline 11}{c BT}{hline 11}{c BRC}"
}
else{

tempname BOOTSTATS GTSTATS GASTATS PTSTATS PASTATS
matrix `BOOTSTATS' = `bootstats'

matrix `GTSTATS' = `BOOTSTATS'[1...,1]
matrix `GASTATS' = `BOOTSTATS'[1...,2]
matrix `PTSTATS' = `BOOTSTATS'[1...,3]
matrix `PASTATS' = `BOOTSTATS'[1...,4] 

qui count
local origobs = r(N)
local rows = rowsof(`BOOTSTATS')
if `rows' > r(N) {
local addedobspastrows = 1
qui set obs `rows'
}
else {
local addedobspastrows = 0
}


matvsort `GTSTATS' `GTSTATS'
matvsort `GASTATS' `GASTATS'
matvsort `PTSTATS' `PTSTATS'
matvsort `PASTATS' `PASTATS'

local diff = 0
local position = 0
forvalues i = 1/`rows' {
local diff = `GTSTATS'[`i',1] - `gt'
local GTSTAT = `GTSTATS'[`i',1]
if `diff' > 0 {
continue, break
}
local position = `position' + 1
}
local pvaluegtboot = `position'/`rows'

local diff = 0
local position = 0
forvalues i = 1/`rows' {
local diff = `GASTATS'[`i',1] - `ga'
if `diff' > 0 {
continue, break
}
local position = `position' + 1
}
local pvaluegaboot = `position'/`rows'

local diff = 0
local position = 0
forvalues i = 1/`rows' {
local diff = `PTSTATS'[`i',1] - `pt'
if `diff' > 0 {
continue, break
}
local position = `position' + 1
}
local pvalueptboot = `position'/`rows'

local diff = 0
local position = 0
forvalues i = 1/`rows' {
local diff = `PASTATS'[`i',1] - `pa'
if `diff' > 0 {
continue, break
}
local position = `position' + 1
}
local pvaluepaboot = `position'/`rows'


di in smcl as txt "{hline 11}{c TT}{hline 11}{c TT}{hline 11}{c TT}{hline 11}{c TT}{hline 16}{c TRC}"
di in smcl as txt " Statistic {c |}   Value   {c |}  Z-value  {c |}  P-value  {c |} Robust P-value {c |}"
di in smcl as txt "{hline 11}{c +}{hline 11}{c +}{hline 11}{c +}{hline 11}{c +}{hline 16}{c RT}"
di "     Gt    {c | } " as res %8.3f `gt' as txt "  {c |} " as res %8.3f `gtnorm' as txt "  {c |}" as res %8.3f round(normal(`gtnorm'),0.0001) as txt "   {c |}   " as res %8.3f round(`pvaluegtboot',0.0001) as txt "     {c |} "
di "     Ga    {c | } " as res %8.3f `ga' as txt "  {c |} " as res %8.3f `ganorm' as txt "  {c |}" as res %8.3f round(normal(`ganorm'),0.0001) as txt "   {c |}   " as res %8.3f round(`pvaluegaboot',0.0001) as txt "     {c |} "
di "     Pt    {c | } " as res %8.3f `pt' as txt "  {c |} " as res %8.3f `ptnorm' as txt "  {c |}" as res %8.3f round(normal(`ptnorm'),0.0001) as txt "   {c |}   " as res %8.3f round(`pvalueptboot',0.0001) as txt "     {c |} "
di "     Pa    {c | } " as res %8.3f `pa' as txt "  {c |} " as res %8.3f `panorm' as txt "  {c |}" as res %8.3f round(normal(`panorm'),0.0001) as txt "   {c |}   " as res %8.3f round(`pvaluepaboot',0.0001) as txt "     {c |} "
di in smcl as txt "{hline 11}{c BT}{hline 11}{c BT}{hline 11}{c BT}{hline 11}{c BT}{hline 16}{c BRC}"


if `addedobspastrows' == 1 {
qui drop if _n > `origobs'
}

return scalar gt_pvalboot = `pvaluegtboot'
return scalar ga_pvalboot = `pvaluegaboot'
return scalar pt_pvalboot = `pvalueptboot'
return scalar pa_pvalboot = `pvaluepaboot'

** end of stats-condition (only ran after completed bootstrap) 
}


return scalar gt_pval = normal(`gtnorm')
return scalar ga_pval = normal(`ganorm')
return scalar pt_pval = normal(`ptnorm')
return scalar pa_pval = normal(`panorm')

return scalar gt_z = `gtnorm'
return scalar ga_z = `ganorm'
return scalar pt_z = `ptnorm'
return scalar pa_z = `panorm'

return scalar gt = `gt'
return scalar ga = `ga'
return scalar pa = `pa'
return scalar pt = `pt'


end


*****
***** separate procedure for calculating long-run variance (with optional bartlett weights,...)
*****

program define xtwestregdisplay, eclass 
version 8
args bb VV
eret post `bb' `VV'
di ""
eret disp
end


program define xtwestmgdisplay, eclass 
version 8
args b V b2 V2 auto 

eret post `b2' `V2' 
di ""
di ""
di as txt "Mean-group error-correction model"
if `auto' {
di as txt "Short run coefficients apart from the error-correction term are omitted as lag and lengths might differ between cross-sectional units"
di ""
}
eret disp


eret post `b' `V' 
di ""
di as txt "Estimated long-run relationship and short run adjustment"
eret disp


end

    

program define lrvar, rclass
version 8
syntax varlist(ts) [if] [in] [,  Weighted Nodemean Maxlag(integer -1) ]

marksample touse
markout `touse' `timevar'

tempname lrvar T J gamma
local nodemean = "`nodemean'"!=""
local d `1'
local dbar 0
qui summ `d' if `touse'
local T = r(N)
local dbar = r(mean)
if `nodemean' {
  local dbar = 0
}

* generate autocovariances of y series
local varlist2 L(0/`maxlag').`d'
tsrevar `varlist2'
local varlist3 `r(varlist)'
local ml1 = `maxlag'+1
mata:  cov("`varlist3'",`dbar',"`touse'")
scalar `J' = __gamma[1,1]
forv l = 1/`maxlag' {
  * uniform kernel is unweighted; otherwise use Bartlett kernel
  local w 1
  if "`weighted" != "" {
    local w = 1 - (`l'/(`maxlag'+1))
  }
  scalar `J' = `J' + 2*`w'*__gamma[`l'+1,1]
}       
scalar `lrvar' = `J'/`T'
if `lrvar'==. {
  di _n "Long-run variance is non-positive for this kernel and truncation lag."
  error 506
}
return scalar lrvar = `lrvar'
end


mata:
void cov(string scalar vname, real scalar dbar, string scalar touse)
{
  real matrix X, gamma
  string rowvector vars
  string scalar v
  // access the Stata variables in varlist, respecting touse
  vars = tokens(vname)
  v = vars[|1,.|]
  st_view(X,.,v,touse)
  // demean by dbar
  X = X :- dbar
  // change all missing values to 0, which will be ignored in cross
  _editmissing(X,0)
  // apply cross to get the covariances and scale by T
  gamma = cross(X,X) 
  // return the __gamma matrix
  st_matrix("__gamma",gamma)
}
end




