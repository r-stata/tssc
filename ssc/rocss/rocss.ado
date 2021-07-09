*!  Version 1.0 - March 11, 2004 - N.Orsini

program rocss, rclass

version 8

syntax varlist (min=2 max=2 numeric) [if] [in] [, NCut(numlist >0 max=1 integer) GRaph SAVEData(string) REPlace]

preserve 

marksample touse 

quietly {

tempvar y p  

parse "`varlist'" , parse(" ")
gen `y' =  `1' if `touse'	 
gen `p' =  `2' if `touse'
tab `p'
local ncp = r(r)

/* check the outcome and the probability */

capture assert `y' == 1 | `y' == 0 if `touse'

if _rc != 0 {
		di in r "The outcome variable is not coded 0/1"
		exit 198
		}

capture assert `p' >= 0 & `p' <= 1 if `touse'

if _rc != 0 {
		di in r "The probability variable must range in the interval 0 / 0.1"
		exit 198
		}

/* fix the number equally spaced probability intervals in the range 0, 1.*/

if "`ncut'" != ""  { 
                      local  st  = 1/`ncut'
                          }
			  else {
				local ncut = 10
				local st = 1/10
				}
tempname TOT Y1 Y0
su `y' if `touse' 
scalar `TOT' = r(N)
return scalar N = `TOT'

count if `y' == 1 & `touse'
scalar `Y1' = r(N)
count if `y' == 0 & `touse'
scalar `Y0' = r(N)

/* use a post-file to record the results */

tempname mcss
tempfile mroc
qui postfile `mcss' cutoff sens spec cclass  using  mroc ,  replace 

local c = 0
local cp = 0 

/* loop to calculate sensitivity, specificity */

forvalues i = 0(`st') 1.000000000002  {

tempname NSENS SENS NSPEC SPEC CUTOFF CORRCLASS 
 			   
if `c' != 0  local cp = `cp' + `st'
  else local cp 0

local c = `c' + 1

count if `y' == 1 & `p' >= `i'  & `touse'
scalar `NSENS' = r(N)
scalar `SENS' = r(N)/`Y1'
count if `y' == 0 & `p' <  `i' & `touse'
scalar `NSPEC' = r(N)
scalar `SPEC' = r(N)/`Y0'
scalar `CUTOFF' = `cp'
scalar `CORRCLASS' = (`NSENS'+`NSPEC')/`TOT'*100

post `mcss' (`CUTOFF') (`SENS') (`SPEC') (`CORRCLASS')     

	}	
}

postclose `mcss'

return scalar cutoff = `c'  

qui use mroc , clear
gen double omspec = 1- spec
qui su cclas 
return scalar maxcclas = r(max)

/* compute area under ROC curve */

gen double carea  = sum((spec-spec[_n-1])*(sens+sens[_n-1])/2)	
return scalar area = carea[_N] 
local area = return(area)

label var  sens  "Sensitivity"
label var  spec  "Specifity"
label var omspec "1-Specifity"
label var cutoff "Probability cutoff"
label var cclass "Correctly classified"
label var carea  "Cumulative Area"

/* display results */

format cutoff %4.3f
format sens spec omspec cclass carea %5.4f
 
l cutoff sens spec omspec cclass carea, sep(0)

noi di _n in  g "Number of observations                   " _col(45) " = "  `Y1'+`Y0'
noi di    in  g "Number of probability cutoffs (`ncut'+1) " _col(45) " = "  return(cutoff)   
noi di    in g  "Area under ROC curve                     " _col(45) " = " %6.4f return(area)
noi di    in g  "Highest value of correctly classified    " _col(45) " = " %6.4f return(maxcclas) 

/* display ROC curve */

if "`graph'" != ""  {

format sens omspec %3.2f
local area : di %6.4f return(area)
local cutoff = _N
local note = "Area under ROC curve (`cutoff' cutoffs) = `area'"
local yttl : var label  sens
local xttl : var label  omspec 

gr twoway (connected  sens   omspec ,		///
			sort				///
			ylabel(0(.25)1, grid) ///
			ytitle(`"`yttl'"')		///
			xlabel(0(.25)1, grid)		///
			xtitle(`"`xttl'"') ///
			note(`"`note'"') ///
   			legend(nodraw)   )	///
		 (function y=x,		///		 
			clstyle(refline)		///
			range(`vspec')			///
			n(2)	///			
			  yvarlabel("Sensitivity") ///
			xvarlabel("1-Specifity") )					 
}

/* save dataset */

if "`savedata'" != ""  {
		    if "`replace'" != ""  {	 
   				   qui save "`savedata'", replace
                     		}
		 		else {
   				   qui save "`savedata'"
            	         }
			}

capture erase mroc.dta

end

