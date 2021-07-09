*! version 2.20 04JUN2019

/*
History: Changes from version 1.0
version 2.0 (21Jun2017): 
	1- added option for conducting bipolar factors analysis.
	2- dropped sed option and added effect size (Cohen's d) option for identifying distinguishing statements.
	3- dropped use of nstatement and nqsort as required options. nstatements and nqsort are now automatically identified.
	4- the program is now able to conduct all rotation techniques (orthogonal and oblique) available for Stata.
	5- the program accommodates (truly!) theoretical rotation using "target(Tg)" option.

version 2.10:
	1- dropped ml for factor extraction
	2-bug fixes
	
version 2.10.01:
	1- Added a note in the help file that bipolar() option works only with Brown's scores.
	
version 2.20:
	1- The option for reading data from PQMethod format has been deleted.
	2- The names of the original variables  are now preserved and shown in the output. 
*/
program define qfactor 
version 12.0

syntax varlist(min=3 numeric) [if] [in], NFActor(integer) [EXTraction(string)] ///
                      [ROTation(string)] [SCOre(string)] ///
					  [ESize(string)] [BIPolar(string)]
preserve
foreach var in `varlist' {
confirm variable `var'
}
//
tokenize `varlist'
qui tab `1', matcell(dim1) matrow(dim2)

/* To identify Q-sort table distribution*/
scalar nstat=r(N) /*Define number of Statements*/
scalar r= rowsof(dim1)
forvalues j=2/`=r' {
matrix dim1[`j', 1]=dim1[`j', 1] + dim1[`j'-1, 1]
}
//
if "`extraction'"=="" local extraction "ipf"
if "`extraction'"=="ml" {
dis as err " Option ml is not allowed for extraction" 
exit 198
}
if "`rotation'"=="" local rotation "varimax"
global n=`nfactor' /*Define number of factors to be extracted*/
local nsort: word count `varlist' /*Define number of Q-sorts*/
scalar nsort=`nsort'

factor `varlist', fa($n) `extraction'  /*Choose matrix extracting technique*/
matrix unrotated=e(L)
matrix unique=e(Psi) /* These 4 line calculate communality for each subject*/
qui matrix unique=unique'
svmat unique
qui gen h2=1-unique1

dis ""
dis "       ******************************************************************"
dis "            ************* ROTATION TECHNIQUE =" " `rotation' *************"
dis "       ******************************************************************"

if "`rotation'"=="none" {
matrix rotated=e(L) /*To save unrotated factor loadings*/
}
else {
rotate, `rotation' normalize /*Rotating the extracted factors*/

matrix rotated=e(r_L) /*To save rotated factor loadings*/
}
//
svmat rotated, names(f) /*saving rotated matrix loadings as variables*/

scalar rcut=2/sqrt(nstat) /* To calculate cut-off point for significant loadings */

/*The following loop replaces non-significant loading with zero*/
forvalues i=1/$n {
qui replace f`i'=0 if abs(f`i')<rcut | f`i'^2 <h2/2
}
//
/*Identifying bipolar factors */
if ("`bipolar'"=="" | "`bipolar'"=="no") local bipolar= "0"
global nl=`bipolar' /*Define criteria for # of negative loadings for a bipolar factor*/
/*The following loop deals with negative loadings*/
if $nl == 0 {
}
else {

forvalues i=1/$n {
qui count if f`i' >=0
scalar bipole=nsort-r(N)
if bipole == 0 {
}
else if bipole >= $nl {
if "`score'"=="" local score= "brown"

if "`score'"~="brown" {
dis as err "bipolar option is only available for Brown's factor scores" 
exit 198
}

qui gen f`i'_1=f`i'
qui gen f`i'_2=f`i'
qui replace f`i'_1=0 if f`i'_1 <0
qui replace f`i'_2=0 if f`i'_1 >0
drop f`i'
global n=$n +1
}
}
//
ren f*# f#, renumber
}
//

if "`score'"=="" | "`score'"=="brown" {
di ""
dis  "   ***** Factor scores were calculated using Brown's formula*****"
forvalues i=1/$n {
qui gen wf`i'=f`i'/(1-f`i'^2) /*Calculating weights for factor loading based on Brown*/
}
mkmat wf1-wf$n if _n<=nsort, matrix (weights) /*Save weights for factor loading in a matrix*/
mkmat `varlist' if _n <=nstat, matrix(Qsorts) /*Save Qsorts in a matrix*/
matrix StScore=Qsorts*weights /*Calculate the factor scores */
svmat StScore, names(score) /*write factor score into the file*/
}

else {
dis ""  
qui predict score*, `score' 
local method r(method)
dis "    *** Factor scores were calculated using "`method' " method ***"
}	
//
forvalues i=1/$n {
qui egen ncount=count(f`i') if f`i'!=0 & f`i'<.
qui sum ncount
scalar fcount`i'=r(N) /* Number of significant loadings for each factor*/
drop ncount
} 
//
gen Factor=0 //To identify which Qsort loaded on which factor
forvalues i=1/$n {
qui gen loaded`i'=f`i'
qui recode loaded`i' (0=0)(nonmiss=1)
qui replace Factor= `i' if loaded`i'==1
}
//
qui gen Qsort=_n
local j = 1  
      foreach v of local varlist {
             label def Qsort `j' "`v'", modify
             local ++j
      }

      label val Qsort Qsort

format f* %5.2g
dis ""
dis   "********** Q-SORTS LOADED ON EACH FACTOR **********"
list Qsort f* loaded* if f1 <., noobs sep(0)


/*Next step: standardise the factor score*/

forvalues i=1/$n {
qui egen zscore`i'=std(score`i')
qui egen F_`i'=rank(zscore`i'), unique
}
//
/* Calculating the final synthesized Q-sort for each factor*/
local j= dim1[1,1]
local k= dim2[1,1]
qui recode F_* (1/`j'=`k')

forvalues i=2/`=r' {
local l= dim1[`i'-1,1]+1
local j= dim1[`i',1]
local k= dim2[`i',1]
qui recode F_* (`l'/`j'=`k')	
}		
//
/*Identifying distinguishing statements for each factor*/

/*The following line identify whether the diff between factor */
/*scores are significant for each statement.*/

if "`esize'"=="" | "`esize'"=="0" | "`esize'"=="stephenson" {
dis ""
dis  "* DIFFERENCES BETWEEN FACTOR SCORES FOR EACH STATEMENT WERE CALCULATED USING STEPHENSON'S FORMULA *"
forvalues i=1/$n {
scalar rf`i'=0.8*fcount`i'/(1+(fcount`i'-1)*.80) /*rf stands for correlation*/
/* between factor scores and fcount is number of Q-sorts loaded on each factor*/
scalar se`i'=sqrt(1-rf`i') /*se for each factor score*/
}
forvalues i=1/$n  {
forvalues j=1/$n  {
if `i'~=`j' {
qui gen diff`i'`j'=0 
scalar sed`i'`j'=sqrt(se`i'^2+se`j'^2) //se for factor score differences
qui replace diff`i'`j'=1 if abs(zscore`i'-zscore`j')>=1.96*sed`i'`j'
}
}
} 
}
else {
global d=`esize'
if $d >0 & $d <=1 {
dis ""
dis "* DIFFERENCES BETWEEN FACTOR SCORES FOR EACH STATEMENT WERE ASSESSED USING Cohen's d= `esize' *"

forvalues i=1/$n  {
forvalues j=1/$n  {
if `i'~=`j' {
qui gen diff`i'`j'=0 
qui replace diff`i'`j'=1 if abs(zscore`i'-zscore`j')>=$d  
}
}
}
 
}
else {
dis ""
dis as err " The identified Effect Size (esize) is out of (0,1) range."
exit 198
}
}
//	

format zscore* %5.3g
/*The following lines identify and prints distinguishing statements for each factor*/

forvalues i=1/$n  {
qui egen ds`i'=rowtotal(diff`i'*) 
} 
//
sort StatNo
dis ""
dis ""
dis "       ************** z_scores and ranks for all Statements  **************"
list StatNo zscore1-F_$n if F_1<. , noobs sep(0)

/*Saving unrotated Factor loadings, factor scores and Factor variable, etc.*/

svmat unrotated, names(unroL)
ren unique1 unique
//qui gen Qsort=_n

/*Writing Distinguishing Statements*/

forvalues i=1/$n {
dis ""
dis ""
dis in green "             ********* Distinguishing Statements for Factor `i' **********"
dis ""
dis "                      Number of Q-sorts loaded on Factor `i'= " fcount`i'  
gsort -F_`i' /*to sort ranks in descending order*/
list StatNo statement F_* if F_1<. & ds`i'==$n-1, noobs sep(0)
} 

/* The following prints Consensus statements*/ 
  
egen ds=rowtotal(ds*)
dis ""
dis ""
dis "               ************** Consensus Statements **************"
list StatNo statement F_* if F_1<. & ds==0, noobs sep(0)

/*Saving Factor Loadings in a different file*/
qui keep Qsort Factor unique h2 unroL*   
sort Qsort
qui drop if Qsort>nsort
matrix rotL=e(r_L)
svmat rotL, names(rotL)
order Qsort unroL* rotL* unique h2 Factor
qui save FactorLoadings.dta, replace

restore

end

