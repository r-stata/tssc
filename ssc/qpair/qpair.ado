*! version 1.00 21MAY2021

program define qpair, rclass 
version 12.0

syntax [if] [in], FIRst(varlist) SECond(varlist) NFActor(integer) ///
                 [EXTraction(string)] [ROTation(string)] [APProach(string)] ///
				 [SCOre(string)] [ESize(string)] [BIPolar(string)] [STLength(string)]
preserve

foreach var in `first' `second' {
confirm variable `var'
}
local nsort: word count `first'
scalar nsort=`nsort'
//
tokenize `first'
local first1 `1'
forval j=2/`nsort' {
local first`j' ``j''
}

tokenize `second'
local second1 `1'
forval j=2/`nsort' {
local second`j' ``j''
}

qui tab `first1', matcell(dim1) matrow(dim2)

/* To identify Q-sort table distribution*/
scalar nstat=r(N) /*Define number of Statements*/
scalar r= rowsof(dim1)
forvalues j=2/`=r' {
matrix dim1[`j', 1]=dim1[`j', 1] + dim1[`j'-1, 1]
}
//
if "`extraction'"=="" local extraction "ipf"
if "`extraction'"=="ml" {
dis as err " Option ml is not allowed for factor extraction " 
exit 198
}
if "`rotation'"=="" local rotation "varimax"
global n=`nfactor' /*Define number of factors to be extracted*/

/*Settimg length of statement*/
if "`stlength'"=="" local stlength "50"
global s=`stlength'
replace statement=substr(statement,1,$s )

if "`approach'"=="" | "`approach'"=="1" | "`approach'"=="I" | "`approach'"=="one" {
forval i=1/`nsort' {
gen diff`i'=`first`i''- `second`i''
}

di ""
di  "************************************************************************"
di  "************************** APPROACH I WAS USED ***************************"
di  "************************************************************************"

/* Calculate & standardise differenes*/

forval i=1/`nsort' {
sort diff`i' StatNo
qui egen rankdiff`i'=rank(diff`i'), unique
}
//

local j= dim1[1,1]
local k= dim2[1,1]
qui recode rankdiff* (1/`j'=`k')

forvalues i=2/`=r' {
local l= dim1[`i'-1,1]+1
local j= dim1[`i',1]
local k= dim2[`i',1]
qui recode rankdiff* (`l'/`j'=`k')	
}		
//

forval i=1/`nsort' {
qui replace diff`i'=rankdiff`i'
}
drop rankdiff*

factor diff*, fa($n) `extraction'  /*Choose factor extractin technique*/
matrix unrotated=e(L)
matrix unique=e(Psi) /* These 4 line calculate communality for each subject*/
qui matrix unique=unique'
svmat unique
ren unique1 unique
gen h2= 1-unique

dis ""
dis "       ******************************************************************"
dis "         ************* ROTATION TECHNIQUE =" " `rotation' *************"
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
scalar bipole=`nsort'-r(N)
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
dis "   ***** Factor scores were calculated using Brown's formula*****"
forvalues i=1/$n {
gen wf`i'=f`i'/(1-f`i'^2) /*Calculating weights for factor loading based on Brown's approach*/
}
mkmat wf1-wf$n if _n<=`nsort', matrix (weights) /*Save weights for factor loading in a matrix*/
mkmat diff* if _n <=nstat, matrix(Qsorts) /*Save Qsorts in a matrix*/
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
format f1-f$n %5.2g
dis ""
dis   "********** Q-SORTS LOADED ON EACH FACTOR **********"
list Qsort f1-f$n loaded1-loaded$n if f1 <., noobs sep(0)


/*Next step: standardise the factor score*/

forvalues i=1/$n {
qui egen zscore`i'=std(score`i')
sort zscore`i' StatNo // To generate the same F's in the next line
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
/*Identifying distiguishing statements for each factor*/

/*The following line identify whether the diff between factor */
/*scores are significant for each statement.*/

if "`esize'"=="" | "`esize'"=="0" | "`esize'"=="stephenson" {
dis ""
dis "* DIFFERENCES BETWEEN FACTOR SCORES FOR EACH STATEMENT WERE CALCULATED USING STEPHENSON'S FORMULA *"
forvalues i=1/$n {
scalar rf`i'=0.8*fcount`i'/(1+(fcount`i'-1)*.80) /*rf stands for correlation*/
/* between factor scores and fcount is number of Q-sorts loaded on each factor*/
scalar se`i'=sqrt(1-rf`i') /*se for each factor score*/
}
forvalues i=1/$n  {
forvalues j=1/$n  {
if `i'~=`j' {
qui gen zdiff`i'`j'=0 
scalar sed`i'`j'=sqrt(se`i'^2+se`j'^2) //se for factor score differences
qui replace zdiff`i'`j'=1 if abs(zscore`i'-zscore`j')>=1.96*sed`i'`j'
}
}
} 
}
else {
global d=`esize'
if $d >0 & $d <=1 {
dis ""
dis  "* DIFFERENCES BETWEEN FACTOR SCORES FOR EACH STATEMENT WAS ASSESSED USING Cohen's d= `esize' *"

forvalues i=1/$n  {
forvalues j=1/$n  {
if `i'~=`j' {
qui gen zdiff`i'`j'=0 
qui replace zdiff`i'`j'=1 if abs(zscore`i'-zscore`j')>=$d  
}
}
}
}
else {
dis ""
dis as err " The identified Effect Size (esize) is out of (0, 1) range."
exit 198
}
}
//	

format zscore* %5.3g

/*The following lines identify and prints distinguishing statements for each factor*/

forvalues i=1/$n {
egen ds`i'=rowtotal(zdiff`i'*) 
} 
//
drop zdiff*

sort StatNo, stable
dis ""
dis ""
dis "       ************** z_scores and ranks for all Statements  **************"
list StatNo zscore1-F_$n if F_1<. , noobs sep(0)

/*Saving unrotated Factor loadings, factor scores and Factor variable, etc.*/

svmat unrotated, names(unroL)

/*Writing Distinguishing Statements*/

forvalues i=1/$n {
dis ""
dis ""
dis "             ********* Distinguishing Statements for Factor `i' **********"
dis ""
dis "                      Number of Q-sorts loaded on Factor `i'= " fcount`i'  
gsort -F_`i' /*to sort ranks in decending order*/
list StatNo statement F_* if F_1<. & ds`i'==$n-1, noobs sep(0)
} 

/* The following commands print Consensus statements*/ 
egen ds=rowtotal(ds*)
dis ""
dis ""
dis "               ************** Consensus Statements **************"
list StatNo statement F_* if F_1<. & ds==0, noobs sep(0)

/*Saving Factor scores in a different file*/

qui keep Qsort Factor unique h2 unroL*   
sort Qsort
qui drop if Qsort>`nsort'
matrix rotL=e(r_L)
svmat rotL, names(rotL)
order Qsort unroL* rotL* unique h2 Factor
qui save FactorLoadings.dta, replace
}
else {
if "`approach'"=="2" | "`approach'"=="II" | "`approach'"=="two" {
di ""
di  "************************************************************************"
di  "************************** APPROACH II WAS USED ***************************"
di  "************************************************************************"

factor `first', fa($n) `extraction'  
matrix unrotated=e(L)
matrix unique=e(Psi) /* These 4 line calculate communality for each subject*/
qui matrix unique=unique'
svmat unique
ren unique1 unique
gen h2= 1-unique

dis ""
dis "       ******************************************************************"
dis "         ************* ROTATION TECHNIQUE =" " `rotation' *************"
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
scalar bipole=`nsort'-r(N)
if bipole == 0 {
}
else if bipole >= $nl {
if "`score'"=="" local score= "brown"

if "`score'"~="brown" {
dis as err "Bipolar option is only available for Brown's factor scores" 
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
dis "   ***** Factor scores were calculated based on Brown's formula*****"
forvalues i=1/$n {
gen wf`i'=f`i'/(1-f`i'^2) /*Calculating weights for factor loading based on Brown*/
}
mkmat wf1-wf$n if _n<=`nsort', matrix (weights) /*Save weights for factor loading in a matrix*/
mkmat `first' if _n <=nstat, matrix(Qsorts) /*Save Qsorts in a matrix*/
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
format f* %5.2g
dis ""
dis   "********** Q-SORTS LOADED ON EACH FACTOR **********"
list Qsort f* loaded* if f1 <., noobs sep(0)


/*Next step: standardise the factor score*/

forvalues i=1/$n {
qui egen zscore`i'=std(score`i')
sort zscore`i'
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
			 
/*Identifying distiguishing statements for each factor*/

if "`esize'"=="" | "`esize'"=="0" | "`esize'"=="stephenson" {
dis ""
dis "* DIFFERENCES BETWEEN FACTOR SCORES FOR EACH STATEMENT WERE CALCULATED USING STEPHENSON'S FORMULA *"
forvalues i=1/$n {
scalar rf`i'=0.8*fcount`i'/(1+(fcount`i'-1)*.80) /*rf stands for correlation*/
/* between factor scores and fcount is number of Q-sorts loaded on each factor*/
scalar se`i'=sqrt(1-rf`i') /*se for each factor score*/
}
forvalues i=1/$n  {
forvalues j=1/$n  {
if `i'~=`j' {
qui gen zdiff`i'`j'=0 
scalar sed`i'`j'=sqrt(se`i'^2+se`j'^2) //se for factor score differences
qui replace zdiff`i'`j'=1 if abs(zscore`i'-zscore`j')>=1.96*sed`i'`j'
}
}
} 
}
else {
global d=`esize'
if $d >0 & $d <=1 {
dis ""
dis  "* DIFFERENCES BETWEEN FACTOR SCORES FOR EACH STATEMENT WAS ASSESSED USING Cohen's d= `esize' *"

forvalues i=1/$n  {
forvalues j=1/$n  {
if `i'~=`j' {
qui gen zdiff`i'`j'=0 
qui replace zdiff`i'`j'=1 if abs(zscore`i'-zscore`j')>=$d  
}
}
}
}
else {
dis ""
dis as err " The identified Effect Size (esize) is out of (0, 1) range."
exit 198
}
}
//	

format zscore* %5.3g

/*The following lines identify and prints distinguishing statements for each factor*/

forvalues i=1/$n {
egen ds`i'=rowtotal(zdiff`i'*) 
} 
//
drop zdiff*

sort StatNo, stable
dis ""
dis ""
dis "       ************** z_scores and ranks for all Statements  **************"
list StatNo zscore1-F_$n if F_1<. , noobs sep(0)

/*Saving unrotated Factor loadings, factor scores and Factor variable, etc.*/

svmat unrotated, names(unroL)

/*Writing Distinguishing Statements*/

forvalues i=1/$n {
dis ""
dis ""
dis "       ******* Distinguishing Statements for Factor `i' at Baseline *******"
dis ""
dis "                      Number of Q-sorts loaded on Factor `i'= " fcount`i'  
gsort -F_`i' /*to sort ranks in decending order*/
list StatNo statement F_* if F_1<. & ds`i'==$n-1, noobs sep(0)
} 

/* The following commands print Consensus statements*/ 
egen ds=rowtotal(ds*)
dis ""
dis ""
dis "        ************** Consensus Statements at Baseline **************"
list StatNo statement F_* if F_1<. & ds==0, noobs sep(0)

/*Saving Factor Loadings in a different file*/

sort Qsort, stable
matrix rotL=e(r_L)
svmat rotL, names(rotL)

mkmat Qsort unroL* rotL* unique h2 Factor, mat(FactorLoadings)
return matrix FactorLoadings=FactorLoadings
qui recode Factor(0=.)

dis ""
dis ""
dis "     ******** Number of Q-sorts loaded on each factor at Baseline ********"
tab Factor, gen(factor)
qui recode factor* (.=0) if Qsort<=`nsort'  
mkmat factor*, matrix(factors) nomis
/*Cleaning and re-saving FactorScores file*/
order StatNo zscore* F_*
sort StatNo, stable
qui drop if StatNo==.

mkmat StatNo zscore* F_*, mat(FactorScores)
return matrix FactorScores=FactorScores

mkmat `second', matrix(Qsortafter)
matrix A=Qsortafter*factors

mkmat F_*, matrix(Fscores)
svmat A, names(After)

forvalues i=1/$n {
ren F_`i' F`i'1
}
//
forvalues i=1/$n {
qui egen zAfter`i'=std(After`i')
sort zAfter`i'
qui egen rankAfter`i'=rank(zAfter`i'), unique
}
//
local j= dim1[1,1]
local k= dim2[1,1]
qui recode rankAfter* (1/`j'=`k')

forvalues i=2/`=r' {
local l= dim1[`i'-1,1]+1
local j= dim1[`i',1]
local k= dim2[`i',1]
qui recode rankAfter* (`l'/`j'=`k')	
}		
//
drop After* zAfter*
ren rankAfter* F*2

/*Writing Distinguishing Statements*/
order _all, seq
forvalues i=1/$n {
dis ""
dis ""
dis "    **** Score Differences in Distinguishing Statements for Factor `i' ****"
dis ""
dis "                      Number of Q-sorts loaded on Factor `i'= " fcount`i'  
gsort -F`i'1 /*to sort ranks in decending order*/
list StatNo statement F`i'* if F11<. & ds`i'==$n-1, noobs sep(0)
} 
//
sort StatNo, stable
drop Factor
dis ""
dis "    ******** Score Differences for all Statements for all Factors ********"
list StatNo statement F* if F11<. , noobs sep(0)

}
else {
dis as err "********** `approach' is not an acceptable approach. **********" 
}
}
// 
restore

end
