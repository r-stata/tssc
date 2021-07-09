*! Date    : 08 May 2018
*! Version : 1.0

/*
 08/05/18 v1.0 Initial version complete
*/

program define des_bayesfreq, rclass
version 11.0
syntax, [J(integer 2) pi0(real 0.1) pi1(real 0.3) Alpha(real 0.05) ///
         Beta(real 0.2) mu(real 0.1) nu(real 0.9) nmin(integer 1) ///
		 nmax(integer 30) optimality(string) control(string) ///
		 EQual_n(integer 0) PL(real 0.5) PU(real 0.9) PT(real 0.95) ///
		 SUMmary(integer 0) PLot *]

local xopt `"`options'"'		 
preserve

if ("`optimality'" == "") {
  local optimality "ess"
}
if ("`control'" == "") {
  local control "both"
}

///// Perform checks on input variables ////////////////////////////////////////

if (`j' < 1 & `j' > 2) {
  di "{error} J must be an either 1 or 2."
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
if (`mu' <= 0) {
  di "{error} mu must be a real strictly greater than 0."
  exit(198)
}
if (`nu' <= 0) {
  di "{error} nu must be a real strictly greater than 0."
  exit(198)
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
if ("`optimality'" ~= "minimax" & "`optimality'" ~= "ess") {
  di "{error} optimality must be one of: minimax or ess."
  exit(198)
}
if ("`control'" ~= "frequentist" & "`control'" ~= "bayesian" & "`control'" ~= "both") {
  di "{error} optimality must be one of: frequentist, bayesian, or both."
  exit(198)
}

///// Compute and Output ///////////////////////////////////////////////////////

mata: DesBF(`j', `pi0', `pi1', `alpha', `beta', `mu', `nu', `nmin', `nmax', "`optimality'", "`control'", `equal_n', `pl', `pu', `pt', `summary', "`plot'", `"`xopt'"')
if (`j' == 1) {
  matrix colnames des = n1 a1 r1 "PB(pi0)" "PB(pi1)" "PF(pi0)" "PF(pi1)"
}
else {
  matrix colnames des = n1 n2 a1 a2 r1 r2 "PB(pi0)" "PB(pi1)" "PF(pi0)" "PF(pi1)" "ESSB" "ESSF(pi0)" "ESSF(pi1)" "PETB" "PETF(pi0)" "PETF(pi1)" "n1 + n2"
}
return mat des = des
return mat J = J
return mat n = n
return mat a = a
return mat r = r
if (`j' == 1) {
  matrix colnames feasible = n1 a1 r1 "PB(pi0)" "PB(pi1)" "PF(pi0)" "PF(pi1)"
}
else {
  matrix colnames feasible = n1 n2 a1 a2 r1 r2 "PB(pi0)" "PB(pi1)" "PF(pi0)" "PF(pi1)" "ESSB" "ESSF(pi0)" "ESSF(pi1)" "PETB" "PETF(pi0)" "PETF(pi1)" "n1 + n2"
}
return mat feasible = feasible
return mat pi0 = pi0
return mat pi1 = pi1
return mat alpha = alpha
return mat beta = beta
return mat mu = mu
return mat nu = nu
return mat nmin = Nmin
return mat nmax = Nmax
return local optimality "`optimality'"
return local control "`control'"
return mat equal_n = equal_n
return mat PL = PL
return mat PU = PU
return mat PT = PT
return mat summary = summary

restore

end

///// Mata  ////////////////////////////////////////////////////////////////////

mata:

void DesBF(J, pi0, pi1, alpha, beta, mu, nu, Nmin, Nmax, optimality, control, equal_n, PL, PU, PT, summary, plot, xopt)
{

  ///// Print Summary //////////////////////////////////////////////////////////

  
  
  ///// Main Computations //////////////////////////////////////////////////////
  
  feasible = IntDesBF(J, pi0, pi1, alpha, beta, mu, nu, Nmin, Nmax, control, equal_n, PL, PU, PT, summary)
  if (feasible[1, 1] > 0) {
    if (summary == 1) {
	  printf("...feasible designs in range of considered maximal allowed sample size identified....")
      printf("...now identifying optimal design(s)...")
	}
	if (J == 1) {
	  feasible = sort(feasible, (1, -5))
	  des = feasible[1, ]
	  n   = feasible[1, 1]
	  a   = feasible[1, 2]
	  r   = feasible[1, 3]
	}
	else {
	  if (optimality == "ess") {
	    feasible = sort(feasible, (11, 17, -8))
	  }
	  else {
	    feasible = sort(feasible, (17, 11, -8))
	  }
	  des = feasible[1, ]
	  n   = feasible[1, 1::2]
	  a   = feasible[1, 3::4]
	  r   = feasible[1, 5::6]
	}
	if (plot ~= "") {
	  if (J == 1) {
	    states_cont = permutations(0::(n - 1), 2)
	    states_cont = states_cont[mm_which((states_cont[, 1] :<= states_cont[, 2]) :& (states_cont[, 2] :> 0)), ]
	    states_acc  = ((0::a), J(a + 1, 1, n))
	    states_rej  = ((r::n), J(n - r + 1, 1, n))
	    st_matrix("states_cont", states_cont)
	    st_matrix("states_acc", states_acc)
	    st_matrix("states_rej", states_rej)
	    stata("qui svmat states_cont")
	    stata("qui svmat states_acc")
	    stata("qui svmat states_rej")
	    stata(`"twoway (scatter states_cont1 states_cont2, msymbol(oh) color(gs13)) (scatter states_acc1 states_acc2, msymbol(X) color(red)) (scatter states_rej1 states_rej2, msymbol(+) color(green)), xtitle({it:s}) ytitle({it:m}) legend(lab(1 "Continue") lab(2 "Do not reject {it:H}{subscript:0}") lab(3 "Reject {it:H}{subscript:0}"))"'+ xopt)
	  }
	  else {
	    states = permutations((0::n[1]), 2)
	    states = states[mm_which((states[, 1] :<= states[, 2]) :& (states[, 2] :> 0)), ]
	    outcome = J(rows(states), 1, 0)
	    for (i = 1; i <= rows(states); i++) {
	      if (states[i, 1] <= a[1] & states[i, 2] == n[1]) {
		    outcome[i] = 1
		  }
		  else if (states[i, 1] >= r[1] & states[i, 2] == n[1]) {
		    outcome[i] = 2
		  }
	    }
	    states = (states, outcome)
	    cont = (max((0, a[1] + 1)), min((r[1] - 1, n[1])))
	    for (j = 2; j <= J; j++) {
	      vals_j = permutations((0::n[j]), 2)
	      vals_j = vals_j[mm_which((vals_j[, 1] :<= vals_j[, 2]) :& (vals_j[, 2] :> 0)), ]
		  states_j = J(1, 2, .)
		  for (sj = cont[1]; sj <= cont[2]; sj++) {
		    states_j = (states_j \ (vals_j[, 1] :+ sj, vals_j[, 2] :+ sum(n[1::(j - 1)])))
		  }
		  states_j = states_j[2::rows(states_j), ]
		  outcome  = J(rows(states_j), 1, 0)
	      for (i = 1; i <= rows(states_j); i++) {
	        if (states_j[i, 1] <= a[j] & states_j[i, 2] == sum(n[1::j])) {
		      outcome[i] = 1
		    }
		    else if (states_j[i, 2] >= r[j] & states_j[i, 2] == sum(n[1::j])) {
		      outcome[i] = 2
		    }
	      }
		  states_j = (states_j, outcome)
		  cont     = (min(states_j[mm_which(states_j[, 1] :> a[j]), 1]), max(states_j[mm_which(states_j[, 1] :< r[j]), 1]))
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
	}
  }
  else {
    feasible = des = J(1, (J == 1 ? 7 : 17), .)
	n = a = r = .
	if (summary) {
      printf("...no feasible designs found in range of considered maximal allowed sample size. Consider decreasing nmin and increasing nmax...")
    }
  }
  
  ///// Return /////////////////////////////////////////////////////////////////
  
  if (summary == 1) {
    printf("...outputting")
  }
  st_matrix("des", des)
  st_matrix("n", n)
  st_matrix("a", a)
  st_matrix("r", r)
  st_matrix("feasible", feasible)
  st_matrix("J", J)
  st_matrix("pi0", pi0)
  st_matrix("pi1", pi1)
  st_matrix("alpha", alpha)
  st_matrix("beta", beta)
  st_matrix("mu", mu)
  st_matrix("nu", nu)
  st_matrix("Nmin", Nmin)
  st_matrix("Nmax", Nmax)
  st_local("optimality", optimality)
  st_local("control", control)
  st_matrix("equal_n", equal_n)
  st_matrix("PL", PL)
  st_matrix("PU", PU)
  st_matrix("PT", PT)
  st_matrix("summary", summary)
  
}

// Function to determine feasible group sequential designs
real matrix IntDesBF(real scalar J, real scalar pi0, real scalar pi1,
                     real scalar alpha, real scalar beta, real scalar mu,
					 real scalar nu, real scalar Nmin, real scalar Nmax,
					 string control, real scalar equal_n, real scalar PL,
					 real scalar PU, real scalar PT, real scalar summary)
{
  prob_s1_n1 = J(Nmax + 1, Nmax, 0)
  Beta       = beta(mu, nu)
  for (n1 = 1; n1 <= Nmax; n1++) {
    prob_s1_n1[1::(n1 + 1), n1] = comb(n1, 0::n1):*beta(mu :+ (0::n1), nu :+ n1 :- (0::n1))/Beta
  }
  dbinomial_pi0                  = J(Nmax + 1, Nmax, 0)
  dbinomial_pi1                  = J(Nmax + 1, Nmax, 0)
  for (n = 1; n <= Nmax; n++) {
    dbinomial_pi0[1::(n + 1), n] = binomialp(n, 0::n, pi0)
	dbinomial_pi1[1::(n + 1), n] = binomialp(n, 0::n, pi1)
  }
  if (J == 2) {
    prob_s2_s1n1n2 = asarray_create("real", 4)
	for (n1 = 1; n1 <= Nmax; n1++) {
	  for (s1 = 0; s1 <= n1; s1++) {
	    for (n2 = 1; n2 <= Nmax; n2++) {
		  for (s2 = 0; s2 <= n2; s2++) {
		    asarray(prob_s2_s1n1n2, (s2 + 1, s1 + 1, n1, n2), comb(n2, s2)*beta(mu + s1 + s2, nu + n1 - s1 + n2 - s2)/beta(mu + s1, nu + n1 - s1))
		  }
		}
	  }
	}
	PP_TS_s1n1n2 = asarray_create("real", 3)
	for (n1 = 1; n1 <= Nmax; n1++) {
	  for (n2 = 1; n2 <= Nmax; n2++) {
	    for (s1 = 0; s1 <= n1; s1++) {
		  cond_s2 = J(1, n2 + 1, 0)
		  for (s2 = 0; s2 <= n2; s2++) {
		    cond_s2[s2 + 1] = asarray(prob_s2_s1n1n2, (s2 + 1, s1 + 1, n1, n2))
		  }
		  prob = ibetatail(mu :+ s1 :+ (0::n2), nu :+ n1 :+ n2 :- s1 :- (0::n2), pi0)'
		  asarray(PP_TS_s1n1n2, (s1 + 1, n1, n2), sum(cond_s2[mm_which(prob :> PT)]))
		}
	  }
	}
  }
  feasible = J(10^7, (J == 2 ? 17 : 7), 0)
  counter  = 1
  if (J == 1) {
    AB_pi1 = RB_pi0 = AF_pi1 = RF_pi0 = 0
	for (n = Nmin; n <= Nmax; n++) {
	  for (a = 0; a <= n - 1; a++) {
	    r      = a + 1
		RB_pi0 = sum(prob_s1_n1[(r + 1)::(n + 1), n]:*ibeta(mu :+ (r::n), nu :+ n :- (r::n), pi0))
		RF_pi0 = sum(dbinomial_pi0[(r + 1)::(n + 1), n])
		AB_pi1 = sum(prob_s1_n1[1::(a + 1), n]:*ibetatail(mu :+ (0::a), nu :+ n :- (0::a), pi1))
		AF_pi1 = sum(dbinomial_pi1[1::(a + 1), n])
		if (control == "frequentist") {
		  if (RF_pi0 <= alpha & AF_pi1 <= beta) {
		    feasible[counter, ] = (n, a, r, RB_pi0, 1 - AB_pi1, RF_pi0, 1 - AF_pi1)
			counter++
		  }
		}
		else if (control == "bayesian") {
		  if (RB_pi0 <= alpha & AB_pi1 <= beta) {
		    feasible[counter, ] = (n, a, r, RB_pi0, 1 - AB_pi1, RF_pi0, 1 - AF_pi1)
			counter++
		  }
		}
		else {
		  if (RB_pi0 <= alpha & RF_pi0 <= alpha & AB_pi1 <= beta & AF_pi1 <= beta) {
		    feasible[counter, ] = (n, a, r, RB_pi0, 1 - AB_pi1, RF_pi0, 1 - AF_pi1)
			counter++
		  }
		}
	  }
	  if (summary == 1 & mod(n, 10) == 0) {
	    printf("{txt}...completed evaluation of designs with n = {res}%g{txt}...\n", n)
	  }
	}
  }
  else {
    for (n1 = (equal_n == 1 ? ceil(Nmin/2) : 1); n1 <= (equal_n == 1 ? floor(Nmax/2) : Nmax - 1); n1++) {
	  for (n2 = (equal_n == 1 ? n1 : max((1, Nmin - n1))); n2 <= (equal_n == 1 ? n1 : Nmax - n1); n2++) {
	    n      = n1 + n2
		AB_pi1 = RB_pi0 = AF_pi1 = RF_pi0 = J(1, 2, 0)
		PP_TS  = J(1, n1 + 1, 0)
		for (s1 = 0; s1 <= n1; s1++) {
		  PP_TS[s1 + 1] = asarray(PP_TS_s1n1n2, (s1 + 1, n1, n2))
		}
		a1 = max(mm_which(PP_TS :<= PL)) - 1
		r1 = min(mm_which(PP_TS :>= PU)) - 1
		if (a1 ~= .) {
		  AB_pi1[1] = sum(prob_s1_n1[1::(a1 + 1), n1]:*ibetatail(mu :+ (0::a1), nu :+ n1 :- (0::a1), pi1))/sum(prob_s1_n1[1::(a1 + 1), n1])
		  AF_pi1[1] = sum(dbinomial_pi1[1::(a1 + 1), n1])
		}
		if (r1 ~= .) {
		  RB_pi0[1] = sum(prob_s1_n1[(r1 + 1)::(n1 + 1), n1]:*ibeta(mu :+ (r1::n1), nu :+ n1 :- (r1::n1), pi0))/sum(prob_s1_n1[(r1 + 1)::(n1 + 1), n1])
		  RF_pi0[1] = sum(dbinomial_pi0[(r1 + 1)::(n1 + 1), n1])
		}
		check = 1
		if (control == "frequentist") {
		 if (RF_pi0[1] > alpha | AF_pi1[1] > beta) {
		   check = 0
		 }
		}
		else if (control == "bayesian") {
		  if (RB_pi0[1] > alpha | AB_pi1[1] > beta) {
		   check = 0
		  }
		}
		else {
		  if (RF_pi0[1] > alpha | AF_pi1[1] > beta | RB_pi0[1] > alpha | AB_pi1[1] > beta) {
		   check = 0
		 }
		}
		if (check) {
		  PETB     = 0
		  PETF_pi0 = 0
		  PETF_pi1 = 0
		  if (a1 ~= .) {
		    PETB     = sum(prob_s1_n1[1::(a1 + 1), n1])
            PETF_pi0 = sum(dbinomial_pi0[1::(a1 + 1), n1])
            PETF_pi1 = sum(dbinomial_pi1[1::(a1 + 1), n1])
		  }
		  if (r1 ~= .) {
		    PETB     = PETB + sum(prob_s1_n1[(r1 + 1)::(n1 + 1), n1])
            PETF_pi0 = PETF_pi0 + sum(dbinomial_pi0[(r1 + 1)::(n1 + 1), n1])
            PETF_pi1 = PETF_pi1 + sum(dbinomial_pi1[(r1 + 1)::(n1 + 1), n1])
		  }
		  ESSB       = n1 + (1 - PETB)*n2
          ESSF_pi0   = n1 + (1 - PETF_pi0)*n2
          ESSF_pi1   = n1 + (1 - PETF_pi1)*n2
		  if (a1 < r1 - 1) {
		    for (a2 = max((0, a1 + 1)); a2 <= min((r1 + n2 - 2, n1 + n2 - 1)); a2++) {
		      r2    = a2 + 1
			  numer = denom = freq = 0
			    for (s1 = max((0, a1 + 1)); s1 <= min((r1 - 1, n1)); s1++) {
			      if (r2 - s1 <= n2) {
			        for (s2 = max((r2 - s1, 0)); s2 <= n2; s2++) {
				      s     = s1 + s2
				      numer = numer + comb(n1, s1)*comb(n2, s2)*beta(mu + s, nu + n - s)*ibeta(mu + s, nu + n - s, pi0)/Beta
				      denom = denom + comb(n1, s1)*comb(n2, s2)*beta(mu + s, nu + n - s)/Beta
				      freq  = freq + dbinomial_pi0[s1 + 1, n1]*dbinomial_pi0[s2 + 1, n2]
				    }
			      }
			    }
			    RB_pi0[2] = numer/denom
			    RF_pi0[2] = freq
			    numer = denom = freq = 0
			    for (s1 = max((0, a1 + 1)); s1 <= min((r1 - 1, n1)); s1++) {
			      if (s1 <= a2) {
			        for (s2 = 0; s2 <= a2 - s1; s2++) {
				      s     = s1 + s2
				      numer = numer + comb(n1, s1)*comb(n2, s2)*beta(mu + s, nu + n - s)*ibetatail(mu + s, nu + n - s, pi1)/Beta
				      denom = denom + comb(n1, s1)*comb(n2, s2)*beta(mu + s, nu + n - s)/Beta
				      freq  = freq + dbinomial_pi1[s1 + 1, n1]*dbinomial_pi1[s2 + 1, n2]
				    }
			      }
			    }
			    AB_pi1[2] = numer/denom
			    AF_pi1[2] = freq
			  if (control == "frequentist") {
			    if (sum(RF_pi0) <= alpha & sum(AF_pi1) <= beta) {
			      feasible[counter, ] = (n1, n2, a1, a2, r1, r2, sum(RB_pi0), 1 - sum(AB_pi1), sum(RF_pi0), 1 - sum(AF_pi1), ESSB, ESSF_pi0, ESSF_pi1, PETB, PETF_pi0, PETF_pi1, n1 + n2)
				  counter++
			    }
			  }
			  else if (control == "bayesian") {
			    if (sum(RB_pi0) <= alpha & sum(AB_pi1) <= beta) {
			      feasible[counter, ] = (n1, n2, a1, a2, r1, r2, sum(RB_pi0), 1 - sum(AB_pi1), sum(RF_pi0), 1 - sum(AF_pi1), ESSB, ESSF_pi0, ESSF_pi1, PETB, PETF_pi0, PETF_pi1, n1 + n2)
				  counter++
			    }
			  }
			  else {
			    if (sum(RF_pi0) <= alpha & sum(AF_pi1) <= beta & sum(RB_pi0) <= alpha & sum(AB_pi1) <= beta) {
			      feasible[counter, ] = (n1, n2, a1, a2, r1, r2, sum(RB_pi0), 1 - sum(AB_pi1), sum(RF_pi0), 1 - sum(AF_pi1), ESSB, ESSF_pi0, ESSF_pi1, PETB, PETF_pi0, PETF_pi1, n1 + n2)
				  counter++
			    }
			  }
		    }
		  }
		}
	  }
	  if (summary == 1 & mod(n1, 10) == 0) {
	    printf("{txt}...completed evaluation of designs with n1 = {res}%g{txt}...\n", n1)
	  }
	}
  }
  if (counter > 1) {
    feasible = feasible[1::(counter - 1), ]
  }
  else {
    feasible = feasible[1, ]
  }
  return(feasible)
}

real vector beta(real vector a, real vector b)
{
  return(exp(lngamma(a) + lngamma(b) - lngamma(a+b)))
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

end
