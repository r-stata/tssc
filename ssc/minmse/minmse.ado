/*
 Authors 
 Sebastian Schneider, sschneider@coll.mpg.de; sebastian@sebastianschneider.eu

 Copyright (C) 2021 Sebastian Schneider

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 3
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.  
*/

*********************************************************************
**** Min MSE Treatment Assignment for multiple Treatment Groups *****
*********************************************************************


* Program to evaluate a given treatment assignment
capture program drop evaluateSolution
program evaluateSolution, rclass
	* Written for Stata Version 13.1
	version 13.1
	* Program expects (nothing but) a varlist as argument
	syntax varname(numeric), Covariates(varlist)

	* First variable of varlist is the solution to be evaluated; remaining variables are the covariates for evaluation. Prepare internal variables
	local n_vars = wordcount("`covariates'")
	scalar n_vars = `n_vars'
	
	qui sum `varlist', detail
	local treatments = `r(max)'
	scalar treatments = `treatments'
	scalar N = _N

	order `covariates'

	* Prepare reading-in in Mata
	local treatment_vars ""
	forvalues i = 0/`treatments' {
		tempname treatment`i'
		qui gen `treatment`i'' = 1 if `varlist' == `i'
		qui replace `treatment`i'' = 0 if missing(`treatment`i'')
		local treatment_vars = "`treatment_vars' `treatment`i''"
	}
	
	* Call Mata function defined below
	mata: calcScoreFunction("`treatment_vars'")
	
	* Return evaluated Value
	return scalar evaluatedValue = r(evaluatedValue)
end


* Mata Code to evaluate a given treatment assignment
capture mata: mata drop calcScoreFunction()
version 13.1
mata:
mata set matastrict on
void calcScoreFunction(string scalar varlist)
{
	real matrix       sum_of_inv_xt, x_full, mean_of_xi
	real scalar       n_treatments, n_vars, evaluatedValue, i
	pointer matrix 	  x
	string rowvector  treatment
	
	treatment = tokens(varlist)

	n_treatments = st_numscalar("treatments")
	n_vars = st_numscalar("n_vars")
	
	// Treatment-wise compute the ingredients for the objective function
	x=J(1,n_treatments+1,NULL)
	
	sum_of_inv_xt = J(n_vars,n_vars,0)
	for (i=1; i<=n_treatments+1; i++)
	{
		x[1,i]=&st_data(.,1..n_vars,treatment[i])
		*x[1,i] = invsym(((*x[1,i])')*(*x[1,i]))
		
		if (i > 1) {
			*x[1,i] = (*x[1,i])+(*x[1,1])
			sum_of_inv_xt = sum_of_inv_xt + *x[1,i]
			*x[1,i] = NULL
		}
	}
	*x[1,1] = NULL
	
	st_view(x_full,.,1..n_vars,.)
	mean_of_xi = mean((x_full[.,1..n_vars]))

	// Now evaluate the solution according to the objective function
	evaluatedValue = mean_of_xi*sum_of_inv_xt*mean_of_xi'


	st_numscalar("r(evaluatedValue)", evaluatedValue)
}	
end

* Mata Code to swap treatments
capture mata: mata drop swapTreatments()
version 13.1
mata:
mata set matastrict on
void swapTreatments(string scalar varname, real scalar no_swaps)
{
	real colvector	X, Y
	
	st_view(X = ., 1::no_swaps , varname )
	do
	{
	Y = jumble(X)
	} while ((X == Y) & (colsum(X:==mean(X)) ~= no_swaps))
	X[.,.] = Y
	
}	
end

* Program to find an MSE minimizing treatment assignment
capture program drop minmse
program define minmse, rclass

* Initialize program and conduct some argument checks
	* Program was written for Stata version 13.1
	version 13.1
	* Define the command's syntax
	syntax varlist, Generate(name) [Treatments(integer 1), Iterations(integer 50), Assignment(varname numeric), Change(integer 3), COOLing(integer 1), T0(integer 10), TMax(integer 10), Plot(integer 1)]
	* Check whether the given variable name for the output of the treatment assignment is valid
	confirm new variable `generate'
	* Check whether input parameters are positive
	if (`treatments' <= 0){
		di as error "Number of treatments must be greater or equal to 1"
	}
	if (`iterations' < 1){
		di as error "Positive number of iterations needed"
	}

	* Assign internal parameters for computation
	local groups = `treatments' + 1
	local n_vars = wordcount("`varlist'")
	local N = _N
	if "`assignment'" == "" {
		tempname assignment
		quietly gen `assignment' = .
	}
	quietly sum `assignment'
	local leftToAssign = `N' - r(N)
	if `N' ~= `leftToAssign' {
		local ObsPerGroup = (`N')/(`groups')
		local ObsAdj = `N'
		local GroupsToAssign = 0
		forvalues t = 0/`treatments' {
			local leftToAssignGroup`t' = 0
			qui sum `assignment' if `assignment' == `t'
			local assignedGroup`t' = `r(N)'
			if `assignedGroup`t'' < `ObsPerGroup' {
				local leftToAssignGroup`t' = 1
			}
			else {
				local ObsAdj = `ObsAdj' - `assignedGroup`t''
			}
			local GroupsToAssign = `GroupsToAssign' + `leftToAssignGroup`t''
		}
		local ObsPerGroupAdj = `ObsAdj'/`GroupsToAssign'
		local groupsToCeil = mod(`ObsAdj',`GroupsToAssign')
		forvalues t = 0/`treatments' {
			if (`ObsPerGroupAdj' - `assignedGroup`t'') > 0 {
			local leftToAssignGroup`t' = floor((`ObsPerGroupAdj' - `assignedGroup`t''))
			local ObsAdj = `ObsAdj' - `leftToAssignGroup`t'' - `assignedGroup`t''
			local GroupsToAssign = `GroupsToAssign' - 1
			local ObsPerGroupAdj = `ObsAdj'/`GroupsToAssign'
			}
			di "Group `t': Assigned: `assignedGroup`t''; LeftToAssign: `leftToAssignGroup`t''; Total Observations Group `t': " `assignedGroup`t''+`leftToAssignGroup`t''
		}
	}
	if `change' <=  1 {
		local change 3
	}
	if `change' >= `leftToAssign' {
		local change min(3,`leftToAssign')
	}
	if `cooling' > 2 | `cooling' < 1 {
		local cooling 1
	}
	if `tmax' < 1 {
		local tmax 10
	}
	* Cooling parameter t0 is set after first solution is evaluated
		
* Set missing values to a variable's mean and rescale all variables to have a variance of 1
	local varlist_opt = ""
	
	local j = 0
	foreach var in `varlist'{
	tempname `j'_opt
	quietly gen ``j'_opt' = `var'
	
	quietly sum ``j'_opt'
	quietly replace ``j'_opt' = r(mean) if missing(``j'_opt')
	
	quietly sum ``j'_opt', detail
	if r(sd) > 0 {
		quietly replace ``j'_opt' = ``j'_opt' / r(sd)
	}
	
	local varlist_opt = "`varlist_opt' ``j'_opt'"
	local j = `j' + 1
	}

* Generate 5% of iterations first solutions
	local no_firstSolutions = min(max(round(`iterations'/100*5)-1,`N'-1), round(`iterations'/100*10)-1)
	
	tempname u
	capture drop `u'
	quietly gen `generate' = `assignment'

	if `leftToAssign' == `N' {
		qui generate double `u' = runiform() if missing(`generate')
		qui replace `u' = `u' * (-1)
		sort `u', stable
		quietly replace `generate' = mod(_n,`groups')
	}
	else {
		forvalues t = 0/`treatments' {
			capture drop `u'
			qui generate double `u' = runiform() if missing(`generate')
			qui replace `u' = `u' * (-1)
			sort `u', stable
			quietly replace `generate' = `t' if _n <= `leftToAssignGroup`t''
		}
	}

* Evaluate first solution and define the variables for the optimization procedure
	evaluateSolution `generate', covariates(`varlist_opt')
	local current_ssd = r(evaluatedValue)

	local opt_ssd = `current_ssd'
	tempname opt_treatment
	quietly gen `opt_treatment' = `generate'

	forvalues k = 1/`no_firstSolutions' {
	quietly replace `generate' = `assignment'
		
		if `leftToAssign' == `N' {
			capture drop `u'
			qui generate double `u' = runiform() if missing(`generate')
			qui replace `u' = `u' * (-1)
			sort `u', stable
			quietly replace `generate' = mod(_n, `groups') if missing(`generate')
		}
		else {
			forvalues t = 0/`treatments' {
				capture drop `u'
				qui generate double `u' = runiform() if missing(`generate')
				qui replace `u' = `u' * (-1)
				sort `u', stable
				quietly replace `generate' = `t' if _n <= `leftToAssignGroup`t''
			}					
		}
		
		evaluateSolution `generate', covariates(`varlist_opt')
		local current_ssd = r(evaluatedValue)
		
		if `current_ssd' < `opt_ssd' {
			local opt_ssd = `current_ssd'
			quietly replace `opt_treatment' = `generate'
		}

	}
	
	quietly replace `generate' = `opt_treatment'
	local current_ssd = `opt_ssd'
	
	matrix ssds = (`current_ssd')
	
* Set T0 for the cooling process
	if `t0' == 0 {
		local t0 10
	}	
	if `t0' < 0 {
		local t0 = -(1/`t0')*`current_ssd' 
	}

* Start optimization procedure: Find new solutions based on last solution and compare to last/best solution.
	tempname next_treatment
	tempname u
	tempname id
	qui gen `id' = _n
	qui gen `next_treatment' = .
	
	* Start the algorithm
	forvalues k = 1/`iterations' {
	* Based on the current treatment assignment, find the next treatment assignment by switching treatment of two (or more, depending on the sample size) randomly selected participants.
		qui replace `next_treatment' = `generate'

		* Choose random participant
			capture drop `u'
			qui generate double `u' = runiform() if missing(`assignment')
			qui replace `u' = `u' * (-1)
			sort `u', stable
			
			* Call mata function to swap treatments
			mata: swapTreatments("`next_treatment'", `change')

		* Evaluate that solution
			evaluateSolution `next_treatment', covariates(`varlist_opt')
			local next_ssd = r(evaluatedValue)		

	* Compare the last solution with the new solution and keep the new solution according to the simulated annealing algorithm
		local randomNumber = runiform()
		local t_scheme_1 = `t0' / log(floor((`k'-1) / `tmax')*`tmax' + exp(1))
		local t_scheme_2 = `t0' / (floor( (`k'-1) / `tmax')*`tmax' + 1)
		local temperature = `t_scheme_`cooling''
		if (`randomNumber' <=  min(1,exp( (`current_ssd' - `next_ssd')/(`temperature'))) ) {
			qui replace `generate' = `next_treatment'
			local current_ssd = `next_ssd'

			if `current_ssd' < `opt_ssd' {
				qui replace `opt_treatment' = `generate'
				local opt_ssd = `current_ssd'
			}

		}
		
	* Prepare data for graphing the evolution of the best solution	
		if colsof(ssds) == (`c(matsize)'-1) {
			matrix ssds = [ssds, `opt_ssd']
			scalar newcol = `c(matsize)'
			matrix ssds = ssds[1,2..newcol]
		}
		else {
			matrix ssds = [ssds,`opt_ssd']	
		}	
		
		
	* Give some feedback about process of the procedure	
		if mod(`k',round(`iterations'/10)) == 0 {
			local percentageCompleted = round((`k'/`iterations')*100,.1)
			di "Completed iteration no. `k' of `iterations' (`percentageCompleted'%);"
			di "Value of the objective function for the currently minimal MSE treatment assignment found: `opt_ssd'"
		}
	}
	
	qui replace `generate' = `opt_treatment'

* Graph evolution of the best solution	
	if `plot' {
	matrix ssds = ssds'
	tempvar iteration
	svmat ssds
	qui gen `iteration' = _n if _n <= min(`c(matsize)',`iterations')
	label variable ssds1 "Value of objective function"
	label variable `iteration' "Last Iterations"
	twoway line ssds `iteration'

	*sum ssds, detail
	
	qui drop ssds
	qui drop `iteration'
	qui drop if _n > `N'
	}
	
	return scalar objectiveFunction = `opt_ssd'	
end
* Have a nice day!
