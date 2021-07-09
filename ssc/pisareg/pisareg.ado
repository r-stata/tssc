* version APR2020, updated by Maciej Jakubowski
* Developed by:
* Maciej Jakubowski, Evidence Institute and University of Warsaw, Poland
* Artur Pokropek, Institute of Philosophy and Sociology, Polish Academy of Sciences
* contact: mj@evidin.pl 

* regression with PISA data

cap program drop pisareg

program define pisareg, rclass
syntax [namelist(min=1)] [if] [in] [, cons pvindep1(string) pvindep2(string) pvindep3(string) cycle(integer 2018) over(varname numeric) cnt(string) save(string) fast round(integer 2) r2(string)]

version 12.0

marksample touse

if inlist(`cycle',2000,2003,2006,2009,2012,2015,2018)==0 {
	di as error "There was no PISA `cycle'. Please specify a proper cycle year"
	exit 198
	}
if `cycle'==. local cycle=2018

if `cycle'==2015 | `cycle'==2018 {
	local ilepv=10
	local schoolid="cntschid"
	local repwt="w_fsturwt"
	}
else {
	local ilepv=5
	local schoolid="schoolid"
	local repwt="w_fstr"
	}
	
tokenize `namelist'
local outcome `1'
macro shift
local varlist `*'

tempvar probka
tempname b se temp_b temp_se

if "`if'"=="" {
	local if=" if "
	}
else local if="`if' "+" & "

if "`r2'"=="" local r2="r2"

tempvar test
qui gen `test'=1 
foreach var of local varlist {
	capture confirm numeric variable `var'
	if !_rc qui replace `test'=`test'*`var'
    else di as error "`var' is not a numeric variable"
	}

_country_list "`cycle'" "`cnt'"
local cnt "`r(cnt)'"

local pv=inlist("`outcome'","math","scie","read","proflevel")	
if `pv'==0 {
	if `cycle'==2000 local pv=inlist("`outcome'","read1","read2","read3","math1","math2")
	else if `cycle'==2003 local pv=inlist("`outcome'","math1","math2","math3","math4","prob")
		else if `cycle'==2006 local pv=inlist("`outcome'","intr","supp","eps","isi","use")
			else if `cycle'==2009 local pv=inlist("`outcome'","era","read1","read2","read3","read4","read5")
				else if `cycle'==2012 local pv=inlist("`outcome'","macc","macq","macs","macu","mape","mapf","mapi")
					else if `cycle'==2015 local pv=inlist("`outcome'","scep", "sced", "scid", "skco", "skpe", "ssph", "ssli", "sses")
						else if `cycle'==2018 local pv=inlist("`outcome'","glcm", "rcli", "rcun", "rcer", "rtsn", "rtml")
				}
			
if `pv'==1 	qui replace `test'=`test'*pv1`outcome'
else {
	capture confirm numeric variable `outcome'
	if !_rc qui replace `test'=`test'*`outcome'
    else di as error "`outcome' is not a numeric variable"
	}
	
local n_vars: word count `pvindep1' `pvindep2' `pvindep3' `varlist' `cons'
local n_cnt: word count `cnt'

if "`pvindep1'"!="" | "`pvindep2'"!="" | "`pvindep3'"!="" {
	local pvindep=1
	}
else local pvindep=0

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
		local labelka: label (`over') `numerek'
		file write `tempfile' `"<th colspan="`col_span'">`labelka'</th>"'
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
	mat b_over`i'=J(`n_cnt',`n_vars',.)
	mat se_over`i'=J(`n_cnt',`n_vars',.)
	mat r2_over`i'=J(`n_cnt',1,.)
	}

local tokeep=""
if `pvindep'==1 {
	if "`pvindep1'"!="" local tokeep="`tokeep' pv*`pvindep1'"
	if "`pvindep2'"!="" local tokeep="`tokeep' pv*`pvindep2'"
	if "`pvindep3'"!="" local tokeep="`tokeep' pv*`pvindep3'"
	}
local tokeep="`tokeep' `varlist' w_fst*"
if `pv'==1 local tokeep="`tokeep' pv*`outcome'"
else local tokeep="`tokeep' `outcome'"
if "`fast'"!="" local tokeep="`tokeep' `schoolid'"

local OECD_saved=0
local country_list=""

foreach l of local cnt {
	di ""
  	di as result "`l'"  _continue
	
	if "`l'"=="OECD" {
		file write `tempfile' `"<tr style="background-color:yellow"> <td><b>OECD Average</td>"'
		local OECD_saved=1
		forvalues i=1(1)`n_over' {
			foreach var in `pvindep1' `pvindep2' `pvindep3' `varlist' `cons' {
				local mean=string(round(`OECD_`var'_`i''/`noc_`i'',`decimal'),"%20.`round'f")
				local se=string(round(sqrt(`OECD_SE_`var'_`i'')/`noc_`i'',`decimal'),"%20.`round'f")
				if abs((`OECD_`var'_`i''/`noc_`i'')/(sqrt(`OECD_SE_`var'_`i'')/`noc_`i''))>=1.96 & `OECD_`var'_`i''!=0 file write `tempfile' `"<td style="text-align:center;background-color:yellow"> <b> `mean' </b></td> <td style="text-align:center"> `se' </td> "'
				else file write `tempfile' `"<td style="text-align:center;background-color:yellow"> `mean' </td> <td style="text-align:center"> `se' </td> </td> "'
				}
		local mean=string(round(`OECD_r2_`i''/`noc_`i'',`decimal'),"%20.`round'f")
		file write `tempfile' `"<td style="text-align:center"> `mean' </td>"' 
		}
 	file write `tempfile' `"<tr><tr><td><b>Partner countries and economies</td>"'
	}	
	else {
				
		_cnt `l'
		if `cycle'==2015 & "`l'"=="QAR" {
				local name="CABA (Argentina)" 
				}
		local name=r(name)
		local country_list="`country_list'`l' "
		file write `tempfile' "<tr><td>" "`name'" "</td>"
		
		forvalues i=1(1)`n_over' {
			
			if 1!=`n_over' di as text " `i'" _c
			
			sum `test' if cnt=="`l'" & `over'==over_values[`i',1], meanonly
			local nonmissing=r(N)
			cap tab `schoolid' if `test'!=. & cnt=="`l'" & `over'==over_values[`i',1], nofreq
			
			if `nonmissing'>30 & r(r)>5 {
			 cap drop `probka'
			 qui gen `probka'=1 `if' cnt=="`l'" & `over'==over_values[`i',1] `in'
			 
			 preserve
			 qui keep if `probka'==1
			 qui keep `tokeep'
			 
			 if `pv'==1 | `pvindep'==1 {
			 	if "`fast'"=="" {
					forvalues ip=1(1)`ilepv' {	
						di as text "." _c
						local indeplist=""
						if "`pvindep1'"!="" local indeplist="`indeplist' pv`ip'`pvindep1'"
						if "`pvindep2'"!="" local indeplist="`indeplist' pv`ip'`pvindep2'"
						if "`pvindep3'"!="" local indeplist="`indeplist' pv`ip'`pvindep3'"
						local indeplist="`indeplist' `varlist'"
						if `pv'==1 _regbrr pv`ip'`outcome' `indeplist', `cons' r2(`r2') repweight("`repwt'")
						else _regbrr `outcome' `indeplist', `cons'  r2(`r2') repweight("`repwt'")
						matrix b`ip'=r(coef)
						matrix se`ip'=r(se)
						local r2`ip'=r(r2)
						}
					}
				else {					
					forvalues ip=1(1)`ilepv' {
						di as text "." _c
						local indeplist=""
						if "`pvindep1'"!="" local indeplist="`indeplist' pv`ip'`pvindep1'"
						if "`pvindep2'"!="" local indeplist="`indeplist' pv`ip'`pvindep2'"
						if "`pvindep3'"!="" local indeplist="`indeplist' pv`ip'`pvindep3'"
						local indeplist="`indeplist' `varlist'"
						if `pv'==1 _regfast pv`ip'`outcome' `indeplist', `cons' r2(`r2')
						else _regfast `outcome' `indeplist', `cons' r2(`r2')
						matrix b`ip'=r(coef)
						matrix se`ip'=r(se)
						local r2`ip'=r(r2)
						}
					}
				* MATRICES WITH MEANS AND SEs FROM PVs
				if `cycle'==2015 | `cycle'==2018 {
					mata: pvmat2015()
					local temp_r2=(`r21'+`r22'+`r23'+`r24'+`r25'+`r26'+`r27'+`r28'+`r29'+`r210')/10
					}
				else {
					mata: pvmat()
					local temp_r2=(`r21'+`r22'+`r23'+`r24'+`r25')/5
					}
			  }
			else if `pv'!=1 & `pvindep'!=1 {
				if "`fast'"=="" {
					_regbrr `outcome' `varlist', `cons' r2(`r2')  repweight("`repwt'")
					matrix b=r(coef)
					matrix se=r(se)
					local temp_r2=r(r2)
					}
				else {
					_regfast `outcome' `varlist', `cons' r2(`r2')
					matrix b=r(coef)
					matrix se=r(se)
					local temp_r2=r(r2)
					}
				}
				
			restore
			
			local noc_`i'=`noc_`i''+1
						
			mat temp=b'
			mat temp= temp[1,1..`n_vars']
			mat b_over`i'[`noc_`i'',1]=temp
			mat temp=se'
			mat temp= temp[1,1..`n_vars']
			mat se_over`i'[`noc_`i'',1]=temp
			
			mat r2_over`i'[`noc_`i'',1]=`temp_r2'
				
			local row=1
			
			foreach var in `pvindep1' `pvindep2' `pvindep3' `varlist' `cons' {
				local b=b[`row',1]
				local se=se[`row',1]
				local row=`row'+1
				if `b'==0 & `se'==0 {
						file write `tempfile' `"<td style="text-align:center"> 0 </td>"' `"<td style="text-align:center"> 0 </td>"'
						}
				else {
					local mean=string(round(`b',`decimal'),"%20.`round'f")
					local se=string(round(`se',`decimal'),"%20.`round'f")
					if abs(`mean'/`se')>=1.96 file write `tempfile' `"<td style="text-align:center"><b> `mean' </b></td>"' `"<td style="text-align:center">`se'</td>"'
					else file write `tempfile' `"<td style="text-align:center"> `mean' </td>"' `"<td style="text-align:center">`se'</td>"'
																		
					local OECD_`var'_`i'=`OECD_`var'_`i''+`mean'
					local OECD_SE_`var'_`i'=`OECD_SE_`var'_`i''+`se'^2
					}
				}
			local OECD_r2_`i'=`OECD_r2_`i''+`temp_r2'
			local mean=string(round(`temp_r2',`decimal'),"%20.`round'f")
			file write `tempfile' `"<td style="text-align:center"> `mean' </td>"' 
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
			if abs((`OECD_`var'_`i''/`noc_`i'')/(sqrt(`OECD_SE_`var'_`i'')/`noc_`i''))>=1.96 & `OECD_`var'_`i''!=0 file write `tempfile' `"<td style="text-align:center;background-color:yellow"> <b> `mean' </b></td> <td style="text-align:center"> `se' </td> "'
			else file write `tempfile' `"<td style="text-align:center;background-color:yellow"> `mean' </td> <td style="text-align:center"> `se' </td> </td> "'
			}
		local mean=string(round(`OECD_r2_`i''/`noc_`i'',`decimal'),"%20.`round'f")
		file write `tempfile' `"<td style="text-align:center"> `mean' </td>"' 
		}
	}	

file write `tempfile' _n "<tr> </table> </BODY></HTML>"
file close `tempfile' 
di ""
di "Results saved in the `save'.html file"

forvalues i=1(1)`n_over' {
	matrix colnames b_over`i' = `pvindep1' `pvindep2' `pvindep3' `varlist' `cons'
	matrix colnames se_over`i' = `pvindep1' `pvindep2' `pvindep3' `varlist' `cons'
	matrix rownames b_over`i' = `country_list'
	matrix rownames se_over`i' = `country_list'
	matrix rownames r2_over`i' = `country_list'
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

******************************************************
					
cap program drop _regbrr
program define _regbrr, rclass
						
syntax [namelist(min=2)], [cons r2(string)] repweight(string)

tokenize `namelist'
local outcome `1'
macro shift
local varlist `*'
tempname coef se 

if "`cons'"!="" {
	local n_vars=`n_vars'+1
	local stala="_cons"
	}

* point estimates with one plausible value
qui _regress `outcome' `varlist' [aw=w_fstuwt]
foreach var in `varlist' `stala' {
	local b_`var'=_b[`var']
	}

local ret_r2=e(`r2')
	
* 80 replications with BRR weights
foreach var in `varlist' `stala' {
	local var_`var'=0
	}
	
forvalues j=1(1)80 {
	qui _regress `outcome' `varlist' [aw=`repweight'`j']
	foreach var in `varlist' `stala' {
			local var_`var'=`var_`var''+(`b_`var''-_b[`var'])^2
			}
	}
	
foreach var in `varlist' `stala' {
			matrix `coef'=(nullmat(`coef') \ `b_`var'')
			matrix `se' = (nullmat(`se') \ sqrt(`var_`var''/20))
			}
		
return matrix coef=`coef'
return matrix se=`se'
return scalar r2=`ret_r2'
								
end

******************************************************
cap program drop _regfast
program define _regfast, rclass
						
syntax [namelist(min=2)], [cons r2(string)]

tokenize `namelist'
local outcome `1'
macro shift
local varlist `*'
tempname coef se 

if "`cons'"!="" {
	local n_vars=`n_vars'+1
	local stala="_cons"
	}

* point estimates with one plausible value
qui _regress `outcome' `varlist' [aw=w_fstuwt], cluster(`schoolid')
foreach var in `varlist' `stala' {
	matrix `coef'=(nullmat(`coef') \ _b[`var'])
	matrix `se' = (nullmat(`se') \ _se[`var'])
	}
		
return matrix coef=`coef'
return matrix se=`se'
return scalar r2=e(`r2')
								
end

*********

version 9
cap mata: mata drop pvmat()
mata:

void pvmat()
  {
	 b1 = st_matrix("b1")
	 b2 = st_matrix("b2")
	 b3 = st_matrix("b3")
	 b4 = st_matrix("b4")
	 b5 = st_matrix("b5")
	 se1 = st_matrix("se1")
	 se2 = st_matrix("se2")
	 se3 = st_matrix("se3")
	 se4 = st_matrix("se4")
	 se5 = st_matrix("se5")
	 
	b = (b1+b2+b3+b4+b5):/5
	var =((se1:^2)+(se2:^2)+(se3:^2)+(se4:^2)+(se5:^2)):/5
	imp = ( ((b-b1):^2) + ((b-b2):^2) + ((b-b3):^2) + ((b-b4):^2) + ((b-b5):^2) ):/4
	se=(var+(imp:*1.2)):^0.5
	st_matrix("b",b)
	st_matrix("se",se)
	
    }

end

***********

version 9
cap mata: mata drop pvmat2015()
mata:

void pvmat2015()
  {
	 b1 = st_matrix("b1")
	 b2 = st_matrix("b2")
	 b3 = st_matrix("b3")
	 b4 = st_matrix("b4")
	 b5 = st_matrix("b5")
	 b6 = st_matrix("b6")
	 b7 = st_matrix("b7")
	 b8 = st_matrix("b8")
	 b9 = st_matrix("b9")
	 b10 = st_matrix("b10")

	 se1 = st_matrix("se1")
	 se2 = st_matrix("se2")
	 se3 = st_matrix("se3")
	 se4 = st_matrix("se4")
	 se5 = st_matrix("se5")
	 se6 = st_matrix("se6")
	 se7 = st_matrix("se7")
	 se8 = st_matrix("se8")
	 se9 = st_matrix("se9")
	 se10 = st_matrix("se10")
	 
	b = (b1+b2+b3+b4+b5+b6+b7+b8+b9+b10):/10
	var =((se1:^2)+(se2:^2)+(se3:^2)+(se4:^2)+(se5:^2)+(se6:^2)+(se7:^2)+(se8:^2)+(se9:^2)+(se10:^2)):/10
	imp = ( ((b-b1):^2) + ((b-b2):^2) + ((b-b3):^2) + ((b-b4):^2) + ((b-b5):^2) + ((b-b6):^2) + ((b-b7):^2) + ((b-b8):^2) + ((b-b9):^2) + ((b-b10):^2) ):/9
	se=(var+(imp:*1.1)):^0.5
	st_matrix("b",b)
	st_matrix("se",se)
	
    }

end

***********

cap program drop _cnt

program define _cnt, rclass
	args l

	local name="`l'"
	if "`l'"=="ALB" local name="Albania"
	if "`l'"=="ARE" local name="United Arab Emirates"
	if "`l'"=="ARG" local name="Argentina"
	if "`l'"=="AUS" local name="Australia"
	if "`l'"=="AUT" local name="Austria"
	if "`l'"=="AZE" local name="Azerbaijan"
	if "`l'"=="BEL" local name="Belgium"
	if "`l'"=="BGR" local name="Bulgaria"
	if "`l'"=="BIH" local name="Bosnia and Herzegovina"
	if "`l'"=="BLR" local name="Belarus"
	if "`l'"=="BRA" local name="Brazil"
	if "`l'"=="BRN" local name="Brunei Darussalam"
	if "`l'"=="CAN" local name="Canada"
	if "`l'"=="CHE" local name="Switzerland"
	if "`l'"=="CHL" local name="Chile"
	if "`l'"=="CHN" local name="Shanghai (China)"
	if "`l'"=="COL" local name="Colombia"
	if "`l'"=="CRI" local name="Costa Rica"
	if "`l'"=="CZE" local name="Czech Republic"
	if "`l'"=="DEU" local name="Germany"
	if "`l'"=="DOM" local name="Dominican Republic"
	if "`l'"=="DNK" local name="Denmark"
	if "`l'"=="DZA" local name="Algeria"
	if "`l'"=="ESP" local name="Spain"
	if "`l'"=="EST" local name="Estonia"
	if "`l'"=="FIN" local name="Finland"
	if "`l'"=="FRA" local name="France"
	if "`l'"=="GBR" local name="United Kingdom"
	if "`l'"=="GEO" local name="Georgia"
	if "`l'"=="GRC" local name="Greece"
	if "`l'"=="HKG" local name="Hong Kong (China)"
	if "`l'"=="HRV" local name="Croatia"
	if "`l'"=="HUN" local name="Hungary"
	if "`l'"=="IDN" local name="Indonesia"
	if "`l'"=="IRL" local name="Ireland"
	if "`l'"=="ISL" local name="Iceland"
	if "`l'"=="ISR" local name="Israel"
	if "`l'"=="ITA" local name="Italy"
	if "`l'"=="JOR" local name="Jordan"
	if "`l'"=="JPN" local name="Japan"
	if "`l'"=="KAZ" local name="Kazakhstan"
	if "`l'"=="KGZ" local name="Kyrgyzstan"
	if "`l'"=="KOR" local name="Korea"
	if "`l'"=="KSV" local name="Kosovo"
	if "`l'"=="LBN" local name="Lebanon"
	if "`l'"=="LIE" local name="Liechtenstein"
	if "`l'"=="LTU" local name="Lithuania"
	if "`l'"=="LUX" local name="Luxembourg"
	if "`l'"=="LVA" local name="Latvia"
	if "`l'"=="MAC" local name="Macao (China)"
	if "`l'"=="MAR" local name="Morocco"
	if "`l'"=="MDA" local name="Moldova"
	if "`l'"=="MEX" local name="Mexico"
	if "`l'"=="MKD" local name="North Macedonia"
	if "`l'"=="MLT" local name="Malta"
	if "`l'"=="MNE" local name="Montenegro"
	if "`l'"=="MYS" local name="Malaysia"
	if "`l'"=="NLD" local name="Netherlands"
	if "`l'"=="NOR" local name="Norway"
	if "`l'"=="NZL" local name="New Zealand"
	if "`l'"=="PAN" local name="Panama"
	if "`l'"=="PER" local name="Peru"
	if "`l'"=="PHL" local name="Philippines"
	if "`l'"=="POL" local name="Poland"
	if "`l'"=="PRT" local name="Portugal"
	if "`l'"=="QAT" local name="Qatar"
	if "`l'"=="QCN" local name="Shanghai (China)"
	if "`l'"=="QAR" local name="Dubai (UAE)"
	if "`l'"=="QAZ" local name="Baku (Azerbaijan)"
	if "`l'"=="QCI" local name="B-S-J-Z (China)"
	if "`l'"=="QMR" local name="Moscow Region (RUS)"
	if "`l'"=="QRT" local name="Tatarstan (RUS)"
	if "`l'"=="QCH" local name="B-S-J-G (China)"
	if "`l'"=="QRS" local name="Perm (RUS)"
	if "`l'"=="QUA" local name="Florida (USA)"
	if "`l'"=="QUB" local name="Connecticut (USA)"
	if "`l'"=="QUC" local name="Massachusetts (USA)"
	if "`l'"=="ROU" | "`l'"=="ROM" local name="Romania"
	if "`l'"=="RUS" local name="Russia"
	if "`l'"=="SAU" local name="Saudi Arabia"
	if "`l'"=="SGP" local name="Singapore"
	if "`l'"=="SRB" local name="Serbia"
	if "`l'"=="SVK" local name="Slovak Republic"
	if "`l'"=="SVN" local name="Slovenia"
	if "`l'"=="SWE" local name="Sweden"
	if "`l'"=="TAP" local name="Chinese Taipei"
	if "`l'"=="THA" local name="Thailand"
	if "`l'"=="TTO" local name="Trinidad and Tobago"
	if "`l'"=="TUN" local name="Tunisia"
	if "`l'"=="TUR" local name="Turkey"
	if "`l'"=="UKR" local name="Ukraine"
	if "`l'"=="URY" local name="Uruguay"
	if "`l'"=="USA" local name="United States"
	if "`l'"=="VNM" local name="Viet Nam"
	
	return local name "`name'"
end

cap program drop _country_list

program define _country_list, rclass
	args cycle cnt
	
	if `cycle'==2000 {
		if "`cnt'"=="OECD" local cnt = "AUS AUT BEL CAN CZE DNK FIN FRA DEU GRC HUN ISL IRL ITA JPN KOR LUX MEX NLD NZL NOR POL PRT ESP SWE CHE GBR USA OECD"
		else if "`cnt'"=="PARTNERS" local cnt = "ALB ARG BGR BRA CHL HKG IDN ISR LIE LVA MKD PER ROM RUS THA"
			else if "`cnt'"=="PISA" local cnt = "AUS AUT BEL CAN CZE DNK FIN FRA DEU GRC HUN ISL IRL ITA JPN KOR LUX MEX NLD NZL NOR POL PRT ESP SWE CHE GBR USA OECD ALB ARG BGR BRA CHL HKG IDN ISR LIE LVA MKD PER ROM RUS THA"
				else if "`cnt'"=="ALL" | "`cnt'"=="" qui levelsof cnt, local(cnt)
		}
	else if `cycle'==2003 {
		if "`cnt'"=="OECD" local cnt = "AUS AUT BEL CAN CZE DNK ESP FIN FRA DEU GRC HUN ISL IRL ITA JPN KOR LUX MEX NLD NZL NOR POL PRT SVK SWE CHE TUR GBR USA OECD"
		else if "`cnt'"=="PARTNERS" local cnt = "BRA HKG IDN LIE LVA MAC RUS THA TUN URY YUG"
			else if "`cnt'"=="PISA" local cnt = "AUS AUT BEL CAN CZE DNK FIN FRA DEU GRC HUN ISL IRL ITA JPN KOR LUX MEX NLD NZL NOR POL PRT SVK ESP SWE CHE TUR GBR USA OECD BRA HKG IDN LIE LVA MAC RUS THA TUN URY YUG"
				else if "`cnt'"=="ALL" | "`cnt'"==""  qui levelsof cnt, local(cnt)
		}
	else if `cycle'==2006 {
		if "`cnt'"=="OECD" local cnt = "AUS AUT BEL CAN CZE DNK FIN FRA DEU GRC HUN ISL IRL ITA JPN KOR LUX MEX NLD NZL NOR POL PRT SVK ESP SWE CHE TUR GBR USA OECD"
		else if "`cnt'"=="PARTNERS" local cnt = "ARG AZE BGR BRA CHL COL EST HKG HRV IDN ISR JOR KGZ LIE LTU LVA MAC MNE QAT ROU RUS SRB SVN TAP THA TUN URY"
			else if "`cnt'"=="PISA" local cnt = "AUS AUT BEL CAN CZE DNK FIN FRA DEU GRC HUN ISL IRL ITA JPN KOR LUX MEX NLD NZL NOR POL PRT SVK ESP SWE CHE TUR GBR USA OECD ARG AZE BGR BRA CHL COL EST HKG HRV IDN ISR JOR KGZ LIE LTU LVA MAC MNE QAT ROU RUS SRB SVN TAP THA TUN URY"
				else if "`cnt'"=="ALL" | "`cnt'"=="" qui levelsof cnt, local(cnt)
		}
	else if `cycle'==2009 {
		if "`cnt'"=="OECD" local cnt = "AUS AUT BEL CAN CHL CZE DNK EST FIN FRA DEU GRC HUN ISL IRL ISR ITA JPN KOR LUX MEX NLD NZL NOR POL PRT SVK SVN ESP SWE CHE TUR GBR USA OECD"
		else if "`cnt'"=="PARTNERS" local cnt = "ALB ARG AZE BRA BGR COL HRV QAR HKG IDN JOR KAZ KGZ LVA LIE LTU MAC MNE PAN PER QAT ROU RUS SRB QCN SGP TAP THA TTO TUN URY"
			else if "`cnt'"=="PISA" local cnt "AUS AUT BEL CAN CHL CZE DNK EST FIN FRA DEU GRC HUN ISL IRL ISR ITA JPN KOR LUX MEX NLD NZL NOR POL PRT SVK SVN ESP SWE CHE TUR GBR USA OECD ALB ARG AZE BRA BGR COL HRV QAR HKG IDN JOR KAZ KGZ LVA LIE LTU MAC MNE PAN PER QAT ROU RUS SRB QCN SGP TAP THA TTO TUN URY"
				else if "`cnt'"=="ALL" | "`cnt'"=="" qui levelsof cnt, local(cnt)
		}
	else if `cycle'==2012 {
		if "`cnt'"=="OECD" local cnt = "AUS AUT BEL CAN CHL CZE DNK EST FIN FRA DEU GRC HUN ISL IRL ISR ITA JPN KOR LUX MEX NLD NZL NOR POL PRT SVK SVN ESP SWE CHE TUR GBR USA OECD"
		else if "`cnt'"=="PARTNERS" local cnt = "ALB ARG BRA BGR COL CRI HRV HKG IDN JOR KAZ LVA LIE LTU MAC MYS MNE PER QAT ROU RUS SRB QCN SGP TAP THA TUN ARE URY VNM"
			else if "`cnt'"=="PISA" local cnt "AUS AUT BEL CAN CHL CZE DNK EST FIN FRA DEU GRC HUN ISL IRL ISR ITA JPN KOR LUX MEX NLD NZL NOR POL PRT SVK SVN ESP SWE CHE TUR GBR USA OECD ALB ARG BRA BGR COL CRI HRV HKG IDN JOR KAZ LVA LIE LTU MAC MYS MNE PER QAT ROU RUS SRB QCN SGP TAP THA TUN ARE URY VNM"
				else if "`cnt'"=="ALL" | "`cnt'"=="" qui levelsof cnt, local(cnt)
		}
	else if `cycle'==2015 {
		if "`cnt'"=="OECD" local cnt = "AUS AUT BEL CAN CHL CZE DNK EST FIN FRA DEU GRC HUN ISL IRL ISR ITA JPN KOR LVA LUX MEX NLD NZL NOR POL PRT SVK SVN ESP SWE CHE TUR GBR USA OECD"
		else if "`cnt'"=="PARTNERS" local cnt = "ALB DZA BRA QCH BGR QAR COL CRI HRV DOM MKD GEO HKG IDN JOR KSV LBN LTU MAC MLT MDA MNE PER QAT ROU RUS SGP TAP THA TTO TUN ARE URY VNM"
			else if "`cnt'"=="PISA" local cnt "AUS AUT BEL CAN CHL CZE DNK EST FIN FRA DEU GRC HUN ISL IRL ISR ITA JPN KOR LVA LUX MEX NLD NZL NOR POL PRT SVK SVN ESP SWE CHE TUR GBR USA OECD ALB DZA BRA QCH BGR QAR COL CRI HRV DOM MKD GEO HKG IDN JOR KSV LBN LTU MAC MLT MDA MNE PER QAT ROU RUS SGP TAP THA TTO TUN ARE URY VNM"
				else if "`cnt'"=="ALL" | "`cnt'"=="" qui levelsof cnt, local(cnt)
		}
	else if `cycle'==2018 {
		if "`cnt'"=="OECD" local cnt = "AUS AUT BEL CAN CHL COL CZE DNK EST FIN FRA DEU GRC HUN ISL IRL ISR ITA JPN KOR LVA LTU LUX MEX NLD NZL NOR POL PRT SVK SVN ESP SWE CHE TUR GBR USA OECD"
		else if "`cnt'"=="PARTNERS" local cnt = "ALB ARG QAZ BLR BIH BRA BRN QCI BGR CRI HRV DOM GEO HKG IDN JOR KAZ KSV LBN MAC MYS MLT MDA MNE MAR MKD PAN PER PHL QAT ROU RUS SAU SRB SGP TAP THA UKR ARE URY VNM"
			else if "`cnt'"=="PISA" local cnt "AUS AUT BEL CAN CHL COL CZE DNK EST FIN FRA DEU GRC HUN ISL IRL ISR ITA JPN KOR LVA LTU LUX MEX NLD NZL NOR POL PRT SVK SVN ESP SWE CHE TUR GBR USA OECD ALB ARG QAZ BLR BIH BRA BRN QCI BGR CRI HRV DOM GEO HKG IDN JOR KAZ KSV LBN MAC MYS MLT MDA MNE MAR MKD PAN PER PHL QAT ROU RUS SAU SRB SGP TAP THA UKR ARE URY VNM"
				else if "`cnt'"=="ALL" | "`cnt'"=="" qui levelsof cnt, local(cnt)
		}
		
	return local cnt "`cnt'"
	
end
