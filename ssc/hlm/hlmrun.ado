*! version 2.0, sean f. reardon, 30dec2005

/*-------------------------------------------------
The hlmrun program runs an existing hlm command file.
estimates from the model are returned as e-class
-------------------------------------------------*/

capture program drop hlmrun
program define hlmrun, eclass
ereturn clear

version 8.2
	syntax anything (id="hlm cmdfile" name=filename) ///
	[, hlm2 hlm3 noView MDM(string) STore(string) ROBUST]

gettoken path ext: filename, p(".")
if "`ext'"=="" local filename "`filename'.hlm"
else if "`ext'" ~= ".hlm" {
	di in re "file must be an .hlm file"
	error 603
}
confirm file `"`filename'"'

if "`hlm2'"=="hlm2" & "`hlm3'"=="hlm3"  error 197
else if "`hlm2'"=="" & "`hlm3'"=="" local hlm2 "hlm2"

if "`mdm'"=="" local mdm "$mdmfile"
if "`mdm'"=="" {
	di in re "no mdm file specified"
	exit
}

*-----------------------------------------------------------------
*NOTE if $varsinorder == "", then a problem reading in vc matrices 
*from models with > 60 fixed effects estimates
*but not easy to get varsinorder from .hlm commmand file
*-----------------------------------------------------------------

*extract modeltype and variables from hlm command file
*--------------------------------------------------
tempname cmd
file open `cmd' using "`filename'", read
file read `cmd' line
while r(eof) == 0 {
	if `"`=lower(substr("`line'",1,7))'"' == "nonlin:" {
		loc modeltype `"`=trim(lower(subinstr("`line'","nonlin:","",1)))'"'
		tokenize "`modeltype'", parse(",")
		loc modeltype "`1'"
		if "`modeltype'" == "n" loc modeltype "linear"
	}
	else if `"`=lower(substr("`line'",1,7))'"' == "level1:" {
		loc out `"`=trim(lower(subinstr("`line'","level1:","",1)))'"'
		tokenize "`out'", parse("=")
		loc out "`1'"
	}
	else if `"`=lower(substr("`line'",1,8))'"' == "laplace:" {
		loc laplace `"`=lower(substr("`line'",9,1))'"'
	}
	else if `"`=lower(substr("`line'",1,9))'"' == "laplace6:" {
		loc l6 `"`=lower(substr("`line'",10,1))'"'
	}
	else if `"`=lower(substr("`line'",1,11))'"' == "emlaplace5:" {
		loc eml5 `"`=lower(substr("`line'",12,1))'"'
	}
	else if `"`=lower(substr("`line'",1,9))'"' == "deviance:" {
		tokenize "`line'", parse(":")
		loc dev = `3'
	}
	else if `"`=lower(substr("`line'",1,3))'"' == "df:" {
		tokenize "`line'", parse(":")
		loc df = `3'
	}
	file read `cmd' line
}
file close `cmd'

*determine which results are stored in e(b) and e(V)
*---------------------------------------------------
if "`modeltype'" == "linear" {
	if "`store'"~="lin" & "`store'"~="" {
		di in re "store option invalid for linear model"
		exit 197
	}
	if "`store'" == "" loc store = "lin"
	if "`robust'"=="robust" loc store = "r"
}
else if "`laplace'`l6'`eml5'" == "" {
	if "`store'"~="us" & "`store'"~="pa" &  "`store'"~="" {
		di in re "store option invalid"
		exit 197
	}
	if "`store'" == "" loc store = "us"
	if "`robust'" == "robust" loc store = "`store'r"
}
else if "`laplace'`l6'" ~= "" {
	if "`store'"~="us" & "`store'"~="pa" & "`store'"~="eml" ///
			& "`store'"~="l6" & "`store'"~="" {
		di in re "store option invalid for `modeltype' model"
		exit 197
	if "`robust'" == "robust" & ("`store'" == "eml" | "`store'" == "l6" ///
		di in gr "note: robust standard errors not computed for laplace estimates"
	}
	if "`laplace'" == "y" & "`store'" == "" loc store = "eml"
	else if "`l6'" == "y" & "`store'" == "" loc store "l6"
	if "`robust'" == "robust" & "`store'" ~= "eml" & "`store'" ~= "l6" ///
		loc store = "`store'r"
}


*temporarily rename existing tau & vc files
*------------------------------------------
local d = 0
loc rc = 0
foreach f in gamvc gamvcr gamvcus gamvcusr gamvcpa gamvcpar ///
		gamvceml gamvcl tauvc tauvceml tauvcl6 {
	capture confirm new file "`f'.dat"
	loc rc = `rc' + _rc
}

while `rc' != 0 {
	loc rc = 0
	local d = `d' + 1
	foreach f in gamvc gamvcr gamvcus gamvcusr gamvcpa gamvcpar ///
			gamvceml gamvcl tauvc tauvceml tauvcl6 {
		capture confirm new file "`f'_temp`d'.dat"
		loc rc = `rc' + _rc
	}
}
if `d' != 0 {
	foreach f in gamvc gamvcr gamvcus gamvcusr gamvcpa gamvcpar ///
			gamvceml gamvcl tauvc tauvceml tauvcl6 {
		capture confirm file "`f'.dat"
		if _rc==0 {
			copy "`f'.dat" "`f'_temp`d'.dat"
			erase "`f'.dat" 
		}
	}
}
global vctemp = `d'

*run hlm command file to fit HLM model
*-------------------------------------
!`hlm2'`hlm3' "`mdm'" "`filename'"
if "`view'"=="" view `path'.txt


*store the estimates of gammas and their VC matrices
*------------------------------------------------------------------
loc nvars: word count $varsinorder
loc matlines=int(`=`nvars'+59'/60)
foreach f in null r us usr pa par eml l {
	if "`f'" == "null" loc f ""
	capture confirm file "gamvc`f'.dat"
	if _rc == 0 {
		tempname bvc b_`f' V_`f'
		file open `bvc' using "gamvc`f'.dat", read
		loc gammas ""
		loc l = 1
		while `l' <= `matlines' {
			file read `bvc' line
			loc gammas "`gammas' `line'"
			loc l = `l' + 1
		}
		loc vcmat ""
		loc r = 1
		while `r' <= `nvars' {
		loc l = 1
			while `l' <= `matlines' {
				file read `bvc' line
				loc vcmat "`vcmat' `line'"
				loc l = `l' + 1
			}
			if `r' < `nvars' loc vcmat "`vcmat' \"
			loc r = `r' + 1
		}
		file close `bvc'
		capture erase "gamvc`f'.dat"
		if "`f'" == "" loc f "lin"
		if "`f'" == "l" loc f "l6"
		matrix input b_`f' = (`gammas')
		matrix input V_`f' = (`vcmat')
		matrix rownames b_`f' = "y1"
		matrix colnames b_`f' = $varsinorder
		matrix rownames V_`f' = $varsinorder
		matrix colnames V_`f' = $varsinorder
		matrix se_`f'=vecdiag(cholesky(diag(vecdiag(V_`f'))))
	}
}

capture confirm matrix b_`store'
if _rc == 0 {
	ereturn post b_`store' V_`store', depname(`out')
	matrix b_`store' = e(b)
	matrix V_`store' = e(V)
	loc disp "y"
}
else {
	di in re ///
	`"note: requested results ("`store'") not produced, e(V) and e(b) not stored"'
	loc disp "n"
}
foreach f in lin r us usr pa par eml l6 {
	capture confirm matrix b_`f'
	if _rc == 0 {
		if "`f'" != "r" & "`f'" != "usr" & "`f'" != "par" ///
			ereturn matrix b_`f' = b_`f'
		else matrix drop b_`f'
		ereturn matrix V_`f' = V_`f'
		ereturn matrix se_`f' = se_`f'
	}
}

*store the tau matrices
*----------------------
capture confirm file "tauvc.dat"
if _rc == 0 & "`hlm2'" == "hlm2" {
	tempname tau 
	file open `tau' using "tauvc.dat", read
	file read `tau' line
	loc rtau: word count `line'
	loc taumat ""
	loc r = 1
	while `r' < `rtau' {
		loc taumat "`taumat'`line' \ "
		file read `tau' line
		loc r = `r' + 1
	}
	loc taumat "`taumat'`line'"

	matrix input tau2 = (`taumat')
	ereturn matrix tau2 = tau2

* - - - - - - - - - - - - - - - - - - - - - - - - - 
*need to check dimension of tau information matrix
*before activating the following lines:
*tau information matrix not included in HLM2 tauvc.dat file?

*	loc rdim = `=`rtau'*(`rtau'+1)/2'
*	loc tauimat ""
*	loc r = 1
*	file read `tau' line
*	while `r' < `rdim' {
*		loc tauimat "`tauimat'`line' \ "
*		file read `tau' line
*		loc r = `r' + 1
*	}
*	loc tauimat "`tauimat'`line'"
*	matrix input invtaui = (`tauimat')
*	matrix se_tau = vecdiag(cholesky(diag(vecdiag(invtaui))))
*	ereturn matrix invtaui = invtaui
*	ereturn matrix se_tau = se_tau
* - - - - - - - - - - - - - - - - - - - - - - - - - 

	file read `tau' line
	loc sig2chk: word count `line'
	if `sig2chk' == 1 ereturn scalar sig2 = `line'

	file close `tau'
	capture erase "tauvc.dat"
}
else if _rc == 0 & "`hlm3'" == "hlm3" {
	tempname tau 
	file open `tau' using "tauvc.dat", read
	file read `tau' line
	loc rtau2: word count `line'
	loc tau2mat ""
	loc r = 1
	while `r' < `rtau2' {
		loc tau2mat "`tau2mat'`line' \ "
		file read `tau' line
		loc r = `r' + 1
	}
	loc tau2mat "`tau2mat'`line'"

	file read `tau' line
	loc rtau3: word count `line'
	loc tau3mat ""
	loc r = 1
	while `r' < `rtau3' {
		loc tau3mat "`tau3mat'`line' \ "
		file read `tau' line
		loc r = `r' + 1
	}
	loc tau3mat "`tau3mat'`line'"
	matrix input tau2 = (`tau2mat')
	matrix input tau3 = (`tau3mat')
	ereturn matrix tau2 = tau2
	ereturn matrix tau3 = tau3

* - - - - - - - - - - - - - - - - - - - - - - - - - 
*need to check dimension of tau information matrix
*before activating the following lines:

	loc rdim = `=(`rtau2'*(`rtau2'+1)/2)+(`rtau3'*(`rtau3'+1)/2)'
	loc tauimat ""
	loc r = 1
	file read `tau' line
	while `r' < `rdim' {
		loc tauimat "`tauimat'`line' \ "
		file read `tau' line
		loc r = `r' + 1
	}
	loc tauimat "`tauimat'`line'"
	matrix input invtaui = (`tauimat')
	matrix se_tau = vecdiag(cholesky(diag(vecdiag(invtaui))))
	ereturn matrix invtaui = invtaui
	ereturn matrix se_tau = se_tau
* - - - - - - - - - - - - - - - - - - - - - - - - - 

	file read `tau' line
	loc sig2chk: word count `line'
	if `sig2chk' == 1 ereturn scalar sig2 = `line'

	file close `tau'
	capture erase "tauvc.dat"
}
capture confirm file "tauvceml.dat"
if _rc == 0 {
	tempname taueml 
	file open `taueml' using "tauvceml.dat", read
	file read `taueml' line
	loc rtau: word count `line'
	loc taumat ""
	loc r = 1
	while `r' < `rtau' {
		loc taumat "`taumat'`line' \ "
		file read `taueml' line
		loc r = `r' + 1
	}
	loc taumat "`taumat'`line'"

	file close `taueml'
	matrix input tau2_eml = (`taumat')
	ereturn matrix tau2_eml = tau2_eml
	capture erase "tauvceml.dat"
}
capture confirm file "tauvcl6.dat"
if _rc == 0 {
	tempname taul6 
	file open `taul6' using "tauvcl6.dat", read
	file read `taul6' line
	loc rtau: word count `line'
	loc taumat ""
	loc r = 1
	while `r' < `rtau' {
		loc taumat "`taumat'`line' \ "
		file read `taul6' line
		loc r = `r' + 1
	}
	loc taumat "`taumat'`line'"
	matrix input tau2_l6 = (`taumat')
	ereturn matrix tau2_l6 = tau2_l6

* - - - - - - - - - - - - - - - - - - - - - - - - - 
*need to check dimension of tau information matrix
*before activating the following lines:

*	loc rdim = `=`rtau'*(`rtau'+1)/2'
*	loc tauimat ""
*	loc r = 1
*	file read `taul6' line
*	while `r' < `rdim' {
*		loc tauimat "`tauimat'`line' \ "
*		file read `taul6' line
*		loc r = `r' + 1
*	}
*	loc tauimat "`tauimat'`line'"
*	matrix input invtaui_l6 = (`tauimat')
*	matrix se_tau_l6 = vecdiag(cholesky(diag(vecdiag(invtaui_l6))))
*	ereturn matrix invtaui_l6 = invtaui_l6
*	ereturn matrix se_tau_l6 = se_tau_l6
* - - - - - - - - - - - - - - - - - - - - - - - - - 

	file close `taul6'
	capture erase "tauvcl6.dat"
}

*store the deviance statistics
*-----------------------------
mac drop df dev dev_us dev_pa dev_eml dev_l6

tempname outfile
file open `outfile' using `"`path'.txt"', read
file read `outfile' line
loc line: subinstr loc line `"'"' `"""', all
*set trace on
while r(eof) == 0 {
	tokenize `"`line'"'
	if `"`=lower(substr(trim(`"`line'"'),1,22))'"' == "the maximum number of " {
		if "`5'" == "level-1" ereturn scalar N_1 = `8'
		if "`5'" == "level-2" ereturn scalar N_2 = `8'
		if "`5'" == "level-3" ereturn scalar N_3 = `8'
	}
	if "`=lower(substr(`"`1'"',2,8))'" == "results" {
		loc w = 1
		while "``w''" ~= "" {
			if "`=lower(`"``w''"')'" == "unit-specific" loc results = "_us"
			if "`=lower(`"``w''"')'" == "population" loc results = "_pa"
			if "`=lower(`"``w''"')'" == "laplace-6" loc results = "_l6"
			if "`=lower(`"``w''"')'" == "laplace-2" loc results = "_eml"
			loc w = `w' + 1
		}
		file read `outfile' line
		loc line: subinstr loc line `"'"' `"""', all
		tokenize `"`line'"'
		loc w = 1
		while "``w''" ~= "" {
			if "`=lower(`"``w''"')'" == "unit-specific" loc results = "_us"
			if "`=lower(`"``w''"')'" == "population" loc results = "_pa"
			if "`=lower(`"``w''"')'" == "laplace-6" loc results = "_l6"
			if "`=lower(`"``w''"')'" == "laplace-2" loc results = "_eml"
			loc w = `w' + 1
		}
	}	
	if "`1'" == "Deviance" {
		global dev`results' = `3'
		ereturn scalar dev`results' = ${dev`results'}
	}
	if `"`=lower(substr(trim(`"`line'"'),1,30))'"' ///
		== "number of estimated parameters" global df = `6'
	file read `outfile' line
	loc line: subinstr loc line `"'"' `"""', all
}
file close `outfile' 

ereturn local cmd "`hlm2'`hlm3'"
ereturn local model "`modeltype'"
ereturn local depvar "`out'"
ereturn local cmdfile `"`filename'"'
local setype "non-robust"
if "`robust'" === "robust" & "`store'" ~= "eml" local setype "robust"
ereturn local setype "`setype'"
local esttype ""
if "`store'" == "us" | "`store'" == "usr" local esttype "unit-specific"
if "`store'" == "pa" | "`store'" == "par" local esttype "population-average"
if "`store'" == "eml" local esttype "em laplace"
if "`store'" == "l6" local esttype "laplace-6"
ereturn local esttype "`esttype'"
if "`esttype'" ~= "" local esttype " `esttype'"

if "$df" ~= "" ereturn scalar df = $df

if "`disp'" == "y" {
	di in gr "dependent variable: " in ye "`out'"
	di in gr "model type: " in ye "`modeltype'"
	di in gr "results: " in ye "estimated`esttype' gammas with `setype' standard errors"
	ereturn display
}

if "`dev'" ~= "" & "`e(df)'" ~= "" {
	loc results: subinstr loc store "r" "", all
	loc results "_`results'"
	if "`results'" == "_lin" local results ""
	di
	if (`e(dev`results')'-`dev')*(`e(df)'-`df')>0 ///
		di in re "Caution: Models are not nested"
	di in gr "{col 25}Deviance{col 40}df"
	di in gr "---------------------------------------------
	di in gr "Current model:{col 25}" e(dev`results') " {col 40}" e(df)
	di in gr "Comparison model:{col 25}" `dev' " {col 40}" `df'
	di in gr "Difference:{col 25}" in ye abs(`e(dev`results')'-`dev') ///
		 " {col 40}" abs(`e(df)'-`df')
	di
	di in ye "P-value:{col 24}" ///
		1-chi2(abs(`e(df)'-`df'),abs(`e(dev`results')'-`dev')) 
	di in gr "---------------------------------------------
}

*drop new tau and vc files and rename old ones
*---------------------------------------------
if $vctemp != 0 {
	foreach f in gamvc gamvcr gamvcus gamvcusr gamvcpa gamvcpar ///
			gamvceml gamvcl tauvc tauvceml tauvcl6 {
		capture confirm file "`f'_temp${vctemp}.dat"
		if _rc==0 copy "`f'_temp${vctemp}.dat" "`f'.dat"
		if _rc==0 erase "`f'_temp${vctemp}.dat" 
	}
}
mac drop vctemp


end

