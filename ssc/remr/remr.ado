* REMR version 1.1 - 19 August 2020
* Authors: Luis Furuya-Kanamori (luis.furuya-kanamori@anu.edu.au), Chang Xu, Suhail AR Doi

*version 1.1 - ref(#) not part of dataset, added warning message ""Graph not rendered - reference value should match one of the dose levels in the dataset"


program define remr, rclass
version 14

syntax varlist(min=3 max=4 numeric) [if] [in] ///
, ID(varname) CATegory(varname) [, or rr rd noGraph bplot Table eform] ///
[rcs(numlist max=1)] [Knots(numlist)] [REFerence (numlist max=1)] [CENter (numlist max=1)] [STARTdose (numlist min=2 max=2)]

tokenize `varlist'

preserve
marksample touse, novarlist 
quietly keep if `touse'

quietly{

*Error messages
	*OR and RR
	if "`or'"!="" & "`rr'"!=""{
	noisily di as error "or and rr cannot both be specified"
	exit 198
	}	
	
	*OR and RD
	if "`or'"!="" & "`rd'"!=""{
	noisily di as error "or and rd cannot both be specified"
	exit 198
	}	
	
	*RR and RD
	if "`rr'"!="" & "`rd'"!=""{
	noisily di as error "rr and rd cannot both be specified"
	exit 198
	}
		
	*OR, RR, and RD with data entry as "[1]es [2]se [3]dose"
	if ("`or'"!="" | "`rr'"!="" | "`rd'"!="") & "`4'"=="" {
	noisily di as text "Note: effect size is specified by `1'"
	}	
	
	*Missing ID or category
	cap assert !missing(`id')
	if _rc {
	noisily di as err "`id' cannot contain missing values"
	exit 198
	}
	cap assert !missing(`category')
	if _rc {
	noisily di as err "`category' cannot contain missing values"
	exit 198
	}
	
	*Reference and Center
	if "`reference'"!="" & "`center'"==""{
	noisily di as error "reference option can only be used when center has been specified"
	exit 198
	}
			
	*Category check
	sort `id' `category' 
	bysort `id': gen __category_check = _n-1 
	cap assert `category' == __category_check
	if _rc & ("`if'"=="" & "`in'"==""){
	noisily di as err "category wrongly specified"
	exit 198
	}
	
	if _rc & ("`if'"!="" | "`in'"!=""){
	noisily di as err "verify category is correctly specified"
	}
	

	*Graph
	if "`graph'" == "nograph" & "`bplot'" !="" {
	di as error "nograph and bplot cannot both be specified"
	exit 198	
	}
	if "`bplot'" !="" & "`reference'" !="" {
	di as error "bplot cannot be displayed when a reference has been specified"
	exit 198	
	}	
		
	
*Data entry 
	*[1]cases [2]non-cases [3]total [4]dose
		if "`3'"!="" & "`4'"!=""{
		
		gen __drop =.
		replace __drop = 1 if `1'==0 & `2'==0 
		replace __drop = 1 if `1'==. | `2'==. | `4'==.
		sort `id' `category' 
		bysort `id': replace __drop = 1 if __drop[1] == 1 	
		drop if __drop==1
				
		gen __data_entry_type = "Data input format cases non_cases total dose, id() cat()"

		sort `id' `category' 
		bysort `id': gen __study_id=_n	
		
			*OR (by default)
			if "`or'"!="" | ("`or'"=="" & "`rr'"=="" & "`rd'"==""){
			gen __continuity = 1 if (`1' ==0 | `2' ==0)
				replace `1' = `1'+0.5 if __continuity==1 
				replace `2' = `2'+0.5 if __continuity==1 
			gen __effect_size = "OR"
			gen __or=.
			replace __or=1 if __study_id==1
			bysort `id': replace __or=(`1'*`2'[1]) / (`2'*`1'[1]) if __study_id!=1
			gen __es=ln(__or)
			gen __se=.
			replace __se=0 if __study_id==1
			bysort `id': replace __se=sqrt((1/`1')+(1/`2')+(1/`1'[1])+(1/`2'[1])) if __study_id!=1
			gen __dose=`4'
			}
		
			*RR
			if "`rr'"!=""{
			gen __continuity = 1 if (`1' ==0 | `2' ==0)
				replace `1' = `1'+0.5 if __continuity==1 
				replace `2' = `2'+0.5 if __continuity==1 
			gen __effect_size = "RR"
			gen __rr = .
			replace __rr=1 if __study_id==1
			bysort `id': replace __rr= (`1'/(`1'+`2')) / (`1'[1]/(`1'[1]+`2'[1])) if __study_id!=1
			gen __es=ln(__rr)
			gen __se=.
			replace __se=0 if __study_id==1
			bysort `id': replace __se=sqrt((1/`1')+(1/`1'[1])-(1/(`1'+`2'))-(1/(`1'[1]+`2'[1]))) if __study_id!=1
			gen __dose=`4'
			}
			
			*RD (continuity only for SE)
			if "`rd'"!=""{
			gen __continuity = 1 if (`1' ==0 | `2' ==0)
			gen __effect_size = "RD"
			gen __rd = .
			replace __rd=0 if __study_id==1
			bysort `id': replace __rd= (`1'/(`1'+`2')) - (`1'[1]/(`1'[1]+`2'[1])) if __study_id!=1
			gen __es=__rd
				replace `1' = `1'+0.5 if __continuity==1 
				replace `2' = `2'+0.5 if __continuity==1 
			gen __se=.
			replace __se=0 if __study_id==1
			bysort `id': replace __se=sqrt( ((`1'*`2')/(`1'+`2')^3) + ((`1'[1]*`2'[1])/(`1'[1]+`2'[1])^3) ) if __study_id!=1
			gen __dose=`4'
			}	
		}
		
	*[1]es [2]se [3]dose
		if "`3'"!="" & "`4'"==""{
		
		gen __drop =.
		replace __drop = 1 if `1'==. | `3'==.
		replace __drop = 1 if `2'==. & `category' !=0
		sort `id' `category' 
		bysort `id': replace __drop = 1 if __drop[1] == 1 	
		drop if __drop==1
				
		gen __data_entry_type = "Data input format es se dose, id() cat()"
		
		gen __es = `1'
		gen __se = `2'
		gen __dose=`3'
		
		sort `id' `category'
		bysort `id': gen __study_id=_n	
		}
		

*Center + start dose
	if "`center'"=="" & "`startdose'"!=""{
	noisily di as err "startdose cannot be specified without center"
	exit 198
	}
		
	if "`center'"!="" & "`startdose'"==""{
	local cent `center'
	gen __cent = `center'
	bysort `id': gen __cent_start = __dose[1]
	bysort `id': gen __dose_cent = (__dose-__cent_start)+`cent'
	replace __dose = __dose_cent
	}

	if "`center'"!="" & "`startdose'"!=""{
	local cent `center'
	gen __cent = `center'
	
	tokenize `startdose'
		local startdose1 `1'
		local startdose2 `2'
	
		cap assert `startdose1'<=`cent' | `cent'>=`startdose2'
		if _rc {
		noisily di as err "center(#) has to be within startdose(#1 #2) range"
		exit 198
		}
	
	bysort `id': gen __cent_start = __dose[1]
	bysort `id': gen __dose_cent = (__dose-__cent_start)+`cent'
	replace __dose = __dose_cent
	
	drop if __cent_start < `startdose1' 
	drop if __cent_start > `startdose2'
	
		cap assert _N != 0
		if _rc {
		noisily di as err "studies' lowest dose outside startdose(#1 #2) range"
		exit 198	
		}
	}
	
	
*Chang-Doi method
	gen __wt = 1/(__se^2)
	bysort `id': egen __maxwt = max(__wt)
	replace __wt =. if `category'==0
	replace __wt = __maxwt if __wt==. & `category'==0
		
	*Restricted cubic spline option
	if "`rcs'"=="" & "`knots'"==""{
		gen __model = "Linear"
		gen __doses1 = __dose 
		gen __n_knots = "None"
		gen __knot_val1 = "None"
	}
	
	if "`rcs'"!="" & "`knots'"==""{
	local rcs `rcs'
	mkspline __doses = __dose, cubic nk(`rcs')	dis
		gen __model = "Non-linear"
		gen __n_knots = r(N_knots)
		matrix knots = r(knots)
		svmat knots, names(__knot_val)
	} 
	
 	if  "`rcs'"=="" & "`knots'"!="" {
	local nc 0
	tokenize "`knots'"
	mkspline __doses = __dose, cubic knots(`knots')	dis
		gen __model = "Non-linear"
		gen __n_knots = r(N_knots)
		matrix knots = r(knots)
		svmat knots, names(__knot_val)
	}
	
	if "`rcs'"!="" & "`knots'"!="" {
	local rcs `rcs'
	local nc 0
	tokenize "`knots'"
	mkspline __doses = __dose, cubic knots(`knots')	nk(`rcs') dis
		gen __model = "Non-linear"
		gen __n_knots = r(N_knots)
		matrix knots = r(knots)
		svmat knots, names(__knot_val)
	}
		

	*Calculations + options eform & reference
	sort __doses1
	list __doses* if __doses1 != __doses1[_n-1]
		regress __es __doses* [aweight=__wt], vce(cluster `id') eform (exp beta)
		matrix model = r(table)
		levelsof __dose, local(levels)
			if "`eform'" !="" & "`reference'"!=""{
				local ref `reference'
				gen __ref = `reference'
				xblc __doses* , covname (__dose) at(`r(levels)') eform gen(__d __xb __lci __uci) ref(`ref')
			}
			if "`eform'" =="" & "`reference'"!=""{
				local ref `reference'
				gen __ref = `reference'
				xblc __doses* , covname (__dose) at(`r(levels)') gen(__d __xb __lci __uci) ref(`ref')
			}
			if "`eform'" !="" & "`reference'"==""{
				xblc __doses* , covname (__dose) at(`r(levels)') eform gen(__d __xb __lci __uci)
			}
			if "`eform'" =="" & "`reference'"==""{
				xblc __doses* , covname (__dose) at(`r(levels)') gen(__d __xb __lci __uci)
			}
			
		
*Display results
noisily di ""
noisily di in smcl as txt "{hline 19}{c TT}{hline 65}"
	
	noisily di in smcl as text "Data entry type" as text "{col 20}{c |}" ///
	"{col 25}" (__data_entry_type[1])
	
	if __data_entry_type=="Data input format cases non_cases total dose, id() cat()"{
	noisily di in smcl as text "Effect size" as text "{col 20}{c |}" ///
	"{col 25}" (__effect_size[1])
	}
	
	noisily di in smcl as text "Model" as text "{col 20}{c |}" ///
	"{col 25}" (__model[1])
	
	if "`center'"!=""{
	noisily di in smcl as text "Center value" as text "{col 20}{c |}" ///
	"{col 25}" (__cent[1])
	}
	
	if "`reference'"!=""{
	noisily di in smcl as text "Reference value" as text "{col 20}{c |}" ///
	"{col 25}" (__ref[1])
	}
	
	noisily di in smcl as text "Num knots" as text "{col 20}{c |}" ///
	"{col 25}" (__n_knots[1])

	if "`rcs'"=="" & "`knots'"==""{
	noisily di in smcl as text "Knot values" as text "{col 20}{c |}" ///
	"{col 25}" (__knot_val1[1])
	}

	if "`rcs'"!="" | "`knots'"!=""{
	sort __knot_val1
		if __n_knots[1]==2{
		noisily di in smcl as text "Knot values" as text "{col 20}{c |}" ///
		"{col 25}" int(__knot_val1[1]) ///
		"{col 28}" int(__knot_val2[1])
		}
		if __n_knots[1]==3{
		noisily di in smcl as text "Knot values" as text "{col 20}{c |}" ///
		"{col 25}" int(__knot_val1[1]) ///
		"{col 28}" int(__knot_val2[1]) ///
		"{col 31}" int(__knot_val3[1])
		}
		if __n_knots[1]==4{
		noisily di in smcl as text "Knot values" as text "{col 20}{c |}" ///
		"{col 25}" int(__knot_val1[1]) ///
		"{col 28}" int(__knot_val2[1]) ///
		"{col 31}" int(__knot_val3[1]) ///
		"{col 34}" int(__knot_val4[1])
		}
		if __n_knots[1]==5{
		noisily di in smcl as text "Knot values" as text "{col 20}{c |}" ///
		"{col 25}" int(__knot_val1[1]) ///
		"{col 28}" int(__knot_val2[1]) ///
		"{col 31}" int(__knot_val3[1]) ///
		"{col 34}" int(__knot_val4[1]) ///
		"{col 37}" int(__knot_val5[1]) 
		}
		if __n_knots[1]==6{
		noisily di in smcl as text "Knot values" as text "{col 20}{c |}" ///
		"{col 25}" int(__knot_val1[1]) ///
		"{col 28}" int(__knot_val2[1]) ///
		"{col 31}" int(__knot_val3[1]) ///
		"{col 34}" int(__knot_val4[1]) ///
		"{col 37}" int(__knot_val5[1]) ///
		"{col 40}" int(__knot_val6[1]) 
		}
		if __n_knots[1]==7{
		noisily di in smcl as text "Knot values" as text "{col 20}{c |}" ///
		"{col 25}" int(__knot_val1[1]) ///
		"{col 28}" int(__knot_val2[1]) ///
		"{col 31}" int(__knot_val3[1]) ///
		"{col 34}" int(__knot_val4[1]) ///
		"{col 37}" int(__knot_val5[1]) ///
		"{col 40}" int(__knot_val6[1]) ///
		"{col 43}" int(__knot_val7[1]) 
		}
		if __n_knots[1]==8{
		noisily di in smcl as text "Knot values" as text "{col 20}{c |}" ///
		"{col 25}" int(__knot_val1[1]) ///
		"{col 28}" int(__knot_val2[1]) ///
		"{col 31}" int(__knot_val3[1]) ///
		"{col 34}" int(__knot_val4[1]) ///
		"{col 37}" int(__knot_val5[1]) ///
		"{col 40}" int(__knot_val6[1]) ///
		"{col 43}" int(__knot_val7[1]) ///
		"{col 46}" int(__knot_val8[1]) 
		}
		if __n_knots[1]==9{
		noisily di in smcl as text "Knot values" as text "{col 20}{c |}" ///
		"{col 25}" int(__knot_val1[1]) ///
		"{col 28}" int(__knot_val2[1]) ///
		"{col 31}" int(__knot_val3[1]) ///
		"{col 34}" int(__knot_val4[1]) ///
		"{col 37}" int(__knot_val5[1]) ///
		"{col 40}" int(__knot_val6[1]) ///
		"{col 43}" int(__knot_val7[1]) ///
		"{col 46}" int(__knot_val8[1]) ///
		"{col 49}" int(__knot_val9[1]) 
		}
	}
	
	gen __num_obs = e(N)
	noisily di in smcl as text "Num obs" as text "{col 20}{c |}" ///
	"{col 25}" (__num_obs[1])
	
	gen __num_studies = .
	bysort `id': replace __num_studies = 1 if __num_studies[1]==.
	replace __num_studies = sum(__num_studies)
	gsort -__num_studies
	noisily di in smcl as text "Num studies" as text "{col 20}{c |}" ///
	"{col 25}" (__num_studies[1])
	
	gen __r2 = e(r2)
	noisily di in smcl as text "R-squared" as text "{col 20}{c |}" ///
	"{col 25}" round(__r2[1],0.001)
	
	gen __root_mse = e(rmse)
	noisily di in smcl as text "Root MSE" as text "{col 20}{c |}" ///
	"{col 25}" round(__root_mse[1],0.001)
	
noisily di in smcl as txt "{hline 19}{c BT}{hline 65}"

	*Output table
		if "`table'" != ""{
			if "`eform'" !="" & "`reference'"!=""{
			noisily regress __es __doses* [aweight=__wt], vce(cluster `id') eform (exp beta)
			matrix model = r(table)
			levelsof __dose, local(levels)
			local ref `reference'
			if "`rd'"!=""{
			noisily xblc __doses* , covname (__dose) at(`r(levels)') eform ref(`ref') format(%7.3f)
			}
				else{
				noisily xblc __doses* , covname (__dose) at(`r(levels)') eform ref(`ref') format(%7.2f)
				}				
			}
			if "`eform'" =="" & "`reference'"!=""{
			noisily regress __es __doses* [aweight=__wt], vce(cluster `id') 
			matrix model = r(table)
			levelsof __dose, local(levels)
			local ref `reference'
			if "`rd'"!=""{
			noisily xblc __doses* , covname (__dose) at(`r(levels)') ref(`ref') format(%7.3f)
			}
				else{
				noisily xblc __doses* , covname (__dose) at(`r(levels)') ref(`ref') format(%7.2f)
				}
			}			
			if "`eform'" !="" & "`reference'"==""{
			noisily regress __es __doses* [aweight=__wt], vce(cluster `id') eform (exp beta)
			matrix model = r(table)
			levelsof __dose, local(levels)
			if "`rd'"!=""{
			noisily xblc __doses* , covname (__dose) at(`r(levels)') eform format(%7.3f)
			}
				else{
				noisily xblc __doses* , covname (__dose) at(`r(levels)') eform format(%7.2f)
				}
			}
			if "`eform'" =="" & "`reference'"==""{
			noisily regress __es __doses* [aweight=__wt], vce(cluster `id')
			matrix model = r(table)
			levelsof __dose, local(levels)
			if "`rd'"!=""{
			noisily xblc __doses* , covname (__dose) at(`r(levels)') format(%7.3f)
			}
				else{
				noisily xblc __doses* , covname (__dose) at(`r(levels)') format(%7.2f)
				}				
			}
		}

		
*Matrices (+ Regression model[above])
sort __d

	cap mkmat __d __xb __lci __uci, matrix(output) nomissing
	cap return matrix output = output

	cap return matrix model = model
	
	cap mkmat __doses*, matrix(doses) nomissing
	cap return matrix doses = doses

		
*Graph
	if "`graph'" != "nograph" & "`bplot'" == "" & (__lci==. & __uci==.){
		noisily di as err "graph not rendered - reference value should match one of the dose levels in the dataset"
		}

	if "`graph'" != "nograph" & "`bplot'" == "" & (__lci!=. & __uci!=.){
		sort __d
		tw (line __xb __d, lcolor(black) lpattern(l) lwidth(thick)) /// 
		(line __lci __d, lcolor(black) lpattern(dash) lwidth(thick)) ///
		(line __uci __d, lcolor(black) lpattern(dash) lwidth(thick)), /// 
		legend(off) sch(s1mono) ///	
		xtitle("dose") ///                    
		plotregion(style(none)) ///
		ylabel(#7, angle(horiz) format(%3.2fc)) ///
		xlabel(#7)
		}
		
	if "`bplot'" != "" {
		bysort `id': egen __dosemin = min(__dose) 
		replace __wt=. if __dose == __dosemin	
		
			if "`eform'" =="eform" {
			replace __es = exp(__es)
			}
		
		sort __d
		tw (scatter __es __dose [aw=__wt] if __se!=., msymbol(oh)) ///
		(line __xb __d, lcolor(black) lpattern(l) lwidth(thick)) /// 
		(line __lci __d, lcolor(black) lpattern(dash) lwidth(thick)) ///
		(line __uci __d, lcolor(black) lpattern(dash) lwidth(thick)), /// 
		legend(off) sch(s1mono) ///	
		xtitle("dose") ///                    
		plotregion(style(none)) ///
		ylabel(#7, angle(horiz) format(%3.2fc)) ///
		xlabel(#7)
		}
}		
*

*Restore data and exit
restore 
end
exit	
	
	
	
