*! Date    : 08 May 2018
*! Version : 1.0

/*
 08/05/18 v1.0 Initial version complete
*/

program define des_admissable, rclass
version 11.0
syntax, [J(integer 2) pi0(real 0.1) pi1(real 0.3) Alpha(real 0.05) ///
         Beta(real 0.2) nmin(integer 1) nmax(integer 30) FUTility(integer 1) ///
		 EFFicacy(integer 0) EQual_n(integer 0) ENSign(integer 0) ///
		 SUMmary(integer 0) PLot *]

local xopt `"`options'"'		 
preserve

///// Perform checks on input variables ////////////////////////////////////////

if (`j' <= 1) {
  di "{error} J must be an integer greater than or equal to two."
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
if (`j' > 3) {
  di "{error} J > 3 is not currently supported."
  exit(198)
}

///// Compute and Output ///////////////////////////////////////////////////////

mata: DesAdmissable(`j', `pi0', `pi1', `alpha', `beta', `nmin', `nmax', `futility', `efficacy', `equal_n', `ensign', `summary', "`plot'", `"`xopt'"')
if (`j' == 2) {
  matrix colnames admissable = Design n1 n2 a1 a2 r1 r2 "P(pi0)" "P(pi1)" "PET1(pi0)" "PET1(pi1)" "ESS(pi0)" "ESS(pi1)" "Med(pi0)" "Med(pi1)" "VSS(pi0)" "VSS(pi1)" "max(N)"
}
else {
  matrix colnames admissable = Design n1 n2 n3 a1 a2 a3 r1 r2 r3 "P(pi0)" "P(pi1)" "PET1(pi0)" "PET1(pi1)" "PET2(pi0)" "PET2(pi1)" "ESS(pi0)" "ESS(pi1)" "Med(pi0)" "Med(pi1)" "VSS(pi0)" "VSS(pi1)" "max(N)"
}
return mat admissable = admissable
matrix colnames weights = w0 w1 Design
return mat weights = weights
if (`j' == 2) {
  matrix colnames feasible = Design n1 n2 a1 a2 r1 r2 "P(pi0)" "P(pi1)" "PET1(pi0)" "PET1(pi1)" "ESS(pi0)" "ESS(pi1)" "Med(pi0)" "Med(pi1)" "VSS(pi0)" "VSS(pi1)" "max(N)"
}
else {
  matrix colnames feasible = Design n1 n2 n3 a1 a2 a3 r1 r2 r3 "P(pi0)" "P(pi1)" "PET1(pi0)" "PET1(pi1)" "PET2(pi0)" "PET2(pi1)" "ESS(pi0)" "ESS(pi1)" "Med(pi0)" "Med(pi1)" "VSS(pi0)" "VSS(pi1)" "max(N)"
}
return mat feasible = feasible
return mat J = J
return mat pi0 = pi0
return mat pi1 = pi1
return mat alpha = alpha
return mat beta = beta
return mat nmin = Nmin
return mat nmax = Nmax
return mat futility = futility
return mat efficacy = efficacy
return mat equal_n = equal_n
return mat ensign = ensign
return mat summary = summary

restore

end

///// Mata  ////////////////////////////////////////////////////////////////////

mata:

void DesAdmissable(J, pi0, pi1, alpha, beta, Nmin, Nmax, futility, efficacy, equal_n, ensign, summary, plot, xopt)
{

  ///// Print Summary //////////////////////////////////////////////////////////


  
  ///// Main Computations //////////////////////////////////////////////////////
  
  feasible = IntDesAdmissable(J, pi0, pi1, alpha, beta, Nmin, Nmax, futility, efficacy, equal_n, ensign, summary)
  if (feasible[1, 2] > 0) {
    if (summary == 1) {
	  printf("...feasible designs in range of considered maximal allowed sample size identified....")
      printf("...now identifying admissable design(s)...")
	}
	feasible = (feasible[, 1::(2*J + J)], feasible[, 2*J + 1] + J(rows(feasible), 1, 1), feasible[, (2*J + J + 1)::cols(feasible)], rowsum(feasible[, 2::(J + 1)]))
	if (futility ~= 1) {
	  feasible[, (J + 1)::(2*J - 1)] = J(rows(feasible), J - 1, .)
	}
	if (efficacy ~= 1) {
	  feasible[, (2*J + 1)::(3*J - 1)] = J(rows(feasible), J - 1, .)
	}
	feasible         = sort(feasible, (5*J + 2, 5*J + 8))
	weights          = permutations(0.005*(0::200), 2)
	weights          = select(weights, rowsum(weights) :<= 1)
	weights          = weights[2::rows(weights), ]
	opt_indices      = J(rows(weights), 1, 0)
	admissable       = select(feasible, feasible[, 1] :== 1)
	for (i = 1; i <= rows(weights); i++) {
	  opt_indices[i] = order(weights[i, 1]*admissable[, 5*J + 2] + weights[i, 2]*admissable[, 5*J + 3] + (1 - weights[i, 1] - weights[i, 2])*admissable[, 5*J + 8], 1)[1]
	}
	uniq_opt_indices = uniqrows(opt_indices)
	admissable       = admissable[uniq_opt_indices, ]
	admissable[, 1]  = 1::rows(admissable)
	optimal_des      = J(rows(weights), 1, 0)
	for (i = 1; i <= length(uniq_opt_indices); i++) {
	  optimal_des[mm_which(opt_indices :== uniq_opt_indices[i])] = J(length(mm_which(opt_indices :== uniq_opt_indices[i])), 1, i)
	}
	weights          = (weights, optimal_des)
	if (plot ~= "") {
	  if (length(uniq_opt_indices) >= 1) {
	    weights1 = weights[mm_which(weights[, 3] :== 1), ]
	    st_matrix("weights1", weights1)
	    stata("qui svmat weights1")
	  }
	  if (length(uniq_opt_indices) >= 2) {
	    weights2 = weights[mm_which(weights[, 3] :== 2), ]
	    st_matrix("weights2", weights2)
	    stata("qui svmat weights2")
	  }
	  if (length(uniq_opt_indices) >= 3) {
	    weights3 = weights[mm_which(weights[, 3] :== 3), ]
	    st_matrix("weights3", weights3)
	    stata("qui svmat weights3")
	  }
	  if (length(uniq_opt_indices) >= 4) {
	    weights4 = weights[mm_which(weights[, 3] :== 4), ]
	    st_matrix("weights4", weights4)
	    stata("qui svmat weights4")
	  }
	  if (length(uniq_opt_indices) >= 5) {
	    weights5 = weights[mm_which(weights[, 3] :== 5), ]
	    st_matrix("weights5", weights5)
	    stata("qui svmat weights5")
      }
	  if (length(uniq_opt_indices) >= 6) {
	    weights6 = weights[mm_which(weights[, 3] :== 6), ]
	    st_matrix("weights6", weights6)
	    stata("qui svmat weights6")
	  }
	  if (length(uniq_opt_indices) >= 7) {
	    weights7 = weights[mm_which(weights[, 3] :== 7), ]
	    st_matrix("weights7", weights7)
	    stata("qui svmat weights7")
	  }
	  if (length(uniq_opt_indices) >= 8) {
	    weights8 = weights[mm_which(weights[, 3] :== 8), ]
	    st_matrix("weights8", weights8)
	    stata("qui svmat weights8")
	  }
	  if (length(uniq_opt_indices) > 8) {
	    printf("Warning: Admissability plot currently only supports the presence of 8 or less admissable designs")
	  }
	  if (length(uniq_opt_indices) == 1) {
	    stata(`"twoway (scatter weights12 weights11, color(black) msymbol(o)), xtitle({it:w}{subscript:0}) ytitle({it:w}{subscript:1}) legend(lab(1 "Design 1"))"'+ xopt)
	  }
	  else if (length(uniq_opt_indices) == 2) {
	    stata(`"twoway (scatter weights12 weights11, color(black) msymbol(o)) (scatter weights22 weights21, color(blue) msymbol(o)), xtitle({it:w}{subscript:0}) ytitle({it:w}{subscript:1}) legend(lab(1 "Design 1") lab(2 "Design 2"))"'+ xopt)
	  }
	  else if (length(uniq_opt_indices) == 3) {
	    stata(`"twoway (scatter weights12 weights11, color(black) msymbol(o)) (scatter weights22 weights21, color(blue) msymbol(o)) (scatter weights32 weights31, color(green) msymbol(o)), xtitle({it:w}{subscript:0}) ytitle({it:w}{subscript:1}) legend(lab(1 "Design 1") lab(2 "Design 2") lab(3 "Design 3"))"'+ xopt)
	  }
	  else if (length(uniq_opt_indices) == 4) {
	    stata(`"twoway (scatter weights12 weights11, color(black) msymbol(o)) (scatter weights22 weights21, color(blue) msymbol(o)) (scatter weights32 weights31, color(green) msymbol(o)) (scatter weights42 weights41, color(red) msymbol(o)), xtitle({it:w}{subscript:0}) ytitle({it:w}{subscript:1}) legend(lab(1 "Design 1") lab(2 "Design 2") lab(3 "Design 3") lab(4 "Design 4"))"'+ xopt)
	  }
	  else if (length(uniq_opt_indices) == 5) {
	    stata(`"twoway (scatter weights12 weights11, color(black) msymbol(o)) (scatter weights22 weights21, color(blue) msymbol(o)) (scatter weights32 weights31, color(green) msymbol(o)) (scatter weights42 weights41, color(red) msymbol(o)) (scatter weights52 weights51, color(yellow) msymbol(o)), xtitle({it:w}{subscript:0}) ytitle({it:w}{subscript:1}) legend(lab(1 "Design 1") lab(2 "Design 2") lab(3 "Design 3") lab(4 "Design 4") lab(5 "Design 5"))"'+ xopt)
	  }
	  else if (length(uniq_opt_indices) == 6) {
	    stata(`"twoway (scatter weights12 weights11, color(black) msymbol(o)) (scatter weights22 weights21, color(blue) msymbol(o)) (scatter weights32 weights31, color(green) msymbol(o)) (scatter weights42 weights41, color(red) msymbol(o)) (scatter weights52 weights51, color(yellow) msymbol(o)) (scatter weights62 weights61, color(orange) msymbol(o)), xtitle({it:w}{subscript:0}) ytitle({it:w}{subscript:1}) legend(lab(1 "Design 1") lab(2 "Design 2") lab(3 "Design 3") lab(4 "Design 4") lab(5 "Design 5") lab(6 "Design 6"))"'+ xopt)
	  }
	  else if (length(uniq_opt_indices) == 7) {
	    stata(`"twoway (scatter weights12 weights11, color(black) msymbol(o)) (scatter weights22 weights21, color(blue) msymbol(o)) (scatter weights32 weights31, color(green) msymbol(o)) (scatter weights42 weights41, color(red) msymbol(o)) (scatter weights52 weights51, color(yellow) msymbol(o)) (scatter weights62 weights61, color(orange) msymbol(o)) (scatter weights72 weights71, color(purple) msymbol(o)), xtitle({it:w}{subscript:0}) ytitle({it:w}{subscript:1}) legend(lab(1 "Design 1") lab(2 "Design 2") lab(3 "Design 3") lab(4 "Design 4") lab(5 "Design 5") lab(6 "Design 6") lab(7 "Design 7"))"'+ xopt)
	  }
	  else if (length(uniq_opt_indices) == 8) {
	    stata(`"twoway (scatter weights12 weights11, color(black) msymbol(o)) (scatter weights22 weights21, color(blue) msymbol(o)) (scatter weights32 weights31, color(green) msymbol(o)) (scatter weights42 weights41, color(red) msymbol(o)) (scatter weights52 weights51, color(yellow) msymbol(o)) (scatter weights62 weights61, color(orange) msymbol(o)) (scatter weights72 weights71, color(purple) msymbol(o)) (scatter weights82 weights81, color(brown) msymbol(o)), xtitle({it:w}{subscript:0}) ytitle({it:w}{subscript:1}) legend(lab(1 "Design 1") lab(2 "Design 2") lab(3 "Design 3") lab(4 "Design 4") lab(5 "Design 5") lab(6 "Design 6") lab(7 "Design 7") lab(8 "Design 8"))"'+ xopt)
	  }
	}
  }
  else {
    feasible = admissable = J(1, (J == 2 ? 18 : 23), .)
	weights  = J(1, 3, .)
	if (summary) {
      printf("...no feasible designs found in range of considered maximal allowed sample size. Consider decreasing nmin and increasing nmax...")
    }
  }
  
  ///// Return /////////////////////////////////////////////////////////////////
  
  if (summary == 1) {
    printf("...outputting")
  }
  st_matrix("admissable", admissable)
  st_matrix("weights", weights)
  st_matrix("n", n)
  st_matrix("a", a)
  st_matrix("r", r)
  st_matrix("feasible", feasible)
  st_matrix("J", J)
  st_matrix("pi0", pi0)
  st_matrix("pi1", pi1)
  st_matrix("alpha", alpha)
  st_matrix("beta", beta)
  st_matrix("Nmin", Nmin)
  st_matrix("Nmax", Nmax)
  st_matrix("futility", futility)
  st_matrix("efficacy", efficacy)
  st_matrix("equal_n", equal_n)
  st_matrix("ensign", ensign)
  st_matrix("summary", summary)
}

// Function to determine feasible group sequential designs
real matrix IntDesAdmissable(real scalar J, real scalar pi0, real scalar pi1,
                             real scalar alpha, real scalar beta,
							 real scalar Nmin, real scalar Nmax,
							 real scalar futility, real scalar efficacy,
							 real scalar equal_n, real scalar ensign,
							 real scalar summary)
{
  dbinomial_pi0                  = J(Nmax, Nmax - 1, 0)
  dbinomial_pi1                  = J(Nmax, Nmax - 1, 0)
  for (i = 1; i <= Nmax - 1; i++) {
    dbinomial_pi0[1::(i + 1), i] = binomialp(i, 0::i, pi0)
	dbinomial_pi1[1::(i + 1), i] = binomialp(i, 0::i, pi1)
  }
  A_pi0 = A_pi1 = R_pi0 = R_pi1 = J(1, J, 0)
  C_pi0 = C_pi1 = J(Nmax + 1, J, 0)
  feasible_designs = J(500000, (J == 2 ? 16 : 21), 0)
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
				feasible_designs[counter, ] = (1, n1, n2, a1, a2, r1, sum(R_pi0), sum(R_pi1), PET1_pi0, PET1_pi1, ESS_pi0, ESS_pi1, Med_pi0, Med_pi1, Var_pi0, Var_pi1)
				for (i = 1; i <= counter - 1; i++) {
                  if ((feasible_designs[counter, 11] >= feasible_designs[i, 11]) & (feasible_designs[counter, 12] > feasible_designs[i, 12]) & (sum(feasible_designs[counter, 2::3]) > sum(feasible_designs[i, 2::3]))) {
				    feasible_designs[counter, 1] = 0
					break
			      }
                }
                if (feasible_designs[counter, 1] == 1 & counter > 1) {
                  admissable = mm_which(feasible_designs[1::(counter - 1), 1] :== 1)
                  for (i = 1; i <= length(admissable); i++) {
                    if ((feasible_designs[admissable[i], 11] >= feasible_designs[counter, 11]) & (feasible_designs[admissable[i], 12] > feasible_designs[counter, 12]) & (sum(feasible_designs[admissable[i], 2::3]) > sum(feasible_designs[counter, 2::3]))) {
                      feasible_designs[admissable[i], 1] = 0
                    }
                  }
                }
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
                      feasible_designs[counter, ] = (1, n1, n2, n3, a1, a2, a3, r1, r2, sum(R_pi0), sum(R_pi1), PET1_pi0, PET1_pi1, PET2_pi0, PET2_pi1, ESS_pi0, ESS_pi1, Med_pi0, Med_pi1, Var_pi0, Var_pi1)
					  for (i = 1; i <= counter - 1; i++) {
                        if ((feasible_designs[counter, 16] >= feasible_designs[i, 16]) & (feasible_designs[counter, 17] > feasible_designs[i, 17]) & (sum(feasible_designs[counter, 2::4]) > sum(feasible_designs[i, 2::4]))) {
				          feasible_designs[counter, 1] = 0
					      break
					    }
                      }
                      if (feasible_designs[counter, 1] & counter > 1) {
                        admissable = mm_which(feasible_designs[1::(counter - 1), 1] :== 1)
                        for (i = 1; i <= length(admissable); i++) {
                          if ((feasible_designs[admissable[i], 16] >= feasible_designs[counter, 16]) & (feasible_designs[admissable[i], 17] > feasible_designs[counter, 17]) & (sum(feasible_designs[admissable[i], 2::4]) > sum(feasible_designs[counter, 2::4]))) {
                            feasible_designs[admissable[i], 1] = 0
                          }
                        }
                      }
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
