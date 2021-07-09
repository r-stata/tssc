*! rd 1.0.4  7june2011 fixed 'touse' to be nonmissing zero when obs are added to dataset
*! rd 1.0.3  15nov2007
*! author Austin Nichols austinnichols@gmail.com
* rd 1.0.3  15nov2007 fixed bug in graph command, made ddens optionally off
* rd 1.0.2  5nov2007 first public release
prog rd_obs, eclass
loc version "1.0.2 5nov2007" 
if replay() eret di
else {
 loc lpoly "locpoly"
 loc k "tri"
 loc bw "w"
 if (_caller()<10) version 8.2
 else {
  version 10
  loc lpoly "lpoly"
  loc k "k(tri)"
  loc bw "bw"
  }
 syntax varlist(min=2 max=3) [if] [in] [aw fw pw/] [, s(str) Mult(real 1) GENerate(str) at(str) /*
  */ n(integer 0) GRaph BINgraph binvar(varlist max=1) noSCatter Width(real 0) BWidth(real 0) Kernel(str) /*
  */ defbw Degree(integer 1) mbw(numlist >0 integer) z0(real 0) lwald NOIsily /*
  */ Placebo DDens Tdisc x(varlist numeric) SCOpt(str) LINEopt(str) *]
 tempname beta
 cap `lpoly'
 if _rc==199 {
  cap net from http://www.stata-journal.com/software/sj6-4
  net inst st0053_3
  }
 if "`generate'`at'"!="" {
  di as error "Do not specify " as res "generate " as err "or " as res "at " as err "options."
  di as err "Instead use " as res "s(stubname) " as err "syntax to generate new variables."
  error 198
  }
 if `bwidth'!=0 & `width'!=0 {
  di as error "Cannot specify both " as res "width " as err "and " as res "bwidth " as err "options."
  error 198
  }
 if `bwidth'!=0 loc w=`bwidth'
 else loc w=`width'
 if "`kernel'"!="" & "`k'"=="tri" loc k="`kernel'"
 if "`kernel'"!="" & "`k'"=="k(tri)" loc k="k(`kernel')"
 if "`kernel'"=="" loc kernel="triangle (default)"
 marksample touse
 if "`lpoly'"=="locpoly" & "`exp'"!="" {
  preserve
  tempvar wtvar dropme
  qui {
   gsort -`touse'
   g double `wtvar'=`exp'-`exp'[_n-1] if _n>1 & `touse'
   su `wtvar', meanonly
   replace `wtvar'=`exp'/r(min)
   loc N=_N
   expand `wtvar'
   g byte `dropme'=_n>`N'
   }
  }
 else if "`exp'"!="" loc wt="[aw=`exp']"
 tokenize `varlist'
 loc was2="`2'"
 if "`3'"=="" {
  loc nolwald=1
  loc 3="`2'"
  tempvar 2
  qui g byte `2'=(`3'>=`z0')
  loc was2=""
  di as res "Two variables specified; treatment is "
  di as res "assumed to jump from zero to one at Z=`z0'. "
  di as res _n " Assignment variable Z is `3'"
  di as res " Treatment variable X_T unspecified"
  di as res " Outcome variable y is `1'" _n
  }
 else {
  di as res "Three variables specified; jump in treatment  "
  di as res "at Z=`z0' will be estimated. Local Wald Estimate"
  di as res "is the ratio of jump in outcome to jump in treatment."
  di as res _n " Assignment variable Z is `3'"
  di as res " Treatment variable X_T is `2'"
  di as res " Outcome variable y is `1'" _n
  }
 tempvar z obs close
 di as res "Command used: " as txt "`lpoly'" as res "; Kernel used: " as txt "`kernel'"
 loc was3="`3'"
 if `z0'!=0 {
  tempvar 3
  qui g double `3'=(`was3'-`z0')
  qui compress `3'
  }
 su `3' if `touse', meanonly
 if r(min)>0 | r(max)<0 {
  di as err _n "Assignment variable Z should have cutoff at `z0'"
  di as err "But range of assignment variable Z does not include `z0':"
  if `z0'!=0 su `was3' if `touse'
  else       su `3'    if `touse'
  error 198
  }
 if `n'==0 {
  * calculate steps for 50 pts on the right
  loc step=r(max)/50
  local N=50+floor(-r(min)/(r(max)/50))
  cap set obs `N'
  loc n=50
  }
 else {
  * calculate steps for `n' pts 
  loc step=(r(max)-r(min))/(`n'-1)
  cap set obs `n'
  loc N=`n'
  * reset `n' to n pts on the right 
  loc n=floor(r(max)/`step')
  }
 if `w'==0 & "`defbw'"=="" {
  sort `3'
  g `close'=sum(`touse'*(`3'>0))
  qui g long `obs'=_n if `touse'
  su `obs' if `close'>0, meanonly
  loc ub=`3'[`=r(min)+30']
  loc lb=`3'[`=r(min)-30']
  loc w=max(`ub',abs(`lb'))
  qui count if (`3'>=0 & `3'<`step'*2) & `touse'
  if r(N)>40 loc w=`step'*2
  qui count if (`3'<0 & `3'>-`step'*2) & `touse'
  if r(N)>40 loc w=`step'*2
  }
 loc w=`mult'*`w'
 if "`mbw'"=="" loc mbw "100 50 200"
 else {
  loc j100 "100"
  loc mbw: list uniq mbw
  loc mbw: list mbw - j100
  loc mbw "100 `mbw'"
  } 
 qui {
  g `z'=(_n-1)*`step' in 1/`=`n'+1'
  replace `z'=-(_n-`=`n'+1')*`step' in `=`n'+2'/`N'
  }
 la var `z' "Assignment variable relative to cutoff"
 if "`binvar'"=="" loc binvar="`z'"
 local opt "at(`z') nogr `k' deg(`degree') `options'"
 if "`defbw'"!="" {
   `lpoly' `1' `3' `wt' if `touse', gen(`f0') `opt'
   loc w=`mult'*r(width)
   }
foreach i of local mbw {
 loc lw=`i'/100*`w'
 if "`i'"=="100" loc i
 tempvar i`i'f0 i`i'f1 i`i'g0 i`i'g1
 loc b="`bw'(`lw')"
 local opt "at(`z') nogr `k' `b' deg(`degree') `options'"
 qui {
 if "`ddens'"!="" {
  tempvar df0 df1
  kdensity `3' if `3'>=0 & `touse' `wt', at(`z') nogr `k' `b' gen(`df1')
  replace `df1'=. if `z'<0
  kdensity `3' if `3'<0 & `touse' `wt', at(`z') nogr `k' `b' gen(`df0')
  replace `df0'=. if `z'>0
  su `touse' if `3'>=0  `wt'
  loc sumw1=r(sum_w)
  su `touse' if `3'<0  `wt'
  loc sumw0=r(sum_w)
  replace `df1'=`df1'*`sumw1'/(`sumw1'+`sumw0')
  replace `df0'=`df0'*`sumw0'/(`sumw1'+`sumw0')
  loc dd`i'=`df1'[1]-`df0'[1]
 `noisily' di as txt "Bandwidth: " as res `lw' _c
 `noisily' di as txt "; Jump Estimate for Density: " _c
 `noisily' di as res (`df1'[1]-`df0'[1])
    if "`graph'"!="" {
     tempvar kd
     kdensity `3' if `touse' `wt', at(`z') gen(`kd') nogr
     line `kd' `df1' `df0' `z', sort leg(off) name(ddens`i', replace) ti("Jump in Density of Assignment Variable" "Bandwidth=`lw'")
     }
  }
 foreach lhs in `x' `1' {
    `lpoly' `lhs' `3' `wt' if `3'<0 & `touse', gen(`i`i'f0') `opt'
    replace `i`i'f0'=. if `z'>0
    `lpoly' `lhs' `3' `wt' if `3'>=0 & `touse', gen(`i`i'f1') `opt'
    replace `i`i'f1'=. if `z'<0
    local numerat=`i`i'f1'[1]-`i`i'f0'[1]
     `noisily' di as txt "Bandwidth: " as res `lw' _c
     `noisily' di as txt "; Jump Estimate for `lhs': " _c
     `noisily' di as res (`i`i'f1'[1]-`i`i'f0'[1])
    if "`lhs'"!="`1'" {
     cap loc rown: rownames `beta'
     mat `beta'=nullmat(`beta') \ `numerat'
     mat rownames `beta'= `rown' `lhs'`i'
    }
    if "`graph'"!="" {
     if "`scatter'"=="" {
      if "`bingraph'"!="" {
       tempvar y
       g `y'=.
       levelsof `binvar' if `touse', loc(bins)
       loc binT: word count `bins'
       forv bint=1/`binT' {
        loc lastbin
        loc nextbin
        cap loc lastbin: word `=`bint'-1' of `bins'
        if "`lastbin'"=="" loc lastbin=c(mindouble)
        cap loc nextbin: word `=`bint'+1' of `bins'
        if "`nextbin'"=="" loc nextbin=.
        su `lhs' `wt' if `3'>=`lastbin' & `3'<=`nextbin' &`touse'
        replace `y'=r(mean) if `3'>=`lastbin' & `3'<=`nextbin' &`touse'
       }
      }
      else loc y="`lhs'"
      loc sp "sc `y' `3' if `touse', mc(gs14) `scopt' ||"
      }
     tw `sp' line `i`i'f0' `i`i'f1' `z', lw(thick thick) lp(l -) leg(off) ti("`:var la `lhs''" "Bandwidth `lw'") name(`lhs'`i', replace) `lineopt'
    }
    if "`s'"!="" {
       ren `i`i'f0' `s'`i'`lhs'0
       ren `i`i'f1' `s'`i'`lhs'1
    }
    else drop `i`i'f0' `i`i'f1'
 }
 if "`lwald'"=="" & "`nolwald'"=="" {
    `lpoly' `2' `3' `wt' if `3'<0 & `touse', gen(`i`i'g0') `opt'
    replace `i`i'g0'=. if `z'>0
    `lpoly' `2' `3' `wt' if `3'>=0 & `touse', gen(`i`i'g1') `opt'
    replace `i`i'g1'=. if `z'<0
    if "`graph'"!="" {
     if "`scatter'"=="" {
      if "`bingraph'"!="" {
       tempvar y
       g `y'=.
       levelsof `binvar' if `touse', loc(bins)
       loc binT: word count `bins'
       forv bint=1/`binT' {
        loc lastbin
        loc nextbin
        cap loc lastbin: word `=`bint'-1' of `bins'
        if "`lastbin'"=="" loc lastbin=c(mindouble)
        cap loc nextbin: word `=`bint'+1' of `bins'
        if "`nextbin'"=="" loc nextbin=.
        su `2' `wt' if `3'>=`lastbin' & `3'<=`nextbin' &`touse'
        replace `y'=r(mean) if `3'>=`lastbin' & `3'<=`nextbin' &`touse'
       }
      }
      else loc y="`2'"
      loc sp "sc `y' `3' if `touse', mc(gs14) `scopt' ||"
      }
     tw `sp' line `i`i'g0' `i`i'g1' `z', lw(thick thick) lp(l -) leg(off) ti("`:var la `2''" "Bandwidth `lw'") name(`2'`i', replace) `lineopt'
    }
   loc denomin=`i`i'g1'[1]-`i`i'g0'[1]
   if "`s'"!=""  {
     ren `i`i'g0' `s'`i'`2'0
     ren `i`i'g1' `s'`i'`2'1
    }
 }
  else {
    loc denomin=1
    if "`s'"!="" & "`was2'"!="" {
     g byte `i`i'g0'=0 if `z'<=0
     g byte `i`i'g1'=1 if `z'>=0
     ren `i`i'g0' `s'`i'`was2'0
     ren `i`i'g1' `s'`i'`was2'1
    }
  }
 if "`lwald'"=="" & "`nolwald'"=="" {
 cap loc rown: rownames `beta'
 mat `beta'=nullmat(`beta') \ `numerat'
 mat rownames `beta'= `rown' numer`i'
 cap loc rown: rownames `beta'
 mat `beta'=nullmat(`beta') \ `denomin'
 mat rownames `beta'= `rown' denom`i'
 }
 cap loc rown: rownames `beta'
 mat `beta'=nullmat(`beta') \ `=`numerat'/`denomin''
 mat rownames `beta'= `rown' lwald`i'
 cap loc rown: rownames `beta'
 if "`dd`i''"!="" {
  mat `beta'=nullmat(`beta') \ `dd`i''
  mat rownames `beta'= `rown' ddens`i'
  }
 }
 loc w`i'=`lw'
 di as txt "Bandwidth: " as res `lw' _c
 di as txt "; Local Wald Estimate: " _c
 di as res `numerat'/`denomin'
}
 if "`s'"!="" ren `z' `s'`3'
 cap compress `s'*
 cap drop if `dropme'
 matrix `beta'=`beta''
 qui count if `touse'
 qui replace `touse'=0 if mi(`touse')
 eret post `beta', esample(`touse')
 ereturn scalar N = `=r(N)'
 ereturn local depvar "`1'"
 ereturn local cmd "rd"
 ereturn local version "`version'"
 ereturn local rdversion "`version'"
 foreach i of local mbw {
  if "`i'"=="100" loc i
  ereturn scalar w`i'=`w`i''
 }
 cap drop if `dropme'
}
end
