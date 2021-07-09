* version 2, NOV2013
* Maciej Jakubowski and Artur Pokropek
* decomposition with PISA data
* you need to install all the necessary user-written packages before using pisadeco

cap program drop pisadeco
program define pisadeco

syntax [namelist(min=2)] [if] [in], group(varname numeric) cnt(string) save(string) cmd(string) ///
[cmdops(string) cycle(integer 2012) over(varname numeric) fast round(integer 2) weight(string) ]

version 10.0

marksample touse

if inlist(`cycle',2000,2003,2006,2009,2012)==0 {
	di as error "There was no PISA `cycle'. Please specify a proper cycle year"
	exit 198
	}
if `cycle'==. local cycle=2012
	
if "`weight'"=="" {
	local mainweight="w_fstuwt"
	local repweight="w_fstr"
	}
else {
	local mainweight="`weight'0"
	local repweight="`weight'"
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

tempvar test
qui gen `test'=1 
foreach var of local varlist {
	capture confirm numeric variable `var'
	if !_rc {
		qui replace `test'=`test'*`var'
		}
    else {
        di as error "`var' is not a numeric variable"
         }
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
				}
			
if `pv'==1 {
	qui replace `test'=`test'*pv1`outcome'
	}
else {
	capture confirm numeric variable `outcome'
	if !_rc {
		qui replace `test'=`test'*`outcome'
		}
    else {
        di as error "`outcome' is not a numeric variable"
         }
	}
	
local n_vars: word count `varlist'

if "`over'"!="" {
	tab `over', nofreq matrow(over_values)
	local n_over=r(r)
	}
else {
	local over="1"
	matrix over_values=(1,1)
	local n_over=1
	}

if "`cmd'"=="" {
	di as error "Please specify the cmd() option"
	}
else {
	if `pv'==1 local tempout="pv1`outcome'"
	else local tempout="`outcome'"
	if "`cmd'"=="oaxaca" {
		cap oaxaca `tempout' `varlist' [aw=`mainweight'], by(`group') nose
		if !_rc {
			local groupvar="by"
			local nose="nose"
			mat b=e(b)
			local ncol=colsof(b)
			}
		else {
			di as error "Your specification of the command -`cmd'- does not work. Before running pisadeco please check why this command does not work: `cmd' `tempout' `varlist' [aw=`mainweight'], group(`group')""
			}
		}
	else if "`cmd'"=="counterfactual" | "`cmd'"=="cdeco" | "`cmd'"=="cdeco_jmp" {
		{
		cap `cmd' `tempout' `varlist' [aw=`mainweight'], group(`group') noboot
		if !_rc {
			local groupvar="group"
			local nose="noboot"
			mat b=e(b)
			local ncol=colsof(b)
			}
		else {
			di as error "Your specification of the command -`cmd'- does not work. Before running pisadeco please check why this command does not work: `cmd' `tempout' `varlist' [aw=`mainweight'], group(`group')"
			}
		}
	}
		
************ PREPARING OUTPUT FILE	
	
tempname tempfile
file open `tempfile' using "`save'.html", write replace
file write `tempfile' `"<HTML><HEAD></HEAD><BODY>"' "<tr> <td> </td>"

* TABLE HEADER - OVER CATEGORIES - if over() specified
if `n_over'>1 {
	local col_span=2*`ncol'
	file write `tempfile' `"<table width="100%" style="text-family:arial;font-size:13px"> <td>Over categories:</td>"'
	forvalues i=1(1)`n_over' {
		local numerek=over_values[`i',1]
		local labelka: label (`over') `numerek'
		file write `tempfile' `"<th colspan="`col_span'">`labelka'</th>"'
		}
	}

* SECOND ROW - predictors
local nazwy: colfullnames b
file write `tempfile' `"<table width="100%" style="text-family:arial;font-size:13px"> <td> </td>"'
forvalues i=1(1)`n_over' {
	forvalues col=1(1)`ncol' {
		local nazwa: word `col' of `nazwy'
		file write `tempfile' `"<th colspan="2">`nazwa'</th>"'
		}
	}
	
* THIRD ROW - coef and SE row
file write `tempfile' "<tr><td>" "Country" "</td>"
forvalues i=1(1)`n_over' {
	forvalues col=1(1)`ncol' {
			file write `tempfile' `"<td style="text-align:center">"' "Coef." "</td>" `"<td style="text-align:center">"' "S.E." "</td>"
			local OECD_`var'`col'_`i'=0
			local OECD_SE_`var'`col'_`i'=0
			}
		}

local decimal=0.1^`round'

local how_many : word count `cnt'
local ile : word count `varlist'

forvalues i=1(1)`n_over' {
	local noc_`i'=0
	}
	
local tokeep="`varlist' `mainweight' `repweight'* `group'"
if `pv'==1 local tokeep="`tokeep' pv*`outcome'"
else local tokeep="`tokeep' `outcome'"
if "`fast'"!="" local tokeep="`tokeep' schoolid"

local OECD_saved=0

foreach l of local cnt {
	di ""
  	di as result "`l'"  _continue

	if "`l'"=="OECD" {
		file write `tempfile' `"<tr style="background-color:yellow"> <td><b>OECD Average</td>"'
		local OECD_saved=1
		forvalues i=1(1)`n_over' {
			forvalues col=1(1)`ncol' {
				local mean=string(round(`OECD_`col'_`i''/`noc_`i'',`decimal'),"%12.`round'f")
				local se=string(round(sqrt(`OECD_SE_`col'_`i'')/`noc_`i'',`decimal'),"%12.`round'f")
				if abs((`OECD_`col'_`i''/`noc_`i'')/(sqrt(`OECD_SE_`col'_`i'')/`noc_`i''))>=1.96 & `OECD_`var'`col'_`i''!=0 file write `tempfile' `"<td style="text-align:center;background-color:yellow"> <b> `mean' </b></td> <td style="text-align:center"> `se' </td> "'
				else file write `tempfile' `"<td style="text-align:center;background-color:yellow"> `mean' </td> <td style="text-align:center"> `se' </td> </td> "'
				}
			}
		file write `tempfile' `"<tr><td><b>Partner countries and economies</td>"'
		}	
	else {
		_cnt `l'
		local name=r(name)
		file write `tempfile' "<tr><td>" "`name'" "</td>"
		
		forvalues i=1(1)`n_over' {
			if 1!=`n_over' di as text " `i'" _c
			
			sum `test' if cnt=="`l'" & `over'==over_values[`i',1], meanonly
			local nonmissing=r(N)
			cap tab schoolid if `test'!=. & cnt=="`l'" & `over'==over_values[`i',1], nofreq
			
			if `nonmissing'>30 & r(r)>5 {
			 cap drop `probka'
			 qui gen `probka'=1 `if' cnt=="`l'" & `over'==over_values[`i',1] `in'

			 preserve
			 qui keep if `probka'==1
			 qui keep `tokeep' `probka'
			 
			 if `pv'==1 {
			 	if "`fast'"=="" {
					forvalues ip=1(1)5 {	
						di as text "." _c
						_decobrr pv`ip'`outcome' `varlist', cmd(`cmd') cmdops("`nose' `cmdops'") group(`group') groupvar(`groupvar') mainweight(`mainweight') repweight(`repweight')
						matrix b`ip'=r(coef)
						matrix se`ip'=r(se)
						}
					* HERE CALCULATES MATRICES WITH MEANS AND SEs FROM FIVE PVs
					mata: pvmat()
					}
				else {					
					forvalues ip=1(1)5 {
						di as text "." _c
						_decofast pv`ip'`outcome' `varlist', cmd(`cmd') cmdops("`nose' `cmdops'") group(`group') groupvar(`groupvar') mainweight(`mainweight')
						matrix b`ip'=r(coef)
						}
					mata: pvfast()
					}
			  }
			else if `pv'!=1 {
					_decobrr `outcome' `varlist', cmd(`cmd') cmdops("`nose' `cmdops'") group(`group') groupvar(`groupvar') mainweight(`mainweight') repweight(`repweight')
					matrix b=r(coef)
					matrix se=r(se)
					}
			restore
						
			local noc_`i'=`noc_`i''+1
			forvalues col=1(1)`ncol' {
				local b=b[1,`col']
				if "`fast'"=="" local se=se[1,`col']
				else local se=.
				if `b'==0 & `se'==0 {
					file write `tempfile' `"<td style="text-align:center"> 0 </td>"' `"<td style="text-align:center"> 0 </td>"'
					}
				else {
					local mean=string(round(`b',`decimal'),"%12.`round'f")
					local se=string(round(`se',`decimal'),"%12.`round'f")
					if abs(`mean'/`se')>=1.96 file write `tempfile' `"<td style="text-align:center"><b> `mean' </b></td>"' `"<td style="text-align:center">`se'</td>"'
					else file write `tempfile' `"<td style="text-align:center"> `mean' </td>"' `"<td style="text-align:center">`se'</td>"'
																	
					local OECD_`col'_`i'=`OECD_`col'_`i''+`mean'
					local OECD_SE_`col'_`i'=`OECD_SE_`col'_`i''+`se'^2
					}

				}
			}
		}
	}
  }
}

if `OECD_saved'==0 {
	file write `tempfile' `"<tr style="background-color:yellow"> <td><b>Average</td>"'
	forvalues i=1(1)`n_over' {
		forvalues col=1(1)`ncol' {
			local mean=string(round(`OECD_`col'_`i''/`noc_`i'',`decimal'),"%12.`round'f")
			local se=string(round(sqrt(`OECD_SE_`col'_`i'')/`noc_`i'',`decimal'),"%12.`round'f")
			if abs((`OECD_`col'_`i''/`noc_`i'')/(sqrt(`OECD_SE_`col'_`i'')/`noc_`i''))>=1.96 & `OECD_`col'_`i''!=0 file write `tempfile' `"<td style="text-align:center;background-color:yellow"> <b> `mean' </b></td> <td style="text-align:center"> `se' </td> "'
			else file write `tempfile' `"<td style="text-align:center;background-color:yellow"> `mean' </td> <td style="text-align:center"> `se' </td> </td> "'
			}
		}
	}	


file write `tempfile' _n "<tr> </table> </BODY></HTML>"
file close `tempfile' 
di ""
di "Results saved in the `save'.html file"

end


******************************************************
					
cap program drop _decobrr
program define _decobrr, rclass
						
syntax [namelist(min=2)],  cmd(string) cmdops(string) group(varname numeric) groupvar(string) mainweight(string) repweight(string)

tokenize `namelist'
local outcome `1'
macro shift
local varlist `*'

tempname point repvar

* point estimates with one plausible value
qui `cmd' `outcome' `varlist' [aw=`mainweight'], `cmdops' `groupvar'(`group')
mat point=e(b)

local ncols=colsof(point)
mat var=J(1,`ncols',0)
			
forvalues j=1(1)80 {
	qui `cmd' `outcome' `varlist' [aw=`repweight'`j'], `cmdops' `groupvar'(`group')
	mat b=e(b)
	forvalues col=1(1)`ncols' {
		mat var[1,`col']=var[1,`col']+(point[1,`col']-b[1,`col'])^2
		}
	}
	
forvalues col=1(1)`ncols' {
		mat var[1,`col']=sqrt(var[1,`col']/20)
		}

return matrix coef=point
return matrix se=var
					
end


******

cap program drop _decofast
program define _decofast, rclass
												
syntax [namelist(min=2)],  cmd(string) cmdops(string) group(varname numeric) groupvar(string) mainweight(string)

tokenize `namelist'
local outcome `1'
macro shift
local varlist `*'

tempname point

qui `cmd' `outcome' `varlist' [aw=`mainweight'], `cmdops' `groupvar'(`group')
mat point=e(b)

return matrix coef=point
					
end

*********


version 9
cap mata: mata drop pvmat()
mata:
mata set matastrict off

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

*****************
	
cap mata: mata drop pvfast()
mata:
mata set matastrict off

void pvfast()
  {
	 b1 = st_matrix("b1")
	 b2 = st_matrix("b2")
	 b3 = st_matrix("b3")
	 b4 = st_matrix("b4")
	 b5 = st_matrix("b5")
	b = (b1+b2+b3+b4+b5):/5
	st_matrix("b",b)
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
	if "`l'"=="BRA" local name="Brazil"
	if "`l'"=="CAN" local name="Canada"
	if "`l'"=="CHE" local name="Switzerland"
	if "`l'"=="CHL" local name="Chile"
	if "`l'"=="CHN" local name="Shanghai-China"
	if "`l'"=="COL" local name="Colombia"
	if "`l'"=="CRI" local name="Costa Rica"
	if "`l'"=="CZE" local name="Czech Republic"
	if "`l'"=="DEU" local name="Germany"
	if "`l'"=="DNK" local name="Denmark"
	if "`l'"=="ESP" local name="Spain"
	if "`l'"=="EST" local name="Estonia"
	if "`l'"=="FIN" local name="Finland"
	if "`l'"=="FRA" local name="France"
	if "`l'"=="GBR" local name="United Kingdom"
	if "`l'"=="GRC" local name="Greece"
	if "`l'"=="HKG" local name="Hong Kong-China"
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
	if "`l'"=="LIE" local name="Liechtenstein"
	if "`l'"=="LTU" local name="Lithuania"
	if "`l'"=="LUX" local name="Luxembourg"
	if "`l'"=="LVA" local name="Latvia"
	if "`l'"=="MAC" local name="Macao-China"
	if "`l'"=="MEX" local name="Mexico"
	if "`l'"=="MKD" local name="Macedonia"
	if "`l'"=="MNE" local name="Montenegro"
	if "`l'"=="MYS" local name="Malaysia"
	if "`l'"=="NLD" local name="Netherlands"
	if "`l'"=="NOR" local name="Norway"
	if "`l'"=="NZL" local name="New Zealand"
	if "`l'"=="PAN" local name="Panama"
	if "`l'"=="PER" local name="Peru"
	if "`l'"=="POL" local name="Poland"
	if "`l'"=="PRT" local name="Portugal"
	if "`l'"=="QAT" local name="Qatar"
	if "`l'"=="QCN" local name="Shanghai-China"
	if "`l'"=="QAR" local name="Dubai (UAE)"
	if "`l'"=="QRS" local name="Perm(Russian Federation)"
	if "`l'"=="QUA" local name="Florida (USA)"
	if "`l'"=="QUB" local name="Connecticut (USA)"
	if "`l'"=="QUC" local name="Massachusetts (USA)"
	if "`l'"=="ROU" | "`l'"=="ROM" local name="Romania"
	if "`l'"=="RUS" local name="Russian Federation"
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
	
			
	return local cnt "`cnt'"
	
end


