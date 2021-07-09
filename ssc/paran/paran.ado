*! version 1.5.0 04oct2012 by alexis dot dinno at pdx dot edu
*! perform horn's parallel analysis of principle components/factors

*   Copyright Notice
*   paran and paran.ado are Copyright (c) 2001, 2012 alexis dinno
*
*   This file is part of paran.
*
*   Paran is of free software ; you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation; either version 2 of the License, or
*   (at your option) at any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with this program (paran.copying); if not, write to the Free Software
*   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

* Syntax:  paran varlist [weight] [if exp] [in range] [, iterations(#) centile(#) quietly nostatus nostatus status factor(factor_type) citerate(#) protect(#) pnf all graph color lcolors(# # # # # # # # #) saving(file) replace seed(#) anything(name=mat id="correlation matrix") n(numlist max=1 >=0 integer 0) copyleft]

program define paran

  if int(_caller())<8 {
    di in r "paran- does not support this version of Stata." _newline
    di as txt "Requests for a v7 compatible version will be relatively easy to honor." 
    di as txt "Requests for a v6 compatible version may be less easy." 
    di as txt "Requests for a version compatible with versions of STATA earlier than v6 are "
    di as txt "untenable since I do not have access to the software." _newline 
    di as txt "All requests are welcome and will be considered."
    exit
  }
   else paran8 `0'
end

program define paran8, eclass
 version 8.0
 
 #del ;
 syntax [varlist(numeric default=none)] [aweight fweight] [if] [in] 
 [, 
     ITErations(integer 0) 
     CENTile(numlist min=1 max=1 >0 <100) 
     Quietly 
     NOSTatus 
     STatus 
     factor(string) 
     CITerate(passthru) 
     PRotect(passthru) 
     pnf 
     all 
     GRaph 
     color 
     lcolors(numlist integer missingok min=9 max=9 >=0 <=255) 
     saving(string) 
     replace 
     seed(integer 0) 
     Mat(string) 
     n(integer 0) 
     copyleft
 ];
 #del cr
     
 preserve
 quietly {


* display the copyleft information if requested

  if "`copyleft'" == "copyleft" {
    noisily {
      di _newline "Copyright Notice"
      di "paran and paran.ado are Copyright (c) 2001, 2012 alexis dinno" _newline
      di "This file is part of paran." _newline
      di "Paran is of free software ; you can redistribute it and/or modify"
      di "it under the terms of the GNU General Public License as published by"
      di "the Free Software Foundation; either version 2 of the License, or"
      di "(at your option) at any later version." _newline
      di "This program is distributed in the hope that it will be useful,"
      di "but WITHOUT ANY WARRANTY; without even the implied warranty of"
      di "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"
      di "GNU General Public License for more details." _newline
      di "You should have received a copy of the GNU General Public License"
      di "along with this program (paran.copying); if not, write to the Free Software"
      di "Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA" _newline
    }
  }

* Confirm that EITHER x OR mat were provided
  if ( "`mat'"=="" & "`varlist'"=="" ) {
    di as err "you must provide either x or mat"
    exit 100
    }  
* Confirm that x and mat were NOT both provided
  if ( "`mat'"!="" & (`:list sizeof mat' > 1) ) {    di as err "you must provide the name of only one correlation matrix"    exit 103    }
  if ( ("`mat'"!="") & !("`varlist'"=="") ) {
    di as err "you must supply either x or mat but not both"
    exit 198
    }

* Set number of variables
  if ( "`mat'"=="" & "`varlist'" != "" ) {
    local P: word count `varlist'
    }
  if ( "`mat'"!="" & "`varlist'" == "" ) {
    local P = rowsof(`mat')
    if ("`if'"!="") {
      di as err "you may not use if when specifying the mat option"
      exit 198
      }
    if ("`in'"!="") {
      di as err "you may not use in when specifying the mat option"
      exit 198
      }
    if ("`weight'"!="") {
      di as err "you may not use analytic or frequency weights when specifying the mat option"
      exit 406
      }
    }

* Confirm correlation matrix, and not covariance matrix
  if ("`mat'"!="") {
    if (colsof(`mat') != rowsof(`mat')) {
      di as err "the matrix provided with the mat argument is not a correlation matrix"
      exit 505
      }
    forvalues i = 1/`P' {
      if (el(`mat',`i',`i') != 1) {
        di as err "the matrix provided with the mat argument is not a correlation matrix" _newline "parallel analysis is not compatible with the eigendecomposition of a covariance matrix"
        exit 499
        }
      }
    }


* quick validation of factor() option which is used to indicate the type of 
* factor estimation used, and of citerate and protect.

   if "`factor'" != "" & ~("`factor'" == "pf" | "`factor'" == "pcf" | "`factor'" == "ipf" | "`factor'" == "ml") {
     noisily { 
       di _newline as red "Invalid factor type specified!"
       di as txt "You must specify " as white "factor()" as txt " as pf, pcf, ipf or ml."
       exit
     }
   }
   
   if "`factor'" == "ipf" & "`citerate'" != "" & "`protect'" != "" {
     noisily {
       di _newline as yellow "iterated principal factors specified, " as white "`protect'" as res " ignored." _newline
       local protect = ""
     }
   }
   
   if "`factor'" == "ml" & "`citerate'" != "" & "`protect'" != "" {
     noisily {
       di _newline as yellow "maximum likelihood factors specified, " as white "`citerate'" as res " ignored." _newline
       local citerate = ""
     }
   }

* quick validation of centile as an integer value

   if "`pnf'" == "pnf" {
     local centile = 95
     }

   if "`centile'" != "" {
     local centile = round(`centile')
   }

* quick check if the undocumented status option is used
   if "`status'" == "status" {
     local nostatus = ""
     }

*******************************************************************************
* Program start. Identify P (number of variables in component analysis) and   *
* use _N for the number of observations (modified by any if conditioning      *
* within the pca command). Then generate the data-set of this size with the   *
* uniform() function.                                                         *
*******************************************************************************
   if ("`mat'"=="") {
     pca `varlist'
     matrix Ev = get(Ev)
     }
   if ("`mat'"!="") {
     pcamat `mat', n(`n')
     matrix Ev = e(Ev)
     }
   local P = colsof(Ev)
   if ("`mat'"=="") {
     count
     local N = r(N)
     }
   if ("`mat'"!="") {
     local N = `n'
     }

*Perform user's pca or factor command.

   if "`quietly'"=="" { 

     if "`factor'" != "" {
       noisily {
         if ("`mat'"=="") {
           factor `varlist' `if' `in' [`weight' `exp'], `factor' `citerate' `protect'
           }
         if ("`mat'"!="") {
           factormat `mat', n(`n') `factor' `citerate' `protect'
           }
       }
     }

      else {
       noisily { 
         if ("`mat'"=="") {
           pca `varlist' `if' `in' [`weight' `exp']
           }
         if ("`mat'"!="") {
           pcamat `mat', n(`n')
           }
        }
      }
   }   

    else {
      if "`factor'" != "" {
        if ("`mat'"=="") {
          factor `varlist' `if' `in' [`weight' `exp'], `factor' `citerate' `protect'
          }
        if ("`mat'"!="") {
          factormat `mat', n(`n') `factor' `citerate' `protect'
          }
      }
       else {
        if ("`mat'"=="") {
          pca `varlist' `if' `in' [`weight' `exp']
          }
        if ("`mat'"!="") {
          pcamat `mat', n(`n')
          }
       }
    }

* clean up iteration and determine value
   if `iterations'<0 {
     local iterations = 30*(`P')
     noisily { 
       di _newline as err "Invalid number of iterations! Using default value of `iterations'."
     }
   }
   if `iterations' == 0 {
     local iterations = 30*(`P')
   } 


* Let the user know the program is working.
   if "`nostatus'"!="nostatus" { 
     if `iterations' >= 10 {
       noisily {
         di _newline as res "Computing: " _continue
       }
     }
   }

   forval k = 1/`iterations' {
   
* Yet _more_ letting the user know the program is working!
      if "`nostatus'" != "nostatus" {
       if mod(`k',(`iterations'/10)) == 1 & `iterations' >= 10 & `k' > 1 {
         local pct = int(`k'/(`iterations'/10))*10
         noisily {
           di "`pct'% " _continue
         }
       }
       if `k' == `iterations' {
       	 noisily {
       	   di as res "100%" _newline
       	 }
       }
      }

* prepare to save the results of each pca
     if `k' > 1 {
       forvalues p = 1/`P' {
         drop `C`p'' `_val`p'' 
         }
       }
     if `N' < `iterations' {
       set obs `iterations'
       }
     forvalues p = 1/`P' {
       tempvar C`p'
       gen `C`p'' = .     
       }
       
* Create the random dataset.

* but first set seed for the random number generator if requested
     if `seed' != 0 {
       local Seed = `seed'*`k'
       set seed `Seed'
       }

     forval x = 1/`P' {
       tempvar _val`x'
       gen `_val`x'' = invnorm(uniform())
       replace `_val`x'' = . if _n > `N'
       }

* Run a principal components analysis on the random dataset (which is the same 
* size and dimension as the user dataset.)
     if "`factor'" != "" {
       factor `_val1'-`_val`P'' `if' `in', `factor' `citerate' `protect'
       }
      else {
       pca `_val1'-`_val`P'' `if' `in'
       }

* Save eigenvalues
     matrix Evs = get(Ev)
     forvalues p = 1/`P' {
       replace `C`p'' = Evs[1,`p'] if _n == `k'
       }

*End the multiple iteration loop
   }


*******************************************************************************
* Make assertions to the user about the results of this analysis.             *
*******************************************************************************

* set the name of the analysis run
  local model = ""
  if "`factor'" == "" {
    local model = "principal components"
  }
  if "`factor'" == "pf" {
    local model = "principal factors"
  }
  if "`factor'" == "pcf" {
    local model = "principal components factors"
  }
  if "`factor'" == "ipf" {
    local model = "iterated principal factors"
  }
  if "`factor'" == "ml" {
    local model = "maximum likelihood factors"
  }

*end the quiet execution of commands
 }
 
 di _newline _newline as txt "Results of Horn's Parallel Analysis for `model'"

 if `iterations' == 1 {
   if "`centile'" == "" {
     di as res "1" as txt " iteration, using the " as res "mean" as txt " estimate" _newline
   }
   if "`centile'" != "" {
     di as res "1" as txt " iteration, using the " as res "p`centile'" as txt " estimate" _newline
   }
 }
  else {
    if "`centile'" == "" {
      di as res "`iterations'" as txt " iterations, using the " as res "mean" as txt " estimate" _newline
    }
    if "`centile'" != "" & "`centile'" != "50" {
      di as res "`iterations'" as txt " iterations, using the " as res "p`centile'" as txt " estimate" _newline
    }
    if "`centile'" == "50" {
      di as res "`iterations'" as txt " iterations, using the " as res "p`centile'" as txt " (median) estimate" _newline
    }
  }

 di as txt "--------------------------------------------------"
 di as txt "Component   Adjusted    Unadjusted    Estimated"
 di as txt "or Factor   Eigenvalue  Eigenvalue    Bias"
 di as txt "--------------------------------------------------"

  quietly {
    matrix RndEv = J(1,`P',.) 

    if "`centile'" != "" {
    	forvalues p = 1/`P' {
    	  centile `C`p'', centile(`centile')
    	  matrix RndEv[1,`p'] = r(c_1)
    	  }
    	}
    if "`centile'" == "" {
    	forvalues p = 1/`P' {
    	  sum `C`p''
    	  matrix RndEv[1,`p'] = r(mean)
    	  }
      }
    }

  local est = 1
 
  if el(Ev,1,1) < 1 { 
    di as res "No components passed."
    di as txt "--------------------------------------------------"
    exit 
    }

 if "`factor'" == "" {
  local criterion = 1
  }
 if "`factor'" != "" {
  local criterion = 0
  }

 forval x=1/`P' {
   local y = `x'
   if el(Ev,1,`x') < `criterion' | el(RndEv,`est',`x') < `criterion' { 
     local y = `x'
     continue, break
     }
   }



 if "`all'" == "all" {
   local y = `P'
   } 

 matrix AdjEv = RndEv
 forvalues p = 1/`P' {
   matrix AdjEv[1,`p'] = Ev[1,`p'] - (RndEv[1,`p'] - `criterion')
   }

 forval x=1/`P' {
   local retained = `x'
   if AdjEv[1,`x'] <= `criterion' {
     local retained = `x' - 1
     continue, break
     }
   }

 matrix Bias = RndEv
 forvalues p = 1/`P' {
   matrix Bias[1,`p'] = RndEv[1,`p'] - `criterion'
   }

 local noretain = 0
 forval x=1/`y' {
   local sigcolor = "res"

   if AdjEv[1,`x'] <= `criterion' | `noretain' == 1 {
     local noretain = 1
     local sigcolor = "red"
     }

   if "`all'" == "all" {
     di as res " " `x' as `sigcolor' _col(13) AdjEv[1,`x'] as res _col(25) el(Ev,1,`x') as res _col(39) el(Bias,`est',`x')
     }
    else {
     if el(Ev,1,`x') >= `criterion' {
       di as res " " `x' as `sigcolor' _col(13) AdjEv[1,`x'] as res _col(25) el(Ev,1,`x') as res _col(39) el(Bias,`est',`x')
       }
     }
   }

 di as txt "--------------------------------------------------"
 if "`factor'" == "" {
   di as txt "Criterion: retain adjusted components > 1"
   }
 if "`factor'" != "" {
   di as txt "Criterion: retain adjusted factors > 0"
   }      

 if "`graph'" == "graph" {
   if "`lcolors'" == "" {
     local EvCol = "red"
     local RndEvCol = "blue"
     local AdjEvCol ="black"
     }
   if "`lcolors'" != "" {
     tokenize `lcolors'
     local EvCol = "`1' `2' `3'"
     local RndEvCol = "`4' `5' `6'"
     local AdjEvCol = "`7' `8' `9'"
     }
   local EvLpat = "solid"
   local RndEvLpat = "solid"
   if "`color'" == "" & "`lcolors'" == ""{
     local EvCol = "black"
     local RndEvCol = "black"
     local EvLpat = "dash"
     local RndEvLpat = "dot"
     } 
   matrix P = Ev',AdjEv',RndEv'
   local N = colsof(Ev)
   svmat P
   gen n = _n
   label var P1 "Observed"
   label var P2 "Adjusted"
   label var P3 "Random"
   label var n "Component"
   if "`factor'" != "" {
	   label var n "Factor"
	   }
   if "`save'" == "" {
     graph twoway connect P1 n if _n <= `N', yline(`criterion' ,lcolor(gs10) lwidth(vthin)) aspectratio(1) legend(cols(1) order(1 3 2)) mcolor("`EvCol'") msymbol(O) msize(tiny) lwidth(vthin) lcolor("`EvCol'") lpattern(`EvLpat') ytitle("Eigenvalue") || connect P3 n if _n <= `N', msize(tiny) msymbol(O) mcolor("`RndEvCol'") lwidth(vthin) lcolor("`RndEvCol'") lpattern(`RndEvLpat') || connect P2 n if _n <= `N', mcolor("`AdjEvCol'") msize(vsmall) msymbol(O) lwidth(thin) lcolor("`AdjEvCol'") lpattern(solid) || scatter P2 n if _n > `retained' & _n <= `N', mcolor(white) msize(tiny) msymbol(O)
     }
   if "`save'" != "" {
     graph twoway connect P1 n if _n <= `N', yline(`criterion' ,lcolor(gs10) lwidth(vthin)) aspectratio(1) legend(cols(1) order(1 3 2)) mcolor("`EvCol'") msymbol(O) msize(tiny) lwidth(vthin) lcolor("`EvCol'") lpattern(`EvLpat') ytitle("Eigenvalue") || connect P3 n if _n <= `N', msize(tiny) msymbol(O) mcolor("`RndEvCol'") lwidth(vthin) lcolor("`RndEvCol'") lpattern(`RndEvLpat') || connect P2 n if _n <= `N', mcolor("`AdjEvCol'") msize(vsmall) msymbol(O) lwidth(thin) lcolor("`AdjEvCol'") lpattern(solid) || scatter P2 n if _n > `retained' & _n <= `N', mcolor(white) msize(tiny) msymbol(O) saving("`save'", "`replace'")
     }
   }

*******************************************************************************
*Clean up and produce the appropriate return stuff.                           *
*******************************************************************************

   *Retain things for the for user...
   ereturn matrix Bias           = Bias
   if ("`centile'"=="") {
     ereturn matrix CentRandomEv = RndEv
     }
   if ("`centile'"!="") {
     ereturn matrix MeanRandomEv = RndEv
     }
   ereturn matrix AdjustedEv     = AdjEv
   ereturn matrix UnadjustedEv   = Ev
 
   return clear
   restore

end

