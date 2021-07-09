program onemode
version 11
//Revised 24feb2015
//Author: Zachary Neal (zpneal@msu.edu)
syntax anything , [ROWid COLumnid TRANSpose method(str) HIGHThreshold(real -99) LOWThreshold(real -99) alpha(real .05) reps(int 1000) model(str) iterate(int 16000) PROGress saveas(str)]
quietly {
preserve
clear
tempfile temp

//SET DEFAULTS, RETURN ERROR MESSAGES
if "`method'" == "" local method "standard"
if "`model'" == "" local model "optimal"
if "`saveas'" == "" local saveas "`method'"

if `alpha' < 0 | `alpha' > 1 noisily: display "ERROR: Alpha must be between 0 and 1."
error (`alpha' < 0 | `alpha' > 1)

if `reps' <= 0 noisily: display "ERROR: The number of simulation replications must be greater than 0."
error (`reps' <= 0)

if "`method'" ~= "standard" & "`method'" ~= "pearson" & "`method'" ~= "bonacich" & "`method'" ~= "nystuen" & ///
   "`method'" ~= "serrano" & "`method'" ~= "hyperg" & "`method'" ~= "sdsm" ///
   noisily: display "ERROR: You specified an invalid type of projection in the -method- option."
error ("`method'" ~= "standard" & "`method'" ~= "pearson" & "`method'" ~= "bonacich" & "`method'" ~= "nystuen" & ///
       "`method'" ~= "serrano" & "`method'" ~= "hyperg" & "`method'" ~= "sdsm")

if "`model'" ~= "optimal" & "`model'" ~= "logit" & "`model'" ~= "probit" & "`model'" ~= "scobit" & "`model'" ~= "cloglog"  ///
   noisily: display "ERROR: You specified an invalid type of binary outcome model in the -model- option."
error ("`model'" ~= "optimal" & "`model'" ~= "logit" & "`model'" ~= "probit" & "`model'" ~= "scobit" & "`model'" ~= "cloglog")

//READ IN DATA
if "`rowid'" == "" & "`columnid'" == "" insheet using "`anything'.csv", comma nonames	//Contains no ids

if "`rowid'" ~= "" & "`columnid'" == "" {		//Only contains row ids
	insheet using "`anything'.csv", comma nonames
	mata rowid = st_sdata(.,1)
	drop v1
	}

if "`columnid'" ~= "" & "`rowid'" == "" {		//Only contains column ids
	insheet using "`anything'.csv", comma nonames
	mata colid = st_sdata(1,.)
	mata colid = colid'
	drop in 1
	}

if "`rowid'" ~= "" & "`columnid'" ~= "" {		//Contains both row and column ids
	insheet using "`anything'.csv", comma nonames
	drop in 1
	mata rowid = st_sdata(.,1)
	clear
	insheet using "`anything'.csv", comma nonames
	drop v1
	mata colid = st_sdata(1,.)
	mata colid = colid'
	drop in 1
	}	

destring _all, replace
mata twomode = st_data(.,.)
if "`transpose'" ~= "" {
	mata: twomode = twomode'
	describe
	local agents = r(k)
	local artifacts = _N
	}
else {
	local agents = _N
	describe
	local artifacts = r(k)
	}
noisily: display "These data describe `agents' agents' affiliation with `artifacts' artifacts."

//STANDARD PROJECTION
if "`method'" == "standard" {
clear
mata: proj = twomode * twomode'
if `highthreshold' ~= -99 | `lowthreshold' ~= -99 {
	clear
	mata st_matrix("proj", proj)
	svmat proj
	if `highthreshold' ~= -99 & `lowthreshold' == -99 recode _all (min/`highthreshold' = 0) (else = 1)
	if `highthreshold' == -99 & `lowthreshold' ~= -99 recode _all (`lowthreshold'/max = 0) (else = -1)
	if `highthreshold' ~= -99 & `lowthreshold' ~= -99 recode _all (`lowthreshold'/`highthreshold' = 0) (min/`lowthreshold' = -1) (`highthreshold'/max = 1)
	mata proj = st_data(.,.)
	}
}

//PEARSON NORMALIZED PROJECTION
if "`method'" == "pearson" {
clear	
mata: proj = correlation(twomode')
if `alpha' ~= 0 {
	clear
	mata st_matrix("proj", proj)
	svmat proj
	local upper = (invnormal(1-((`alpha'/2))))/(sqrt(`artifacts'-1))
	local lower = -(invnormal(1-((`alpha'/2))))/(sqrt(`artifacts'-1))
	recode _all (`lower'/`upper' = 0) (min/`lower' = -1) (`upper'/max = 1)
	mata proj = st_data(.,.)
	}
}

//BONACICH NORMALIZED PROJECTION
if "`method'" == "bonacich" {
	//Obtain observed overlap & agent degrees
	clear
	mata valued = vec(twomode*twomode')
	mata rowsum = rowsum(twomode)
	mata st_matrix("rowsum", rowsum)
	svmat rowsum
	rename rowsum1 rowsum_i
	gen i = _n
	save `temp'
	rename i j
	rename rowsum_i rowsum_j
	cross using `temp'
	sort i j
	gen valued = .
	mata st_store(., "valued", valued[.,1])
gen a = valued
gen b = rowsum_i - valued
gen c = rowsum_j - valued
gen d = `artifacts' - (a + b + c)
gen bonacich = ((a*d)-sqrt(a*d*b*c))/((a*d)-(b*c))		//Correct in bonacich, wrong in Borgatti's handbook entry
replace bonacich = .5 if bonacich == . 				//That is, if AD = BC
keep i j bonacich
reshape wide bonacich, i(i) j(j)
drop i
mata proj = st_data(.,.)
clear
if `highthreshold' ~= -99 | `lowthreshold' ~= -99 {
	clear
	mata st_matrix("proj", proj)
	svmat proj
	if `highthreshold' ~= -99 & `lowthreshold' == -99 recode _all (min/`highthreshold' = 0) (else = 1)
	if `highthreshold' == -99 & `lowthreshold' ~= -99 recode _all (`lowthreshold'/max = 0) (else = -1)
	if `highthreshold' ~= -99 & `lowthreshold' ~= -99 recode _all (`lowthreshold'/`highthreshold' = 0) (min/`lowthreshold' = -1) (`highthreshold'/max = 1)
	mata proj = st_data(.,.)
	}
}

//NYSTUEN PROJECTION
if "`method'" == "nystuen" {
clear
set obs `agents'
gen i = _n
save `temp'
rename i j
cross using `temp'
sort i j
gen valued = .
mata valued = vec(twomode*twomode')
mata st_store(., "valued", valued[.,1])
replace valued = 0 if i == j
egen max_i = max(valued), by(i)
egen max_j = max(valued), by(j)
gen nystuen = (max_i == valued | max_j == valued)
keep i j nystuen
reshape wide nystuen, i(i) j(j)
drop i
mata proj = st_data(.,.)
clear
}

//SERRANO PROJECTION
if "`method'" == "serrano" {
clear
set obs `agents'
gen i = _n
save `temp'
rename i j
cross using `temp'
sort i j
mata valued = vec(twomode*twomode')
gen valued = .
mata st_store(., "valued", valued[.,1])
gen i_01 = (valued>0)
egen i_k = total(i_01), by(i)
gen j_01 = (valued>0)
egen j_k = total(j_01), by(j)
egen i_total = total(i), by(i)
egen j_total = total(j), by(j)
gen i_norm = valued/i_total
gen j_norm = valued/j_total
gen i_pvalue = .
gen j_pvalue = .
local edges = _N
local interval = int(`edges'/40)
if "`progress'" ~= "" {
	noisily: display "Serrano Test Progress - "
	noisily: display "0        25        50        75      100%"
	noisily: display "----------------------------------------"
	}
forvalues x = 1/`edges' {
	if "`progress'" ~= "" & (`x'==`edges' | mod(`x',`interval')==0) noisily: display "*" _continue
	if i_norm[`x'] ~= 0 & j_norm[`x'] ~= 0 {
	range x 0 i_norm[`x'] 100
	gen y = (1 - x) ^ (i_k[`x'] - 2)
	integ y x 
	local i_p = 1 - (i_k[`x'] - 1) * r(integral)
	replace i_pvalue in `x' = `i_p'
	drop y x
	range x 0 j_norm[`x'] 100
	gen y = (1 - x) ^ (j_k[`x'] - 2)
	integ y x 
	local j_p = 1 - (j_k[`x'] - 1) * r(integral)
	replace j_pvalue in `x' = `j_p'
	drop y x
	}
	}
if "`progress'" ~= "" noisily: display " "
replace i_pvalue = 1 if i_pvalue == .
replace j_pvalue = 1 if j_pvalue == .
gen serrano = (i_pvalue < `alpha' | j_pvalue < `alpha')
keep i j serrano
reshape wide serrano, i(i) j(j)
drop i
mata proj = st_data(.,.)
clear
}

//HYPERGEOMETRIC PROJECTION
if "`method'" == "hyperg" {
	//Obtain observed overlap & agent degrees
	clear
	mata valued = vec(twomode*twomode')
	mata rowsum = rowsum(twomode)
	mata st_matrix("rowsum", rowsum)
	svmat rowsum
	rename rowsum1 rowsum_i
	gen i = _n
	save `temp'
	rename i j
	rename rowsum_i rowsum_j
	cross using `temp'
	sort i j
	gen valued = .
	mata st_store(., "valued", valued[.,1])

gen negative = hypergeometric(`artifacts',rowsum_i,rowsum_j,valued)	//Prob of observed co-occurance or less
gen hyperg = -1 if negative < (`alpha' / 2)
gen positive = (1 - negative) + hypergeometricp(`artifacts',rowsum_i,rowsum_j,valued)	//Prob of observed co-occurance or more
replace hyperg = 1 if positive < (`alpha' / 2)
replace hyperg = 0 if hyperg == .
keep i j hyperg
reshape wide hyperg, i(i) j(j)
drop i
mata proj = st_data(.,.)
clear
}

//STOCHASTIC DEGREE SEQUENCE MODEL
if "`method'" == "sdsm" {
local interval = int(`reps'/40)

	//Setup matrices
	mata: valued = twomode*twomode'
	mata: higher = J(rows(valued),cols(valued),0)
	mata: lower = J(rows(valued),cols(valued),0)
	mata: trials = J(rows(twomode),cols(twomode),1)

	//Obtain probability matrix
	gen i = _n
	reshape long v, i(i) j(j)
	rename i row
	rename j column
	rename v link
	egen rowmarg = total(link), by(row)
	egen colmarg = total(link), by(column)
	gen interact = rowmarg * colmarg
	save `temp'
	if "`model'" == "scobit" | "`model'" == "optimal" {
		clear
		use `temp'
		scobit link rowmarg colmarg interact, iterate(`iterate')
		predict scobit
		keep row column scobit
		reshape wide scobit, i(row) j(column)
		drop row
		mata: scobit = st_data(.,.)
		if "`transpose'" ~= "" mata: scobit = scobit'
		}
	if "`model'" == "logit" | "`model'" == "optimal" {
		clear
		use `temp'
		logit link rowmarg colmarg interact, iterate(`iterate')
		predict logit
		keep row column logit
		reshape wide logit, i(row) j(column)
		drop row
		mata: logit = st_data(.,.)
		if "`transpose'" ~= "" mata: logit = logit'
		}
	if "`model'" == "probit" | "`model'" == "optimal" {
		clear
		use `temp'
		probit link rowmarg colmarg interact, iterate(`iterate')
		predict probit
		keep row column probit
		reshape wide probit, i(row) j(column)
		drop row
		mata: probit = st_data(.,.)
		if "`transpose'" ~= "" mata: probit = probit'
		}
	if "`model'" == "cloglog" | "`model'" == "optimal" {
		clear
		use `temp'
		cloglog link rowmarg colmarg interact, iterate(`iterate')
		predict cloglog
		keep row column cloglog
		reshape wide cloglog, i(row) j(column)
		drop row
		mata: cloglog = st_data(.,.)
		if "`transpose'" ~= "" mata: cloglog = cloglog'
		}

if "`model'" ~= "optimal" noisily: display "Using `model' binary outcome model; fit indices:"
if "`model'" == "optimal" {
	clear
	mata: obs_marg = rowsum(twomode)\colsum(twomode)'
	
	mata: random = rbinomial(1,1,trials,scobit)
	mata: scobit_marg = rowsum(random)\colsum(random)'

	mata: random = rbinomial(1,1,trials,logit)
	mata: logit_marg = rowsum(random)\colsum(random)'

	mata: random = rbinomial(1,1,trials,probit)
	mata: probit_marg = rowsum(random)\colsum(random)'

	mata: random = rbinomial(1,1,trials,cloglog)
	mata: cloglog_marg = rowsum(random)\colsum(random)'
	
	mata: marginals = obs_marg, scobit_marg, logit_marg, probit_marg, cloglog_marg
	mata st_matrix("marginals", marginals)
	svmat marginals
	
	reg marginals1 marginals2
	local rmse = e(rmse)
	local modeluse = "scobit"
	reg marginals1 marginals3
	if e(rmse) < `rmse' {
		local modeluse = "logit"
		local rmse = e(rmse)
		}
	reg marginals1 marginals4
	if e(rmse) < `rmse' {
		local modeluse = "probit"
		local rmse = e(rmse)
		}
	reg marginals1 marginals5
	if e(rmse) < `rmse' {
		local modeluse = "cloglog"	
		local rmse = e(rmse)
		}
	local model = "`modeluse'"
	noisily: display "Optimal binary outcome model is `model'; fit indices:"
	}

clear
mata: obs_marg = rowsum(twomode)\colsum(twomode)'
mata: random = rbinomial(1,1,trials,`model')
mata: rand_marg = rowsum(random)\colsum(random)'
mata: marginals = obs_marg, rand_marg
mata st_matrix("marginals", marginals)
svmat marginals
reg marginals1 marginals2
local rmse = string(round(e(rmse),.0001))
local r2 = string(round(e(r2),.0001))
noisily: display "R-squared: `r2'"
noisily: display "Root Mean Squared Error: `rmse'"
noisily: display " "

clear
if "`progress'" ~= "" {
	noisily: display "SDSM Test Progress - "
	noisily: display "0        25        50        75      100%"
	noisily: display "----------------------------------------"
	}
forvalues rep = 1/`reps' {	//Construct random twomode networks, project and compare to observed
	if "`progress'" ~= "" & (`rep'==`reps' | mod(`rep',`interval')==0) noisily: display "*" _continue
	mata: random = rbinomial(1,1,trials,`model')
	mata: randomproj = random*random'
	mata: higher = higher :+ (valued:<=randomproj)
	mata: lower = lower :+ (valued:>=randomproj)
	}
mata: positive = ((higher:/`reps'):<(`alpha'/2))
mata: negative = ((lower:/`reps'):<(`alpha'/2))
mata: _editvalue(negative,1,-1)
mata: proj = positive :+ negative
}

//OUTPUT
clear
mata _diag(proj,0)
mata st_matrix("proj", proj)
svmat proj
if "`rowid'" ~= "" & "`transpose'" == "" {
	gen str50 rowid = ""
	mata st_sstore(.,"rowid",rowid)
	order rowid
	}
if "`columnid'" ~= "" & "`transpose'" ~= "" {
	gen str50 colid = ""
	mata st_sstore(.,"colid",colid)
	order colid
	}
outsheet using "`saveas'.csv", comma replace nonames

restore
}
end
*/
