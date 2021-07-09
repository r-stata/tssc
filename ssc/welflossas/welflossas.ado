*! version 1.0 17march2017 Alicia Pérez-Alonso

capture program drop welflossas
program def welflossas , rclass byable(recall) sortpreserve 
version 13 /* This program was written on Stata 14.2 but it was tested that it also runs successfully on version 13 of Stata. */
syntax varlist(min=2 max=3) [aweight fweight iweight] [if] [in] [ , AGgregate ADDStatus CALLFile(string) CALLVar(string) SAVing(string) STats(string) THRincl(real 0) NOGraph Format(string)]
args occp white wage 
tempname F wagemv wtot Wj Wjg index rowtot coltot RN  /*
     */ Psi Omega WAD EgapAS Decomp dtilde dtildein FGT pop aux Coord /*	
	*/ rslt1 rslt1index rslt1group rslt1value rslt2index rslt2group rslt2value
marksample touse, novarlist 

set more off
mata mata clear

if "`format'" == "" loc format "%9.4f"
di ""
di "{hline 100}"
********************************************************************************  
******************************************************************************** 
local occp:  word 1 of `varlist'
local white: word 2 of `varlist'

local stats "`stats'"
local thr `thrincl'
if (`thrincl'<0){
	di as error "Error: threshold must be non-negative."
	exit
	}
	
quietly: tab `occp' `white' [`weight' `exp'] if `touse', matcell(`F') matcol(`white')	
local rr0 = r(r)

qui levelsof `occp' if `touse', local(lo)  
qui levelsof `white' if `touse', local(lw) 
******************************************************************************** 
if "`aggregate'" =="" {	
	if length(`"`addstatus'"')!= 0 {	
		di as error "Error: this option is only allowed for aggregated data."
		exit
	}

	if "`stats'"=="" local stats "mean"
	if "`stats'"=="median" & "`weight'"=="iweight"{
		di as error "Error: iweights not allowed for the median."
		exit
	}
	
	local wage:  word 3 of `varlist'
	qui gen `wagemv'=`wage' if `touse'
	qui mvdecode `wagemv' if `touse',mv(0) 

	dis "Computing a family of indices measuring well-being (monetary) gain/loss and social welfare loss associated with segregation based on disaggregated data."
	dis ""

	matrix `Wjg' =J(`: word count `lo'',`: word count `lw'',.)
	matrix `Wj' =J(`: word count `lo'',1,.)
	****************************************************************************	
	if "`stats'"=="mean" {	
		su `wagemv' [`weight' `exp'] if `touse',meanonly
		scalar `wtot'=r(mean)
		
		if (`wtot'==.){
			di as error "Error: The average status of the economy cannot be missing."
			exit
		}
		
		local i = 1
		foreach k of local lo {
		su `wagemv' [`weight' `exp'] if `touse' & `occp' == `k', meanonly 
		matrix `Wj'[`i',1] = r(mean) 
		local j = 1
			foreach m of local lw {
			su `wagemv' [`weight' `exp'] if `touse' & `occp' == `k' & `white' == `m', meanonly 
				if missing(r(mean)) matrix `Wjg'[`i',`j']=`Wj'[`i',1]
				else matrix `Wjg'[`i',`j'] = r(mean)
			local ++j
			}
		local ++i
		}
	}
	****************************************************************************
	if "`stats'"=="median" {	
		qui su `wagemv' [`weight' `exp'] if `touse',detail
		scalar `wtot'=r(p50)
	
		if (`wtot'==.){
			di as error "Error: The median status of the economy cannot be missing."
			exit
		}
		
		local i = 1
		foreach k of local lo {
		qui su `wagemv' [`weight' `exp'] if `touse' & `occp' == `k', detail 
		matrix `Wj'[`i',1] = r(p50) 
		local j = 1
			foreach m of local lw {
			qui su `wagemv' [`weight' `exp'] if `touse' & `occp' == `k' & `white' == `m', detail 
				if missing(r(p50)) matrix `Wjg'[`i',`j']=`Wj'[`i',1]
				else matrix `Wjg'[`i',`j'] = r(p50)
			local ++j
			}
		local ++i
		}
	}
	****************************************************************************
	mata: st_matrix(st_local("index"),selectindex(rowmissing(st_matrix("`Wj'")):==0))
	mata: st_matrix(st_local("Wjg"),st_matrix("`Wjg'")[st_matrix("`index'"),.]) 
	mata: st_matrix(st_local("Wj"),st_matrix("`Wj'")[st_matrix("`index'"),.])
	mata: st_matrix(st_local("F"),st_matrix("`F'")[st_matrix("`index'"),.])	
}
********************************************************************************
else {
	if length(`"`addstatus'"')!= 0 {
		preserve
		qui keep if `touse' 
		sort `occp' `white'
		
		local wage "`callvar'"
		local mm=`"m:1"'
		
		merge `mm' `occp' using "`callfile'",keep(match) keepusing(`wage') nogenerate /*tamén podería pór quietly*/
		if length(`"`saving'"') != 0 save "`saving'.dta", replace
	}
	else{
		local wage:  word 3 of `varlist'
		if ("`wage'"==""){
			di as error "Error: A third argument (status) is required."
			exit
		}
	}
	
	if "`stats'"!="" {
		di "Warning: status does not vary in within-unit for different groups. Mean and median produce the same output."
	}
	
	dis ""
	dis "Computing a family of indices measuring well-being (monetary) gain/loss and social welfare loss associated with segregation based on aggregated (by unit) data."
	dis ""
	
	qui gen `wagemv'=`wage' if `touse'
	qui mvdecode `wagemv' if `touse',mv(0) 
    su `wagemv' [`weight' `exp'] if `touse',meanonly
	scalar `wtot'=r(mean)
	
	if (`wtot'==.){
		di as error "Error: The average status of the economy cannot be missing."
		exit
	}
		
	matrix `Wj' =J(`: word count `lo'',1,.)
	local i = 1
	foreach k of local lo {
	 su `wagemv' [`weight' `exp'] if `touse' & `occp' == `k', meanonly 
	 matrix `Wj'[`i',1] = r(mean) 
	 local ++i
    }
	
	mata: st_matrix(st_local("index"),selectindex(rowmissing(st_matrix("`Wj'")):==0))
	mata: st_matrix(st_local("Wj"),st_matrix("`Wj'")[st_matrix("`index'"),.])
	mata: st_matrix(st_local("F"),st_matrix("`F'")[st_matrix("`index'"),.])	
}
******************************************************************************** 

mata: st_matrix(st_local("rowtot"),rowsum(st_matrix("`F'"))) /* rows x 1 */
mata: st_matrix(st_local("coltot"),colsum(st_matrix("`F'"))) /* 1 x cols */
mata: st_matrix(st_local("RN"),rowsum(st_matrix("`coltot'")))

local  rn=`RN'[1,1] 
local  rc=colsof(`F')
local  rr=rowsof(`F')
local occpdrop=`rr0'-`rr'
******************************************************************************** 
********************************************************************************
if "`aggregate'" =="" {	 
	matrix `Psi'   = J(5,`rc',0)
	matrix `Omega' = J(5,`rc',0)

	forvalues i = 1 / `rc' {
		forvalues j = 1 / `rr' {
		************************************************************************
        *epsilon=0
		matrix	`Psi'[1,`i']  = `Psi'[1,`i']  + ((`F'[`j',`i'] /`coltot'[1,`i'])-(`rowtot'[`j',1] / `rn'))*(`Wj'[`j',1]/`wtot')
		matrix `Omega'[1,`i']  = `Omega'[1,`i']  + (`F'[`j',`i'] /`coltot'[1,`i'])*((`Wjg'[`j',`i']/`wtot')-(`Wj'[`j',1]/`wtot'))
		************************************************************************
		*epsilon=1
		matrix	`Psi'[2,`i'] = `Psi'[2,`i']  + ((`F'[`j',`i'] /`coltot'[1,`i'])-(`rowtot'[`j',1] / `rn'))*ln(`Wj'[`j',1]/`wtot')	
		matrix `Omega'[2,`i']  = `Omega'[2,`i']  + (`F'[`j',`i'] /`coltot'[1,`i'])*(ln(`Wjg'[`j',`i']/`wtot')-ln(`Wj'[`j',1]/`wtot'))
		************************************************************************
		*epsilon=2,3,4
		local k=3
		foreach epsilon of numlist 2 3 4 {
			matrix	`Psi'[`k',`i'] = `Psi'[`k',`i']  + (((`F'[`j',`i'] /`coltot'[1,`i'])-(`rowtot'[`j',1] / `rn'))*((`Wj'[`j',1]/`wtot')^(1-`epsilon')-1))/(1-`epsilon')
			matrix	`Omega'[`k',`i'] = `Omega'[`k',`i']  + ((`F'[`j',`i'] /`coltot'[1,`i'])*(((`Wjg'[`j',`i']/`wtot')^(1-`epsilon')-1)-((`Wj'[`j',1]/`wtot')^(1-`epsilon')-1)))/(1-`epsilon')	
			local ++k
			}	
		}
	}

	mata:	st_matrix(st_local("WAD"), st_matrix("`Psi'")+ st_matrix("`Omega'")) 
	mata:	st_matrix(st_local("EgapAS"), st_matrix("`Psi'")[1,.]:/st_matrix("`WAD'")[1,.]) 

	if "`nograph'"~= "nograph" {
		matrix `Decomp'=`Psi'[1,1...]*100 \ `Omega'[1,1...]*100 \ `WAD'[1,1...]*100 \ `white'
		matrix `Decomp'=`Decomp''

		cap drop _Decomp*
		svmat `Decomp',names(_Decomp)  

		graph bar (asis) _Decomp1 _Decomp2 in 1/`rc', over(_Decomp4) stack legend(label(1 "Segregation") label(2 "Within-unit status disparities") size(small))/*
		*/title("Decomposition of the per capita earning gap ratio (EGap x 100)", span size(medium))/*
		*/saving(grEGap,replace)

		cap drop _Decomp*
	}
}
********************************************************************************
else{
	matrix `Psi'   = J(5,`rc',0)
	
	forvalues i = 1 / `rc' {
		forvalues j = 1 / `rr' {
		******************************************************
        *epsilon=0
		matrix	`Psi'[1,`i']  = `Psi'[1,`i']  + ((`F'[`j',`i'] /`coltot'[1,`i'])-(`rowtot'[`j',1] / `rn'))*(`Wj'[`j',1]/`wtot')
		******************************************************
		*epsilon=1  
		matrix	`Psi'[2,`i'] = `Psi'[2,`i']  + ((`F'[`j',`i'] /`coltot'[1,`i'])-(`rowtot'[`j',1] / `rn'))*ln(`Wj'[`j',1]/`wtot')	
		******************************************************
		*epsilon=2,3,4
		local k=3
		foreach epsilon of numlist 2 3 4 {
			matrix	`Psi'[`k',`i'] = `Psi'[`k',`i']  + (((`F'[`j',`i'] /`coltot'[1,`i'])-(`rowtot'[`j',1] / `rn'))*((`Wj'[`j',1]/`wtot')^(1-`epsilon')-1))/(1-`epsilon')
			local ++k
			}	
		}
	}
}
********************************************************************************
********************************************************************************
matrix `dtilde'   = J(5,`rc',.)
forvalues j = 1/`rc' {
	matrix `dtilde'[1 , `j']= abs(min(`Psi'[1 , `j'],`thr'))	
	forvalues i = 2/5 {
		matrix `dtilde'[`i' , `j']= abs(min(`Psi'[`i', `j'],0))
	}
}
	
mata: st_matrix(st_local("dtildein"),st_matrix("`dtilde'"):!=0)  
mata: st_matrix(st_local("pop"),st_matrix("`coltot'")/`rn') 
mata: st_matrix(st_local("FGT"),rowsum(st_matrix("`pop'"):* st_matrix("`dtildein'"))) 

local k=1
foreach a of numlist 1 2 3{
	tempname FGT`k'
	mata: st_matrix(st_local("FGT`k'"),rowsum(st_matrix("`pop'"):* st_matrix("`dtilde'"):^`a')) 
	matrix `FGT'=`FGT',`FGT`k''  
	local ++k
}	
********************************************************************************

cap drop _p*  
cap drop _Wd*
cap drop _TIP*

local x "_p"
local y "_Wd"
local rc1=`rc'+1

mata : st_matrix(st_local("aux"),st_matrix("`pop'"):* st_matrix("`dtilde'")) 

forvalues i=1/5 {	
	tempname TIP`i'
	tempname Coords`i'
	mat `TIP`i'' = (`dtilde'[`i',1...] \ `pop'\ `aux'[`i',1...])'
		
	mata: st_matrix(st_local("TIP`i'"),sort(st_matrix("`TIP`i''"),(-1,2)))
			
	mat `TIP`i'' = `TIP`i''[1...,2..3]
	mat `TIP`i'' = (0 , 0) \ `TIP`i''
	
	svmat `TIP`i'',names(_TIP`i'_)  
	ren _TIP`i'_1 `x'`i' 
	ren _TIP`i'_2 `y'`i'
		
	qui replace `x'`i'=sum(`x'`i') in 1/`rc1'
	qui replace `y'`i'=sum(`y'`i') in 1/`rc1'
			
	mkmat `x'`i' `y'`i' in 1/`rc1',mat(`Coords`i'')
		
	qui replace `x'`i'=`x'`i'*100 in 1/`rc1'
	qui replace `y'`i'=`y'`i'*100 in 1/`rc1'
}

mat `Coord'=(`Coords1'[2...,.], `Coords2'[2...,.], `Coords3'[2...,.], `Coords4'[2...,.], `Coords5'[2...,.])

if "`nograph'"~= "nograph" {
	local xtitle "cumulative population share"
	local ytitle "cumulative sum of well-being losses divided by T"
	local graph_options "plotr(m(zero)) connect(l) lpattern(solid) lwidth(medium) lcolor(black) xtick(0(10)100) xlabel(0(10)100,labsize(small)) ylabel(,labsize(small)) xtitle("`xtitle'", size(small) ) ytitle("`ytitle'", size(small) )"

	local graphs ""
	forvalues i=1/5 {	
		local j=`i'-1
		graph twoway line `y'`i' `x'`i' in 1/`rc1',`graph_options' title("{&epsilon} = `j'",size(small)) name(g`i', replace) nodraw
		local graphs "`graphs' g`i'"
	}
	graph combine `graphs', col(3) title("Social Welfare Loss curves associated with segregation (WLAS{sub:{&epsilon}} x 100)",size(small)) saving(grWLAS,replace)	
}
	
cap drop _p* _Wd* 
******************************************************************************** 
******************************************************************************** 
*Preparing results
if "`aggregate'" =="" {	
	mat `rslt1'= ( `pop' \ `Psi' \ `Omega' \ `WAD' \ `EgapAS' )
	mat rownames `rslt1' = "share" Gamma_Psi0 Psi1 Psi2 Psi3 Psi4 Delta_Omega0 Omega1 Omega2 Omega3 Omega4 EGap_WAD0 WAD1 WAD2 WAD3 WAD4 seg_Egap
}
else{
	mat `rslt1'= ( `pop' \ `Psi' )
	mat rownames `rslt1' = "share" Gamma_Psi0 Psi1 Psi2 Psi3 Psi4  
}

local r_rslt1=rowsof(`rslt1')
local n_rslt1=rowsof(`rslt1')*`rc'
  
local k=1
qui range `rslt1index' . `n_rslt1' `n_rslt1' /* Create n_rslt1 obs on index from . to n_rslt1 */
qui range `rslt1value' . `n_rslt1' `n_rslt1'
qui range `rslt1group' . `n_rslt1' `n_rslt1'
forvalues j= 1/`rc' {
	forvalues i=1/`r_rslt1 ' {
		qui replace `rslt1index'=`i' 			  if _n==`k'
		qui replace `rslt1value'=`rslt1'[`i',`j'] if _n==`k'
		qui replace `rslt1group'=`white'[1,`j']   if _n==`k'
		local ++k
	}
}

lab def `rslt1index' 1 "pop-share" 2 "Gamma:Psi{eps=0}" 3 "Psi{epsilon=1}" 4 "Psi{epsilon=2}" 5 "Psi{epsilon=3}" 6 "Psi{epsilon=4}" 7 "Delta:Omega{eps=0}" 8 "Omega{epsilon=1}" /*
*/ 9 "Omega{epsilon=2}" 10 "Omega{epsilon=3}" 11 "Omega{epsilon=4}" 12 "EGap:WAD{eps=0}"  13 "WAD{epsilon=1}" 14 "WAD{epsilon=2}" 15 "WAD{epsilon=3}" 16 "WAD{epsilon=4}" 17 "seg-EGap"
lab val `rslt1index' `rslt1index'
lab var `rslt1index' "Measures of well-being (monetary) gain/loss associated with segregation"

cap lab copy `white' `rslt1group'
cap lab val  `rslt1group' `rslt1group'   
cap lab var  `rslt1group' "`white'"  

********************************************************************************
mat colnames `Coord'= x(cumshare0) y(WLAS0) x(cumshare1) y(WLAS1) x(cumshare2) y(WLAS2) x(cumshare3) y(WLAS3) x(cumshare4) y(WLAS4) 
mat colnames `FGT'= FGT0 FGT1 FGT2 FGT3
mat rownames `FGT'= epsilon0 epsilon1 epsilon2 epsilon3 epsilon4

local k=1
qui range `rslt2index' . 20 20 
qui range `rslt2value' . 20 20
qui range `rslt2group' . 20 20
forvalues j= 1/4 {
	forvalues i=1/5 {
		qui replace `rslt2index'=`i' 			if _n==`k'
		qui replace `rslt2value'=`FGT'[`i',`j'] if _n==`k'
		qui replace `rslt2group'=`j'            if _n==`k'
		local ++k
	}
}

lab def  `rslt2index' 1 "epsilon=0" 2 "epsilon=1" 3 "epsilon=2" 4 "epsilon=3"  5 "epsilon=4"
lab val  `rslt2index' `rslt2index'    
lab var  `rslt2index' "FGT indices"  

lab def `rslt2group' 1 "alpha=0" 2 "alpha=1" 3 "alpha=2" 4 "alpha=3" 
lab val `rslt2group' `rslt2group'
lab var `rslt2group' "Inequality aversion parameter"

********************************************************************************  
******************************************************************************** 
*Reporting results
dis ""
dis as text "Number of units  (`occp') = " as result `rr'

if `occpdrop'!= 0 {
	di as result `occpdrop' as text " unit(s) dropped because no status is observed for any group."
    }		
dis as text "Number of groups (`white') = " as result `rc'
dis ""

lab var `rslt1value' "Population shares"
tabdisp  `rslt1group' if `rslt1value'~=. & `rslt1index'==1,  c(`rslt1value')  f(`format') concise stubwidth(20) csepwidth(1) cellwidth(20) 

lab var `rslt1value' "`white'" 
tabdisp `rslt1index' `rslt1group'    if `rslt1value'~=. & `rslt1index'>1,  c(`rslt1value')  f(`format') concise stubwidth(20) csepwidth(1) cellwidth(20) 

if "`aggregate'" =="" {	
	dis "{bf:Psi_{epsilon}}=Family of indices to quantify the well-being gain/loss of a group associated with its segregation."
	dis "{bf:Omega_{epsilon}}=The well-being gain/loss of a group due to within-unit status disparities with respect to other groups."
	dis "{bf:WAD_{epsilon}}=Total well-being advantage/disadvantage (WAD) of a group: Psi_{epsilon} + Omega_{epsilon}."
	dis "{bf:seg-EGap}=Contribution of segregation to the per capita earning gap ratio (EGap=WAD_{0}) of the group: Psi_{0}/WAD_{0}."
	dis "{ul: Note 1} {it:epsilon={0,1,2,3,4}} is the constant elasticity of the assumed utility function that can be interpreted as a (relative) inequality aversion parameter in Psi_{epsilon} indices." 
	dis "{ul: Note 2} {it:Gamma=Psi_{0}} measures the monetary gain/loss of a group associated with its segregation." 
	dis "{ul: Note 3} {it:Delta=Omega_{0}} measures the monetary gain/loss of the group associated with within-unit status disparities with respect to other groups." 
	if "`stats'"=="median"{
		dis as text "{ul: Note 4} All measures are computed using " as result "`stats'" as text " " as result "`wage'"  as text " in the economy and the unit. Default is mean."
	}
}
else{
	dis "{bf:Psi_{epsilon}}=Family of indices to quantify the well-being gain/loss of a group associated with its segregation."
	dis "{ul: Note 1} {it:epsilon={0,1,2,3,4}} is the constant elasticity of the assumed utility function that can be interpreted as a (relative) inequality aversion parameter in Psi_{epsilon} indices." 
}

dis ""
tabdisp `rslt2index' `rslt2group' if `rslt2value'~=.,  c(`rslt2value')  f(`format') concise stubwidth(20) csepwidth(1) cellwidth(10) 
dis "{bf:FGT_{alpha}}=The Foster-Greer-Thorbecke (FGT) family of poverty indices adapted to measure the social welfare loss that the society experiences due to segregation."

if "`aggregate'" =="" {	
	dis "{ul: Note 1} {it:alpha={0,1,2,3}} is an inequality aversion parameter in FGT indices."
	dis "{ul: Note 2} {it:FGT_{alpha=0}} is the headcount ratio: fraction of the population that belongs to groups that have well-being (monetary) losses associated with segregation."
	if `thr'!=0{
		dis as text "{ul: Note 3} FGT indices are computed with threshold=" as result `thr' as text " for {it:epsilon}=0. Default is threshold=0."
	}
}
else{
	dis "{ul: Note 1} {it:alpha={0,1,2,3}} is an inequality aversion parameter in FGT indices."
	dis "{ul: Note 2} {it:FGT_{alpha=0}} is the headcount ratio: fraction of the population that belongs to groups that have well-being (monetary) losses associated with segregation."
	if `thr'!=0{
		dis as text "{ul: Note 3} FGT indices and WLAS curves are computed with threshold=" as result `thr' as text " for {it:epsilon}=0. Default is threshold=0."
	}
}

dis ""
dis "{bf:References:}"
dis as text `"Del Río, C. and Alonso-Villar, O. (2017), "Segregation and Social Welfare: A Methodological Proposal with an Application to the U.S.", Social Indicators Research, forthcoming. DOI: 10.1007/s11205-017-1598-0"'
dis as text `"Alonso-Villar, O. and Del Río, C. (2016), "Local segregation and well-being", The Review of Income and Wealth. DOI: 10.1111/roiw.12224"'
dis as text `"Del Río, C. and Alonso-Villar, O. (2015), "The Evolution of Occupational Seggregation in the United States, 1940-2010: Gains and Losses of Gender-Race/Ethnicity Groups", Demography, vol. 52(3), pp. 967-988. DOI:10.1007/s13524-015-0390-5"' 
di "{hline 100}"

mat `rslt1'=`rslt1'[2...,.] 
return matrix measures=`rslt1'
return matrix share=`pop'
return matrix FGT=`FGT'
return matrix xywlas=`Coord'
********************************************************************************  
********************************************************************************
mata mata clear
end

