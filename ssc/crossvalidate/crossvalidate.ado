// cv: cross-validated predictions from any Stata estimation command.
// Breaks a dataset into a number of subsets ("folds"), and for each
// runs an estimator on everything but that subset, and predicts results.
program define crossvalidate 
*! version 1.2.2  Oct 28, 2020   name change inside crossv.ado

  version 14.1
  /* parse arguments */
  gettoken target 0 : 0
  gettoken estimator 0 : 0
  //  estimators starting with discrim have two words
  if "`estimator'"=="discrim"  gettoken estimator2 0 : 0

  if "`estimator'"=="discrim"  { 
     di as error "Requires special parsing : varlist is no longer y xvars, but instead ,group(y)" 
	 di as error " not yet implemented; see gridsearch.ado"
	 // if ("`estimator'"=="discrim") local addstuff = `"group(`group')"' "
	 exit 198
  }
  
  syntax varlist (fv ts) [if] [in], [folds(string)] [gen(string)] [shuffle] [*]

  confirm name `estimator'
  confirm new variable `target'
  
  //Stata if funky: because I use [*] above, if I declare folds(int 5) and you pass a real (e.g. folds(18.5)), 
  // 	rather than giving the usual "option folds() incorrectly specified" error, Stata *ignores* that folds, 
  //  	gives the default value, and pushes the wrong folds into the `options' macro
  // instead, I take a string (i.e. anything) to ensure the folds option always, and then parse manually
  if("`folds'"=="") {
    local folds = 5
  }
  confirm integer number `folds'
  
  //di as txt "folds= `folds' options=`options'" //DEBUG
  
  qui count `if' `in'
  if(`folds'<1 | `folds'>=`r(N)') {
    di as error "Invalid number of folds: `folds'. Must be between 2 and the number of active observations `r(N)'."
    exit 1
  }
  
  if(`folds'==1) {
    // special case: 1-fold is the same as just training
    `estimator' `estimator2' `varlist' `if' `in', `options'
    predict `target'
    exit 
  }
  
  if("`strata'" != "") {
    confirm variable `strata'
    di as error "crossvalidate: stratification not implemented."
    exit 2
  }
  
  
  /* generate folds */
  // the easiest way to do this in Stata is simply to mark a new column
  // and stamp out id numbers into it
  // the tricky part is dealing with if/in
  // and the trickier (and currently not implemented) part is dealing with
  // stratification (making sure each fold has equal proportions of a categorical variable)
  tempvar fold
    
  // compute the size of each group *as a float*
  // derivation:
  // we have r(N) items in total -- you can also think of this as the last item, which should get mapped to group `folds' 
  // we want `folds' groups
  // if we divide each _n by `folds' then the largest ID generated is r(N)/`folds' == # of items per group
  // so we can't do that
  // if instead we divide each _n by r(N)/`folds', then the largest is r(N)/(r(N)/`folds') = `folds'
  // Also, maybe clearer, this python script empirically proves the formula:
  /*
  for G in range(1,302):
      for N in range(G,1302):
          folds = {k: len(list(g)) for k,g in groupby(int((i-1)//(N/G)+1) for i in range(1,N+1)) }
          print("N =", N, "G =", G, "keys:", set(folds.keys()));
          assert set(folds.keys()) == set(range(1,G+1))
  */
  qui count `if' `in'
  local g =  `r(N)'/`folds'
    // generate a pseudo-_n which is the observation *within the if/in subset*
    // if you do not give if/in this is should be equal to _n
  qui gen int `fold' = 1 `if' `in'
  
  /* shuffling */
  // this is tricky: shuffling has to happen *after* partially generating fold IDs,
  // because the shuffle invalidates the `in', but it must happen *before* the IDs
  // are actually assigned because otherwise there's no point
  if("`shuffle'"!="") {
    tempvar original_order
    tempvar random_order
    qui gen `original_order' = _n
    qui gen `random_order' = uniform()
    sort `random_order'
  }
  
  qui replace `fold' = sum(`fold') if !missing(`fold') //egen has 'fill()' which is more complicated than this, and so does not allow if/in. None of its other options seem to be what I want.
  
  // map the pseudo-_n into a fold id number
  // nopromote causes integer instead of floating point division, which is needed for id numbers
  //Stata counts from 1, which is why the -1 and +1s are there
  // (because the proper computation should happen counting from 0, but not true)
  qui replace `fold' = (`fold'-1)/`g'+1 if !missing(`fold'), nopromote

  // because shuffling can only affect which folds data ends up in,
  // immediately after generating fold labels we can put the data back as they were.
  // (i prefer rather do this early lest something later break and the dataset be mangled)
  // (this can't use snapshot or preserve because restoring those will erase `fold')
  if("`shuffle'"!="") {
    sort `original_order'
  }
  
  // make sure the trickery above worked
  qui sum `fold'
  assert `r(min)'==1
  assert `r(max)'==`folds'
  qui levelsof `fold'
  assert `: word count `r(levels)''==`folds'
  
  
  /* cross-predict */
  // We don't actually predict into target directly, because most estimation commands
  // get annoyed at you trying to overwrite an old variable (even if an unused region).
  // Instead we repeatedly predict into B, copy the fold into target, and destroy B.
  // 
  // We don't actually create `target' until we have done one fold, at which point we *clone* it
  // because we do not know what types/labels the predictor wants to attach to its predictions,
  // (which can lead to strangeness if the predictor is inconsistent with itself)
  tempvar B
  forvalues f = 1/`folds' {
    // train on everything satisfaying `if' `in' that isn't the fold
	// use IFAND to combine `if' with the other if condition
	if ("`if'"=="") local IFAND = "if "   //`if' is empty 
	else			local IFAND = " & "   //`if' is not empty and contains the word if already
    qui count `if' `IFAND'  `fold'!=`f'   `in'
    di as text "[fold `f'/`folds': training on `r(N)' observations]"
    capture noi `estimator' `estimator2' `varlist' `if' `IFAND' `fold' != `f'   `in', `options'
    if(_rc!=0) {
      di as error "`estimator' `estimator2' failed"
      exit _rc
    }
    
    // predict on the fold
    qui count if `fold' == `f'
    di "[fold `f'/`folds': predicting on `r(N)' observations]"
    predict `B' if `fold' == `f'
    
    // on the first fold, *clone* B to our real output
    if(`f' == 1) {
      qui clonevar  `target' = `B' if 0
    }
    
    // save the predictions from the current fold
    qui replace `target' = `B' if `fold' == `f'
    drop `B'
  }
  
  if "`gen'"!="" {
	// optionally, keep fold variable
	gen `gen' = `fold'
  }
  
  /* clean up */
  // drop e(), because its contents at this point are only valid for the last fold
  // and that's just confusing
  ereturn clear
  
end
///////////////////////////////////////////////////////////////////////////////////
//Version History: 
//
//version 1.2.1  Oct 28, 2020   remove eclass; not needed
//version 1.2.0  June, 2020   gen(newvar) option
//version 1.1.0  May, 2020
//version 1.0.0  May, 2017

