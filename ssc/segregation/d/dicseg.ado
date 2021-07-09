*! Pogram to compute two-groups segregation
*! Carlos Gradin
*! This version 2.2, March 2015
*! It includes some new indices, accepts agggregated data, and fixes some bugs


****************************************************** Program dicseg *******************************************************************************


* It requires to have matsort.ado (written by Paul Millar) previously installed

	* This program computes overall segregation indices across units in a two-groups context
	* Based on microdata (data not collapsed by units) or in data aggregated by units
		* results are saved as matrices and scalars
	* It also draws the segregation curves if option sc is specified, and creates variables using x() and y() options
		* First variable indcates units (ex. occupations, census tracts, schools, ....), second variable identifies groups (gender, race, ...)
		

cap program drop dicseg
program def dicseg	 , rclass  byable(recall)
version 10
syntax varlist(min=2 max=3) [aweight iweight fweight] [if] [in] [, AGgregate NORmalize Format(string) sc NOGraph x(string) y(string) XTitle(string) YTitle(string) GRaph_options(string) ]
tempname F z1 z2 D M aux E H G A CV KM Gg seg CT RT FC FR FF S SS RT overall index value
marksample touse

set more off

if "`format'" == "" {
	loc format "%9.4f"
}

di ""
di as text "{hline 100}"

if "`aggregate'" == "" {

	local occp:  word 1 of `varlist'
	local white: word 2 of `varlist'
	local error: word 3 of `varlist'
	dis "Computing Segregation of groups (`white') across units (`occp') based on individual data"
	if "`error'" ~= "" {
		dis as error "Only 2 variables must be specified using individual data"
	}

	qui: tab `varlist' [`weight' `exp'] if `touse', matcell(`F') missing label matcol(`white')

	local rc = r(c)
	local rr = r(r)
	local rn = r(N)
}

if "`aggregate'" ~= "" {

	local occp:  word 1 of `varlist'
	local g1: word 2 of `varlist'
	local g2: word 3 of `varlist'

	dis "Computing Segregation of groups (`g1' and `g2') across units (`occp') based on aggregated data "

	if "`weight'" ~= "" {
		dis as error "Weights are not allowed using aggregated data. They will be ignored"
	}

	mkmat `g1' `g2' if `touse' , mat(`F') rowname(`occp')

	local rc = colsof(`F')
	local rr = rowsof(`F')
	mat aux  = `F''*J(`rr',2,1)
	local rn = aux[1,1]+aux[2,1]
}


if `rc' > 2 | `rc'<2 {
	di as error "Variable `white' must have 2 groups "
}
else {


* Check occupations with 0 observations in any group

qui gen `z1'=0
qui gen `z2'=0

forvalues j = 1 / `rr' {
	qui replace `z1'=`z1'+1 if `F'[`j',1]==0 in 1
	qui replace `z2'=`z2'+1 if `F'[`j',2]==0 in 1
}

qui sum `z1'
scalar  `z1'=r(sum)
qui sum `z2'
scalar  `z2'=r(sum)





mat `D'  	= J(1,1,0)
mat `E'   	= J(10,1,0)
mat `H'  	= J(1,1,0)
mat `CV'  	= J(1,1,0)
mat `A'  	= J(8,1,0)
mat `A'[8,1]	= 1

	* Column and row totals

mat `CT' =     J(1,`rr',1)*`F'
mat `RT' = `F'*J(`rc',1,1)

	*log2(x) = ln(x)=ln(2)
mat `M'  	= (`CT'[1,1] / `rn')*(ln(`rn'/`CT'[1,1])/ln(2)) + (`CT'[1,2] / `rn')*(ln(`rn'/`CT'[1,2])/ln(2))


forvalues j = 1 / `rr' {

	* Dissimilarity 
			* Hornseth (1947) ; Duncan and Duncan (1955)
		mat	`D'[1,1]  = `D '[1,1] + abs( `F'[`j',2] / `CT'[1,2] - `F'[`j',1] / `CT'[1,1]) / 2
		

	* Generalized Entropy Measure of Segregation, GE(c)


		* GE(0<c<1)
		local k=4
		foreach c in .10 .25 .50 .75 .90 {
 			mat	`E'[`k',1] = `E'[`k',1]  + (     (`F'[`j',1] / `CT'[1,1])^(1-`c')  * (`F'[`j',2] / `CT'[1,2])^`c' - (`F'[`j',1] / `CT'[1,1])      ) / (`c'*(`c'-1))			
			local k=`k'+1
		}
		
		* GE(2), 1/2CV^2					infinite if F1=0
			mat	`E'[10 ,1] = `E'[10 ,1]  + (     (`F'[`j',1] / `CT'[1,1])^(1-2)  * (`F'[`j',2] / `CT'[1,2])^2 - (`F'[`j',1] / `CT'[1,1])      ) / (2*(2-1))			

		* GE(1), Theil Measure (Hutchens, 1991, pp. 48) 	infinite if F1=0		if F2=0, lim [xln(x)]=0 if x->0;
			if `F'[`j',2]>0 {
				mat 	`E'[ 9 ,1] = `E'[9,1] + (`F'[`j',2] / `CT'[1,2])* ln( (`F'[`j',2] / `CT'[1,2]) / (`F'[`j',1] / `CT'[1,1]) )	
			}

		* GE(-1, -2), if F1=0, 					infinite if F2=0
			local k=1
			foreach c in -2 -1  {
 				mat	`E'[`k',1] = `E'[`k',1]  + (     (`F'[`j',1] / `CT'[1,1])^(1-`c')  * (`F'[`j',2] / `CT'[1,2])^`c' - (`F'[`j',1] / `CT'[1,1])      ) / (`c'*(`c'-1))			
				local k=`k'+1
			}
		
		* GE(0), Mean Log Deviation, 				infinite if F2=0		if F1=0, lim [xln(x)]=0 if x->0; 

			if `F'[`j',1]>0 {
				mat 	`E'[ 3 ,1] = `E'[3,1] + (`F'[`j',1] / `CT'[1,1])* ln( (`F'[`j',1] / `CT'[1,1]) / (`F'[`j',2] / `CT'[1,2]) )
			}

	* Atkinson Measure of Segregation, A(c)


		* A(c)							infinite if F2=0 for c>1
		
		local k=1
		foreach c in .10 .25 .50 .75 .90 2 4 {
 			mat	`A'[`k',1] = `A'[`k',1]  + (    ( (`F'[`j',2] / `CT'[1,2])^(1-`c') ) * ( (`F'[`j',1] / `CT'[1,1])^`c')    )
			local k=`k'+1
		}


		* A(1)							if F1=0, lim(1/x)^x=1 if x->0							

		mat 	`aux' = ( `F'[`j',1] / `CT'[1,1]  ) 
		if `F'[`j',1] >0 {
			mat	`A'[`k',1] = `A'[`k',1]  * ( `F'[`j',2] / `F'[`j',1] )^`aux'[1,1]
		}

	* Mutual Information Index, M (Frankel and Volij, 2007, 2008, extension of Theil and Finnizza, 1971)
			* if F1=0, limM=0 + M2; if F2=0, limM=M1+0; log in base 2 or in ln

		* In log 2 () [Mora and Ruiz-Castillo, 2003)	log2(x)=ln(x)/ln(2)

		if `F'[`j',1] >0 {
			mat 	`M'[1,1] = `M'[1,1] 	- (`RT'[`j',1] / `rn') * (`F'[`j',1] / `RT'[`j',1]) * (ln(`RT'[`j',1] / `F'[`j',1])/ln(2))
		}

		if `F'[`j',2] >0 {
			mat 	`M'[1,1] = `M'[1,1] 	- (`RT'[`j',1] / `rn') * (`F'[`j',2] / `RT'[`j',1]) * (ln(`RT'[`j',1] / `F'[`j',2])/ln(2))
		}

}

	* Atkinson


		local k=1
		foreach c in .10 .25 .50 .75 .90 2 4 {
 			mat	`A'[`k',1] = 1-`A'[`k',1]^(1/(1-`c'))
			local k=`k'+1
		}

			mat `A'[8,1] = 1-`A'[8,1] / ( `CT'[1,2] / `CT'[1,1] )

		* sorting by c

		mat `A' = `A'[1..5,1] \ `A'[8,1] \ `A'[6..7,1]

	* Hutchens Square root index = GE(.5)*.25

		mat	`H'[1,1] =  `E'[6,1] * .25		

	* Coefficient of Variation: GE(2)=.5*CV^2 --> CV=sqr[2*GE(2)]

		mat	`CV'[1,1]= (`E'[10,1]*2)^.5
	

	* KM

		mat `KM'= 2*`D'*`CT'[1,1]/`rn'*`CT'[1,2]/`rn'

	* Normalization

	if "`normalize'" ~= "" {
		local i=4
		foreach c in .10 .25 .50 .75 .90 {
			mat `E'[`i',1]=`c'*(1-`c')*`E'[`i',1]
			local i=`i'+1
		}
	}


******************************************************** Based on ordered distribution ( F[,2]/CT[1,2] )


		* normalizing cells by row totals (occupation), FF

mat `SS'	= vecdiag(inv(diag(`RT')))
mat `SS' 	= diag(`SS')
mat `FF'	= `SS'*`F'

		* F sorted by second column of FF (whites), FC

mat `FR' = `FF'[1...,2], `F' 
matsort `FR' 1 "up"
mat `FC' = `FR'[1...,2..3]
		
		* normalizing FC cells by column total

mat `S'	 = vecdiag(inv(diag(`CT')))
mat `S'  = diag(`S')
mat `FC' = `FC'*`S'

mat `G'  = J(`rr',1,0)

	* Gini index (G), Hutchens, 1991

forvalues i = 1 / `rr' {
	forvalues j= `=`i'+1' / `rr' {
		mat `G'[`i',1]=`G'[`i',1] + (`FC'[`j',1])
	}
	mat `G'[`i',1]=`FC'[`i',2]*( `FC'[`i',1] + 2*`G'[`i',1] )
}

mat `G'=1-J(1,`rr',1)*`G'



******************************************************** Preparing results


mat 		`seg' = (`D' \ `KM' \ `E' \ `H' \ `CV' \ `A' \ `M' \ `G')
mat rownames 	`seg' = D KM GEm2 GEm1 GE0 GE10 GE25 GE50 GE75 GE90 Theil GE2 H CV A10 A25 A50 A75 A90 A1 A2 A4 Mutual(log2) Gini



local rk=rowsof(`seg')*colsof(`seg')
local rs=rowsof(`seg')
local cs=colsof(`seg')

*mat list `seg'

qui range `index' . `rs' `rs'
qui range `value' . `rs' `rs'
forvalues i=1/`rs' {
	*di "`i'
	qui replace `index'=`i' 		if _n==`i'
	qui replace `value'=`seg'[`i',1] 	if _n==`i'
	*list `index' `value'
}

qui replace `value'=0 if `value'<0

lab def `index' 1 "Dissimilarity" 2 "Karmel-MacLachlan" 3 "GE(-2)" 4 "GE(-1)" 5 "GE(0)" 6 "GE(.10)" 7 "GE(.25)" 8 "GE(.50)" 9 "GE(.75)" 10 "GE(.90)" 11 "GE(1)" 12 "GE(2)" 13 "Squared root" 14 "Cof. of Variation" 15 "A(.10)" 16 "A(.25)" 17 "A(.50)" 18 "A(.75)" 19 "A(.90)" 20 "A(1)" 21 "A(2)" 22 "A(4)" 23 "Mutual Information" 24 "Gini"
lab val `index' `index'
lab var `index' "Segregation Measures"


if "`sc'" ~= "" {
	cap drop _F*
	cap drop _E*

	if "`x'" == "" {
		local x "_E"
	}
	if "`y'" == "" {
		local y "_F"
	}
	
	local rf =colsof(`FR')
	local cf1=rowsof(`FR') + 1
	mat `FC' = (0 , 0) \ `FC'
	svmat `FC' , names(_F)
	ren _F1 `x'
	ren _F2 `y'
	qui	replace `x'=sum(`x') if `x'~=.
	qui	replace `y'=sum(`y') if `y'~=.
		
	if "`xtitle'" == "" {
		local xtitle "cumulative proportion of group 1"
	}
	if "`ytitle'" == "" {
		local ytitle "cumulative proportion of group 2"
	}
		
	if "`graph_options'"== "" {
		local graph_options "aspectratio(1) plotr(m(zero)) connect(l) lpattern(solid) lwidth(medium) lcolor(red) xtick(0(.1)1) xlabel(0(.1)1) legend( cols(3) forcesize label(1 "45º line") label(2 "segregation curve") ) ytick(0(.1)1) ylabel(0(.1)1) xtitle("`xtitle'", size(small) ) ytitle("`ytitle'", size(small) )"
	}
	
	if "`nograph'"~= "nograph" {
		graph twoway line `x' `x' in 1/`cf1' || line `y' `x' in 1/`cf1' , `graph_options'
	}
	cap drop _E* _F*
}


******************************************** Reporting

di ""
di as text "Number of units (" as result "`occp'" as text ") = 	" as result `rr'
local freq1 = `CT'[1,1]/(`CT'[1,1] + `CT'[1,2])
local freq2 = 1 - `freq1'
if "`aggregate'" == "" {
	lab var `value'	`white'
	di as text "Proportion group 1 (" as result "`white' = " `white'[1,1] as text ") = "  as result `format' `freq1' 
	di as text "Proportion group 2 (" as result "`white' = " `white'[1,2] as text ") = "  as result `format' `freq2' 
}
if "`aggregate'" ~= "" {
	lab var `value'	"   "
	di as text "Proportion of group 1 (" as result "`g1'" as text ")= " as result `format' `freq1' 
	di as text "Proportion of group 2 (" as result "`g2'" as text ")= " as result `format' `freq2' 
}
di ""
if `z1'>0{
	di as result `z1' as text " unit(s) with zero observations from group 1: CV and GE(alpha>=1) infinite"
}
if `z2'>0{
	di as result `z2' as text " unit(s) with zero observations from group 2: GE(alpha<=0) infinite ; A(epsilon>1) infinite"
}
tabdisp  `index' if `value'~=., c(`value') f(`format') concise stubwidth(20) csepwidth(1) cellwidth(20) 
dis ""
di as text "Notes:"
di as text " - GE(alpha) = Generalized Entropy Family"
if "`normalize'" ~= "" {
	di as text "     - GE(0<alpha<1) normalized multiplying by alpha*(1-alpha) to range between 0 and 1"
}

di as text " - A(epsilon) = Atkinson family"
di as text " - Mutual Information index (log base 2)"
dis ""

return scalar D     =`seg'[1 ,1]
return scalar KM    =`seg'[2 ,1]
return scalar GEm2  =`seg'[3 ,1]
return scalar GEm1  =`seg'[4 ,1]
return scalar GE0   =`seg'[5 ,1]
return scalar GE10  =`seg'[6 ,1]
return scalar GE25  =`seg'[7 ,1]
return scalar GE50  =`seg'[8 ,1]
return scalar GE75  =`seg'[9 ,1]
return scalar GE90  =`seg'[10,1]
return scalar GE1   =`seg'[11,1]
return scalar GE2   =`seg'[12,1]
return scalar H     =`seg'[13,1]
return scalar CV    =`seg'[14,1]
return scalar A10   =`seg'[15 ,1]
return scalar A25   =`seg'[16 ,1]
return scalar A50   =`seg'[17 ,1]
return scalar A75   =`seg'[18 ,1]
return scalar A90   =`seg'[19 ,1]
return scalar A1    =`seg'[20 ,1]
return scalar A2    =`seg'[21 ,1]
return scalar A4    =`seg'[22 ,1]
return scalar M	    =`seg'[23,1]
return scalar Gini  =`seg'[24,1]

return scalar nunits=`rr'
return scalar freq1=`freq1'
return scalar freq2=`freq2'

return mat seg=`seg'

di as text "{hline 100}"

}

end


