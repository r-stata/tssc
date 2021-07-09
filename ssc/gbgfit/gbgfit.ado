*! version 1.0 Austin Nichols, June 23, 2009
*! Fit Generalized Beta (Type 2) distribution to grouped data by multinomial ML
*! ssc install gb2fit for individual data
prog gbgfit, eclass byable(onecall)
 version 8.2
 if replay() {
  if "`e(cmd)'" != "gbgfit" {
   noi di as error "results for gbgfit not found"
   exit 301
  }
  if _by() {
   error 190
  }
  Display `0'
  exit `rc'
 }
 if _by() {
  by `_byvars'`_byrc0': Estimate `0'
 }
 else Estimate `0'
end
prog Estimate, eclass byable(recall) sortpreserve
syntax varlist(max=1) [if] [in] [aw fw pw iw] [,z1(varlist numeric) z2(varlist numeric) From(string) noLOG cap /*
 */ Level(integer $S_level) Avar(varlist numeric) Bvar(varlist numeric) Pvar(varlist numeric) Qvar(varlist numeric) /*
 */ replace double Gini(varlist max=1 numeric) sva(varlist max=1 numeric) svb(varlist max=1 numeric) svp(varlist max=1 numeric) svq(varlist max=1 numeric) *]
local title "Gen. Beta (Type 2) dist. for grouped data"
local n "`varlist'"
if "`z1'"=="" loc z1 "z1"
if "`z2'"=="" loc z2 "z2"
marksample touse 
qui count if `touse' 
 if r(N) == 0 {
 error 2000 
}
sort `touse' `z2'
cap assert `z2'<. if _n<_N & `touse'
if _rc {
 di as err "Only the rightmost boundary may be missing, signifying infinity"
 exit 198
 }
foreach v in `z1' `z2' {
 conf numeric var `v'
 su `v' if `touse', meanonly
 if r(min)<0 {
  di as err "No boundary may be negative"
  exit 198
  }
 }
sort `touse' `z1' `z2'
cap assert `z1'[_n+1]==`z2' if `touse'
if _rc {
 di as err "Right boundary of each category should equal left boundary of next category"
 exit 198
 }
foreach varsave in gini sva svb svp svq {
 if "``varsave''" != "" {
  cap confirm new variable `varsave' 
  if _rc & "`replace'"=="" exit _rc
  else {
   cap g `double' ``varsave''=.
   if _rc {
      di as err "Problem generating variable `varsave'"
      exit _rc
      }
   }
 }
}
if "`from'" != ""  {
 local b0 "`from'"
}
if "`level'" != "" {
 local level "level(`level')"
}
mlopts mlopts, `options'
local log = cond("`log'" == "","noi","qui")
local wtype `weight'
local wtexp `"`exp'"'
if "`weight'" != "" loc wgt `"[`weight'`exp']"'  
global S_mln "`n'"
global S_mlz1 "`z1'"
global S_mlz2 "`z2'"
`cap' `log' ml model lf gbgfit_ll (a: `avar') (b: `bvar')  (p: `pvar') (q: `qvar') 	///
	`wgt' if `touse' , maximize noscvars	 				///
	collinear title(`title') `robust' `svy' init(`b0') 	///
	search(on) `clopt' `level' `mlopts' `stdopts' `modopts' 
eret local cmd "dagfit"
eret local depvar "`n'"
tempname e
cap mat `e' = e(b)
tempname ba bb bp bq
cap mat `ba' = `e'[1,"a:"] 
cap mat `bb' = `e'[1,"b:"]
cap mat `bp' = `e'[1,"p:"]
cap mat `bq' = `e'[1,"q:"]
cap local a = `ba'[1,1]
cap local b = `bb'[1,1]
cap local p = `bp'[1,1]
cap local q = `bq'[1,1]
cap eret matrix b_a = `ba'
cap eret matrix b_b = `bb'
cap eret matrix b_p = `bp'
cap eret matrix b_q = `bq'
cap eret scalar ba=`a' 
cap eret scalar bb=`b' 
cap eret scalar bp=`p' 
cap eret scalar bq=`q' 
cap eret scalar mean = `b'*exp(lngamma(`p'+1/`a'))*exp(lngamma(`q'-1/`a'))/( exp(lngamma(`p'))*exp(lngamma(`q'))) 
cap eret scalar mode = cond(`a'*`p'>1,`b'*(((`a'*`p'-1)/(`a'*`q'+1))^(1/`a')),0,.)
cap eret scalar var = `b'*`b'*exp(lngamma(1+2/`a'))*exp(lngamma(`q'-2/`a'))/( exp(lngamma(`p'))*exp(lngamma(`q')) )-(`e(mean)'*`e(mean)')
cap eret scalar sd = sqrt(`e(var)')
cap eret scalar i2 = .5*`e(var)'/(`e(mean)')^2
eret local gini = "Gini coef. is function of generalized hypergeometric 3F2 function; see help file"
local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
forv x=1/99 {	
 local ib = invibeta(`p',`q',`x'/100)
 cap eret scalar p`x' =  `b'* (`ib'/(1-`ib'))^(1/`a') 
 cap eret scalar Lp`x' = ibeta(`p'+1/`a',`q'-1/`a',(`e(p`x')'/`b')^`a'/(1+(`e(p`x')'/`b')^`a') )
}
if e(converged)==1 {
 Display, `level' `pfrac'  `diopts'
 foreach varsave in gini a b p q {
  loc var=cond( length("`varsave'")==1, "`sv`varsave''","``varsave''")
  cap if "``varsave''"!="" replace `var'=`e(`varsave')' if `touse'
  }
}
end
program define Display
	syntax [,Level(int $S_level) *]
	local diopts "`options'"
	ml display, level(`level') `diopts'
	if `level' < 10 | `level' > 99 {
		local level = 95
		}
	di as txt  "I2 (GE2)" _col(12) as res %9.5f `e(i2)' _col(30) "Gini coeff not calculated (see help file)"
end
exit


