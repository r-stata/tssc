*! Date    : 15 May 2006
*! Version : 1.48
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-hnr.cam.ac.uk

/* Bug fix log 

15/5/06 version 1.48 put quietly in front of merge because of stupid message about merge variables not defining master dataset!
2/3/01 bug fix in haplo expansion for haplotypes
 *********************************************************************
 * 8/11/99 Now I want to implement some log-linear modelling within the
 * hapfreq3.ado algorithm. Basically the expansion of the dataset
 * is still carried out but instead of a simple calculating
 * algorithm I shall use the log-linear approach hence any model
 * can be specified
 *************************************************************************************
 * 15/11/99 About to add the LDIM as the varlist to calculate the likelihood over.
 * This is important otherwise the algorithm will use the minimal continguency
 * table and when comparing tables you need the same dimension tables. The varlist
 * defines the table. Not sure about the missing data and cells :(
 *************************************************************************************/

program define hapipf, rclass
version 7.0
syntax [varlist] [using/] [if] ,[ LDIM(varlist) IPF(string) START DISplay EXPect KNOWN PHASE(varname) ACC(real 0.00001) IPFACC(real 0.000001) DEBUG(integer 0) NOLOG MODEL(integer 0) LRTEST(numlist) RARE(real 0) CONVARS(string) CONFILE(string) QUIET NOISE MV MVDEL MENU CONDF(integer -1) CC(varname) CONMOD(string) NOPRINT SAVEW(string) USEW(string)]

/*Check on the missing option */

if "`mv'"~="" & "`mvdel'"~="" {
  di as error "The mv and mvdel options can not be specified at the same time"
  exit(198)
}

if _N==0 {
  di as error "No observations"
  exit(2000)
}

/* Do some checks on using the rare option */
  
if "`rare'"~="0" {
  di as txt "WARNING: The rare option is specified MAKE sure the model in the ipf() option just involves loci terms"
  if "`cc'"=="" {
    di as error "The dependent variable must be specified by the cc() option"
    exit
  }
  
  /* check that the saturated model is selected */
  tokenize `ipf', parse(" *")
  while "`1'"~="" {
    while "`1'"=="*" { mac shift 1 }
    if index("`1'","+")~=0 {
      di as error "You have not specified the saturated model in ipf()"
      di as error "`1'"
      exit
    }
    if index("`1'","l")==0 {
      di as error "This variable `1' is not of the form l#"
      di as error "Only locus variables are allowed when using the rare() option"
      exit
    }
    mac shift 1
  }    
}

if "`condf'"~="-1" & "`confile'"=="" & "`rare'"=="0" {
  di as error "ONLY specify degrees of freedom  when using a constraint file"
  exit
}

if "`menu'"~="" {
  cap _qmenu
  if _rc==3000 {
    di in red "Command will not be run"
    exit
  }
  if _rc==3001 {
    di in blue "Running $Qcommand..."
    $Qcommand
    exit
  }
}
                                                                 
tokenize `varlist'

cap which ipf
if _rc~=0 {
  di in red "YOU MUST INSTALL ipf.ado which was first introduced in STB55"
  di "This function performs the log-linear modelling"
  exit(198)
}

tempfile origin
qui save "`origin'",replace

if "`if'"~="" { keep `if'}

return local N = _N

global all_name  "`varlist'"
global nloc 0
global nsub= _N
                                                                
/***************************************************
 * Delete all lines with missing marker information
 * for each marker in the varlist
 ***************************************************/
                                                              
  if "`mv'"~="" & "`known'"~="" { 
    di as error "If you want to impute missing data then phase is not known for those people with missing typings" 
  }

  local cum_nmiss 0
  if "`mvdel'"~="" {
    local len = length("You have selected the deletion of missing lines")
    if "`quiet'"=="" {
      di
      di as text "You have selected the deletion of missing lines"
      di in smcl "{dup `len':{c -}}"
    
      di in smcl as result "(#lines deleted) {ul:Variable} variable label "
      di
    }
    while "`1'"~="" {
      qui count if `1'==.
      local cum_nmiss = `cum_nmiss'+`r(N)'
      local lab : variable label `1'
      if "`lab'"~="" { 
        if "`quiet'"=="" { di  in smcl _continue "(" %4.0f `r(N)' ") {ul:`1'} {col 15}`lab'"  } 
      }
      else { 
        if "`quiet'"=="" { di in smcl  _continue "(" %4.0f `r(N)' ") {ul:`1'}" }
      }
      qui drop if `1'==.
      mac shift 1
      qui count if `1'==.
      local cum_nmiss = `cum_nmiss'+`r(N)'
      local lab : variable label `1'
      if "`lab'"~="" { 
        if "`quiet'"=="" { di in smcl  _col(29) "(" %4.0f `r(N)' ") {ul:`1'} {col 44}`lab'" } 
      }
      else { 
         if "`quiet'"=="" { di in smcl  _col(29) "(" %4.0f `r(N)' ") {ul:`1'}" }
      }
      qui drop if `1'==.
      mac shift 1
    }
  }
return local nmiss=`cum_nmiss'
tokenize "`varlist'"
                                                            
/*********************************************
 * Pair the data from the varlist
 * and check that they are numeric
 *********************************************/

if "`quiet'"=="" {
  di
  di as text "Marker information"
  di in smcl "{dup 18:{c -}}"
}

local i 1
while "`1'"~="" {
   if "`2'"=="" { di in red "There must be paired data `1' and ?" }
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
     if "`lab1'"~="" & "`lab2'"~="" { di in smcl as res "Alleles for l$nloc are (`root1' , `root2') {col 44}[`lab1' , `lab2']" }
     else { di as res "Alleles for l$nloc are (`root1' , `root2') " }
   }
   return local loci`i' = "`root1' `root2'"
   local i = `i'+1
mac shift 2
}
                                                              
if "`quiet'"=="" { di }

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
   if "`convars'"=="" { di as error "You must specify the convars() option when using constraint files" }
   qui use "`confile'",replace
   tokenize "`convars'"
   cap confirm variable Efreqold
   if _rc~=0 {
     cap confirm variable Ifreq
     if _rc~=0 {
       di as error "Constraints file doesnt contain Efreqold or Ifreq!"
       exit(198)
     }
     else { rename Ifreq Efreqold }
   }
   sort `convars'
   qui save "`confile'",replace
   
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

qui use "`temp'",replace

/**********************************************************************
 * haplotyp expands the dataset into the phases
 * Takes the varlist and constructs the haplotypes
 * locus1 and locus2
 * For phase unknown locus1 and locus2 contain all possible haplotypes
 **********************************************************************
 * Additionally the user can specify that there are missing values
 * in the DNA typings with the MV option
 */


if "`known'"~="" & "`phase'"=="" { haplotyp, known `mv' `quiet'}
if "`known'"=="" & "`phase'"==""{ haplotyp, `mv' `quiet'}
if "`phase'"~="" { haplotyp,known phase(`phase') `mv' `quiet'}

/* What is the next line? Probably gets rid of the chance of duplicates */


qui {
drop `varlist'
compress
}

/********************************************************************************
 * Start frequencies: 
 * 1) Each phase is equally likely
 * 2) Each phase is randomly likely
 * 3) Each phase's probability is specified in a file (this means re-estimation 
 *    of the same model is immediate -- helpful when doing multiple models)
 * N.B. the weights are allocated to the phase expanded dataset. 
 * The default is equal weights
 ********************************************************************************/

tempvar f1 tef1
if "`start'"=="" & "`usew'"=="" {
   sort subject
   qui by subject: gen double `f1'=1/_N 
}
if "`start'" ~= "" {
   sort subject
   qui gen double `f1'=uniform()
   qui by subject: gen double `tef1'= sum(`f1')
   qui by subject: replace `f1'= `f1'/`tef1'[_N]
   drop `tef1'
}
if "`usew'"~="" {
  confirm file `usew'.dta
  sort subject locus1 locus2
  qui merge subject locus1 locus2 using `usew'
  qui count if _merge~=3
  if r(N)>0 {
    di as error "The start weights contain different loci or subjects to the dataset"
    exit
  }
  qui drop _merge
  qui gen double `f1' = weight
  drop weight 
}

/*********************************************
 *   EM algorithm
 *********************************************/

local cont 1
local it 0
local saveimp 0 

      cap confirm new variable locus
      if _rc~=0 {
        di as error "Rename the variable locus"
        exit(111)
      }

while(`cont'==1) { /*Start of while loop */
                       
   cap drop `pr' `prs'
   tempvar pr prs stupid plocus

   cap drop llh
   local it = `it'+1

/************************************************************
 *       # New estimate of haplotype relative frequencies
 ************************************************************/

   cap drop freq

      qui gen long `stupid' = _n /* this will preserve line numbers */
      qui _stack locus1 locus2
      qui rename locus1 locus
      qui drop locus2

     /* generate individual loci variables */

      local vlist " "
      qui gen str70 `plocus' = locus
      forval i=1/$nloc {
         tempvar len len2
         qui gen `len' = index(`plocus',".")-1
         qui gen l`i'=real(substr(`plocus',1,`len'))
         if `i'==$nloc { qui replace l`i'=real(`plocus') }
         else { qui gen `len2' = index(`plocus',".")+1
         qui replace `plocus'=substr(`plocus',`len2',.) }
         drop `len'
         cap drop `len2'
         local vlist "`vlist' l`i'"
      }
                   
   if `debug'>0 {
     tab locus
     list l* if locus==""
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


 if "`ldim'"=="" {
      if "`convars'"=="" {
         if "`noise'"=="" { qui  ipf [fw=`f1'],exp fit(`ipf') save("`file'") acc(`ipfacc') }
         else{ ipf [fw=`f1'],exp fit(`ipf') save("`file'") acc(`ipfacc')  }
      }
      else {
        if "`noise'"=="" { qui ipf [fw=`f1'],exp convars(`convars') confile("`confile'") fit(`ipf') save("`file'") acc(`ipfacc') }
        else { ipf [fw=`f1'],exp convars(`convars') confile("`confile'") fit(`ipf') save("`file'") acc(`ipfacc') }
      }
       
      local df  "`r(df)'"
      local nparms "`r(parms)'"
      local ncells "`r(ncells)'"
      sort `r(vlist)'
      global ipflist = "`r(vlist)'"
      qui merge `r(vlist)' using "`file'"   /* merge in the new frequencies */

 }
 else {
    qui ipf `ldim' [fw=`f1'], fit(`ipf') save("`file'") acc(`ipfacc')
    local df "`r(df)'"
    sort `ldim'
    global ipflist = "`ldim'"
    qui merge `ldim' using `file'   /* merge in the new frequencies */
 }


/******************************************************
 * Sometimes fit.dta has an unobserved line of 
 ******************************************************/

local rvlist "`r(vlist)'"
qui count if locus==""

if `debug'>1 {
  l locus caco Efreq prob if locus==""
  di "`r(N)' loci missing"
}

if `r(N)' > 0 {
  tempvar temprep
  qui gen `temprep' = locus==""
  forval i=1/$nloc {
    qui replace locus = cond( locus=="", locus + string(l`i'), locus +"."+ string(l`i')) if `temprep'==1
  }
  qui drop `temprep'
}


if `debug'>2 {
  l locus caco Efreq prob 
}

/****************************************
 * Saving the expected Frequencies.
 ****************************************/

  if `saveimp'==1 {
    tempfile imputef now
    qui save "`now'"
    sort `rvlist'
    qui by `rvlist': keep if _n==1
    qui save "`imputef'"
    qui use "`now'",clear
  }

      drop `vlist' Efreq Ofreq _merge
 

      sort _stack `stupid'
      qui _ustack locus prob, by(_stack) val(1 2)
      drop _stack merg _merge

      drop `stupid' 
      cap drop npar
	
      qui gen npar = 1
      local npar = npar[_N]

/*************************************************************
 *     # New probabilities (per phase and per subject)
 ************************************************************/

   qui gen double `pr' = prob1*prob2
   drop prob1 prob2 

/******************************************************************************
 *     # Calculate log likelihood
 * 1/11/99 I think in the next part within subject `by' shouldnt change
 * hence could ignore `by' UNLESS in each by strata individuals ids are
 * determined
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


      if `it'==1 {
        if "`quiet'"=="" {
          di as txt "Iterations"
          di as smcl "{dup 10:{c -}}"
        }
      }
      if "`nolog'"=="" {
        di as res "Iteration `it' loglhd = `llh'"
      }
      else { 
        if "`noprint'"=="" { di as res _continue "." }
      }

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
       local tmpdiff = (`lastllh'-`llh')
       di in smcl "{err}Likelihood not increased in hapipf. Decrease= `tmpdiff'"
     }
   }

if `saveimp'==0 {
  if `cont'==0 {
    local saveimp 1
    local cont 1
  }
}

local lastllh = `llh'

if mod(`it',100)==0 & "`nolog'"~="" {
  di as error "Iteration `it' loglhd = `llh'"
}


}  /*end of while loop */

/* 
 * You can save the weights at the end of the iteration cycle 
 * This is useful when you want to fit a very similar model and start at roughly the right place
 */

if "`savew'"~="" {
  tempfile nowtemp
  qui save "`nowtemp'"
  sort subject locus1 locus2
  qui g double weight = `f1'
  keep subject locus1 locus2 weight
  qui save `savew', replace
  qui use "`nowtemp'"
}

if "`nolog'"~="" & "`noprint'"=="" { di }

qui _stack locus1 locus2 `pr' `pr'
rename locus1 locus

/********************************************************************************
 * In order to display the results I need the variables included
 * in the ipf model so that the expected frequencies are split
 * in groups of this as well
 ********************************************************************************/
/*WILL this work for number of loci >10... i.e l1  is in l10*/
     local vlist "$ipflist "
     forval i=1/$nloc {
         local length= length("l`i'")
         local ind = index("`vlist'","l`i' ")
         if `ind'>0 { local vlist = substr("`vlist'",1,`ind'-1)+substr("`vlist'",`ind'+`length',.) }
      }

sort locus `vlist'
qui by locus `vlist' : gen double freq = sum(`pr')
qui _unique subject
qui gen double eprob=freq/(2*r(unique))
qui by locus `vlist' : keep if _n==_N

sort `vlist' locus

/******************************************************************
 * A routine to combine rare haplotypes and to specify the degrees
 * of freedom test for a general test of association.
 ******************************************************************/

if `rare'~=0 {
  tempfile raremaster
  qui save "`raremaster'"
  qui use "`origin'",replace
  qui cap tab `cc',matrow(lev)
  if _rc==198 {
    di " option matrow() not allowed"
    di "does the variable `cc' only have one row?"
    exit(198)
  }

  qui use "`raremaster'",replace

  di
  di as txt "Grouping Rare Haplotypes" 
  di as txt as smcl "{dup 24:{c -}}"
  
  /* First generate indicator variable to indicate the rare haplotypes */
  qui gen rare= eprob<`rare'
  qui count if rare==1
  local nrare=r(N)
  local totrare = _N
  if `nrare'==0 {
    di as error "There are no lines of rare data! alter the rare frequency"
    qui use "`origin'",clear
    exit(198)
  }
  local nlines = _N
  local sumrareprob 0
  forval x = 1/`nlines' {
    if rare[`x']==1 {
      local sumrareprob = `sumrareprob'+eprob[`x']
      local clocus = locus[`x']
      local cfreq = substr(string(eprob[`x']),1,8)
      if `x'~=1 {
        local combi "`combi' `clocus'"
        local combi2 "`combi2' `cfreq'"
      }
      else {
        local combi "`clocus'"
        local combi2 "`cfreq'"
      }
    } 
  }
  di as txt "The following haplotypes are combined:"
  di
  di as smcl "{col 5}`haptext'{col 20}Frequencies"
  local i 1
  foreach chap of local combi {
    local temp: word `i' of `combi2'
    di as res as smcl "{col 5}`chap'{col 20}`temp'"
    local i = `i'+1
  }
  local sumrareprob = substr("`sumrareprob'",1,8)
  di as res as smcl "{col 5}{dup 23:{c -}}"
  di as res as smcl "{col 5}TOTAL{col 20}`sumrareprob'"
  
  local i 1
  local slist ""
  qui gen str70 plocus = locus
  while `i'<=$nloc {
     qui gen len = index(plocus,".")-1
     qui gen l`i'=real(substr(plocus,1,len))
     if `i'==$nloc { qui replace l`i'=real(plocus) }
     else {
       qui gen len2 = index(plocus,".")+1
       qui replace plocus=substr(plocus,len2,.)
     }     
     qui drop len
     qui cap drop len2
     if `i'==1 { local slist "l`i'" }
     else { local slist "`slist' l`i'" }
     local i=`i'+1
  }

  keep `slist' rare
  tempfile precon
  qui save "`precon'"
  qui gen double Efreqold = cond(rare==1, 1 ,.)
  qui drop rare
  sort `slist'
  qui save constrain1,replace

  /* Now create the second constraint file that includes the dependent
    variable normally Case/control status  */
  qui use "`precon'"
  local rarelv = rowsof(lev)
  qui expand `rarelv'
  sort `slist'
  qui by `slist':gen `cc' = lev[_n,1]
  qui gen double Efreqold = cond(rare==1,1,.)
  qui drop rare
  qui save constrain2,replace
  
  di
  local ci 1
  foreach ln of local slist {
    if `ci'==1 { local cipf "`ln'" }
    else { local cipf "`cipf'+`ln'" }
    local ci = `ci'+1
  }
  local cdf2 = `totrare'-`nrare'
  local cdf1 = 0

  local xtra ""
  if "`phase'"~="" { local xtra "`xtra' phase(`phase')" }
  
  local rarecommand1 "hapipf `varlist',ipf(`cipf'+`cc') confile(constrain1) convars(`slist') model(1) condf(`cdf2') nolog quiet `known' `display' `xtra' conmod(Independence) `mv' `mvdel' `start'"
  local rarecommand2 "hapipf `varlist',ipf(`cipf'+`cc') confile(constrain2) convars(`slist' `cc') model(0) lrtest(0,1) condf(`cdf1') nolog quiet `known' `display' `xtra' conmod(Association) `mv' `mvdel' `start'"

  qui use "`raremaster'",replace  
  
}

/**********************************
 * Display the testing expressions
 **********************************/

  if "`quiet'"=="" {
    di as text ""
    local len = length("`haptext' Frequency Estimation by EM algorithm")
    di "`haptext' Frequency Estimation by EM algorithm"
    di in smcl "{dup `len':{c -}}"

    if "`confile'"=="" {  di as res " Model ", _col(20) "= `ipf'" } 
    di as res " No. loci ", _col(20) "= $nloc"
    di " Log-Likelihood ", _col(20) "= `llh'"
    if "`condf'"=="-1" { di " Df ", _col(20) "=" , `df' }
    else { di " Df ", _col(20) "=" , `condf' }
    if "`condf'"=="-1" {
      di " No. parameters ", _col(20) "=" , `nparms'
      di " No. cells ", _col(20) "=" , `ncells'
    }
    if "`confile'"~="" & "`condf'"=="-1" {
      di in smcl as text "{c TLC}{dup 45:{c -}}{c TRC}"
      di in smcl as text "{c |}" as res "WARNING: df wrong when using constraints file" as text "{c |}"
      di in smcl as text "{c BLC}{dup 45:{c -}}{c BRC}"
    }
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
 qui gen double `total'=sum(freq)
 qui gen double eprob=freq/`total'[_N]
 sort locus `vlist'
         
if "`display'"~="" {
   qui gen str80 `haptvar'=locus
   qui compress `haptvar'
   list `haptvar' `vlist' freq eprob, noobs
   qui drop `haptvar'
   /* LOOK at the total frequency */
   qui gen double totf = sum(freq)
   di 
   di "TOTAL FREQ is ", totf[_N]
}

global loglik=`llh'
global df =`df'

keep locus `vlist' freq eprob
if "`using'"~="" {

/* Must create the l1 l2 l3...  variables from locus for the profile likelihood */

  qui gen str70 plocus = locus
  forval i=1/$nloc {
      qui gen len = index(plocus,".")-1
      qui gen l`i'=real(substr(plocus,1,len))
      if `i'==$nloc { qui replace l`i'=real(plocus) }
      else { qui gen len2 = index(plocus,".")+1
      qui replace plocus=substr(plocus,len2,.) }
      drop len
      cap drop len2
  }
  drop plocus

  cap save "`using'", replace
}

/****************************************************************
 * Saving the model ipf string and the loglikelihood and
 * degrees of freedom
 ****************************************************************/

if "`condf'"=="-1" { global hapmod`model'="`ipf'" }
else { global hapmod`model'="`conmod'" }
if "`condf'"=="-1" { global hapdf`model'="`df'" }
else { global hapdf`model'="`condf'" }
global hapllhd`model'="`llh'"

if "`lrtest'"~="" {
   tokenize "`lrtest'"
   local m1 "hapmod`1'"
   local m2 "hapmod`2'"
   local l1 "hapllhd`1'"
   local l2 "hapllhd`2'"
   local d1 "hapdf`1'"
   local d2 "hapdf`2'"
   local mlab1 "`1'"
   local mlab2 "`2'"

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
   if `error'~=1 {
     local len =length("Likelihood Ratio Test Comparing Model $`m2' to $`m1'")
     if "`noprint'"=="" {
     di
     di as text "Likelihood Ratio Test Comparing Model $`m2' to $`m1'"
     di in smcl "{dup `len':{c -}}"
     di as res "Model `mlab1': llhd (df)           =", $`l2', "($`d2')"
     di        "Model `mlab2': llhd (df)           =", $`l1', "($`d1')"
     di
     di "-2*(llhd2-llhd1)  =",-2*($`l2'-$`l1')
     di "Change in df      = ", $`d2'-$`d1'
     }
     local lrt = -2*($`l2'-$`l1')
     local chdf = $`d2'-$`d1'
     local pv=chiprob(`chdf',`lrt')
     if "`noprint'"=="" { di "p-value           = ", chiprob(`chdf',`lrt') }
     if `chdf'<0 {
       di as error "WARNING: negative change in df (`chdf')"
       di as error "       The order of models in lrtest() is wrong"
     }                   
     if `lrt'<0 {
       di as error "WARNING: negative chi-squared statistic (`lrt')"
       di as error "       Either The order of models in lrtest() is wrong"
       di as error "       OR     The accuracy options ipfacc() acc() are too low"
     }                   
     if `chdf'>=0 & `lrt'>=0 & "`noprint'"=="" {
       if `pv'<0.05 { di as text "Do not Reject Model $`m1' at 5% significance level" }
       else {  di as text "Reject Model $`m1' at 5% significance level" }
     }
     return scalar lrtpv = `pv'
     return scalar lrtdf = `chdf'
     return scalar lrtchi = `lrt'
   }
}


qui use "`origin'",clear
if "`rare'"~="0" {
  di as txt in smcl "{c TLC}{dup 50:{c -}}{c TRC}"
  di as txt in smcl "{c |}" as res "With the grouped haplotypes two models are fitted" as txt "{col 52}{c |}"
  di in smcl "{c |}" as res "The first is the independence model" as txt "{col 52}{c |}"
  di in smcl "{c |}" as res "The second is the association model" as txt "{col 52}{c |}"
  di as txt in smcl "{c BLC}{dup 50:{c -}}{c BRC}"
  `rarecommand1'
  `rarecommand2'
}

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
	qui by temp: gen double freq=sum(one)
	qui by temp: keep if _n==_N
}
if "`by'"~="" {
	stack `1' `3' `by' `2' `4' `by', into(temp one `by') clear
	sort temp `by'
	qui by temp `by': gen double freq=sum(one)
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
qui egen long hapgrp = group(haplo)
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
syntax [varlist] [,NOISE KNOWN PHASE(string) MV QUIET]
tokenize `varlist'

cap confirm new variable locus1 locus2 subject
if _rc~=0 {
  di as error "You must rename the following variable"
  confirm new variable locus1 locus2 subject
}
tempvar subj expand

/* NOTE that `subj' contains the actual subject ids and at the end it gets renamed
 * as subject
 */

qui gen long subject = _n
qui gen long `subj' = _n

if "`mv'"~="" {
  if "`quiet'"=="" { di "EXPANDING MISSING DATA....." }

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
      if "`quiet'"=="" { di "There are `cnt' missing values at locus `li'" }
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
      
    /* The matrix unique now contains just one copy of the alleles
     * Replace missing with one from each of unique
     * FOR TWO loci this would be the number of unique*(unique+1)/2
     */
      
      tempvar temp
      sort subject
      qui gen long `temp'=_n
      local missex = rowsof(unique)
      local missex = `missex'*(`missex'+1)/2
      qui expand  `missex' if `root1'==. | `root2'==.
      sort `temp'
      
      /*Create the new phenotypes */

      local lineno 1

      local rowsofunique = rowsof(unique)
      forval i=1/`rowsofunique' {
        forval j=1/`rowsofunique' {
           qui by `temp': replace `root1' = cond(`root1'==. & _n==`lineno', unique[`i',1],`root1')
           qui by `temp': replace `root2' = cond(`root2'==. & _n==`lineno', unique[`j',1],`root2')
           local lineno = `lineno'+1
         }
      }

 
    } /* end of if dealing with missing */


    local li =`li'+1  /*loop of loci */
  }

}



if "`known'"~="" & "`phase'"=="" {
	qui gen str70 locus1=""
	qui gen str70 locus2=""
	/*******************************************
	 * Construct locus strings from alleles
	 *******************************************/
	sort subject
	global unknown = 0
	forval i=1/$nloc {
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

	}
}

if "`known'"=="" & "`phase'"=="" {

	local root1: word 1 of $all_name
	local root2: word 2 of $all_name
	qui gen str70 locus1=string(`root1')
	qui gen str70 locus2=string(`root2')
	qui gen `expand'=.

	/*******************************************
	 * Construct locus strings from alleles and 
	 * also expand to all possibilities
	 *******************************************/

        if "`mv'"=="" {	local i 2 }
	if "`mv'"~="" { local i 1 }

	while `i'<=$nloc {
          sort `subj'
          /* Gets the two loci names for locus i */
          local wc1=2*`i'-1
          local wc2=`wc1'+1
          local root1: word `wc1' of $all_name
          local root2: word `wc2' of $all_name
		

        /* Expand out heterozygotes */
                qui replace `expand'= 2*(`root1'~=`root2')

          /* old subject no is _n */
                  
		qui replace subject=_n
		qui expand `expand'
		sort subject

/* OLD WAY OF DOING MISSING DATA
                qui by subject: replace locus1= locus1+"."+string(cond(_n==2,`root2',`root1'))
               qui by subject: replace locus2= locus2+"."+string(cond(_n==2,`root1',`root2'))
*/

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
	qui gen str70 locus1=string(`root1')
	qui gen str70 locus2=string(`root2')
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

        if "`mv'"=="" {	local i 2 }
	if "`mv'"~="" { local i 1 }

	while `i'<=$nloc {
		sort `subj'
		local wc1=2*`i'-1
		local wc2=`wc1'+1
		local root1: word `wc1' of $all_name
		local root2: word `wc2' of $all_name
		
                /* THIS BIT IS FOR NOT EXPANDING FOR WHOLE DATASET*/

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

qui append using "`stack'"

end

program define _ustack
version 7.0
syntax varlist(min=1) [using/] [if],BY(string) VALues(string) [NOISE START KNOWN PHASE(string) ]
tokenize `varlist'

tokenize "`values'", parse(" ")
tempfile first merge

qui by `by': gen long merg=_n
save "`first'"

keep if `by'==`1'
keep `varlist' merg
foreach var of varlist `varlist' {
	rename `var' `var'1
}
sort merg
save "`merge'"

qui use "`first'"
tokenize `values', parse(" ")
keep if `by'==`2'
foreach var of varlist `varlist' {
	rename `var' `var'2
}

sort merg
merge merg using "`merge'"

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

/******************************************
 * BUILDING the menu system for easy use
 ******************************************/

prog def _qmenu
version 7.0
syntax [varlist]

win c clear
local statnloc 10

/* Window width and height textheight */

local winw  260
local winh 240
local texth 7
local leftmargin 10
local rightmargin =`winw'-10

/* Initialising globals */

forval i=1/`statnloc' {
  global statloc`i' ""
}
global Qadd ""
global Qipf ""
global Qvar ""
global Qtvar ""
global infoqt "then press apply"
global infoqt1 "Select variables and"
global Qcommand ""

/* Varlist options */
  
global Qsel "Select variables for:"
global Qmany "Loci"
global Qqt "Disease Outcome"
global Qvarlist "`varlist'"
window control static Qsel 5 10 110 `texth' center
window control static Qqt 60 20 50 `texth' center
window control ssimple Qvarlist 60 30 50 100 Qtvar
window control static Qmany 5 20 50 10 center
window control msimple Qvarlist 5 30 50 100 Qvar

/* BUTTONS */

local tey = `winh'-11-15
global Qvchk1 "hapupdate 0"
global Qvchk2 "hapupdate 1"
window control button "Apply" 5 `tey' 30 11 Qvchk1
window control button "Put in review window" 40 `tey' 70 11 Qvchk2

/* Get rid of window */

global Qrun "exit 3001"
global Qexit "exit 3000"
window control button "Run command" 115 `tey' 55 11 Qrun
window control button "Exit" 175 `tey' 30 11 Qexit

/* INFORMATION
 * Display info qdix and qdiy control the top left corner */

local qdix=`winw'-140
local qdiy 30
local qdisx = `qdix'+35
local qdiw = `winw'-10-`qdix'

global Qdi "Information"
window control static Qdi `qdix' 30 `qdiw' 100 blackframe
window control static Qdi `qdisx' 27 30 7 center

/* Put in pairs of vars */
  
tokenize $Qvar
forval i=1/`statnloc' {
  local tey = `qdiy'+10
  local tex = `qdix'+10
  local tew = `qdiw'-20
  local staty = `tey' + 7*(`i'-1)
  win c static statloc`i' `tex' `staty' `tew' `texth' left
}
local tey=`staty'+10
win c static infoqt1 `tex' `tey' `tew' `texth'
local tey=`tey'+`texth'
win c static infoqt `tex' `tey' `tew' `texth'

/* Display three models with check box and ipf() syntax box */

global Qllm "Loglinear Model"
local tey=`winh'-11-15-75
local teyy = `tey'-3
local tey2 = `tey'+9
local tew = `rightmargin'-`leftmargin'
local tew2= `tew'-20
local tex = `leftmargin'+10
local temid = int((`rightmargin'-`leftmargin')/2)-30
window control static Qllm `leftmargin' `tey' `tew' 20 blackframe
window control static Qllm `temid' `teyy' 60 8 center
window control static Qipf `tex' `tey2' `tew2' `texth' center

/* Display 4 models with check box and ipf() syntax box */

global Qmod1 ""
global Qmod2 ""
global Qmod3 ""
global Qmod4 ""

global Qqm "4 common models"
local tey=`winh'-11-15-50
local teyy = `tey'-3
local tew = `rightmargin'-`leftmargin'
local temid = int((`rightmargin'-`leftmargin')/2)-30
local tew2= `tew'-20
local tex = `leftmargin'+10
local tey2 = `tey'+9
window control static Qqm `leftmargin' `tey' `tew' 45 blackframe
window control static Qqm `temid' `teyy' 64 `texth' center
local tey3 = `tey'+7
local tex2 = `tex'+80
win c radbegin "Haplotype frequencies" `tex' `tey3' 80 `texth' Qrad
win c static Qmod1  `tex2' `tey3' 90 `texth'
local tey3 = `tey3'+9
win c radio "Linkage equilibrium" `tex' `tey3' 90 8 Qrad
win c static Qmod2  `tex2' `tey3' 90 `texth'
local tey3 = `tey3'+9
win c radio "Disease association" `tex' `tey3' 90 `texth' Qrad
win c static Qmod3  `tex2' `tey3' 90 `texth'
local tey3 = `tey3'+9
win c radend "No association"  `tex' `tey3' 90 `texth' Qrad
win c static Qmod4  `tex2' `tey3' 90 `texth'

/* Display the syntax */

global Qdis ""
local tey=`winh'-1-`texth'
local tex=`leftmargin'+31
window control static Qdis `leftmargin' `tey' 30 `texth' left
window control static Qcommand `tex' `tey' 200 `texth' left

/* ENd of windowing */

window dialog "A window to help with the basic model syntax" . . `winw' `winh'

end




