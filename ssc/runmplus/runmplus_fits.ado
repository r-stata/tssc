capture program drop runmplus_fits
program define runmplus_fits , eclass
version 10.0
syntax [anything] [ , REPlace ESTimate(string) se(string) fitmat(string) ]

if "`estimate'"~="" {
   mat _B = r(estimate)
}

if "`se'"~="" {
   mat _S = r(se)
}


if "`fitmat'"=="" {
   capture confirm mat e(fits)
   if _rc~=0 {
      di in green "matrix e(fits) not found"
   }
   if _rc==0 {
      mat fits = e(fits)
   }
}

if "`fitmat'"~="" {
   mat fits = `fitmat'
}

if "`replace'"=="replace" {
   capture drop matrix fits
   capture drop matrix e(fits)
   capture drop matrix fit
   local new=1
}


if "`anything'"=="" {
   local fitp = "Loglikelihood Loglikelihood_cf free_parameters aBIC "
}
if "`anything'"~="" {
   local fitp = "`anything'"
}

local C : word count `fitp'

capture mat drop fit
mat define fit  = J(1,`C',.)
matrix colnames fit = `fitp'

capture confirm mat fits
if _rc~=0 {
   mat define fits  = J(1,`C',.)
   matrix colnames fits = `fitp'
   local new=1
}


local i=0
foreach p in `fitp' {
   if "`r(`p')'"~="" {
      local p`++i' = `r(`p')'
   }
   else {
      local p`++i' = .
   }
   mat fit[1,`i']=`p`i''
}

if "`estimate'"~="" {
   local K : word count `estimate'
   mat define estimates = J(1,`K',.)
   mat colnames estimates = `estimate'
   local k=0
   foreach e in `estimate' {
      mat s =  _B["`e'",1]
      local s`++k' = s[1,1]
      mat estimates[1,`k']=`s`k''
      mat drop s
  }
  mat fit = fit , estimates
}

foreach x in `se' {
	local ses "`ses' se_`x'"
}

noisily di "`ses'"

if "`se'"~="" {
   local K : word count `se'
   mat define ses = J(1,`K',.)
   mat colnames ses = `ses'
   local k=0
   foreach e in `se' {
      mat s =  _S["`e'",1]
      local s`++k' = s[1,1]
      mat ses[1,`k']=`s`k''
      mat drop s
  }
  mat fit = fit , ses
}


if "`new'"=="1" {
   mat fits = fit
}
if "`new'"~="1" {
	
	mat list fits
	
	mat list fit
	
   mat fits = fits \ fit
}

ereturn matrix fits=fits

end



   
