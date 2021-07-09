program define ge_gravity
version 11.2

*! A simple Stata program for solving for GE effects of trade policies, by Tom Zylkin
*! Department of Economics, University of Richmond
*! This version: v1.1, March 2019
*!
*! Suggested citation: Baier, Yotov, and Zylkin (2019): 
*! "On the Widely Differing Effects of Free Trade Agreements: Lessons from Twenty Years of Trade Integration"
*! Journal of International Economics, 116, 206-226.

* v1.0: first version
* v1.1: now allows you to save computed changes in nominal wages and price indices

syntax anything [if] [in] ///
,theta(real) gen_w(name) gen_X(name) [gen_rw(name) MULTiplicative gen_nw(name) gen_P(name)]

* Ex: "GE_gravity exporter importer X beta, theta(-4) gen_w(welf) gen_X(new_pi)" will generate GE 
* welfare effects "gen_w" and new trade values "gen_X" for a set of countries
* with initial trade values "X", resulting from a set of partial effects "beta", 
* under the assumption that the trade elasticity, "theta", is 4.

* Note the assumptions used here:
*  - Only one sector (i.e., best suited for aggregate trade)
*  - One factor of production (labor)
*  - Trade in final goods only (no intermediates)
*  - Linear (as opposed to multiplicative) trade balances.

* In addition, note that trade values are normalized by holding total nominal world
* output constant. This provides a numeraire.

gettoken exp_id rest  : anything
gettoken imp_id rest  : rest
gettoken X      rest  : rest
gettoken beta   close : rest

qui marksample touse

// Check to make sure each obs. is uniquely ID'd by a single origin and destination	
local id_flag = 0
local check_ids = "`exp_id' `imp_id'"							

local are_both_ids_strings = 0
foreach v of varlist `check_ids' {
	cap confirm numeric variable `v'
	if _rc {
		local are_both_ids_strings = `are_both_ids_strings' + 1
		local `v'_is_string = 1
	}
	else{
		local `v'_is_string = 0
	}
}

if `are_both_ids_strings' == 0 {
	mata: id_check("`check_ids'",  "`touse'")
}

if `are_both_ids_strings' == 2 {
	mata: id_check_string("`check_ids'",  "`touse'")
}

if `are_both_ids_strings' == 1 {
	foreach v of varlist `check_ids' {
		tempvar `v'2
		if  ``v'_is_string' == 1 {
			qui egen ``v'2' = group(`v')
		}
		else{
			qui gen ``v'2' = `v'
		}
		
	local check_ids2 = "`check_ids2'" + "``v'2' "
	}
	mata: id_check("`check_ids2'",  "`touse'")
}
				    				
if `id_flag' != 0 {
	di in red "Error: the set of origin and destination IDs do not uniquely describe the data"
	di in red "If this is not a mistake, try collapsing the data first using collapse (sum)" 
	exit 111
}


tempname elasticity
scalar `elasticity' = `theta'

if "`gen_rw'" == ""{
	tempname gen_rw
}
if "`gen_nw'" == ""{
	tempname gen_nw
}
if "`gen_P'" == ""{
	tempname gen_P
}



cap gen `gen_w'  = .
cap gen `gen_X' = .
cap gen `gen_rw' = .
cap gen `gen_nw' = .
cap gen `gen_P' = .

di "sorting..."

sort `exp_id' `imp_id'

di "solving..."

mata: ge_solver("`X'", "`beta'", "`elasticity'", "`multiplicative'", "`gen_w'", "`gen_X'", "`gen_rw'", "`gen_nw'", "`gen_P'", "`touse'")

di "solved!"
end


* Iteration procedure:
*
* 0.   (initial competitive equilibrium): Y_i = w_i * L_i =  sum_j { pi_ij * E_j }
*
*                                                         =  A_i * w_i^-theta * sum_j {d_ij^-theta * E_j / P_j^-theta}         (eq 1)
*
*                                         where: P_j^-theta = sum_i {A_i * w_i^-theta * d_ij^-theta}                           (eq 2)
*
* 0.1. (new equilibrium in changes):      Y_i * w_i_hat =  w_i_hat^-theta * sum_j { pi_ij * e^beta * E_j' / P_j_hat^-theta }   (eq 3)
*
*                                         where: P_j_hat^-theta = sum_i { pi_ij * e^beta * w_i_hat^-theta }                    (eq 4)
*                                                
*										  and:   E_j' = Y_j * w_j_hat + D_j                                                    (eq 5)
*
* 1.   Update w_i_hat 1 time using (eq 3). 
*
* 1.5. Normalize all prices so world output stays the same (acts as numeraire):  sum_j { Y_j * w_j_hat } = sum_j { Y_j } 
*
* 2.   Update P_j_hat^-theta 1 time using (eq 4).
*
* 3.   Update E_j' 1 time using (eq 5) 
*
* 4.   Return to Step 1, using new values for w_hat, P_j_hat^-theta, and E_j'. Iterate until convergence.

mata: 
void ge_solver(string scalar trade, string scalar partials, string scalar elasticity, string scalar mult_opt,
               string scalar gen1, string scalar gen2, string scalar gen3, string scalar gen4, string scalar gen5,
			   string scalar ok)
  
{ 

  /* read data from Stata memory */
  X       = st_data(.,tokens(trade),ok)
  beta    = st_data(.,tokens(partials),ok)
  theta   = st_numscalar(tokens(elasticity))
  
  /* ensure data set includes all possible flows for each location */
  N = sqrt(rows(X))
  if (floor(N) != N) {
	displayas("err")
	printf("\nNon-square data set detected. The size of the data should be NxN. Check whether every location has N trade partners, including itself. Exiting.\n \n")
	exit(1)
  }

  /* flash warning if trade matrix has missing values */
  if (missing(X)>0) {
	displayas("err")
	printf("Flow values missing for at least 1 pair; assumed to be zero.\n")
	X=editmissing(X,0)
	displayas("text")
  }

  /* check for negative trade values */
  if (min(X)<0) {
	displayas("err")
	printf("\nNegative flow values detected. Exiting.\n \n")
	exit(1)
  }
  
  /* Set up X_ij trade matrix: exporters (rows) by importers (columns) */
  X = colshape(X, N)
  
  /* check that internal trade is included for all countries */
  if(min(diagonal(X))==0) {
	displayas("err")
	printf("\nX_ii is missing or zero for at least 1 location. Exiting.\n \n")
	exit(1)
  }
  
  /* flash warning if any beta values are missing */
  if (missing(beta)>0) {
	displayas("err")
	printf("beta values missing for at least 1 pair; assumed to be zero.\n")
	beta=editmissing(beta,0)
	displayas("text")
  }
  
  /* "B" (= e^beta) is the matrix of partial effects */
  B = colshape(exp(beta), N) 
  
  /* flash warning if betas on the diagonal are not zero. */
  if (min(diagonal(B):== 1) != 1) {
    displayas("err")
	printf("Non-zero beta values for some X_ii terms detected. These have been set to zero.\n")
	B = B - diag(B) :+ I(N)           // should be all 1's on the diagonal
	displayas("text")
  }
  
  /* Set up Y and E vectors; calculate trade balances  */
  E = colsum(X)'
  Y = rowsum(X)
  D = E - Y
  
  // for if user specifies "multiplicative" option for trade imbalances
  if (mult_opt == "") {
	mult = 0
  }
  else {
	mult = 1
  }
  
  
  /* set up pi_ij matrix of trade shares */
  pi = X :/ (E'#J(N,1,1))
  
  /* Initialize w_i_hat = P_j_hat = 1 */
  w_hat = P_hat = J(N,1,1)
  
  /* while loop */
  X_new = X
  crit = 1
  j = 0
  max_iter = 1000000
  tol = .00000001	
  do {
  
	X_last_step = X_new
	
	/* Step 1: update w_i_hat */ 	
	w_hat = ( ((pi :* B) * (E :/ P_hat)) :/ Y ) :^ (1/(1+theta))
	
	/* Step 1.5: Normalize so total world output stays the same  */
	w_hat = w_hat :* (sum(Y) :/ sum(Y :* w_hat))

	/* Step 2: update P_j_hat */
	P_hat = (pi' :* B') * (w_hat :^-theta)
	
	/* Step 3: update E_j' */
	if (mult) {
		E = (Y+D) :* w_hat
	}
	else{
		E = Y :* w_hat + D  // default is to have additive trade imbalances
	}
	
	/* Calculate new trade shares (to verify convergence) */
	pi_new = (pi :* B) :* ((w_hat:^-theta)#J(1,N,1))  :/ (P_hat'#J(N,1,1))
	X_new = pi_new :* (E'#J(N,1,1))

	crit = max(abs(ln(X_new) - ln(X_last_step)))
    j = j + 1
  
  } while (crit > tol & j < max_iter)

  /* Post welfare effects and new trade values to Stata memory */
  X_new = colshape(X_new,1)
   
  real_wage = w_hat :/ (P_hat):^(-1/theta) 
 
  if (mult) {
	welfare = real_wage
  }
  else {
	welfare = ((Y :* w_hat) + D) :/ (Y+D) :/ (P_hat):^(-1/theta)
  }
  
  welfare     = welfare # J(N, 1, 1) 
   
  real_wage   = real_wage # J(N, 1, 1) 
  
  nom_wage    = w_hat # J(N, 1, 1) 
  
  price_index = ((P_hat):^(-1/theta)) # J(N, 1, 1) 
  
  /* For in case you want to check the change real wages: */
  /* 
  real_wage'
  welfare'
  X_new'
  */
  /* could also put: real_wage =  (diagonal(pi_new) :/  diagonal(pi)) :^ (-1/theta)  (ACR formula) */
	
  st_store(.,tokens(gen1), ok, welfare )
  st_store(.,tokens(gen2), ok, X_new ) 
  st_store(.,tokens(gen3), ok, real_wage )
  st_store(.,tokens(gen4), ok, nom_wage )
  st_store(.,tokens(gen5), ok, price_index )
}


/*************************************************************/
/* CHECK_ID (checks whether ID vars uniquely describe data)  */
/*************************************************************/

// Sometimes users may make a mistake in providing duplicate observations for the same trade flow.
// This will generate a error letting them know. If this is not done by accident,
// perhaps the data needs to be aggregated by collapsing the data.

mata:
void id_check(string scalar idvars,| string scalar touse)
{
	
	st_view(id_vars,.,tokens(idvars), touse)
	uniq_ids = uniqrows(id_vars)
	if (rows(id_vars) != rows(uniq_ids)) {
		st_local("id_flag", "1")
	}	
}

mata:
void id_check_string(string scalar idvars,| string scalar touse)
{
	st_sview(id_vars,.,tokens(idvars), touse)
	uniq_ids = uniqrows(id_vars)
	if (rows(id_vars) != rows(uniq_ids)) {
		st_local("id_flag", "1")
	}	
}


end
	