*! rd 2.9: package to implement regression discontinuity design
*! author Austin Nichols <austinnichols@gmail.com>
* rd 2.9  30sep2016 fix undocumented bingraph option; use ineq implied by strineq and only graph 1 obs per bin
* rd 2.8  9may2012 add check on OB calc failure e.g. r(2000) and divide Z by 10 until no failure
* rd 2.7  14dec2011 add -mbnum- option to allow numlist of actual numeric values for bandwidths rather than multiples of default bandwidth
* rd 2.6  12sep2011 fixed ddens option
* rd 2.5  7sep2011 double reported bandwidth of rec kernel to match IK, add -covcoefdiff- option to not constrain covar() vars to have same coefs on either side of Z0
* rd 2.4  11jun2011 fixed strineq option, added rec kernel, added weights to new estim proc, and added cluster() and covar() options
* rd 2.3  7jun2011 added e(w) for compatibility with rd_obs output (and help file)
* rd 2.2  24may2011 added option strineq to assume X_T==1 iff Z>0
* rd 2.1  23may2011 switched back to X==1 iff Z>=0
* rd 2.0  20mar2011 shifted to weighted linear regression, -suest-, and IV instead of -lpoly- by default
* rd moved to rd_obs (mar 2011) to reflect shift in estimation strategy
* OB calc now (nov 2010) based on rdob.ado from http://www.economics.harvard.edu/faculty/imbens/software_imbens
* rd 1.0.6  15oct2010 fixed bug where n+2 exceeds N in z grid
* rd 1.0.5  25aug2010 fixed bug in noSCatter option
* rd 1.0.4  17dec2009 added Imbens and Kalyanaraman approach to bw calc as default; http://www.nber.org/papers/w14726
* rd 1.0.3  15nov2007 fixed bug in graph command, made ddens optionally off
* rd 1.0.2  5nov2007 first public release
prog rd, eclass
loc version "2.9  30sep2016" 
if replay() eret di
else {
loc vmult 1
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
syntax varlist(min=2 max=3) [if] [in] [aw fw pw/] [, s(string) Mult(real 1) GENerate(str) at(str) FORCElinear CLuster(varlist) /*
 */ n(integer 0) GRaph BINgraph binvar(varlist max=1) noSCatter Width(real 0) BWidth(real 0) Kernel(str) COVar(varlist numeric) /*
 */ defbw Degree(integer 1) mbw(numlist >0 integer) z0(real 0) lwald NOIsily SUPPresse format(string) STRineq COVCoefdiff /*
 */ Placebo DDens Tdisc x(varlist numeric) SCOpt(str) LINEopt(str) bdep bdopt(string) rcapopt(string) OXline level(real 95) MBNum(numlist >=0) *]
marksample touse
if !inrange(`level'*100,1,9999)|(mod(`level'*100,1)!=0) loc level 95
if `"`format'"'=="" loc format %4.3g 
conf format `format'
* fix "above condition" and "below condition" depending whether strict ineq assumed or not
if "`strineq'"=="" {
  loc abc ">=0"
  loc bec "<0"
  }
else              {
  loc abc ">0"
  loc bec "<=0"
  }
tempname beta
if "`bingraph'"!="" loc graph "graph"
if "`graph'"!="" {
 cap `lpoly'
 * any Stata that does not recognize -lpoly- for graphing must download -locpoly-
 if _rc==199 {
  cap net from http://www.stata-journal.com/software/sj6-4
  net inst st0053_3
  }
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
if "`kernel'"=="" loc kernel="triangle (default)"
if strpos("`kernel'","tri")==0&strpos("`kernel'","rec")==0  {
 di as res "rd" as err " allows only " as res "tri" as err "angle or " as res "rec" as err "tangle kernels; use " as res "rd_obs " as err "for old options."
 error 198
 }
if strpos("`kernel'","rec")>0  loc k: subinstr loc k "tri" "rec"
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
if "`exp'"=="" loc exp 1
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
loc was3="`3'"
tempvar 3
qui g double `3'=(`was3'-`z0')
qui compress `3'
la var `3' "`: var lab `was3''"
loc w=0
if `bwidth'!=0 loc w=`bwidth'
else if `width'!=0 loc w=`width'
 loc divide 1
if `w'==0 & "`mbnum'"=="" {
 loc obfail 1
 loc divide 1
 while `obfail'==1 {
  qui {
   loc obfail 0
   tempvar Y1 Y2 temp1 temp2 temp3 temp4
   qui su `3' if `touse' `wt', d
   loc Sx = r(sd)
   loc N = r(N)
   loc h1 = 1.84*`Sx'*(`N'^(-1/5))
   qui su `1' if -`h1'<=`3' & `3'`bec' & `touse' `wt', meanonly
   loc Yh1n = r(mean)
   loc Nh1n = r(N)
   qui su `1' if `3'`abc' & `3'<=`h1' & `touse' `wt', meanonly
   loc Yh1p = r(mean)
   loc Nh1p = r(N)
   loc fxc = (`Nh1p'+`Nh1n')/(2*`N'*`h1')
   g double `Y1' =(`1'-`Yh1n')^2
   su `Y1' if -`h1'<=`3' & `3'`bec' & `touse' `wt', meanonly
   loc Y1sum =r(sum)
   g double `Y2' =(`1'-`Yh1p')^2
   su `Y2' if `3'`abc' & `3'<=`h1' & `touse' `wt', meanonly
   loc Y2sum=r(sum)
   loc sigma2c=(`Y1sum'+`Y2sum')/(`Nh1p'+`Nh1n')
   su `3' if `3'`abc'  & `touse' `wt', d
   scalar medXp = r(p50)
   loc Np=r(N)
   su `3' if `3'`bec'   & `touse' `wt', d
   scalar medXn = r(p50)
   loc Nn=r(N)
   g byte `temp1'=(`3'`abc') if !mi(`3')
   g double `temp2'=`3'
   g double `temp3'=`3'^2
   g double `temp4'=`3'^3
   regress `1' `temp1' `temp2' `temp3' `temp4' if `3' >= scalar(medXn) & `3' <= scalar(medXp) & `touse' `wt'
   loc m3c=6*_b[`temp4']
   loc h2p=3.56*((`sigma2c'/(`fxc'*max((`m3c')^2, 0.01)))^(1/7))*(`Np'^(-1/7))
   loc h2n=3.56*((`sigma2c'/(`fxc'*max((`m3c')^2, 0.01)))^(1/7))*(`Nn'^(-1/7))
   regress `1' `temp2' `temp3' if 0<=`3' & `3'<=`h2p'  & `touse' `wt'
   loc m2pc=2*_b[`temp3']
   loc N2p=e(N)
   regress `1' `temp2' `temp3' if -`h2n'<=`3' & `3'`bec'  & `touse' `wt'
   loc m2nc=2*_b[`temp3']
   loc N2n=e(N)
   loc rp=(720*`sigma2c')/(`N2p'*((`h2p')^4))
   loc rn=(720*`sigma2c')/(`N2n'*((`h2n')^4))
   if strpos("`k'","rec")>0 loc CK = 5.4/2
   else loc CK = 3.4375
   loc w= `CK'*(((2*`sigma2c')/(`fxc'*(((`m2pc'-`m2nc')^2)+(`rp'+`rn'))))^(1/5))*`N'^(-1/5)
   loc w100=`mult'*`w'
   loc repw = cond(strpos("`k'","rec")>0, `w100'*2, `w100')
   }
  if `obfail'==1 {
   qui replace `3'=`3'/10
   loc divide=`divide'*10
   }
  }
 }
su `3' if `touse', meanonly
loc minz=r(min)
loc maxz=r(max)
if `minz'>0 | `maxz'<0 {
 di as err _n "Assignment variable Z should have cutoff at `z0'"
 di as err "But range of assignment variable Z does not include `z0':"
 if `z0'!=0 su `was3' if `touse'
 else       su `3'    if `touse'
 error 198
 }
 if "`mbw'"=="" & "`mbnum'"=="" loc mbw "100 50 200"
 else if "`mbnum'"=="" {
  loc j100 "100"
  loc mbw: list uniq mbw
  loc mbw: list mbw - j100
  loc mbw "100 `mbw'"
  } 
 if "`mbw'"=="" & "`mbnum'"!="" {
  gettoken w mbnum: mbnum
  loc mbw 100
  foreach v in `mbnum' {
   loc mbw "`mbw' `=round(`v'/`w'*100)'"
   }
  loc w100=`mult'*`w'
  loc w=`mult'*`w'
  }
if "`cluster'"!="" {
 tempvar clustv
 egen `clustv'=group(`cluster')
 loc clv cluster(`clustv')
 }
if "`w100'"=="" loc w100=`mult'*`w'
if "`graph'"!="" {
 di as res "Command used for graph: " as txt "`lpoly'" as res "; Kernel used: " as txt "`kernel'"
 if `n'==0 {
  * calculate steps for 50 pts on the right
  loc step=(`maxz')/50
  if floor(-(`minz')/(`maxz'/50))>3 loc N=50+floor(-(`minz')/(`maxz'/50))
  else loc N=54
  cap set obs `N'
  qui replace `touse'=0 if mi(`touse')
  loc n=50
  }
 else {
  * calculate steps for `n' pts 
  loc step=(`maxz'-`minz')/(`n'-1)
  cap set obs `n'
  loc N=`n'
  * reset `n' to n pts on the right 
  loc n=floor(`maxz'/`step')
  }
 if `w'==0 & "`defbw'"=="" {
  sort `3'
  g `close'=sum(`touse'*(`3'>0))
  qui g long `obs'=_n if `touse'
  su `obs' if `close'>0, meanonly
  loc ub=`3'[`=r(min)+30']
  loc lb=`3'[`=r(min)-30']
  loc w=max(`ub',abs(`lb'))
  qui count if (`3'`abc' & `3'<`step'*2) & `touse'
  if r(N)>40 loc w=`step'*2
  qui count if (`3'`bec' & `3'>-`step'*2) & `touse'
  if r(N)>40 loc w=`step'*2
  }
 if "`w100'"=="" loc w100=`mult'*`w'
 qui {
  g `z'=(_n-1)*`step' in 1/`=`n'+1'
  replace `z'=-(_n-`=`n'+1')*`step' in `=`n'+2'/`N'
  }
 la var `z' "Assignment variable relative to cutoff"
 if "`binvar'"=="" loc binvar="`z'"
 loc opt "at(`z') nogr `k' deg(`degree') `options'"
 if "`defbw'"!="" {
   `lpoly' `1' `3' `wt' if `touse', gen(`f0') `opt'
   loc w100=`mult'*r(width)
   }
 foreach i of loc mbw {
  loc lw=`i'/100*`w100'
  if "`i'"=="100" loc i
  tempvar i`i'f0 i`i'f1 i`i'g0 i`i'g1
  loc b="`bw'(`lw')"
  loc opt "at(`z') nogr `k' `b' deg(`degree') `options'"
  qui {
  if "`ddens'"!="" {
   tempvar df0 df1
   kdensity `3' if `3'`abc' & `touse' `wt', at(`z') nogr `k' `b' gen(`df1')
   replace `df1'=. if `z'<0
   kdensity `3' if `3'`bec' & `touse' `wt', at(`z') nogr `k' `b' gen(`df0')
   replace `df0'=. if `z'>0
   su `touse' if `3'`abc'  `wt'
   loc sumw1=r(sum_w)
   su `touse' if `3'`bec'  `wt'
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
     `lpoly' `lhs' `3' `wt' if `3'`bec' & `touse', gen(`i`i'f0') `opt'
     replace `i`i'f0'=. if `z'>0
     `lpoly' `lhs' `3' `wt' if `3'`abc' & `touse', gen(`i`i'f1') `opt'
     replace `i`i'f1'=. if `z'<0
     loc numerat=(`i`i'f1'[1]-`i`i'f0'[1])*`divide'
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
        tempvar only1perbin
        bys `binvar' (`3'): g byte `only1perbin'=_n==ceil(_N/2)
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
         su `lhs' `wt' if `3'`abc'`lastbin' & `3'`bec'`nextbin' &`touse'
         replace `y'=r(mean) if `3'`abc'`lastbin' & `3'`bec'`nextbin' &`touse'&`only1perbin'
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
     `lpoly' `2' `3' `wt' if `3'`bec' & `touse', gen(`i`i'g0') `opt'
     replace `i`i'g0'=. if `z'>0
     `lpoly' `2' `3' `wt' if `3'`abc' & `touse', gen(`i`i'g1') `opt'
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
         su `2' `wt' if `3'`abc'`lastbin' & `3'`bec'`nextbin' &`touse'
         replace `y'=r(mean) if `3'`abc'`lastbin' & `3'`bec'`nextbin' &`touse'&`only1perbin'
        }
       }
       else loc y="`2'"
       loc sp "sc `y' `3' if `touse', mc(gs14) `scopt' ||"
       }
      tw `sp' line `i`i'g0' `i`i'g1' `z', lw(thick thick) lp(l -) leg(off) ti("`:var la `2''" "Bandwidth `lw'") name(`2'`i', replace) `lineopt'
     }
    loc denomin=(`i`i'g1'[1]-`i`i'g0'[1])*`divide'
    if "`s'"!=""  {
      ren `i`i'g0' `s'`i'`2'0
      ren `i`i'g1' `s'`i'`2'1
     }
  }
   else {
     loc denomin=1
     if "`s'"!="" & "`was2'"!="" {
      g byte `i`i'g0'=0 if `z'<=0
      g byte `i`i'g1'=1 if `z'`abc'
      ren `i`i'g0' `s'`i'`was2'0
      ren `i`i'g1' `s'`i'`was2'1
     }
   }
  if "`lwald'"=="" & "`nolwald'"=="" {
*  cap loc rown: rownames `beta'
*  mat `beta'=nullmat(`beta') \ `numerat'
*  mat rownames `beta'= `rown' numer`i'
*  cap loc rown: rownames `beta'
*  mat `beta'=nullmat(`beta') \ `denomin'
*  mat rownames `beta'= `rown' denom`i'
  }
  cap loc rown: rownames `beta'
*  mat `beta'=nullmat(`beta') \ `=`numerat'/`denomin''
*  mat rownames `beta'= `rown' lwald`i'
*  cap loc rown: rownames `beta'
  if "`dd`i''"!="" {
   mat `beta'=nullmat(`beta') \ `dd`i''
   mat rownames `beta'= `rown' ddens`i'
   }
  }
  loc w`i'=`lw'
  if strpos("`k'","rec")>0 loc w`i'=`lw'*2
  di as txt "Bandwidth: " as res `lw' _c
  di as txt "; loc Wald Estimate: " _c
  di as res `numerat'/`denomin'
  }
 if "`s'"!="" ren `z' `s'`3'
 cap compress `s'*
 cap drop if `dropme'
 if "`suppresse'"!="" {
  matrix `beta'=`beta''
  qui count if `touse'
  loc N=r(N)
  tempvar ee
  qui g byte `ee'=`touse'
  eret post `beta', esample(`ee')
  ereturn scalar N = `N'
  }
 else {
*  cap mat drop `beta'
  loc rown
  }
 }
if "`suppresse'"=="" {
 tempname var diag
 tempvar above zbelow zabove 
 g byte `above'=(`3'`abc'0) if `touse'
 g double `zabove'=(`above')*(`3')
 g double `zbelow'=(1-`above')*(`3')
 if "`covcoefdiff'"!="" & "`covar'"!="" {
  foreach v of loc covar {
   tempvar a`v' 
   g double `a`v''=(`above')*(`v')
   g double `b`v''=(1-`above')*(`v')
   loc acovar `acovar' `a`v''
   loc bcovar `bcovar' `b`v''
   }
  }
 if "`covcoefdiff'"=="" & "`covar'"!="" {
  loc acovar `covar' 
  loc bcovar 
  }
 foreach i of loc mbw {
 loc w`i'=`i'/100*`w100'
 if "`i'"=="100" loc i
 noi di as res "Estimating for bandwidth `w`i''"
 tempvar kwt
 if strpos("`k'","rec")==0 g double `kwt'=max(0,`w`i''-abs(`3'))*(`exp')
 else                      g double `kwt'=(`exp')*((-`w`i''<=(`3'))&((`3')<`w`i''))
 * double reported bandwidth for rect kernel to match IK parametrization
 if strpos("`k'","rec")>0 loc w`i'=`w`i''*2
 foreach lhs in `x' `1' {
  qui if !("`lwald'"=="" & "`nolwald'"=="") {
   reg `lhs' `above' `zabove' `zbelow' `acovar' `bcovar' [pw=`kwt'], `clv'
   loc numerat=_b[`above']
   loc var1=_se[`above']^2
   mat `var'=nullmat(`var') \ `var1'
   cap loc rown: rownames `beta'
   mat `beta'=nullmat(`beta') \ `numerat'
   if "`lhs'"=="`1'" mat rownames `beta'= `rown' lwald`i'
   else mat rownames `beta'= `rown' `lhs'`i'
   cap loc rown: rownames `beta'
   }
  qui if "`lwald'"=="" & "`nolwald'"=="" {
   tempname v suv sub rb rv dtmp r1 r2
   mat `rb'=J(1,3,.)
   mat `rv'=J(3,3,0)
   reg `lhs' `above' `zabove' `zbelow' `acovar' `bcovar'  [aw=`kwt']
   est sto `r1'
   reg `2' `above' `zabove' `zbelow' `acovar' `bcovar'  [aw=`kwt']
   su `2' [aw=`kwt'], mean
   loc bad1 0
   if !inrange(_b[`above']+_b[_cons],r(min),r(max))|!inrange(_b[_cons],r(min),r(max)) {
    noi di as err "A predicted value of treatment at cutoff lies outside feasible range;"
    loc bad1=1
    if "`forcelinear'"!="" {
     noi di as err "interpret local Wald estimates with extreme caution."
     }
    else {
     noi di as err "switching to local mean smoothing for treatment discontinuity."
     reg `2' `above' `acovar' `bcovar'  [aw=`kwt']
     }
    }
   est sto `r2'
   suest `r1' `r2', `clv'
   if _se[`above']==0 {
     di as err "using -ivreg- to estimate due to failure of -suest-"
     if `bad1'==0 {
      reg `lhs' `above' `zabove' `zbelow' `acovar' `bcovar'  [pw=`kwt'], `clv'
      mat `rb'[1,1]=_b[`above']
      mat `rv'[1,1]=_se[`above']^2
      reg `2' `above' `zabove' `zbelow' `acovar' `bcovar'  [pw=`kwt'], `clv'
      mat `rb'[1,2]=_b[`above']
      mat `rv'[2,2]=_se[`above']^2
      ivreg `lhs' (`2'=`above') `zabove' `zbelow' `acovar' `bcovar'  [aw=`kwt'], `clv'
      mat `rb'[1,3]=_b[`2']
      mat `rv'[3,3]=_se[`2']^2
      }
     else {
      reg `lhs' `above' `3' `acovar' `bcovar'  [pw=`kwt']
      mat `rb'[1,1]=_b[`above']
      mat `rv'[1,1]=_se[`above']^2
      reg `2' `above' `3' `acovar' `bcovar'  [pw=`kwt']
      mat `rb'[1,2]=_b[`above']
      mat `rv'[2,2]=_se[`above']^2
      ivreg `lhs' (`2'=`above') `3' `acovar' `bcovar'  [pw=`kwt'], `clv'
      mat `rb'[1,3]=_b[`2']
      mat `rv'[3,3]=_se[`2']^2
      }
    }
   else {
    mat `sub'=e(b)
    mat `rb'[1,1]=`sub'[1,"`r1'_mean:`above'"],`sub'[1,"`r2'_mean:`above'"]
    mat `suv'=e(V)
    mat `rv'[1,1]=`suv'["`r1'_mean:`above'","`r1'_mean:`above'"],`suv'["`r1'_mean:`above'","`r2'_mean:`above'"]\ `suv'["`r1'_mean:`above'","`r2'_mean:`above'"],`suv'["`r2'_mean:`above'","`r2'_mean:`above'"]
    nlcom [`r1'_mean]`above'/ [`r2'_mean]`above'
    mat `rb'[1,3]=r(b)
    mat `rv'[3,3]=r(V)
    }
   cap conf mat `diag'
   if _rc==0 {
    loc posit=rowsof(`diag')+1
    loc siz=rowsof(`diag')+rowsof(`rv')
    mat `dtmp'=J(`siz',`siz',0)
    mat `dtmp'[1,1]=`diag'
    mat `dtmp'[`posit',`posit']=`rv'
    mat `diag'=`dtmp'
    }
   else {
    mat `diag'=`rv'
    }
   cap loc rown: rownames `beta'
   mat `beta'=nullmat(`beta') \ `rb''
   if "`lhs'"=="`1'" mat rownames `beta'= `rown' numer`i' denom`i' lwald`i'
   else mat rownames `beta'= `rown' `lhs'numer`i' `lhs'denom`i' `lhs'`i'
   cap loc rown: rownames `beta'
   }
  }
 }
 if !("`lwald'"=="" & "`nolwald'"=="") mat `diag'=diag(`var')
 matrix `beta'=`beta''
 mat rownames `diag'= `rown'
 mat colnames `diag'= `rown'
 mat `diag'=`vmult'*`diag'
 qui count if `touse'
 loc N=r(N)
 eret post `beta' `diag', esample(`touse')
 ereturn scalar N = `N'
 } 
 ereturn loc depvar "`1'"
 ereturn loc cmd "rd"
 ereturn loc version "`version'"
 ereturn loc rdversion "`version'"
 foreach i of loc mbw {
  if "`i'"=="100" ereturn scalar w`i'=`w100' 
  else ereturn scalar w`i'=`w`i''
  }
 cap ereturn scalar w=`w100'
 eret di 
 cap drop if `dropme'
 if "`bdep'"!="" {
  tempvar bwid est lbci ubci
  loc estn 1
  qui {
   g `bwid'=.
   g `est'=.
   g `lbci'=.
   g `ubci'=.
   foreach i of local mbw {
    if "`oxline'"!="" & "`i'"=="100" loc ox "xli(`w100')"
    if "`i'"=="100" loc i
    replace `bwid'=`w`i'' in `estn'
    replace `est'=_b[lwald`i'] in `estn'
    replace `lbci'=_b[lwald`i']-invnormal(1/2-`level'/200)*_se[lwald`i'] in `estn'
    replace `ubci'=_b[lwald`i']+invnormal(1/2-`level'/200)*_se[lwald`i'] in `estn'
    loc xl `"`xl' `w`i'' "`:di `format' `w`i'''" "'
    loc estn=`estn'+1
    }
   tw rcap `lbci' `ubci' `bwid', `rcapopt'||sc `est' `bwid', xla(`xl') leg(lab(1 "CI") lab(2 "Est")) xti(Bandwidth) yti(Estimated effect) `ox' `bdopt'
   }
  }
}
end
