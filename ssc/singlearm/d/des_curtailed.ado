*! Date    : 08 May 2018
*! Version : 1.0

/*
 08/05/18 v1.0 Initial version complete
*/

program define des_curtailed, rclass
version 11.0
syntax, [J(integer 2) pi0(real 0.1) pi1(real 0.3) Alpha(real 0.05) ///
         Beta(real 0.2) thetaf(numlist) thetae(numlist) nmin(integer 1) ///
		 nmax(integer 30) FUTility(integer 1) EFFicacy(integer 0) ///
		 optimality(string) EQual_n(integer 0) ENSign(integer 0) ///
		 SUMmary(integer 0) PLot *]

local xopt `"`options'"'		 
preserve
if ("`optimality'" == "") {
  local optimality "null_ess"
}

///// Perform checks on input variables ////////////////////////////////////////

if (`j' <= 0) {
  di "{error} J must be an integer greater than or equal to one."
  exit(198)
}
if ((`pi0' <= 0) | (`pi0' >= 1)) {
  di "{error} pi0 must be a real strictly between 0 and 1."
  exit(198)
}
if ((`pi1' <= 0) | (`pi1' >= 1)) {
  di "{error} pi1 must be a real strictly between 0 and 1."
  exit(198)
}
if (`pi0' >= `pi1') {
  di "{error} pi0 must be a real strictly less than the real pi1."
  exit(198)
}
if ((`alpha' <= 0) | (`alpha' >= 1)) {
  di "{error} alpha must be a real strictly between 0 and 1."
  exit(198)
}
if ((`beta' <= 0) | (`beta' >= 1)) {
  di "{error} beta must be a real strictly between 0 and 1."
  exit(198)
}
if ("`thetaf'" ~= "") {
  local lenthetaf:list sizeof thetaf
  if (`lenthetaf' ~= `j') {
    di "{error} thetaf must be a numlist of length J."
    exit(198)
  }
  if ("`thetae'" == "") {
    forvalues i = 1/`lenthetaf' {
      local thetafi:word `i' of `thetaf'
      if (`thetafi' > 1) {
        di "{error} Elements in thetaf must be less than or equal to 1."
        exit(198)
      }
    }
  }
}
if ("`thetae'" ~= "") {
  local lenthetae:list sizeof thetae
  if (`lenthetae' ~= `j') {
    di "{error} thetae must be a numlist of length J."
    exit(198)
  }
  if ("`thetaf'" == "") {
    forvalues i = 1/`lenthetae' {
      local thetaei:word `i' of `thetae'
      if (`thetaei' < 0) {
        di "{error} Elements in thetae must be greater than or equal to 0."
        exit(198)
      }
    }
  } 
}
if ("`thetaf'" ~= "" & "`thetae'" ~= "") {
  forvalues i = 1/`lenthetaf' {
    local thetafi:word `i' of `thetaf'
    local thetaei:word `i' of `thetae'
    if (`thetafi' > `thetaei') {
      di "{error} Elements in thetaf must be less than or equal to their corresponding element in thetae."
      exit(198)
    }
  }
}
if (`nmin' <= 0) {
  di "{error} nmin must be a strictly positive integer."
  exit(198)
}
if (`nmax' <= 0) {
  di "{error} nmax must be a strictly positive integer."
  exit(198)
}
if (`nmin' > `nmax') {
  di "{error} nmin must be an integer less than or equal to the integer nmax."
  exit(198)
}
if (`futility' ~= 1 & `efficacy' ~= 1) {
  di "{error} At least one of futility and efficacy must be equal to 1."
  exit(198)
}
if ("`optimality'" ~= "minimax" & "`optimality'" ~= "null_ess" & "`optimality'" ~= "alt_ess" & "`optimality'" ~= "null_med" & "`optimality'" ~= "alt_med") {
  di "{error} optimality must be one of: minimax, null_ess, alt_ess, null_med, and alt_med."
  exit(198)
}
if (`j' > 2) {
  di "{error} J > 2 is not currently supported."
  exit(198)
}
// Set up matrices to pass to mata
if ("`thetaf'" ~= "") {
  local matathetaf ""
  foreach i of local thetaf{
    if "`matathetaf'" == "" local matathetaf "`i'"
    else local matathetaf "`matathetaf',`i'"
  }
  mat thetaf = (`matathetaf')
}
else {
  mat thetaf = .
}
if ("`thetae'" ~= "") {
  local matathetae ""
  foreach i of local thetae{
    if "`matathetae'" == "" local matathetae "`i'"
    else local matathetae "`matathetae',`i'"
  }
  mat thetae = (`matathetae')
}
else {
  mat thetae = .
}

///// Compute and Output ///////////////////////////////////////////////////////

mata: DesCurtailed(`j', `pi0', `pi1', `alpha', `beta', `nmin', `nmax', `futility', `efficacy', "`optimality'", `equal_n', `ensign', `summary', "`plot'", `"`xopt'"')
return mat des = des
matrix colnames opchar = "P(pi0)" "P(pi1)" "ESS(pi0)" "ESS(pi1)" "Med(pi0)" "Med(pi1)" "VSS(pi0)" "VSS(pi1)" "max(N)"
return mat opchar = opchar
return mat J = J
return mat n = n
return mat a = a
return mat r = r
return mat J_curt = J_curt
return mat n_curt = n_curt
return mat a_curt = a_curt
return mat r_curt = r_curt
if (`j' == 1) {
  matrix colnames feasible = n1 a1 r1 "P(pi0)" "P(pi1)"
}
else if (`j' == 2) {
  matrix colnames feasible = n1 n2 a1 a2 r1 r2 "P(pi0)" "P(pi1)" "PET1(pi0)" "PET1(pi1)" "ESS(pi0)" "ESS(pi1)" "Med(pi0)" "Med(pi1)" "VSS(pi0)" "VSS(pi1)" "max(N)"
}
else {
  matrix colnames feasible = n1 n2 n3 a1 a2 a3 r1 r2 r3 "P(pi0)" "P(pi1)" "PET1(pi0)" "PET1(pi1)" "PET2(pi0)" "PET2(pi1)" "ESS(pi0)" "ESS(pi1)" "Med(pi0)" "Med(pi1)" "VSS(pi0)" "VSS(pi1)" "max(N)"
}
return mat feasible = feasible
return mat pi0 = pi0
return mat pi1 = pi1
return mat alpha = alpha
return mat beta = beta
return mat thetaf = thetaF
return mat thetae = thetaE
return mat nmin = Nmin
return mat nmax = Nmax
return mat futility = futility
return mat efficacy = efficacy
return local optimality "`optimality'"
return mat equal_n = equal_n
return mat ensign = ensign
return mat summary = summary

restore

end

///// Mata  ////////////////////////////////////////////////////////////////////

mata:

void DesCurtailed(J, pi0, pi1, alpha, beta, Nmin, Nmax, futility, efficacy, optimality, equal_n, ensign, summary, plot, xopt)
{
  
  thetaF = st_matrix("thetaf")
  thetaE = st_matrix("thetae")
  if (thetaF == .) {
    thetaF = J(1, J, 0)
  }
  if (thetaE == .) {
    thetaE = J(1, J, 1)
  }
  
  ///// Print Summary //////////////////////////////////////////////////////////

  
  
  ///// Main Computations //////////////////////////////////////////////////////
  
  if (J == 1) {
    dbinomial_pi0 = J(Nmax + 1, Nmax, 0)
    dbinomial_pi1 = J(Nmax + 1, Nmax, 0)
    for (i = 1; i <= Nmax; i++) {
      dbinomial_pi0[1::(i + 1), i] = binomialp(i, 0::i, pi0)
	  dbinomial_pi1[1::(i + 1), i] = binomialp(i, 0::i, pi1)
    }
    if (exact == 1) {
      possible = permutations(0::Nmax, 2)
	  possible = possible[mm_which(possible[, 1] :> possible[, 2] :& 0 :< possible[, 1]), ]
    }
    else {
      possible = Nmin::Nmax
	  possible = (possible, round(possible*pi0 + invnormal(1 - alpha)*sqrt(possible*pi0*(1 - pi0))))
	  possible = possible[mm_which(possible[, 1] :> possible[, 2] :& 0 :<= possible[, 2]), ]
    }
    possible = (possible, possible[, 2] + J(rows(possible), 1, 1), J(rows(possible), 2, 0))
    for (i = 1; i <= rows(possible); i++) {
      possible[i, (4, 5)] = (sum(dbinomial_pi0[(possible[i, 3] + 1)::possible[i, 1], possible[i, 1]]), sum(dbinomial_pi1[(possible[i, 3] + 1)::possible[i, 1], possible[i, 1]]))
	  if (allof((summary == 1, mod(i, 1000) == 0), 1)) {
	    printf("{txt}...{res}%g{txt} designs evaluated...\n", i)
	  }
    }
    if (summary == 1) {
      printf("...determining feasible designs, and then the optimal design...")
    }
    feasible = possible[mm_which(possible[, 4] :<= alpha :& possible[, 5] :>= 1 - beta), ] 
    if (rows(feasible) > 0) {
      feasible = sort(feasible, (1, -5))
	  des      = feasible[1, ]
	  n        = feasible[1, 1]
	  a        = feasible[1, 2]
	  r        = feasible[1, 3]
	  if (plot ~= "") {
	    // Need plot of state-space here (use xopt)
	  }
    }
    else {
      feasible = .
	  n        = .
	  a        = .
	  r        = .
	  des      = .
    }
  }
  else {
    feasible = IntDesGS(J, pi0, pi1, alpha, beta, Nmin, Nmax, futility, efficacy, equal_n, ensign, summary)
    if (feasible[1, 1] > 0) {
      if (summary == 1) {
	    printf("...feasible designs in range of considered maximal allowed sample size identified....")
        printf("...now identifying optimal design(s)...")
	  }
	  feasible = (feasible[, 1::(2*J + J - 1)], feasible[, 2*J] + J(rows(feasible), 1, 1), feasible[, (2*J + J)::cols(feasible)], rowsum(feasible[, 1::J]))
	  if (futility ~= 1) {
	    feasible[, (J + 1)::(2*J - 1)] = J(rows(feasible), J - 1, .)
	  }
	  if (efficacy ~= 1) {
	    feasible[, (2*J + 1)::(3*J - 1)] = J(rows(feasible), J - 1, .)
	  }
	  if (optimality == "null-ess") {
	    feasible = sort(feasible, (5*J + 1, 5*J + 7))
	  }
	  else if (optimality == "alt-ess") {
	    feasible = sort(feasible, (5*J + 2, 5*J + 7))
	  }
	  else if (optimality == "null-med") {
	    feasible = sort(feasible, (5*J + 3, 5*J + 7))
	  }
	  else if (optimality == "alt-med") {
	    feasible = sort(feasible, (5*J + 4, 5*J + 7))
	  }
	  else if (optimality == "minimax") {
	    feasible = sort(feasible, (5*J + 7, 5*J + 1))
	  }
	  des        = feasible[1, ]
	  n          = feasible[1, 1::J]
	  a          = feasible[1, (J + 1)::(2*J)]
	  r          = feasible[1, (2*J + 1)::(3*J)]
    }
    else {
      feasible = des = .
	  if (summary) {
        printf("...no feasible designs found in range of considered maximal allowed sample size. Consider decreasing nmin and increasing nmax...")
      }
    }
  }
  if (des ~= .) {
	cp_mat = J(sum(n) + 1, sum(n), 0)
	for (m = 1; m <= sum(n); m++) {
	  for (s = 0; s <= m; s++) {
	    cp_mat[s + 1, m] = cr_gs(pi1, s, m, J, a, r, n)
	  }
	}
	a_curt = J(1, sum(n), .)
	r_curt = J(1, sum(n), .)
	n_curt = J(1, sum(n), 1)
	for (i = 1; i <= sum(n); i++) {
	  j = min(mm_which(i :<= runningsum(n)))
	  if (any(cp_mat[1::(i + 1), i] :<= thetaF[j])) {
	    a_curt[i] = max(mm_which(cp_mat[1::(i + 1), i] :<= thetaF[j])) - 1
	  }
	  if (any(cp_mat[, i] :>= thetaE[j])) {
	    r_curt[i] = min(mm_which(cp_mat[, i] :>= thetaE[j])) - 1
	  }
	}
	opchar_H0 = int_opchar_curtailed(pi0, J, sum(n), a_curt, r_curt, n, n_curt, runningsum(n), runningsum(n_curt), (1::J)')
    opchar_H1 = int_opchar_curtailed(pi1, J, sum(n), a_curt, r_curt, n, n_curt, runningsum(n), runningsum(n_curt), (1::J)')
    a_curt[mm_which(a_curt :== -1)] = J(1, length(mm_which(a_curt :== -1)), .)
    r_curt[mm_which(r_curt :== sum(n) + 1)] = J(1, length(mm_which(r_curt :== sum(n) + 1)), .)
	maxN      = max(mm_which(a_curt :+ 1 :< r_curt)) + 1
	J_curt    = sum(n)
	des       = (J, n, a, r, n_curt, a_curt, r_curt, opchar_H0[2], opchar_H1[2], opchar_H0[(6 + 4*J_curt + 2*J)::(5 + 4*J_curt + 3*J)], opchar_H1[(6 + 4*J_curt + 2*J)::(5 + 4*J_curt + 3*J)], opchar_H0[3], opchar_H1[3], opchar_H0[5], opchar_H1[5], opchar_H0[4], opchar_H1[4], maxN)
    opchar    = (opchar_H0[2], opchar_H1[2], opchar_H0[3], opchar_H1[3], opchar_H0[5], opchar_H1[5], opchar_H0[4], opchar_H1[4], maxN)
    if (plot ~= "") {
	  a_curt[mm_which(a_curt :== .)] = J(1, length(mm_which(a_curt :== .)), -1)
      r_curt[mm_which(r_curt :== .)] = J(1, length(mm_which(r_curt :== .)), sum(n) + 1)
	  states = permutations((0::n_curt[1]), 2)
	  states = states[mm_which((states[, 1] :<= states[, 2]) :& (states[, 2] :> 0)), ]
	  outcome = J(rows(states), 1, 0)
	  for (i = 1; i <= rows(states); i++) {
	    if (states[i, 1] <= a_curt[1] & states[i, 2] == n_curt[1]) {
		  outcome[i] = 1
		}
		else if (states[i, 1] >= r_curt[1] & states[i, 2] == n_curt[1]) {
		  outcome[i] = 2
		}
	  }
	  states = (states, outcome)
	  cont = (max((0, a_curt[1] + 1)), min((r_curt[1] - 1, n_curt[1])))
	  for (j = 2; j <= J_curt; j++) {
	    vals_j = permutations((0::n_curt[j]), 2)
	    vals_j = vals_j[mm_which((vals_j[, 1] :<= vals_j[, 2]) :& (vals_j[, 2] :> 0)), ]
		states_j = J(1, 2, .)
		for (sj = cont[1]; sj <= cont[2]; sj++) {
		  states_j = (states_j \ (vals_j[, 1] :+ sj, vals_j[, 2] :+ sum(n_curt[1::(j - 1)])))
		}
		states_j = states_j[2::rows(states_j), ]
		outcome  = J(rows(states_j), 1, 0)
	    for (i = 1; i <= rows(states_j); i++) {
	      if (states_j[i, 1] <= a_curt[j] & states_j[i, 2] == sum(n_curt[1::j])) {
		    outcome[i] = 1
		  }
		  else if (states_j[i, 2] >= r_curt[j] & states_j[i, 2] == sum(n_curt[1::j])) {
		    outcome[i] = 2
		  }
	    }
		states_j = (states_j, outcome)
		cont     = (min(states_j[mm_which(states_j[, 1] :> a_curt[j]), 1]), max(states_j[mm_which(states_j[, 1] :< r_curt[j]), 1]))
		states   = (states \ states_j)
	  }
	  states_cont = states[mm_which(states[, 3] :== 0), 1::2]
	  states_acc = states[mm_which(states[, 3] :== 1), 1::2]
	  states_rej = states[mm_which(states[, 3] :== 2), 1::2]
	  st_matrix("states_cont", states_cont)
	  st_matrix("states_acc", states_acc)
	  st_matrix("states_rej", states_rej)
	  stata("qui svmat states_cont")
	  stata("qui svmat states_acc")
	  stata("qui svmat states_rej")
	  stata(`"twoway (scatter states_cont1 states_cont2, msymbol(oh) color(gs13)) (scatter states_acc1 states_acc2, msymbol(X) color(red)) (scatter states_rej1 states_rej2, msymbol(+) color(green)), xtitle({it:s}) ytitle({it:m}) legend(lab(1 "Continue") lab(2 "Do not reject {it:H}{subscript:0}") lab(3 "Reject {it:H}{subscript:0}"))"'+ xopt)
	}
  } else {
    des       = .
	opchar    = J(1, 9, .)
	cols(feasible)
	feasible  = J(1, (J == 1 ? 5 : (J == 2 ? 17 : 22)), .)
	J_curt    = a_curt = n_curt = r_curt = .
  }
  
  ///// Return /////////////////////////////////////////////////////////////////
  
  if (summary == 1) {
    printf("...outputting")
  }
  st_matrix("des", des)
  st_matrix("opchar", opchar)
  st_matrix("J", J)
  st_matrix("n", n)
  st_matrix("a", a)
  st_matrix("r", r)
  st_matrix("J_curt", J_curt)
  st_matrix("n_curt", n_curt)
  st_matrix("a_curt", a_curt)
  st_matrix("r_curt", r_curt)
  st_matrix("feasible", feasible)
  st_matrix("pi0", pi0)
  st_matrix("pi1", pi1)
  st_matrix("alpha", alpha)
  st_matrix("beta", beta)
  st_matrix("thetaF", thetaF)
  st_matrix("thetaE", thetaE)
  st_matrix("Nmin", Nmin)
  st_matrix("Nmax", Nmax)
  st_matrix("futility", futility)
  st_matrix("efficacy", efficacy)
  st_local("optimality", optimality)
  st_matrix("equal_n", equal_n)
  st_matrix("ensign", ensign)
  st_matrix("summary", summary)
  
}

// Function to determine feasible group sequential designs
real matrix IntDesGS(real scalar J, real scalar pi0, real scalar pi1,
                     real scalar alpha, real scalar beta, real scalar Nmin,
				     real scalar Nmax, real scalar futility,
					 real scalar efficacy, real scalar equal_n,
					 real scalar ensign, real scalar summary)
{
  dbinomial_pi0                  = J(Nmax, Nmax - 1, 0)
  dbinomial_pi1                  = J(Nmax, Nmax - 1, 0)
  for (i = 1; i <= Nmax - 1; i++) {
    dbinomial_pi0[1::(i + 1), i] = binomialp(i, 0::i, pi0)
	dbinomial_pi1[1::(i + 1), i] = binomialp(i, 0::i, pi1)
  }
  A_pi0 = A_pi1 = R_pi0 = R_pi1 = J(1, J, 0)
  C_pi0 = C_pi1 = J(Nmax + 1, J, 0)
  feasible_designs = J(500000, (J == 2 ? 15 : 20), 0)
  counter = 1
  counter2 = 0
  if (J == 2) {
    for (n1 = (futility + efficacy == 2 ? 2 : 1); n1 <= (equal_n == 1 ? floor(Nmax/2) : (Nmax - 1)); n1++) {
	  C_pi0[, 1] = C_pi1[, 1] = J(Nmax + 1, 1, 0)
	  C_pi0[1::(n1 + 1), 1] = dbinomial_pi0[1::(n1 + 1), n1]
	  C_pi1[1::(n1 + 1), 1] = dbinomial_pi1[1::(n1 + 1), n1]
	  for (a1 = (futility == 1 ? 0 : -1); a1 <= (futility == 1 ? (ensign == 1 ? 0 : (efficacy == 1 ? n1 - 2 : n1 - 1)) : -1); a1++) {
	    if (a1 >= 0) {
		  A_pi0[1] = sum(C_pi0[1::(a1 + 1), 1])
		  A_pi1[1] = sum(C_pi1[1::(a1 + 1), 1])
		}
		else {
		 A_pi0[1] = A_pi1[1] = 0
		}
		if (A_pi1[1] > beta) {
		  break
		}
		for (r1 = (efficacy == 1 ? n1 : n1 + 1); r1 >= (efficacy == 1 ? a1 + 2 : n1 + 1); r1--) {
		  if (r1 <= n1) {
		    R_pi0[1] = sum(C_pi0[(r1 + 1)::(n1 + 1), 1])
			R_pi1[1] = sum(C_pi1[(r1 + 1)::(n1 + 1), 1])
		  }
		  else {
		    R_pi0[1] = R_pi1[1] = 0
		  }
		  if (R_pi0[1] > alpha) {
		    break
		  }
		  for (n2 = (equal_n == 1 ? n1 : max((1, Nmin - n1))); n2 <= (equal_n == 1 ? n1 : Nmax - n1); n2++) {
		    C_pi0[, 2] = J(Nmax + 1, 1, 0)
			C_pi1[, 2] = J(Nmax + 1, 1, 0)
			for (s = max((a1 + 1, 0)); s <= min((r1 - 1, n1)); s++) {
			  C_pi0[(s + 1)::(s + 1 + n2), 2]= C_pi0[(s + 1)::(s + 1 + n2), 2] + C_pi0[s + 1, 1]*dbinomial_pi0[1::(n2 + 1), n2]
			  C_pi1[(s + 1)::(s + 1 + n2), 2]= C_pi1[(s + 1)::(s + 1 + n2), 2] + C_pi1[s + 1, 1]*dbinomial_pi1[1::(n2 + 1), n2]
			}
			for (a2 = max((0, a1 + 1)); a2 <= min((r1 + n2 - 2, n1 + n2 - 1)); a2++) {
			  R_pi1[2] = sum(C_pi1[(a2 + 2)::(n1 + n2 + 1), 2])
			  counter2++
		      if (allof((summary == 1, mod(counter2, 10000) == 0), 1)) {
	            printf("{txt}...over {res}%g{txt} designs evaluated...\n", counter2)
	          }
			  if (sum(R_pi1) < 1 - beta) {
			    break
			  }
			  R_pi0[2] = sum(C_pi0[(a2 + 2)::(n1 + n2 + 1), 2])
			  if (sum(R_pi0) <= alpha) {
			    A_pi0[2] = sum(C_pi0[1::(a2 + 1), 2])
				A_pi1[2] = sum(C_pi1[1::(a2 + 1), 2])
				PET1_pi0 = A_pi0[1] + R_pi0[1]
				PET1_pi1 = A_pi1[1] + R_pi1[1]
				ESS_pi0 = n1 + (1 - PET1_pi0)*n2
				ESS_pi1 = n1 + (1 - PET1_pi1)*n2
				Med_pi0 = (PET1_pi0 < 0.5 ? n1 + n2 : (PET1_pi0 > 0.5 ? n1 : n1 + 0.5*n2))
				Med_pi1 = (PET1_pi1 < 0.5 ? n1 + n2 : (PET1_pi1 > 0.5 ? n1 : n1 + 0.5*n2))
				Var_pi0 = PET1_pi0*n1^2 + (1 - PET1_pi0)*(n1 + n2)^2 - ESS_pi0^2
				Var_pi1 = PET1_pi1*n1^2 + (1 - PET1_pi1)*(n1 + n2)^2 - ESS_pi1^2
				feasible_designs[counter, ] = (n1, n2, a1, a2, r1, sum(R_pi0), sum(R_pi1), PET1_pi0, PET1_pi1, ESS_pi0, ESS_pi1, Med_pi0, Med_pi1, Var_pi0, Var_pi1)
				counter++
			  }
			}
          }
		}
	  }
	}
  }
  else {
    for (n1 = (futility + efficacy == 2 ? 2 : 1); n1 <= (equal_n == 1 ? floor(Nmax/3) : (Nmax - 3)); n1++) {
	  C_pi0[, 1] = C_pi1[, 1] = J(Nmax + 1, 1, 0)
	  C_pi0[1::(n1 + 1), 1] = dbinomial_pi0[1::(n1 + 1), n1]
	  C_pi1[1::(n1 + 1), 1] = dbinomial_pi1[1::(n1 + 1), n1]
	  for (a1 = (futility == 1 ? 0 : -1); a1 <= (futility == 1 ? (ensign == 1 ? 0 : (efficacy == 1 ? n1 - 2 : n1 - 1)) : -1); a1++) {
	    if (a1 >= 0) {
		  A_pi0[1] = sum(C_pi0[1::(a1 + 1), 1])
		  A_pi1[1] = sum(C_pi1[1::(a1 + 1), 1])
		}
		else {
		 A_pi0[1] = A_pi1[1] = 0
		}
		if (A_pi1[1] > beta) {
		  break
		}
		for (r1 = (efficacy == 1 ? n1 : n1 + 1); r1 >= (efficacy == 1 ? a1 + 2 : n1 + 1); r1--) {
		  if (r1 <= n1) {
		    R_pi0[1] = sum(C_pi0[(r1 + 1)::(n1 + 1), 1])
			R_pi1[1] = sum(C_pi1[(r1 + 1)::(n1 + 1), 1])
		  }
		  else {
		    R_pi0[1] = R_pi1[1] = 0
		  }
		  if (R_pi0[1] > alpha) {
		    break
		  }
		  for (n2 = (equal_n == 1 ? n1 : 2); n2 <= (equal_n == 1 ? n1 : Nmax - n1 - 1); n2++) {
		    C_pi0[, 2] = J(Nmax + 1, 1, 0)
			C_pi1[, 2] = J(Nmax + 1, 1, 0)
			for (s = max((a1 + 1, 0)); s <= min((r1 - 1, n1)); s++) {
			  C_pi0[(s + 1)::(s + 1 + n2), 2]= C_pi0[(s + 1)::(s + 1 + n2), 2] + C_pi0[s + 1, 1]*dbinomial_pi0[1::(n2 + 1), n2]
			  C_pi1[(s + 1)::(s + 1 + n2), 2]= C_pi1[(s + 1)::(s + 1 + n2), 2] + C_pi1[s + 1, 1]*dbinomial_pi1[1::(n2 + 1), n2]
			}
			for (a2 = (futility == 1 ? max((0, a1 + 1)) : -1); a2 <= (futility == 1 ? min((r1 + n2 - 2, n1 + n2 - 1)) : -1); a2++) {
			  if (a2 >= 0) {
			    A_pi0[2] = sum(C_pi0[1::(a2 + 1), 2])
				A_pi1[2] = sum(C_pi1[1::(a2 + 1), 2])
			  }
			  else {
			    A_pi0[2] = A_pi1[2] = 0
			  }
			  if (A_pi1[1] + A_pi1[2] > beta){
                break
              }
			  for (r2 = (efficacy == 1 ? r1 + n2 - 1 : n1 + n2 + 1); r2 >= (efficacy == 1 ? max((a2 + 2, r1)) : n1 + n2 + 1); r2--) {
			    if (r2 <= n1 + n2) {
				  R_pi0[2] = sum(C_pi0[(r2 + 1)::(n1 + n2 + 1), 1])
				  R_pi1[2] = sum(C_pi1[(r2 + 1)::(n1 + n2 + 1), 1])
				}
				else {
				  R_pi0[2] = R_pi1[2] = 0
				}
				if (R_pi0[1] + R_pi0[2] > alpha){
                  break
                }
				for (n3 = (equal_n == 1 ? n1 : max((1, Nmin - n1 - n2))); n3 <= (equal_n == 1 ? n1 : Nmax - n1 - n2); n3++) {
				  for (s = max((a2 + 1, 0)); s <= min((r2 - 1, n1 + n2)); s++) {
			        C_pi0[(s + 1)::(s + 1 + n3), 3]= C_pi0[(s + 1)::(s + 1 + n3), 3] + C_pi0[s + 1, 2]*dbinomial_pi0[1::(n3 + 1), n3]
			        C_pi1[(s + 1)::(s + 1 + n3), 3]= C_pi1[(s + 1)::(s + 1 + n3), 3] + C_pi1[s + 1, 2]*dbinomial_pi1[1::(n3 + 1), n3]
			      }
				  for (a3 = max((0, a2 + 1)); a3 <= min((r2 + n3 - 2, n1 + n2 + n3 - 1)); a3++) {
				    R_pi1[3] = sum(C_pi1[(a3 + 2)::(n1 + n2 + n3 + 1), 1])
					counter2++
		            if (allof((summary == 1, mod(counter2, 10000) == 0), 1)) {
	                  printf("{txt}...over {res}%g{txt} designs evaluated...\n", counter2)
	                }
					if (sum(R_pi1) < 1 - beta) {
                      break
                    }
					R_pi0[3] = sum(C_pi0[(a3 + 2)::(n1 + n2 + n3 + 1), 1])
					if (sum(R_pi0) <= alpha) {
					  A_pi0[3] = sum(C_pi0[1::(a3 + 1), 3])
				      A_pi1[3] = sum(C_pi1[1::(a3 + 1), 3])
					  PET1_pi0 = A_pi0[1] + R_pi0[1]
                      PET1_pi1 = A_pi1[1] + R_pi1[1]
                      PET2_pi0 = A_pi0[2] + R_pi0[2]
                      PET2_pi1 = A_pi1[2] + R_pi1[2]
                      ESS_pi0 = PET1_pi0*n1 + PET2_pi0*(n1 + n2) + (1 - PET1_pi0 - PET2_pi0)*(n1 + n2 + n3)
                      ESS_pi1 = PET1_pi1*n1 + PET2_pi1*(n1 + n2) + (1 - PET1_pi1 - PET2_pi1)*(n1 + n2 + n3)
                      if (PET1_pi0 == 0.5) {
                        Med_pi0 = n1 + 0.5*n2
                      }
                      else if (PET1_pi0 + PET2_pi0 == 0.5){
                        Med_pi0 = n1 + n2 + 0.5*n3
                      }
                      else {
                        if (PET1_pi0 > 0.5){
                          Med_pi0 = n1
                        }
                        else if ((PET1_pi0 < 0.5) & (PET1_pi0 + PET2_pi0 > 0.5)) {
                          Med_pi0 = n1 + n2
                        }
                        else {
                          Med_pi0 = n1 + n2 + n3
                        }
                      }
                      if (PET1_pi1 == 0.5) {
                        Med_pi1 = n1 + 0.5*n2
                      }
                      else if (PET1_pi1 + PET2_pi1 == 0.5) {
                        Med_pi1 = n1 + n2 + 0.5*n3
                      }
                      else {
                        if (PET1_pi1 > 0.5) {
                          Med_pi1 = n1
                        }
                        else if ((PET1_pi1 < 0.5) & (PET1_pi1 + PET2_pi1 > 0.5)) {
                          Med_pi1 = n1 + n2
                        }
                        else {
                          Med_pi1 = n1 + n2 + n3
                        }
                      }
                      Var_pi0 = PET1_pi0*n1^2 + PET2_pi0*(n1 + n2)^2 + (1 - PET1_pi0 - PET2_pi0)*(n1 + n2 + n3)^2 - ESS_pi0^2
                      Var_pi1 = PET1_pi1*n1^2 + PET2_pi1*(n1 + n2)^2 + (1 - PET1_pi1 - PET2_pi1)*(n1 + n2 + n3)^2 - ESS_pi1^2
                      feasible_designs[counter, ] = (n1, n2, n3, a1, a2, a3, r1, r2, sum(R_pi0), sum(R_pi1), PET1_pi0, PET1_pi1, PET2_pi0, PET2_pi1, ESS_pi0, ESS_pi1, Med_pi0, Med_pi1, Var_pi0, Var_pi1)
                      counter++
					}
				  }
				}
			  }
			}
		  }
		}
	  }
	}
  }
  return(feasible_designs[1::(counter > 1 ? counter - 1 : 1), ])  
}

// Function to return conditional rejection probability in a group sequential
// design
real scalar cr_gs(real scalar pi, real scalar s, real scalar m, real scalar J,
                  real rowvector a, real rowvector r, real rowvector n)
{
  if (J > 1) {
    a[mm_which(a :== .)] = J(1, length(mm_which(a :== .)), -1)
    r[mm_which(r :== .)] = J(1, length(mm_which(r :== .)), sum(n) + 1)
  }
  if (J == 1) {
    cr              = binomialtail(n - m, r - s, pi)
  }
  else {
    if (m <= n[1]) {
      if (s >= r[1]) {
        cr          = 1
      }
	  else {
        poss_s      = permutations(uniqrows(s :+ 0::(n[1] - m) \ 0::n[2]), 2)
		poss_s      = select(poss_s, poss_s[, 1] :>= s :& poss_s[, 1] :<= s + n[1] - m :& poss_s[, 2] :>= 0 :& poss_s[, 2] :<= n[2])
		poss_s      = select(poss_s, poss_s[, 1] :>= r[1] :| (poss_s[, 1] :>= max((0, a[1] + 1)) :& poss_s[, 1] :<= min((n[1], r[1] - 1)) :& (poss_s[, 1] + poss_s[, 2] :>= r[2])))
		if (rows(poss_s) > 0) {
		  if (m < n[1]) {
		    prob_poss_s = (binomialp(n[1] - m, poss_s[, 1] :- s, pi), binomialp(n[2], poss_s[, 2], pi))
		  }
		  else {
		    prob_poss_s = (J(rows(poss_s), 1, 1), binomialp(n[2], poss_s[, 2], pi))
		  }
		  cr          = sum(prob_poss_s[, 1]:*prob_poss_s[, 2])
		}
		else {
		  cr = 0
		}
      }
    }
	else {
      cr            = binomialtail(sum(n) - m, r[2] - s, pi)
    }
  }
  return(cr)
}

// Function for determining pmf of group sequential design
real matrix pmf_curtailed(real scalar pi, real scalar J, real scalar J_curt,
                          real rowvector a_curt, real rowvector r_curt,
				          real rowvector n, real rowvector n_curt,
				          real rowvector k,| real colvector dbinom_pi)
{
  a_curt[mm_which(a_curt :== .)] = J(1, length(mm_which(a_curt :== .)), -1)
  r_curt[mm_which(r_curt :== .)] = J(1, length(mm_which(r_curt :== .)), sum(n) + 1)
  if (args() < 9) {
    dbinom_pi                     = J(max(n_curt) + 1, J_curt, 0)
    for (j = 1; j <= J_curt; j++) {
      dbinom_pi[1::(n_curt[j] + 1), j] = binomialp(n_curt[j], 0::n_curt[j], pi)
    }
  }
  pmf_mat                        = J(sum(n) + 1, J_curt, 0)
  pmf_mat[1::(n_curt[1] + 1), 1] = dbinom_pi[1::(n_curt[1] + 1), 1]
  cont                           = (max((0, a_curt[1] + 1)), min((r_curt[1] - 1, n_curt[1])))
  for (j = 1; j <= J_curt - 1; j++) {
    for (i = cont[1]; i <= cont[2]; i++) {
      pmf_mat[(i + 1)::(i + 1 + n_curt[j + 1]), j + 1] = pmf_mat[(i + 1)::(i + 1 + n_curt[j + 1]), j + 1] :+ pmf_mat[i + 1, j]*dbinom_pi[1::(n_curt[j + 1] + 1), j + 1]
    }
    pmf_mat[(cont[1] + 1)::(cont[2] + 1), j] = J(cont[2] - cont[1] + 1, 1, 0)
    upd                                      = cont[1]::(cont[2] + n_curt[j + 1])
    cont                                     = (min(select(upd, upd :> a_curt[j + 1])), max(select(upd, upd :< r_curt[j + 1])))
  }
  N        = (0, runningsum(n))
  full_k   = 0
  for (i = 1; i <= length(k); i++) {
    full_k = (full_k \ (N[k[i]] + 1)::N[k[i] + 1])
  }
  full_k   = full_k[2::length(full_k)]
  if (length(full_k) < J_curt) {
    for (stage = 1; stage <= J_curt; stage++) {
	  if (!any(stage :== full_k)) {
	    pmf_mat[, stage] = J(sum(n) + 1, 1, 0)
	  }
	}
	pmf_mat              = pmf_mat/sum(pmf_mat)
  }
  terminal = terminal_states_gs(J_curt, a_curt, r_curt, n_curt, full_k')
  if (sum(pmf_mat :> 0) > 1) {
    true_k = J(rows(terminal), 1, 0)
	for (i = 1; i <= rows(terminal); i++) {
	  true_k[i] = min(mm_which(N :>= terminal[i, 2])) - 1
	}
	f   = .
	for (j = 1; j <= J_curt; j++) {
	  f = (f \ select(pmf_mat[, j], pmf_mat[, j] :> 0))
	}
    pmf = (J(rows(terminal), 1, pi), terminal[, 1], terminal[, 2], true_k, f[2::length(f)])
  }
  else {
    true_k = J(rows(terminal), 1, 0)
	for (i = 1; i <= rows(terminal); i++) {
	  true_k[i] = min(mm_which(N :>= terminal[i, 3])) - 1
	}
    pmf      = (J(rows(terminal), 1, pi), terminal[, 1], terminal[, 2], terminal[, 3], J(rows(terminal), 1, 0))
    non_zero = (mm_which(rowsum(pmf_mat) :> 0) - 1, mm_which(colsum(pmf_mat :> 0)))
	pmf[mm_which(pmf[, 2] :== non_zero[1] :& pmf[, 4] :== non_zero[2]), 5] = 1
  }
  return(pmf)
}

// Function for determining operating characteristics of group sequential design
real rowvector int_opchar_curtailed(real scalar pi, real scalar J,
                                    real scalar J_curt, real rowvector a_curt,
									real rowvector r_curt, real rowvector n,
									real rowvector n_curt, real rowvector N,
									real rowvector N_curt,
							        real rowvector k,| real matrix pmf_pi)
{
  a_curt[mm_which(a_curt :== .)] = J(1, length(mm_which(a_curt :== .)), -1)
  r_curt[mm_which(r_curt :== .)] = J(1, length(mm_which(r_curt :== .)), sum(n) + 1)
  if (args() < 11) {
    pmf_pi = pmf_curtailed(pi, J, J_curt, a_curt, r_curt, n, n_curt, k)
  }
  A      = J(1, J_curt, 0)
  R      = J(1, J_curt, 0)
  for (j = 1; j <= J_curt; j++) {
    A[j] = sum(select(pmf_pi, pmf_pi[, 2] :<= a_curt[j] :& pmf_pi[, 3] :== j)[, 5])
    R[j] = sum(select(pmf_pi, pmf_pi[, 2] :>= r_curt[j] :& pmf_pi[, 3] :== j)[, 5])
  }
  S      = A + R
  cum_S  = runningsum(S)
  N      = (0, N)
  Atilde = J(1, J, 0)
  Rtilde = J(1, J, 0)
  for (j = 1; j <= J; j++) {
    Atilde[j] = sum(A[(1 + N[j])::N[j + 1]])
    Rtilde[j] = sum(R[(1 + N[j])::N[j + 1]])
  }
  N      = N[2::length(N)]
  Stilde = Atilde + Rtilde
  cum_Stilde = runningsum(Stilde)
  if (any(cum_S :== 0.5)) {
    Med  = 0.5*(N_curt[mm_which(cum_S :== 0.5)] + N_curt[mm_which(cum_S :== 0.5) + 1])
  }
  else {
    Med  = N_curt[mm_which(cum_S :> 0.5)[1]]
  }
  return((pi, sum(R), sum(N_curt:*S), sum(N_curt:^2:*S) - sum(N_curt:*S)^2, Med, A, R, S, cum_S, Atilde, Rtilde, Stilde, cum_Stilde))
}

// Function to determine all permutations of length q from a vector vec with
// replacement
real matrix permutations(real colvector vec, real scalar q)
{
  if (q == 1) {
    return(vec)
  }
  lvec = length(vec)
  if (lvec == 1) {
    return(J(1, q, vec))
  }
  l                 = lvec^q
  allperms          = J(l, q, 0)
  d                 = vec[2::lvec] :- vec[1::(lvec - 1)]
  ld                = length(d)
  vl                = (-sum(d) \ d)
  tmp               = J(1, l/lvec, vl)
  allperms[1::l, q] = vec(tmp)
  elts    = 1
  count   = 1
  while (elts[count] + lvec^(q - 1) <= l) {
    elts  = (elts \ elts[count] + lvec^(q - 1))
    count = count + 1
  }
  allperms[elts, 1] = vl
  if (q > 2) {
    for (i = 2; i <= q - 1; i++) {
      elts    = 1
      count   = 1
      while (elts[count] + lvec^(i - 1) <= l) {
        elts  = (elts \ elts[count] + lvec^(i - 1))
        count = count + 1
      }
      tmp = J(1, length(elts)/(ld + 1), vl)
      allperms[elts, q - i + 1] = vec(tmp)
    }
  }
  allperms[1, 1::q] = J(1, q, vec[1])
  origallperms      = allperms
  for (i = 2; i <= l; i++) {
    for (j = 1; j <= q; j++) {
      allperms[i, j] = sum(origallperms[1::i, j])
    }
  }
  return(allperms)
}

// Function to determine terminal states in a group sequential design
real matrix terminal_states_gs(real scalar J, real rowvector a,
                               real rowvector r, real rowvector n,
							   real rowvector k)
{
  a[mm_which(a :== .)] = J(1, length(mm_which(a :== .)), -1)
  r[mm_which(r :== .)] = J(1, length(mm_which(r :== .)), sum(n) + 1)
  terminal      = J(1, 3, 0)
  if (a[1] >= 0) {
    s1          = 0::a[1]
    terminal    = (terminal \ (s1, J(a[1] + 1, 1, n[1]), J(a[1] + 1, 1, 1)))
  }
  if (r[1] <= n[1]) {
    s1          = r[1]::n[1]
    terminal    = (terminal \ (s1, J(n[1] - r[1] + 1, 1, n[1]), J(n[1] - r[1] + 1, 1, 1)))
  }
  cont          = (max((0, a[1] + 1)), min((r[1] - 1, n[1])))
  if (J >= 3) {
    for (j = 1; j <= J - 2; j++) {
	  num_rows  = cont[2] + n[j + 1] - cont[1] + 1
      vals      = cont[1]::(cont[2] + n[j + 1])
	  upd       = (vals, J(num_rows, 1, sum(n[1::(j + 1)])), J(num_rows, 1, j + 1))
      terminal  = (terminal \ select(upd, upd[, 1] :<= a[j + 1] :| upd[, 1] :>= r[j + 1]))
	  cont      = (min(select(upd, upd[, 1] :> a[j + 1])[, 1]), max(select(upd, upd[, 1] :< r[j + 1])[, 1]))
    }
  }
  num_rows      = cont[2] + n[J] - cont[1] + 1
  vals          = cont[1]::(cont[2] + n[J])
  terminal      = (terminal \ (vals, J(num_rows, 1, sum(n)), J(num_rows, 1, J)))
  keep_rows     = mm_which(terminal[, 3] :== k[1])
  if (length(k) > 1) {
    for (els = 2; els <= length(k); els++) {
	  keep_rows = (keep_rows \ mm_which(terminal[, 3] :== k[els]))
	}
  }
  terminal      = terminal[keep_rows, ]
  return(terminal)
}

end
