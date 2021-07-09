*!version 1.0 MJB 9 May 2003

cap program drop metannt
program define metannt , rclass
    version 7.0
    syntax [, measure(string) size(string) confint(string) baseline(string)]
*If measure size & confint left unspecified, assume that these are as stored
*from previous metan/meta-analysis in r(ES) etc

if "`measure'`size'`confint'"=="" {
*Get effect size, conf intervals and type of summary measure from metan
	local measure = r(measure)
	local size  = r(ES)
	local conf_l= r(ci_low)
	local conf_u= r(ci_upp)
 }
 else {
*otherwise, user is assumed to have specified them: conf interval needs parsing (and is optional)
	local measure=upper("`measure'")
	if "`confint'"!="" {
		tokenize "`confint'", parse(",")
		local conf_l=`1'
		local conf_u=`3'
	}
}

cap {
	if ("`measure'"=="SMD" | "`measure'"=="WMD" | "`measure'"=="ES")
	di in re "metannt valid only after binary data meta-analysis"
	exit
}
cap {
	assert ("`measure'"=="OR" | "`measure'"=="RR" | "`measure'"=="RD")
	assert `size'>-1	
	assert `size'>0 if ("`measure'"=="OR" |"`measure'"=="RR") 
	assert `size'<1 if "`measure'"=="RD" 
	assert `size'!=.
}
if _rc!=0 {
	di in re "Specify a valid measure AND effect size using measure( ) and size( ) options," 
	di in re " or use last estimates from metan"
	exit
}

if "`conf_l'"!="" {
	cap {
		assert `conf_l'>=-1
		assert `conf_l'>0 if "`measure'"!="RD"
		assert `conf_u'<=1 if "`measure'"=="RD"
		assert `size'>`conf_l'
		assert `size'<`conf_u'
	}
	if _rc!=0 {
		di in re "Invalid confidence interval"
		exit
	}
}
if "`baseline'"=="" {
	local baseline =r(cger) 
	local note2 "**"  /* to reinforce estimation of CGER from data */
}

if ( (`size'>0 & "`measure'"=="RD") | (`size'>1 & "`measure'"!="RD") ) {
	local directn "excess"
	local nntstub "H"
 }
 else         { 
	local directn "avoided" 
	local nntstub "B"
}
if "`conf_l'"!="" { 
	local ci "(CI)" 
	local cont "_cont"
}
di _n in gr " Control group | Treatment group |" _col(43) "|  No. of `directn' " 
di    in gr "  event rate   |   event rate *" _col(34) "|  NNT`nntstub'* | events per 1000 `ci'*"  
di    in gr _dup(15) "-" "+"  _dup(17) "-" "+" _dup(8) "-" "+" _dup(26) "-"


*error check
local flag=0 


parse "`baseline'", parse(",")
while "`1'"!="" {
  local cger=`1'
*calculate tger then NNT / events from d-a 
  if "`measure'"=="RD" {
	local tger=`cger'+`size'
	if "`ci'"!="" {
		local tger_ll = `cger'+`conf_l'
		local tger_ul = `cger'+`conf_u'
	}
  }

  if "`measure'"=="RR" {
	local tger=(`cger'*`size')
	if "`ci'"!="" {
		local tger_ll =(`cger'*`conf_l')
		local tger_ul =(`cger'*`conf_u')
	}
  }

  if "`measure'"=="OR" {
	local tger=(`size'*`cger')/(1-`cger'+`cger'*`size')
	if "`ci'"!="" {
		local tger_ll =(`conf_l'*`cger')/(1-`cger'+`cger'*`conf_l')
		local tger_ul =(`conf_u'*`cger')/(1-`cger'+`cger'*`conf_u')
	}
  }
  if (`tger'>=0 & `tger'<=1 & `cger'>=0 & `cger'<=1) {

	local nnt = abs(1/(`cger'-`tger'))
	local np1000=abs(1000*(`cger'-`tger'))
	if "`ci'"!="" {
*direction is important for CI
		if `cger'>`tger' {
*events avoided: CI goes from (cg-max_tg to cg-min_tg)
			local np1k_ll =(1000*(`cger'-`tger_ul'))
			local np1k_ul =(1000*(`cger'-`tger_ll'))
		 }
		 else {
*events excess: CI goes from (tg_min-cg to tg_max-cg)
			local np1k_ll =(1000*(`tger_ll'-`cger'))
			local np1k_ul =(1000*(`tger_ul'-`cger'))
		}
	}

   }
   else {
	local flag=10
	local nnt =.
	local np1000 =.
  }

  di in ye _col(5) %6.3f `cger' " `note2'"  _col(23) %6.3f `tger' _col(35) %6.1f `nnt' /*
*/ _col(48) %5.1f `np1000' `cont'

	if "`ci'"!="" {
		di in ye "  (" %5.1f `np1k_ll' " , "  %5.1f `np1k_ul' ")
		local tger_ll = `cger'+`conf_u'
	}



  mac shift 2
}

if `flag'>1 { di in bl "Note some baseline/event rate combinations are invalid"}
di _n in bl "*  based on `measure'=" %5.3f `size' " applied to the control group event rate(s)"
if "`note2'"=="**" {
	di in bl "** based on an assumed average control group event rate of `cger'"

return scalar cger= `cger'
return scalar tger= `tger'
return scalar nnt= `nnt'
return scalar ep1000= `np1000'

end

