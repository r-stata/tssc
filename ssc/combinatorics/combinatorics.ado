*!Version 1.0  06jun2016 Claire Vandendriessche
*!Requires Stata version 11.0 or higher and ssc package tuples
*Questions, remarks: claire.vandendriessche@psemail.eu

program combinatorics
version 11.0
syntax varlist(min=2 numeric ts fv) [if] [in] [fweight aweight iweight/] [, Saving(string) Add(varlist numeric fv ts) ]

set more off

*Treat options:
local globalvarlist `varlist'
if !mi("`weight'") local weight "[`weight'=`exp']"
if !mi("`saving'") preserve

*Treat varlists:
fvunab globalvarlist: `globalvarlist'
local globalvarlist: list uniq local(globalvarlist)
tokenize `globalvarlist'
local depvar `1'
_fv_check_depvar `depvar'
local varset: list local(globalvarlist) - local(depvar)
local nvars: list sizeof local(varset)
local nmodels=2^`nvars'-1
fvexpand `varset'
local varsetXP `r(varlist)'

*Treat "ADD" option:
if !mi("`add'") {
	fvunab addvarlist: `add'
	local addvarlist: list uniq local(addvarlist)
	local addvarlist: list local(addvarlist) - local(globalvarlist)
	fvexpand `addvarlist'
	local addvarlist `r(varlist)'
	local varsetADD tokens("`addvarlist'"),
}

*Prevent conflict names:
local forbiddenwords timer i n rank r2 oosr2 oosn rmse pseudor2 _constant model
local conflict `varsetXP' `addvarlist' `forbiddenwords'
local conflict: list dups conflict
local size: list sizeof conflict
if `size'>0 {
	di as err "You have specified the following variables: `conflict'"
	di as err "Please rename them before executing this program again."
	di as err "The following variable names should always be avoided in this program: `forbiddenwords'"
	exit 101
}

*Prevent collinear models:
_rmcollright `varlist' `add' ,collinear
local dropped `r(dropped)'
local ndropped: list sizeof dropped
if `ndropped'>0 {
	di as err "The following variables are causing collinearity in some but not all models where they are estimated: `dropped'"
	di as err "When a variable is causing perfect multicollinearity, it should cause it for all estimated models, otherwise the program will bug."
	exit 101
}


*Initializes the future dataset X:
mata: varset=(`varsetADD'tokens("`varsetXP'"),"_constant")	//Gets the variable set (their names)
mata: Xnames=("timer","i","n","rank","r2","oosr2","oosn","rmse","pseudor2",strtoname(abbrev(varset,29)),strtoname(abbrev(varset,29):+"_se"))	//Prepares the future dataset's variable names
mata: X=J(`nmodels'+1,cols(Xnames),.)				//Prepares the future dataset
mata if (stataversion()>=1300) {
	models=J(`nmodels'+1,1,"")
	};			//Prepares the future dataset's string variable for the model's cmdline (only available for Stata 13 and higher)
mata: timer_clear(1)						//Prepares the timer

*Generate all possible models:	
cap tuples `varset'
if _rc==199 {
	ssc install tuples
	tuples `varset'
}
local tuple0

*Estimate each model:
tempvar insample hat lev
forvalues i=0/`nmodels' {
	mata: timer_on(1)
	fvexpand `tuple`i''				//Expands the model's variables by dummifying its categorical variables
	local tuple `r(varlist)'
	
	*Regression:
	qui reg `depvar' `addvarlist' `tuple' `if' `in' `weight'
	qui gen byte `insample'=e(sample)
	mata: n=st_numscalar("e(N)")
	mata: r2=st_numscalar("e(r2)")
	mata: rank=st_numscalar("e(rank)")
	mata: b=st_matrix("e(b)")					//Get the coefficients-vector
	mata: se=sqrt(diagonal(st_matrix("e(V)")))'			//Get the standard-error vector
	mata: model=(`varsetADD'tokens("`tuple'"),"_constant")			//Gets the variable subset used in this model (their names)
	mata: modeldum=J(1,cols(varset),.)				//modeldum serves to identify which of all variables are estimated in this model
	mata: for (i=1; i<=cols(varset); i++)  modeldum[i]=anyof(model,varset[i])
	mata if (rowsum(modeldum)!=cols(b)) {
		_error(3000,"Syntax problem, possibly due to the presence of collinear explanatory variables.")
	};
	mata: designmatrix=designmatrix(select(range(1,cols(modeldum),1),modeldum'))	//designmatrix serves to transform the vectors of coefficients (and SE) into a vector of greater size giving "." to the unestimated coefficients (or SE) of the rest of the variable set
	mata: notmodel=select(range(1,cols(modeldum),1)',modeldum:==0)
	mata: designmatrix=(designmatrix,J(cols(b),cols(modeldum)-cols(designmatrix),0))
	mata: designmatrix[.,notmodel]=J(rows(designmatrix),cols(notmodel),.)
	mata: bset=b*designmatrix					//bset is the greater vector of coefficients
	mata: seset=se*designmatrix					//seset is the greater vector of standard errors
	
	*OOSS PseudoR²:
	qui predict `hat',xb
	cap corr `depvar' `hat' if !`insample'
	if _rc==2000  {
		mata: oossr2=.
		mata: oossn=.
	}
	else {
		mata: oossr2=st_numscalar("r(rho)")^2
		mata: oossn=st_numscalar("r(N)")
	}
	
	*Cross-validation
	qui predict `lev' if `insample',leverage
	mata: depvar=.
	mata: st_view(depvar,.,"`depvar'")
	mata: fitted=.
	mata: st_view(fitted,.,"`hat'")
	mata: sample=.
	mata: st_view(sample,.,"`insample'")
	mata: lev=.
	mata: st_view(lev,.,"`lev'")
	mata: y=.
	mata: st_select(y,depvar,sample)
	mata: yhat=.
	mata: st_select(yhat,fitted,sample)
	mata: l=.
	mata: st_select(l,lev,sample)
	mata: mse=mean(((y:-yhat):/(1:-l)):^2)
	mata: mst=mean((y:-mean(y)):^2)
	mata: pseudor2=1-mse/mst
	mata: rmse=sqrt(mse)

	*Input results from regression and cross-validation into future dataset X
	drop `insample' `hat' `lev'
	mata: timer_off(1)
	mata: timeleft=timer_value(1)[1]*(`nmodels'+1-timer_value(1)[2])/(timer_value(1)[2])
	mata: st_numscalar("hoursleft",floor(timeleft/3600))
	mata: st_numscalar("minutesleft",floor(mod(timeleft/60,60)))
	mata: st_numscalar("secondsleft",floor(mod(timeleft,60)))
	mata: X[`i'+1,.]=(timer_value(1)[1],`i',n,rank,r2,oossr2,oossn,rmse,pseudor2,bset,seset)
	mata if (stataversion()>=1300) {
		models[`i'+1]="`addvarlist' `tuple'" 
	};
	di "Model run: # " `i' " ; still " `nmodels'-`i' " models to go (" hoursleft " hrs., " minutesleft " min., " secondsleft " sec. left)"
}
clear
quietly{
	mata: st_addvar("double",Xnames)
	mata: st_addobs(rows(X))
	mata: st_store(.,.,X)
	mata if (stataversion()>=1300) {
		st_addvar("strL","model")
		st_sstore(.,cols(X)+1,models)
	};
}

*Save file
local 0 `"`saving'"'
syntax [ anything(name=saving) ] [, noREPLACE ]
if !mi("`saving'") {
	if "`replace'"=="" {
		save "`saving'" , replace
		restore
	}
	else save "`saving'"
}



end
