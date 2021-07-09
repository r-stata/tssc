* version 5, DEC2013
* Maciej Jakubowski & Artur Pokropek
* decriptive statistics with PIAAC data

cap program drop piaactab
program define piaactab, rclass

syntax namelist [if] [in] , save(string) [missing twoway weight(varlist max=1) rep(varlist) ///
countryid(varname) vemethodn(varname numeric) over(string) round(integer 2) fast] 

version 10.0

tempvar probka cntid jkvar proflevel1 tabvar1
tempname b se over_values

local longlist=0

if "`namelist'"=="`over'" {
	di as error "Please specify different variable in over() option"
	exit
	}

local overpv=0
if "`over'"=="pvlit" | "`over'"=="pvnum" | "`over'"=="PVLIT" | "`over'"=="PVNUM" {
	tempvar proflevel1 proflevel2 proflevel3 proflevel4 proflevel5 proflevel6 proflevel7 proflevel8 proflevel9 proflevel10
	forvalues i=1(1)10 {
		if "`missing'"=="" qui recode `over'`i' (.=.) (0/175.9999=0) (176/225.9999=1) (226/275.9999=2) (276/325.9999=3) (326/375.9999=4) (376/999=5), gen(`proflevel`i'')
		else qui recode `over'`i' (.=9) (0/175.9999=0) (176/225.9999=1) (226/275.9999=2) (276/325.9999=3) (326/375.9999=4) (376/999=5), gen(`proflevel`i'')
		}
	local overpv=1
	if "`missing'"=="" {
		mat over_values= (0\1\2\3\4\5)
		local nover=6
		}
	else {
		mat over_values= (9\0\1\2\3\4\5)
		local nover=7
		}
	}
	else if "`over'"=="pvpsl" | "`over'"=="PVPLS"  {
		tempvar proflevel1 proflevel2 proflevel3 proflevel4 proflevel5 proflevel6 proflevel7 proflevel8 proflevel9 proflevel10
		forvalues i=1(1)10 {
			if "`missing'"=="" qui recode `over'`i' (.=.) (0/240.9999=0) (241/290.9999=1) (291/339.9999=2) (340/999=3), gen(`proflevel`i'')
			else qui recode `over'`i' (.=9) (0/240.9999=0) (241/290.9999=1) (291/340.9999=2) (341/999=3), gen(`proflevel`i'')
			}
		local overpv=1
		if "`missing'"=="" {
			mat over_values= (0\1\2\3)
			local nover=4
			}
		else {
			mat over_values= (9\0\1\2\3)
			local nover=5
			}
		}
	else {
		if strpos("`over'","pv_")>0 {
			tempvar proflevel1 proflevel2 proflevel3 proflevel4 proflevel5 proflevel6 proflevel7 proflevel8 proflevel9 proflevel10
			forvalues i=1(1)10 {
				local tempname=subinstr("`over'","_","`i'",1)
				qui gen `proflevel`i''=`tempname'
				}
			local overpv=1
			tab `proflevel1', nofreq matrow(over_values) `missing'
			local nover=r(r)
			}
		else {
			if "`over'"=="" {
				tempvar over
				qui gen `over'=1
				matrix over_values=(1,1)
				local nover=1
				}
			else {
				tab `over', nofreq matrow(over_values) `missing'
				local nover=r(r)
				local overpv=0
				}
			}
		}

if "`namelist'"=="pvlit" | "`namelist'"=="pvnum" | "`namelist'"=="PVLIT" | "`namelist'"=="PVNUM" {
	tempvar tabvar1 tabvar2 tabvar3 tabvar4 tabvar5 tabvar6 tabvar7 tabvar8 tabvar9 tabvar10
	forvalues i=1(1)10 {
		if "`missing'"=="" qui recode `namelist'`i' (.=.) (0/175.9999=0) (176/225.9999=1) (226/275.9999=2) (276/325.9999=3) (326/375.9999=4) (376/999=5), gen(`tabvar`i'')
		else qui recode `namelist'`i' (.=9) (0/175.9999=0) (176/225.9999=1) (226/275.9999=2) (276/325.9999=3) (326/375.9999=4) (376/999=5), gen(`tabvar`i'')
		}
	local pv=1
	if "`missing'"=="" {
		mat tabvar_values= (0\1\2\3\4\5)
		local ntab=6
		}
	else {
		mat tabvar_values= (9\0\1\2\3\4\5)
		local ntab=7
		}
	}
	else if "`namelist'"=="pvpsl" | "`namelist'"=="PVPSL"  {
		tempvar tabvar1 tabvar2 tabvar3 tabvar4 tabvar5 tabvar6 tabvar7 tabvar8 tabvar9 tabvar10
		forvalues i=1(1)10 {
			if "`missing'"=="" qui recode pvpsl`i' (.=.) (0/240.9999=0) (241/290.9999=1) (291/339.9999=2) (340/999=3), gen(`tabvar`i'')
			else qui recode pvpsl`i' (.=9) (0/240.9999=0) (241/290.9999=1) (291/340.9999=2) (341/999=3), gen(`tabvar`i'')
			}
		local pv=1
		if "`missing'"=="" {
			mat tabvar_values= (0\1\2\3)
			local ntab=4
			}
		else {
			mat tabvar_values= (9\0\1\2\3)
			local ntab=5
			}
		}
	else {
		if strpos("`namelist'","pv_")>0 {
			tempvar tabvar1 tabvar2 tabvar3 tabvar4 tabvar5 tabvar6 tabvar7 tabvar8 tabvar9 tabvar10
			forvalues i=1(1)10 {
				local tempname=subinstr("`namelist'","_","`i'",1)
				qui gen `tabvar`i''=`tempname'
				}
			local pv=1
			tab `tabvar1', nofreq matrow(tabvar_values) `missing'
			local ntab=r(r)
			}
		else {
			local pv=0
			tempvar tabvar
			qui gen `tabvar'=`namelist'
			tab `tabvar', nofreq matrow(tabvar_values) `missing'
			local ntab=r(r)
			}
		}
		
if `pv'==1 local tabvarlist="`tabvar1' `tabvar2' `tabvar3' `tabvar4' `tabvar5' `tabvar6' `tabvar7' `tabvar8' `tabvar9' `tabvar10'"
else local tabvarlist="`tabvar'"
if `overpv'==1 local overvarlist="`proflevel1' `proflevel2' `proflevel3' `proflevel4' `proflevel5' `proflevel6' `proflevel7' `proflevel8' `proflevel9' `proflevel10'"
else local overvarlist="`over'"

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
			di as error "Your dataset does not contain variable vemethodn or VEMETHODN. Please specify vemethodn() option"
			exit 100
			}
		else gen `jkvar'=`vemethodn'
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

if "`if'"=="" local if=" if "
else local if=`"`if' "'+" & "

local n_cnt: word count `cnt'
if `longlist'==1 local n_cnt=`n_cnt'-2

	
tempname tempfile
file open `tempfile' using "`save'.html", write replace
file write `tempfile' `"<HTML><HEAD></HEAD><BODY>"' "<tr> <td> </td>"

if "`fast'"=="" local fastcol=2
else local fastcol=1

* TABLE HEADER - OVER CATEGORIES - if over() or overpv() specified
if `nover'>1 {
	local col_span=`fastcol'*`ntab'
	file write `tempfile' `"<table width="100%" style="text-family:arial;font-size:13px"> <td>Over categories:</td>"'
	forvalues i=1(1)`nover' {
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
				if `numerek'==9  {
					file write `tempfile' `"<th colspan="`col_span'">Missing</th>"'	
					}
				else {
					file write `tempfile' `"<th colspan="`col_span'">Level `numerek'</th>"'
					}
				}
			}
		}

	}
	
* SECOND ROW - predictors
file write `tempfile' `"<table width="100%" style="text-family:arial;font-size:13px"> <td>Variable</td>"'
forvalues i=1(1)`nover' {
	forvalues j=1(1)`ntab' {
		local numerek=tabvar_values[`j',1]
		if `pv'!=1 {
			local labelka: label (`tabvar') `numerek'
			file write `tempfile' `"<th colspan="`fastcol'">`labelka'</th>"'
			}
		else {
			local labelka: label (`tabvar1') `numerek'
			if `numerek'==0  {
				file write `tempfile' `"<th colspan="`fastcol'">Below Level 1</th>"'
				}
			else {
				if `numerek'==9  {
					file write `tempfile' `"<th colspan="`fastcol'">Missing</th>"'	
					}
				else {
					file write `tempfile' `"<th colspan="`fastcol'">Level `numerek'</th>"'
					}
				}
			}
		}
	}

* third row
file write `tempfile' "<tr><td>" "Country" "</td>"
forvalues i=1(1)`nover' {
	forvalues j=1(1)`ntab' {
		if "`fast'"=="" file write `tempfile' `"<td style="text-align:center">"' "%" "</td>" `"<td style="text-align:center">"' "S.E." "</td>"
		else file write `tempfile' `"<td style="text-align:center">"' "%" "</td>"
		local OECD_`j'_`i'=0
		if "`fast'"=="" local OECD_SE_`j'_`i'=0
		
		}
	}
	
forvalues i=1(1)`nover' {
	local noc_`i'=0
	* creating output matrices
	forvalues i=1(1)`nover' {
		mat b_over`i'=J(`n_cnt',`ntab',.)
		if "`fast'"=="" mat se_over`i'=J(`n_cnt',`ntab',.)
		}
	}

local decimal=0.1^`round'
local OECD_saved=0
local country_list=""
local cnt_i=0

foreach l of local cnt {

  if "`l'"=="OECD" | "`l'"=="SUB" {
    if "`l'"=="SUB"  file write `tempfile' `"<tr><td><b>Sub-national entities</td>"' 
	else {
		local OECD_saved=1
		file write `tempfile' `"<tr style="background-color:yellow"> <td><b>OECD Average</td>"'
		forvalues i=1(1)`nover' {
			forvalues j=1(1)`ntab' {
				local mean=string(round(`OECD_`j'_`i''/`noc_`i'',`decimal'),"%20.`round'f")
				if "`fast'"=="" {
					local se=string(round(sqrt(`OECD_SE_`j'_`i'')/`noc_`i'',`decimal'),"%20.`round'f")
					file write `tempfile' `"<td style="text-align:center;background-color:yellow"> `mean' </td> <td style="text-align:center"> `se' </td> </td> "'
					}
				else file write `tempfile' `"<td style="text-align:center;background-color:yellow"> `mean' </td>"'
				}
			}
		file write `tempfile' `"<tr><td><b>Partners</td>"'
		}
	  }
 else {
 local cntname=strtoname(trim("`l'"))
 if substr("`cntname'",1,1)=="_" local cntname=substr("`cntname'",2,.)
  _cnt `l'
  local name=r(name)
  local country_list="`country_list'`cntname' "
  local cnt_i=`cnt_i'+1
  
  	di ""
  	di as result "`name'"  _continue	
	file write `tempfile' "<tr><td>" "`name'" "</td>"
  
  sum `jkvar' if `cntid'=="`l'" , meanonly
	
  if r(N)>0 {
    local jk=`r(mean)'
	if `jk'<1 | `jk'>2 {
				di as error "Please specify values 1 or 2 in `jkvar'"
				exit 100
				}

	_pvoverpv `tabvarlist' `if' `cntid'=="`l'" `in', overpv(`overvarlist') ///
			weight(`weight') rep(`rep') jk(`jk') `twoway' `fast' ntab(`ntab') nover(`nover') `missing'
	
	forvalues i=1(1)`nover' {
		local noc_`i'=`noc_`i''+1
		
		matrix b=r(est_over`i')	
		mat b_over`i'[`cnt_i',1]=b
		if "`fast'"=="" {
			matrix se=r(se_over`i')
			mat se_over`i'[`cnt_i',1]=se
			}
				
	  forvalues col=1(1)`ntab' {
			local b=b[1,`col']
			if "`fast'"=="" local se=se[1,`col']
			else local se=0
			if `b'==0 & `se'==0 {
					if "`fast'"=="" file write `tempfile' `"<td style="text-align:center"> 0 </td>"' `"<td style="text-align:center"> 0 </td>"'
					else file write `tempfile' `"<td style="text-align:center"> 0 </td>"'
					local mean=0
					}
			else {
				local mean=string(round(`b',`decimal'),"%20.`round'f")
				if "`fast'"=="" {
					local stde=string(round(`se',`decimal'),"%20.`round'f")
					file write `tempfile' `"<td style="text-align:center"> `mean' </td>"' `"<td style="text-align:center">`stde'</td>"'
					}
				else file write `tempfile' `"<td style="text-align:center"> `mean' </td>"'
				}
			if `b'!=. local OECD_`col'_`i'=`OECD_`col'_`i''+`b'
			if `se'!=. & "`fast'"=="" local OECD_SE_`col'_`i'=`OECD_SE_`col'_`i''+`se'^2
			}
		}
	}
 }
 }
 
mat drop tabvar_values

if `OECD_saved'==0 {
	file write `tempfile' `"<tr style="background-color:yellow"> <td><b>Average</td>"'
	forvalues i=1(1)`nover' {
		forvalues j=1(1)`ntab' {
			local mean=string(round(`OECD_`j'_`i''/`noc_`i'',`decimal'),"%20.`round'f")
			if "`fast'"=="" {
				local se=string(round(sqrt(`OECD_SE_`j'_`i'')/`noc_`i'',`decimal'),"%20.`round'f")
				file write `tempfile' `"<td style="text-align:center;background-color:yellow"> `mean' </td> <td style="text-align:center"> `se' </td> </td> "'
				}
			else file write `tempfile' `"<td style="text-align:center;background-color:yellow"> `mean' </td>"'
			}
		}
	}
	
forvalues i=1(1)`nover' {
		matrix rownames b_over`i' = `country_list'
		if "`fast'"=="" matrix rownames se_over`i' = `country_list'
		}

if `nover'==1 {
	return matrix b=b_over1
	if "`fast'"=="" return matrix se=se_over1
	}
else {
	forvalues i=1(1)`nover' {
		return matrix b_over`i'=b_over`i'
		if "`fast'"=="" return matrix se_over`i'=se_over`i'
		}
	}

file write `tempfile' _n "<tr> </table> </BODY></HTML>"
file close `tempfile' 
di ""
di "Results saved in the `save'.html file"

end

***********************************************

cap program drop _pvoverpv
program define _pvoverpv, rclass
syntax varlist [if] [in], overpv(varlist) [twoway] weight(varlist max=1) rep(varlist) jk(integer) ntab(integer) nover(integer) [fast missing]

return clear
preserve
qui keep `if' `in'
qui keep `varlist' `overpv' `weight' `rep' 

local nvarlist : word count `varlist'
local noverlist : word count `overpv'

if `nvarlist'>1 | `noverlist'>1 local ifpv=10
else local ifpv=1

if `jk'==1 local jkfactor=79/80
else local jkfactor=1

forvalues pvcount=1(1)`ifpv' { 

	di "." _c
	
	if `nvarlist'>1 local tvar : word `pvcount' of `varlist'
	else local tvar="`varlist'"
	if `noverlist'>1 local tover : word `pvcount' of `overpv'
	else local tover="`overpv'"
	
	_fulltab `tover' `tvar' `nover' `ntab' `weight'
	mat temp=r(fulltab)
	if "`twoway'"=="" mata: rowperc("temp")
	else mata: matperc("temp")
	mat tab`pvcount'=res
		
	if "`fast'"=="" {
		mat var=J(`nover',`ntab',0)
		foreach r of local rep {
				_fulltab `tover' `tvar' `nover' `ntab' `r'
				mat temp=r(fulltab)
				if "`twoway'"=="" mata: rowperc("temp")
				else mata: matperc("temp")
				mat temp=res
				mata: repvar("tab`pvcount'","temp","var")
				mat var=res
				}
		mata: sevar("var",`jkfactor')
		mat se`pvcount'=res
		}
	}

forvalues overcount=1(1)`nover' {
cap mat drop pvstats
cap mat drop rstats
	forvalues i=1(1)`ifpv'{
		mat pvstats=(nullmat(pvstats)\tab`i'[`overcount',1..`ntab'])
		if "`fast'"=="" mat rstats=(nullmat(rstats)\se`i'[`overcount',1..`ntab'])
		}
	if "`fast'"=="" mata: compPVvar("pvstats","rstats")
	else mata: compPV("pvstats")
		
	return matrix est_over`overcount'=respv	 
	if "`fast'"=="" return matrix se_over`overcount'=resvar
	}
	
restore
	
end


************
version 10

mata:
mata clear

void compPVvar(string scalar pvstats,string scalar rstats)
{
	real matrix repVAR
	real matrix pvdif
	real matrix sumofsqpv
	real matrix VAR
	real matrix pvVAR
	real matrix totVAR
	real matrix SDR
	real matrix pvs
	
	pvs=st_matrix("pvstats")
	repVAR=mean(st_matrix("rstats"))
	
	pvdif=pvs:-mean(pvs)
	sumofsqpv=pvdif'pvdif
	VAR=1.1:*sumofsqpv:/9
	pvVAR= diagonal(VAR)'
	totVAR=repVAR+pvVAR
	SDR=totVAR:^0.5
	
	st_matrix("resvar", SDR)
	st_matrix("respv", mean(pvs))
}
end

version 10
mata:
void compPV(string scalar pvstats)
{
	real matrix pvs
	
	pvs=st_matrix("pvstats")
	st_matrix("respv", mean(pvs))
}

end

************
version 10
mata:
void repvar(string scalar mainmat, string scalar repmat, string scalar varmat)
	{
	real matrix var
	real matrix temp
	
	var=st_matrix(varmat)
	temp=st_matrix(mainmat):-st_matrix(repmat)
	temp=temp:^2
	var=var:+temp
	st_matrix("res", var)
}
end

**************
version 10
mata:
void rowperc(string scalar matname)
	{
	real matrix temp
	real matrix matbyrow
	
    temp=st_matrix(matname)
	matbyrow=temp:/rowsum(temp)*100
	st_matrix("res",matbyrow)
	}
end

**************
version 10
mata:
function matperc(string scalar matname)
	{
	real matrix temp
	real matrix matbyrow
	
    temp=st_matrix(matname)
	matbyrow=temp:/sum(temp)*100
    st_matrix("res", matbyrow)
    }
end

**************
**************

version 10

mata:
void sevar(string scalar matname, real scalar jkfactor)
	{
	real matrix temp
		
    temp=st_matrix(matname)
	temp=temp:*jkfactor
	
	st_matrix("res", temp)
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


******************

cap program drop _fulltab
program define _fulltab, rclass

	args tover tvar nover ntab w

	tempname tempmat
	mat `tempmat'=J(`nover',`ntab',0)
	qui sum `w' if `tover'!=. & `tvar'!=.
	local totwgt=r(sum)
	forvalues overcount=1(1)`nover' {
			forvalues tabcount=1(1)`ntab' {
				qui sum `w' if `tover'==over_values[`overcount',1] & `tvar'==tabvar_values[`tabcount',1]
				if r(N)>0 mat `tempmat'[`overcount',`tabcount']==r(sum)/`totwgt'
				else mat `tempmat'[`overcount',`tabcount']=0
				}
			}
	return matrix fulltab=`tempmat'
	
end
