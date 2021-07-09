*! v.1.0.0 Orsini N, Jansky I 5oct18
capture program drop reu
program define reu , rclass
syntax [varlist] [, SE(string) ] 
version 11.0
qui count if e(sample)
local ntouse = r(N)
tempvar touse
gen `touse' = e(sample)

local getcmd : word 1 of `e(cmdline)'
local cmd `e(cmdline)'

if "`se'" != "" { 
				local stderr = `se'
				}
else {

		if "`getcmd'" == "binreg" {		  
			if "`e(varfunct)'" == "Bernoulli" & "`e(linkt)'" == "Identity" {
				   local stderr = 0.00002
			}
			if "`e(varfunct)'" == "Bernoulli" & "`e(linkt)'" == "Log" {
				   local stderr = 0.002
			}
			if "`e(varfunct)'" == "Bernoulli" & "`e(linkt)'" == "Logit" {
				   local stderr = 0.004
			}
			
		}

		if "`getcmd'" == "regress" {
					  local stderr = 0.00002
		}

		if inlist("`getcmd'", "logit", "logistic") == 1 {
					  local stderr = 0.004
		}

		if inlist("`getcmd'", "poisson") == 1 {
					  local stderr = .0028284
		}
		
		if "`getcmd'" == "glm" {

			if "`e(varfunct)'" == "Bernoulli" {
				  if inlist("`e(linkt)'", "Logit") == 1 local stderr = 0.004
			}
			
			
			if "`e(varfunct)'" == "Bernoulli" {
				  if inlist("`e(linkt)'", "Log") == 1 local stderr = 0.002
			}
			
			if "`e(varfunct)'" == "Bernoulli" {
				  if inlist("`e(linkt)'", "Identity") == 1 local stderr = 0.00002
			}
			
			if "`e(varfunct)'" == "Gaussian" {
				  if inlist("`e(linkt)'", "Identity") == 1 local stderr = 0.00002
			}

			if "`e(varfunct)'" == "Poisson" {
				  if inlist("`e(linkt)'", "Log") == 1 local stderr = .0028284
			}
		}

		if inlist("`getcmd'", "stcox", "streg") == 1 {
					  local stderr = .0028284
		}
}		

if "`stderr'" == "" {
		di as err "previously model fitted not recognized. Please specify option se()"
		exit 198
}
		
if "`varlist'" == "" {
	di as err "specify the name of at least one predictor"
	exit 198
}

tempvar tag
tempname uniq

foreach v of local varlist {
		capture drop `tag'
		qui bys `touse' `v': gen byte `tag'= 1 if _n==1 & `touse'

		qui count if `tag'==1 & !missing(`v') & `touse'
		local uniq = r(N)
		
		if `uniq' > 2 local binary 0
		else local binary 1 

		if (`binary' == 0) {
				tempvar b se nrperc  perc
				qui gen `b' = .
				qui gen `se' = .
				qui gen `nrperc' = .
				qui gen `perc' = .
			
			_pctile `v', percentile(1(1)99)

			local past `: di=r(r1)'
			local listperc "`past'"

			forv i = 2/99 {
				if  (`=r(r`i')' != `past') {
											local listperc "`listperc' `=r(r`i')'"
											local past  "`=r(r`i')'"
				}
			}
						
			local j = 1
			
			 foreach i of local listperc {
				tempvar `v'`j'
			    capture drop ``v'`j''
				qui gen ``v'`j'' = (`v' > `i') if `touse'  
				
				local newcmd = regexr( "`cmd'","`v'", "``v'`j''")
						
				qui `newcmd'
				
				qui replace `b' = _b[``v'`j''] in `j'
				qui replace `se' = _se[``v'`j''] in `j'
				qui replace `nrperc' = `j' in `j'
				qui replace `perc' = `i' in `j'

				local j = `j' + 1
			}
		 
			tempname `v'`min'  `v'reu
			tempvar tag2 first
			qui su `se' if `se' != 0, d
			qui gen `tag2' = (`se' == r(min))
			qui gen  ``v'reu' = (`se'/`stderr')^2 if `tag2' == 1
			
			qui bysort `tag2' : gen `first' = _n == 1
			
			char `perc'[varname] "cut-off" 
			char `b'[varname] "beta"
			char `se'[varname] "std err"
			char ``v'reu'[varname] "REU"
			
			di _n as txt "Random Error Unit (REU) for " as res "`v'"
			list  `perc' `b' `se'  ``v'reu' if `tag2' == 1 & `first'==1, clean noobs subvarname
			qui su `perc' if `tag2' == 1 & `first'==1
			return scalar cutoff_`v' = r(mean)
			qui su `b' if `tag2' == 1 & `first'==1
			return scalar cutoff_b_`v' = r(mean)
			qui su `se' if `tag2' == 1 & `first'==1
			return scalar cutoff_se_`v' = r(mean)
			qui su ``v'reu'  if `tag2' == 1 & `first'==1
			return scalar reu_`v' = r(mean)
		}
	if (`binary' == 1) {
				tempvar b se `v'reu tag3
				qui gen `b' = _b[`v']
				qui gen `se' =  _se[`v']
				qui gen  ``v'reu' = (`se'/`stderr')^2 
				gen `tag3' = (_n==1) 
				char `b'[varname] "beta"
				char `se'[varname] "std err"
				char ``v'reu'[varname] "REU"
				di _n as txt "Random Error Unit (REU) for " as res "`v'"
			    list   `b' `se'  ``v'reu' if `tag3' == 1 , clean noobs subvarname
				qui su ``v'reu'  if `tag3' == 1  
				return scalar reu_`v' = r(mean)
   }
				
}

return scalar stderr = `stderr'
end

exit

use "http://www.stats4life.se/data/hyponatremia.dta", clear

glm nas135 female, fam(binomial) link(log)
reu female
ret list


binreg nas135  female  , rr
reu female
ret list

exit
binreg nas135  female  , rr
reu female
ret list

binreg nas135  female  , or
reu female
ret list
exit


// Odds Ratios

glm nas135 wtdiff bmi runtime female urinat3p, fam(bin) link(logit)
reu wtdiff bmi female
ret list

// Risk Differences

glm nas135  female  , fam(bin) link(identity)
reu female
reg nas135  female   
reu female
binreg nas135  female   , rd
reu female
exit
// Hazard Ratios

stset runtime, f(nas135)
stcox wtdiff bmi female 
reu wtdiff bmi female
ret list
streg wtdiff female bmi, dist(exp)
reu wtdiff bmi female
ret list
log close





