*! version 1.1.0 - Mike Lacy 28sep2010
// Calculate ordinal variation measures and their standard errors.
// See Blair, J. and M. Lacy 2000. "Statistics of Ordinal Variation." 
// Sociological Methods & Research 28:251-80, and citations to Berry et al.
// therein for the normed version and the derivation of the standard
// errors.  See Lacy, M. 2006 "An Explained Variation Model for Ordinal
// Response Models... ." Sociological Methods & Research. 34: 469-520 for 
// a presentation of the non-normed version.
//
//
//             USAGE 1: ordvar MyVar        
//
//   where MyVar is required to be coded with consecutive integers.
//   In this form, the max and min values of MyVar are obtained from the data.
//
//
//   There is a second form of usage, in which the user specifies the 
//   max and min values for MyVar. 
//         
//        USAGE 2: ordvar MyVar, low(MyLowValue) high(MyHighValue) 
//
//    Specifying the max and min values is necessary if there is a zero 
// frequency at the top or bottom of the theoretical range of MyVar, 
// which would not be detected from merely examining the data. Such 
// zero frequencies, though, are very important to the value of the 
// dispersion or concentration statistic, and in some applications 
// such data can commonly occur.
// 
//  See syntax below. Note that [if] and [by] are allowed
//
//
//
program define ordvar, rclass sortpreserve byable(recall)
* This program calculates the lsq and d^2 measures and  their variance. Translated
* from my original pascal code.
* approach to it.
* Sept, 2005
* Modification, July 2007.  Make the program byable.
* Modification, July 2007.  Make all scalars into tempnames
* Modification, April 2008. Allow for zero frequencies in the distribution.
* Modification, April 2010. Make output nicer.
*
version 9.0
syntax varlist(max = 1) [if] [in] [, LOW(integer -1) HIGH(integer -1) ]
tokenize `varlist'
local y = "`1'"  // the user's variable
marksample touse
tempname F N k p
// Tabulate and echo frequencies and put them in a column vector, numbered
// consecutively.  tab1 will not work here because it can't deal with empty 
// categories.
if (`low' == -1) | (`high' == -1) {
   //  Typical: User did not supply low and high values, so we get them from data.
      quiet summ `y' if `touse', meanonly // get min and max values
   if (`low' == -1) local low = trunc(r(min))
   if (`high' == -1) local high = trunc(r(max))
}    
// But sometimes user supplies high and low, e.g., for leading or trailing zero freqs.
//
local k = `high' - `low' + 1  
mat `F' = J(`k',1,0)
scalar `N' = 0
local i = 1
local anyzeros = 0
display as text "Cell Frequencies for "_continue
display as result "`y'"
//
forval val = `low'/`high' {
   quiet count if (`y' == `val') & `touse' 
   mat `F'[`i',1] = r(N)
   di as result "  " `val' "  " `F'[`i',1]
   if !`anyzeros' & r(N) ==0 {
      local anyzeros = 1
   }
   scalar `N' = `N' + r(N)
   local ++i
}
di as text "Total N = " `N'
if `anyzeros' ==1 {
   di as result "Note: A zero frequency occurred." 
}   
di _newline 
//
matrix `p' = `F'  /* capture for future use */
// Frequencies are in the matrix p, convert to relative, then cumulative frequencies 
matrix `p'[1,1] = `p'[1,1]/`N'
matrix `F'[1,1]  = `p'[1,1]
forvalues i = 2/`k' {    
   matrix `p'[`i',1] = `p'[`i',1]/`N'
   matrix `F'[`i',1] = `F'[`i'-1, 1] + `p'[`i', 1] 
}   
// debug  mat list `F  
// debug mat list `p' 
// 
//Start calculation Sum of F(1-F) over all categories 
tempname dsq
scalar `dsq' = 0
forvalues i = 1/`k' {
   scalar `dsq' = `dsq' + ( `F'[`i',1] * ( 1.0 - `F'[`i',1]))
 }
tempname lsq
scalar `lsq' = 1 - `dsq' *4.0/(`k' - 1) 
*
// Now do standard error
tempname SixtyFour OneHalf part1 term1 term2 part2
scalar `SixtyFour' = 64.0  /* a constant in the variance expression */
scalar  `OneHalf' = 1.0/2.0
*  `part1', `part2'   /* first and second parts of the variance expression */
*  `term1', `term2'/* first and second terms appearing */
                   /* in each part of the variance expression */
scalar `part1' = 0.0
local km1 = `k' - 1   // k minus 1
forvalues l = 1/`k' {
   scalar `term1' = (`k'-`l') * (`OneHalf' - `p'[`k',1])
   scalar `term2' = 0.0
   local lp1 = `l' + 1
   forvalues j = `lp1'/`km1'  {
     scalar `term2' = `term2' + (`l' - `j') * `p'[`j',1]
   }  
   scalar `part1' = `part1' + (`term1' + `term2')^2 * `p'[`l',1]
}      
scalar `part1' = `SixtyFour' * `part1'/(`km1')^2
/* debug  di "`part1' at end of first loop" `part1'   */
/* preceding was ok */
*    
   scalar `part2' = 0.0
   forvalues l = 1/`k' {
      scalar `term1' = (`k'- `l')  * (`OneHalf' - `p'[`k',1])
      /* debug  display "l and `term1' in 1 to k loop " `l' " " %12.8f `term1' */
      scalar `term2' = 0.0
      local lp1 = `l' + 1
      forvalue j = `lp1'/`km1' {
         scalar `term2' = `term2' + (`l' - `j') * `p'[`j',1]
         /* debug  di "j and `term2' at end inside j loop, j = " `j' "  "  %12.8f `term2' */
*     debug j and `term2' look ok          
      }  
      
      scalar `part2' = `part2' + (`term1' + `term2') * `p'[`l',1]
      /* debug  display " l and `part2', inside 2nd loop= " `l' " " %20.12f `part2' */
   }
   /* debug  di "`part1' `part2', right before 64X : " %12.8f `part1' " " %12.8f `part2' */
   scalar `part2' = `SixtyFour' * (`part2'^2)/(`km1'^2)
   
   
*
   tempname lsqvar lsqSE dsqSE 
   scalar `lsqvar' = (`part1' - `part2')/`N'
   scalar `lsqSE' = sqrt(`lsqvar')
   scalar `dsqSE'  = `lsqSE'  *(`k'-1)/4 
   //
   /*
   di as text "Ordinal Dispersion/Consensus Measures and (Standard Errors)"
   di as text "Normed Dispersion (1-LSQ) = " _cont
   di as result  %7.5f 1.0-`lsq'  " (" %8.6f = `lsqSE' ")"
   */
   di as text "Ordinal Dispersion and Consensus Measures (Standard Errors)" _newline
   di as text _col(5)"Normed Dispersion" _col(30) "Non-Normed Dispersion" _continue
   di as text _col(60) "Normed Consensus"
   di as text _col(5) "(1-lsq)" _col(30) "d-squared [Sum(F(1-F)]" _continue 
   di as text _col(60) "lsq"
   di as text _col(5) _dup(72) "_" _newline
   di as result _col(5) %7.5f 1.0-`lsq'  " (" %8.6f = `lsqSE' ")" _continue
   di as result _col(30) %7.5f = `dsq' " (" %8.6f = `dsqSE' ")" _continue
   di as result _col(60) %7.5f `lsq'  " (" %8.6f = `lsqSE' ")" _continue
   //
   return scalar dsqse  = `dsqSE'
   return scalar dsq = `dsq'
   return scalar lsqse = `lsqSE'
   return scalar lsq = `lsq'
   return scalar onemlsq = 1.0 - `lsq'
end   
*
