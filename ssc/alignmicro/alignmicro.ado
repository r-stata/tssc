/* 
Alignment Calibration for Microsimulation Models in Stata
Jinjing Li 

version 0.98
Last Updated: 2 July 2013

Ref: Li, J., & O’Donoghue, C. (2014). Evaluating Binary Alignment Methods in Dynamic Microsimulation Models. Journal of Artificial Society and Simulation, 17(1). 

Syntax:

alignmicro prob if a==1, target(0.8) outcome(variable) method(1) 
alignmicro prob if a==1, target(523) outcome(variable) method(sbp)

prob: input probability
target: percentage of positive outcome
outcome: save aligned variable as a new one
method: which method to use
outprob: save the aligned probability  (under development)

[if]: alignmicro supports if conditions

*/

*! version 0.9.8    2Jul2013
program define alignmicro, rclass
	version 9.0
	syntax varlist(min=1 max=1) [if], target(real) outcome(name) [method(string) outprob(name) est(string) weight(name) reserve(name)]
	* set trace on
	confirm new variable `outcome'
	if "`outprob'" !="" {
		confirm new variable `outprob'
	}
	if (`target'<0) {
		display as error "Invalid target ratio or target number"
		exit 198
	}
	else if (`target' >1 ){
		local totalalign=int(`target')
		if (`target' != `totalalign') {
			display as error "The number of events must be an integer"
			exit 198
		}
		qui sum `varlist' `if'
		local target = `target' / r(N)
	}
	else if (`target' <=1) {
		qui sum `varlist' `if'
		local totalalign=round(`target'*r(N))
	}
	
	timer clear 99
	timer on 99

	* method 1 : Multiplicative scaling
	if ("`method'" == "1" | "`method'" == "ms") {
		tempname np
		qui sum `varlist' `if'
		qui gen `np' = `varlist'*`target'/r(mean) `if'
		qui gen `outcome'=`np'>uniform() `if'
		if ("`outprob'"!="") {
			qui gen `outprob'=`np' `if'
		}
		local methodname "multiplicative scaling"
	}
	* method 2: sidewalk
	else if ("`method'" == "2" | "`method'" == "sidewalk") {
		tempname np npc npcd
		qui sum `varlist' `if'
		qui gen `np' = `varlist'*`target'/r(mean) `if'
		qui gen `npc'=sum(`np') `if'
		qui gen `npcd'=`npc'
		qui replace `npcd'=`npcd'[_n-1] if `npcd'==.
		qui gen `outcome'=(int(`npc')-int(`npcd'[_n-1]))==1 `if'
		local methodname "sidewalk basic"
	}
	
	* Sidewalk Hybrid Method with nonlinear adjustment
	else if ("`method'" == "3" | "`method'" == "sidewalknl") {
		tempname np order o u nlv 
		qui gen `u'=uniform() `if'
		qui sum `varlist' `if'
		qui gen `np' =`varlist' `if'
		qui gen `nlv' = .
		qui sum `np'
		local diff=abs(`target'-r(mean))
		while (`diff'>0){
			local gp = ln(`target'/(1-`target'))-ln(r(mean)/(1-r(mean))) //extra adjustment in logit
			qui replace `nlv'=ln(`np'/(1-`np'))+ `gp' `if'
			qui replace `np' = exp(`nlv')/ (1+exp(`nlv')) `if'
			qui sum `np' `if'
			if (`diff' <= abs(`target'-r(mean))) {
				local diff = 0
				qui replace `np' = exp(`nlv'-`gp')/(1+exp(`nlv'-`gp')) `if' //revert to optimal
			} 
			else {
				local diff = abs(`target'-r(mean))
			}
		}
		qui sum `np' `if'
		local out=0
		local sidevar=0
		qui gen `outcome'=.
		qui gen `order' = _n
		// move the observations under if condition first while save the orginal order in "order"
		qui egen `o' = rank(`order') `if', track
		qui sum `o'
		local obs=r(max)
		sort `o'
		forvalues i=1/`obs'{
			local sidevar = `sidevar' + `np'[`i']
			if ((`sidevar' - `out') > 0.5) {
					qui replace `outcome'=(`u'[`i'] - min(`np'[`i']/2,(1-`np'[`i'])/2,0.03))< `np'[`i'] in `i'
				}
				else {
					qui replace `outcome'=(`u'[`i'] + min(`np'[`i']/2,(1-`np'[`i'])/2,0.03))< `np'[`i'] in `i'
				}
			local out = `out' + `outcome'[`i']
		}
		sort `order'
		local methodname "sidewalk hybrid"
	}
	
	* Central Limit Theorem
	else if ("`method'" == "4" | "`method'" == "clt") {
		tempname order o psum
		qui gen `outcome'=.
		local out=0
		gen `order' = _n
		qui egen `o' = rank(`order') `if', unique
		qui sum `o'
		local obs=r(max)
		if ("`outprob'"!="") {
			local totalalign=`target'*`obs'
		}
		sort `o'
		//need a total probabilty and left probabilty
		qui egen `psum'=sum(`varlist') `if'
		local leftp=`psum'[1]
		forvalues i=1/`obs'{
			qui replace `outcome' = (`varlist'[`i']/`leftp'*(`totalalign'-`out'))> uniform() in `i'
			local out = `out' + `outcome'[`i']
			local leftp = `leftp' - `varlist'[`i']
		}
		sort `order'
		local methodname "central limit"
	}
	* method 5: Sidewalk Shuffle without wraparound and zero setting Morrison (2006) (require m1)
	else if ("`method'" == "5" | "`method'" == "sidewalks") {
		tempname np	npc
		qui sum `varlist' `if'
		qui gen `np' = `varlist'*`target'/r(mean) `if'
		tempname npcd
		qui gen `npc'=sum(`np')+uniform() `if'
		qui gen `npcd'=`npc'
		qui replace `npcd'=`npcd'[_n-1] if `npcd'==.
		qui gen `outcome'=(int(`npc')-int(`npcd'[_n-1]))==1 `if'
		local methodname "sidewalk"
	}
	* method 6 : Alignment by sorting (simple sorting)
	else if ("`method'" == "6" | "`method'" == "sbp") {
		tempname sortrank
		qui egen `sortrank'=rank(-`varlist') `if', unique
		qui sum `sortrank' `if'
		local obs=r(max)
		if ("`outprob'"!="") {
			local totalalign=`target'*`obs'
		}
		qui gen `outcome'=(`sortrank'<=`totalalign') `if'
		local methodname "SBP"
	}
	* method 7: Alignment by sorting (difference of p adjusted sorting)
	else if ("`method'" == "7" | "`method'" == "sbd") {
		tempname sortrank 
		qui egen `sortrank'=rank(uniform()-`varlist') `if', unique
		qui sum `sortrank' `if'
		local obs=r(max)
		if ("`outprob'"!="") {
			local totalalign=`target'*`obs'
		}
		qui gen `outcome'=(`sortrank'<=`totalalign') `if'
		local methodname "SBD"
	}
	* method 8: Alignment by sorting (difference of logistic p adjusted sorting)
	else if ("`method'" == "8" | "`method'" == "sbdl") {
		tempname sortrank logitu
		qui gen `logitu'=-ln(1/uniform()-1) `if'
		qui egen `sortrank'=rank(`logitu'+ln((1-`varlist')/`varlist')) `if', unique
		qui sum `sortrank' `if'
		local obs=r(max)
		if ("`totalalign'"=="") {
			local totalalign=`target'*`obs'
		}
		qui gen `outcome'=(`sortrank'<=`totalalign') `if'
		local methodname "SBDL"
	}
	else {
		display as error "Invalid alignment method specified"
		exit 198	
	}
	
	
	
	* display "Alignment finished (`methodname'), output variable: `outcome'"
	timer off 99
	qui timer list 99
	return scalar ctime=r(t99)
	return local method "`method'"

end
