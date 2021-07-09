* version APR2020, updated by Maciej Jakubowski
* Developed by:
* Maciej Jakubowski, Evidence Institute and University of Warsaw, Poland
* Artur Pokropek, Institute of Philosophy and Sociology, Polish Academy of Sciences
* contact: mj@evidin.pl 
* basic statistics with PISA data

cap program drop pisastats

program define pisastats

syntax [varlist(default=none)] [if] [in] , cnt(string) save(string) ///
[stats(string) pv(string) over(varname numeric) cycle(integer 2018) ///
fast round(integer 2) sas bold]

version 12.0

local n_stats: word count `stats'

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
	
if "`over'"!="" {
	tab `over', nofreq matrow(over_values)
	local n_over=r(r)
	}
else {
	local over="1"
	matrix over_values=(1,1)
	local n_over=1
	}

_country_list "`cycle'" "`cnt'"
local cnt "`r(cnt)'"

tempvar probka

if "`if'"=="" {
	local if=" if "
	}
else local if="`if' "+" & "

tempname tempfile
file open `tempfile' using "`save'.html", write replace
file write `tempfile' `"<HTML><HEAD></HEAD><BODY>"' "<tr> <td> </td>"

* TABLE HEADER

file write `tempfile' `"<table width="100%" style="text-family:arial;font-size:13px"> <td>Variable</td>"'

if `n_stats'==0 local col_span=2*`n_over'
else local col_span=2*`n_over'*`n_stats'

if "`pv'"!="" file write `tempfile' `"<th colspan="`col_span'" style="text-align:center">`pv'</th>"'
		
foreach var in `varlist' {
	file write `tempfile' `"<th colspan="`col_span'" style="text-align:center">`var'</th>"'
	}

* second row

if `n_stats'==0 local col_span=2
else local col_span=2*`n_stats'

if `n_over'>1 {
	file write `tempfile' "<tr><td>" "Categories" "</td>"
	if "`pv'"!="" forvalues i=1(1)`n_over' {
					local numerek=over_values[`i',1]
					local labelka: label (`over') `numerek'
					file write `tempfile' `"<th colspan="`col_span'" style="text-align:center">`labelka'</th>"'
					}
	foreach var in `varlist'  {
		forvalues i=1(1)`n_over' {
			local numerek=over_values[`i',1]
			local labelka: label (`over') `numerek'
			file write `tempfile' `"<th colspan="`col_span'" style="text-align:center">`labelka'</th>"'
			}
		}
	}
	
* third row

file write `tempfile' "<tr><td>" "Country" "</td>"
if "`pv'"!="" forvalues i=1(1)`n_over' {
				if `n_stats'==0 {
						file write `tempfile' `"<td style="text-align:center">"' "Mean" "</td>" `"<td style="text-align:center">"' "S.E." "</td>"
						local OECD_mean_`pv'_`i'=0
						local OECD_SE_mean_`pv'_`i'=0
						}
					else foreach stat in `stats' {
						file write `tempfile' `"<td style="text-align:center">"' "`stat'" "</td>" `"<td style="text-align:center">"' "S.E." "</td>"
							local OECD_`stat'_`pv'_`i'=0
							local OECD_SE_`stat'_`pv'_`i'=0
							}
				}

foreach var in `varlist'  {
	forvalues i=1(1)`n_over' {
		if `n_stats'==0 {
				file write `tempfile' `"<td style="text-align:center">"' "Mean" "</td>" `"<td style="text-align:center">"' "S.E." "</td>"
				local OECD_mean_`var'_`i'=0
				local OECD_SE_mean_`var'_`i'=0
				}
			else foreach stat in `stats' {
					file write `tempfile' `"<td style="text-align:center">"' "`stat'" "</td>" `"<td style="text-align:center">"' "S.E." "</td>"
					local OECD_`stat'_`var'_`i'=0
					local OECD_SE_`stat'_`var'_`i'=0
					}
		}
	}

local how_many : word count `cnt'
local ile : word count `varlist'
if "`pv'"!="" {
  foreach stat in `stats' {
	forvalues i=1(1)`n_over' {
		local noc_`stat'_`pv'_`i'=0
		}
	}
 }
 
foreach var in `varlist'  {
	foreach stat in `stats' {
		forvalues i=1(1)`n_over' {
			local noc_`stat'_`var'_`i'=0
			}
		}
	}

local decimal=0.1^`round'

if `n_stats'==0 local stats="mean"

if "`fast'"!="" qui svyset `schoolid' [pw=w_fstuwt]
if "`bold'"!="" local bold="<b>"
else local bold=""

local tokeep="`varlist' w_fst* cnt `schoolid'"
if "`pv'"!="" local tokeep="`tokeep' pv*`pv'"

foreach l in `cnt' {
	di ""
  	di as result "`l' - " _continue

	if "`l'"=="OECD" {
		file write `tempfile' `"<tr style="background-color:yellow"> <td><b>OECD Average</td>"'
		if "`pv'"!="" foreach stat in `stats' {
						forvalues i=1(1)`n_over' {
							local ratio = "?"
							cap local mean=string(round(`OECD_`stat'_`pv'_`i''/`noc_`stat'_`pv'_`i'',`decimal'),"%12.`round'f")
							cap local se=string(round(sqrt(`OECD_SE_`stat'_`pv'_`i'')/`noc_`stat'_`pv'_`i'',`decimal'),"%12.`round'f")
							cap local ratio=abs((`OECD_`stat'_`pv'_`i''/`noc_`stat'_`pv'_`i'')/(sqrt(`OECD_SE_`stat'_`pv'_`i'')/`noc_`stat'_`pv'_`i''))
							capture confirm number `ratio'
							if _rc==0 {	
								if `ratio' >=1.96 & `OECD_`stat'_`pv'_`i''!=0 file write `tempfile' `"<td style="text-align:center;background-color:yellow"> `bold' `mean' </b></td> <td style="text-align:center"> `se' </td> "'
								else file write `tempfile' `"<td style="text-align:center;background-color:yellow"> `mean' </td> <td style="text-align:center"> `se' </td> </td> "'
								}
							else file write `tempfile' `"<td style="text-align:center;background-color:yellow"> error </td> <td style="text-align:center"> error </td> </td> "'
							}
						}
						
		foreach var in `varlist'  {
		  foreach stat in `stats' {
			forvalues i=1(1)`n_over' {
				local ratio = "?"
				cap local mean=string(round(`OECD_`stat'_`var'_`i''/`noc_`stat'_`var'_`i'',`decimal'),"%12.`round'f")
				cap local se=string(round(sqrt(`OECD_SE_`stat'_`var'_`i'')/`noc_`stat'_`var'_`i'',`decimal'),"%12.`round'f")
				cap local ratio=abs((`OECD_`stat'_`var'_`i''/`noc_`stat'_`var'_`i'')/(sqrt(`OECD_SE_`stat'_`var'_`i'')/`noc_`stat'_`var'_`i''))
				capture confirm number `ratio'
				if _rc==0 {	
					if abs((`OECD_`stat'_`var'_`i''/`noc_`stat'_`var'_`i'')/(sqrt(`OECD_SE_`stat'_`var'_`i'')/`noc_`stat'_`var'_`i''))>=1.96 & `OECD_`stat'_`var'_`i''!=0 file write `tempfile' `"<td style="text-align:center;background-color:yellow"> `bold' `mean' </b></td> <td style="text-align:center"> `se' </td> "'
					else file write `tempfile' `"<td style="text-align:center;background-color:yellow"> `mean' </td> <td style="text-align:center"> `se' </td> </td> "'
					}
				else file write `tempfile' `"<td style="text-align:center;background-color:yellow"> error </td> <td style="text-align:center"> error </td> </td> "'
				}
			}
			
		}
		file write `tempfile' `"<tr><tr><td><b>Partner countries and economies</td>"'
		}
	else {
		_cnt `l'
		local name=r(name)
		if `cycle'==2015 & "`l'"=="QAR" {
				local name="CABA (Argentina)" 
				}
		file write `tempfile' "<tr><td>" "`name'" "</td>"
		
	   	if "`pv'"!="" {
			di as text "`pv': " _continue
			
			forvalues i=1(1)`n_over' {
			 cap restore
			 if 1!=`n_over' di as input "`i' " _c
			 qui count if pv1`pv'!=. & cnt=="`l'" & `over'==over_values[`i',1]
			 local obs=r(N)
			 cap tab `schoolid' if pv1`pv'!=. & cnt=="`l'" & `over'==over_values[`i',1], nofreq
			 if `obs'>30 & r(r)>5 {
			 
			 cap drop `probka'
			 qui gen `probka'=1 `if' cnt=="`l'" & `over'==over_values[`i',1] `in'
			 
			 preserve
			 qui keep if `probka'==1
			 qui keep `tokeep'
			
			  foreach stat in `stats' {
			  di as input "`stat' " _c
			   
			   if "`fast'"=="" {
			  
			    forvalues ip=1(1)`ilepv' {
					di as input "." _c
					qui sum pv`ip'`pv' [aw=w_fstuwt], detail
					if "`stat'"=="sd" & "`SAS'"!="" local mean`ip'=`r(sd)'*sqrt((`r(N)'-1)/`r(N)')
					else local mean`ip'=`r(`stat')'
																
					local variance`ip'=0
					if "`stat'"=="mean" forvalues j=1(1)80 {
								sum pv`ip'`pv' [aw=`repwt'`j'], meanonly
								local variance`ip'=`variance`ip''+(`mean`ip''-`r(mean)')^2
								}
						else if "`SAS'"!="" forvalues j=1(1)80 {
										qui sum pv`ip'`pv' [aw=`repwt'`j'], detail
										if "`stat'"=="sd" local variance`ip'=`variance`ip''+(`mean`ip''- `r(sd)'* sqrt((`r(N)'-1)/`r(N)'))^2 	
										else local variance`ip'=`variance`ip''+(`mean`ip''-`r(`stat')')^2
										}
							else forvalues j=1(1)80 {
									qui sum pv`ip'`pv' [aw=`repwt'`j'] , detail
									local variance`ip'=`variance`ip''+(`mean`ip''-`r(`stat')')^2
									}
					}
					
					local variance=0
					local mean=0
					forvalues ip=1(1)`ilepv' {
						local mean=`mean'+`mean`ip''
						local variance=`variance'+(`variance`ip''/20)
						}
					local mean=`mean'/`ilepv'
					local imp_var=0
					forvalues ip=1(1)`ilepv' {
						local imp_var=`imp_var'+(`mean'-`mean`ip'')^2
						}
						
					if `cycle'==2015 | `cycle'==2018 {
						local variance=`variance'/`ilepv'+1.1*`imp_var'/9
						}
					else {
						local variance=`variance'/`ilepv'+1.2*`imp_var'/4
						}
						
					local se=sqrt(`variance')
					}
				else if "`fast'"!="" {
					if "`stat'"=="mean" {
						if `cycle'==2015 | `cycle'==2018 {
							qui svy: mean pv1`pv' pv2`pv' pv3`pv' pv4`pv' pv5`pv' pv6`pv' pv7`pv' pv8`pv' pv9`pv' pv10`pv' 
							local mean=(_b[pv1`pv']+_b[pv2`pv']+_b[pv3`pv']+_b[pv4`pv']+_b[pv5`pv']+_b[pv6`pv']+_b[pv7`pv']+_b[pv8`pv']+_b[pv9`pv']+_b[pv10`pv'])/10
							local U=(_se[pv1`pv']^2+_se[pv2`pv']^2+_se[pv3`pv']^2+_se[pv4`pv']^2+_se[pv5`pv']^2+_se[pv6`pv']^2+_se[pv7`pv']^2+_se[pv8`pv']^2+_se[pv9`pv']^2+_se[pv10`pv']^2)/10
							local imp=( (`mean'-_b[pv1`pv'])^2+(`mean'-_b[pv2`pv'])^2+(`mean'-_b[pv3`pv'])^2+(`mean'-_b[pv4`pv'])^2+(`mean'-_b[pv5`pv'])^2+(`mean'-_b[pv6`pv'])^2+(`mean'-_b[pv7`pv'])^2+(`mean'-_b[pv8`pv'])^2+(`mean'-_b[pv9`pv'])^2+(`mean'-_b[pv10`pv'])^2 )/9
							local se=sqrt(`U'+1.1*`imp')
							}
						else {
							qui svy: mean pv1`pv' pv2`pv' pv3`pv' pv4`pv' pv5`pv' 
							local mean=(_b[pv1`pv']+_b[pv2`pv']+_b[pv3`pv']+_b[pv4`pv']+_b[pv5`pv'])/5
							local U=(_se[pv1`pv']^2+_se[pv2`pv']^2+_se[pv3`pv']^2+_se[pv4`pv']^2+_se[pv5`pv']^2)/5
							local imp=( (`mean'-_b[pv1`pv'])^2+(`mean'-_b[pv2`pv'])^2+(`mean'-_b[pv3`pv'])^2+(`mean'-_b[pv4`pv'])^2+(`mean'-_b[pv5`pv'])^2 )/4
							local se=sqrt(`U'+1.2*`imp')
							}
						}
					else {
						forvalues ip=1(1)`ilepv' {
							qui sum pv`ip'`pv' [aw=w_fstuwt] , detail
							if "`stat'"=="sd" & "`SAS'"!="" local mean`ip'=`r(sd)'*sqrt((`r(N)'-1)/`r(N)')
							else local mean`ip'=r(`stat')
							}							
						if `cycle'==2015 | `cycle'==2018 {
							local mean=(`mean1'+`mean2'+`mean3'+`mean4'+`mean5'+`mean6'+`mean7'+`mean8'+`mean9'+`mean10')/10
							}
						else {
							local mean=(`mean1'+`mean2'+`mean3'+`mean4'+`mean5')/5
							}
						local se=0						
						}
					}
					
					local OECD_`stat'_`pv'_`i'=`OECD_`stat'_`pv'_`i''+`mean'
					local OECD_SE_`stat'_`pv'_`i'=`OECD_SE_`stat'_`pv'_`i''+`se'^2
					local mean=string(round(`mean',`decimal'),"%12.`round'f")
					local noc_`stat'_`pv'_`i'=`noc_`stat'_`pv'_`i''+1
					local se=string(round(`se',`decimal'),"%12.`round'f")
					
					if abs(`mean'/`se')>=1.96 file write `tempfile' `"<td style="text-align:center">`bold' `mean' </b></td>"' `"<td style="text-align:center">`se'</td>"'
					else file write `tempfile' `"<td style="text-align:center"> `mean' </td>"' `"<td style="text-align:center">`se'</td>"'
					}
				  }
			 else {
				if `obs'!=0 foreach stat in `stats' {
								file write `tempfile' `"<td style="text-align:center">c</td>"' `"<td style="text-align:center">c</td>"'
								}
				else foreach stat in `stats' {
					file write `tempfile' `"<td style="text-align:center">m</td>"' `"<td style="text-align:center">m</td>"'
					}
				}
			  }
			}
					

		foreach var in `varlist' {
			di as text "`var': " _c
						
			forvalues i=1(1)`n_over' {
			 if 1!=`n_over' di as input "`i' " _c
				cap restore
				cap drop `probka'
				qui gen `probka'=1 `if' cnt=="`l'" & `over'==over_values[`i',1] `in'
			 
				preserve
				qui keep if `probka'==1
				qui keep `tokeep'	
				
			  foreach stat in `stats' {
			  di as input "`stat' " _c
			
			  cap tab `schoolid' if `var'!=. , nofreq
			  local no_of_schools=`r(r)'
			  qui sum `var' [aw=w_fstuwt], detail
			  local obs=`r(N)'
								
			  if `r(N)'>30 & `no_of_schools'>5 { 
			  
				if "`stat'"=="sd" & "`SAS'"!="" local mean=`r(sd)'*sqrt((`r(N)'-1)/`r(N)')
				else local mean=r(`stat')
											
				local variance=0
				if "`fast'"=="" {
					if "`stat'"=="mean" forvalues j=1(1)80 {
						sum `var' [aw=`repwt'`j'] , meanonly
						local variance=`variance'+(`mean'-`r(mean)')^2
						}
					else if "`SAS'"!="" forvalues j=1(1)80 {
										qui sum `var' [aw=`repwt'`j'] , detail
										if "`stat'"=="sd" local variance=`variance'+(`mean'-`r(sd)'*sqrt((`r(N)'-1)/`r(N)'))^2 	
										else local variance=`variance'+(`mean'-`r(`stat')')^2
										}
						else forvalues j=1(1)80 {
									qui sum `var' [aw=`repwt'`j'] , detail
									local variance=`variance'+(`mean'-`r(`stat')')^2
									}
					local se=sqrt(`variance'/20)
				}
				else if "`fast'"!="" {
					if "`stat'"=="mean" {
						qui svy: mean `var' 
						local mean=_b[`var']
						local se=_se[`var']
						}
					else {
						qui sum `var' [aw=w_fstuwt] , detail
						if "`stat'"=="sd" {
							local mean=`r(sd)'*sqrt((`r(N)'-1)/`r(N)')
							}
						else {
							local mean=r(`stat')
							}
						local se=0						
						}
					}
						
				local OECD_`stat'_`var'_`i'=`OECD_`stat'_`var'_`i''+`mean'
				local OECD_SE_`stat'_`var'_`i'=`OECD_SE_`stat'_`var'_`i''+`se'^2
				local noc_`stat'_`var'_`i'=`noc_`stat'_`var'_`i''+1
				local mean=string(round(`mean',`decimal'),"%12.`round'f")
				local se=string(round(`se',`decimal'),"%12.`round'f")
				
				if abs(`mean'/`se')>=1.96 file write `tempfile' `"<td style="text-align:center">`bold' `mean' </b></td>"' `"<td style="text-align:center">`se'</td>"'
				else file write `tempfile' `"<td style="text-align:center"> `mean' </td>"' `"<td style="text-align:center">`se'</td>"'
				}
			  else if `obs'!=0 file write `tempfile' `"<td style="text-align:center">c</td>"' `"<td style="text-align:center">c</td>"'
				else file write `tempfile' `"<td style="text-align:center">m</td>"' `"<td style="text-align:center">m</td>"'
			}
		 }
		}
	}
}

file write `tempfile' _n "<tr> </table> </BODY></HTML>"
file close `tempfile' 
di ""
di "Results saved in the `save'.html file"

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


