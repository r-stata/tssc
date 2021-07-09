*! Pogram to compute local and overall multigroup segregation
*! Carlos Gradin
*! This version 2.2, March 2015
*! It includes some new indices, accepts agggregated data, and fixes some bugs


* Written by Carlos Gradín, Universidade de Vigo		

* It requires to have matsort.ado (written by Paul Millar) previously installed

	* This program computes local and overall segregation indices across units in a multigroup context,
		* as proposed by Alonso-Villar and Del Río, 2010, based on microdata (data not collapsed by units) or in data aggregated by units
		* results saved as matrices
	* It also draws the local segregation curves if option "sc" is specified, and creates variables using "x()" and "y()" options, 
		* First variable indcates units (ex. occupations, census tracts, schools, ....), second variable identifies groups (gender, race, ...)
	* Example: "localseg occupation race [aw=pw] [if] [in], sc"
		
		
cap program drop localseg
program def localseg , rclass byable(recall)
version 10
syntax varlist [aweight iweight fweight] [if] [in] [ , AGgregate Format(string) sc NOGraph x(string) y(string) XTitle(string) YTitle(string) GRaph_options(string)  ]
args occp white
tempname F D M G Dg Ip xx Gg K1g K2g Eg E aux lseg oseg CT RT FC FR S SS SR RC RT names overall group index value /*
	*/ oindex ovalue ogroup freq S EC DC GC cont wh
marksample touse

set more off

if "`format'" == "" {
	loc format "%9.4f"
}

local n : word count `varlist'

di ""
di as text "{hline 100}"

if "`aggregate'" == "" {

	local occp:  word 1 of `varlist'
	local white: word 2 of `varlist'

	dis "Computing Local and Overall Segregation of groups (`white') across units (`occp') based on individual data"
	qui: tab `varlist' [`weight' `exp'] if `touse', matcell(`F') missing label matcol(`white')

	local rc = r(c)
	local rr = r(r)
	local rn = r(N)
}

if "`aggregate'" ~= "" {

	local occp:  word 1 of `varlist'
	mat `white'=1
	forvalues i=2/`n' {
		local g`i': word `i' of `varlist'
		local groups `groups' `g`i''
		mat `white'=`white' , `i'
	}
	local n1 = `n'-1
	mat `white'=`white'[1,1..`n1']

	dis "Computing Segregation of groups (`groups') across units (`occp') based on aggregated data "
	mkmat `groups' if `touse' , mat(`F') rowname(`occp')

	local rc = colsof(`F')
	local rr = rowsof(`F')
	mat aux  = `F''*J(`rr',`rc',1)
	local rn=0
	forvalues i=1/`rc' {
		local rn = `rn' + aux[`i',1]
	}
}

qui sum `white'
local overall = r(max) + 1

	* Check occupations with 0 observations in any group

forvalues i = 1 / `rc' {
	tempname z`i'
	qui gen `z`i''=0
	forvalues j = 1 / `rr' {
		qui replace `z`i''=`z`i''+1 if `F'[`j',`i']==0 in 1
	}
	qui sum `z`i''
	scalar  `z`i''=r(sum)
}


matrix `Dg'  = J(1,`rc',0)
matrix `Eg'  = J(9,`rc',0)
matrix `aux' = `Eg'
matrix `Gg'  = J(1,`rc',0)
matrix `K1g' = J(5,`rc',0)
matrix `K2g' = J(1,`rc',1)
	
	* Column and row totals

matrix `CT' = J(1,`rr',1)*`F'
matrix `RT' = `F'*J(`rc',1,1)

* D, K1, K2, Ip, and GE
forvalues i = 1 / `rc' {
	forvalues j = 1 / `rr' {
*		dis "i=" `i' "; j=" `j'
		matrix	`Dg'[1,`i']  = `Dg'[1,`i']  + abs( `F'[`j',`i'] / `CT'[1,`i'] - `RT'[`j',1] / `rn' ) / 2

		* Only meaning if Fji>0	(K2gi=0 if Fji=0 we replace by .)
		if `F'[`j',`i'] >0 {
			matrix	`K2g'[1,`i'] = `K2g'[1,`i'] * (  (`F'[`j',`i'] / `CT'[1,`i'])^.5  * (`RT'[`j',1] / `rn')^.5   )

		}
		else {
			matrix	`K2g'[1,`i'] = .
		}

		* Only meaning if Fji>0	(K1g=0 if any Fji=0, we replace by .)

			local k=1
			foreach a of numlist .10 .30 .50 .70 .90 {
				if `F'[`j',`i'] >0 {
					matrix	`K1g'[`k',`i'] = `K1g'[`k',`i'] + (  (`F'[`j',`i'] / `CT'[1,`i'])^`a' * (`RT'[`j',1] / `rn')^`a'  ) / `rr'
				}
				else {
					matrix	`K1g'[`k',`i'] = .	
				}
				local k=`k'+1
			}	

		local k=3
		foreach c of numlist .10 .25 .50 .75 .90 2 {
			matrix	`aux'[`k',`i'] = `aux'[`k',`i'] + ( (`RT'[`j',1] / `rn')*(( (`F'[`j',`i'] / `CT'[1,`i']) / (`RT'[`j',1] / `rn') )^`c' - 1 )) / (`c'*(`c'-1))			
			local k=`k'+1
		}	
		*c=1, 					if Fji=0, lim [xln(x)]=0 if x->0;
		if `F'[`j',`i'] >0 {
		matrix 	`aux'[9,`i'] = `aux'[9,`i'] + (`F'[`j',`i'] / `CT'[1,`i'])* ln( (`F'[`j',`i'] / `CT'[1,`i']) / (`RT'[`j',1] / `rn') )
		}
		* c=-1, 0,					infinite if Fji=0 ; 
		matrix	`aux'[1,`i'] = `aux'[1,`i'] + ( (`RT'[`j',1] / `rn')*(( (`F'[`j',`i'] / `CT'[1,`i']) / (`RT'[`j',1] / `rn') )^(-1) - 1 )) / 2			
		matrix 	`aux'[2,`i'] = `aux'[2,`i'] +   (`RT'[`j',1] / `rn')* ln( (`RT'[`j',1] / `rn') / (`F'[`j',`i'] / `CT'[1,`i']) )
		

	}
}

	* Ip and D

mat `Ip'=`Dg'*`CT''/`rn'
scalar `xx'=2
forvalues i = 1 / `rc' {
	scalar `xx' = `xx'*`CT'[1,`i']/`rn'
}

mat `D'=`Ip'/`xx'
mat rownames `D' = Dissimilarity
mat colnames `D' = overall

	* K1, K2

forvalues i = 1 / `rc' {
	mat `K2g'[1,`i'] =  1 - `K2g'[1,`i']^(1/`rr')
}



forvalues i = 1 / `rc' {
	local k=1
	foreach a of numlist .10 .30 .50 .70 .90 {
		mat `K1g'[`k',`i'] =  1 - `K1g'[`k',`i'] ^ ( 1/(2*`a') )
		local k=`k'+1
	}
}	


	* GE: sorting by ascending `c'

mat `Eg'=`aux'
mat `Eg'[8,1]=`aux'[9,1...]
mat `Eg'[9,1]=`aux'[8,1...]
mat `E' = `Eg'*`CT''/`rn'


* Gini: Local (Gg) and overall (G)    

forvalues i = 1 / `rc' {
	forvalues j = 1 / `rr' {
		forvalues k = `=`j'+1' / `rr' {
			matrix `Gg'[1,`i'] = `Gg'[1,`i'] +  ((`RT'[`j',1]*`RT'[`k',1]/`rn'^2))*abs( (`F'[`j',`i'] / `RT'[`j',1]) - (`F'[`k',`i'] / `RT'[`k',1]) ) / (`CT'[1,`i']/`rn')
		}
	}
}	

matrix `G' 	= `Gg'*`CT''/`rn'

* local


if "`aggregate'" == "" {
	qui tab `white' [`weight' `exp'] if `touse', matcell(`freq')
}
if "`aggregate'" ~= "" {
	local i=1
	mat `freq'=J(`rc',1,0)
	foreach var in `groups' {
		qui egen `aux'=sum(`var')
		mat `freq'[`i',1]=`aux'[1]
		cap drop `aux'
		local i=`i'+1
	}
}


mat `freq'=`freq''/`rn'
mat rownames `freq' = "pop_share"


mat `lseg'= ( `freq' \ `Dg' \ `K1g' \ `K2g' \ `Eg' \ `Gg' )
mat rownames `lseg' = "share" Ip K10 K30 K50 K70 K90 K GEm1 GE0 GE10 GE25 GE50 GE75 GE90 GE1 GE2 Gini 

local rk=rowsof(`lseg')*colsof(`lseg')
local rs=rowsof(`lseg')
local cs=colsof(`lseg')


local k=1

local qq=`rs'*`cs'
qui range `index' . `qq' `qq'
qui range `value' . `qq' `qq'
qui range `group' . `qq' `qq'
forvalues j= 1/`cs' {
	forvalues i=1/`rs' {
		qui replace `index'=`i' 		if _n==`k'
		qui replace `value'=`lseg'[`i',`j'] 	if _n==`k'
		qui replace `group'=`white'[1,`j'] 	if _n==`k'
		local k=`k'+1
	}
}




lab def `index' 1 "share" 2 "Ip" 3 "K(0.1)" 4 "K(0.3)" 5 "K(0.5)" 6 "K(0.7)" 7 "K(0.9)" 8 "K" 9 "GE(-1)" 10 "GE(0)" 11 "GE(.10)" 12 "GE(.25)" 13 "GE(.50)" 14 "GE(.75)" 15 "GE(.90)" 16 "GE(1)" 17 "GE(2)" 18 "Gini"
lab val `index' `index'
lab var `index' "Local Segregation Measures"

* overall and contribution

mat `Eg' = `Eg'[8,1...]

if `Ip'[1,1]~=0 {
	mat `EC' = `Eg'/`E'[8,1]
	mat `DC' = `Dg'/`Ip'[1,1]
	mat `GC' = `Gg'/`G'[1,1]
}
else {
	mat `EC' = `Eg'
	mat `DC' = `Dg'
	mat `GC' = `Gg'
}
	mat `cont' = `DC' \ `EC' \ `GC'
	mat `cont' = `cont' * diag(`freq')

if `rc'==2 {
	mat `oseg'= (J(1,colsof(`Dg'),.) \ `cont') , (`D' \ `Ip' \ `E'[8,1] \ `G' )
	mat rownames `oseg' = D Ip M Gini 
}
else {
	mat `oseg'= `cont' , (`Ip' \ `E'[8,1] \ `G' )
	mat rownames `oseg' = Ip M Gini 
}

local rk=rowsof(`oseg')*colsof(`oseg')
local rs=rowsof(`oseg')
local cs=colsof(`oseg')

mat `white' = `white' , `overall'

local k=1
qui gen `oindex'=.
qui gen `ogroup'=.
qui gen `ovalue'=.
forvalues j= 1/`cs' {
	forvalues i=1/`rs' {
		qui replace `oindex'=`i' 		if _n==`k'
		qui replace `ogroup'=`white'[1,`j'] 	if _n==`k'
		qui replace `ovalue'=`oseg'[`i',`j'] 	if _n==`k'
		local k=`k'+1
	}
}

if `rc'==2 {
	lab def `oindex' 1 D 2 Ip 3 M 4 Gini
}
else {
	lab def `oindex' 1 Ip 2 M 3 Gini
}
lab val `oindex' `oindex'
lab var `oindex' "Overall Segregation Measures"



if "`aggregate'" == "" {
	cap lab copy `white' `group'
	cap lab val  `group' `group'
	cap lab var  `group' "`white'"

	cap lab copy `white' `ogroup'
	cap lab def  `ogroup' `overall' " ", add
	cap lab val  `ogroup' `ogroup'
	lab var `ogroup' "`white'"

	lab var `value' "`white'"
}
if "`aggregate'" ~= "" {
	local i=1
	foreach var in `groups' {
		lab def  `group' `i' "`var'" , modify
		local i=`i'+1
	}
	lab val   `group' `group'
	lab var   `group' "Groups"
	lab copy `group' `ogroup'
	lab def  `ogroup' `overall' " ", add
	lab val  `ogroup' `ogroup'
	lab var  `ogroup' "Groups"

	lab var `value' "Groups"
}





if "`sc'" ~= "" {
	cap drop _F*
	cap drop _E*

		* normalizing cells by row total: FR=F/RT
	mat `SS' = vecdiag(inv(diag(`RT')))
	mat `SS' = diag(`SS')
	mat `FR' = `SS'*`F'

		* normalizing cells by column total: FC, RC
	mat `S'	 = vecdiag(inv(diag(`CT')))
	mat `S'  = diag(`S')
	mat `FC' = `F'*`S'

	mat `SR' = J(1,rowsof(`RT'),1)*`RT'
	mat `SR' = vecdiag(inv(diag(`SR')))
	mat `SR' = diag(`SR')
	mat `RC' = `RT'*`SR'

		* sorting vectors by FR, generating variables and accumulating by FC: Fi_1 e Fi_2
	if "`x'" == "" {
		local x "_E"
	}
	if "`y'" == "" {
		local y "_F"
	}
	local rf=colsof(`FR')
	local cf=rowsof(`FR')
	local cf1=`cf'+1
	
	forvalues i=1/`rf' {
		mat FF`i' = `FR'[1...,`i'], `RC' , `FC'[1...,`i'] 
		matsort FF`i' 1 "up"
		mat FF`i' = FF`i'[1...,2..3]
		mat FF`i' = (0 , 0) \ FF`i'
		svmat FF`i' , names(_F`i'_)
		mat drop FF`i'
		local j=`i'+1
		ren _F`i'_1 `x'`i'
		ren _F`i'_2 `y'`i'
		qui	replace `x'`i'=sum(`x'`i') if `x'`i'~=.
		qui	replace `y'`i'=sum(`y'`i') if `y'`i'~=.
		local line 	" `line' || line `y'`i' `x'`i' in 1/`cf1' " 
		local lab	" `lab' label(`j' `y'`i') "
	}
	
	if "`xtitle'" == "" {
		local xtitle "cumulative employment"
	}
	if "`ytitle'" == "" {
		local ytitle "cumulative target workers"
	}

	if "`graph_options'"== "" {
		local graph_options "aspectratio(1) plotr(m(zero)) connect(l) lpattern(solid) lwidth(medium) lcolor(black) xtick(0(.1)1) xlabel(0(.1)1) legend( cols(3) forcesize label(1 "45º line") `lab' ) ytick(0(.1)1) ylabel(0(.1)1) xtitle("`xtitle'", size(small) ) ytitle("`ytitle'", size(small) )"
	}
	
	if "`nograph'"~= "nograph" {
		graph twoway line `x'1 `x'1 in 1/`cf1' `line', `graph_options' 
	}
	cap drop _E* _F*
}

********

dis "Alonso-Villar, O. and Del Río, C. (2010), <<Local versus Overall Segregation Measures>>, Mathematical Social Sciences, vol. 60(1), pp. 30-38"
dis ""
dis as text "Number of units  (`occp') = " as result `rr'
dis as text "Number of groups (`white') = " as result `rc'
dis ""


tabdisp `oindex' `ogroup' if `ogroup'==`overall', c(`ovalue') f(`format') concise stubwidth(20) csepwidth(1) cellwidth(20) 
dis "Ip = multigroup index of dissimilarity"
dis "M = GE(1); Mutual Information Index M [ natural logs ]"
dis "D (Dissimilarity index) only reported in the case of two groups"

lab var `group' "Population shares"
tabdisp  `group' if `value'~=. & `index'==1,  c(`value')  f(`format') concise stubwidth(20) csepwidth(1) cellwidth(20) 


if `Ip'[1,1]~=0 {
	lab var `oindex' "Relative contribution to overall segregation"
	tabdisp `oindex' `ogroup' if `ovalue'~=. & `ogroup'<`overall', c(`ovalue') f(`format') concise stubwidth(20) csepwidth(1) cellwidth(20) 
}
if "`aggregate'" == "" {
	lab var `group' `white'
}
if "`aggregate'" ~= "" {
	lab var `group' "Groups"
}

di ""

forvalues i=1/`rc' {
	if `z`i''>0{
		di as result `z`i'' as text " unit(s) with zero observations from group `i' (" as result "`white'= " `white'[1,`i'] as text ")"
	}
}

tabdisp `index' `group'    if `value'~=. & `index'>1,  c(`value')  f(`format') concise stubwidth(20) csepwidth(1) cellwidth(8) 
dis "K, K(a) and GE(c<=0) only reported for groups with members in all units."

mat `oseg'=`oseg'[1...,colsof(`oseg')] , `oseg'[1...,1..`rc']

return matrix lseg=`lseg'
return matrix oseg=`oseg'
return matrix share=`freq'

di as text "{hline 100}"

end


