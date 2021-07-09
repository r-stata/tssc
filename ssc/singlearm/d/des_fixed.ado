*! Date    : 08 May 2018
*! Version : 1.0

/*
 08/05/18 v1.0 Initial version complete
*/

program define des_fixed, rclass
version 11.0
syntax, [pi0(real 0.1) pi1(real 0.3) Alpha(real 0.05) Beta(real 0.2) ///
         nmin(integer 1) nmax(integer 30) EXact(integer 1) ///
		 SUMmary(integer 0) PLot *]

local xopt `"`options'"'		 
preserve

///// Perform checks on input variables ////////////////////////////////////////

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

///// Compute and Output ///////////////////////////////////////////////////////

mata: DesFixed(`pi0', `pi1', `alpha', `beta', `nmin', `nmax', `exact', `summary', "`plot'", `"`xopt'"')

matrix rownames des = "Optimal design"
matrix colnames des = n a r "P(pi0)" "P(pi1)"
return mat des = des
return mat n = n
return mat a = a
return mat r = r
matrix colnames feasible = n a r "P(pi0)" "P(pi1)"
return mat feasible = feasible
return mat pi0 = pi0
return mat pi1 = pi1
return mat alpha = alpha
return mat beta = beta
return mat nmin = Nmin
return mat nmax = Nmax
return mat exact = exact
return mat summary = summary

restore

end

///// Mata  ////////////////////////////////////////////////////////////////////

mata:

void DesFixed(pi0, pi1, alpha, beta, Nmin, Nmax, exact, summary, plot, xopt)
{

  ///// Print Summary //////////////////////////////////////////////////////////

  
  
  ///// Main Computations //////////////////////////////////////////////////////
  
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
  }
  else {
    feasible = des = J(1, 5, .)
	n = a = r = .
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
  st_matrix("pi0", pi0)
  st_matrix("pi1", pi1)
  st_matrix("alpha", alpha)
  st_matrix("beta", beta)
  st_matrix("Nmin", Nmin)
  st_matrix("Nmax", Nmax)
  st_matrix("exact", exact)
  st_matrix("summary", summary)
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
