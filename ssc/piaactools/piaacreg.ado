* version 4.3, DEC2013
* Artur Pokropek & Maciej Jakubowski
* regression with PIAAC data

cap program drop piaacreg
program define piaacreg, rclass

syntax [varlist(default=none)] [if] [in] ///
, save(string) [ weight(varlist max=1) rep(varlist) ///
countryid(varname) vemethodn(varname numeric) pvdep(string) pvindep1(string) pvindep2(string) pvindep3(string) ///
over(string) fast round(integer 2) cmd(string) cmdops(string) r2(string) cons or] 

version 10.0

tempvar probka cntid jkvar proflevel1
tempname b se over_values 

local oldover="`over'"
local longlist=0

local overpv=0
if "`over'"=="pvlit" | "`over'"=="pvnum" | "`over'"=="PVLIT" | "`over'"=="PVNUM" {
		qui recode `over'1 (.=.) (0/175.9999=0) (176/225.9999=1) (226/275.9999=2) (276/325.9999=3) (326/375.9999=4) (376/999=5), gen(`proflevel1')
	local overpv=1
	local over="`proflevel1'"
	}
	else if "`over'"=="pvpsl" | "`over'"=="PVPLS"  {
		qui recode pvpsl1 (.=.) (0/240.9999=0) (241/290.9999=1) (291/340.9999=2) (341/999=3), gen(`proflevel1')
		local overpv=1
		local over="`proflevel1'"
		}


if "`cmd'"=="" local cmd="reg"
if "`r2'"=="" {
	if "`cmd'"=="reg" local r2="r2"
	else if "`cmd'"=="logit" | "`cmd'"=="logistic" | "`cmd'"=="poisson" | "`cmd'"=="ologit" local r2="r2_p"
	}
	
if "`pvdep'"=="" {
	tokenize `varlist'
	local outcome `1'
	macro shift
	local varlist `*'
	local pv=0
	}
else {
	local outcome `pvdep'1
	local pv=1	
	}
	
if "`cmd'"=="logit" | "`cmd'"=="logistic" {
	sum `outcome', meanonly
	if r(min)!=0 | r(mean)<=0 {
		di as error "outcome has to vary and contain 0 and positive values only"
		}
	}
	
if "`cmd'"=="poisson" {
	sum `outcome', meanonly
	if r(mean)<=0 {
		di as error "outcome has to vary and contain nonnegative values only"
		}
	}
	
if "`pvindep1'"!="" | "`pvindep2'"!="" | "`pvindep3'"!=""  | `overpv'!=0 local pv=1

if "`countryid'"!="" {
	capture confirm string variable `countryid'
	if !_rc {
		qui gen `cntid'=`countryid'
		qui levelsof `cntid' `if' `in', local(cnt)
		}
	else {
		qui tostring(`countryid'), gen(`cntid')
		qui levelsof `cntid' `if' `in', local(cnt)
		}
	}
else {		
  cap confirm variable cntryid
  if !_rc {
	qui tostring(cntryid), gen(`cntid')
	qui local cnt="36 40 124 203 208 233 246 250 276 372 380 392 410 528 578 616 703 724 752 840 SUB 56 826 OECD 196 643"
	local longlist=1
	}
  else {
	cap confirm variable CNTRYID
	if !_rc {
		qui tostring(CNTRYID), gen(`cntid')
		qui local cnt="36 40 124 203 208 233 246 250 276 372 380 392 410 528 578 616 703 724 752 840 SUB 56 826 OECD 196 643"
		local longlist=1
		}
	else {
		di as error "Your dataset does not contain variable cntryid or CNTRYID. Please specify option countryid()"
		exit 100
		}
	}
}

if "`weight'"=="" {
	cap confirm variable spfwt0
	if !_rc local weight="spfwt0"
	else {
		cap confirm variable SPFWT0
		if !_rc local weight="SPFWT0"
		else {
			di as error "Your dataset does not contain main survey weight spfwt0 or SPFWT0. Please specify weight() option"
			exit 100
			}
		}
	}
	
local ok_small=0
local ok_big=0

if "`rep'"=="" {
	forvalues i=1(1)80 {
		cap confirm variable spfwt`i'
		if !_rc local ok_small=`ok_small'+1
		cap confirm variable SPFWT`i'
		if !_rc local ok_big=`ok_big'+1
		}

	if `ok_small'==80 local rep="spfwt1-spfwt80"
	else if `ok_big'==80 local rep="SPFWT1-SPFWT80"
		else {
			di as error "Your dataset does not contain all replicate weights spfwt1-spfwt80 or SPFWT1-SPFWT80. Please specify rep() option"
			exit 100
			}
	}
	
cap confirm variable vemethodn
if !_rc {
	qui gen `jkvar'=vemethodn
	}
else {
	cap confirm variable VEMETHODN
	if !_rc {
		qui gen `jkvar'=VEMETHODN
		}
	else {
		if "`vemethodn'"=="" {
			di as error "Your dataset does not contain variable vemethodn or VEMETHODN. Please specify option vemethodn()"
			}
		else gen `jkvar'=`vemethodn'
		}
	}

if "`if'"=="" local if=" if "
else local if=`"`if' "'+" & "

tempvar test
qui gen `test'=1 
foreach var of local varlist {
	capture confirm numeric variable `var'
	if !_rc qui replace `test'=`test'*`var'
    else di as error "`var' is not a numeric variable"
    }

if "`pvdep'"=="" {
	capture confirm numeric variable `outcome'
	if !_rc qui replace `test'=`test'*`outcome'
	else di as error "`outcome' is not a numeric variable"
	}
else {
	qui replace `test'=`test'*`pvdep'1
	local  outcome=""
	}
	
if "`pvdep'"!="" qui replace `test'=`test'*`pvdep'1
if "`pvindep1'"!="" qui replace `test'=`test'*`pvindep1'1
if "`pvindep2'"!="" qui replace `test'=`test'*`pvindep2'1
if "`pvindep3'"!="" qui replace `test'=`test'*`pvindep3'1
if `overpv'==1 qui replace `test'=`test'*`oldover'1
		
local n_vars: word count `pvindep1' `pvindep2' `pvindep3' `varlist' `cons'
local n_cnt: word count `cnt'
if `longlist'==1 local n_cnt=`n_cnt'-2

if "`over'"!="" {
	tab `over', nofreq matrow(over_values)
	local n_over=r(r)
	}
else {
	local over="1"
	matrix over_values=(1,1)
	local n_over=1
	}

tempname tempfile
file open `tempfile' using "`save'.html", write replace
file write `tempfile' `"<HTML><HEAD></HEAD><BODY>"' "<tr> <td> </td>"

* TABLE HEADER - OVER CATEGORIES - if over() specified
if `n_over'>1 {
	local col_span=2*`n_vars'+1
	file write `tempfile' `"<table width="100%" style="text-family:arial;font-size:13px"> <td>Over categories:</td>"'
	forvalues i=1(1)`n_over' {
		local numerek=over_values[`i',1]
		if `overpv'!=1 {
			local labelka: label (`over') `numerek'
			file write `tempfile' `"<th colspan="`col_span'">`labelka'</th>"'
			}
		else {
			if `numerek'==0  {
				file write `tempfile' `"<th colspan="`col_span'">Below Level 1</th>"'
				}
			else {
				file write `tempfile' `"<th colspan="`col_span'">Level `numerek'</th>"'
				}
			}
		}
	}


* SECOND ROW - predictors
file write `tempfile' `"<table width="100%" style="text-family:arial;font-size:13px"> <td>Variable</td>"'
forvalues i=1(1)`n_over' {
	foreach var in `pvindep1' `pvindep2' `pvindep3' `varlist' `cons' {
		file write `tempfile' `"<th colspan="2">`var'</th>"'
		}
	file write `tempfile' `"<th colspan="1">`r2'</th>"'
	}

* third row
file write `tempfile' "<tr><td>" "Country" "</td>"
forvalues i=1(1)`n_over' {
	foreach var in `pvindep1' `pvindep2' `pvindep3' `varlist' `cons' {
		file write `tempfile' `"<td style="text-align:center">"' "Coef." "</td>" `"<td style="text-align:center">"' "S.E." "</td>"
		local OECD_`var'_`i'=0
		local OECD_SE_`var'_`i'=0
		}
	file write `tempfile' `"<td style="text-align:center">"' "" "</td>"	
	local OECD_r2_`i'=0
	}

local decimal=0.1^`round'

forvalues i=1(1)`n_over' {
	local noc_`i'=0
	* creating output matrices
	mat b_over`i'=J(`n_cnt',`n_vars',.)
	mat se_over`i'=J(`n_cnt',`n_vars',.)
	mat r2_over`i'=J(`n_cnt',1,.)
	}

local OECD_saved=0

local pvlist="`outcome'"
if "`pvindep1'"!="" local pvlist="`pvlist' `pvindep1'*"
if "`pvindep2'"!="" local pvlist="`pvlist' `pvindep2'*"
if "`pvindep3'"!="" local pvlist="`pvlist' `pvindep3'*"
if "`pvdep'"!="" local pvlist="`pvlist' `pvdep'*"
if `overpv'==1 local pvlist="`pvlist' `oldover'*"

local country_list=""

local cnt_i=0

foreach l of local cnt {

  if "`l'"=="OECD" | "`l'"=="SUB" {
    if "`l'"=="SUB"  file write `tempfile' `"<tr><td><b>Sub-national entities</td>"' 
	else {
		local OECD_saved=1
		file write `tempfile' `"<tr style="background-color:yellow"> <td><b>OECD Average</td>"'
		forvalues i=1(1)`n_over' {
			foreach var in `pvindep1' `pvindep2' `pvindep3' `varlist' `cons' {
				local mean=string(round(`OECD_`var'_`i''/`noc_`i'',`decimal'),"%20.`round'f")
				local se=string(round(sqrt(`OECD_SE_`var'_`i'')/`noc_`i'',`decimal'),"%20.`round'f")
				file write `tempfile' `"<td style="text-align:center;background-color:yellow"> `mean' </td> <td style="text-align:center"> `se' </td> </td> "'
				}
			local mean=string(round(`OECD_r2_`i''/`noc_`i'',`decimal'),"%20.`round'f")
			file write `tempfile' `"<td style="text-align:center;background-color:yellow"> `mean' </td> "'
			}
		file write `tempfile' `"<tr><td><b>Partners</td>"'
		}
	  }

  else {
  
  _cnt `l'
  local name=r(name)
  local country_list="`country_list'`l' "
  local cnt_i=`cnt_i'+1
	
	di ""
  	di as result "`name'"  _continue	
	file write `tempfile' "<tr><td>" "`name'" "</td>"  
  
  sum `jkvar' if `cntid'=="`l'" , meanonly
  if `r(N)'>0 {
  
	local jk=1
	sum `jkvar' if `cntid'=="`l'" , meanonly
	cap local jk=`r(mean)'
	if `jk'<1 | `jk'>2 {
				di as error "Please specify values 1 or 2 in `jkvar'"
				exit 100
				}
		
	forvalues i=1(1)`n_over' {
		if 1!=`n_over' di as text " `i'" _c
		
		sum `test' if `cntid'=="`l'" & `over'==over_values[`i',1], meanonly

		if r(N)>2 {
				return clear
				cap drop `probka'
				
				if `overpv'==0 qui gen `probka'=1 `if' `cntid'=="`l'" & `over'==over_values[`i',1] `in'
				else qui gen `probka'=1 `if' `cntid'=="`l'" `in'
				
				local temp=over_values[`i',1]
				
				preserve 
				qui keep if `probka'==1
				keep `pvlist' `varlist' `probka' `weight' `rep'
								
				if `pv'==1 | `overpv'==1 {
					if "`fast'"=="" _piaacregpv `outcome' `varlist', overval(`temp') overpv(`oldover') if(`probka') pvdep(`pvdep') pvindep1(`pvindep1') pvindep2(`pvindep2') pvindep3(`pvindep3') weight(`weight') rep(`rep') jk(`jk') cmd(`cmd') cmdops(`cmdops') r2(`r2') `cons' `or'
					else _piaacregfastpv `outcome' `varlist',  overval(`temp')  overpv(`oldover') if(`probka') pvdep(`pvdep') pvindep1(`pvindep1') pvindep2(`pvindep2') pvindep3(`pvindep3') weight(`weight') cmd(`cmd') cmdops(`cmdops') r2(`r2') `cons' `or'
					}
			 	else {
					if "`fast'"=="" _piaacreg `outcome' `varlist', if(`probka') weight(`weight') rep(`rep') jk(`jk') cmd(`cmd') cmdops(`cmdops') r2(`r2') `cons' `or'
					else _piaacregfast `outcome' `varlist', if(`probka') weight(`weight') cmd(`cmd') cmdops(`cmdops') r2(`r2') `cons' `or'
					}
					
			matrix b=r(coef)
			matrix se=r(se)

			local noc_`i'=`noc_`i''+1

			mat temp=b'
			mat temp= temp[1,1..`n_vars']
			mat b_over`i'[`cnt_i',1]=temp
			mat temp=se'
			mat temp= temp[1,1..`n_vars']
			mat se_over`i'[`cnt_i',1]=temp
			
			local row=1
			
			foreach var in `pvindep1' `pvindep2' `pvindep3' `varlist' `cons' {
				local b=b[`row',1]
				local se=se[`row',1]
				local row=`row'+1
				if `b'==0 & `se'==0 file write `tempfile' `"<td style="text-align:center"> 0 </td>"' `"<td style="text-align:center"> 0 </td>"'
				else {
					local mean=string(round(`b',`decimal'),"%20.`round'f")
					local se=string(round(`se',`decimal'),"%20.`round'f")
					file write `tempfile' `"<td style="text-align:center"> `mean' </td>"' `"<td style="text-align:center">`se'</td>"'
																		
					local OECD_`var'_`i'=`OECD_`var'_`i''+`mean'
					local OECD_SE_`var'_`i'=`OECD_SE_`var'_`i''+`se'^2
					}
				}
			local b=b[`row',1]
			mat r2_over`i'[`cnt_i',1]=`b'
			local mean=string(round(`b',`decimal'),"%20.`round'f")
			file write `tempfile' `"<td style="text-align:center"> `mean' </td>"' 
			local OECD_r2_`i'=`OECD_r2_`i''+`mean'
			
			restore
			}
		else {
			foreach var in `pvindep1' `pvindep2' `pvindep3' `varlist' `cons' {
				file write `tempfile' `"<td style="text-align:center"> . </td>"' `"<td style="text-align:center"> . </td>"'
				}
			file write `tempfile' `"<td style="text-align:center"> . </td>"' 
			}
		}
	}
  }
}

if `OECD_saved'==0 {
	file write `tempfile' `"<tr style="background-color:yellow"> <td><b>Average</td>"'
	forvalues i=1(1)`n_over' {
			foreach var in `pvindep1' `pvindep2' `pvindep3' `varlist' `cons' {
				local mean=string(round(`OECD_`var'_`i''/`noc_`i'',`decimal'),"%20.`round'f")
				local se=string(round(sqrt(`OECD_SE_`var'_`i'')/`noc_`i'',`decimal'),"%20.`round'f")
				file write `tempfile' `"<td style="text-align:center;background-color:yellow"> `mean' </td> <td style="text-align:center"> `se' </td> </td> "'
				}
			local mean=string(round(`OECD_r2_`i''/`noc_`i'',`decimal'),"%20.`round'f")
			file write `tempfile' `"<td style="text-align:center;background-color:yellow"> `mean' </td> "'
			}
		}

file write `tempfile' _n "<tr> </table> </BODY></HTML>"
file close `tempfile' 
di ""
di "Results saved in the `save'.html file"

forvalues i=1(1)`n_over' {
	matrix colnames b_over`i' = `pvindep1' `pvindep2' `pvindep3' `varlist' `cons'
	matrix colnames se_over`i' = `pvindep1' `pvindep2' `pvindep3' `varlist' `cons'
	matrix rownames b_over`i' =  `country_list'
	matrix rownames se_over`i' =  `country_list'
	matrix rownames r2_over`i' =  `country_list'
	matrix colnames r2_over`i' = `r2'
	}

if `n_over'==1 {
	return matrix b=b_over1
	return matrix se=se_over1
	return matrix r2=r2_over1
	}
else {
	forvalues i=1(1)`n_over' {
		return matrix b_over`i'=b_over`i'
		return matrix se_over`i'=se_over`i'
		return matrix r2_over`i'=r2_over`i'
		}
	}
	
end

***********

cap program drop _cnt

program define _cnt, rclass
	args l

	local name="`l'"
	
	if "`l'"=="36" local name="Australia"
	if "`l'"=="40" local name="Austria"
	if "`l'"=="124" local name="Canada"
	if "`l'"=="203" local name="Czech Republic"
	if "`l'"=="276" local name="Germany"
	if "`l'"=="208" local name="Denmark"
	if "`l'"=="724" local name="Spain"
	if "`l'"=="233" local name="Estonia"
	if "`l'"=="246" local name="Finland"
	if "`l'"=="250" local name="France"
	if "`l'"=="826" local name="England/N. Ireland (UK)"
	if "`l'"=="372" local name="Ireland"
	if "`l'"=="380" local name="Italy"
	if "`l'"=="392" local name="Japan"
	if "`l'"=="410" local name="Korea"
	if "`l'"=="528" local name="Netherlands"
	if "`l'"=="578" local name="Norway"
	if "`l'"=="616" local name="Poland"
	if "`l'"=="643" local name="Russian Federation"
	if "`l'"=="703" local name="Slovak Republic"
	if "`l'"=="752" local name="Sweden"
	if "`l'"=="840" local name="United States"
	if "`l'"=="56"  local name="Flanders (Belgium)"
	if "`l'"=="196" local name="Cyprus"

	return local name "`name'"
end




****************************************************

cap program drop _piaacreg
program define _piaacreg, rclass
syntax [varlist], weight(varlist max=1) rep(varlist) jk(integer) ///
 cmd(string) if(varname numeric) [cmdops(string) r2(string) cons or] 

	tokenize `varlist'
	local outcome `1'
	macro shift
	local varlist `*'

	* SETUP		
	local num_rep : word count `rep'
	local n_vars: word count `varlist'
	if "`cons'"!="" {
		local n_vars=`n_vars'+1
		local stala="_cons"
		}
		
	matrix coef = J(`n_vars'+1,1,.)
	matrix rownames coef =`varlist' `cons' `r2'
	matrix se= J(`n_vars',1,.)
	matrix rownames se =`varlist' `cons'
	
	qui `cmd' `outcome' `varlist' [pw=`weight'] if `if'==1, `cmdops'
	foreach var in `varlist' `stala' {
		local fulstat_`var'=_b[`var']
		local sumofsq_`var'=0	
	}
	local fulstat_r2=e(`r2')
		
	foreach replication of local rep {
		qui `cmd'  `outcome' `varlist' [pw=`replication'] if `if'==1, `cmdops'
		foreach var in `varlist' `stala' {
			local sq_`var' = (_b[`var'] - `fulstat_`var'')^2
			local sumofsq_`var'=`sumofsq_`var''+ `sq_`var''
		}
	}
				
	foreach var in `varlist' `stala' {
		if  `jk'==1 local sdr_`var'=sqrt(((`num_rep'-1)/`num_rep')*`sumofsq_`var'')
		else local sdr_`var'=sqrt(1*`sumofsq_`var'')
		} 	
	
    local  row=1
 	foreach var in `varlist' `stala' {
		if "`or'"=="" {
			matrix coef[`row',1] = `fulstat_`var''
			matrix se[`row',1] =  `sdr_`var''
			}
		else {
			matrix coef[`row',1] = exp(`fulstat_`var'')
			matrix se[`row',1] =  exp(`fulstat_`var'')*`sdr_`var''
			}
		local row=`row'+1
	}
	matrix coef[`row',1] = `fulstat_r2'

matrix colnames coef = b
matrix colnames se = se

return matrix coef =coef
return matrix se =se
			
end

*************************************

cap program drop _piaacregfast
program define _piaacregfast, rclass
syntax [varlist], weight(varlist max=1) ///
 cmd(string) if(varname numeric) [cmdops(string) r2(string) cons or] 

	tokenize `varlist'
	local outcome `1'
	macro shift
	local varlist `*'

	* SETUP		
	local n_vars: word count `varlist'
	if "`cons'"!="" {
		local n_vars=`n_vars'+1
		local stala="_cons"
		}
		
	matrix coef = J(`n_vars'+1,1,.)
	matrix rownames coef =`varlist' `cons' `r2'
	matrix se= J(`n_vars',1,.)
	matrix rownames se =`varlist' `cons'
	
	qui `cmd' `outcome' `varlist' [pw=`weight'] if `if'==1, `cmdops'
    local  row=1
 	foreach var in `varlist' `stala' {
		if "`or'"=="" {
			matrix coef[`row',1] = _b[`var']
			matrix se[`row',1] = _se[`var']
			}
		else {
			matrix coef[`row',1] = exp(_b[`var'])
			matrix se[`row',1] = exp(_b[`var'])*_se[`var']
			}
		local row=`row'+1
	}
	matrix coef[`row',1] = e(`r2')

matrix colnames coef = b
matrix colnames se = se

return matrix coef =coef
return matrix se =se
			
end


**************

cap program drop _piaacregpv
program define _piaacregpv, rclass
syntax [varlist(numeric default=none)], [overpv(string) overval(string) pvdep(string) pvindep1(string) pvindep2(string) pvindep3(string)] ///
weight(varlist max=1) rep(varlist) jk(integer) cmd(string) if(varname numeric) [cmdops(string)  r2(string) cons or] 
 
if "`overpv'"=="pvlit" | "`overpv'"=="pvnum" | "`overpv'"=="PVLIT" | "`overpv'"=="PVNUM" {
	tempvar proflevel1 proflevel2 proflevel3 proflevel4 proflevel5 proflevel6 proflevel7 proflevel8 proflevel9 proflevel10
	forvalues i=1(1)10 {
		qui recode `overpv'`i' (.=.) (0/175.9999=0) (176/225.9999=1) (226/275.9999=2) (276/325.9999=3) (326/375.9999=4) (376/999=5), gen(`proflevel`i'')
		}
	local overpv=1
	}
	else if "`overpv'"=="pvpsl" | "`overpv'"=="PVPSL"  {
		tempvar proflevel1 proflevel2 proflevel3 proflevel4 proflevel5 proflevel6 proflevel7 proflevel8 proflevel9 proflevel10

		forvalues i=1(1)10 {
			qui recode pvpsl`i' (.=.) (0/240.9999=0) (241/290.9999=1) (291/340.9999=2) (341/999=3), gen(`proflevel`i'')
			}
		local overpv=1
		}
	else local overpv=0

tempvar probkaif

if "`pvdep'"=="" {
	tokenize `varlist'
	local outcome `1'
	macro shift
	local varlist `*'
	local pv=0
	}
else local pv=1
 
local num_rep : word count `rep'
local n_vars: word count `varlist' `pvindep1' `pvindep2' `pvindep3'
if "`cons'"!="" {
	local n_vars=`n_vars'+1
	local stala="_cons"
	}
	
matrix coef = J(`n_vars'+1,10,.)
matrix rownames coef =`varlist' `pvindep1' `pvindep2' `pvindep3' `cons' `r2'
matrix se= J(`n_vars',10,.)
matrix rownames se =`varlist' `pvindep1' `pvindep2' `pvindep3' `cons'

forvalues ipv=1(1)10 {
	di as text "." _c
	if "`pvindep1'"!="" local pvindep="`pvindep1'`ipv'"
	if "`pvindep2'"!="" local pvindep="`pvindep' `pvindep2'`ipv'"
	if "`pvindep3'"!="" local pvindep="`pvindep' `pvindep3'`ipv'"
	if `pv'!=0 local outcome="`pvdep'`ipv'"
	
	cap drop `probkaif'
	if `overpv'==1 qui gen `probkaif'=1 if `proflevel`ipv''==`overval' 
	else local probkaif=1

	qui `cmd' `outcome' `pvindep' `varlist' [pw=`weight'] if `probkaif'==1, `cmdops'
	foreach var in `pvindep' `varlist' `stala' {
		local fulstat_`var'=_b[`var']
		local sumofsq_`var'=0	
		}
	local fulstat_r2=e(`r2')
	if `fulstat_r2'==. local fulstat_r2=0
	
	foreach replication of local rep {
		qui `cmd' `outcome' `pvindep' `varlist' [pw=`replication'] if `probkaif'==1, `cmdops'
		foreach var in `pvindep' `varlist' `stala' {
			local sq_`var' = (_b[`var'] - `fulstat_`var'')^2
			local sumofsq_`var'=`sumofsq_`var''+ `sq_`var''
		}
	}
				
	foreach var in `pvindep' `varlist' `stala' {
		if  `jk'==1 local rVAR_`var'=(((`num_rep'-1)/`num_rep')*`sumofsq_`var'')
		else local rVAR_`var'=(1*`sumofsq_`var'')
		} 	
	
    local  row=1
 	foreach var in `pvindep' `varlist' `stala' {
		matrix coef[`row',`ipv'] = `fulstat_`var''
		matrix se[`row',`ipv'] =  `rVAR_`var''
		local row=`row'+1
		}
	matrix coef[`row',`ipv'] = `fulstat_r2'
}

mat coef=coef'
mat se=se'

mata: pvmat()

if "`or'"!="" {
    local  row=1
 	foreach var in `pvindep1' `pvindep2' `pvindep3' `varlist' `cons' {
		matrix newcoef[`row',1] = exp(newcoef[`row',1])
		matrix newse[`row',1] =  newcoef[`row',1]*newse[`row',1] 
		local row=`row'+1
		}
	}

matrix rownames newcoef = `pvindep1' `pvindep2' `pvindep3' `varlist' `cons'  `r2'
matrix colnames newcoef = b
matrix rownames newse = `pvindep1' `pvindep2' `pvindep3' `varlist' `cons'
matrix colnames newse = se

return matrix coef =newcoef
return matrix se =newse

end


**************

cap program drop _piaacregfastpv
program define _piaacregfastpv, rclass
syntax [varlist(numeric default=none)], [overpv(string) overval(string) pvdep(string) pvindep1(string) pvindep2(string) pvindep3(string)] ///
 weight(varlist max=1) cmd(string) if(varname numeric) [cmdops(string) r2(string) cons or] 

if "`overpv'"=="pvlit" | "`overpv'"=="pvnum" | "`overpv'"=="PVLIT" | "`overpv'"=="PVNUM" {
	tempvar proflevel1 proflevel2 proflevel3 proflevel4 proflevel5 proflevel6 proflevel7 proflevel8 proflevel9 proflevel10
	forvalues i=1(1)10 {
		qui recode `overpv'`i' (.=.) (0/175.9999=0) (176/225.9999=1) (226/275.9999=2) (276/325.9999=3) (326/375.9999=4) (376/999=5), gen(`proflevel`i'')
		}
	local overpv=1
	}
	else if "`overpv'"=="pvpsl" | "`overpv'"=="PVPSL"  {
		tempvar proflevel1 proflevel2 proflevel3 proflevel4 proflevel5 proflevel6 proflevel7 proflevel8 proflevel9 proflevel10

		forvalues i=1(1)10 {
			qui recode pvpsl`i' (.=.) (0/240.9999=0) (241/290.9999=1) (291/340.9999=2) (341/999=3), gen(`proflevel`i'')
			}
		local overpv=1
		}
	else local overpv=0

tempvar probkaif
 
if "`pvdep'"=="" {
	tokenize `varlist'
	local outcome `1'
	macro shift
	local varlist `*'
	local pv=0
	}
else local pv=1

local n_vars: word count `varlist' `pvindep1' `pvindep2' `pvindep3'
if "`cons'"!="" {
	local n_vars=`n_vars'+1
	local stala="_cons"
	}

matrix coef = J(`n_vars'+1,10,.)
matrix rownames coef =`varlist' `pvindep1' `pvindep2' `pvindep3' `cons' `r2'
matrix se= J(`n_vars',10,.)
matrix rownames se =`varlist' `pvindep1' `pvindep2' `pvindep3' `cons'

forvalues ipv=1(1)10 {
	di as text "." _c
	if "`pvindep1'"!="" local pvindep="`pvindep1'`ipv'"
	if "`pvindep2'"!="" local pvindep="`pvindep' `pvindep2'`ipv'"
	if "`pvindep3'"!="" local pvindep="`pvindep' `pvindep3'`ipv'"
	if `pv'!=0 local outcome="`pvdep'`ipv'"
	
	cap drop `probkaif'
	if `overpv'==1 qui gen `probkaif'=1 if `proflevel`ipv''==`overval' 
	else local probkaif=1
	
	qui `cmd' `outcome' `pvindep' `varlist' [pw=`weight'] if `probkaif'==1, `cmdops'
    local  row=1
 	foreach var in `pvindep' `varlist' `stala' {
		if "`or'"=="" {
			matrix coef[`row',`ipv'] = _b[`var']
			matrix se[`row',`ipv'] =  _se[`var']
			}
		else {
			matrix coef[`row',`ipv'] = exp(_b[`var'])
			matrix se[`row',`ipv'] = exp(_b[`var'])*_se[`var']
			}
		local row=`row'+1
	}
	matrix coef[`row',`ipv'] = e(`r2')
}

mat coef=coef'
mat se=se'
mata: pvmat()

matrix rownames newcoef = `pvindep1' `pvindep2' `pvindep3' `varlist' `cons'  `r2'
matrix colnames newcoef = b
matrix rownames newse = `pvindep1' `pvindep2' `pvindep3' `varlist' `cons'
matrix colnames newse = se
return matrix coef =newcoef
return matrix se =newse

end

***************

version 10
clear mata
mata:
void pvmat()
   {
   
	pvs_org=st_matrix("coef")
	pvs=pvs_org[|1,1\10,cols(pvs_org)-1|]
	repVAR=mean(st_matrix("se"))
	
	pvdif=pvs:-mean(pvs)
	sumofsqpv=pvdif'pvdif
	VAR=1.1:*sumofsqpv:/9
	pvVAR= diagonal(VAR)'
	totVAR=repVAR+pvVAR
	SDR=totVAR:^0.5

	st_matrix("newse", SDR')
	st_matrix("newcoef", mean(pvs_org)')
    }
end



