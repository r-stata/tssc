program define mcd, eclass
version 10.0
 
* MCD
* By Vincenzo Verardi FNRS-FUNDP

syntax varlist(min=1 numeric) [if] [in] , [e(real 0.2) proba(real 0.99) trim(real 0.5) OUTlier BESTsample raw setseed(numlist max=1)]

tempvar rand touse dist2 mah_dist hat y nobs res ord ww finsamp first
tempname v tcand n dist2 bestdet eps maxit

mark `touse' `if' `in'
markout `touse' `varlist' `dummies'
qui count if `touse'
local nobs=r(N)
qui gen `ord'=_n
_rmcoll `varlist' if `touse'
local varlist `r(varlist)'

if "`trim'"!="" {
      if `trim'>0.5|`trim'<0 {
      display in r "Trimming must be between 0 and 0.5" 
      exit
      }

}

local nvar: word count `varlist'
local nvar1=`nvar'+1

if `nvar'==1 {
qui sum `varlist', detail
gen `first'=abs((`varlist'-r(p50))/(r(p75)-r(p25)))
gsort -`first'
local first=int((r(N)*`trim'))+1

qui sum `varlist' in `first'/l
gen `finsamp'=0
replace `finsamp'=1 in `first'/l
gen `mah_dist'=(`varlist'-r(mean))/r(sd)
matrix covMCD=r(sd)^2
matrix locationMCD=r(mean)

capture drop Robust_distance 
gen Robust_distance=sqrt(`mah_dist'^2)
capture drop MCD_outlier
gen MCD_outlier=Robust_distance>2.25

qui sum `varlist' if MCD_outlier==0
matrix covRMCD=r(sd)^2
matrix locationRMCD=r(mean)

if "`outlier'"=="" {
drop MCD_outlier Robust_distance
}
}

else{

gen `finsamp'=0
local ivs `varlist'

if "`e'"!="" {
      if `e'>0.5|`e'<0 {
      display in r "e must be between 0 and 0.5"
      exit
      }

}

if "`proba'"!="" {
      if `proba'<0|`proba'>0.9999 {
      display in r "The probabilit must be between 0 and 0.9999"
      exit
      }

}


local h=ceil(`trim'*`nobs')


else {
local h=ceil((`nobs'+`nvar1')/2)
}

qui matrix accum Cov = `varlist' if `touse', deviations noconstant
qui matrix Cov = Cov/(r(N)-1)
qui gen `tcand'=abs(det(Cov))
qui gen `y'=invnorm(uniform()) if `touse'
qui gen `dist2'=0
qui gen `mah_dist'=0
scalar `bestdet'=abs(det(Cov))
scalar `maxit'=200
scalar `eps'=1e-12
capture drop `rand'
capture qui gen `rand'=0

local reps=max(ceil((log(1-`proba'))/(log(1-(1-`e')^(`nvar1')))),20)

      if `reps'>2000 {
      display in red "!!! The number of subsamples to check is " `reps' " it can take quite some time. Try changing 'e' or 'proba' in the options"
      }

      else {
      display in white "The number of subsamples to check is "`reps'
      }


forvalues i=1(1)`reps' {

      local err=1e+12

	if "`setseed'"!="" {
	qui local counter=`setseed'*`reps'-ceil(log(`reps'))
	set seed `counter'
	}

      capture qui replace `rand'=uniform()

      qui gsort -`touse' `rand'
	qui _rmcoll `varlist' if `touse'
	qui matrix accum Cov = `r(varlist)' in 1/`nvar1', deviations noconstant
      qui matrix Cov = Cov/(r(N)-1)
      qui local det0=det(Cov)


            if `det0'==0  {
                  local det 1 
                  while `det'>0 {
                  local nvar1=`nvar1'+1
                  matrix accum Cov = `varlist'* in 1/`nvar1', deviations noconstant
                  matrix Cov = Cov/(r(N)-1)
                  scalar `det0'=det(Cov)
                  local det=(`det0'==0)
                  }
            }


                  qui reg `y' `varlist' in 1/`nvar1'
                  capture drop `hat'
                  capture qui predict `hat' if `touse', hat
                  capture drop `dist2'
                  capture qui gen `dist2'=(`nvar1'-1)*(`hat'-(1/`nvar1')) if `touse'&`hat'!=.
                  gsort -`touse' `dist2' 

                  local k 1
                  while `k'<=2 {
                  qui reg `y' `varlist' if `touse' in 1/`h'
                  capture drop `hat'
                  capture qui predict `hat' if `touse', hat
                  capture drop `dist2'
                  capture qui gen `dist2'=(`h'-1)*(`hat'-(1/`h')) if `touse'&`hat'!=.
                  gsort -`touse' `dist2' 
                  qui matrix accum Cov =`varlist' in 1/`h', deviations noconstant
                  qui matrix Cov = Cov/(r(N)-1)
                  qui local det=abs(det(Cov))
                  local k=`k'+1
                  }
   

                  sort `tcand'

                  if `det'<`tcand' in 10 {
                  capture qui replace `tcand'=`det' in 10

                  local k 1
                  while `k'<=`maxit'&`err'>`eps' {   
                  gsort -`touse' `dist2' 
                  qui reg `y' `varlist' in 1/`h'
                  capture drop `hat'
                  capture qui predict `hat' if `touse', hat
                  capture drop `dist2'
                  capture qui gen `dist2'=(`h'-1)*(`hat'-(1/`h')) if `touse'&`hat'!=.
                  sort `dist2'
                  qui matrix accum Cov =`varlist' in 1/`h', deviations noconstant
                  qui matrix Cov = Cov/(r(N)-1)
                  qui local det2=det(Cov)
                  local err=abs(`det2'/`det')-1
                  local det=`det2'
                  local k=`k'+1
                  }

                  if abs(`det')<abs(`bestdet'){
                  scalar `bestdet'=abs(`det')
                  capture qui replace `mah_dist'=`dist2'
                  matrix Covfull=Cov
                  capture qui replace `finsamp'=0
                  capture qui replace `finsamp'=1 in 1/`h'
            }
            }
sort `ord'
}

capture qui centile(`mah_dist')
local par=r(c_1)/invchi2(`nvar',0.5)
matrix covMCD=`par'*Covfull
capture qui replace `mah_dist'=`mah_dist'/`par' if `touse'
capture drop Robust_distance 
capture qui gen Robust_distance=`mah_dist' if `touse'
qui matrix accum Cov =`varlist' if `finsamp'==1, deviations noconstant mean(locationMCD)



gen `ww'=(Robust_distance<invchi2(`nvar'-1,0.975))

capture qui reg `y' `varlist' if `ww'==1
capture drop `hat'
qui predict `hat', hat
capture drop `dist2'
qui gen `dist2'=(e(N)-1)*(`hat'-(1/e(N)))

qui sum `ww'
local NN=r(sum)

qui matrix accum Cov =`varlist' if `ww'==1, deviations noconstant mean(locationRMCD)
qui matrix covRMCD = 0.975/chi2(`nvar'+2,invchi2(`nvar',0.975))*Cov/(`NN'-1)


qui capture drop MCD_outlier 
qui capture drop Robust_distance

if "`outlier'"!="" {
qui gen Robust_distance=`dist2'

qui gen MCD_outlier=(Robust_distance>invchi2(`nvar'-1,0.975)) if `touse'& Robust_distance!=.
qui replace Robust_distance=sqrt(Robust_distance)
}
}
if "`bestsample'"!="" {
qui capture drop MCD_sample
qui gen MCD_sample=`finsamp'
}

if "`raw'"!="" {
matrix drop covRMCD
matrix drop locationRMCD

}
else {
matrix drop covMCD
matrix drop locationMCD

}

sort `ord'

if `nvar'>1 {
matrix drop Cov Covfull
}


ereturn clear

end


