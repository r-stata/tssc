*! Date        : 19 August 2009
*! Version     : 1.37
*! Author      : Adrian Mander
*! Email       : adrian.mander@mrc-hnr.cam.ac.uk
*! Description : Quantitative trait haplotype analysis

/*
 2/3/01 bug fix in haplo expansion for haplotypes 
 2/6/03 bug fix in the additive haplotype model 
v 1.36 21/8/06 changed email 
v 1.37 19/8/09  bug fix .. an append using  `stack' to append using "`stack'"
*/

program define qhapipf, rclass
version 7.0
syntax [varlist] [using/] [if] ,[ IPF(string) REGress(string) DOM(string) START DISplay EXPect KNOWN PHASE(varname) ACC(real 0.001) IPFACC(real 0.000001) DEBUG(integer 0) NOLOG MODEL(integer 0) LRTEST(numlist) RARE(real 0) CONVARS(string) CONFILE(string) QUIET NOISE MV HAP(string) MVDEL LOGALL(integer 1) MENU QT(varname)] 

/*Check on the missing option */

if "`mv'"~="" & "`mvdel'"~="" {
  di as error "The mv and mvdel options can not be specified at the same time"
  exit(198)
}

if _N==0 {
  di as error "No observations"
  exit(2000)
}
di

/* Run the command from the menu system */

if "`menu'"~="" {
  cap _qmenu
  if _rc==3000 {
    di as text "Running $Qcommand..."
    $Qcommand
    exit
  }
  if _rc~=3000 {
    di in red "Command will not be run"
    exit 
  }
}

if "`qt'"=="" {
  di in red "You must specify the Quantitative trait variable using the qt() option"
  exit(198)
}

tokenize "`varlist'"

matrix drop _all

cap which ipf
if _rc~=0 {
  di in red "YOU MUST INSTALL ipf.ado which was first introduced in STB55"
  di as error "This function performs the log-linear modelling"
  exit
}

tempfile origin temp
qui save "`origin'",replace

if "`if'"~="" { keep `if' }

global all_name "`varlist'"
global nloc 0
global nsub= _N

/* Just a little check on the state of the dummy variable construction. */

if "`hap'"=="" {
  if "`quiet'"~="" {
    di "The program will attempt to select the reference haplotype"
    di "Use hap() to alter this e.g. hap(1.1.1) for 3 loci model"
  }
}

/***************************************************
 * Delete all lines with missing marker information
 * for each marker in the varlist
 ***************************************************/
  
  if "`mv'"~="" & "`known'"~="" { di as error "If you want to impute missing data then phase is not known for those people with missing typings!" }
  
  if "`mvdel'"~="" {
    di
    di as text "You have selected the deletion of missing lines"
    di "-----------------------------------------------"
    di as res "Variable [variable label] (#lines deleted)"
    while "`1'"~="" {
      qui count if `1'==.
      local lab : variable label `1'
      if "`lab'"~="" { di  _continue "`1' [`lab']", _col(17) " (" %4.0f `r(N)' ")" }
      else { di  _continue "`1'", _col(10) " (" %4.0f `r(N)' ")" }
      qui drop if `1'==.
      mac shift 1
      qui count if `1'==.
      local lab : variable label `1'
      if "`lab'"~="" { di  _col(10) "`1' [`lab'] (`r(N)')" }
      else { di  _col(10) "`1'  (`r(N)')" }
      qui drop if `1'==.
      mac shift 1
    }
  }
tokenize "`varlist'"

/***************************************************
 * warnings about missing data and the subsequent
 * deletion of the data
 ***************************************************/

qui summ `qt'
if `r(N)'~=_N {
  local nomiss = _N-`r(N)'
  di as text "Missing in the quantitative trait variable"
  di "------------------------------------------"
  di as text "There are `nomiss' missing values in `qt'"
  di as error "These lines will be deleted...."
  di
  qui drop if `qt'==.
}

/*********************************************
 * Pair the data from the varlist
 * and check that they are numeric
 *********************************************/

if "`quiet'"=="" {
  di
  di in green "Marker information"
  di in smcl "{dup 18:{c -}}"
}

local i 1
while "`1'"~="" {
   if "`2'"=="" { di in red "There must be paired data" }
   global nloc =$nloc+1
   local wc1=2*$nloc-1
   local wc2=`wc1'+1
   local root1: word `wc1' of $all_name
   local root2: word `wc2' of $all_name
   cap confirm string variable `root1'
   if _rc==0 {
     di "`root1' cannot be a string variable"
     exit(7)
   }
   cap confirm string variable `root2'
   if _rc==0 {
     di "`root2' cannot be a string variable"
     exit(7)
   }
   if "`quiet'"=="" {
     local lab1 : variable label `root1'
     local lab2 : variable label `root2'
     if "`lab1'"~="" & "`lab2'"~="" { di as res "Alleles for l$nloc are (`root1' , `root2') [`lab1' , `lab2']" }
     else { di as res "Alleles for l$nloc are (`root1' , `root2') " }
   }
   return local loci`i' = "`root1' `root2'"
   local i = `i'+1
mac shift 2
}
                                                                 
if "`quiet'"=="" {di}

local nloc = $nloc
if "`nloc'"~="1" {
  local haptext "Haplotype"
  local haptvar "Haplo"
}
else {
  local haptext "Allele"
  local haptvar "Allele"
}

/**********************************
 * Check out the constraint file
 **********************************/

tempfile temp

qui save "`temp'",replace

if "`confile'"~="" {
   di
   di as txt "NB the degrees of freedom are wrong when using the constraint files" 
   if "`convars'"=="" { di as error "You must specify the convars() option when using constraint files" }
   use "`confile'",replace
   tokenize "`convars'"
   cap confirm variable Efreqold
   if _rc~=0 {
     cap confirm variable Ifreq
     if _rc~=0 {
       di in red "Constraints file doesnt contain Efreqold or Ifreq!"
       exit(198)
     }
     else { rename Ifreq Efreqold }
   }
   sort `convars'
   save "`confile'",replace
   
   while "`1'"~="" {
     mac shift 1
   }
}

/*********************************************
 * Make sure about including the ipf() option
 *********************************************/

  if "`ipf'"=="" {
    di in red "You must specify the loglinear model in the ipf() option "
    exit(198)
  }
  if "`regress'"=="" {
    di in red "You must specify the quantitative model in the regress() option "
    exit(198)
  }

use "`temp'",replace

/**********************************************************************
 * haplotyp expands the dataset into the phases
 * Takes the varlist and constructs the haplotypes
 * locus1 and locus2
 * For phase unknown locus1 and locus2 contain all possible haplotypes
 **********************************************************************
 * Additionally the user can specify that there are missing values
 * in the DNA typings with the MV option
 */

if "`known'"~="" & "`phase'"=="" { haplotyp, known `mv'}
if "`known'"=="" & "`phase'"==""{ haplotyp, `mv'}
if "`phase'"~="" { haplotyp,known phase(`phase') `mv'}


/* Haplotype dummy variables */

qui save "`temp'",replace

/*
 * If hap == all then when markers are multiallelic all factors are fitted
 * Else a single haplotype of interest is used as a reference factor.
 */

if "`hap'"=="all" {
  di as err "This has been disabled"
  exit(198)
  _mkdum2, add(`add')
}
else {
  if "`hap'"=="" { local hap "none" }
  if "`dom'"=="" { _mkdummy, hap(`hap') reg(`regress') file(`origin') }
}

local regnv=`r(nvars)'
local regmod "`r(model)'"
local regmoda "`r(modela)'"
local regmodb "`r(modelb)'"

use "`temp'",replace

qui {
drop `varlist'
compress
}

/***********************************************************
 * Start frequencies f1 - future thing to do is to 
 * implement a weighting system on the start points
 *
 * Note that if a subject has been expanded by phase then
 * the start frequencies are spread evenly by default
 ***********************************************************/

tempvar f1 tef1
if "`start'"=="" {
   sort subject
   qui by subject: gen double `f1'=1/_N 
}
else {
   sort subject
   qui gen double `f1'=uniform()
   qui by subject: gen double `tef1'= sum(`f1')
   qui by subject: replace `f1'= `f1'/`tef1'[_N]
   drop `tef1'
}

/*********************************************
 *   EM algorithm - We have equal weights for each genotype phase.
 * First we need to estimate haplotype frequencies given these weights.
 * Then use the hap frequencies in estimating P(H1)P(H2)
 * To calulate P(Y|H1,H2) use a regression model and put the fitted parameters
 * into the pdf to get the new weights
 *********************************************/

local cont 1
local it 0
local saveimp 0 

      cap confirm new variable locus
      if _rc~=0 {
        di in red "Rename the variable locus"
        exit(111)
      }

/* Setup the temporary variables for the two regressions */

tempvar y1 y2 y1old y2old

while(`cont'==1) { /*Start of while loop */
                       
   cap drop `pr' `prs'
   tempvar pr prs stupid plocus

   cap drop llh
   local it = `it'+1

/************************************************************
 *       # New estimate of haplotype relative frequencies
 ************************************************************/

   cap drop freq

      gen long `stupid' = _n /* this will preserve line numbers */

   /* Make one column of the haplotypes keeping all other variables as well */

      qui _stack locus1 locus2
      qui rename locus1 locus
      qui drop locus2

    /* generate individual loci variables - l1 l2 l3 ... put them in `vlist' */

      local i 1
      local vlist " "
      qui gen str40 `plocus' = locus
      while `i'<=$nloc {
         tempvar len len2
         qui gen `len' = index(`plocus',".")-1
         qui gen l`i'=real(substr(`plocus',1,`len'))
         if `i'==$nloc { qui replace l`i'=real(`plocus') }
         else { qui gen `len2' = index(`plocus',".")+1
         qui replace `plocus'=substr(`plocus',`len2',.) }
         drop `len'
         cap drop `len2'
         local vlist "`vlist' l`i'"
         local i=`i'+1
      }

      drop `plocus'

/************************************************************
 * Use the iterative proportional fitting algorithm and save
 * the expected frequencies in fit.dta
 * The variables present in the model are output into the
 * r(vlist) as this may contain more variables than loci
 ************************************************************/
                     
tempfile fit
local file = substr("`fit'",1,index("`fit'",".")-1)
                
   if "`convars'"=="" {
     if "`noise'"=="" { qui ipf [fw=`f1'], exp fit(`ipf') save(`file') acc(`ipfacc') }
     else{ ipf [fw=`f1'], exp fit(`ipf') save(`file') acc(`ipfacc')  }
   }
   else {
      qui ipf [fw=`f1'],exp convars(`convars') confile(`confile') fit(`ipf') save(`file') acc(`ipfacc')
   }
       
   local df=r(df)
   local nparms=r(parms)
   local ncells=r(ncells)
   sort `r(vlist)'
   global ipflist = "`r(vlist)'"   /* should contain list of loci l1 l2 l3 ... */
   merge `r(vlist)' using `file'   /* merge in the new frequencies */

/******************************************************
 * Note now the haplotype probabilities are in prob
 *-----------------------------------------------------
 * Sometimes fit.dta has an unobserved line of  and we
 * have to reconstruct locus from l*
 ******************************************************/

local rvlist "`r(vlist)'"
qui count if locus==""

if `debug'>1 {
  l locus caco Efreq prob if locus==""
  di "`r(N)' loci missing"
}

if `r(N)' > 0 {
  tempvar temprep
  gen `temprep' = locus==""
  local i 1
  while `i'<=$nloc {
    qui replace locus = cond( locus=="", locus + string(l`i'), locus +"."+ string(l`i')) if `temprep'==1
    local i = `i'+1
  }
}

if `debug'>2 {
  l locus caco Efreq prob 
}

/*******************************************************
 * Saving the expected Frequencies when the algorithm
 * converges
 *******************************************************/

  if `saveimp'==1 {
    tempfile imputef now
    qui save "`now'"
    sort `rvlist'
    qui by `rvlist': keep if _n==1
    qui save "`imputef'"
    use "`now'",clear
  }

/*************************************************************
 * Tidy up the datafile and retransform into wide format
 *************************************************************/

      drop `vlist' Efreq Ofreq _merge

      sort _stack `stupid'
      qui _ustack locus prob, by(_stack) val(1 2)
      drop _stack merg _merge

      drop `stupid' 

/**************************************************************************
 * Perform the regression between the quantitative trait and
 * the haplotypes. Creating the dummy variables should be done once only!'
 *
 * Create two variables y1 and y2 that are perturbed y's then get ordered
 * genotype regression but only one variance estimate
 **************************************************************************/
                   
  sort locus1 locus2 subject
  merge locus1 locus2 subject using dummy
  qui count if _merge~=3
  if `r(N)'>0 { di in red "merging with dummy has a problem" /*check the merge */
    exit 666
  }
  qui drop _merge
  tempvar lineno depvar

  tempvar tey n1 yhat
  tempvar swr sumw depvar
  
  qui reg `qt' `regmod' [pw=`f1'], nocons

/* estimates list */

  /* Calculate the standard error using the weights */

  qui predict double `yhat'
  local nop = `e(N)'-`e(df_r)'

/*******************************************************
 * Saving the yhats  when the algorithm
 * converges
 *******************************************************/

  if `saveimp'==1 {
    tempfile yhats now
    qui save "`now'"
    sort locus1 locus2
    qui by locus1 locus2: keep if _n==1
    keep locus1 locus2 `yhat'
    rename `yhat' mean
    qui save "`yhats'"
    use "`now'",clear
  }


/*
if `nop'~=`regnv'+1 {
  di as error "no of parms `nop' but should be ", (`regnv'+1)
  di as error "Reduce the complexity of the regression model"
  exit(666)
}
*/
  local regnop = `nop'

  /* WORK out the likelihood */
  
  sort subject

  /* calculate the variance estimate on the wide dataset. */

  qui gen double `swr' = sum( `f1'*(`yhat'-`qt')*(`yhat'-`qt') )
  qui gen double `sumw' = sum(`f1')

if (`sumw'[_N]-`nop')<=0 {
 di as red "more parameters than data"
 exit(2000)
}

/*******WARNING using the variance estimator without nop!!!!**************
 *  local rmse = sqrt( `swr'[_N]/(`sumw'[_N]-`nop') ) */
   
  local rmse = sqrt( `swr'[_N]/(`sumw'[_N]) )

/*summ `f1'
*di as text "`rmse' `llhd'"
*  di as error "ade2 `rmse' `e(N)' `e(df_r)'"
*noi l `swr' `sumw' */
  
  gen double proby  =  exp( -1/2*( (`qt'-`yhat')^2/((`rmse')^2) ) ) / (sqrt(2*asin(1)*2)*`rmse')

/* To do multiple regressions as a test.
 local extrareg "more"
 local i 1
 while "`extrareg'"=="more" & `i'<6 {
 qui gen double `pr' = prob1*prob2*proby
 sort subject  
 qui by subject : gen double `prs'=sum(`pr')
 qui by subject : gen double llh = log(`prs'[_N]) 
 qui by subject : replace `pr' = `pr'/`prs'[_N]
 qui replace `f1' = `pr'
 qui by subject :gen double llhh= cond(_n==_N,llh[_n],0)
 qui replace llhh = sum(llhh)
 local llh = llhh[_N]
 drop llhh
 if "`nolog'"=="" { di as text "Iteration `it' loglhd = `llh'" }
 qui reg `qt' `regmod' [pw=`f1'], nocons
 drop `yhat' `swr' `sumw' proby `pr' llh `prs' 
 qui predict double `yhat'
 local nop = `e(N)'-`e(df_r)'
 sort subject
 qui gen double `swr' = sum( `f1'*(`yhat'-`qt')*(`yhat'-`qt') )
 qui gen double `sumw' = sum(`f1')
 local rmse = sqrt( `swr'[_N]/(`sumw'[_N]-`nop') )
 gen double proby  =  exp( -1/2*( (`qt'-`yhat')^2/((`rmse')^2) ) ) / (sqrt(2*asin(1)*2)*`rmse')
 local i =`i'+1
 }
*/
  
  if `debug'>0 {
    di "The estimate of the standard deviation is `rmse'"
    gen double temp = exp( -1/2*( (`qt'-`yhat')^2/((`rmse')^2) ) )
    l temp proby prob1 locus1 locus2 `qt' `regmod' if _n<3, noobs
    drop temp
  }

/*************************************************************
 *     New Genotype probabilities (per phase and per subject)
 ************************************************************/
  
   qui gen double `pr' = prob1*prob2*proby

/*
  if "`logall'"~="" {
  if `logall'==1 {
 *    l subject `regmoda' `regmodb' `f1'
 *    l subject locus1 locus2 `qt' `yhat'
 *    l subject proby prob1 prob2 `pr'
  }
  if `logall'==1 {
 *      reg
 *      di "`rmse'"
  }
 }
*/
  
    drop prob1 prob2 `yhat'
    drop proby

/******************************************************************************
 *      Calculate log likelihood
 ******************************************************************************/
 
   cap confirm new variable llh llhh
   if _rc~= 0 { di in red "rename the variable below:"
      confirm new variable llh llhh
   }
 
      sort subject  
      qui by subject : gen double `prs'=sum(`pr')
      qui by subject : gen double llh = log(`prs'[_N]) 
      qui by subject : replace `pr' = `pr'/`prs'[_N]

      qui by subject :gen double llhh= cond(_n==_N,llh[_n],0)

      qui replace llhh = sum(llhh)
      local llh = llhh[_N]
      drop llhh

      if "`nolog'"=="" { di as res "Iteration `it' loglhd = `llh'" }

/**************************************
 * Use the new weights for the ipf
 **************************************/
  
      qui replace `f1' = `pr'

/**************************************
 *       # Convergence test
 **************************************/

   if (`it'>1) {
     local cont = (`llh' - `lastllh')>`acc' 
     if (`llh' < `lastllh') {
       local cont 1
       di as error "likelihood not increased in qhapipf"
       local problemllhd 1
     }
   }

if `saveimp'==0 {
  if `cont'==0 {
    local saveimp 1
    local cont 1
  }
}

local lastllh = `llh'

}  /*end of while loop */

/********************************************************************************
 *Display the last estimates of the regression
 ********************************************************************************/

if "`noise'"~="" { reg }

di
di as text "Regression Parameters"
di in smcl "{dup 21:{c -}}"

di as res "Residual standard deviation is " %8.4f `rmse'
di
di as text "Standard errors are calculated conditional on the weights"
di as text "  Var      Coef        SE            Parameter "
di in smcl "{c TLC}{dup 6:{c -}}{c TT}{dup 10:{c -}}{c TT}{dup 10:{c -}}{c TT}{dup 49:{c -}}{c TRC}"
local i 0
while `i'<=`regnv' {
  local lab: variable label _d`i'
  local regb = _b[_d`i']
  local regse = _se[_d`i']
  if `regb'~=0 & `regse'~=0 {
    di in smcl as text "{c |}", as res "_d`i'", as text "{col 8}{c |}",as res  %8.4f `regb', as text "{col 19}{c |}",as res %8.4f  `regse', as text "{col 30}{c |}", as res "`lab'", as text "{col 80}{c |}"
  }
  else {
    di in smcl as text "{c |}", as res "_d`i'", as text "{col 8}{c |}", as err "dropped", as text "{col 19}{c |}{col 30}{c |}{col 80}{c |}"
  }
local i = `i'+1
}
di in smcl "{c BLC}{dup 6:{c -}}{c BT}{dup 10:{c -}}{c BT}{dup 10:{c -}}{c BT}{dup 49:{c -}}{c BRC}"
di as text " ~= symbol represents dominance parameters"
di as text " &  symbol represents additive parameters."

_stack locus1 locus2 `pr' `pr'
rename locus1 locus

/********************************************************************************
 * In order to display the results I need the variables included
 * in the ipf model so that the expected frequencies are split
 * in groups of this as well
 ********************************************************************************/

     local i 1
     local vlist "$ipflist"
      while `i'<=$nloc {
         local length= length("l`i'")
         local ind = index("`vlist'","l`i'")
         if `ind'>0 { local vlist = substr("`vlist'",1,`ind'-1)+substr("`vlist'",`ind'+`length',.) }
         local i=`i'+1
      }

sort locus `vlist'
qui by locus `vlist' : gen double freq = sum(`pr')
qui _unique subject
qui gen double eprob=freq/(2*r(unique))
qui by locus `vlist' : keep if _n==_N

sort `vlist' locus

/****************************************************************
 * A routine to remove rare haplotypes but not zero haplotypes
 * and also remove the degrees of freedom
 ****************************************************************/

if `rare'~=0 {
  di "Removing rare haplotypes...."

/*
  gen rare= eprob<`rare'
  count if rare==1
  local nrare=r(N)
                      
      local i 1
      local slist ""
      qui gen str40 plocus = locus
      while `i'<=$nloc {
         qui gen len = index(plocus,".")-1
         qui gen l`i'=real(substr(plocus,1,len))
         if `i'==$nloc { qui replace l`i'=real(plocus) }
         else { qui gen len2 = index(plocus,".")+1
         qui replace plocus=substr(plocus,len2,.) }
         drop len
         cap drop len2
   local slist "`slist' l`i'"
         local i=`i'+1
      }
     drop plocus
  gen Efreqold = cond(rare==1, 0 ,.)
  sort `slist'
  save constrain,replace
*/

  gen double rare= eprob<`rare' & eprob>0
  count if rare==1
  local nrare=r(N)

  drop if rare==1

  list locus `vlist' freq eprob if rare==1, noobs


}

/**********************************
 * Display the testing expressions
 **********************************/
  
local allnop = `regnop'+`nparms'

if "`quiet'"=="" {
di ""
di as text "Quantitative-`haptext' Estimation by EM algorithm"
di in smcl "{dup 49:{c -}}"
di as res " No. loci ", _col(20) "= $nloc"
di " Log-Likelihood ", _col(20) "= `llh'"
di " Tot. parameters ", _col(20) "=" , `allnop'
/* di " Log-Likelihood under null ", _col(20) "= `llh0'"
 * di " 2*LogLikelihoodRatio  ", _col(20) "=", 2*(`llh'-`llh0')
 * di " Df ", _col(20) "=" , `df'
 */
di " No. cells      (from log-linear)", _col(20) "=" , `ncells'
di " No. parameters (from log-linear)", _col(20) "=" , `nparms'
di " No. parameters (from regression)", _col(20) "=" , `regnop'
/* di " No of rare parameters dropped ", _col(20) "=", `nrare' */
di
}

/************************************************
 * Should display the expected frequencies and
 * the imputed frequencies.
 ************************************************/

if "`display'"~="" {
   sort locus `vlist'
   di in gr "Imputed Frequencies"
   qui gen str80 `haptvar'=locus
   qui compress `haptvar'
   list `haptvar' `vlist' freq eprob, noobs
   qui drop `haptvar'
   di in gr "Expected Frequencies"
}

 qui use "`imputef'",clear
 sort locus `vlist'
 rename Efreq freq
 tempvar total
 gen double `total'=sum(freq)
 gen double eprob=freq/`total'[_N]
 sort locus `vlist'
         
if "`display'"~="" {
   qui gen str80 `haptvar'=locus
   qui compress `haptvar'
   list `haptvar' `vlist' freq eprob, noobs
   qui drop `haptvar'
   * LOOK at the total frequency
   qui gen double totf = sum(freq)
   di 
   di "TOTAL FREQ is ", totf[_N]
}

global loglik=`llh'

keep locus `vlist' freq eprob
if "`using'"~="" {

 /* Must create the l1 l2 l3...  variables from locus for the profile likelihood */

  local i 1 
  qui gen str40 plocus = locus
  while `i'<=$nloc {
      qui gen len = index(plocus,".")-1
      qui gen l`i'=real(substr(plocus,1,len))
      if `i'==$nloc { qui replace l`i'=real(plocus) }
      else { qui gen len2 = index(plocus,".")+1
      qui replace plocus=substr(plocus,len2,.) }
      drop len
      cap drop len2
      local i=`i'+1
  }
  drop plocus

  cap save "`using'", replace
}


if "`display'"~="" {
  use "`yhats'",replace
  qui compress
  list locus1 locus2 mean, noobs
}

/****************************************************************
 * Saving the model ipf string and the loglikelihood and
 * degrees of freedom
 ****************************************************************/

global hapmod`model'="L=`ipf' R=`regress' "
global hapdf`model'="`df'"
global hapnp`model'="`allnop'"
global hapllhd`model'="`llh'"

if "`lrtest'"~="" {
   tokenize "`lrtest'"
   local m1 "hapmod`1'"
   local m2 "hapmod`2'"
   local l1 "hapllhd`1'"
   local l2 "hapllhd`2'"
   local d1 "hapdf`1'"
   local d2 "hapdf`2'"
   local n1 "hapnp`1'"
   local n2 "hapnp`2'"

   /******************************************
    * Check whether these MACROS exist or not
    ******************************************/

   local error 0
   if "$`l2'" == "" {
      di in red "GLOBAL: `l2' does not exist is there a model `2'?"
      local error 1
   }
   if "$`l1'" == "" { 
      di in red "GLOBAL: `l1' does not exist is there a model `1'?"
      local error 1
    }
   if "$`m2'" == "" { 
      di in red "GLOBAL: `m2' does not exist is there a model `2'?"
      local error 1
    }
   if "$`m1'" == "" { 
      di in red "GLOBAL: `m1' does not exist is there a model `1'?" 
      local error 1
   }
   if "$`d2'" == "" { 
      di in red "GLOBAL: `d2' does not exist is there a model `2'?" 
      local error 1
   }
   if "$`d1'" == "" { 
      di in red "GLOBAL: `d1' does not exist is there a model `1'?" 
      local error 1
   }
   if "$`n2'" == "" { 
      di in red "GLOBAL: `n2' does not exist is there a model `2'?" 
      local error 1
   }
   if "$`n1'" == "" { 
      di in red "GLOBAL: `n1' does not exist is there a model `1'?" 
      local error 1
   }
   if `error'~=1 {
     di
     di as text in smcl "{dup 37:{c -}}"
     di "Likelihood Ratio Test Comparing Model "
     di "$`m2' to "
     di "$`m1'"
     di as text in smcl "{dup 37:{c -}}"
     di as res " llhd1 (np1)           =", $`l1', $`n1'
     di " llhd2 (np2)           =", $`l2', $`n2'
     di
     di "-2*(llhd2-llhd1)  =",-2*($`l2'-$`l1')
     di "Change in np      = ", $`n1'-$`n2'
     local lrt = -2*($`l2'-$`l1')
     local chnp = $`n1'-$`n2'
     local pv=chiprob(`chnp',`lrt')
     di "p-value           = ", chiprob(`chnp',`lrt')
     if `chnp'<0 {
       di as error "WARNING: negative chi-squared statistic"
       di as error "       The order of models in lrtest() is wrong"
     }                   
     else {
       if `pv'<0.05 { di as text "Do not reject Model $`m1' at 5% significance level" }
       else {  di as text "Do not reject Model $`m2' at 5% significance level" }
     }
     return scalar lrtpv = `pv'
     return scalar lrtnp = `chnp'
     return scalar lrtchi = `lrt'
   }
}

/* Might get rid of this deletion because it is system dependent */

qui !rm dummy.dta
use "`origin'",clear

if "`problemllhd'"=="1" { save problemllhd,replace  }

end

/*********************************************************
 * Tabulate for both locus the expected frequency
 * The 3rd and fourth variables contain the counting 
 * vectors
 *********************************************************/

program define tabduo
version 7.0
syntax	varlist(min=2 max=100), [BY(string)]
tokenize `varlist'

if "`by'"=="" {
	stack `1' `3' `2' `4', into(temp one) clear
	sort temp
	qui by temp: gen long freq=sum(one)
	qui by temp: keep if _n==_N
}
if "`by'"~="" {
	stack `1' `3' `by' `2' `4' `by', into(temp one `by') clear
	sort temp `by'
	qui by temp `by': gen long freq=sum(one)
	qui by temp `by': keep if _n==_N
}
end

/*********************************************************
 * Take the 2 haplotypes from each subject 
 * and do some basic tabulating saving the resulting 
 * tabulate in merge and merge2, these two represent 
 * the different sorted variables
 **********************************************************/

program define tabhap
version 7.0
syntax varlist(min=2 max=100)
tokenize `varlist'

cap confirm new file merge.dta
if _rc~=0 { di in red "merge.dta will be deleted within the program" }
cap confirm new file merge2.dta
if _rc~=0 { di in red "merge2.dta will be deleted within the program" }

stack `1' `2', into(haplo) clear
qui egen hapgrp = group(haplo)
sort haplo
qui by haplo: keep if _n==_N
keep haplo hapgrp
cap save merge,replace
sort hapgrp
cap save merge2,replace
end

/*************************************************************************
 * Calculate all the 2*($nloc-1) possible haplotypes 
 * given the 
 * observed data for each phase and person.
 * have locus1 and locus2 contain the string versions of the haplotypes
 * and the global unknown having the number of subjects with phase unknown
 **************************************************************************
 * 8/11/99 - The strings are out and separate variables are in
 **************************************************************************/

program define haplotyp
version 7.0
syntax [varlist] [,NOISE KNOWN PHASE(string) MV]
tokenize `varlist'

        
cap confirm new variable locus1 locus2 subject
if _rc~=0 {
  di in red "You must rename the following variable"
  confirm new variable locus1 locus2 subject
}
tempvar subj expand

/* Note that subj contains the subject id numbers and is renamed subject */

qui gen long subject = _n
qui gen long `subj' = _n

if "`mv'"~="" {
  di as text "EXPANDING MISSING DATA....."

  local li 1
  while `li'<=$nloc {
    local wc1=2*`li'-1
    local wc2=`wc1'+1
    local root1: word `wc1' of $all_name
    local root2: word `wc2' of $all_name

    qui count if `root1'==.
    local c1 = `r(N)'
    qui count if `root2'==.
    local cnt = `c1'+`r(N)'

    if `cnt'>0 {
      di as res "There are `cnt' missing values at locus `li'"
      qui tab `root1' , matrow(row)
      qui tab `root2' , matrow(col)
      
      /* NEED to make one matrix with all the values at locus i called unique */

      mat values = row \ col  
      local j 1
      while `j'<=rowsof(values) {
        if `j'==1 {
          mat unique = values[1,1] 
          local j =`j'+1
        }
        local not 0
        local jj 1
        while `jj'<`j' {
          if values[`j',1]==values[`jj',1] {
            local not 1
            local jj=`j'
          }
          local jj=`jj'+1
        }
        if `not'==0 { mat unique = unique \ values[`j',1] }

       local j = `j'+1
      }

    /* The matrix unique now contains just one copy of the alleles */

      /* Replace missing with one from each of unique
       * FOR TWO loci this would be the number of unique*(unique+1)/2
       */
            
      tempvar temp
      sort subject
      gen long `temp'=_n
      local missex = rowsof(unique)
      local missex = `missex'*(`missex'+1)/2
      qui expand  `missex' if `root1'==. | `root2'==.
      sort `temp'

      /* Create the new phenotypes */

      local lineno 1
      local i 1
      while `i'<=rowsof(unique) {
         local j = `i'
         while `j'<=rowsof(unique) {

           qui by `temp': replace `root1' = cond(`root1'==. & _n==`lineno', unique[`i',1],`root1')
           qui by `temp': replace `root2' = cond(`root2'==. & _n==`lineno', unique[`j',1],`root2')
           local lineno = `lineno'+1

         local j = `j'+1
         }
      local i =`i'+1
      }

 
    } /* end of if dealing with missing */

    local li =`li'+1  /*loop of loci */
  }

}
  di
    
if "`known'"~="" & "`phase'"=="" {
	qui gen str40 locus1=""
	qui gen str40 locus2=""
	/*******************************************
	 * Construct locus strings from alleles
	 *******************************************/
	sort subject
	global unknown = 0
	local i 1
	while `i'<=$nloc {
		local wc1=2*`i'-1
		local wc2=`wc1'+1
		local root1: word `wc1' of $all_name
		local root2: word `wc2' of $all_name

		if `i'==1 {
			qui replace locus1 =string(`root1')
			qui replace locus2 =string(`root2')
		}
		else {
			qui replace locus1 = locus1+"."+string(`root1')
			qui replace locus2 = locus2+"."+string(`root2')
		}


	local i=`i'+1
	}
}
if "`known'"=="" & "`phase'"=="" {

	local root1: word 1 of $all_name
	local root2: word 2 of $all_name
	qui gen str40 locus1=string(`root1')
	qui gen str40 locus2=string(`root2')
	qui gen `expand'=.

	/*******************************************
 	 * Construct locus strings from alleles and 
	 * also expand to all possibilities
	 *******************************************/

        if "`mv'"~="" { local i 1}
        if "`mv'"=="" { local i 2}
        
	while `i'<=$nloc {
		sort `subj'
		local wc1=2*`i'-1
		local wc2=`wc1'+1
		local root1: word `wc1' of $all_name
		local root2: word `wc2' of $all_name
		
                qui replace `expand'= 2*(`root1'~=`root2')

		qui replace subject=_n
		qui expand `expand'
		sort subject

		if `i'>1 {
                  qui by subject: replace locus1= locus1+"."+string(cond(_n==2,`root2',`root1'))
		  qui by subject: replace locus2= locus2+"."+string(cond(_n==2,`root1',`root2'))
                }
                if `i'==1 {
                  qui by subject: replace locus1= string(cond(_n==2,`root2',`root1'))
		  qui by subject: replace locus2= string(cond(_n==2,`root1',`root2'))
                }
		
	local i=`i'+1
	}
	qui drop subject `expand'
	qui rename `subj' subject
}

if "`phase'"~="" {
	local root1: word 1 of $all_name
	local root2: word 2 of $all_name
	qui gen str40 locus1=string(`root1')
	qui gen str40 locus2=string(`root2')
	qui gen `expand'=.
	cap confirm variable `phase'
	if _rc~=0 {
		di in red "variable `phase' does not exist!"
		exit 111
	}

	/*******************************************
	 * Construct locus strings from alleles and 
	 * also expand to all possibilities
	 *******************************************/

        if "`mv'"~="" { local i 1}
        if "`mv'"=="" { local i 2}

	while `i'<=$nloc {
		sort `subj'
		local wc1=2*`i'-1
		local wc2=`wc1'+1
		local root1: word `wc1' of $all_name
		local root2: word `wc2' of $all_name


	        qui replace `expand'= cond(`phase'==0,2*(`root1'~=`root2'),1)

		qui replace subject=_n
		qui expand `expand'
		sort subject

                if `i'>1 {
                  qui by subject: replace locus1= locus1+"."+string(cond(_n==2,`root2',`root1'))
		  qui by subject: replace locus2= locus2+"."+string(cond(_n==2,`root1',`root2'))
                }
                if `i'==1 {
                  qui by subject: replace locus1= string(cond(_n==2,`root2',`root1'))
		  qui by subject: replace locus2= string(cond(_n==2,`root1',`root2'))
                }
		
	local i=`i'+1
	}
	qui drop subject `expand'
	qui rename `subj' subject

}
qui compress

end

/****************************************************************
 * My program to stack variables
 * Go thro' varlist  if `1'~=`2' then rename `2'
 * `1' and then drop `1' at the end append in the original file
 ****************************************************************/

program define _stack
version 7.0
syntax varlist(min=1) [using/] [if],[NOISE START KNOWN PHASE(string) BY(string) ACC(real 0.001) DEBUG]
tokenize `varlist'

gen _stack=1
tempfile stack 
qui save "`stack'"

local i 1
while "``i''"~="" {
	local p=`i'
	local i = `i'+1
	if "``p''"~="``i''" {
		drop ``p'' 
		rename ``i'' ``p''
	}
	local i=`i'+1
}

qui replace _stack=2

append using "`stack'"

end

/********************************************** 
 * BETTER explanation needed....
 * MY unstack
 * First the variables and the values are given to the function e.g. locus and "1 2"
 **********************************************/

program define _ustack
version 7.0
syntax varlist(min=1) [using/] [if], BY(string) VALues(string) [NOISE START KNOWN PHASE(string) ]
tokenize `varlist'

tokenize "`values'", parse(" ")
tempfile first merge

qui by `by': gen long merg=_n
save "`first'"

keep if `by'==`1'
tokenize "`varlist'"
keep `varlist' merg
while "`1'"~="" {
	rename `1' `1'1
mac shift 1
}
sort merg
save "`merge'"

use "`first'"
tokenize `values', parse(" ")
keep if `by'==`2'
tokenize `varlist'
while "`1'"~="" {
	rename `1' `1'2
mac shift 1
}

sort merg
merge merg using `merge'

end

/*******************************************
 * This programs unique function
 *******************************************/

program define _unique, rclass
   version 7.0
   syntax varlist(min=1 max=1)
   tokenize "`varlist'"
   local var `1'

preserve
sort `var'
qui by `var': keep if _n==1
return scalar N=_N
global S_1 =_N
qui drop if `var'==.
global S_2 =_N
return scalar unique=_N

restore

end

/***********************************************************************
 * This function creates the dummy variables.
 * Note that a haplotype of interest is required! because this model
 * assumes that you have binary markers 
 *
 ************************************************************************/

program define _mkdummy, rclass
version 7.0
syntax [varlist]  [, HAPint(string) Reg(string) Dom(string) FILE(string) ]

di "`file'"

/********************************************
 * Find out the reference haplotype
 ********************************************/

sort locus1 locus2
if "`hapint'"=="none" {
  di as text "Creating dummy variables"
  di in smcl as text "{dup 24:{c -}}"
  di as error  _continue "The haplotype of interest is NOT specified "
  local hapint = locus1[_N]
  di as res ": It will be `hapint'"
}
else {
  di as text "Creating dummy variables"
  di in smcl as text "{dup 24:{c -}}"
  di as res "The reference haplotype is `hapint' "
}

/*******************************************************
 * create l1a l1b l2a l2b .....
 * lia is the allele at locus 1 for marker i
 * lib is the allele at locus 2 for marker i
 *******************************************************/

   tempvar plocus1 plocus2
   local i 1
   local vlist " "
   qui gen str40 `plocus1' = locus1
   qui gen str40 `plocus2' = locus2
   while `i'<=$nloc {
      tempvar len len2
      qui gen `len' = index(`plocus1',".")-1
      qui gen l`i'a=real(substr(`plocus1',1,`len'))
      if `i'==$nloc { qui replace l`i'a=real(`plocus1') }
      else { qui gen `len2' = index(`plocus1',".")+1
      qui replace `plocus1'=substr(`plocus1',`len2',.) }
      drop `len'
      cap drop `len2'
      qui gen `len' = index(`plocus2',".")-1
      qui gen l`i'b=real(substr(`plocus2',1,`len'))
      if `i'==$nloc { qui replace l`i'b=real(`plocus2') }
      else { qui gen `len2' = index(`plocus2',".")+1
      qui replace `plocus2'=substr(`plocus2',`len2',.) }
      drop `len'
      cap drop `len2'

      local vlist "`vlist' l`i'b"
      local i=`i'+1
   }

   drop `plocus1' `plocus2'

/*********************************************************
 * Split up the hapint string into alleles at
 * each location
 * macros l1 l2 l3 ... contain the allele of interest at
 * that locus
 *********************************************************/

  local i 1
  while `i'<=$nloc {
      local len = index("`hapint'",".")-1

      if `len'==-1 & `i'~=$nloc {
        di in red "HAPINT TOO short are you missing a locus??"
        exit(198)
      }

      local l`i'=real(substr("`hapint'",1,`len'))
      if `i'==$nloc {  local l`i'=real("`hapint'") }
      else { local  len2 = index("`hapint'",".")+1
      local hapint=substr("`hapint'",`len2',.) }
      local i=`i'+1
   }
   if index("`hapint'",".")~=0 { di in red "HAPINT is too long!!" }


/***********************************************
 * Process the regression string
 * 1) Set up the dummy variable for constant
 * 2) then for the other possible models
 ***********************************************/

if "`reg'"=="1" {
  local reg ""
}

/* Process the []*[]*[] parts... Haplotype effects could be additive or dominant */

local brac "1"
local list 1
while "`reg'"~="" {  /* Start going through the reg string */


/**********************************************************
 *  Parse  [l1+l1]*[l2+l2] into   l1+l1  l2+l2  ---> brac   
 *                                     *        ---> start
 **********************************************************/
                                               
  gettoken brac reg:reg, parse("]")
  if index("`brac'","[")~=0 {
    local start = substr("`brac'",1,index("`brac'","[")-1)
    local brac = substr("`brac'",index("`brac'","[")+1,.)
  }

/* 
 * Check that with the brac macro you have the same l1 terms either side 
 * of the other symbol 
 */

   if index("`brac'","l")~=0 {
     tokenize "`brac'", parse ("+*x")
     if index("`1' `3'","a")==0 & ("`1'"~="`3'") {
       di
       di as error "WARNING: within the reg() option this locus submodel [`brac'] is wrong"
       di as error "        `1' must equal to `3' unless parental imprinting is used"
       di as error "                                        e.g.  l1a+l1b" 
       use "`file'", replace
       exit(198)
     }
   }


 /****************************************************************
  * Create the within loci effects and put them into list* macros
  * l1+l1   -->  l1a&l1b
  * l1*l1   -->  l1a&l1b l1a~=l1b
  * l1a+l1b -->  l1a l1b
  * l1a*l1b -->  l1a l1b l1a~=l1b 
 *****************************************************************/
  
  if "`brac'"~="]" {
    tokenize "`brac'", parse ("+*x")
    local list`list' ""
    if "`2'"=="+" {
      if "`1'"=="`3'" { local list`list' "`1'a&`3'b" }
      else { local list`list' "`1' `3'" }
    }
    else {
      if "`1'"=="`3'" { local list`list' "`1'a&`3'b `1'a~=`3'b" }
      else { local list`list' "`1' `3' `1'~=`3'" }
    }
  }

/******************************************************************
 * Create the terms to pass to the haplotype effects
 * "*" means just put a "." operator between all new and old terms
 ******************************************************************/

  if "`start'"=="*" {
    local temp ""
    foreach term of local list`list' {
      foreach term2 of local submod {
        local temp "`temp' `term'.`term2'"
      }
    }
  }
/***********************************************************************
 * To create only between loci additive effects must use the "x" symbol
 ***********************************************************************/

  if "`start'"=="x" {
    local temp ""
    foreach term of local list`list' {
      foreach term2 of local submod {
        local temp "`temp' `term'x`term2'"
      }
    }
  }
/* end of new code */

  local submod "`submod' `list`list'' `temp'"

  local list = `list'+1
}


/*********************************************
 * Have now finished processing the reg string
 * Proceed to now process the submod macro
 *********************************************/

/* Now I have to deal with the & symbol basically swap the .s and the &s by a cross multiplication
MODEL                SUBMOD
[l1*l1]+[l2+l2] l1a&l1b l1a~=l1b l2a&l2b l2a~=l2b   
[l1+l1]+[l2+l2] l1a&l1b          l2a&l2b
[l1+l1]*[l2+l2] l1a&l1b          l2a&l2b          l2a&l2b.l1a&l1b  
[l1*l1]*[l2+l2] l1a&l1b l1a~=l1b l2a&l2b          l2a&l2b.l1a&l1b l2a&l2b.l1a~=l1b  
[l1*l1]*[l2*l2] l1a&l1b l1a~=l1b l2a&l2b l2a~=l2b l2a&l2b.l1a&l1b l2a&l2b.l1a~=l1b l2a~=l2b.l1a&l1b l2a~=l2b.l1a~=l1b 
[l1+l1]x[l2+l2] l1a&l1b          l2a&l2b          l2a&l2bxl1a&l1b  
[l1a+l1b]*[l2a+l2b] l1a l1b    l2a l2b  l2a.l1a l2a.l1b l2b.l1a l2b.l1b
*/


local tesubmod ""
foreach term of local submod {
  local te ""

  /* Select those terms with any between loci interaction with within loci additive terms  */
    
  if index("`term'","&")~=0 {
    gettoken first term:term, parse(".x")

    local parms1 ""
    local parms2 ""
    local specialcase 0  /* for when the term starts with a dominance term */
    local addhap 0

    /* if the term in submod does not contain a . then the function should end now!! */

    while "`first'"~="" {


     if "`first'"=="x" { local addhap 1 } 

     if "`first'"=="." || "`first'"=="x"  { gettoken first term:term, parse(".x") }

      /* Take the first term and split it by the & symbol l1a&l1b   l1a --> one  l1b --> two */

      gettoken one first:first, parse("&")
      gettoken two first:first, parse("&")
      gettoken two first:first, parse("&")


      if "`parms1'"=="" & "`two'"=="" {
        local specialcase 1
      }

        local te ""
        if "`parms1'"=="" {
          local parms1 "`one'"
        }
        else {
          foreach var of local parms1 {
            if `addhap'==0 {
              if "`two'"~="" & `specialcase'==0 & `addhap'==0 { local te "`te' `var'.`one' `var'.`two'" }
              if "`two'"~="" & `specialcase'==1 & `addhap'==0 { local te "`te' `var'.`one'" }
              if "`two'"=="" { local te "`te' `var'.`one'" }
            }
            if `addhap'==1 {
              local te "`te' `var'.`one'" 
            }
          }
        }
        if "`te'"~="" { local parms1 "`te'" }


        local te ""
        if "`parms2'"=="" {
          if "`two'"~="" { local parms2 "`two'" }
          else { local parms2 "`one'" }
        }
        else {
          foreach var of local parms2 {
            if `addhap'==0 {
              if "`two'"~="" & `specialcase'==0 { local te "`te' `var'.`two' `var'.`one'" }
              if "`two'"~="" & `specialcase'==1 {
                local te "`te' `var'.`two'"
                local specialcase 0
              }
              if "`two'"=="" { local te "`te' `var'.`one'" }
            }
            if `addhap'==1 {
               if "`two'"~=""  { local te "`te' `var'.`two' " }
               if "`two'"=="" { local te "`te' `var'.`one'" }
            }
          }
            
        }
        if "`te'"~="" { local parms2 "`te'" }


      gettoken first term:term, parse(".x")

    }
    local te ""
    local t1 1
    foreach t of local parms1 {
      local t2 1
      foreach u of local parms2 {
        if `t1'==`t2' { local te "`te' `t'&`u'" }
        local t2 =`t2'+1
      }
      local t1=`t1'+1
    }
  }
  else { local  tesubmod "`tesubmod' `term'" }
  local tesubmod "`tesubmod' `te'"
}

local submod "`tesubmod'"

/****************************************************************
 *  submod will contain all the model terms  e.g. 
 *   model            submod
 *   [l1a+l1b]       l1a l1b 
 *   [l1a*l1b]       l1a  l1b  l1a~=l1b 
 *   [l1+l1]         l1a&l1b
 *   [l1*l1]         l1a&l1b l1a~=l1b 
 ****************************************************************/

gen _d0 = 1
lab var _d0 "Constant"
local model "_d0"

local ndum 1
foreach term of local submod {
  gen _d`ndum' = 1
  lab var _d`ndum' "`term'"
  local model "`model' _d`ndum'"

 if "`term'"=="l2a.l1a&l2b.l1b" { local yep 1}
  else { local yep 0}
  
  gettoken left term:term, parse("&")
  gettoken temp term:term, parse("&")
  gettoken right term:term, parse("&")

/* Possible problem with thislocus */
  
  tempvar temp1 temp2
  gen `temp1'=1
  tokenize "`left'", parse(".")
  while "`1'"~="" {
    while "`1'"=="." { mac shift 1 }
    if index("`1'","~=")==0 {
      local thislocus = substr("`1'",index("`1'","l")+1,.)
      local len = length("`thislocus'")
      local thislocus = substr("`thislocus'",1,`len'-1)
      qui replace `temp1' = `temp1'*(`1'==`l`thislocus'')
    }
    else {  qui replace `temp1' = `temp1'*(`1') }
    mac shift 1
  }
  qui replace _d`ndum' = `temp1'
  if "`right'"~="" {
    gen `temp2'=1
    tokenize "`right'", parse(".")
    while "`1'"~="" {
      while "`1'"=="." { mac shift 1 }
        if index("`1'","~=")==0 {
           local thislocus = substr("`1'",index("`1'","l")+1,.)
           local len = length("`thislocus'")
           local thislocus = substr("`thislocus'",1,`len'-1)
           qui replace `temp2' = `temp2'*(`1'==`l`thislocus'')
        }
        else { qui replace `temp2' = `temp2'*(`1') }
      mac shift 1
    }
    qui replace _d`ndum' = _d`ndum'+`temp2'
  }


  local ndum = `ndum'+1
}

/* COULD drop subject at the moment
 * _tidy
 */

sort locus1 locus2 subject
keep locus1 locus2 subject _d*
qui compress
qui save dummy,replace

return local model  "`model'"
return local modela  "`modela'"
return local modelb  "`modelb'"
return local nvars = `ndum'-1      
end

/********************************
 * Take the number in `1' 
 * get binary numbers
 ********************************/

program define _bin, rclass
version 7.0
local num `1'
local i = `2'-1
while `i'>=1 {
  local fact = 2^`i'
  if  mod(`num',`fact')~= `num' {
    local ii = `i'+1
    local locs "`locs' `ii'"
    return scalar t`ii' = `ii'
    local num = `num' - `fact'
  }
  local i = `i'-1
}
if `num'==1 {   return scalar t1 = 1 }
if `num'==1 { local locs "`locs' 1" }
return local locs "`locs'"

end

/********************************
 * Take the number in `1' 
 * get binary numbers
 ********************************/

program define _bin2, rclass
version 7.0
local num `1'
local i = `2'-1
while `i'>=1 {
  local fact = 2^`i'
  if  mod(`num',`fact')~= `num' {
    local ii = `i'+1
    local locs "`locs' 1"
    local num = `num' - `fact'
  }
  else { local locs "`locs' 0" }
  local i = `i'-1
}
if `num'==1 { local locs "`locs' 1" }
else { local locs "`locs' 0" }
return local locs "`locs'"

end

/*************************
 * drop _d*a
 *************************/

program define _tidy
version 7.0
syntax [varlist]

tokenize "`varlist'"
while "`1'"~="" {
  if substr("`1'",1,2)=="_d" & substr("`1'",-1,1)=="a" {
   drop `1'
  }
  if substr("`1'",1,2)=="_d" & substr("`1'",-1,1)=="b" {
   drop `1'
  }  
  mac shift 1
}

end

/*****************************************************
 *
 *
 *****************************************************/

prog def _mkdum2, rclass
version 7.0
syntax [varlist]  [, ADD(string)]

keep locus1 locus2 subject
/*******************************************************
 * create l1a l1b l2a l2b .....
 * lia is the allele at locus 1 for marker i
 * lib is the allele at locus 2 for marker i
 *******************************************************/

 tempvar plocus1 plocus2
 local i 1
 local vlist1 ""     /* VLIST1 and VLIST2 and INLIST used later  */
 local vlist2 ""
 local inlist ""

 qui gen str40 `plocus1' = locus1
 qui gen str40 `plocus2' = locus2
 while `i'<=$nloc {
   tempvar len len2
   qui gen `len' = index(`plocus1',".")-1
   qui gen l`i'a=real(substr(`plocus1',1,`len'))
   if `i'==$nloc { qui replace l`i'a=real(`plocus1') }
   else { qui gen `len2' = index(`plocus1',".")+1
   qui replace `plocus1'=substr(`plocus1',`len2',.) }
   drop `len'
   cap drop `len2'
   qui gen `len' = index(`plocus2',".")-1
   qui gen l`i'b=real(substr(`plocus2',1,`len'))
   if `i'==$nloc { qui replace l`i'b=real(`plocus2') }
   else { qui gen `len2' = index(`plocus2',".")+1
   qui replace `plocus2'=substr(`plocus2',`len2',.) }
   drop `len'
   cap drop `len2'

   local vlist1 "`vlist1' l`i'a"
   local vlist2 "`vlist2' l`i'b"
   local inlist "`inlist' l`i'"

   local i=`i'+1
 }
 drop `plocus1' `plocus2'

/********************************************************
 * Get a matrix that contains the alleles for each locus
 ********************************************************/

 preserve
 stack `vlist1' `vlist2', into(`inlist') clear
 local i 1
 while `i'<=$nloc {
   qui tab l`i', matrow(tem`i')
   if rowsof(tem`i')>1 { mat m`i' = tem`i'[2...,1...] }
   else { mat m`i' = tem`i' }
   local i = `i'+1
 }
 restore

/********************************************************
 * Create additive variables per locus
 ********************************************************/

 local i 1
 while `i'<=$nloc {
   local j 1
   while `j'<= rowsof(m`i') {
     local allele = m`i'[`j',1]
     qui gen _dd`i'a`allele'= (l`i'a==`allele')+(l`i'b==`allele')
     lab var _dd`i'a`allele' "l`i'(`allele')"
     
     local j =`j'+1
   }
   local i =`i'+1
 }
   
/*********************************************************
 * Figure out what additive terms are included
 *********************************************************/

gen _d0 = 1
local  model "_d0"
label variable _d0 "1"

if "`add'"=="1" {
  local add ""
}

local di 1
while "`add'"~="" {
  gettoken marg add: add, parse("+")  /* For each marginal model */
  while "`marg'"=="+" {
    gettoken marg add: add, parse("+")
  }
  mat mmod = (0)
  tokenize "`marg'", parse("*")
  local terms 0
  while "`1'"~="" {
    local terms = `terms'+1
    mat thisloc = real(substr("`1'",2,1) )
    mat mmod = mmod \ thisloc
    mac shift 2
  }
  mat mmod = mmod[2...,1]

/* This bit does the combinations using matrices as the dataset could not be
   expanded being too big */
   
  local i 1
  while `i'<2^`terms' {
      _bin `i' `terms'

      cap mat drop comb
      local wi 1
      local wloc: word `wi' of `r(locs)'
      while "`wloc'"~="" {
        local thisloc= mmod[`wloc',1]
        cap qui mat list comb
        if _rc~=0 { mat comb = m`thisloc' }
        else {
          mat newcomb = comb
          local cdim = rowsof(comb)
          local ai 1
          while `ai'<=rowsof(m`thisloc') {
            local all = m`thisloc'[`ai',1]
            mat temp = J(`cdim',1,`all')
            if `ai'==1 { mat comb=newcomb,temp }
            else { mat comb = comb \ (newcomb , temp) }
            local ai=`ai'+1
            mat drop temp
          }
          mat drop newcomb
        }
        local wi=`wi'+1
        local wloc: word `wi' of `r(locs)'
      }

/* now matrix comb has the combinations */

      local j 1
      while `j'<= rowsof(comb) {
        gen _d`di'=1
        local k 1
        while `k'<=colsof(comb) {
          local wloc: word `k' of `r(locs)'
          local thisloc = mmod[`wloc',1]
          local all = comb[`j',`k']
          qui replace _d`di'=_d`di'*_dd`thisloc'a`all'
          local lab: variable label _dd`thisloc'a`all'
          local lab2: variable label _d`di'
          if "`lab2'"=="" { label variable _d`di' "`lab'"}
          else { label variable _d`di' "`lab2'*`lab'"  } 
          local k =`k'+1
        }
      local model "`model' _d`di'"
      local di = `di'+1
      local j=`j'+1
      }

      local i =`i'+1
  }


} /* END of while add loop */


qui drop _dd*
sort locus1 locus2 subject
keep locus1 locus2 subject _d*
qui compress
qui save dummy,replace

return local model  "_d*"
return local nvars = `di'-1      
end

/******************************************
 * BUILDING the menu system for easy use
 ******************************************/

prog def _qmenu
version 7.0
syntax [varlist]

win c clear
local statnloc 10

/* Window width and height textheight */

local winw 240
local winh 280
local texth 7
local leftmargin 5
local rightmargin =`winw'-5

/* Initialising globals */

local i 1
while `i'<= `statnloc' {
  global statloc`i' ""
  local i = `i'+1
}
global Qadd ""
global Qipf ""
global Qvar ""
global Qtvar ""
global infoqt ""
global infoqt1 ""
global Qcommand ""

/*Varlist options */
  
global Qsel "Select variables for:"
global Qmany "Loci"
global Qqt "Quantitative Trait"
global Qvarlist "`varlist'"
window control static Qsel 5 10 110 `texth' center
window control static Qqt 60 20 50 `texth' center
window control ssimple Qvarlist 60 30 50 100 Qtvar
window control static Qmany 5 20 50 10 center
window control msimple Qvarlist 5 30 50 100 Qvar

/* BUTTONS */

local tey = `winh'-11-15
global Qvchk1 "qhapupdate 0"
global Qvchk2 "qhapupdate 1"
window control button "Apply" 5 `tey' 30 11 Qvchk1
window control button "Add to Review" 40 `tey' 55 11 Qvchk2

/* Get rid of window */

global Qrun "exit 3000"
global Qexit "exit 3001"
window control button "Run command" 100 `tey' 55 11 Qrun
window control button "Exit" 160 `tey' 30 11 Qexit


/* INFORMATION
 * Display info qdix and qdiy control the top left corner */

local qdix=`winw'-95
local qdiy 30
local qdisx = `qdix'+35
local qdiw = `winw'-5-`qdix'

global Qdi "Information"
window control static Qdi `qdix' 30 `qdiw' 100 blackframe
window control static Qdi `qdisx' 27 30 7 center

/* Put in pairs of vars */
tokenize $Qvar
local i 1
while `i' <= `statnloc' {
  local tey = `qdiy'+10
  local tex = `qdix'+10
  local tew = `qdiw'-20
  local staty = `tey' + 7*(`i'-1)
  win c static statloc`i' `tex' `staty' `tew' `texth' left
  local i = `i'+1
}
local tey=`staty'+10
win c static infoqt1 `tex' `tey' `tew' `texth'
local tey=`tey'+`texth'
win c static infoqt `tex' `tey' `tew' `texth'

/* Display the saturated model for the haplotypes */

global Qllm "Haplotype Model"
local tey=`winh'-11-15-85
local teyy = `tey'-3
local tey2 = `tey'+9
local tew = `rightmargin'-`leftmargin'
local tew2= `tew'-20
local tex = `leftmargin'+10
local temid = int((`rightmargin'-`leftmargin')/2)-30
window control static Qllm `leftmargin' `tey' `tew' 20 blackframe
window control static Qllm `temid' `teyy' 60 7 center
window control static Qipf `tex' `tey2' `tew2' `texth' center

/* Display a check box to say whether you want to specify an haplotype */

global Qhi_rad 1
global Qhapint "<specify haplotype>"
local tex= `leftmargin'+1
local tey= `winh'-11-15-107
local tew  70
win c radbegin "Haplotype of interest" `tex' `tey' `tew' `texth' Qhi_rad
local tey2 = int(`tey'+`texth'/2)
local tex2 = `tex'+`tew'+1
local texth2 = `texth'+3
win c edit `tex2' `tey2' 60 `texth2' Qhapint
local tey = `tey'+10
*win c radend "All haplotypes" `tex' `tey' `tew' `texth' Qhi_rad

/* Display three models with check box and ipf() syntax box */

global Qqm "Common Quantitative Models"
global Qrad 1
global Qmod1 ""
global Qmod2 ""
global Qmod3 ""
global Qmod4 ""
global Qmod5 ""

local tey=`winh'-11-15-60
local teyy = `tey'-3
local tew = `rightmargin'-`leftmargin'
local temid = int((`rightmargin'-`leftmargin')/2)-30
local tew2= `tew'-20
local tex = `leftmargin'+5
local tey2 = `tey'+9
window control static Qqm `leftmargin' `tey' `tew' 55 blackframe
window control static Qqm `temid' `teyy' 84 `texth' center
local tey3 = `tey'+7
local tex2 = `tex'+80
win c radbegin "Constant Model" `tex' `tey3' 75 `texth' Qrad
win c static Qmod1  `tex2' `tey3' 90 `texth'
local tey3 = `tey3'+9
win c radio "SAM" `tex' `tey3' 90 8 Qrad
win c static Qmod2  `tex2' `tey3' 90 `texth'
local tey3 = `tey3'+9
win c radio "MAM" `tex' `tey3' 90 `texth' Qrad
win c static Qmod3  `tex2' `tey3' 90 `texth'
local tey3 = `tey3'+9
win c radio "No parental imprinting"  `tex' `tey3' 90 `texth' Qrad
win c static Qmod4  `tex2' `tey3' 90 `texth'
local tey3 = `tey3'+9
win c radend "Saturated"  `tex' `tey3' 90 `texth' Qrad
win c static Qmod5  `tex2' `tey3' 90 `texth'

/* Display the syntax */

global Qdis ""
local tey=`winh'-1-`texth'
local tex=`leftmargin'+31
window control static Qdis `leftmargin' `tey' 30 `texth' left
window control static Qcommand `tex' `tey' 200 `texth' left

/* ENd of windowing */

window dialog "A window to help with the syntax" . . `winw' `winh'

end
