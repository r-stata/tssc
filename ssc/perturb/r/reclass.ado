*! version 2, 13Oct2004, John_Hendrickx@yahoo.com
/*
Direct comments to: John Hendrickx <John_Hendrickx@yahoo.com>

Called by perturb.ado to calculate a matrix of reclassification
probabilities.

Version 2, September 30, 2004
Added option -pcnttab- to specify reclassification percentages directly
option -noadjust- to skip making the row and column marginals of the
expected table equal
option -nobestmod- to skip finding a model for misclassification
option -dist- to use a distance model for the association
Version 1, July 11, 2004
Intital version
*/


program define reclass, rclass
	version 7
	syntax varname , [Q(real 1)  U(real 1) Dist(real 1) ASsoc(string) /*
	*/ Pcnttab(string) noADjust noBestmod /*
	*/ Misclass(numlist >0 <100 max=1) Format(string) Verbose]
	preserve

	if "`verbose'" == "" {
		local how "quietly"
	}
	if `"`format'"' == "" {
		local format "%8.3f"
	}
	else {
		capt local tmp : display `format' 1
		if _rc {
			di as err `"invalid %fmt in format(): `format'"'
			exit 120
		}
	}

	`how' tab `varlist', matcell(mrgn)
	local ncat=rowsof(mrgn)
	drop _all
	`how' svmat mrgn, names(artdat)
	`how' expand (`ncat')

	* generate an artificial table with frequencies on the diagonal
	* so it has the same marginals as `varname'
	gen orig=group(`ncat')
	gen dest=1+mod(_n-1,`ncat')
	label variable orig "original variable `varlist'"
	label variable dest "reclassifed variable"
	gen frq=0
	quietly replace frq=mrgn[orig,1] if orig==dest

	* option misclass is maintained for compatiblity
	if "`misclass'" ~= "" {
		tempname inmat
		matrix `inmat'=J(1,`ncat',100-`misclass')
		local pcnttab `inmat'
		local adjust="noadjust"
	}

	if "`pcnttab'" ~= "" {
		local ptype=0
		capture local nrow=rowsof(`pcnttab')
		if _rc ~= 0 {
			tempname inmat
			capture matrix `inmat'=J(1,`ncat',`pcnttab')
			if _rc ~= 0 {
				display as error "Argument `pcnttab' for option {hi:pcnttab} is invalid"
				exit
			}
			local nrow 1
			local ptype=1
			local pcnttab `inmat'
		}
		local ncol=colsof(`pcnttab')
		tempname targtab parmat

		if `nrow' == `ncat' & `ncol' == `ncat' {
			local ptype=3
			mat `targtab'=`pcnttab'
		}
		else if (`nrow' == `ncat' & `ncol' == 1) | (`nrow' == 1 & `ncol' == `ncat') {
			if `ptype' == 0 {local ptype=2}
			tempname inmat
			mat `inmat'=diag(`pcnttab')
			mat `targtab'=`inmat'
			forval i=1/`ncat' {
				mat `targtab'[`i',1]=J(1,`ncat',(100-`inmat'[`i',`i'])/(`ncat'-1))
				mat `targtab'[`i',`i']=`inmat'[`i',`i']
			}
		}
		else {
			display as error "The dimensions of matrix `pcnttab' [`nrow',`ncol'] are invalid for variable `varlist' with `ncat' categories"
			exit
		}
		* create column proportions
		mat `targtab'=inv(diag(`targtab'*J(`ncat',1,1)))*`targtab'
		gen paras=`targtab'[orig,dest]
		display as text _newline "Reclassification probabilities for `varlist':"
		table orig dest [iw=paras], format(`format') col

		mat `parmat'=diag(mrgn)*`targtab'
		quietly replace paras=`parmat'[orig,dest]
		display as text _newline "Initial expected table based on the reclassification probabilities:"
		table orig dest [iw=paras], format(`format') row col

		if "`adjust'" == "noadjust" {
			* don't adjust the margins of the expected table
			* to make them equal to the frequency distribution of the variable
			* just return the cumulative frequencies
			display as text _newline "The reclassification probabilities will used as is and will not be adjusted to let"
			display as text "the expected frequencies of the reclassified variable be equal to those of `varlist'"
			cumul_f `targtab' `ncat'
			return matrix gentab `parmat'
			return matrix margin mrgn
			return matrix classprob rcdcum
			restore
			exit
		}
		else if "`bestmod'" == "nobestmod" {
			* don't try to determine the best model
			* margins will be equal but the association between original/reclassified
			* may be arbitrary
			display as text _newline "The reclassification probabilities will be adjusted to let"
			display as text "the expected frequencies of the reclassified variable be equal to those of `varlist'"
			trg_assoc `parmat'
		}
		else {
			display as text _newline"The reclassification probabilities will be adjusted to let"
			display as text "the expected frequencies of the reclassified variable be equal to those of `varlist'"
			if `ptype' == 3 {
				display as text _newline "A distance model will be determined for the initial expected table"
				get_dist `how'
			}
			else {
				display as text _newline "The expected table will be quasi-independent"
				get_q `ptype' `how'
			}
		}
	}
	else if "`assoc'" ~= "" {
		capture `assoc'
		if _rc ~= 0 {
			local rc=_rc
			display as error "Program `assoc' produced an error (rc `rc')"
			exit
		}
		tempvar checkit
		capture gen `checkit' = sum(missing(paras))
		if _rc ~= 0 {
			local rc=_rc
			display as error "Variable paras was not defined by program `assoc' (rc `rc')"
			exit
		}
		local nmiss=`checkit'[_N]
		if `nmiss' ~= 0 {
			display as error "Variable paras contains `nmiss' missing values!"
			exit
		}

		display as text "Pattern of association defined by program `assoc' will be used for variable `varlist'"
		table orig dest [iw=paras], format(`format')
	}
	else if `q' ~= 1 | `u' ~= 1 | `dist' ~= 1 {
		* parameters for a constrained quasi-uniform association model
		display "Variable `varlist':"
		display "Odds of correct versus misclassification: `q'"
		gen paras=(orig==dest)*ln(`q')
		if `u' ~= 1 {
			display "Uniform association coefficient: `u'"
			quietly replace paras=paras+orig*dest*ln(`u')
		}
		else if `dist' ~= 1 {
			display ", Distance parametr: `dist'"
			quietly replace paras=paras+abs(orig-dest)*ln(`dist')
		}
	}
	else {
		display as error "You must specify either {hi:pcnttab} or {hi:assoc} or one of {hi:q}, {hi:u}, or {hi:dist}"
		exit
	}

	* variable -paras- has been defined above as the log association pattern
	* now estimate the adjusted table using -paras- as an offset variable

	* calculate dummies for 'halfway' effects, i.e. equal main effects
	`how' tabulate orig, generate(rw)
	`how' tabulate dest, generate(cl)
	forval i=1/`ncat' {
		gen hlf`i'=rw`i'+cl`i'
	}
	local nc_1=`ncat'-1

	* estimate a loglinear model with parameters as an offset
	* the predicted values have the same marginals as the input table
	* and the same pattern of association as the offset
	`how' poisson frq hlf1-hlf`nc_1', offset(paras)
	`how' predict pred, n

	display _newline "Adjusted expected table:"
	table orig dest [iw=pred], format(`format') row col

	`how' tabulate orig dest [iw=pred], row nofreq matcell(rcd)
	tempvar rcdprob
	mat `rcdprob'=inv(diag(rcd*J(`ncat',1,1)))*rcd
	quietly replace pred=`rcdprob'[orig,dest]
	display _newline "Final reclassification probabilities:"
	table orig dest [iw=pred], format(`format') col

	* calculate cumulative frequencies
	cumul_f `rcdprob' `ncat'
	return matrix gentab rcd
	return matrix margin mrgn
	return matrix classprob rcdcum
	restore
end

program define trg_assoc
	version 7
	* the input matrix `parmat' has been defined by the pncttab of misclass options
	* as the expected table of original by reclassified
	* next: make `parmat' symmetric, use its log values as an offset
	* to generate the adjusted table
	args parmat
	local nrow=rowsof(`parmat')
	local ncol=colsof(`parmat')
	forval i=1/`nrow' {
		forval j=`i'/`ncol' {
			if `parmat'[`i',`j'] == 0 {
				mat `parmat'[`i',`j'] = 1e-12
			}
			if `parmat'[`j',`i'] == 0 {
				mat `parmat'[`j',`i'] = 1e-12
			}
			mat `parmat'[`i',`j']=( ln(`parmat'[`i',`j'])+ln(`parmat'[`j',`i']) )/2
			mat `parmat'[`j',`i']=`parmat'[`i',`j']
		}
	}
	quietly replace paras=`parmat'[orig,dest]
end

program define get_q
	version 7
	args ptype how
	gen d=(orig==dest)
	if `ptype' ~= 1 {
		quietly replace d=d*orig
	}
	`how' xi: poisson paras i.orig i.dest i.d
	quietly replace paras=0
	foreach var of varlist _Id_* {
		quietly replace paras=paras+`var'*_b[`var']
		display as text "ln(q)=: " as result %13.3f _b[`var']
	}
end

program define get_dist
	version 7
	args how
	gen diag=(orig==dest)
	gen u=orig*dest
	gen dist=abs(orig-dest)
	`how' xi: poisson paras i.orig i.dest diag u
	`how' poisgof
	scalar dev1=r(chi2)
	scalar df1=r(df)
	estimates hold qu
	`how' xi: poisson paras i.orig i.dest diag dist
	`how' poisgof
	if r(chi2) < dev1 {
		quietly replace paras=diag*_b[diag]+dist*_b[dist]
		display as text "using a quasi distance model with ln(q)=" /*
		*/ as result %8.3f _b[diag] "{text: and ln(dist)=}" as result  %8.3f _b[dist]
		display as text "deviance: " as result %12.3f r(chi2) "{text: with }" as result %2.0f r(df) "{text: df}"
		estimates drop qu
	}
	else {
		estimates unhold qu
		quietly replace paras=diag*_b[diag]+u*_b[u]
		display as text "using a quasi uniform association model with ln(q)=" /*
		*/ as result %8.3f _b[diag] "{text: and ln(u)=}" as result  %8.3f _b[u]
		display as text "deviance: " as result %12.3f dev1 "{text: with }" as result %2.0f df1 "{text: df}"
	}
end

program define cumul_f
	version 7
	args inmat ncat
	mat rcdcum=`inmat'
	forval j=2/`ncat' {
		matrix rcdcum[1,`j']=rcdcum[1...,`j']+ rcdcum[1...,`j'-1]
	}
end
