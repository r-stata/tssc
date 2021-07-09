/*
CREATED:	8 Sep 2017
AUTHOR:		Victoria N Nyaga
PURPOSE: 	To fit a bivariate random-effects model to diagnostic data and 
			produce a series of graphs(sroc and forestsplots).
VERSION: 	1.0.0
NOTES
1. Variable names should not contain underscore(_)
2. Data should be sorted and no duplicates
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
UPDATES
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
DATE:						DETAILS:

*/



/*++++++++++++++++++++++	METADTA +++++++++++++++++++++++++++++++++++++++++++
						WRAPPER FUNCTION
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
cap program drop metadta
program define metadta, eclass sortpreserve byable(recall)
version 14.0

	#delimit ;
	syntax varlist(min=4) [if] [in], 
	STudyid(varname) /*Study Idenfier*/
	[
	LAbel(string asis) /*namevar=namevar, yearvar=yearvar*/
	DP(integer 2) /*Decimal place*/
	POWer(integer 0) /*Exponentiating power*/  
	MODel(string asis) /*fixed (1 < n < 3) | random (random)*/ 
	COV(string) /*UNstructured(default)|INdependent | IDentity | EXchangeable*/
	SORTby(varlist) /*order data by varlist. How data appears on the table and forest plot*/
	INteraction(string) /*sesp(default)|se|sp*/ 
	CVeffect(string) /*sesp(default)|se|sp*/ 
	Level(integer 95) /*Significance level*/
	PAIRed /*Paired data or not*/
	OUTtable(string) /*Which summary tables to present:abs|logodds|rr|all*/
	CImethod(string) /*ci method for the study proportions*/
	noFPlot /*No forest plot*/
	noITable /*No study specific summary table*/
	noMC /*No Model comparison - Saves time*/
	PROGress /*See the model fitting*/
	noSRoc /*No SROC*/
	noOVerall /*Dont report the overall in the Itable & fplot*/ 
	noSUBgroup /*Dont report the subgroup in the Itable & fplot*/ 
	SUMMaryonly /*Present only summary in the Itable & fplot*/
	DOWNload(string) /*Keep a copy of data used in the plotting*/
	Alphasort /*Sort the categorical variable alphabetically*/
	FOptions(string asis) /*Options specific to the forest plot*/
	SOptions(string asis) /*Options specific to the sroc plot*/
	] ;
	#delimit cr
	
	preserve
	cap ereturn clear
	marksample touse, strok 
	qui drop if !`touse'

	tempvar rid se sp event total invtotal use id neolabel es lci uci df
	tempname logodds absout rrout selogodds absoutse serrout splogodds absoutsp ///
		sprrout coefmat coefvar BVar WVar Esigma omat isq2 bghet bshet lrtestp V dftestnl ptestnl se_lrtest sp_lrtest
	
	if _by() {
		global by_index_ = _byindex()
		if "`graph'" == "" & "$by_index_" == "1" {
			cap graph drop _all
		}
	}
	else {
		global by_index_ 
	}
	
	/*Check if variables exist*/
	foreach var of local varlist {
		cap confirm var `var'
		if _rc!=0  {
			di in re "Variable `var' not in the dataset"
			exit _rc
		}
	}
	
	//General housekeeping
	if 	"`model'" == "" {
		local model random
	}
	else {
		tokenize "`model'", parse(",")
		local model `1'
		local modelopts "`3'"
	}
	if strpos("`model'", "f") == 1 {
		local model "fixed"
	}
	else if strpos("`model'", "r") == 1 {
		local model "random"
	}
	else {
		di as error "Option `model' not allowed in [`model', `modelopts']"
		di as error "Specify either -fixed- or -random-"
		exit
	}
	if "`model'" == "fixed" & strpos("`modelopts'", "ml") != 0 {
		di as error "Option ml not allowed in [`model', `modelopts']"
		exit
	}
	if "`model'" == "fixed" & strpos("`modelopts'", "irls") != 0 {
		di as error "Option irls not allowed in [`model', `modelopts']"
		exit
	}
	qui count
	if `=r(N)' < 2 {
		di as err "Insufficient data to perform meta-analysis"
		exit 
	}
	if `=r(N)' < 3 & "`model'" == "random"  {
		local model fixed //If less than 3 studies, use fixed model
		di as res _n  "Note: Fixed-effects model imposed whenever number of studies is less than 3."
		if "`modelopts'" != "" {
			local modelopts
			di as res _n  "Warning: Model options ignored."
			di as res _n  "Warning: Consider specifying options for the fixed-effects model."
		}
	}
	if "`model'" == "random" {
		if "`cov'" == "" {
			local cov = "unstructured"
		}
		else {
			local cov = "`cov'"
			
			if strpos("`cov'", "un")== 1{
				local cov = "unstructured"
			}	
			else if ustrregexm("`cov'", "ind", 1){
				local cov = "independent"
			}
			else if ustrregexm("`cov'", "id", 1){
				local cov = "identity"
			}
			else if strpost("`cov'", "ex") == 1{
				local cov = "exchangeable"
			}
			else {
				di as error "Allowed covariance structures: unstructured, independent, identity, or exchangeable"
				exit
			}
		}
	}
	else {
		local cov
	}		
	if `level' < 1 {
			local level `level'*100
	}
	if `level'>99 | `level'<10 {
		local level 95
	}
	/*By default the regressor variabels apply to both sensitivity and specificity*/
	if "`cveffect'" == "" {
		local cveffect "sesp"
	}
	else {
		local rc_ = ("`cveffect'"=="sesp") + ("`cveffect'"=="se") + ("`cveffect'"=="sp")
		if `rc_' != 1 {
			di as err "Options cveffect(`cveffect') incorrectly specified"
			di as err "Allowed options: sesp, se sp"
			exit
		}
	}
	if "`interaction'" != "" {
		if ("`interaction'" != "`cveffect'") & ("`cveffect'" != "`sesp'"){
			di as err "Conflict in cveffect(`cveffect') & interaction(`interaction')"
			exit
		}
	}
	
	tokenize `varlist'
	local depvars "`1' `2' `3' `4'"
	macro shift 4
	local regressors "`*'"
	gettoken idpair confounders : regressors
	local p: word count `regressors'
	*local idpair: word 1 of `regressors'
	if "`paired'" != ""  & "`idpair'" == "" {
		local paired
	}
	if `p' < 2 & "`interaction'" !="" {
		di as error "Interactions allowed with atleast 2 covariates"
		exit
	}
	if "`paired'" != "" {
		cap assert `p' > 0
		if _rc != 0 {
			di as error "Paired analysis requires at least 1 covariate to be specified"
			exit _rc
		}
	}
		
	local nuse = "mu"
	local nusp = "mu"	
	local VarX: word 1 of `regressors'
	forvalues i=1/`p' {
		local c:word `i' of `regressors'
		
		local nuse = "`nuse' + `c'"
		local nusp = "`nusp' + `c'"
		
		if "`interaction'" != "" & `i' > 1 {
			if "`interaction'" == "se" {
				local nuse = "`nuse' + `c'*`VarX'"
			}
			else if "`interaction'" == "sp" {
				local nusp = "`nusp' + `c'*`VarX'"
			}
			else {
				local nuse = "`nuse' + `c'*`VarX'"
				local nusp = "`nusp' + `c'*`VarX'"
			}
		}
	} 
	if "`model'" == "random" {
		local nuse = "`nuse' + `studyid'"
		local nusp = "`nusp' + `studyid'"
	}
	if "`cveffect'" == "se" {
		local nuse = "`nuse'" 
		local nusp = "mu"
	}
	else if "`cveffect'" == "sp" {
		local nuse = "mu" 
		local nusp = "`nusp'"
	} 
	else {
		local nuse = "`nuse'" 
		local nusp = "`nusp'"
	}
	
	di as res _n "*********************************** Fitted model ***************************************"  _n
	
	tokenize `varlist'
	di "{phang} `1' ~ binomial(logit(se), `1' + `4'){p_end}"
	di "{phang} `2' ~ binomial(logit(sp), `2' + `3'){p_end}"
	di "{phang} logit(se) = `nuse'{p_end}"
	di "{phang} logit(sp) = `nusp'{p_end}"
	
	
	if "`model'" == "random" {	
		di "{phang}logit(se), logit(sp) ~ biv.normal(0, sigma){p_end}"
	}
	di _n"*********************************** ************* ***************************************" _n
	//=======================================================================================================================
	//=======================================================================================================================
	tempfile master
	qui save "`master'"
	
	fplotcheck,`paired' `foptions' //Forest plot advance housekeeping
	local outplot = r(outplot)
	local foptions = r(foptions)
	local lcols = r(lcols)
	if "`lcols'" == " " { //if empty
		local lcols
	}
	
	*declare study labels for display
	if "`label'"!="" {
		tokenize "`label'", parse("=,")
		while "`1'"!="" {
			cap confirm var `3'
			if _rc!=0  {
				di as err "Variable `3' not defined"
				exit
			}
			local `1' "`3'"
			mac shift 4
		}
	}	
	qui {
		*put name/year variables into appropriate macros
		if "`namevar'"!="" {
			local lbnvl : value label `namevar'
			if "`lbnvl'"!=""  {
				quietly decode `namevar', gen(`neolabel')
			}
			else {
				gen str10 `neolabel'=""
				cap confirm string variable `namevar'
				if _rc==0 {
					replace `neolabel'=`namevar'
				}
				else if _rc==7 {
					replace `neolabel'=string(`namevar')
				}
			}
		}
		if "`namevar'"==""  {
			cap confirm numeric variable `studyid'
			if _rc != 0 {
				gen `neolabel' = `studyid'
			}
			if _rc == 0{
				gen `neolabel' = string(`studyid')
			}
		}
		if "`yearvar'"!="" {
			local yearvar "`yearvar'"
			cap confirm string variable `yearvar'
			if _rc==7 {
				local str "string"
			}
			if "`namevar'"=="" {
				replace `neolabel'=`str'(`yearvar')
			}
			else {
				replace `neolabel'=`neolabel'+" ("+`str'(`yearvar')+")"
			}
		}
	}
		
	//Long format
	longsetup `varlist', rid(`rid') se(`se') event(`event') total(`total')  

	buildregexpr `varlist', cveffect(`cveffect') interaction(`interaction') se(`se') sp(`sp') `alphasort'
	
	local regexpression = r(regexpression)
	local seregexpression = r(seregexpression)
	local spregexpression = r(spregexpression)
	local catreg = r(catreg)
	local contreg = r(contreg)
	
	if "`catreg'" != " " {
		di _n "{phang}Base levels{p_end}"
		di _n as txt "{pmore} Variable  -- Base Level{p_end}"
		foreach fv of local catreg {
			local lab:label `fv' 1
			di "{pmore} `fv'  -- `lab'{p_end}"
		}
	}	
	
	gen `sp' = 1 - `se'
	
	//fit the model
	if "`progress'" != "" {
		local echo noi
	}
	else {
		local echo qui
	}
	`echo' madamodel `event' `total' `se' `sp', cov(`cov') modelopts(`modelopts') model(`model') regexpression(`regexpression') sid(`studyid') `paired' idpair(`idpair') level(`level') 

	estimates store metadta_modest

	cap drop _ESAMPLE
	qui gen _ESAMPLE = e(sample)

	mat `coefmat' = e(b)
	mat `coefvar' = e(V)

	estcovar, matrix(`coefmat') model(`model') covtype(`cov') 
	local kcov = r(k) //#covariance parameters
	mat `BVar' = r(BVar)  //Between var-cov
		
	if("`outtable'" != "") {
		local loddslabel = "Log_odds"
		local abslabel = "Proportion"
		local rrlabel = "Rel_Ratio"
	}

	local S_1 = e(N) -  e(k) //df
	local S_2 = . //between study heterogeneity chi2
	local S_3 = . // between study heterogeneity pvalues
	local S_7 = . //Isq
	local S_71 = . //Isqse
	local S_72 = . //Isqsp
	local S_81 = . //Full vs Null chi2 -- se
	local S_91 = . //Full vs Null  pvalue -- se
	local S_891 = . //Full vs Null  df -- se
	local S_82 = . //Full vs Null chi2 -- sp
	local S_92 = . //Full vs Null  pvalue -- sp
	local S_892 = . //Full vs Null  df -- sp

	//Consider a reduced model	
	if "`model'" == "random" {
		qui estimates restore metadta_modest
		local S_2 = e(chi2_c)
		local S_3 = e(p_c)
	}
	
	if `p' == 0 {
		/*Compute I2*/
		mat `Esigma' = J(2, 2, 0) /*Expected within study variance*/
					
		qui gen `invtotal' = 1/`total'
		qui summ `invtotal' if `se'
		local invtotalse = r(sum)
		
		qui summ `invtotal' if `sp' 
		local invtotalsp = r(sum)
		local K = r(N)/2
		
		mat `Esigma'[1, 1] = (exp(`BVar'[1, 1]*0.5 + `coefmat'[1, 1]) + exp(`BVar'[1, 1]*0.5 - `coefmat'[1, 1]) + 2)*(1/(`K'))*`invtotalse'
		mat `Esigma'[2, 2] = (exp(`BVar'[2, 2]*0.5 + `coefmat'[1, 2]) + exp(`BVar'[2, 2]*0.5 - `coefmat'[1, 2]) + 2)*(1/(`K'))*`invtotalsp'
		
		local detEsigma = `Esigma'[1, 1]*`Esigma'[2, 2]
		
		local detSigma = (1 - (`BVar'[2, 1]/sqrt(`BVar'[1, 1]*`BVar'[2, 2]))^2)*`BVar'[1, 1]*`BVar'[2, 2]
		
		local IsqE = sqrt(`detSigma')/(sqrt(`detEsigma') + sqrt(`detSigma'))
		
		local S_7 = `IsqE'
		local S_71 = (`BVar'[1, 1]/(`Esigma'[1, 1] + `BVar'[1, 1]))  //se
		local S_72 = (`BVar'[2, 2]/(`Esigma'[2, 2] + `BVar'[2, 2])) //sp
	}
	if `p' > 0 & "`mc'" == "" {
		forvalues i=1/2 {
			local S_9`i' = .
			local S_8`i' = .
			local S_89`i' = .
		}
		
		di _n"*********************************** ************* ***************************************" _n
		di as txt _n "Just a moment - Fitting reduced models for comparisons"
		if "`interaction'" !="" {
			local confariates "`confounders'"
		}
		if "`interaction'" ==""  {
			local confariates "`regressors'"
		}
		local initial 1
		foreach c of local confariates {
			
			if "`interaction'" !="" {
				local xterm = "`c'#`idpair'"
				local xnu = "`c'*`idpair'"
			}
			else {
				local xterm = "`c'"
				local xnu = "`c'"
			}
			if "`cveffect'" != "sp" {
				//Sensivitivity terms
				local nullse		
				foreach term of local seregexpression {
					if ("`term'" != "i.`xterm'#c.`se'")&("`term'" != "c.`xterm'#c.`se'")&("`term'" != "`xterm'#c.`se'") {
						local nullse "`nullse' `term'"
					} 
				}
				local nullnuse = subinstr("`nuse'", "+ `xnu'", "", 1)
				di as res _n "Ommitted : `xnu' in logit(se)"
				di as res "{phang} logit(se) = `nullnuse'{p_end}"
				di as res "{phang} logit(sp) = `nusp'{p_end}"
				
				local nullse = "`nullse' `spregexpression'"
				`echo' madamodel `event' `total' `se' `sp',  cov(`cov') modelopts(`modelopts') model(`model') regexpression(`nullse') sid(`studyid') `paired' idpair(`idpair') level(`level') 
				estimates store metadta_Nullse
				
				//LR test the model
				qui lrtest metadta_modest metadta_Nullse
				local selrp :di %10.`dp'f chi2tail(r(df), r(chi2))
				local selrchi2 = r(chi2)
				local selrdf = r(df)
				estimates drop metadta_Nullse
				
				if `initial'  {
					mat `se_lrtest' = [`selrchi2', `selrdf', `selrp']
				}
				else {
					mat `se_lrtest' = [`selrchi2', `selrdf', `selrp'] \ `se_lrtest'
				}
			}
			if "`cveffect'" != "se" {
				//Specificity terms
				local nullsp		
				foreach term of local spregexpression {
					if ("`term'" != "i.`xterm'#c.`sp'")&("`term'" != "c.`xterm'#c.`sp'")&("`term'" != "`xterm'#c.`sp'") {
						local nullsp "`nullsp' `term'"
					} 
				}
				
				local nullnusp = subinstr("`nusp'", "+ `xnu'", "", 1)
				di as res _n "Ommitted : `xnu' in logit(sp)"
				di as res "{phang} logit(se) = `nuse'{p_end}"
				di as res "{phang} logit(sp) = `nullnusp'{p_end}"
				
				local nullsp = "`seregexpression' `nullsp'" 
				`echo' madamodel `event' `total' `se' `sp', cov(`cov') modelopts(`modelopts') model(`model') regexpression(`nullsp') sid(`studyid') `paired' idpair(`idpair') level(`level') 
				estimates store metadta_Nullsp
				
				//LR test the model
				qui lrtest metadta_modest metadta_Nullsp
				local splrp :di %10.`dp'f chi2tail(r(df), r(chi2))
				local splrchi2 = r(chi2)
				local splrdf = r(df)
				estimates drop metadta_Nullsp
				
				if `initial' {
					mat `sp_lrtest' = [`splrchi2', `splrdf', `splrp']
				}
				else {
					mat `sp_lrtest' = [`splrchi2', `splrdf', `splrp'] \ `sp_lrtest'
				}
			}
			local rownameslr "`xnu' `rownameslr'"
			local initial 0
		}
		if "`cveffect'" != "sp" { 
			mat rownames `se_lrtest' = `rownameslr'
			mat colnames `se_lrtest' =  chi2 df p
		}
		if "`cveffect'" != "se" {
			mat rownames `sp_lrtest' = `rownameslr'
			mat colnames `sp_lrtest' = chi2 df p
		}
		//Ultimate null model
		if `p' > 0 {
			if "`cveffect'" != "sp" {
				local nullse `se'		
				local nullse = "`nullse' `spregexpression'"
				`echo' madamodel `event' `total' `se' `sp',  cov(`cov') modelopts(`modelopts') model(`model') regexpression(`nullse') sid(`studyid') `paired' idpair(`idpair') level(`level') 
				estimates store metadta_Nullse
				
				qui lrtest metadta_modest metadta_Nullse
				local S_91 :di %10.`dp'f chi2tail(r(df), r(chi2))
				local S_81 = r(chi2)
				local S_891 = r(df)
				estimates drop metadta_Nullse
			}
			if "`cveffect'" != "se" {
				local nullsp `sp'
				local nullsp = "`seregexpression' `nullsp'"
				`echo' madamodel `event' `total' `se' `sp',  cov(`cov') modelopts(`modelopts') model(`model') regexpression(`nullsp') sid(`studyid') `paired' idpair(`idpair') level(`level') 
				estimates store metadta_Nullsp
				
				qui lrtest metadta_modest metadta_Nullsp
				local S_92 :di %10.`dp'f chi2tail(r(df), r(chi2))
				local S_82 = r(chi2)
				local S_892 = r(df)
				estimates drop metadta_Nullsp
			}
		}
	}
	
	//LOG ODDS
	if ("`outtable'" == "all") |(strpos("`outtable'", "logodds") != 0){
	
		estp, estimates(metadta_modest) sumstat(`loddslabel') depname(Effect) interaction(`interaction') cveffect(`cveffect') catreg(`catreg') contreg(`contreg') se(`se') level(`level')

	}
	else {
		estp, estimates(metadta_modest) sumstat(`loddslabel') depname(Effect) interaction(`interaction') cveffect(`cveffect') catreg(`catreg') contreg(`contreg') se(`se') level(`level') noprint 
	}
	mat `V' = r(Vmatrix) //var-cov for catreg & overall 
	mat `logodds' = r(outmatrix)
	mat `selogodds' = r(outmatrixse)
	mat `splogodds' = r(outmatrixsp)
	
	//ABS
	if ("`outtable'" == "all") |(strpos("`outtable'", "abs") != 0) {
		estp, estimates(metadta_modest) sumstat(`abslabel') depname(Effect) interaction(`interaction') cveffect(`cveffect') catreg(`catreg') contreg(`contreg')  se(`se') level(`level') expit power(`power')
	}
	else {
		estp, estimates(metadta_modest) sumstat(`abslabel') depname(Effect) interaction(`interaction') cveffect(`cveffect') catreg(`catreg') contreg(`contreg') se(`se') level(`level') expit noprint 
	}
	mat `absout' = r(outmatrix)
	mat `absoutse' = r(outmatrixse)
	mat `absoutsp' = r(outmatrixsp)

	//RR
	if "`catreg'" != " " {
		if ("`outtable'" == "all") |(strpos("`outtable'", "rr") != 0) & `p' > 0 {
			estr, estimates(metadta_modest) sumstat(`rrlabel') `paired' cveffect(`cveffect') catreg(`catreg') se(`se') level(`level') power(`power')
		}
		else {
			estr, estimates(metadta_modest) sumstat(`rrlabel') `paired' cveffect(`cveffect') catreg(`catreg') se(`se') level(`level') power(`power') noprint 
		}
		mat `rrout' = r(outmatrix)
		mat `serrout' = r(outmatrixse)
		mat `sprrout' = r(outmatrixsp)
		mat `dftestnl' = r(dftestnl) 
		mat `ptestnl' = r(ptestnl)
	}

	//CI
	if "`outplot'" == "rr" {
		drop `sp'
		*gettokken idpair confounders : regressors
		/*tokenize `regressors'
		macro shift
		local confounders `*'*/
		qui count
		local NStudies = `=r(N)'*0.25
		sort `se' `regressors' `rid'
		egen `id' = seq(), f(1) t(`NStudies') b(1) 
		sort `id' `se' `idpair'
		widesetup `event' `total' `confounders', idpair(`idpair') se(`se') sid(`id')
		gen `sp' = 1 - `se'
		local vlist = r(vlist)
		local cc0 = r(cc0)
		local cc1 = r(cc1)

		koopmanci `event'1 `total'1 `event'0 `total'0, rr(`es') upperci(`uci') lowerci(`lci') alpha(`=1 - `level'*0.01')
		
		//Rename the varying columns
		foreach v of local vlist {
			rename `v'0 `v'_`cc0'
			label var `v'_`cc0' "`v'_`cc0'"
			rename `v'1 `v'_`cc1'
			label var `v'_`cc1' "`v'_`cc1'"
		}
		
		//make new lcols, rcols
		foreach v of local lcols {
			if strpos("`vlist'", "`v'") != 0 {
				local lcols_rr "`lcols_rr' `v'_`cc0' `v'_`cc1'"
			}
			else {
				local lcols_rr "`lcols_rr' `v'"
			}
		}
		local lcols "`lcols_rr'"
		
		//make new depvars
		local depvars_rr 
		
		foreach v of local depvars {
			if strpos("`vlist'", "`v'") != 0 {
				local depvars_rr "`depvars_rr' `v'_`cc0' `v'_`cc1'"
			}
			else {
				local depvars_rr "`depvars_rr' `v'"
			}
		}
		local depvars "`depvars_rr'"
		
		//make new indvars
		local indvars_rr 
		
		foreach v of local indvars {
			if strpos("`vlist'", "`v'") != 0 {
				local indvars_rr "`indvars_rr' `v'_`cc0' `v'_`cc1'"
			}
			else {
				local indvars_rr "`indvars_rr' `v'"
			}
		}
		local regressors "`indvars_rr'"
	}
	else {
		metadta_propci `total' `event', p(`es') lowerci(`lci') upperci(`uci') cimethod(`cimethod') level(`level')
		gen `id' = _n
	}
	forvalues l = 1(1)6 {
		local S_`l'1 = .
		local S_`l'2 = .
	}
	if "`outplot'" == "abs" {
		local senrows = rowsof(`absoutse')
		local spnrows = rowsof(`absoutsp')
		local S_11 = `absoutse'[`senrows', 1] //p (se)
		local S_21 = `absoutse'[`senrows', 2] //se
		local S_31 = `absoutse'[`senrows', 5] //ll
		local S_41 = `absoutse'[`senrows', 6] //ul
		local S_51 = `absoutse'[`senrows', 3] //z
		local S_61 = `absoutse'[`senrows', 4] //pvalue
		
		local S_12 = `absoutsp'[`spnrows', 1] //p (se)
		local S_22 = `absoutsp'[`spnrows', 2] //se
		local S_32 = `absoutsp'[`spnrows', 5] //ll
		local S_42 = `absoutsp'[`spnrows', 6] //ul
		local S_52 = `absoutsp'[`spnrows', 3] //z
		local S_62 = `absoutsp'[`spnrows', 4] //pvalue
		local sumstatse "Sensitivity"
		local sumstatsp "Specificity"
	}
	else {
		local senrows = rowsof(`serrout')
		local spnrows = rowsof(`sprrout')
		local S_11 = `serrout'[`senrows', 1] //p (se)
		local S_21 = `serrout'[`senrows', 2] //se
		local S_31 = `serrout'[`senrows', 5] //ll
		local S_41 = `serrout'[`senrows', 6] //ul
		local S_51 = `serrout'[`senrows', 3] //z
		local S_61 = `serrout'[`senrows', 4] //pvalue
		
		local S_12 = `sprrout'[`spnrows', 1] //p (se)
		local S_22 = `sprrout'[`spnrows', 2] //se
		local S_32 = `sprrout'[`spnrows', 5] //ll
		local S_42 = `sprrout'[`spnrows', 6] //ul
		local S_52 = `sprrout'[`spnrows', 3] //z
		local S_62 = `sprrout'[`spnrows', 4] //pvalue
		
		local sumstatse "Relative Sensitivity"
		local sumstatsp "Relative Specificity"
	}
	//===================================================================================
	//Prepare data for display
	gen `use' = 1  //Individual studies
	
	mat `omat' = (`S_11', `S_31', `S_41' \ `S_12', `S_32', `S_42')
	if `p' < 3 {
		if "`subgroup'" == "" & "`catreg'" != "" {
			if "`outplot'" == "abs" {
				local fgroupvar : word 1 of `catreg'
			}
			else {
				local fgroupvar : word 2 of `catreg'
			}
			if "`sroc'" == "" {
				if `p' == 1 {
					local sgroupvar : word 1 of `catreg'
				}
			}
		}
	}
	if "`fgroupvar'" == "" {
		local subgroup nosubgroup
	}

	mat `isq2' = (`S_71', `S_7' \ `S_7', `S_72') //Isq
	mat `bghet' = (`S_81', `S_91',  `S_891' \  `S_82', `S_92' ,  `S_892' ) //between group heterogeneity
	mat `bshet' = (`S_2', `kcov', `S_3') // chisq, df, pv, I2
	
	prep4show `id' `se' `use' `neolabel' `es' `lci' `uci', ///
		sortby(`sortby') groupvar(`fgroupvar') df(`df') 	///
		outplot(`outplot') serrout(`serrout') absoutse(`absoutse') absoutsp(`absoutsp') 	   	    ///
		sprrout(`sprrout') omat(`omat') `subgroup' `summaryonly'		///
		`overall' download(`download') indvars(`regressors') depvars(`depvars')
		
	//Display the studies
	disptab `id' `se' `use' `neolabel' `es' `lci' `uci' `df', `itable'	dp(`dp') power(`power') ///
		`subgroup' `overall' sumstatse(`sumstatse') sumstatsp(`sumstatsp')  	///
		isq2(`isq2') bghet(`bghet') bshet(`bshet') model(`model') bvar(`BVar') 	///
		catreg(`catreg') outplot(`outplot') interaction(`interaction') ///
		se_lrtest(`se_lrtest') sp_lrtest(`sp_lrtest') p(`p') `mc'
	
	//Draw the forestplot
	if "`fplot'" == "" {
		fplot `es' `lci' `uci' `use' `neolabel' `df' `id' `se', ///	
			studyid(`studyid') power(`power') dp(`dp') level(`level') ///
			groupvar(`fgroupvar')  ///
			outplot(`outplot') lcols(`lcols') `foptions'
	}
	
	//Draw the SROC curve
	if "`sroc'" == "" {
		if `p' > 1  {
			di as res "NOTE: SROC presented for the overall mean."
		}
		use "`master'", clear
		sroc `varlist',  model(`model') selogodds(`selogodds') splogodds(`splogodds') v(`V') bvar(`BVar') ///
		groupvar(`sgroupvar') cimethod(`cimethod') level(`level') p(`p') `soptions'
	}
	
	cap ereturn clear
	
	cap confirm matrix `BVar'
	if _rc == 0 {
		ereturn matrix vcovar = `BVar'
	}

	cap confirm matrix `logodds'
	if _rc == 0 {
		ereturn matrix logodds = `logodds'
	}
	cap confirm matrix `absout'
	if _rc == 0 {
		ereturn matrix absout = `absout'
		ereturn matrix absoutse = `absoutse'
		ereturn matrix absoutsp = `absoutsp'
	}
	cap confirm matrix `rrout'
	if _rc == 0 {
		ereturn matrix rrout = `rrout'
		ereturn matrix serrout = `serrout'
		ereturn matrix sprrout = `sprrout'
	}
	ereturn local se_ES 	= `S_11'
	ereturn local se_seES 	= `S_21'
	ereturn local se_ci_low = `S_31'
	ereturn local se_ci_upp = `S_41'
	ereturn local se_z 		= `S_51'
	ereturn local se_p_z 	= `S_61'
	
	ereturn local sp_ES 	= `S_12'
	ereturn local sp_seES 	= `S_22'
	ereturn local sp_ci_low = `S_32'
	ereturn local sp_ci_upp = `S_42'
	ereturn local sp_z 		= `S_52'
	ereturn local sp_p_z 	= `S_62'
	

	ereturn local se_het 	= `S_81'
	ereturn local se_p_het 	= `S_91'
	ereturn local se_df_het = `S_891'
	ereturn local sp_het 	= `S_82'
	ereturn local sp_p_het 	= `S_92'
	ereturn local sp_df_het = `S_892'
	
	ereturn local df 	= `S_1'
	ereturn local chi2 	= `S_2'
	ereturn local p_chi2 = `S_3'
	ereturn local i_sq 	= `S_7'		
	
	ereturn local cmdline `"`0'"'
	ereturn local cmd "metadta"
	restore 
end

/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: INDEX +++++++++++++++++++++++++
							Find index of word in a string
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

cap program drop index
program define index, rclass
version 14.0

	syntax, source(string asis) word(string asis)
	local nwords: word count `source'
	local found 0
	local index 1

	while (!`found') & (`index' <= `nwords'){
		local iword:word `index' of `source'
		if "`iword'" == `word' {
			local found 1
		}
		local index = `index' + 1
	}
	
	if `found' {
		local index = `index' - 1
	}
	else{
		local index = 0
	}
	return local index `index'
end

/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: myncod +++++++++++++++++++++++++
								Decode by order of data
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/	
cap program drop my_ncod
program define my_ncod
version 14.1

	syntax newvarname(gen), oldvar(varname)
	
	qui {
		cap confirm numeric var `oldvar'
		tempvar by_num 
		
		if _rc == 0 {				
			decode `oldvar', gen(`by_num')
			drop `oldvar'
			rename `by_num' `oldvar'
		}

		* The _by variable is generated according to the original
		* sort order of the data, and not done alpha-numerically

		qui count
		local N = r(N)
		cap drop `varlist'
		gen `varlist' = 1 in 1
		local lab = `oldvar'[1]
		cap label drop `oldvar'
		if "`lab'" != ""{
			label define `oldvar' 1 "`lab'"
		}
		local found1 "`lab'"
		local max = 1
		forvalues i = 2/`N'{
			local thisval = `oldvar'[`i']
			local already = 0
			forvalues j = 1/`max'{
				if "`thisval'" == "`found`j''"{
					local already = `j'
				}
			}
			if `already' > 0{
				replace `varlist' = `already' in `i'
			}
			else{
				local max = `max' + 1
				replace `varlist' = `max' in `i'
				local lab = `oldvar'[`i']
				if "`lab'" != ""{
					label define `oldvar' `max' "`lab'", modify
				}
				local found`max' "`lab'"
			}
		}

		label values `varlist' `oldvar'
		label copy `oldvar' `varlist', replace
		
	}
end
/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: MADAMODEL +++++++++++++++++++
							Fit the logistic model
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
cap program drop madamodel
program define madamodel
version 14.0

	syntax varlist, [ cov(string) model(string) modelopts(string asis) regexpression(string) sid(varname) paired idpair(varname) level(integer 95)]
		tokenize `varlist'	
		if ("`model'" == "fixed") {
			capture noisily binreg `1' `regexpression', noconstant n(`2') ml `modelopts' l(`level')
			local success = _rc
		}
		if ("`model'" == "random") {		
			if strpos(`"`modelopts'"', "iterate") == 0  {
				local modelopts = `"iterate(30) `modelopts'"'
			}
			if strpos(`"`modelopts'"', "intpoi") == 0  {
				qui count
				if `=r(N)' < 7 {
					local modelopts = `"intpoints(`=r(N)') `modelopts'"'
				}
			}
			//First trial
			#delim ;
			capture noisily  meqrlogit (`1' `regexpression', noc )|| 
			  (`sid': `3' `4', noc cov(`cov')),
			  binomial(`2') `modelopts' l(`level');
			#delimit cr 
			
			local success = _rc
			
			//Try to refineopts 3 times
			if strpos(`"`modelopts'"', "refineopts") == 0 {
				local converged = e(converged)
				local try = 1
				while `try' < 3 & `converged' == 0 {
				
					#delim ;					
					capture noisily  meqrlogit (`1' `regexpression', noc )|| 
						(`sid': `3' `4', noc cov(`cov')) ,
						binomial(`2') `modelopts' l(`level') refineopts(iterate(`=10 * `try''));
					#delimit cr 
					
					local success = _rc
					
					local converged = e(converged)
					local try = `try' + 1
				}
			}
			*Try matlog if still difficult
			if (strpos(`"`modelopts'"', "matlog") == 0) & ((`converged' == 0) | (_rc != 0)) {
				#delim ;
				capture noisily  meqrlogit (`1' `regexpression', noc )|| 
					(`sid': `3' `4', noc cov(`cov')),
					binomial(`2') `modelopts' l(`level') refineopts(iterate(`=10 * `try'')) matlog;
				#delimit cr
				
				local success = _rc
				
				local converged = e(converged)
				*If not converged, exit and offer possible solutions
				if (`converged' == 0) {
					di as res "Model could not converge after 5 attempts"
					di as res "Try fitting a simpler model"
					exit
				}
			}
		}
		if `success' != 0 {
			display as error "Unexpected error performing regression"
            exit `success'
		}
end
	/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: metadta_PROPCI +++++++++++++++++++++++++
								CI for proportions
	++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop metadta_propci
	program define metadta_propci
	version 14.1

		syntax varlist [if] [in], p(name) lowerci(name) upperci(name) [cimethod(string) level(real 95)]
		
		qui {	
			tokenize `varlist'
			gen `p' = .
			gen `lowerci' = .
			gen `upperci' = .
			
			count `if' `in'
			forvalues i = 1/`r(N)' {
				local N = `1'[`i']
				local n = `2'[`i']

				cii proportions `N' `n', `cimethod' level(`level')
				
				replace `p' = r(proportion) in `i'
				replace `lowerci' = r(lb) in `i'
				replace `upperci' = r(ub) in `i'
			}
		}
	end
/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: WIDESETUP +++++++++++++++++++++++++
							Transform data to wide format
	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop widesetup
	program define widesetup, rclass
	version 14.1

	syntax varlist, sid(varlist) idpair(varname) [se(varname) sortby(varlist)]

		qui{
			tokenize `varlist'

			tempvar jvar modey diffy
		
			gen `jvar' = `idpair' - 1
			
			/*Check for varying variable and store them*/
			ds
			local vnames = r(varlist)
			local vlist
			foreach v of local vnames {	
				cap drop `modey' `diffy'
				bysort `sid': egen `modey' = mode(`v'), minmode
				egen `diffy' = diff(`v' `modey')
				sum `diffy'
				local sumy = r(sum)
				if (strpos(`"`varlist'"', "`v'") == 0) & (`sumy' > 0) & "`v'" != "`jvar'" & "`v'" != "`idpair'" {
					if "`se'" != "" & "`v'" == "`se'"{
						local v
					}
					local vlist "`vlist' `v'"
				}
			}
			cap drop `modey' `diffy'
			
			sort `sid' `jvar' `sortby'
			
			/*2 variables per study : n N*/			
			reshape wide `1' `2'  `idpair' `vlist', i(`sid' `se') j(`jvar')
			local cc0 = `idpair'0[1]
			local cc1 = `idpair'1[1]
			local idpair0 : lab `idpair' `cc0'
			local idpair1 : lab `idpair' `cc1'
			
			
			return local vlist = "`vlist'"
			return local cc0 = "`idpair0'"
			return local cc1 = "`idpair1'"
		}
	end	
/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: PREP4SHOW +++++++++++++++++++++++++
							Prepare data for display table and graph
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
cap program drop prep4show
program define prep4show
version 14.0

	#delimit ;
	syntax varlist, omat(name) [serrout(name) sprrout(name) absoutse(name) absoutsp(name) sortby(varlist) 
		groupvar(varname) summaryonly nooverall nosubgroup outplot(string) df(name) download(string asis) 
		indvars(varlist) depvars(varlist)]
	;
	#delimit cr
	tempvar sp  expand 
	tokenize `varlist'
	 
	local id = "`1'"
	local se = "`2'" 
	local use = "`3'"
	local label = "`4'"
	local es = "`5'"
	local lci = "`6'"
	local uci = "`7'"
	qui {
		gen `sp' = 1 - `se'
		bys `groupvar' `se' : egen `df' = count(`id') //# studies in each group
		gen `expand' = 1

	//Groups
		if "`groupvar'" != "" {
		gsort `groupvar' `se' `sortby' `id'
		bys `groupvar' `se' : replace `expand' = 1 + 1*(_n==1) + 2*(_n==_N)
		expand `expand'
		gsort `groupvar' `se' `sortby' `id' `expand'
		bys `groupvar' `se' : replace `use' = -2 if _n==1  //group label
		bys `groupvar' `se' : replace `use' = 2 if _n==_N-1  //subgroup
		bys `groupvar' `se' : replace `use' = 0 if _n==_N //blank
		replace `id' = `id' + 1 if `use' == 1
		replace `id' = `id' + 2 if `use' == 2  //subgroup
		replace `id' = `id' + 3 if `use' == 0 //blank
		replace `label' = "Summary" if `use' == 2
		
		qui label list `groupvar'
		local nlevels = r(max)
		forvalues l = 1/`nlevels' {
			if "`outplot'" == "abs" {
				local S_112 = `absoutse'[`l', 1]
				local S_122 = `absoutsp'[`l', 1]
				local S_312 = `absoutse'[`l', 5]
				local S_322 = `absoutsp'[`l', 5]
				local S_412 = `absoutse'[`l', 6]
				local S_422 = `absoutsp'[`l', 6]
			}
			else {
				local S_112 = `serrout'[`l', 1]
				local S_122 = `sprrout'[`l', 1]
				local S_312 = `serrout'[`l', 5]
				local S_322 = `sprrout'[`l', 5]
				local S_412 = `serrout'[`l', 6]
				local S_422 = `sprrout'[`l', 6]
			}
			local lab:label `groupvar' `l'
			replace `label' = "`lab'" if `use' == -2 & `groupvar' == `l'	
			replace `es' = `S_112'*`se' + `S_122'*`sp' if `use' == 2 & `groupvar' == `l'	
			replace `lci' = `S_312'*`se' + `S_322'*`sp' if `use' == 2 & `groupvar' == `l'	
			replace `uci' = `S_412'*`se' + `S_422'*`sp' if `use' == 2 & `groupvar' == `l'	
		}
		}
		
		//Overall
		gsort  `se' `groupvar' `sortby' `id'
		bys `se' : replace `expand' = 1 + 2*(_n==_N)
		expand `expand'
		gsort  `se' `groupvar' `sortby' `id' `expand'
		bys `se' : replace `use' = 3 if _n==_N-1  //Overall
		bys `se' : replace `use' = 0 if _n==_N //blank
		bys `se' : replace `id' = `id' + 1 if _n==_N-1  //Overall
		bys `se' : replace `id' = `id' + 2 if _n==_N //blank
		//Fill in the right info
		local S_11 = `omat'[1, 1]
		local S_31 = `omat'[1, 2]
		local S_41 = `omat'[1, 3]
		local S_12 = `omat'[2, 1]
		local S_32 = `omat'[2, 2]
		local S_42 = `omat'[2, 3]
		replace `es' = `S_11'*`se' + `S_12'*`sp' if `use' == 3	
		replace `lci' = `S_31'*`se' + `S_32'*`sp' if `use' == 3
		replace `uci' = `S_41'*`se' + `S_42'*`sp' if `use' == 3
		replace `label' = "Overall" if `use' == 3
		count if `use'==1 & `se'==1
		replace `df' = `=r(N)' if `use'==3
		
		replace `label' = "" if `use' == 0
		replace `es' = . if `use' == 0 | `use' == -2
		replace `lci' = . if `use' == 0 | `use' == -2
		replace `uci' = . if `use' == 0 | `use' == -2
		
		gsort `se' `groupvar' `sortby'  `id' 
	}
	
	if "`download'" != "" {
		preserve
		qui {
			cap drop _ES _LCI _UCI _USE _LABEL _PARAMETER
			gen _ES = `es'
			gen _LCI = `lci'
			gen _UCI = `uci'
			gen _USE = `use'
			gen _LABEL = `label'
			gen _PARAMETER = `se'
			gen _ID = `id'
			
			keep `depvars' `indvars' _ES _LCI _UCI _ESAMPLE _USE _LABEL _PARAMETER _ID
		}
		di _n "Data saved"
		noi save "`download'", replace
		
		restore
	}
	qui {
		drop if (`use' == 2 | `use' == 3 ) & (`df' == 1) //drop summary if 1 study		
		drop if (`use' == 1 & "`summaryonly'" != "" & `df' > 1) | (`use' == 2 & "`subgroup'" != "") | (`use' == 3 & "`overall'" != "") //Drop unnecessary rows
		gsort `se' `groupvar' `sortby'  `id' 
		bys `se' : replace `id' = _n 
		gsort `id' `se' 
	}
end	
/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: DISPTAB +++++++++++++++++++++++++
							Prepare data for display table and graph
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
cap program drop disptab
program define disptab
version 14.0
	#delimit ;
	syntax varlist, [nosubgroup nooverall level(integer 95) sumstatse(string asis) 
	sumstatsp(string asis) noitable dp(integer 2) power(integer 0) isq2(name) 
	bghet(name) bshet(name) model(string) bvar(name) catreg(string) outplot(string) 
	interaction(string) se_lrtest(name) sp_lrtest(name) p(integer 0) noMC ]
	;
	#delimit cr
	
	tempvar id se use label es lci uci df
	tokenize `varlist'
	qui gen `id' = `1'
	qui gen `se' = `2' 
	qui gen `use' = `3'
	qui gen `label' = `4'
	qui gen `es' = `5'
	qui gen `lci' = `6'
	qui gen `uci' = `7'
	qui gen `df' = 8
	preserve
	if "`itable'" == "" {
		tempvar tlabellen 
		//study label
		local studylb: variable label `label'
		if "`studylb'" == "" {
			local studylb "Study"
		}		
		qui replace `se' = `se' + 1
		qui widesetup `label', sid(`id') idpair(`se')
		
	
		qui gen `tlabellen' = strlen(`label'0)
		qui summ `tlabellen'
		local nlen = r(max) + 5 
		local nlense = strlen("`sumstatse'")
		local nlensp = strlen("`sumstatsp'")
		di as res _n "****************************************************************************************"
		di as res "{pmore2} Study specific test accuracy sensitivity and specificity  {p_end}"
		di as res    "****************************************************************************************" 
		
		di _n as txt _col(`nlen') "| "   _skip(`=22 - round(`nlense'/2)') "`sumstatse'" ///
				  _skip(`=44 - (22 - round(`nlense'/2)) - `nlense' - 1')	"| " _skip(`=22 - round(`nlensp'/2)') "`sumstatsp'" _cont
				  
		di  _n  as txt _col(2) "`studylb'" _col(`nlen') "| "   _skip(5) "Estimate" ///
				  _skip(5) "[`level'% Conf. Interval]"  ///
				  _skip(5)	"| " _skip(5) "Estimate" ///
				  _skip(5) "[`level'% Conf. Interval]" 
				  
		di  _dup(`=`nlen'-1') "-" "+" _dup(44) "-" "+" _dup(44) "-"
		qui count
		local N = r(N)
		
		forvalues i = 1(1)`N' {
			//Group labels
			if ((`use'[`i']== -2)){ 
				di _col(2) as txt `label'0[`i'] _col(`nlen') "|  " _col(`=`nlen' + 45') "|  "
			}
			//Studies -- se
			if ((`use'[`i'] ==1)) { 
				di _col(2) as txt `label'1[`i'] _col(`nlen') "|  "  ///
				_skip(5) as res  %5.`=`dp''f  `es'1[`i']*(10^`power') /// 
				_col(`=`nlen' + 20') %5.`=`dp''f `lci'1[`i']*(10^`power') ///
				_skip(5) %5.`=`dp''f `uci'1[`i']*(10^`power')  _cont
			}
			//studies - sp
			if (`use'[`i'] ==1 )   { 
				di as txt _col(`=`nlen' + 45') "|  "  ///
				_skip(5) as res  %5.`=`dp''f  `es'0[`i']*(10^`power') /// 
				_col(`=`nlen' + 66') %5.`=`dp''f `lci'0[`i']*(10^`power') ///
				_skip(5) %5.`=`dp''f `uci'0[`i']*(10^`power')  
			}
			//Summaries
			if ( (`use'[`i']== 3) | ((`use'[`i']== 2) & (`df'[`i'] > 1))){
				if ((`use'[`i']== 2) & (`df'[`i'] > 1)) {
					di _col(2) as txt _col(`nlen') "|  " _col(`=`nlen' + 45') "|  "
				}		
				di _col(2) as txt `label'0[`i'] _col(`nlen') "|  "  ///
				_skip(5) as res  %5.`=`dp''f  `es'1[`i']*(10^`power') /// 
				_col(`=`nlen' + 20') %5.`=`dp''f `lci'1[`i']*(10^`power') ///
				_skip(5) %5.`=`dp''f `uci'1[`i']*(10^`power') ///
				as txt _col(`=`nlen' + 45') "|  " ///
				_skip(5) as res  %5.`=`dp''f  `es'0[`i']*(10^`power') /// 
				_col(`=`nlen' + 66') %5.`=`dp''f `lci'0[`i']*(10^`power') ///
				_skip(5) %5.`=`dp''f `uci'0[`i']*(10^`power') 
			}
			//Blanks
			if (`use'[`i'] == 0 ){
				di as txt _dup(`=`nlen'-1') "-" "+" _dup(44) "-" "+" _dup(44) "-"		
				di as txt _col(`nlen') "|  " _col(`=`nlen' + 45') "|  "
			}
		}
	}

	if (`p' > 0 ) | ("`model'" =="random") {
		di as res _n "****************************************************************************************"
		
		if "`model'" =="random" {			
			local rho 		= `bvar'[1, 2]/sqrt(`bvar'[1, 1]*`bvar'[2, 2])
			local tau2se 	= `bvar'[1, 1]
			local tau2sp	= `bvar'[2, 2]
			local tau2g		= (1 - (`bvar'[1, 2]/sqrt(`bvar'[1, 1]*`bvar'[2, 2]))^2)*`bvar'[1, 1]*`bvar'[2, 2]
			di as txt _n "Between-study heterogeneity" 
			di as txt _col(28) "rho" _cont
			di as res _n _col(28) %5.`=`dp''f `rho' 
			
			di as txt  _col(28) "Tau.sq" _cont
			if `p' == 0  {
				di as txt _col(45) "I^2(%)" _cont
				local isq2b  = `isq2'[1, 2]*100
				local isq2se = `isq2'[1, 1]*100
				local isq2sp = `isq2'[2, 2]*100
			}			
			di as txt _n  "Generalized" _cont	
			di as res   _col(28) %5.`=`dp''f `tau2g' _col(45) %5.`=`dp''f `isq2b'  
			di as txt  "Sensitivity" _cont	
			di as res    _col(28) %5.`=`dp''f `tau2se' _col(45) %5.`=`dp''f `isq2se'  
			di as txt  "Specificity" _cont
			di as res    _col(28) %5.`=`dp''f `tau2sp' _col(45) %5.`=`dp''f `isq2sp'
		}
		
		if ("`mc'" =="") {
			di as txt _n _col(30) "Chi2"  _skip(8) "degrees of" _cont
			di as txt _n    _col(28) "statistic" 	_skip(6) "freedom"      _skip(8)"p-val"   _cont
		}	
		local nc : word count `catreg'
		
		if "`model'" =="random" {
			local chisq = `bshet'[1, 1]
			local df 	= `bshet'[1, 2]
			local pv 	= `bshet'[1, 3]	
			if ("`mc'" =="") { 		
				di as txt _n "LR Test: RE vs FE model" _cont
				di as res _col(25) %10.`=`dp''f `chisq' _col(45) `df' _col(52) %10.`=`dp''f `pv'  
			}
		}
		
		if (`p' > 0) & ("`mc'" =="") {
			local S_81 = `bghet'[1, 1] //chi
			local S_91 = `bghet'[1, 2] //p
			local S_891 = `bghet'[1, 3] //df
			local S_82= `bghet'[2, 1] //chi
			local S_92 = `bghet'[2, 2] //p
			local S_892 = `bghet'[2, 3] //df
			if (`p' > 1) {
			di as txt _n "LR Test: Full Model vs Intercept-only Model"   _cont
			di as txt _n "Sensitivity " _cont
			di as res  _col(25) %10.`=`dp''f `S_81' _col(45) `S_891' _col(52) %10.`=`dp''f `S_91'   _cont
			di as txt _n "Specificity" _cont
			di as res  _col(25) %10.`=`dp''f `S_82' _col(45) `S_892' _col(52) %10.`=`dp''f `S_92'  
			}	
			di as res _n "****************************************************************************************"
			di as txt _n "Leave-one-out LR Tests: Model comparisons"
			cap confirm matrix `se_lrtest'
			local semat = _rc
			
			cap confirm matrix `sp_lrtest'
			local spmat = _rc
	
			tempname testmat2print
			if (`=`semat' + `spmat'') == 0 {
				mat roweq `se_lrtest' = Sensitivity
				mat roweq `sp_lrtest' = Specificity
				mat `testmat2print' = `se_lrtest' \ `sp_lrtest' 

				local rnames : rownames `testmat2print'
				local nrows = rowsof(`se_lrtest')
				local testrspec "--`="&"*`=`nrows'-1''-`="&"*`=`nrows'-1''-"
			}
			else if `semat' == 0 {
				mat roweq `se_lrtest' = Sensitivity
				mat roweq `sp_lrtest' = Specificity
				mat `testmat2print' = `se_lrtest' \ `sp_lrtest' 

				local rnames : rownames `testmat2print'
				local nrows = rowsof(`se_lrtest')
				local testrspec "--`="&"*`=`nrows'-1''-"
			}
			else {
				mat roweq `sp_lrtest' = Specificity
				mat `testmat2print' = `sp_lrtest' 

				local rnames : rownames `testmat2print'
				local nrows = rowsof(`sp_lrtest')
				local testrspec "--`="&"*`=`nrows'-1''-"
			}
			mat colnames `testmat2print' = chi2 df p
			local rownamesmaxlen = 15
			forvalues r=1(1)`nrows' {
				local crowname:word `r' of `rnames'
				local nlen : strlen local crowname
				local rownamesmaxlen = max(`rownamesmaxlen', min(`nlen', 32)) //Check if there is a longer name
			}			
			
			#delimit ;
			noi matlist `testmat2print', rowtitle(Excluded Effect) 
				cspec(& %`rownamesmaxlen's |  %8.`=`dp''f &  %8.`=`dp''f &  %8.`=`dp''f o2&) 
				rspec(`testrspec') underscore nodotz
			;
			
			#delimit cr
			if "`interaction'" !="" {
				di as txt "*NOTE: Model with and without interaction effect"
			}
			else {
				di as txt "*NOTE: Model with and without main effect"
			}
			

		}			
	}
	restore
end
/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: LONGSETUP +++++++++++++++++++++++++
							Transform data to long format
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
cap program drop longsetup
program define longsetup
version 14.0

syntax varlist, rid(name) se(name) event(name) total(name)

	qui{
	
		tokenize `varlist'
				
		/*The four variables should contain numbers*/
		forvalue i=1(1)4 {
			capture confirm numeric var ``i''
				if _rc != 0 {
					di as error "The variable ``i'' must be numeric"
					exit
				}	
		}
		/*4 variables per study : TP TN FP FN*/
		gen `event'1 = `1'  /*TP*/
		gen `event'0 = `2'  /*TN*/
		gen `total'1 = `1' + `4'  /*DIS = TP + FN*/
		gen `total'0 = `2' + `3' /*NDIS = TN + FP*/
		
		gen `rid' = _n		
		reshape long `event' `total', i(`rid') j(`se')
	}
end

	/*++++++++++++++++	SUPPORTING FUNCTIONS: BUILDEXPRESSIONS +++++++++++++++++++++
				buildexpressions the regression and estimation expressions
	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop buildregexpr
	program define buildregexpr, rclass
	version 13.1
		
		syntax varlist, [cveffect(string) interaction(string) se(name) sp(name) alphasort]
		
		tempvar holder
		tokenize `varlist'
		
		macro shift 4
		local regressors "`*'"
		local p: word count `regressors'
		
		local mixedcov = 0
		if "`regressors'" != "" {		
			foreach cov of local regressors {
				cap confirm string variable `cov'
				if _rc != 0 {
					local mixedcov = 1
				}
			}
		}
	
		local catreg " "
		local contreg " "
		foreach v of local regressors {
			cap confirm string variable `v'
			if !_rc {
				local catreg "`catreg' `v'"
			}
			else {
				local contreg "`contreg' `v'"
			}
		}
		local seregexpression = `"`se'"'
		local spregexpression = `"`sp'"'
		tokenize `regressors'
		forvalues i = 1(1)`p' {			
			capture confirm numeric var ``i''
			if _rc != 0 {
				if "`alphasort'" != "" {
					sort ``i''
				}
				my_ncod `holder', oldvar(``i'')
				drop ``i''
				rename `holder' ``i''
				local prefix_`i' "i"
			}
			else {
				local prefix_`i' "c"
			}
			/*Add the proper expression for regression*/
			local seregexpression = "`seregexpression' `prefix_`i''.``i''#c.`se'"
			local spregexpression = "`spregexpression' `prefix_`i''.``i''#c.`sp'"
			
			if `i' > 1 & "`interaction'" != "" {
				if "`interaction'" == "se" {
					local seregexpression = "`seregexpression' ``i''#`1'#c.`se'"
				}
				else if "`interaction'" == "sp" {
					local spregexpression = "`spregexpression' ``i''#`1'#c.`sp'"
				}
				else {
					local seregexpression = "`seregexpression' ``i''#`1'#c.`se'"
					local spregexpression = "`spregexpression' ``i''#`1'#c.`sp'"
				}
			}
		}
		if "`cveffect'" == "sp" {
			local seregexpression "`se'"
		}
		else if "`cveffect'" == "sp" {
			local spregexpression "`sp'"
		}
		return local  regexpression = "`seregexpression' `spregexpression'"
		return local seregexpression =  "`seregexpression'"
		return local spregexpression  = "`spregexpression'"
		return local  catreg = "`catreg'"
		return local  contreg = "`contreg'"
	end
/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS:  ESTP +++++++++++++++++++++++++
							estimate log odds or proportions after modelling
	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/	
	cap program drop estp
	program define estp, rclass
	version 14.1
		syntax, estimates(string) [sumstat(string) noprint depname(string) expit se(varname) DP(integer 2)) cveffect(string) interaction(string) catreg(varlist) contreg(varlist) power(integer 0) level(integer 95)]
		
			tempname outmatrix matrixout secontregmarixout spcontregmarixout outmatrixse outmatrixsp serow sprow outmatrixse outmatrixsp outmatrixr overallse overallsp Vmatrix
			
			if "`interaction'" != "" {
				local idpair:word 1 of `catreg'
				tokenize `catreg'
				macro shift 
				local catreg `*'
				local idpairconcat "#`idpair'"
			}
			local marginlist
			while "`catreg'" != "" {
				tokenize `catreg'
				local marginlist = `"`marginlist' `1'`idpairconcat'"'
				macro shift 
				local catreg `*'
			}
			qui estimates restore `estimates'
			qui margin `marginlist', over(`se') predict(xb) grand level(`level')
						
			mat `outmatrix' = r(table)'
			mat `Vmatrix' = r(V)
			mat `outmatrix' = `outmatrix'[1..., 1..6]
			
			local rnames :rownames `outmatrix'
			local nrows = rowsof(`outmatrix')
			
			local init 1
			local ncontreg 0
			local contserownames = ""
			local contsprownames = ""
			if "`contreg'" != "" {
				foreach v of local contreg {
					summ `v', meanonly
					local vmean = r(mean)
					qui margin, over(`se') predict(xb) at(`v'=`vmean') level(`level')
					mat `matrixout' = r(table)'
					mat `matrixout' = `matrixout'[1..., 1..6]
					if `init' {
						local init 0
						mat `secontregmarixout' = `matrixout'[2, 1...] 
						mat `spcontregmarixout' = `matrixout'[1, 1...] 
					}
					else {
						mat `secontregmarixout' =  `secontregmarixout' \ `matrixout'[2, 1...]
						mat `spcontregmarixout' =  `spcontregmarixout' \ `matrixout'[1, 1...]
					}
					local contserownames = "`contserownames' `v'"
					local contsprownames = "`contsprownames' `v'"
					local ++ncontreg
				}
				mat rownames `secontregmarixout' = `contserownames'
				mat rownames `spcontregmarixout' = `contsprownames'
			}
			
			if "`expit'" != "" {
				forvalues r = 1(1)`nrows' {
					mat `outmatrix'[`r', 1] = invlogit(`outmatrix'[`r', 1])
					mat `outmatrix'[`r', 5] = invlogit(`outmatrix'[`r', 5])
					mat `outmatrix'[`r', 6] = invlogit(`outmatrix'[`r', 6])
				}
				forvalues r = 1(1)`ncontreg' {
					mat `secontregmarixout'[`r', 1] = invlogit(`secontregmarixout'[`r', 1])
					mat `secontregmarixout'[`r', 5] = invlogit(`secontregmarixout'[`r', 5])
					mat `secontregmarixout'[`r', 6] = invlogit(`secontregmarixout'[`r', 6])
					
					mat `spcontregmarixout'[`r', 1] = invlogit(`spcontregmarixout'[`r', 1])
					mat `spcontregmarixout'[`r', 5] = invlogit(`spcontregmarixout'[`r', 5])
					mat `spcontregmarixout'[`r', 6] = invlogit(`spcontregmarixout'[`r', 6])
				}
			}
	
			local serownames = ""
			local sprownames = ""
			
			local rownamesmaxlen = 10 /*Default*/
			
			local nrowss = `nrows' - 2 //Except the grand rows
			
			//# equations
			if "`cveffect'" == "sesp" {
				local keq 2
			}
			else {
				local keq 1
			} 
			mat `serow' = J(1, 6, .)
			mat `sprow' = J(1, 6, .)

			
			local initse 0
			local initsp 0					
			forvalues r = 1(1)`nrowss' {
				//Labels
				local rname`r':word `r' of `rnames'
				tokenize `rname`r'', parse("#")					
				local parm = "`1'"
				local left = "`3'"
				local right = "`5'"
				
				tokenize `left', parse(.)
				local leftv = "`3'"
				local leftlabel = "`1'"
				
				if "`right'" == "" {
					if "`leftv'" != "" {
						if strpos("`rname`r''", "1b") == 0 {
							local lab:label `leftv' `leftlabel'
						}
						else {
							local lab:label `leftv' 1
						}
						local eqlab "`leftv'"
					}
					else {
						local lab "`leftlabel'"
						local eqlab ""
					}
					local nlencovl : strlen local llab
					local nlencov = `nlencovl' + 1					
				}
				else {								
					tokenize `right', parse(.)
					local rightv = "`3'"
					local rightlabel = "`1'"
					
					if strpos("`leftlabel'", "c") == 0 {
						if strpos("`leftlabel'", "o") != 0 {
							local indexo = strlen("`leftlabel'") - 1
							local leftlabel = substr("`leftlabel'", 1, `indexo')
						}
						if strpos("`leftlabel'", "1b") == 0 {
							local llab:label `leftv' `leftlabel'
						}
						else {
							local llab:label `leftv' 1
						}
					} 
					else {
						local llab
					}
					
					if strpos("`rightlabel'", "c") == 0 {
						if strpos("`rightlabel'", "o") != 0 {
							local indexo = strlen("`rightlabel'") - 1
							local rightlabel = substr("`rightlabel'", 1, `indexo')
						}
						if strpos("`rightlabel'", "1b") == 0 {
							local rlab:label `rightv' `rightlabel'
						}
						else {
							local rlab:label `rightv' 1
						}
					} 
					else {
						local rlab
					}
					
					if (("`rlab'" != "") + ("`llab'" != "")) ==  0 {
						local lab = "`leftv'#`rightv'"
						local eqlab = ""
					}
					if (("`rlab'" != "") + ("`llab'" != "")) ==  1 {
						local lab = "`llab'`rlab'" 
						local eqlab = "`leftv'*`rightv'"
					}
					if (("`rlab'" != "") + ("`llab'" != "")) ==  2 {
						local lab = "`llab'|`rlab'" 
						local eqlab = "`leftv'*`rightv'"
					}
					local nlencovl : strlen local leftv
					local nlencovr : strlen local rightv
					local nlencov = `nlencovl' + `nlencovr' + 1
				}
				
				local lab = ustrregexra("`lab'", " ", "_")
				
				local nlenlab : strlen local lab
				if "`eqlab'" != "" {
					local nlencov = `nlencov'
				}
				else {
					local nlencov = 0
				}
				local rownamesmaxlen = max(`rownamesmaxlen', min(`=`nlenlab' + `nlencov' + 1', 32)) /*Check if there is a longer name*/
				
				//se or sp
				local parm = substr("`parm'", 1, 1)
				mat `outmatrixr' = `outmatrix'[`r', 1...] //select the r'th row

				if `parm' == 0 {
					if `initsp' == 0 {
						mat `outmatrixsp' = `outmatrixr'
					}
					else {
						mat `outmatrixsp' = `outmatrixsp' \ `outmatrixr'
					}
					local initsp 1
					local sprownames = "`sprownames' `eqlab':`lab'"
				}
				else {
					if `initse' == 0 {
						mat `outmatrixse' = `outmatrixr'
					}
					else {
						mat `outmatrixse' = `outmatrixse' \ `outmatrixr'
					}
					local initse 1
					local serownames = "`serownames' `eqlab':`lab'"
				}
			}
			if `nrowss' > 0 {
				mat rownames `outmatrixse' = `serownames'
				mat rownames `outmatrixsp' = `sprownames'
			}			
			if "`interaction'" != "" {
				mat rownames `serow' = "**--Sensitivity--**"
				mat rownames `sprow' = "**--Specificity--**" //19 characters
			}
			else {
				mat rownames `serow' = "*--Sensitivity--*"
				mat rownames `sprow' = "*--Specificity--*" //19 characters
			}
			local rownamesmaxlen = max(`rownamesmaxlen', 19) /*Check if there is a longer name*/
			
			mat `overallsp' = `outmatrix'[`=`nrows'-1', 1...]
			mat `overallse' = `outmatrix'[`nrows', 1...]
			
			mat rownames `overallse' = "Overall"
			mat rownames `overallsp' = "Overall"
			if `nrowss' > 0 | `ncontreg' > 0 {
				if "`cveffect'" == "sesp" {
					local rspec "---`="&"*`=`nrowss'/2 + `ncontreg'''--`="&"*`=`nrowss'/2 + `ncontreg'''-"
					if (`nrowss' > 0) & (`ncontreg' > 0) {
						mat `outmatrix' = `serow' \ `outmatrixse' \ `secontregmarixout' \ `overallse' \ `sprow' \ `outmatrixsp' \ `spcontregmarixout' \ `overallsp'
					}
					else if (`nrowss' > 0) & (`ncontreg' == 0) {
						mat `outmatrix' = `serow' \ `outmatrixse' \ `overallse' \ `sprow' \ `outmatrixsp' \ `overallsp'
					}
					else if (`nrowss' == 0) & (`ncontreg' > 0) {
						mat `outmatrix' = `serow' \ `secontregmarixout' \ `overallse' \ `sprow' \ `spcontregmarixout' \ `overallsp'
					}
				}
				else {
					if "`cveffect'" == "se" {
						if (`nrowss' > 0) & (`ncontreg' > 0) {
							mat `outmatrix' = `serow' \ `outmatrixse' \ `secontregmarixout' \ `overallse' \ `sprow' \ `overallsp'
						}
						else if (`nrowss' > 0) & (`ncontreg' == 0) {
							mat `outmatrix' = `serow' \ `outmatrixse' \ `overallse' \ `sprow' \ `overallsp'
						}
						else if (`nrowss' == 0) & (`ncontreg' > 0) {
							mat `outmatrix' = `serow' \ `secontregmarixout' \ `overallse' \ `sprow' \ `overallsp'
						}
					}
					else {
						if (`nrowss' > 0) & (`ncontreg' > 0) { 
							mat `outmatrix' = `serow' \ `overallse' \ `sprow' \ `outmatrixsp' \`spcontregmarixout' \ `overallsp'
						}
						else if (`nrowss' > 0) & (`ncontreg' == 0) { 
							mat `outmatrix' = `serow' \ `overallse' \ `sprow' \ `outmatrixsp' \ `overallsp'
						}
						else if (`nrowss' == 0) & (`ncontreg' > 0) { 
							mat `outmatrix' = `serow' \ `overallse' \ `sprow' \ `spcontregmarixout' \ `overallsp'
						}
						local rspec "-----`="&"*`=`nrowss'/2 + `ncontreg'''-"
					}
				}
				if (`nrowss' > 0) & (`ncontreg' > 0) {
					mat `outmatrixse' = `outmatrixse' \ `secontregmarixout' \ `overallse' 
					mat `outmatrixsp' = `outmatrixsp' \ `spcontregmarixout' \ `overallsp' 				
				}
				else if (`nrowss' > 0) & (`ncontreg' == 0) {
					mat `outmatrixse' = `outmatrixse' \ `overallse' 
					mat `outmatrixsp' = `outmatrixsp' \ `overallsp' 
				}
				else if (`nrowss' == 0) & (`ncontreg' > 0) {
					mat `outmatrixse' = `secontregmarixout' \ `overallse' 
					mat `outmatrixsp' = `spcontregmarixout' \ `overallsp' 
				}
			}
			else {
				mat rownames `overallse' = "Sensitivity"
				mat rownames `overallsp' = "Specificity"
				mat `outmatrixse' =  `overallse' 
				mat `outmatrixsp' = `overallsp' 
				local rspec "----"
				mat `outmatrix' =  `overallse' \ `overallsp'
				local rownamesmaxlen = max(`rownamesmaxlen', 12) /*Check if there is a longer name*/
			}			
			if "`expit'" == "" {
				mat colnames `outmatrix' = `sumstat' SE z P>|z| Lower Upper
				mat colnames `outmatrixse' = `sumstat' SE z P>|z| Lower Upper
				mat colnames `outmatrixsp' = `sumstat' SE z P>|z| Lower Upper
			}
			else {
				mat colnames `outmatrix' = `sumstat' SE(logit) z(logit) P>|z| Lower Upper
				mat colnames `outmatrixse' = `sumstat' SE(logit) z(logit) P>|z| Lower Upper
				mat colnames `outmatrixsp' = `sumstat' SE(logit) z(logit) P>|z| Lower Upper
			}
			
			if "`print'" == "" {
				local nlensstat : strlen local sumstat
				local nlensstat = max(10, `nlensstat')
				di as res _n "****************************************************************************************"
				di as res "{pmore2} Conditional summary measures of test accuracy : `sumstat' {p_end}"
				di as res    "****************************************************************************************" 
				tempname mat2print
				mat `mat2print' = `outmatrix'
				local nrows = rowsof(`mat2print')
				forvalues r = 1(1)`nrows' {
					mat `mat2print'[`r', 1] = `mat2print'[`r', 1]*10^`power'
					mat `mat2print'[`r', 5] = `mat2print'[`r', 5]*10^`power'
					mat `mat2print'[`r', 6] = `mat2print'[`r', 6]*10^`power'
					local cellr2 = `mat2print'[`r', 2] 
					if "`cellr2'" == "." {
						forvalues c = 1(1)6 {
							mat `mat2print'[`r', `c'] == .z
						}
					}
				}
				
				#delimit ;
				noi matlist `mat2print', rowtitle(Parameter) 
							cspec(& %`rownamesmaxlen's |  %`nlensstat'.`=`dp''f &  %9.`=`dp''f &  %8.`=`dp''f &  %15.`=`dp''f &  %8.`=`dp''f &  %8.`=`dp''f o2&) 
							rspec(`rspec') underscore  nodotz
				;
				#delimit cr
				
				if (`ncontreg' > 0) {
					di as txt "NOTE: For continous variable margins are computed at the respective mean(s) of - `contreg'"
				} 
				if ("`expit'" != "") {
					di as txt "NOTE: H0: p = 0.5 vs. H1: P != 0.5"
				}
			}
		return matrix outmatrixse = `outmatrixse'
		return matrix outmatrixsp = `outmatrixsp'		
		return matrix outmatrix = `outmatrix'
		return matrix Vmatrix = `Vmatrix'
	end	
/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: ESTR +++++++++++++++++++++++++
							Estimate RR after modelling
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop estr
	program define estr, rclass
	version 13.1
		syntax, estimates(string) [catreg(varlist) sumstat(string) se(varname) noprint paired level(integer 95) DP(integer 2) power(integer 0) cveffect(string)]
		
		local ZOVE -invnorm((100-`level')/200)
		
		
		if "`paired'" != "" {
			local idpair:word 1 of `catreg'
			tokenize `catreg'
			macro shift 
			local catreg `*'
			local idpairconcat "#`idpair'"
		}
		local confounders "`catreg'"
		local marginlist
		while "`catreg'" != "" {
			tokenize `catreg'
			local marginlist = `"`marginlist' `1'`idpairconcat'"'
			macro shift 
			local catreg `*'
		}
		
		tempname lcoef lV outmatrix outmatrixse outmatrixsp serow sprow outmatrixse outmatrixsp outmatrixr overallse overallsp setestnl sptestnl serowtestnl sprowtestnl testmat2print
		
		if "`marginlist'" != "" {
			qui estimates restore `estimates'
			qui margins `marginlist', predict(xb) over(`se') post level(`level')
			
			local EstRlnexpression
			foreach c of local confounders {	
				qui label list `c'
				local nlevels = r(max)
				local sp_test_`c'
				local se_test_`c'
				
				if "`paired'" != "" {
					forvalues l = 1/`nlevels' {
						if `l' == 1 {
							local sp_test_`c' = "_b[sp_`c'_`l']"
							local se_test_`c' = "_b[se_`c'_`l']"
						}
						else {
							local sp_test_`c' = "_b[sp_`c'_`l'] = `sp_test_`c''"
							local se_test_`c' = "_b[se_`c'_`l'] = `se_test_`c''"
						}
						local EstRlnexpression = "`EstRlnexpression' (sp_`c'_`l': ln(invlogit(_b[0.`se'#`l'.`c'#2.`idpair'])) - ln(invlogit(_b[0.`se'#`l'.`c'#1.`idpair'])))"	
						local EstRlnexpression = "`EstRlnexpression' (se_`c'_`l': ln(invlogit(_b[1.`se'#`l'.`c'#2.`idpair'])) - ln(invlogit(_b[1.`se'#`l'.`c'#1.`idpair'])))"	
					}
				}
				else {
					local sp_test_`c' = "_b[sp_`c'_2]"
					local se_test_`c' = "_b[se_`c'_2]"
					
					forvalues l = 2/`nlevels' {
						if `l' > 2 {
							local sp_test_`c' = "_b[sp_`c'_`l'] = `sp_test_`c''"
							local se_test_`c' = "_b[se_`c'_`l'] = `se_test_`c''"
						}
						
						local EstRlnexpression = "`EstRlnexpression' (sp_`c'_`l': ln(invlogit(_b[0.`se'#`l'.`c'])) - ln(invlogit(_b[0.`se'#1.`c'])))"	
						local EstRlnexpression = "`EstRlnexpression' (se_`c'_`l': ln(invlogit(_b[1.`se'#`l'.`c'])) - ln(invlogit(_b[1.`se'#1.`c'])))"	
					}
				}
			}			
			qui nlcom `EstRlnexpression', post level(`level')
			mat `lcoef' = e(b)
			mat `lV' = e(V)
			mat `lV' = vecdiag(`lV')	
			local ncols = colsof(`lcoef') //length of the vector
			local rnames :colnames `lcoef'
			
			local rowtestnl			
			local i = 1
			
			foreach c of local confounders {
				qui label list `c'
				local nlevels = r(max)
				if (`nlevels' > 2 & "`paired'" == "") | (`nlevels' > 1 & "`paired'" != ""){
					qui testnl (`se_test_`c'')
					local se_testnl_`c'_chi2 = r(chi2)				
					local se_testnl_`c'_df = r(df)
					local se_testnl_`c'_p = r(p)
					qui testnl (`sp_test_`c'')
					local sp_testnl_`c'_chi2 = r(chi2)
					local sp_testnl_`c'_df = r(df)
					local sp_testnl_`c'_p = r(p)
					if `i'==1 {
						mat `setestnl' =  [`se_testnl_`c'_chi2', `se_testnl_`c'_df', `se_testnl_`c'_p']
						mat `sptestnl' =  [`sp_testnl_`c'_chi2', `sp_testnl_`c'_df', `sp_testnl_`c'_p']
					}
					else {
						mat `setestnl' = `setestnl' \ [`se_testnl_`c'_chi2', `se_testnl_`c'_df', `se_testnl_`c'_p']
						mat `sptestnl' = `sptestnl' \ [`sp_testnl_`c'_chi2', `sp_testnl_`c'_df', `sp_testnl_`c'_p']
					}
					 
					local ++i
					local rowtestnl = "`c' `rowtestnl'"
				}
			}
			
			if `i' > 1 {
				mat rownames `setestnl' = `rowtestnl'
				mat rownames `sptestnl' = `rowtestnl'
				
				mat roweq `setestnl' = Relative_Sensitivity
				mat roweq `sptestnl' = Relative_Specificity
								
				local testrspec "--`="&"*`=`i'-2''-`="&"*`=`i'-2''-"
				mat `testmat2print' =  `setestnl'  \ `sptestnl' 
				mat colnames `testmat2print' = chi2 df p
			}
			
			
			if "`paired'" != "" {
				mat `outmatrix' = J(`=`ncols' + 2', 6, .)
			}
			else {
				mat `outmatrix' = J(`ncols', 6, .)
			}
			local ncols = colsof(`lcoef') /*length of the vector*/
			forvalues r = 1(1)`ncols' {
				mat `outmatrix'[`r', 1] = exp(`lcoef'[1,`r']) /*Estimate*/
				mat `outmatrix'[`r', 2] = sqrt(`lV'[1, `r']) /*se in log scale, power 1*/
				mat `outmatrix'[`r', 3] = `lcoef'[1,`r']/sqrt(`lV'[1, `r']) /*Z in log scale*/
				mat `outmatrix'[`r', 4] =  normprob(-abs(`outmatrix'[`r', 3]))*2  /*p-value*/
				mat `outmatrix'[`r', 5] = exp(`lcoef'[1, `r'] - `ZOVE' * sqrt(`lV'[1, `r'])) /*lower*/
				mat `outmatrix'[`r', 6] = exp(`lcoef'[1, `r'] + `ZOVE' * sqrt(`lV'[1, `r'])) /*upper*/
			}
		}
		else {
			mat `outmatrix' = J(2, 6, .)
			local ncols = 0
		}
		if "`paired'" != "" {	
			qui estimates restore `estimates'
			qui margins `idpair', predict(xb) over(`se') post level(`level')
					
			//log metric
			qui nlcom (sp_Overall: ln(invlogit(_b[0.`se'#2.`idpair'])) - ln(invlogit(_b[0.`se'#1.`idpair']))) ///
					  (se_Overall: ln(invlogit(_b[1.`se'#2.`idpair'])) - ln(invlogit(_b[1.`se'#1.`idpair'])))
					  
			mat `lcoef' = r(b)
			mat `lV' = r(V)
			mat `lV' = vecdiag(`lV')
			
			forvalues r=1(1)2 {
				mat `outmatrix'[`=`ncols' + `r'', 1] = exp(`lcoef'[1,`r'])  //rr
				mat `outmatrix'[`=`ncols' + `r'', 2] = sqrt(`lV'[1, `r']) //se
				mat `outmatrix'[`=`ncols' + `r'', 3] = `lcoef'[1, `r']/sqrt(`lV'[1, `r']) //zvalue
				mat `outmatrix'[`=`ncols' + `r'', 4] = normprob(-abs(`lcoef'[ 1, `r']/sqrt(`lV'[1, `r'])))*2 //pvalue
				mat `outmatrix'[`=`ncols' + `r'', 5] = exp(`lcoef'[1, `r'] - `ZOVE'*sqrt(`lV'[1, `r'])) //ll
				mat `outmatrix'[`=`ncols' + `r'', 6] = exp(`lcoef'[1, `r'] + `ZOVE'*sqrt(`lV'[1, `r'])) //ul
			}
			local rnames = "`rnames' sp_Overall se_Overall"
		}
		
		local sprownames = ""
		local serownames = ""
		local rspec = "-" /*draw lines or not between the rows*/
		local rownamesmaxlen = 10 /*Default*/
		
		local nrows = rowsof(`outmatrix')
		local initse 0
		local initsp 0
		forvalues r = 1(1)`=`nrows' - 2' {
			local rname`r':word `r' of `rnames'
			tokenize `rname`r'', parse("_")					
			local parm = "`1'"
			local left = "`3'"
			local right = "`5'"
			mat `outmatrixr' = `outmatrix'[`r', 1...] //select the r'th row
			if "`5'" != "" {
				local lab:label `left' `right'
				local lab = ustrregexra("`lab'", " ", "_")
				local nlen : strlen local lab
				local rownamesmaxlen = max(`rownamesmaxlen', min(`nlen', 32)) //Check if there is a longer name
				local `parm'rownames = "``parm'rownames' `left':`lab'" 
				if `init`parm'' == 0 {
					mat `outmatrix`parm'' = `outmatrixr'
				}
				else {
					mat `outmatrix`parm'' = `outmatrix`parm'' \ `outmatrixr'
				}
				local init`parm' 1
			}
		}
		if `nrows' > 2 {
			mat rownames `outmatrixse' = `serownames'
			mat rownames `outmatrixsp' = `sprownames'
		}
			
		mat `serow' = J(1, 6, .)
		mat `sprow' = J(1, 6, .)
		
		mat rownames `serow' = "Relative Sensitivity"
		mat rownames `sprow' = "Relative Specificity"  //20 chars
		local rownamesmaxlen = max(`rownamesmaxlen', 21) //Check if there is a longer name
		
		if "`paired'" != "" {
			mat `overallsp' = `outmatrix'[`=`nrows'-1', 1...]
			mat `overallse' = `outmatrix'[`nrows', 1...]
			
			mat rownames `overallse' = "Overall"
			mat rownames `overallsp' = "Overall"
		}

		if `nrows' > 2 & "`paired'" !="" {
			if "`cveffect'" == "sesp" {
				local rspec "---`="&"*`=`nrows'/2 - 1''--`="&"*`=`nrows'/2 - 1''-"
				mat `outmatrix' = `serow' \ `outmatrixse' \ `overallse'  \ `sprow' \ `outmatrixsp' \ `overallsp'
			}
			else {
				if "`cveffect'" == "se" { 
					mat `outmatrix' = `serow' `outmatsehole' `ovmatsehole' 
				}
				else {
					mat `outmatrix' = `sprow' `outmatsphole' `ovmatsphole'
				}
				local rspec "--`="&"*`=`nrows'/2''-"
			}
		}
		if `nrows' > 2 & "`paired'" =="" {
			if "`cveffect'" == "sesp" {
				local rspec "---`="&"*`=`nrows'/2 - 2''--`="&"*`=`nrows'/2 - 2''-"
				mat `outmatrix' = `serow' \ `outmatrixse'  \ `sprow' \ `outmatrixsp'
				mat `outmatrixse' = `serow' \ `outmatrixse'
				mat `outmatrixsp' = `sprow'  \ `outmatrixsp'
			}
			else {
				if "`cveffect'" == "se" { 
					mat `outmatrix' = `serow' \ `outmatrixse'
					mat `outmatrixse' = `serow' \ `outmatrixse'
					mat `outmatrixsp' = J(1, 6, .)
				}
				else {
					mat `outmatrix' = `sprow'  \ `outmatrixsp'
					mat `outmatrixsp' = `sprow'  \ `outmatrixsp'
					mat `outmatrixse' = J(1, 6, .)
				}
				local rspec "--`="&"*`=`nrows'/2'-1'-"
			}		
		}
		if "`paired'" !=""  {
			if `nrows' > 2 {
				mat `outmatrixse' = `outmatrixse' \ `overallse' 
				mat `outmatrixsp' = `outmatrixsp' \ `overallsp' 
			}
			else {
				mat `outmatrixse' =  `overallse' 
				mat `outmatrixsp' = `overallsp'
				mat `outmatrix' = `serow' \ `outmatrixse'  \ `sprow' \ `outmatrixsp'
				local rspec "--&-&-"			
			}
		}

		mat colnames `outmatrixse' = `sumstat' SE(lor) z(lor) P>|z| Lower Upper
		mat colnames `outmatrixsp' = `sumstat' SE(lor) z(lor) P>|z| Lower Upper
		mat colnames `outmatrix' = `sumstat' SE(lor) z(lor) P>|z| Lower Upper
		local nlensstat : strlen local sumstat
		local nlensstat = max(8, `nlensstat')
		if "`print'" == "" {
			di as res _n "****************************************************************************************"
			di as res "{pmore2} Conditional summary measures of test accuracy : `sumstat' {p_end}"
			di as res    "****************************************************************************************" 
			tempname mat2print
			mat `mat2print' = `outmatrix'
			local nrows = rowsof(`mat2print')
			forvalues r = 1(1)`nrows' {
				mat `mat2print'[`r', 1] = `mat2print'[`r', 1]*10^`power'
				mat `mat2print'[`r', 5] = `mat2print'[`r', 5]*10^`power'
				mat `mat2print'[`r', 6] = `mat2print'[`r', 6]*10^`power'
				local cellr2 = `mat2print'[`r', 2] 
				if "`cellr2'" == "." {
					forvalues c = 1(1)6 {
						mat `mat2print'[`r', `c'] == .z
					}
				}
			}
					
			#delimit ;
			noi matlist `mat2print', rowtitle(Parameter) 
						cspec(& %`rownamesmaxlen's |  %`nlensstat'.`=`dp''f &  %8.`=`dp''f &  %8.`=`dp''f &  %13.`=`dp''f &  %8.`=`dp''f &  %8.`=`dp''f o2&) 
						rspec(`rspec') underscore nodotz
			;
			#delimit cr
			if "`confounders'" != "" {
				cap confirm matrix `testmat2print'
				if _rc == 0 {
					di as res _n "****************************************************************************************"
					di as txt _n "Wald-type test for nonlinear hypothesis"
					di as txt _n "{phang}H0: All (log)RR equal vs. H1: Some (log)RR different {p_end}"
					
					#delimit ;
					noi matlist `testmat2print', rowtitle(Parameter) 
								cspec(& %`rownamesmaxlen's |  %8.`=`dp''f &  %8.`=`dp''f &  %8.`=`dp''f o2&) 
								rspec(`testrspec') underscore nodotz
					;
					#delimit cr
				}
			}
			
		}
		cap confirm matrix `setestnl'
		if _rc == 0 {
			return matrix setestnl = `setestnl'
		}
		cap confirm matrix `sptestnl'
		if _rc == 0 {
			return matrix sptestnl = `sptestnl'
		}
		return matrix outmatrix = `outmatrix'
		return matrix outmatrixse = `outmatrixse'
		return matrix outmatrixsp = `outmatrixsp'
	end	
/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: ESTCOVAR +++++++++++++++++++++++++
							Compose the var-cov matrix
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
cap program drop estcovar
program define estcovar, rclass
version 14.0

	syntax, matrix(name) model(string) [covtype(string)]
	//matrix is colvector
	tempname matcoef BVar 
	mat `matcoef' = `matrix''
	local nrows = rowsof(`matcoef')
	
	//Initialize - Default
	mat	`BVar' = (0, 0\ ///
				0, 0)
	local k = 0	
	
	if ("`model'" == "random") {
		if strpos("`covtype'", "uns") != 0 {
			mat	`BVar' = (exp(`matcoef'[`nrows' - 2, 1])^2, exp(`matcoef'[ `nrows' - 1, 1])*exp(`matcoef'[`nrows' - 2, 1])*tanh(`matcoef'[ `nrows', 1])\ ///
						exp(`matcoef'[ `nrows' - 1, 1])*exp(`matcoef'[`nrows' - 2, 1])*tanh(`matcoef'[ `nrows', 1]), exp(`matcoef'[ `nrows' - 1, 1])^2)
			local k = 3
		}		
		else if strpos("`covtype'", "ind") != 0 {
			mat	`BVar' = (exp(`matcoef'[ `nrows' - 1, 1])^2, 0\ ///
						0, exp(`matcoef'[ `nrows', 1])^2)
			local k = 2
		}
		else if strpos("`covtype'", "exc") != 0 {
			mat	`BVar' = (exp(`matcoef'[ `nrows' - 1, 1])^2, exp(`matcoef'[ `nrows' - 1, 1])*exp(`matcoef'[ `nrows' - 1, 1])*tanh(`matcoef'[ `nrows', 1])\ ///
						exp(`matcoef'[ `nrows' - 1, 1])*exp(`matcoef'[ `nrows' - 1, 1])*tanh(`matcoef'[ `nrows', 1]), exp(`matcoef'[ `nrows' - 1, 1])^2)
			local k = 2
		}
		else if strpos("`covtype'", "id") != 0 {
			mat	`BVar' = (exp(`matcoef'[ `nrows', 1])^2, 0\ ///
				0, exp(`matcoef'[ `nrows', 1])^2)
				
			local k = 1
		}
	}
	return matrix BVar = `BVar' //Between heterogeneity
	return local k = `k' //#of unique parameters
end
	/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: 	KOOPMANCI +++++++++++++++++++++++++
								CI for RR
	++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop koopmanci
	program define koopmanci
	version 14.0

		syntax varlist, RR(name) lowerci(name) upperci(name) [alpha(real 0.05)]
		
		qui {	
			tokenize `varlist'
			gen `rr' = . 
			gen `lowerci' = .
			gen `upperci' = .
			
			count
			forvalues i = 1/`r(N)' {
				local n1 = `1'[`i']
				local N1 = `2'[`i']
				local n2 = `3'[`i']
				local N2 = `4'[`i']

				koopmancii `n1' `N1' `n2' `N2', alpha(`alpha')
				mat ci = r(ci)
				
				if (`n1' == 0) &(`n2'==0) {
					replace `rr' = 0 in `i'
				}
				else {
					replace `rr' = (`n1'/`N1')/(`n2'/`N2')  in `i'	
				}
				replace `lowerci' = ci[1, 1] in `i'
				replace `upperci' = ci[1, 2] in `i'
			}
		}
	end
	
	/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: KOOPMANCII +++++++++++++++++++++++++
								CI for RR
	++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop koopmancii
	program define koopmancii, rclass
	version 14.0
		syntax anything(name=data id="data"), [alpha(real 0.05)]
		
		local len: word count `data'
		if `len' != 4 {
			di as error "Specify full data: n1 N1 n2 N2"
			exit
		}
		
		foreach num of local data {
			cap confirm integer number `num'
			if _rc != 0 {
				di as error "`num' found where integer expected"
				exit
			}
		}
		
		tokenize `data'
		cap assert ((`1' <= `2') & (`3' <= `4'))
		if _rc != 0{
			di as err "Order should be n1 N1 n2 N2"
			exit _rc
		}
		
		mata: koopman_ci((`1', `2', `3', `4'), `alpha')
		
		return matrix ci = ci
		return scalar alpha = `alpha'	

	end
/*	SUPPORTING FUNCTIONS: FPLOTCHECK ++++++++++++++++++++++++++++++++++++++++++
			Advance housekeeping for the fplot
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	capture program drop fplotcheck
	program define fplotcheck, rclass
	version 14.1	
	#delimit ;
	syntax  [,
		/*Passed from top*/
		PAIRed 
		/*passed via foptions*/
		AStext(integer 50) 				
		CIOpt(passthru) 
		DIAMopt(passthru) 
		DOUble 
 		LCols(varlist) 
		noOVLine 
		noSTATS
		ARRowopt(passthru) 		
		OLineopt(passthru) 
		OUTplot(string) 
		PLOTstat(passthru) 
		POINTopt(passthru) 
		SUBLine 
		TEXts(real 1.0) 
		XLAbel(passthru) 
		XTick(passthru) 
		*
	  ];
	#delimit cr
	
		if `astext' > 90 | `astext' < 10 {
		di as error "Percentage of graph as text (ASTEXT) must be within 10-90%"
		di as error "Must have some space for text and graph"
		exit
	}
	if `texts' < 0 {
		di as res "Warning: Negative text size (TEXTSize) are ignored"
		local texts
	}	
	
	if "`outplot'" == "" {
		local outplot abs
	}
	else {
		local outplot = strlower("`outplot'")
		local rc_ = ("`outplot'" == "rr") + ("`outplot'" == "abs")
		if `rc_' != 1 {
			di as error "Options outplot(`outplot') incorrectly specified"
			di as error "Allowed options: abs, rr"
			exit
		}
		if "`outplot'" == "rr" {
			cap assert "`paired'" != "" 
			if _rc != 0 {
				di as error "Option outplot(rr) only avaialable with paired analysis"
				di as error "Specify paired analysis with -paired- option"
				exit _rc
			}
		}
	}
	foreach var of local lcols {
		cap confirm var `var'
		if _rc!=0  {
			di in re "Variable `var' not in the dataset"
			exit _rc
		}
	}
	if "`lcols'" =="" {
		local lcols " "
	}
	if "`astext'" != "" {
		local astext "astext(`astext')"
	}
	if "`texts'" != "" {
		local texts "texts(`texts')"
	}
	local foptions `"`astext' `ciopt' `diamopt' `arrowopt' `double' `ovline' `stats' `olineopt' `plotstat' `pointopt' `subline' `texts' `xlabel' `xtick' `options'"'
	return local outplot = "`outplot'"
	return local lcols ="`lcols'"
	return local foptions = `"`foptions'"'
end

/*	SUPPORTING FUNCTIONS: FPLOT ++++++++++++++++++++++++++++++++++++++++++++++++
			The forest plot
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
// Some re-used code from metaprop

	capture program drop fplot
	program define fplot
	version 14.1	
	#delimit ;
	syntax varlist [if] [in] [,
	    /*Passed from top options*/
		STudyid(varname)
		POWer(integer 0)
		DP(integer 2) 
		Level(integer 95)
		/*passed from within*/	
		Groupvar(varname)		
		/*passed via foptions*/
		AStext(integer 50)
		ARRowopt(string) 		
		CIOpt(string) 
		DIAMopt(string) 
		DOUble 
 		LCols(varlist) 
		noOVLine 
		noSTATS 
		OLineopt(string) 
		OUTplot(string) 
		PLOTstat(string asis) 
		POINTopt(string) 
		SUBLine 
		TEXts(real 1.0) 
		XLAbel(string) 
		XTick(string) 
		*
	  ];
	#delimit cr
	
	local foptions `"`options'"'
	
	tempvar effect lci uci use label tlabel id newid se  df  expand orig ///
	
	tokenize "`varlist'", parse(" ")

	qui {
		gen `effect'=`1'*(10^`power')
		gen `lci'   =`2'*(10^`power')
		gen `uci'   =`3'*(10^`power')
		gen byte `use'=`4'
		gen str `label'=`5'
		gen `df' = `6'
		gen `id' = `7'
		gen `se' = `8'
		
		if "`plotstat'"=="" {
			local outplot = strlower("`outplot'")
			if "`outplot'" == "rr" {
				local plotstatse "Relative Sensitivity"
				local plotstatsp "Relative Specificity"
			}
			else {
				local plotstatse "Sensitivity"
				local plotstatsp "Specificity"
			}
		}
		else {
			local plotstatse : word 1 of `plotstat'
			local plotstatsp : word 2 of `plotstat'
		}
		qui summ `id'
		gen `expand' = 1
		replace `expand' = 1 + 1*(`id'==r(min)) 
		expand `expand'
		replace `id' = `id' + 1 if _n>2
		replace `label' = "" if `id'==1
		replace `use' = 0 if `id'==1
		
		sort `id' `se'
		
		//studylables
		local studylb: variable label `studyid'
		if "`studylb'" == "" {
			label var `label' "`studyid'"
		}
		else {
			label var `label' "`studylb'"
		}
		if "`lcols'" == "" {
			local lcols "`label'"
		}
		else {
			local lcols "`label' `lcols'"
		}
		
		egen `newid' = group(`id')
		replace `id' = `newid'
		drop `newid'

		tempvar estText estTextse estTextsp index
		gen str `estText' = string(`effect', "%10.`=`dp''f") + " (" + string(`lci', "%10.`=`dp''f") + ", " + string(`uci', "%10.`=`dp''f") + ")"  if (`use' == 1 | `use' == 2 | `use' == 3)

		// GET MIN AND MAX DISPLAY
		// SORT OUT TICKS- CODE PINCHED FROM MIKE AND FIRandomED. TURNS OUT I'VE BEEN USING SIMILAR NAMES...
		// AS SUGGESTED BY JS JUST ACCEPT ANYTHING AS TICKS AND RESPONSIBILITY IS TO USER!
	
		qui summ `lci', detail
		local DXmin = r(min)
		qui summ `uci', detail
		local DXmax = r(max)
				
		if "`xlabel'" != "" {
			local DXmin = min(`xlabel')
			local DXmax = max(`xlabel')
		}
		if "`xlabel'"=="" {
			local xlabel 0
		}

		local lblcmd ""
		tokenize "`xlabel'", parse(",")
		while "`1'" != ""{
			if "`1'" != ","{
				local lbl = string(`1',"%7.3g")
				local val = `1'
				local lblcmd `lblcmd' `val' "`lbl'"
			}
			mac shift
		}
		
		if "`xtick'" == ""{
			local xtick = "`xlabel'"
		}

		local xtick2 = ""
		tokenize "`xtick'", parse(",")
		while "`1'" != ""{
			if "`1'" != ","{
				local xtick2 = "`xtick2' " + string(`1')
			}
			if "`1'" == ","{
				local xtick2 = "`xtick2'`1'"
			}
			mac shift
		}
		local xtick = "`xtick2'"

		local DXmin1= (min(`xlabel',`xtick',`DXmin'))
		local DXmax1= (max(`xlabel',`xtick',`DXmax'))

		local DXwidth = `DXmax1'-`DXmin1'
	} // END QUI

	/*===============================================================================================*/
	/*==================================== COLUMNS   ================================================*/
	/*===============================================================================================*/
	qui {	// KEEP QUIET UNTIL AFTER DIAMONDS
	
		local titleOff = 0
		
		if "`lcols'" == "" {
			local lcols = "`label'"
			local titleOff = 1
		}
		
		// DOUBLE LINE OPTION
		if "`double'" != "" & ("`lcols'" != "" | "`stats'" == ""){
			*gen `orig' = `id'
			replace `expand' = 1
			replace `expand' = 2 if `use' == 1
			expand `expand'
			sort `id' `se'
			bys `id' `se': gen `index' = _n
			sort  `se' `id' `index'
			egen `newid' = group(`id' `index')
			replace `id' = `newid'
			drop `newid'
			
			replace `use' = 1 if `index' == 2
			replace `effect' = . if `index' == 2
			replace `lci' = . if `index' == 2
			replace `uci' = . if `index' == 2
			replace `estText' = "" if `index' == 2			
			/*
			replace `id' = `id' + 0.75 if `id' == `id'[_n-1] & `se' == `se'[_n-1] & (`use' == 1)
			replace `use' = 1 if mod(`id',1) != 0 
			replace `effect' = .  if mod(`id',1) != 0
			replace `lci' = . if mod(`id',1) != 0
			replace `uci' = . if mod(`id',1) != 0
			replace `estText' = "" if mod(`id',1) != 0
			*/
			foreach var of varlist `lcols' {
			   cap confirm string var `var'
			   if _rc == 0 {				
				tempvar length words tosplit splitwhere best
				gen `splitwhere' = 0
				gen `best' = .
				gen `length' = length(`var')
				summ `length', det
				gen `words' = wordcount(`var')
				gen `tosplit' = 1 if `length' > r(max)/2+1 & `words' >= 2
				summ `words', det
				local max = r(max)
				forvalues i = 1/`max'{
					replace `splitwhere' = strpos(`var',word(`var',`i')) ///
					 if abs( strpos(`var',word(`var',`i')) - length(`var')/2 ) < `best' ///
					 & `tosplit' == 1
					replace `best' = abs(strpos(`var',word(`var',`i')) - length(`var')/2) ///
					 if abs(strpos(`var',word(`var',`i')) - length(`var')/2) < `best' 
				}

				replace `var' = substr(`var',1,(`splitwhere'-1)) if (`tosplit' == 1) & (`index' == 1)
				replace `var' = substr(`var',`splitwhere',length(`var')) if (`tosplit' == 1) & (`index' == 2)
				replace `var' = "" if (`tosplit' != 1) & (`index' == 2) & (`use' == 1)
				drop `length' `words' `tosplit' `splitwhere' `best'
			   }
			   if _rc != 0{
				replace `var' = . if (`index' == 2) & (`use' == 1)
			   }
			}
		}

		tempvar flag
		summ `id' 
		local max = r(max)
		local new = r(N) + 4
		set obs `new' 
		gen `flag' = 0
		replace `flag' = 1 if `id' == .
		forvalues i = 1/4 {	// up to four lines for titles
			local Nnew`i' = r(N)+`i' 
		}
		local maxline = 1
		if "`lcols'" != "" {
			tokenize "`lcols'"
			local lcolsN = 0

			while "`1'" != "" {
				cap confirm var `1'
				if _rc!=0  {
					di in re "Variable `1' not defined"
					exit _rc
				}
				local lcolsN = `lcolsN' + 1
				tempvar left`lcolsN' leftLB`lcolsN' leftWD`lcolsN'
				cap confirm string var `1'
				if _rc == 0{
					gen str `leftLB`lcolsN'' = `1'
				}
				if _rc != 0{
					cap decode `1', gen(`leftLB`lcolsN'')
					if _rc != 0{
						local f: format `1'
						gen str `leftLB`lcolsN'' = string(`1', "`f'")
						replace `leftLB`lcolsN'' = "" if `leftLB`lcolsN'' == "."
					}
				}
				replace `leftLB`lcolsN'' = "" if (`use' != 1) | (`se' != 1)
				local colName: variable label `1'
				if "`colName'"==""{
					local colName = "`1'"
				}

				// WORK OUT IF TITLE IS BIGGER THAN THE VARIABLE
				// SPREAD OVER UP TO FOUR LINES IF NECESSARY
				local titleln = length("`colName'")
				tempvar tmpln
				gen `tmpln' = length(`leftLB`lcolsN'')
				qui summ `tmpln' if `use' != 0
				local otherln = r(max)
				drop `tmpln'
				// NOW HAVE LENGTH OF TITLE AND MAX LENGTH OF VARIABLE
				local spread = int(`titleln'/`otherln') + 1
				if `spread' > 4{
					local spread = 4
				}
				local line = 1
				local end = 0
				local count = -1
				local c2 = -2

				local first = word("`colName'",1)
				local last = word("`colName'",`count')
				local nextlast = word("`colName'",`c2')

				while `end' == 0 {
					replace `leftLB`lcolsN'' = "`last'" + " " + `leftLB`lcolsN'' in `Nnew`line'' //`Nnew`line'' ONDOC
					local check = `leftLB`lcolsN''[`Nnew`line'' ] + " `nextlast'"	// what next will be

					local count = `count'-1
					local last = word("`colName'",`count')
					if "`last'" == ""{
						local end = 1
					}

					if length(`leftLB`lcolsN''[`Nnew`line'']) > `titleln'/`spread' | ///
					  length("`check'") > `titleln'/`spread' & "`first'" == "`nextlast'" {
						if `end' == 0{
							local line = `line'+1
						}
					}
				}
				if `line' > `maxline'{
					local maxline = `line'
				}
				mac shift
			}
		}
		if `titleOff' == 1	{ 
			forvalues i = 1/4{
				replace `leftLB1' = "" in `Nnew`i''  		// get rid of horrible __var name
			}
		}
			
		replace `leftLB1' = `label' if (`use' == -2 |`use' == 2 | `use' == 3)  	// put titles back in (overall, sub est etc.)

		if "`stats'" == "" {		
			gen `estTextse' = `estText'  if `se'== 1
			gen `estTextsp' = `estText' + " " if `se'== 0
			local rcols = "`estTextse' `estTextsp'" 
			label var `estTextse' "`plotstatse' (`level'% CI)"
			label var `estTextsp' "`plotstatsp' (`level'% CI)"
		}
		else {
			gen `extra1' = " "
			gen `extra2' = " "
			label var `extra1' " "
			label var `extra2' " "
			local rcols = "`extra1' `extra2'" 
		}

		local rcolsN = 0
		if "`rcols'" != "" {
			tokenize "`rcols'"
			local rcolsN = 0
			while "`1'" != "" {
				cap confirm var `1'
				if _rc!=0  {
					di in re "Variable `1' not defined"
					exit _rc
				}
				local rcolsN = `rcolsN' + 1
				tempvar right`rcolsN' rightLB`rcolsN' rightWD`rcolsN'
				cap confirm string var `1'
				if _rc == 0{
					gen str `rightLB`rcolsN'' = `1'
				}
				if _rc != 0 {
					local f: format `1'
					gen str `rightLB`rcolsN'' = string(`1', "`f'")
					replace `rightLB`rcolsN'' = "" if `rightLB`rcolsN'' == "."
				}
				local colName: variable label `1'
				if "`colName'"==""{
					local colName = "`1'"
				}

				// WORK OUT IF TITLE IS BIGGER THAN THE VARIABLE
				// SPREAD OVER UP TO FOUR LINES IF NECESSARY
				local titleln = length("`colName'")
				tempvar tmpln
				gen `tmpln' = length(`rightLB`rcolsN'')
				qui summ `tmpln' if `use' != 0
				local otherln = r(max)
				drop `tmpln'
				// NOW HAVE LENGTH OF TITLE AND MAX LENGTH OF VARIABLE
				local spread = int(`titleln'/`otherln')+1
				if `spread' > 4{
					local spread = 4
				}

				local line = 1
				local end = 0
				local count = -1
				local c2 = -2

				local first = word("`colName'",1)
				local last = word("`colName'",`count')
				local nextlast = word("`colName'",`c2')

				while `end' == 0 {
					replace `rightLB`rcolsN'' = "`last'" + " " + `rightLB`rcolsN'' in `Nnew`line''
					local check =  `rightLB`rcolsN''[`Nnew`line''] + " `nextlast'"	// what next will be 

					local count = `count'-1
					local last = word("`colName'",`count')
					if "`last'" == ""{
						local end = 1
					}
					if length(`rightLB`rcolsN''[`Nnew`line'']) > `titleln'/`spread' | ///
					  length("`check'") > `titleln'/`spread' & "`first'" == "`nextlast'" {
						if `end' == 0{
							local line = `line' +1
						}
					}
				}
				if `line' > `maxline' { 
					local maxline = `line' 
				}
				mac shift
			}
		}

		// now get rid of extra title rows if they weren't used
		if `maxline'==3 {
			drop in `Nnew4' 
		}
		if `maxline'==2 {
			drop in `Nnew3'/`Nnew4' 
		}
		if `maxline'==1 {
			drop in `Nnew2'/`Nnew4' 
		}
		
		count if !`flag'
		forvalues i = 1/`maxline' {	// up to four lines for titles
			local multip = 1
			local add = 0
			local idNew`i' = `i'
			local Nnew`i' = r(N)+`i' 
			local tmp = `Nnew`i''
			replace `id' = `maxline' -`idNew`i'' + 1  in `tmp'
			replace `use' = 0 in `tmp'
			if `i' == `maxline' {
				local borderline = `idNew`i'' + 0.75
			}
		}
		summ `id' if `flag'
		local max = ceil(r(max))
		replace `id' = `id' + `max' if `flag'==0
		replace `expand' = 1
		replace `expand' = 2 if `flag' 
		replace `se' = 0 if `se' == .
		count if `expand' > 1
		local nnewlines = r(N)
		expand `expand'
		replace `se' = 1 in `=_N - `nnewlines' + 1'/`=_N'
		replace `use' = -2 if `flag'
		sort `id' `se'
		
		local skip = 1
		if "`stats'" == "" {				// sort out titles for stats and weight, if there
			local skip = 3
		}
		if "`stats'" != "" {
			local skip = 2
		}

		replace `rightLB1' = "" if (`se' == 0)
		replace `rightLB2' = "" if (`se' == 1)
		
		forvalues i = 1/`lcolsN'{
			replace `leftLB`i'' = "" if (`se' == 0)
		}
		
		local leftWDtot = 0
		local rightWDtot = 0
		forvalues i = 1/`lcolsN'{
			getWidth `leftLB`i'' `leftWD`i''
			qui summ `leftWD`i''
			local maxL = r(max)
			local leftWDtot = `leftWDtot' + `maxL'
			replace `leftWD`i'' = `maxL'
			local leftWD`i' = `maxL' 
		}
		forvalues i = 1/`rcolsN'{
			getWidth `rightLB`i'' `rightWD`i''
			qui summ `rightWD`i'' 
			replace `rightWD`i'' = r(max)
			local rightWD`i' = r(max)
			local rightWDtot = `rightWDtot' + r(max)
		}
	
		local LEFT_WD = `leftWDtot'
		local RIGHT_WD = `rightWDtot'
		local ratio = `astext'		// USER SPECIFIED- % OF GRAPH TAKEN BY TEXT (ELSE NUM COLS CALC?)
		local textWD = ((2*`DXwidth')/(1-`ratio'/100)-(2*`DXwidth')) /(`leftWDtot'+`rightWDtot')
	
		local AXmin = `DXmin1' - `leftWDtot'*`textWD'
		local AXmax = `DXmax1' + `DXwidth' + `rightWDtot'*`textWD'
	
		local step 0
		forvalues i = 1/`lcolsN'{
			gen `left`i'' = `AXmin' + `step'
			local step = `leftWD`i''*`textWD' + `step'
		}
		
		local DXmin2 = `DXmax1' + `rightWD1'*`textWD'
		local DXmax2 = `DXmin2'  + `DXwidth'
		
		gen `right1' = `DXmax1'
		gen `right2' = `DXmax2'
		
		replace `effect' = `effect' + `DXmax1' - `DXmin1'  + 0.5*`rightWDtot'*`textWD'  if !`se'
		replace `lci' = `lci' + `DXmax1' - `DXmin1' + 0.5*`rightWDtot'*`textWD'  if !`se'
		replace `uci' = `uci' + `DXmax1' - `DXmin1' + 0.5*`rightWDtot'*`textWD'  if !`se'	
		
		// DIAMONDS 
		tempvar DIAMleftX DIAMrightX DIAMbottomX DIAMtopX DIAMleftY1 DIAMrightY1 DIAMleftY2 DIAMrightY2 DIAMbottomY DIAMtopY
		gen `DIAMleftX'   = `lci' if `use' == 2 | `use' == 3 
		gen `DIAMleftY1'  = `id' if (`use' == 2 | `use' == 3) 
		gen `DIAMleftY2'  = `id' if (`use' == 2 | `use' == 3) 
		
		gen `DIAMrightX'  = `uci' if (`use' == 2 | `use' == 3)
		gen `DIAMrightY1' = `id' if (`use' == 2 | `use' == 3)
		gen `DIAMrightY2' = `id' if (`use' == 2 | `use' == 3)
		
		gen `DIAMbottomY' = `id' - 0.4 if (`use' == 2 | `use' == 3)
		gen `DIAMtopY' 	  = `id' + 0.4 if (`use' == 2 | `use' == 3)
		gen `DIAMtopX'    = `effect' if (`use' == 2 | `use' == 3)
				
		forvalues r=1(1)2 {
			replace `DIAMleftX' = `DXmin`r'' if (`lci' < `DXmin`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')
			replace `DIAMleftX' = . if (`effect' < `DXmin`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')
			/*If one study, no diamond*/
			replace `DIAMleftX' = . if (`df' < 2) & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')
			
			replace `DIAMleftY1' = `id' + 0.4*( abs((`DXmin`r''-`lci')/(`effect'-`lci')) ) if (`lci' < `DXmin`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')
			replace `DIAMleftY1' = . if (`effect' < `DXmin`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')
		
			replace `DIAMleftY2' = `id' - 0.4*( abs((`DXmin`r''-`lci')/(`effect'-`lci')) ) if (`lci' < `DXmin`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')
			replace `DIAMleftY2' = . if (`effect' < `DXmin`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')
			
			replace `DIAMrightX' = `DXmax`r'' if (`uci' > `DXmax`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')
			replace `DIAMrightX' = . if (`effect' > `DXmax`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')
			/*If one study, no diamond*/
			replace `DIAMrightX' = . if (`df' == 1) & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')
		
			replace `DIAMrightY1' = `id' + 0.4*( abs((`uci'-`DXmax`r'')/(`uci'-`effect')) ) if (`uci' > `DXmax`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')
			replace `DIAMrightY1' = . if (`effect' > `DXmax`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')

			replace `DIAMrightY2' = `id' - 0.4*( abs((`uci'-`DXmax`r'')/(`uci'-`effect')) ) if (`uci' > `DXmax`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')
			replace `DIAMrightY2' = . if (`effect' > `DXmax`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')

			replace `DIAMbottomY' = `id' - 0.4*( abs((`uci'-`DXmin`r'')/(`uci'-`effect')) ) if (`effect' < `DXmin`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')
			replace `DIAMbottomY' = `id' - 0.4*( abs((`DXmax`r''-`lci')/(`effect'-`lci')) ) if (`effect' > `DXmax`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')

			replace `DIAMtopY' = `id' + 0.4*( abs((`uci'-`DXmin`r'')/(`uci'-`effect')) ) if (`effect' < `DXmin`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')
			replace `DIAMtopY' = `id' + 0.4*( abs((`DXmax`r''-`lci')/(`effect'-`lci')) ) if (`effect' > `DXmax`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')

			replace `DIAMtopX' = `DXmin`r'' if (`effect' < `DXmin`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')
			replace `DIAMtopX' = `DXmax`r'' if (`effect' > `DXmax`r'') & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')
			replace `DIAMtopX' = . if ((`uci' < `DXmin`r'') | (`lci' > `DXmax`r'')) & (`use' == 2 | `use' == 3) & (`se' == `=2 -`r'')
		} 
		
		gen `DIAMbottomX' = `DIAMtopX'

	} // END QUI

	forvalues i = 1/`lcolsN'{
		local lcolCommands`i' "(scatter `id' `left`i'', msymbol(none) mlabel(`leftLB`i'') mlabcolor(black) mlabpos(3) mlabsize(`texts'))"
	}

	forvalues i = 1/`rcolsN' {
		local rcolCommands`i' "(scatter `id' `right`i'', msymbol(none) mlabel(`rightLB`i'') mlabcolor(black) mlabpos(3) mlabsize(`texts'))"
	}
	
	if `"`diamopt'"' == "" {
		local diamopt "lcolor("0 0 100")"
	}
	else {
		if strpos(`"`diamopt'"',"hor") != 0 | strpos(`"`diamopt'"',"vert") != 0 {
			di as error "Options horizontal/vertical not allowed in diamopt()"
			exit
		}
		if strpos(`"`diamopt'"',"con") != 0{
			di as error "Option connect() not allowed in diamopt()"
			exit
		}
		if strpos(`"`diamopt'"',"lp") != 0{
			di as error "Option lpattern() not allowed in diamopt()"
			exit
		}
		local diamopt `"`diamopt'"'
	}
	//Point options
	if `"`pointopt'"' != "" & strpos(`"`pointopt'"',"msymbol") == 0{
		local pointopt = `"`pointopt' msymbol(O)"' 
	}
	if `"`pointopt'"' != "" & strpos(`"`pointopt'"',"msize") == 0{
		local pointopt = `"`pointopt' msize(vsmall)"' 
	}
	if `"`pointopt'"' != "" & strpos(`"`pointopt'"',"mcolor") == 0{
		local pointopt = `"`pointopt' mcolor(black)"' 
	}
	if `"`pointopt'"' == ""{
		local pointopt "msymbol(O) msize(vsmall) mcolor("0 0 0")"
	}
	else{
		local pointopt `"`pointopt'"'
	}
	// CI options
	if `"`ciopt'"' == "" {
		local ciopt "lcolor("0 0 0")"
	}
	else {
		if strpos(`"`ciopt'"',"hor") != 0 | strpos(`"`ciopt'"',"vert") != 0{
			di as error "Options horizontal/vertical not allowed in ciopt()"
			exit
		}
		if strpos(`"`ciopt'"',"con") != 0{
			di as error "Option connect() not allowed in ciopt()"
			exit
		}
		if strpos(`"`ciopt'"',"lp") != 0{
			di as error "Option lpattern() not allowed in ciopt()"
			exit
		}
		if `"`ciopt'"' != "" & strpos(`"`ciopt'"',"lcolor") == 0{
			local ciopt = `"`ciopt' lcolor("0 0 0")"' 
		}
		local ciopt `"`ciopt'"'
	}
	// Arrow options
	if `"`arrowopt'"' == "" {
		local arrowopt "mcolor("0 0 0") lstyle(none)"
	}
	else {
		local forbidden "connect horizontal vertical lpattern lwidth lcolor lsytle"
		foreach option of local forbidden {
			if strpos(`"`arrowopt'"',"`option'")  != 0 {
				di as error "Option `option'() not allowed in arrowopt()"
				exit
			}
		}
		if `"`arrowopt'"' != "" & strpos(`"`arrowopt'"',"mcolor") == 0{
			local arrowopt = `"`arrowopt' mcolor("0 0 0")"' 
		}
		local arrowopt `"`arrowopt' lstyle(none)"'
	}

	// END GRAPH OPTS

	tempvar tempOv overrallLine ovMin ovMax h0Line
	
	if `"`olineopt'"' == "" {
		local olineopt "lwidth(thin) lcolor(maroon) lpattern(shortdash)"
	}
	qui summ `id'
	local DYmin = r(min)
	local DYmax = r(max)+2
	
	forvalues r= 1(1)2 {
		qui summ `effect' if `use' == 3 & `se' == `=2 - `r''
		local overall`r' = r(max)
		local overallCommand`r' `" (pci `=`DYmax'-2' `overall`r'' `borderline' `overall`r'', `olineopt') "'
		
		if `overall`r'' > `DXmax`r'' | `overall`r'' < `DXmin`r'' | "`ovline'" != "" {	// ditch if not on graph
			local overallCommand`r' ""
		}
		if "`ovline'" != "" {
			local overallCommand`r' ""
		}
		if "`subline'" != "" & "`groupvar'" != "" {
			local sublineCommand`r' ""
			
			qui label list `groupvar'
			local nlevels = r(max)
			forvalues l = 1/`nlevels' {
				summ `effect' if `use' == 2  & `groupvar' == `l' & (`se' == `=`r' - 1')
				local tempSub`l' = r(mean)
				qui summ `id' if `use' == 1 & `groupvar' == `l'
				local subMax`l' = r(max) + 1
				local subMin`l' = r(min) - 2
				qui count if `use' == 1 & `groupvar' == `l' & (`se' == `=`r' - 1')
				if r(N) > 1 {
					local sublineCommand`r' `" `sublineCommand`r'' (pci `subMin`l'' `tempSub`l'' `subMax`l'' `tempSub`l'', `olineopt')"'
				}
			}
		}
		else {
			local sublineCommand`r' ""
		}
	}

	qui {
		//Generate indicator on direction of the off-scale arro
		tempvar rightarrow leftarrow biarrow noarrow rightlimit leftlimit offRhiY offRhiX offRloY offRloX offLloY offLloX offLhiY offLhiX
		gen `rightarrow' = 0
		gen `leftarrow' = 0
		gen `biarrow' = 0
		gen `noarrow' = 0
		forvalues r= 1(1)2 {
			replace `rightarrow' = 1 if ///
				(round(`uci', 0.001) > round(`DXmax`r'', 0.001)) & ///
				(round(`lci', 0.001) >= round(`DXmin`r'', 0.001))  & ///
				(`use' == 1) & (`se' == `=2 -`r'') & ///
				(`uci' != .) & (`lci' != .)
				
			replace `leftarrow' = 1 if ///
				(round(`lci', 0.001) < round(`DXmin`r'', 0.001)) & ///
				(round(`uci', 0.001) <= round(`DXmax`r'', 0.001)) & ///
				(`use' == 1) & (`se' == `=2 -`r'') & ///
				(`uci' != .) & (`lci' != .)
			
			replace `biarrow' = 1 if ///
				(round(`lci', 0.001) < round(`DXmin`r'', 0.001)) & ///
				(round(`uci', 0.001) > round(`DXmax`r'', 0.001)) & ///
				(`use' == 1) & (`se' == `=2 -`r'') & ///
				(`uci' != .) & (`lci' != .)
				
			replace `noarrow' = 1 if ///
				(`leftarrow' != 1) & (`rightarrow' != 1) & (`biarrow' != 1) & ///
				(`use' == 1) & (`se' == `=2 -`r'') & ///
				(`uci' != .) & (`lci' != .)	

		}
		
		forvalues r= 1/2 {
			replace `lci' = `DXmin`r'' if (round(`lci', 0.001) < round(`DXmin`r'', 0.001)) & (`use' == 1) & (`se' == `=2 -`r'')
			replace `uci' = `DXmax`r'' if (round(`uci', 0.001) > round(`DXmax`r'', 0.001)) & (`uci' !=.) & (`use' == 1) & (`se' == `=2 -`r'')
			
			replace `lci' = . if (round(`uci', 0.001) < round(`DXmin`r'', 0.001)) & (`uci' !=. ) & (`use' == 1) & (`se' == `=2 -`r'')
			replace `uci' = . if (round(`lci', 0.001) > round(`DXmax`r'', 0.001)) & (`lci' !=. ) & (`use' == 1) & (`se' == `=2 -`r'')
			replace `effect' = . if (round(`effect', 0.001) < round(`DXmin`r'', 0.001)) & (`use' == 1) & (`se' == `=2 -`r'')
			replace `effect' = . if (round(`effect', 0.001) > round(`DXmax`r'', 0.001)) & (`use' == 1) & (`se' == `=2 -`r'')
		}		

		summ `id'
		local xaxislineposition = r(max)

		local xaxis1 "(pci `xaxislineposition' `DXmin1' `xaxislineposition' `DXmax1', lwidth(thin) lcolor(black))"
		local xaxis2 "(pci `xaxislineposition' `DXmin2' `xaxislineposition' `DXmax2', lwidth(thin) lcolor(black))"
		
		/*Xaxis 1 title */
		local xaxistitlex1 `=(`DXmax1' + `DXmin1')*0.5'
		local xaxistitlex2 `=(`DXmax2' + `DXmin2')*0.5'
		local xaxistitle1  (scatteri `=`xaxislineposition' + 2.25' `xaxistitlex1' "`plotstatse' (`level'% CI)", msymbol(i) mlabcolor(black) mlabpos(0) mlabsize(`texts'))
		local xaxistitle2  (scatteri `=`xaxislineposition' + 2.25' `xaxistitlex2' "`plotstatsp' (`level'% CI)", msymbol(i) mlabcolor(black) mlabpos(0) mlabsize(`texts'))
		
		/*xticks*/
		local ticksx1
		local ticksx2
		tokenize "`xtick'", parse(",")	
		while "`1'" != "" {
			if "`1'" != "," {
				forvalues r=1(1)2 {
					local where = `1'
					if `r' == 2 {          
						local where = `1' + `DXmax1' - `DXmin1' + 0.5*`rightWDtot'*`textWD'
					}
					local ticksx`r' "`ticksx`r'' (pci `xaxislineposition'  `where' 	`=`xaxislineposition'+.25' 	`where' , lwidth(thin) lcolor(black)) "
				}
			}
			macro shift 
		}
		/*labels*/
		local xaxislabels
		tokenize `lblcmd'
		while "`1'" != ""{
			forvalues r = 1(1)2 {
				local where = `1'
				if `r' == 2 {
					local where = `1' + `DXmax1' - `DXmin1' + 0.5*`rightWDtot'*`textWD' 
				}
				local xaxislabels`r' "`xaxislabels`r'' (scatteri `=`xaxislineposition'+1' `where' "`2'", msymbol(i) mlabcolor(black) mlabpos(0) mlabsize(`texts'))"
			}
			macro shift 2
		}
	}	// end qui	
	/*===============================================================================================*/
	/*====================================  GRAPH    ================================================*/
	/*===============================================================================================*/
	#delimit ;

	twoway
	 /*NOTE FOR RF, AND OVERALL LINES FIRST */ 
		`notecmd' `overallCommand1' `sublineCommand1' `overallCommand2' `sublineCommand2' `hetGroupCmd'  `xaxis1' `xaxistitle1' 
		`ticksx1' `xaxislabels1'  `xaxis2' `xaxistitle2'  `ticksx2' `xaxislabels2'
	 /*COLUMN VARIABLES */
		`lcolCommands1' `lcolCommands2' `lcolCommands3' `lcolCommands4' `lcolCommands5' `lcolCommands6'
		`lcolCommands7' `lcolCommands8' `lcolCommands9' `lcolCommands10' `lcolCommands11' `lcolCommands12'
		`rcolCommands1' `rcolCommands2' 
	 /*PLOT EMPTY POINTS AND PUT ALL THE GRAPH OPTIONS IN THERE */ 
		(scatter `id' `effect' if `use' == 1, 
			msymbol(none)		
			yscale(range(`DYmin' `DYmax') noline reverse)
			ylabel(none) ytitle("")
			xscale(range(`AXmin' `AXmax') noline)
			xlabel(none)
			yline(`borderline', lwidth(thin) lcolor(gs12))
			xtitle("") legend(off) xtick(""))		
	 /*HERE ARE THE CONFIDENCE INTERVALS */
		(pcspike `id' `lci' `id' `uci' if `use' == 1 , `ciopt')	
	 /*ADD ARROWS  `ICICmd1' `ICICmd2' `ICICmd3'*/
		(pcarrow `id' `uci' `id' `lci' if `leftarrow' == 1 , `arrowopt')	
		(pcarrow `id' `lci' `id' `uci' if `rightarrow' == 1 , `arrowopt')	
		(pcbarrow `id' `lci' `id' `uci' if `biarrow' == 1 , `arrowopt')	
	 /*DIAMONDS FOR SUMMARY ESTIMATES -START FROM 9 O'CLOCK */
		(pcspike `DIAMleftY1' `DIAMleftX' `DIAMtopY' `DIAMtopX' if (`use' == 2 | `use' == 3) , `diamopt')
		(pcspike `DIAMtopY' `DIAMtopX' `DIAMrightY1' `DIAMrightX' if (`use' == 2 | `use' == 3) , `diamopt')
		(pcspike `DIAMrightY2' `DIAMrightX' `DIAMbottomY' `DIAMbottomX' if (`use' == 2 | `use' == 3) , `diamopt')
		(pcspike `DIAMbottomY' `DIAMbottomX' `DIAMleftY2' `DIAMleftX' if (`use' == 2 | `use' == 3) , `diamopt') 
	 /*LAST OF ALL PLOT EFFECT MARKERS TO CLARIFY  */
		(scatter `id' `effect' if `use' == 1 , `pointopt')		
		,`foptions' name(fplot, replace)
		;
		#delimit cr		
			
		if "$by_index_" != "" {
			qui graph dir
			local gnames = r(list)
			local gname: word 1 of `gnames'
			tokenize `gname', parse(".")
			local gname `1'
			if "`3'" != "" {
				local ext =".`3'"
			}
			
			qui graph rename `gname'`ext' `gname'$by_index_`ext', replace
		}

end

/*==================================== GETWIDTH  ================================================*/
/*===============================================================================================*/
capture program drop getWidth
program define getWidth
version 14.0
//From metaprop

qui{

	gen `2' = 0
	count
	local N = r(N)
	forvalues i = 1/`N'{
		local this = `1'[`i']
		local width: _length "`this'"
		replace `2' =  `width' +1 in `i'
	}
} 

end
/*+++++++++++++++++++	SUPPORTING FUNCTIONS: SROC ++++++++++++++++++++++++++++++++++++
				   DRAW THE SROC CURVES, CROSSES, CONFIDENCE & PREDICTION REGION
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop sroc
	program define sroc
		version 14.0

		#delimit ;
		syntax varlist,	
			selogodds(name) /*Log odds for se*/
			splogodds(name) /*Log odds for sp*/
			v(name) /*Var-cov for log odds se & se*/
			bvar(name) /*Between study var-cov*/
			model(string) /*model*/
			[
			groupvar(name) /*Grouping variable*/
			p(integer 0) /*No of parameters in the regression equation*/
			cimethod(string) /*How to compute the study-specific CI*/
			LEVel(integer 95) /*Significance level*/
			
			COLorpalette(string) /*soptions: Colors seperated by space*/
			noPREDiction  /*soptions:no Prediction region*/
			Bubbles /*soptions: size of study by bubbles*/
			BUBbleid /*soptions: Identify the bubbles by index*/
			SPointopt(string) /*soptions: options study points*/
			OPointopt(string) /*soptions: options the overall summary points*/
			CUrveopt(string) /*soptions: options the CI points*/
			CIopt(string) /*soptions: options the CI points*/
			PREDCIopt(string) /*soptions: options the PREDCI points*/
			BUBOpt(string) /*soptions: options the bubble points*/
			BIDopt(string) /*soptions: options the bubble ID points*/
			* /*soptions:Other two-way options*/
			]
			;
		#delimit cr
		tempvar se selci seuci sp splci spuci csp Ni rowid Dis tp NDis tn mu gvar
		
		local soptions `"`options'"'
		
		tokenize `varlist'
		gen `tp' = `1'
		gen `Dis' = (`1' + `4')
		gen `tn' = `2'
		gen `NDis' = (`2' + `3')		
		gen `Ni' = `Dis' +`NDis'
		gen `rowid' = _n
		
		if "`groupvar'" != "" {
			my_ncod `gvar', oldvar(`groupvar') //
		}
		//CI
		metadta_propci `Dis' `tp', p(`se') lowerci(`selci') upperci(`seuci') cimethod(`cimethod') level(`level')
		metadta_propci `NDis' `tn', p(`sp') lowerci(`splci') upperci(`spuci') cimethod(`cimethod') level(`level')
		
		gen `csp' = 1 - `sp'				
		
		/*If categorical variable, obtain the sroc and the drawing parameters for each level*/
		if "`groupvar'" != "" {
			qui label list `gvar'
			local nlevels = r(max)
		}
		else {
			gen `gvar' = 1
			local nlevels = 1
		}
		if "`colorpalette'" == "" {
			local colorpalette  "black forest_green cranberry blue sienna orange emerald magenta dknavy gray purple"
		}
		else {
			local kcolors : word count `colorpalette'
			if (`kcolors' < `nlevels') {
				di as error "Please specify the colours to be used for all the `nlevels' levels of `gvar'" 
				di as error "colours should be separated by space in the colorpalette() option"
				exit
			}
		}
		local index 0
		local centre
		local kross
		local sroc
		local points
		local rings
		local idbubble
		local cregion
		local pregion
		local legendlabel
		local legendorder
		/*Options*/
		// CI options
		if `"`ciopt'"' != "" {
			local forbidden "lcolor"
			foreach option of local forbidden {
				if strpos(`"`ciopt'"',"`option'")  != 0 {
					di as error "Option `option'() not allowed in ciopt()"
					exit
				}
			}
		}
		
		// PREDCI options
		if `"`predciopt'"' == "" {
			local predciopt "lpattern(dash)"
		}
		else {
			local forbidden "lcolor"
			foreach option of local forbidden {
				if strpos(`"`predciopt'"',"`option'")  != 0 {
					di as error "Option `option'() not allowed in predciopt()"
					exit
				}
			}
			if `"`predciopt'"' != "" & strpos(`"`predciopt'"',"lpattern") == 0{
				local predciopt = `"`predciopt' lpattern(dash)"' 
			}
		}
		
		// Overall Point options
		if `"`opointopt'"' == "" {
			local opointopt "msymbol(D)"
		}
		else {
			local forbidden "mcolor"
			foreach option of local forbidden {
				if strpos(`"`opointopt'"',"`option'")  != 0 {
					di as error "Option `option'() not allowed in opointopt()"
					exit
				}
			}
			if `"`opointopt'"' != "" & strpos(`"`opointopt'"',"msymbol") == 0{
				local opointopt = `"`opointopt' msymbol(D)"' 
			}
		}
		
		// Study point options
		if `"`spointopt'"' == "" {
			local spointopt "msymbol(o)"
		}
		else {
			local forbidden "mcolor"
			foreach option of local forbidden {
				if strpos(`"`spointopt'"',"`option'")  != 0 {
					di as error "Option `option'() not allowed in spointopt()"
					exit
				}
			}
			if `"`spointopt'"' != "" & strpos(`"`spointopt'"',"msymbol") == 0{
				local spointopt = `"`spointopt' msymbol(o)"' 
			}
		}
		
		// Curve options
		if `"`curveopt'"' != "" {
			local forbidden "lcolor"
			foreach option of local forbidden {
				if strpos(`"`curveopt'"',"`option'")  != 0 {
					di as error "Option `option'() not allowed in curveopt()"
					exit
				}
			}
		}
		
		// Bubble options
		if `"`bubopt'"' == "" {
			local bubopt "msymbol(Oh)"
		}
		else {
			local forbidden "mcolor"
			foreach option of local forbidden {
				if strpos(`"`bubopt'"',"`option'")  != 0 {
					di as error "Option `option'() not allowed in bubopt()"
					exit
				}
			}
			if `"`bubopt'"' != "" & strpos(`"`bubopt'"',"msymbol") == 0{
				local bubopt = `"`bubopt' msymbol(Oh)"' 
			}
		}
		
		//Bubble ID options
		if `"`bidopt'"' == "" {
			local bidopt "mlabsize(`texts') msymbol(i) mlabel(`rowid')"
		}
		else {
			local forbidden "mcolor mlabcolor "
			foreach option of local forbidden {
				if strpos(`"`bidopt'"',"`option'")  != 0 {
					di as error "Option `option'() not allowed in bidopt()"
					exit
				}
			}
			if `"`bidopt'"' != "" & strpos(`"`bidopt'"',"mlabsize") == 0{
				local bidopt = `"`bidopt' mlabsize(`texts')"' 
			}
			if `"`bidopt'"' != "" & strpos(`"`bidopt'"',"msymbol") == 0{
				local bidopt = `"`bidopt' msymbol(i)"' 
			}
			if `"`bidopt'"' != "" & strpos(`"`bidopt'"',"mlabel") == 0{
				local bidopt = `"`bidopt' mlabel(`rowid')"' 
			}
		}
	
		qui {
			local already 0
			if `p' > 1 {
					local nrows = rowsof(`splogodds')
					local ovindex = rowsof(`v')
				}
			forvalues j=1/`nlevels' {
				local color:word `j' of `colorpalette'
				qui count if `gvar' == `j'
				//Centre
				if r(N) > 1 {
					if `p' > 1 {
						local mux`j' = 1 - invlogit(`splogodds'[`nrows', 1])
						local muy`j' = invlogit(`selogodds'[`nrows', 1])
					}
					else{
						local mux`j' = 1 - invlogit(`splogodds'[`j', 1])
						local muy`j' = invlogit(`selogodds'[`j', 1])
					}
				}
				else {						
					qui summ `sp' if `gvar' == `j'
					local mux`j' = 1 - r(mean)
					
					qui summ `se' if `gvar' == `j'
					local muy`j' = r(mean)
				}
				local centre `"`centre' (scatteri `muy`j'' `mux`j'', mcolor(`color') `opointopt')"'
				if `nlevels' == 1 {
					local ++index
					local legendlabel `"lab(`index' "Summary") `legendlabel'"'
					local legendorder `"`index'  `legendorder'"'				
				}
				//Crosses
				if "`model'" == "fixed" | (r(N) < 3 & "`model'" == "random" ){ 
					if r(N) > 1 {
						if `p' > 1 {
							local leftX`j' = 1 - invlogit(`splogodds'[`nrows', 6])
							local leftY`j' = invlogit(`selogodds'[`nrows', 1])
							local rightX`j' = 1 - invlogit(`splogodds'[`nrows', 5])
							local rightY`j' = invlogit(`selogodds'[`nrows', 1])
							local topX`j' = 1 - invlogit(`splogodds'[`nrows', 1])
							local topY`j' = invlogit(`selogodds'[`nrows', 6])
							local bottomX`j' = 1 - invlogit(`splogodds'[`nrows', 1])
							local bottomY`j' = invlogit(`selogodds'[`nrows', 5])
						}
						else{
							local leftX`j' = 1 - invlogit(`splogodds'[`j', 6])
							local leftY`j' = invlogit(`selogodds'[`j', 1])
							local rightX`j' = 1 - invlogit(`splogodds'[`j', 5])
							local rightY`j' = invlogit(`selogodds'[`j', 1])
							local topX`j' = 1 - invlogit(`splogodds'[`j', 1])
							local topY`j' = invlogit(`selogodds'[`j', 6])
							local bottomX`j' = 1 - invlogit(`splogodds'[`j', 1])
							local bottomY`j' = invlogit(`selogodds'[`j', 5])
						}
					}
					else {						
						qui summ `splci' if `gvar' == `j'
						local leftX`j' = 1 - r(mean)
						
						qui summ `spuci' if `gvar' == `j'
						local rightX`j' = 1 - r(mean)
						
						local leftY`j' = `mux`j''
						local rightY`j' = `mux`j''
						
						local topX`j' = `muy`j''
						local bottomX`j' = `muy`j''
						
						qui summ `selci' if `gvar' == `j'
						local topY`j' =  r(mean)
						
						qui summ `seuci' if `gvar' == `j'
						local bottomY`j' =  r(mean)
					}
					local kross `"`kross' (pci `leftY`j'' `leftX`j'' `rightY`j'' `rightX`j'', lcolor(`color') `ciopt') (pci `topY`j'' `topX`j'' `bottomY`j'' `bottomX`j'', lcolor(`color') `ciopt') "'
					if `nlevels' == 1 {
						local ++index
						local legendlabel `"lab(`index' "Confidence intervals") `legendlabel'"'
						local legendorder `"`index'  `legendorder'"'
						local ++index						
					}
				}
				else {
				//Confidence & prediction ellipses
					if !`already' {
						qui set obs 500
						local already 1
					}
					qui summ `csp' if `gvar' == `j' 
					local max`j' = min(0.9999, r(min))
					local min`j' = max(0.0001, r(max))
					local N`j' = r(N)
					
					tempvar fpr`j' sp`j' se`j' xcregion`j' ycregion`j' xpregion`j' ypregion`j'
					
					range `fpr`j'' `min`j'' `max`j''
					gen `sp`j'' = 1 - `fpr`j''
					
					/*HsROC parameters*/
					local b = (sqrt(`bvar'[2,2])/sqrt(`bvar'[1,1]))^0.5
					local beta = ln(sqrt(`bvar'[2,2]) / sqrt(`bvar'[1,1]))
					
					if `p' > 1 {
						local lambda = `b' * `selogodds'[`nrows', 1] + `splogodds'[`nrows', 1] / `b'
						local theta = 0.5 * (`b' * `selogodds'[`nrows', 1] -  `splogodds'[`nrows', 1]  /`b')

					}
					else {
						local lambda = `b' * `selogodds'[`j', 1] + `splogodds'[`j', 1] / `b'
						local theta = 0.5 * (`b' * `selogodds'[`j', 1] -  `splogodds'[`j', 1]  /`b')
					}
					
					local var_accu =  2*( sqrt(`bvar'[2,2]*`bvar'[1,1]) + `bvar'[2,1]) 
					local var_thresh = 0.5*( sqrt(`bvar'[2,2]*`bvar'[1,1]) - `bvar'[2,1]) 

					/*The y axis*/
					gen `se`j'' = invlogit(`lambda' * exp(-`beta' / 2) + exp(-`beta') * logit(`fpr`j''))
					local sroc "`sroc' (line `se`j'' `fpr`j'', lcolor(`color') `curveopt')"
					if `nlevels' == 1 {
						local ++index
						local legendlabel `"lab(`index' "SROC") `legendlabel'"'
						local legendorder `"`index'  `legendorder'"'					
					}
					
					/*Joint confidence region*/
					local t = sqrt(2*invF(2, `=`N`j'' - 2', `level'/100))
					local nlen = 500
					if `p' > 1 {
						local rho = `v'[`=2*`nrows'-1', `=2*`nrows'']/sqrt(`v'[`=`ovindex'-1', `=`ovindex'-1']*`v'[`=2*`nrows'', `=2*`nrows''])
					}
					else {
						local rho = `v'[`j', `=`nlevels' + `j'']/sqrt(`v'[`j', `j']*`v'[`=`nlevels' + `j'', `=`nlevels' + `j''])
					}
					
					tempvar a 
					range `a' 0 2*_pi `nlen'
					if `p' > 1 {
						gen `xcregion`j'' = 1 - invlogit(`splogodds'[`nrows', 1] + sqrt(`v'[`=`ovindex'-1', `=`ovindex'-1']) * `t' * cos(`a' + acos(`rho')))
						gen `ycregion`j'' = invlogit(`selogodds'[`nrows', 1] +  sqrt(`v'[`ovindex', `ovindex']) * `t' * cos(`a'))
					}
					else {
						gen `xcregion`j'' = 1 - invlogit(`splogodds'[`j', 1] + sqrt(`v'[`j', `j']) * `t' * cos(`a' + acos(`rho')))
						gen `ycregion`j'' = invlogit(`selogodds'[`j', 1] +  sqrt(`v'[`=`nlevels' + `j'', `=`nlevels' + `j'']) * `t' * cos(`a'))
					}

					local cregion `"`cregion' (line `ycregion`j'' `xcregion`j'', lcolor(`color') `ciopt')"'
					if `nlevels' == 1 {
						local ++index
						local legendlabel `"lab(`index' "Confidence region") `legendlabel'"'
						local legendorder `"`index'  `legendorder'"'					
					}
					
					/*Joint prediction region*/
					if "`prediction'" == "" {
						if `p' > 1 {
							local rho =  (`v'[`=`ovindex'-1', `ovindex'] + `bvar'[1,2])/ sqrt((`v'[`=`ovindex'-1', `=`ovindex'-1'] + `bvar'[2, 2]) * (`v'[`ovindex', `ovindex'] + `bvar'[1, 1]))
						}
						else {
							local rho =  (`v'[`=`nlevels' + `j'', `j'] + `bvar'[1,2])/ sqrt((`v'[`j', `j'] + `bvar'[2, 2]) * (`v'[`=`nlevels' + `j'', `=`nlevels' + `j''] + `bvar'[1, 1]))
						}
						local d = acos(`rho')	
						if `p' > 1 {
							gen `xpregion`j'' = 1 - invlogit(`splogodds'[`nrows', 1] + `t' * sqrt(`v'[`=`ovindex'-1', `=`ovindex'-1'] + `bvar'[2, 2]) * cos(`a' + acos(`rho')))
							gen `ypregion`j'' = invlogit(`selogodds'[`nrows', 1] +  sqrt(`v'[`ovindex', `ovindex'] + `bvar'[1, 1]) * `t' * cos(`a'))
						}
						else {
							gen `xpregion`j'' = 1 - invlogit(`splogodds'[`j', 1] + `t' * sqrt(`v'[`j', `j'] + `bvar'[2, 2]) * cos(`a' + acos(`rho')))
							gen `ypregion`j'' = invlogit(`selogodds'[`j', 1] +  sqrt(`v'[`=`nlevels' + `j'', `=`nlevels' + `j''] + `bvar'[1, 1]) * `t' * cos(`a'))
						}
						local pregion `"`pregion' (line `ypregion`j'' `xpregion`j'', `predciopt' lcolor(`color'))"'
						if `nlevels' == 1 {
							local ++index
							local legendlabel `"lab(`index' "Prediction region") `legendlabel'"'
							local legendorder `"`index'  `legendorder'"'					
						}
					}
				}
				if "`summaryonly'" =="" {
					if "`bubbles'" != "" {
					//bubbles
						local rings `"`rings' (scatter `se' `csp' [fweight = `Ni'] if `gvar' == `j',   mcolor(`color') `bubopt')"'
						
						if "`bubbleid'" != "" {
							local idbubble `"`idbubble' (scatter `se' `csp' if `gvar' == `j',  mcolor(`color') mlabcolor(`color') `bidopt')"'
						}
					}
					else {
					//points
						local points `"`points' (scatter `se' `csp' if `gvar' == `j',  mcolor(`color') `spointopt')"'
					}
					if `nlevels' == 1 {
						local ++index
						local legendlabel `"lab(`index' "Observed data") `legendlabel'"'
						local legendorder `"`index'  `legendorder'"'					
					}
				}
				if `nlevels' > 1 {
					local lab:label `gvar' `j' /*label*/
					local legendlabel `"lab(`j' "`lab'") `legendlabel'"'
					local legendorder `"`j'  `legendorder'"'
				}
			}
		}
		
		if strpos(`"`soptions'"', "legend") == 0 {
			local legendstr `"legend(order(`legendorder') `legendlabel' position(6))"'
		}
		if strpos(`"`soptions'"', "xscale") == 0 {
			local soptions `"xscale(range(0 1)) `soptions'"'
		}
		if strpos(`"`soptions'"', "yscale") == 0 {
			local soptions `"yscale(range(0 1)) `soptions'"'
		}
		#delimit ;
		graph tw 
			`centre'
			`kross'
			`sroc'
			`cregion'
			`pregion'
			`points'
			`rings'
			`idbubble'
			,
			`legendstr' `soptions' name(sroc, replace)
		;
		#delimit cr
		if "$by_index_" != "" {
				qui graph dir
				local gnames = r(list)
				local gname: word 1 of `gnames'
				tokenize `gname', parse(".")
				local gname `1'
				if "`3'" != "" {
					local ext =".`3'"
				}
				
				qui graph rename `gname'`ext' `gname'_sroc$by_index_`ext', replace
		}
	end

