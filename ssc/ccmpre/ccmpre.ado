//*! version 1.00 - Mike Lacy 15Feb2013.  
cap prog drop ccmpre
prog ccmpre, rclass
// Calculate proportional reduction in error measures after a ccm model
// based on predicting the raw response data.  
//
syntax varlist [if] [in],  key(name) COMPetence(name) [base(string)]
version 11.3  // Might well work on a lower version; I don't know.
//
// competence: N X 1 matrix giving competence scores
// key: matrix of answer key probs, where key[k,l] gives Prob(response l is right answer to question k
// base: string giving user choice of base guessing model //
//       with {U I T} (uniform,individual, total} 
marksample touse
// validate input
quiet count if `touse'
if (r(N) != rowsof(`competence')) {
  di as error "Error, data given to -ccmpre- has different N than matrix `competence'".
  exit
}
if (colsof(`competence') > 1) {
  di as error "Error, competence matrix must be N X 1.".
  exit
}
confirm matrix `key'
confirm matrix `competence'
//
unab X: `varlist' 
local K = rowsof(`key')
local L = colsof(`key')
di "Key covers `K' questions with `L' possible responses. "
local N = rowsof(`competence')
// which guessing model
if ("`base'" == "") | (!inlist("`base'", "I", "T", "U")) {
   local base = "U"
}
// Mata does the work
mata: ResponsePRE("`X'", "`competence'", "`key'", "`base'",  "`touse'")
// Handle the returns
return add 
// Here is what was returned by Mata to r()
//	   E2Item	errors expected for each item under the model
//    E2   		total of errors under the model
//	   E1Item   errors expected for each item under the baseline model
//    E1    	total of errors under the baseline model 
//    PRE   	the PRE measure
return add 
return local basemodel = "`base'"
// Put nice rownames onto matrices before return
tempname temp
foreach M in E2Item E1Item {
   mat `temp' = return(`M')
	mat rownames `temp' = `X'
	return matrix `M' = `temp'
}	
//
di as text "Proportional Reduction in Error:"
di as text _col(5) "Predicted error under baseline(`base'): " as result(return(E1))
di as text _col(5)  "Predicted error under the model: " as result return(E2)
di as text _col(5) "PRE = " as result return(PRE) 
end
//
cap mata mata drop ResponsePRE()
mata:
void ResponsePRE(string scalar Xvarlist, ///   /* varlist of variables with raw response data */
           string scalar Dmatname, ///      /* name of competence matrix*/
           string scalar Zmatname, ///      /* name of key matrix */
           string scalar base,    ///       /* model for baseline error */
           string scalar touse)             /* name of the touse variable */
{   
// Names of response variables, competence matrix, and key matrix
// Calculates the response-based PRE measure, returning the overall and per item measure
  real scalar i, k, l
  real matrix X   // Xik is response of person i to item k,
  real matrix Z   // Zkl is Prob(l is the right answer to item k
  real colvector D  // Di is competence of person i
  real colvector E  // Ek is expected prediction error for item k
  real rowvector pobs // pobs[i] is the probability of getting person i's 
                      // observed response on a given item, given the key and D[i]
  real matrix pImarg // pImarg_il is person i's marginal response proportion for category l
  real matrix pTmarg // pTmarg_l is all persons' person marginal response proportion for category l
  //
   
  // Obtain raw data
  X = st_data(., tokens(Xvarlist), touse) 
  D = st_matrix(Dmatname) 
  Z = st_matrix(Zmatname) 
  N = rows(X)  // n of subjects
  nitems= cols(X) // n of items
  ncat = cols(Z)  // number of response categories each item
  //
  /*
  // Echo input
  printf("Competence\n")
  round(D, 0.001)
  printf("Key")
  round(Z, 0.01)
  printf("Observed Response matrix\n")
  X
  */
  //
  //
  // Calculation of error under the model, given key and competence
  pobs = J(N, 1, 0)
  E = J(nitems, 1, 0) // initialize for sum of errors on each item
                      // E[k,1] = expected errors on item k, 0 < E < N
  for (k = 1; k <= nitems; k++) { // one item at a time
      for ( i = 1; i <= N; i++) {  
        observed = X[i,k] 
        // Model based prob(observed)
        pobs[i] = Z[k,observed]*D[i]  + (1-D[i])/ncat
        //debug printf("pobs %2.0f = %6.3f\n", i, pobs[i])  
      }
      // errors on this item, sum across all persons
      E[k] = N - sum(pobs)  // Error = Total - expected correct
      //debug printf ("C item %2.0f:",k); sum(pobs); printf("\n") 
      //debug printf ("E item %2.0f:",k); E[k]; printf("\n")  
         
  }
  st_matrix("r(E2Item)", E)  // errors expected for each item under the model
  E2 = sum(E)  // total of errors expected under the model
  st_numscalar("r(E2)", E2)
  //
  // Calculate errors under the baseline or guessing model,
  // We first must set up for whichever of the various guessing 
  // regimes is being used
  // 
  if (base != "U" ) {  
     // Get each individuals' marginals for each response category 
     // across all items. Can use as is for I or collapse to T.
     pImarg = J(N, ncat, 0)
     for ( i = 1; i <= N ; i++) {
        for ( k = 1; k <= nitems; k++) {
           observed = X[i,k]
        	  pImarg[i, observed]  = pImarg[i, observed] + 1 
        }	
     }   
     pImarg = pImarg * (1/nitems)
     // " debug pImarg"
     //debug pImarg 
     if (base == "T")  {  // collapse I marginals to T
        pTmarg = J(1, ncat, 0) // 
        pTmarg = colsum(pImarg) * (1/N) 
     }
     
  }
  // Else guessing will just be U uniform, the default.
  // 
  // Count expected errors under the baseline model
  pobs  = J(N, 1, 0)  
  E = J(nitems, 1, 0) // initialize for accumulation
  for (k = 1; k <= nitems; k++) { 
     for ( i = 1; i <= N; i++) {  
        observed = X[i,k] 
        if (base == "I") {
           pobs[i] = pImarg[i,observed] // individual marg prob for the obs cat
           //debug printf("Ebase pobs item %2.0f, person %2.0f = %6.3f\n", k,i, pobs[i]) 
        }
        else if (base == "T") {
           pobs[i] = pTmarg[observed]   // overall marg prob for the obs cat
        }
        else if (base == "U") {
           pobs[i] = 1/ncat             // uniform prob of the observed cat
        }
      }
      E[k] = N - sum(pobs)              // Error on this item = Total - expected correct
  }  
  st_matrix("r(E1Item)", E)          // Errors expected for each item under the baseline model
  E1 = sum(E)
  st_numscalar("r(E1)", E1) 			// total of errors expected under the baseline
  //
  st_numscalar("r(PRE)", (E1 - E2)/E1)
  //
  //
}
end // mata
//



