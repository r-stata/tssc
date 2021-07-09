*! Nikolas Mittag 04Mar2012

cap program drop conddens
program define conddens, eclass properties(b V svyb svyr svyj)
version 10.0
syntax varlist(min=1 numeric) [if] [in] [pweight fweight aweight iweight], [MVars(string)] [MODel(string)] [MASSpoint] [MODELOpts(string)] [MAXopts(string)] [Init(string)] [EQNames(string)] [LIKProg(string)] [PREDict(string)] [MPFunc(string)] [MIXPar(string)] [MIXFunc(string)] [MIXTransf(string)] [MIXLik(string)] [MIXArgs(string)] [WGTTrfunc(string)] [NRPar(string)] [NRFunc(string)] [NRTransf(string)] [NRLik(string)] [NRArgs(string)] [NRWGTTrfunc(string)] [Write] [CMPlot] [CMPOpts(string)]  [SEArch(string)] [MACrokeep]
gettoken true pred : varlist
gettoken obs pred : pred
tempname par v trf b c d pos predictors predictv mixparv nrparv ao vo g w

*get sample (need to do this manually b/c want to keep observations for which `obs' (only) is missing if NR is specified
marksample touse, novarlist
foreach var of varlist `true' `pred' {
	qui replace `touse'=0 if missing(`var')==1 & missing(`obs')==0
}
if "`mvars'"!="" & strmatch(lower("`mvars'"),"cons*")==0 {
	unab mvars: `mvars'
	foreach var of varlist `mvars' {
		qui replace `touse'=0 if missing(`var')==1 & missing(`obs')==1
	}
}
if "`mvars'"=="" & wordcount("`model'")<2 qui replace `touse'=0 if missing(`obs')==1

*stop program if masspoint or NR specified, but no such observations (likelihood runs crazy in such cases, b/c its flat)
else {
	qui: sum `true' if `obs'==. & `touse'==1, meanonly
	if `r(N)'==0 {
		di as error "Non-Response specified, but `obs' does not contain any missing values"
		exit
	}
}	

if "`masspoint'"!="" {
	qui: sum `true' if `true'==`obs' & `touse'==1, meanonly
	if `r(N)'==0 {
		di as error "Mass point specified, but no observations for which true and observed value are equal"
		exit
	}
}



*set up general stuff from input
global mixobs "`obs'"
if strmatch(lower("`maxopts'"),"*iter*")==0 local maxopts "`maxopts' iterate(250)"
if "`likprog'"=="" local likprog "condmix"
if "`mixpar'"!="" mat def `mixparv'=`mixpar'
if "`mixlik'"!="" global mixlik "`mixlik'"
if "`mixargs'"!="" global mixargs "`mixargs'"
if "`nrpar'"!="" mat def `nrparv'=`nrpar'
else mat def `nrparv'=0
if "`nrlik'"!="" global nrlik "`nrlik'"
else global nrlik=0
if "`nrargs'"=="" global nrargs "`nrargs'"

*set up defaults if no input->make sure this is called when needed and doesn't mess things up when not needed.
if "`model'"=="" & ("`mixpar'"=="" | "`predict'"=="") {
	local model "mixnorm"
	di as result "Warning: Relevant input is missing, mixture of normal model without masspoint and non-response assumed"
}


**set up "shortcuts" to standard cases
if "`likprog'"!="condmix" & "`model'"!="" {
	di as err "Option model() only allowed when likelihood function is provided by condmix"
	exit
}
if "`likprog'"=="condmix" {
*basic setup
if wordcount("`model'")==2 {
local nrmodel=lower(word("`model'",2))
local model=lower(word("`model'",1))
local model=subinstr("`model'",",","",.)
if "`mvars'"=="" {
di as res "Option mvars() not specified, using only constants in `nrmodel' for missing values"
local mvars "cons"
}
}
if "`eqnames'"=="" local defnm=1
*defalut model for nr if variables specified, but no model->prevent this from overriding manual specification?
if "`nrmodel'"=="" & "`mvars'"!="" & "`nrpar'"=="" local nrmodel "mixnorm"

*model definitions for measurement error
if (inlist("`model'","normal","mixnorm","exp","mixexp","weibull","mixweibull","t","mixt","mixweit")==1 | inlist("`model'","trnorm","ltrnorm","rtrnorm","mixtrnorm","mixltrnorm","mixrtrnorm")==1) {
if "`model'"=="normal" {
	global mixargs "xb1 sigma1"
	global mixlik "normalden(\$ML_y1,\`xb1',exp(\`sigma1'))"
	local mixfunc "&mrnormal()"
	local mixtransf "1,2,&mexp()"
	mat def `predictv'=(1,0)
	mat def `mixparv'=2
	if `defnm'==1 local eqnames "mean sigma"
	*choosing starting values (conditional mean only)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		if "`masspoint'"!="" qui: reg `true' `obs' `pred' if `touse'==1 & `true'!=`obs'
		else qui: reg `true' `obs' `pred' if `touse'
		mat def `b'=e(b)
		local names=word("`eqnames'",-2)
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'		
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}
if "`model'"=="trnorm" {
	global mixargs "xb1 sigma1 ltrunc1 rtrunc1"
	if "`masspoint'"!="" qui: sum `true' if `touse'==1 & `obs'!=. & `obs'!=`true'
	else qui: sum `true' if `touse'==1 & `obs'!=.
	local ltr=`r(min)'
	local rtr=`r(max)'
	global mixlik "normalden(\$ML_y1,\`xb1',abs(\`sigma1'))/(normal((`rtr'+abs(\`rtrunc1')-\`xb1')/abs(\`sigma1'))-normal((`ltr'-abs(\`ltrunc1')-\`xb1')/abs(\`sigma1')))"
	local mixfunc "&rtrnormal()"
	local mixtransf "1,2,&mabs(),1,3,&mneg(),1,3,`ltr',1,4,&mabs(),1,4,`rtr'"
	mat def `predictv'=(1,0,0,0)
	mat def `mixparv'=4
	if `defnm'==1 local eqnames "mean sigma left_trunc right_trunc"
	*choosing starting values (conditional mean only)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		local lname=word("`eqnames'",-2)
		if strmatch("`init'","*`lname'*")==0 local init "/`lname'=0 `init'"
		local rname=word("`eqnames'",-1)
		if strmatch("`init'","*`rname'*")==0 local init "/`rname'=0 `init'"
		if "`masspoint'"!="" qui: reg `true' `obs' `pred' if `touse'==1 & `true'!=`obs'
		else qui: reg `true' `obs' `pred' if `touse'
		mat def `b'=e(b)
		local names=word("`eqnames'",-4)
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'		
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}
if "`model'"=="ltrnorm" {
	global mixargs "xb1 sigma1 ltrunc1"
	if "`masspoint'"!="" qui: sum `true' if `touse'==1 & `obs'!=. & `obs'!=`true'
	else qui: sum `true' if `touse'==1 & `obs'!=.
	local ltr=`r(min)'
	global mixlik "normalden(\$ML_y1,\`xb1',abs(\`sigma1'))/(1-normal((`ltr'-abs(\`ltrunc1')-\`xb1')/abs(\`sigma1')))"
	local mixfunc "&rltrnormal()"
	local mixtransf "1,2,&mabs(),1,3,&mneg(),1,3,`ltr'"
	mat def `predictv'=(1,0,0)
	mat def `mixparv'=3
	if `defnm'==1 local eqnames "mean sigma left_trunc"
	*choosing starting values (conditional mean only)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		local lname=word("`eqnames'",-1)
		if strmatch("`init'","*`lname'*")==0 local init "/`lname'=0 `init'"
		if "`masspoint'"!="" qui: reg `true' `obs' `pred' if `touse'==1 & `true'!=`obs'
		else qui: reg `true' `obs' `pred' if `touse'
		mat def `b'=e(b)
		local names=word("`eqnames'",-3)
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'		
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}
if "`model'"=="rtrnorm" {
	global mixargs "xb1 sigma1 rtrunc1"
	if "`masspoint'"!="" qui: sum `true' if `touse'==1 & `obs'!=. & `obs'!=`true'
	else qui: sum `true' if `touse'==1 & `obs'!=.
	local rtr=`r(max)'
	global mixlik "normalden(\$ML_y1,\`xb1',abs(\`sigma1'))/(normal((`rtr'+abs(\`rtrunc1')-\`xb1')/abs(\`sigma1')))"
	local mixfunc "&rrtrnormal()"
	local mixtransf "1,2,&mabs(),1,3,&mabs(),1,3,`rtr'"
	mat def `predictv'=(1,0,0)
	mat def `mixparv'=3
	if `defnm'==1 local eqnames "mean sigma right_trunc"
	*choosing starting values (conditional mean only)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		local rname=word("`eqnames'",-1)
		if strmatch("`init'","*`rname'*")==0 local init "/`rname'=0 `init'"
		if "`masspoint'"!="" qui: reg `true' `obs' `pred' if `touse'==1 & `true'!=`obs'
		else qui: reg `true' `obs' `pred' if `touse'
		mat def `b'=e(b)
		local names=word("`eqnames'",-3)
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'		
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}
if "`model'"=="mixnorm" {
	global mixargs "xb1 sigma1 xb2 sigma2 w2"
	global mixlik "(1-invlogit(\`w2'))*normalden(\$ML_y1,\`xb1',exp(\`sigma1'))+invlogit(\`w2')*normalden(\$ML_y1,\`xb2',exp(\`sigma2'))"
	local mixfunc "&mrnormal()"
	local mixtransf "1,2,&mexp()"
	local wgttrfunc "&invlogit()"
	mat def `predictv'=(1,0,1,0,0)
	mat def `mixparv'=2
	if `defnm'==1 local eqnames "mean1 sigma1 mean2 sigma2 weight2"
	*choosing starting value (overall conditional expectation for conditional means of both components & weight=0.5)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		local wname=word("`eqnames'",wordcount("`eqnames'"))
		if strmatch("`init'","*`wname'*")==0 local init "/`wname'=0 `init'"
		if "`masspoint'"!="" qui: reg `true' `obs' `pred' if `touse'==1 & `true'!=`obs'
		else qui: reg `true' `obs' `pred' if `touse'
		mat def `b'=e(b)
		local names=word("`eqnames'",-3)
		local names2=word("`eqnames'",-5)
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'		
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			if strmatch("`init'","*`names2':``i''*")==0 local init `"`names2':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}
*doesn't work too well, imposes constraint that truncation is out of sample support for both components, one may want to relax that (particularly when constraining coefficients)
if "`model'"=="mixtrnorm" {
	global mixargs "xb1 sigma1 ltrunc1 rtrunc1 xb2 sigma2 ltrunc2 rtrunc2 w2"
	if "`masspoint'"!="" qui: sum `true' if `touse'==1 & `obs'!=. & `obs'!=`true'
	else qui: sum `true' if `touse'==1 & `obs'!=.
	local ltr=`r(min)'
	local rtr=`r(max)'
	global mixlik "(1-invlogit(\`w2'))*normalden(\$ML_y1,\`xb1',abs(\`sigma1'))/(normal((`rtr'+abs(\`rtrunc1')-\`xb1')/abs(\`sigma1'))-normal((`ltr'-abs(\`ltrunc1')-\`xb1')/abs(\`sigma1')))+invlogit(\`w2')*normalden(\$ML_y1,\`xb2',abs(\`sigma2'))/(normal((`rtr'+abs(\`rtrunc2')-\`xb2')/abs(\`sigma2'))-normal((`ltr'-abs(\`ltrunc2')-\`xb2')/abs(\`sigma2')))"
	local mixfunc "&rtrnormal()"
	local mixtransf "1,2,&mabs(),1,3,&mneg(),1,3,`ltr',1,4,&mabs(),1,4,`rtr'"
	local wgttrfunc "&invlogit()"
	mat def `predictv'=(1,0,0,0,1,0,0,0,0)
	mat def `mixparv'=4
	if `defnm'==1 local eqnames "mean1 sigma1 left_trunc1 right_trunc1 mean2 sigma2 left_trunc2 right_trunc2 weight2"
	*choosing starting value (overall conditional expectation for conditional means of both components & weight=0.5)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		local wname=word("`eqnames'",-1)
		if strmatch("`init'","*`wname'*")==0 local init "/`wname'=0 `init'"
		local lname=word("`eqnames'",-3)
		if strmatch("`init'","*`lname'*")==0 local init "/`lname'=-10 `init'"
		local rname=word("`eqnames'",-2)
		if strmatch("`init'","*`rname'*")==0 local init "/`rname'=-10 `init'"
		local lname=word("`eqnames'",-7)
		if strmatch("`init'","*`lname'*")==0 local init "/`lname'=-10 `init'"
		local rname=word("`eqnames'",-6)
		if strmatch("`init'","*`rname'*")==0 local init "/`rname'=-10 `init'"
		if "`masspoint'"!="" qui: reg `true' `obs' `pred' if `touse'==1 & `true'!=`obs'
		else qui: reg `true' `obs' `pred' if `touse'
		local names=word("`eqnames'",-4)
		if strmatch("`init'","*`names'*")==0 local init "/`names'=`e(rmse)' `init'"
		local names=word("`eqnames'",-8)
		if strmatch("`init'","*`names'*")==0 local init "/`names'=`e(rmse)' `init'"
		mat def `b'=e(b)
		local names=word("`eqnames'",-5)
		local names2=word("`eqnames'",-9)
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			if strmatch("`init'","*`names2':``i''*")==0 local init `"`names2':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}
if "`model'"=="mixltrnorm" {
	global mixargs "xb1 sigma1 ltrunc1 xb2 sigma2 ltrunc2 w2"
	if "`masspoint'"!="" qui: sum `true' if `touse'==1 & `obs'!=. & `obs'!=`true'
	else qui: sum `true' if `touse'==1 & `obs'!=.
	local ltr=`r(min)'
	global mixlik "(1-invlogit(\`w2'))*normalden(\$ML_y1,\`xb1',abs(\`sigma1'))/(1-normal((`ltr'-abs(\`ltrunc1')-\`xb1')/abs(\`sigma1')))+invlogit(\`w2')*normalden(\$ML_y1,\`xb2',abs(\`sigma2'))/(1-normal((`ltr'-abs(\`ltrunc2')-\`xb2')/abs(\`sigma2')))"
	local mixfunc "&rltrnormal()"
	local mixtransf "1,2,&mabs(),1,3,&mneg(),1,3,`ltr'"
	local wgttrfunc "&invlogit()"
	mat def `predictv'=(1,0,0,1,0,0,0)
	mat def `mixparv'=3
	if `defnm'==1 local eqnames "mean1 sigma1 left_trunc1 mean2 sigma2 left_trunc2 weight2"
	*choosing starting value (overall conditional expectation for conditional means of both components & weight=0.5)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		local wname=word("`eqnames'",-1)
		if strmatch("`init'","*`wname'*")==0 local init "/`wname'=0 `init'"
		local lname=word("`eqnames'",-2)
		if strmatch("`init'","*`lname'*")==0 local init "/`lname'=0 `init'"
		local lname=word("`eqnames'",-5)
		if strmatch("`init'","*`lname'*")==0 local init "/`lname'=0 `init'"
		if "`masspoint'"!="" qui: reg `true' `obs' `pred' if `touse'==1 & `true'!=`obs'
		else qui: reg `true' `obs' `pred' if `touse'
		local names=word("`eqnames'",-3)
		if strmatch("`init'","*`names'*")==0 local init "/`names'=`e(rmse)' `init'"
		local names=word("`eqnames'",-6)
		if strmatch("`init'","*`names'*")==0 local init "/`names'=`e(rmse)' `init'"
		mat def `b'=e(b)
		local names=word("`eqnames'",-4)
		local names2=word("`eqnames'",-7)
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			if strmatch("`init'","*`names2':``i''*")==0 local init `"`names2':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}
*lots of convergence problems, imposes constraint that truncation is out of sample support for both components, one may want to relax that (particularly when constraining coefficients)
if "`model'"=="mixrtrnorm" {
	global mixargs "xb1 sigma1 rtrunc1 xb2 sigma2 rtrunc2 w2"
	if "`masspoint'"!="" qui: sum `true' if `touse'==1 & `obs'!=. & `obs'!=`true'
	else qui: sum `true' if `touse'==1 & `obs'!=.
	local rtr=`r(max)'
	global mixlik "(1-invlogit(\`w2'))*normalden(\$ML_y1,\`xb1',abs(\`sigma1'))/(normal((`rtr'+abs(\`rtrunc1')-\`xb1')/abs(\`sigma1')))+invlogit(\`w2')*normalden(\$ML_y1,\`xb2',abs(\`sigma2'))/(normal((`rtr'+abs(\`rtrunc2')-\`xb2')/abs(\`sigma2')))"
	local mixfunc "&rrtrnormal()"
	local mixtransf "1,2,&mabs(),1,3,&mabs(),1,3,`rtr'"
	local wgttrfunc "&invlogit()"
	mat def `predictv'=(1,0,0,1,0,0,0)
	mat def `mixparv'=3
	if `defnm'==1 local eqnames "mean1 sigma1 right_trunc1 mean2 sigma2 right_trunc2 weight2"
	*choosing starting value (overall conditional expectation for conditional means of both components & weight=0.5)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		local wname=word("`eqnames'",-1)
		if strmatch("`init'","*`wname'*")==0 local init "/`wname'=0 `init'"
		local rname=word("`eqnames'",-2)
		if strmatch("`init'","*`rname'*")==0 local init "/`rname'=0 `init'"
		local rname=word("`eqnames'",-5)
		if strmatch("`init'","*`rname'*")==0 local init "/`rname'=0 `init'"
		if "`masspoint'"!="" qui: reg `true' `obs' `pred' if `touse'==1 & `true'!=`obs'
		else qui: reg `true' `obs' `pred' if `touse'
		local names=word("`eqnames'",-3)
		if strmatch("`init'","*`names'*")==0 local init "/`names'=`e(rmse)' `init'"
		local names=word("`eqnames'",-6)
		if strmatch("`init'","*`names'*")==0 local init "/`names'=`e(rmse)' `init'"
		mat def `b'=e(b)
		local names=word("`eqnames'",-4)
		local names2=word("`eqnames'",-7)
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			if strmatch("`init'","*`names2':``i''*")==0 local init `"`names2':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}
if "`model'"=="exp" {
	global mixargs "eloc1 xb1"
	if "`masspoint'"!="" qui: sum `true' if `touse'==1 & `obs'!=. & `obs'!=`true'
	else qui: sum `true' if `touse'==1 & `obs'!=.
	local loctr=`r(min)'
	global mixlik "exp(\`xb1')*exp(-exp(\`xb1')*(\$ML_y1-`loctr'+abs(\`eloc1')))"
	local mixfunc "&rexploc()"
	local mixtransf "1,1,&mneg(),1,1,`loctr',1,2,&mexp()"
	mat def `predictv'=(0,1)
	mat def `mixparv'=2
	*define init by running regression?
	if `defnm'==1 local eqnames "eloc lambda"
}
if "`model'"=="mixexp" {
	global mixargs "eloc1 xb1 eloc2 xb2 w2"
	if "`masspoint'"!="" qui: sum `true' if `touse'==1 & `obs'!=. & `obs'!=`true'
	else qui: sum `true' if `touse'==1 & `obs'!=.
	local loctr=`r(min)'	
	global mixlik "(1-invlogit(\`w2'))*exp(\`xb1')*exp(-exp(\`xb1')*(\$ML_y1-`loctr'+abs(\`eloc1')))+cond(\$ML_y1+\`eloc2'>0,1,0)*invlogit(\`w2')*exp(\`xb2')*exp(-exp(\`xb2')*(\$ML_y1-\`eloc2'))"	
	local mixfunc "&rexploc(),&rexploc()"
	local mixtransf "1,1,&mneg(),1,1,`loctr',1,2,&mexp(),2,2,&mexp()"
	local wgttrfunc "&invlogit()"
	mat def `predictv'=(0,1,0,1,0)
	mat def `mixparv'=(2,2)
	if `defnm'==1 local eqnames "eloc1 lambda1 eloc2 lambda2 weight2"
	*only setting weight to zero for init -> more? less?
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		local wname=word("`eqnames'",wordcount("`eqnames'"))
		if strmatch("`init'","*`wname'*")==0 local init "/`wname'=0 `init'"
	}
}
if "`model'"=="weibull" {
	global mixargs "wloc1 k1 xb1"
	if "`masspoint'"!="" qui: sum `true' if `touse'==1 & `obs'!=. & `obs'!=`true'
	else qui: sum `true' if `touse'==1 & `obs'!=.
	local loctr=`r(min)'
	global mixlik "exp(\`k1')/exp(\`xb1')*((\$ML_y1-`loctr'+exp(\`wloc1'))/exp(\`xb1'))^(exp(\`k1')-1)*exp(-((\$ML_y1-`loctr'+exp(\`wloc1'))/exp(\`xb1'))^exp(\`k1'))"
	local mixfunc "&rweibloc()"
	local mixtransf "1,1,&mexp(),1,1,&mneg(),1,1,`loctr',1,2,&mexp(),1,3,&mexp()"
	mat def `predictv'=(0,0,1)
	mat def `mixparv'=3
	*define init by running regression?
	if `defnm'==1 local eqnames "wloc wshape lambda"
}
if "`model'"=="mixweibull" {
	global mixargs "wloc1 k1 xb1 wloc2 k2 xb2 w2"
	if "`masspoint'"!="" qui: sum `true' if `touse'==1 & `obs'!=. & `obs'!=`true'
	else qui: sum `true' if `touse'==1 & `obs'!=.
	local loctr=`r(min)'	
	global mixlik "(1-invlogit(\`w2'))*exp(\`k1')/exp(\`xb1')*((\$ML_y1-`loctr'+exp(\`wloc1'))/exp(\`xb1'))^(exp(\`k1')-1)*exp(-((\$ML_y1-`loctr'+exp(\`wloc1'))/exp(\`xb1'))^exp(\`k1'))+cond(\$ML_y1-\`wloc2'>0,1,0)*invlogit(\`w2')*exp(\`k2')/exp(\`xb2')*((\$ML_y1-\`wloc2')/exp(\`xb2'))^(exp(\`k2')-1)*exp(-((\$ML_y1-\`wloc2')/exp(\`xb2'))^exp(\`k2'))"	
	local mixfunc "&rweibloc(),&rweibloc()"
	local mixtransf "1,1,&mexp(),1,1,&mneg(),1,1,`loctr',1,2,&mexp(),1,3,&mexp(),2,2,&mexp(),2,3,&mexp()"
	local wgttrfunc "&invlogit()"
	mat def `predictv'=(0,0,1,0,0,1,0)
	mat def `mixparv'=(3,3)
	if `defnm'==1 local eqnames "wloc1 wshape1 lambda1 wloc2 wshape2 lambda2 weight2"
	*only setting weight to zero for init -> more? less?
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		local wname=word("`eqnames'",wordcount("`eqnames'"))
		if strmatch("`init'","*`wname'*")==0 local init "/`wname'=0 `init'"
	}
}
if "`model'"=="t" {
	global mixargs "xb1 sigma1 df1"
	global mixlik "exp(lngamma((exp(\`df1')+2)/2))/(exp(\`sigma1')*sqrt((exp(\`df1')+1)*_pi)*exp(lngamma((exp(\`df1')+1)/2)))*(1+((\$ML_y1-\`xb1')/exp(\`sigma1'))^2/(exp(\`df1')+1))^(-(exp(\`df1')+2)/2)"
	local mixfunc "&rgent()"
	local mixtransf "1,2,&mexp(),1,3,&mexp(),1,3,1"
	mat def `predictv'=(1,0,0)
	mat def `mixparv'=3
	if `defnm'==1 local eqnames "mean sigma df"
	*choosing starting values
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		if "`masspoint'"!="" qui: reg `true' `obs' `pred' if `touse'==1 & `true'!=`obs'
		else qui: reg `true' `obs' `pred' if `touse'
		mat def `b'=e(b)
		local names=word("`eqnames'",-3)
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'		
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}
if "`model'"=="mixt" {
	global mixargs "xb1 sigma1 df1 xb2 sigma2 df2 w2"
	global mixlik "(1-invlogit(\`w2'))*(exp(lngamma((exp(\`df1')+2)/2))/(exp(\`sigma1')*sqrt((exp(\`df1')+1)*_pi)*exp(lngamma((exp(\`df1')+1)/2)))*(1+((\$ML_y1-\`xb1')/exp(\`sigma1'))^2/(exp(\`df1')+1))^(-(exp(\`df1')+2)/2))+invlogit(\`w2')*(exp(lngamma((exp(\`df2')+2)/2))/(exp(\`sigma2')*sqrt((exp(\`df2')+1)*_pi)*exp(lngamma((exp(\`df2')+1)/2)))*(1+((\$ML_y1-\`xb2')/exp(\`sigma2'))^2/(exp(\`df2')+1))^(-(exp(\`df2')+2)/2))"
	local mixfunc "&rgent()"
	local mixtransf "1,2,&mexp(),1,3,&mexp(),1,3,1"
	local wgttrfunc "&invlogit()"
	mat def `predictv'=(1,0,0,1,0,0,0)
	mat def `mixparv'=3
	if `defnm'==1 local eqnames "mean1 sigma1 df1 mean2 sigma2 df2 weight2"
	*choosing starting value (overall conditional expectation for conditional means of both components & weight=0.5)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		local wname=word("`eqnames'",wordcount("`eqnames'"))
		if strmatch("`init'","*`wname'*")==0 local init "/`wname'=0 `init'"
		if "`masspoint'"!="" qui: reg `true' `obs' `pred' if `touse'==1 & `true'!=`obs'
		else qui: reg `true' `obs' `pred' if `touse'
		mat def `b'=e(b)
		local names=word("`eqnames'",-4)
		local names2=word("`eqnames'",-7)
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			if strmatch("`init'","*`names2':``i''*")==0 local init `"`names2':``i''=`j' `init'"'
			local i=`i'+1
		}	
	}
}
if "`model'"=="mixweit" {
	global mixargs "xb1 sigma1 df1 xb2 k2 lambda2 w2"
	global mixlik "(1-invlogit(\`w2'))*(exp(lngamma((exp(\`df1')+2)/2))/(exp(\`sigma1')*sqrt((exp(\`df1')+1)*_pi)*exp(lngamma((exp(\`df1')+1)/2)))*(1+((\$ML_y1-\`xb1')/exp(\`sigma1'))^2/(exp(\`df1')+1))^(-(exp(\`df1')+2)/2))+invlogit(\`w2')*(cond(\$ML_y1-\`xb2'>0,exp(\`k2')/exp(\`lambda2')*((\$ML_y1-\`xb2')/exp(\`lambda2'))^(exp(\`k2')-1)*exp(-((\$ML_y1-\`xb2')/exp(\`lambda2'))^exp(\`k2')),0))"
	local mixfunc "&rgent(),&rweibloc()"
	local mixtransf "1,2,&mexp(),1,3,&mexp(),1,3,1,2,2,&mexp(),2,3,&mexp()"
	local wgttrfunc "&invlogit()"
	mat def `predictv'=(1,0,0,1,0,0,0)
	mat def `mixparv'=(3,3)
	if `defnm'==1 local eqnames "mean1 sigma1 df1 wloc2 wshape2 wlambda2 weight2"
	*only setting weight to zero for init -> more? less?
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		local wname=word("`eqnames'",-1)
		if strmatch("`init'","*`wname'*")==0 local init "/`wname'=0 `init'"
	}
}
}
else if "`model'"!="" {
di as err "Invalid argument for measurement error in option model(): `model'"
exit
}

*setup model for non-response
if "`mvars'"!="" {
if strmatch(lower("`modelopts'"),"*miss*")==0 local modelopts "`modelopts' missing"
if (inlist("`nrmodel'","normal","mixnorm","exp","mixexp","weibull","mixweibull","t","mixt","mixweit")==1 | inlist("`nrmodel'","trnorm","ltrnorm","rtrnorm","mixtrnorm","mixltrnorm","mixrtrnorm")==1) {
if "`nrmodel'"=="normal" {
	global mixargs "m1 sigmam1 $mixargs"	
	global nrlik "normalden(\$ML_y1,\`m1',exp(\`sigmam1'))"
	local nrfunc "&mrnormal()"
	local nrtransf "1,2,&mexp()"
	mat def `nrparv'=2
	if "`mvars'"=="cons" mat def `predictv'=(0,0,`predictv')
	else mat def `predictv'=(1,0,`predictv')
	if `defnm'==1 local eqnames "m1 sigmam `eqnames'"
	*choosing starting values (conditional mean only)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		if "`mvars'"!="cons"{
			qui: reg `true' `mvars' if `touse'==1 & `obs'==.
		}
		else qui: reg `true' if `touse'==1 & `obs'==.
		mat def `b'=e(b)
		if `defnm'==1 local names=word("`eqnames'",1)
		else local names=word("`eqnames'",wordcount("`masspoint'")+1)
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'		
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			local i=`i'+1
		}	
	}
}	
if "`nrmodel'"=="trnorm" {
	global mixargs "m1 sigmam1 ltruncm1 rtruncm1 $mixargs"
	qui: sum `true' if `touse'==1 & `obs'==.
	local ltr=`r(min)'
	local rtr=`r(max)'
	global nrlik "normalden(\$ML_y1,\`m1',abs(\`sigmam1'))/(normal((`rtr'+abs(\`rtruncm1')-\`m1')/abs(\`sigmam1'))-normal((`ltr'-abs(\`ltruncm1')-\`m1')/abs(\`sigmam1')))"
	local nrfunc "&rtrnormal()"
	local nrtransf "1,2,&mabs(),1,3,&mneg(),1,3,`ltr',1,4,&mabs(),1,4,`rtr'"
	mat def `nrparv'=4
	if "`mvars'"=="cons" mat def `predictv'=(0,0,0,0,`predictv')
	else mat def `predictv'=(1,0,0,0,`predictv')
	if `defnm'==1 local eqnames "m1 sigma_m left_trunc_m right_trunc_m `eqnames'"
	*choosing starting values (conditional mean only)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		if `defnm'==1 local lname=word("`eqnames'",3)
		else local lname=word("`eqnames'",wordcount("`masspoint'")+3)
		if strmatch("`init'","*`lname'*")==0 local init "/`lname'=0 `init'"
		if `defnm'==1 local rname=word("`eqnames'",4)
		else local rname=word("`eqnames'",wordcount("`masspoint'")+4)
		if strmatch("`init'","*`rname'*")==0 local init "/`rname'=0 `init'"
		if "`mvars'"!="cons"{
			qui: reg `true' `mvars' if `touse'==1 & `obs'==.
		}
		else qui: reg `true' if `touse'==1 & `obs'==.
		mat def `b'=e(b)
		if `defnm'==1 local names=word("`eqnames'",1)
		else local names=word("`eqnames'",wordcount("`masspoint'")+1)
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'		
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}
if "`nrmodel'"=="ltrnorm" {
	global mixargs "m1 sigmam1 ltruncm1 $mixargs"
	qui: sum `true' if `touse'==1 & `obs'==.
	local ltr=`r(min)'
	global nrlik "normalden(\$ML_y1,\`m1',abs(\`sigmam1'))/(1-normal((`ltr'-abs(\`ltruncm1')-\`m1')/abs(\`sigmam1')))"
	local nrfunc "&rltrnormal()"
	local nrtransf "1,2,&mabs(),1,3,&mneg(),1,3,`ltr'"
	mat def `nrparv'=3
	if "`mvars'"=="cons" mat def `predictv'=(0,0,0,`predictv')
	else mat def `predictv'=(1,0,0,`predictv')
	if `defnm'==1 local eqnames "m1 sigma_m left_trunc_m `eqnames'"
	*choosing starting values (conditional mean only)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		if `defnm'==1 local lname=word("`eqnames'",3)
		else local lname=word("`eqnames'",wordcount("`masspoint'")+3)
		if strmatch("`init'","*`lname'*")==0 local init "/`lname'=0 `init'"
		if "`mvars'"!="cons"{
			qui: reg `true' `mvars' if `touse'==1 & `obs'==.
		}
		else qui: reg `true' if `touse'==1 & `obs'==.
		mat def `b'=e(b)
		if `defnm'==1 local names=word("`eqnames'",1)
		else local names=word("`eqnames'",wordcount("`masspoint'")+1)
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'		
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}
if "`nrmodel'"=="rtrnorm" {
	global mixargs "m1 sigmam1 rtruncm1 $mixargs"
	qui: sum `true' if `touse'==1 & `obs'==.
	local rtr=`r(max)'
	global nrlik "normalden(\$ML_y1,\`m1',abs(\`sigmam1'))/(normal((`rtr'+abs(\`rtruncm1')-\`m1')/abs(\`sigmam1')))/abs(\`sigmam1')))"
	local nrfunc "&rrtrnormal()"
	local nrtransf "1,2,&mabs(),1,3,&mabs(),1,3,`rtr'"
	mat def `nrparv'=3
	if "`mvars'"=="cons" mat def `predictv'=(0,0,0,`predictv')
	else mat def `predictv'=(1,0,0,`predictv')
	if `defnm'==1 local eqnames "m1 sigma_m right_trunc_m `eqnames'"
	*choosing starting values (conditional mean only)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		if `defnm'==1 local rname=word("`eqnames'",3)
		else local rname=word("`eqnames'",wordcount("`masspoint'")+3)
		if strmatch("`init'","*`rname'*")==0 local init "/`rname'=0 `init'"
		if "`mvars'"!="cons"{
			qui: reg `true' `mvars' if `touse'==1 & `obs'==.
		}
		else qui: reg `true' if `touse'==1 & `obs'==.
		mat def `b'=e(b)
		if `defnm'==1 local names=word("`eqnames'",1)
		else local names=word("`eqnames'",wordcount("`masspoint'")+1)
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'		
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}
if "`nrmodel'"=="mixnorm" {
	global mixargs "m1 sigmam1 m2 sigmam2 wm $mixargs"
	global nrlik "(1-invlogit(\`wm'))*normalden(\$ML_y1,\`m1',exp(\`sigmam1'))+invlogit(\`wm')*normalden(\$ML_y1,\`m2',exp(\`sigmam2'))"
	local nrfunc "&mrnormal(),&mrnormal()"
	local nrtransf "1,2,&mexp(),2,2,&mexp()"
	local nrwgttrfunc "&invlogit()"
	mat def `nrparv'=(2,2)
	if lower("`mvars'")=="cons" mat def `predictv'=(0,0,0,0,0,`predictv')
	else mat def `predictv'=(1,0,1,0,0,`predictv')
	if `defnm'==1 {
		local eqnames "m1 sigmam1 m2 sigmam2 nrweight2 `eqnames'"
		local wname="nrweight2"
	}
	else local wname=word("`eqnames'",5+wordcount("`masspoint'"))
	*choosing starting value (overall conditional expectation for conditional means of both components & weight=0.5)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		if strmatch("`init'","*`wname'*")==0 local init "/`wname'=0 `init'"
		if "`mvars'"!="cons"{
			qui: reg `true' `mvars' if `touse'==1 & `obs'==.
		}
		else qui: reg `true' if `touse'==1 & `obs'==.
		mat def `b'=e(b)
		if `defnm'==1 {
			local names=word("`eqnames'",1)
			local names2=word("`eqnames'",3)
		}
		else {
			local names=word("`eqnames'",wordcount("`masspoint'")+1)
			local names2=word("`eqnames'",wordcount("`masspoint'")+3)	
		}
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			if strmatch("`init'","*`names2':``i''*")==0 local init `"`names2':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}	
*doesn't work too well, imposes constraint that truncation is out of sample support for both components, one may want to relax that (particularly when constraining coefficients)
if "`nrmodel'"=="mixtrnorm" {
	global mixargs "m1 sigmam1 ltruncm1 rtruncm1 m2 sigmam2 ltruncm2 rtruncm2 wm $mixargs"
	qui: sum `true' if `touse'==1 & `obs'==.
	local ltr=`r(min)'
	local rtr=`r(max)'
	global nrlik "(1-invlogit(\`wm'))*normalden(\$ML_y1,\`m1',abs(\`sigmam1'))/(normal((`rtr'+abs(\`rtruncm1')-\`m1')/abs(\`sigmam1'))-normal((`ltr'-abs(\`ltruncm1')-\`m1')/abs(\`sigmam1')))+invlogit(\`wm')*normalden(\$ML_y1,\`m2',abs(\`sigmam2'))/(normal((`rtr'+abs(\`rtruncm2')-\`m2')/abs(\`sigmam2'))-normal((`ltr'-abs(\`ltruncm2')-\`m2')/abs(\`sigmam2')))"
	local nrfunc "&rtrnormal(),&rtrnormal()"
	local nrtransf "1,2,&mabs(),1,3,&mneg(),1,3,`ltr',1,4,&mabs(),1,4,`rtr',2,2,&mabs(),2,3,&mneg(),2,3,`ltr',2,4,&mabs(),2,4,`rtr'"
	local nrwgttrfunc "&invlogit()"
	mat def `mixparv'=(4,4)
	if lower("`mvars'")=="cons" mat def `predictv'=(0,0,0,0,0,0,0,0,0,`predictv')
	else mat def `predictv'=(1,0,0,0,1,0,0,0,0,`predictv')
	if `defnm'==1 {
		local eqnames "m1 sigmam1 left_trunc_m1 right_trunc_m1 m2 sigmam2 left_trunc_m2 right_trunc_m2 nrweight2 `eqnames'"
		local wname="nrweight2"
	}
	else local wname=word("`eqnames'",9+wordcount("`masspoint'"))
	*choosing starting value (overall conditional expectation for conditional means of both components & weight=0.5)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		if strmatch("`init'","*`wname'*")==0 local init "/`wname'=0 `init'"
		if `defnm'==1 {
			local lname=word("`eqnames'",3)
			local rname=word("`eqnames'",4)
			local lname2=word("`eqnames'",7)
			local rname2=word("`eqnames'",8)
		}		
		else {
			local lname=word("`eqnames'",wordcount("`masspoint'")+3)
			local rname=word("`eqnames'",wordcount("`masspoint'")+4)
			local lname2=word("`eqnames'",wordcount("`masspoint'")+7)
			local rname2=word("`eqnames'",wordcount("`masspoint'")+8)			
		}
		if strmatch("`init'","*`lname'*")==0 local init "/`lname'=0 `init'"
		if strmatch("`init'","*`rname'*")==0 local init "/`rname'=0 `init'"
		if strmatch("`init'","*`lname2'*")==0 local init "/`lname2'=0 `init'"
		if strmatch("`init'","*`rname2'*")==0 local init "/`rname2'=0 `init'"
		if "`mvars'"!="cons"{
			qui: reg `true' `mvars' if `touse'==1 & `obs'==.
		}
		else qui: reg `true' if `touse'==1 & `obs'==.
		mat def `b'=e(b)
		if `defnm'==1 {
			local names=word("`eqnames'",1)
			local names2=word("`eqnames'",5)
		}
		else {
			local names=word("`eqnames'",wordcount("`masspoint'")+1)
			local names2=word("`eqnames'",wordcount("`masspoint'")+5)	
		}
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			if strmatch("`init'","*`names2':``i''*")==0 local init `"`names2':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}
if "`nrmodel'"=="mixltrnorm" {
	global mixargs "m1 sigmam1 ltruncm1 m2 sigmam2 ltruncm2 wm $mixargs"
	qui: sum `true' if `touse'==1 & `obs'==.
	local ltr=`r(min)'
	global nrlik "(1-invlogit(\`wm'))*normalden(\$ML_y1,\`m1',abs(\`sigmam1'))/(1-normal((`ltr'-abs(\`ltruncm1')-\`m1')/abs(\`sigmam1')))+invlogit(\`wm')*normalden(\$ML_y1,\`m2',abs(\`sigmam2'))/(1-normal((`ltr'-abs(\`ltruncm2')-\`m2')/abs(\`sigmam2')))"
	local nrfunc "&rltrnormal(),&rltrnormal()"
	local nrtransf "1,2,&mabs(),1,3,&mneg(),1,3,`ltr',2,2,&mabs(),2,3,&mneg(),2,3,`ltr'"
	local nrwgttrfunc "&invlogit()"
	mat def `mixparv'=(3,3)
	if lower("`mvars'")=="cons" mat def `predictv'=(0,0,0,0,0,0,0,`predictv')
	else mat def `predictv'=(1,0,0,1,0,0,0,`predictv')
	if `defnm'==1 {
		local eqnames "m1 sigmam1 left_trunc_m1 m2 sigmam2 left_trunc_m2 nrweight2 `eqnames'"
		local wname="nrweight2"
	}
	else local wname=word("`eqnames'",7+wordcount("`masspoint'"))
	*choosing starting value (overall conditional expectation for conditional means of both components & weight=0.5)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		if strmatch("`init'","*`wname'*")==0 local init "/`wname'=0 `init'"
		if `defnm'==1 {
			local lname=word("`eqnames'",3)
			local lname2=word("`eqnames'",6)
		}		
		else {
			local lname=word("`eqnames'",wordcount("`masspoint'")+3)
			local lname2=word("`eqnames'",wordcount("`masspoint'")+6)
		}
		if strmatch("`init'","*`lname'*")==0 local init "/`lname'=0 `init'"
		if strmatch("`init'","*`lname2'*")==0 local init "/`lname2'=0 `init'"
		if "`mvars'"!="cons"{
			qui: reg `true' `mvars' if `touse'==1 & `obs'==.
		}
		else qui: reg `true' if `touse'==1 & `obs'==.
		mat def `b'=e(b)
		if `defnm'==1 {
			local names=word("`eqnames'",1)
			local names2=word("`eqnames'",4)
		}
		else {
			local names=word("`eqnames'",wordcount("`masspoint'")+1)
			local names2=word("`eqnames'",wordcount("`masspoint'")+4)	
		}
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			if strmatch("`init'","*`names2':``i''*")==0 local init `"`names2':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}
*lots of convergence problems, imposes constraint that truncation is out of sample support for both components, one may want to relax that (particularly when constraining coefficients)
if "`nrmodel'"=="mixrtrnorm" {
	global mixargs "m1 sigmam1 rtruncm1 m2 sigmam2 rtruncm2 wm $mixargs"
	qui: sum `true' if `touse'==1 & `obs'==.
	local rtr=`r(max)'
	global nrlik "(1-invlogit(\`wm'))*normalden(\$ML_y1,\`m1',abs(\`sigmam1'))/(normal((`rtr'+abs(\`rtruncm1')-\`m1')/abs(\`sigmam1')))+invlogit(\`wm')*normalden(\$ML_y1,\`m2',abs(\`sigmam2'))/(normal((`rtr'+abs(\`rtruncm2')-\`m2')/abs(\`sigmam2')))"
	local nrfunc "&rrtrnormal(),&rrtrnormal()"
	local nrtransf "1,2,&mabs(),1,3,&mabs(),1,3,`rtr',2,2,&mabs(),2,3,&mabs(),2,3,`rtr'"
	local nrwgttrfunc "&invlogit()"
	mat def `mixparv'=(3,3)
	if lower("`mvars'")=="cons" mat def `predictv'=(0,0,0,0,0,0,0,`predictv')
	else mat def `predictv'=(1,0,0,1,0,0,0,`predictv')
	if `defnm'==1 {
		local eqnames "m1 sigmam1 right_trunc_m1 m2 sigmam2 right_trunc_m2 nrweight2 `eqnames'"
		local wname="nrweight2"
	}
	else local wname=word("`eqnames'",7+wordcount("`masspoint'"))	
	*choosing starting value (overall conditional expectation for conditional means of both components & weight=0.5)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		if strmatch("`init'","*`wname'*")==0 local init "/`wname'=0 `init'"
		if `defnm'==1 {
			local rname=word("`eqnames'",3)
			local rname2=word("`eqnames'",6)
		}		
		else {
			local rname=word("`eqnames'",wordcount("`masspoint'")+3)
			local rname2=word("`eqnames'",wordcount("`masspoint'")+6)
		}
		if strmatch("`init'","*`rname'*")==0 local init "/`rname'=0 `init'"
		if strmatch("`init'","*`rname2'*")==0 local init "/`rname2'=0 `init'"
		if "`mvars'"!="cons"{
			qui: reg `true' `mvars' if `touse'==1 & `obs'==.
		}
		else qui: reg `true' if `touse'==1 & `obs'==.
		mat def `b'=e(b)
		if `defnm'==1 {
			local names=word("`eqnames'",1)
			local names2=word("`eqnames'",4)
		}
		else {
			local names=word("`eqnames'",wordcount("`masspoint'")+1)
			local names2=word("`eqnames'",wordcount("`masspoint'")+4)	
		}
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			if strmatch("`init'","*`names2':``i''*")==0 local init `"`names2':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}
if "`nrmodel'"=="exp" {
	global mixargs "nreloc1 m1 $mixargs"
	qui: sum `true' if `touse'==1 & `obs'==.
	local nrloctr=`r(min)'
	global nrlik "exp(\`m1')*exp(-exp(\`m1')*(\$ML_y1-`nrloctr'+abs(\`nreloc1')))"
	local nrfunc "&rexploc()"
	local nrtransf "1,1,&mneg(),1,1,`nrloctr',1,2,&mexp()"
	mat def `nrparv'=2
	if lower("`mvars'")=="cons" mat def `predictv'=(0,0,`predictv')
	else mat def `predictv'=(0,1,`predictv')
	if `defnm'==1 local eqnames "nreloc nrlambda `eqnames'"
}	
if "`nrmodel'"=="mixexp" {
	global mixargs "nreloc1 m1 nreloc2 m2 wm $mixargs"
	qui: sum `true' if `touse'==1 & `obs'==.
	local nrloctr=`r(min)'
	global nrlik "(1-invlogit(\`wm'))*exp(\`m1')*exp(-exp(\`m1')*(\$ML_y1-`nrloctr'+abs(\`nreloc1')))+cond(\$ML_y1+\`nreloc2'>0,1,0)*invlogit(\`wm')*exp(\`m2')*exp(-exp(\`m2')*(\$ML_y1-\`nreloc2'))"
	local nrfunc "&rexploc(),&rexploc()"
	local nrtransf "1,1,&mneg(),1,1,`nrloctr',1,2,&mexp(),2,2,&mexp()"
	local nrwgttrfunc "&invlogit()"
	mat def `nrparv'=(2,2)
	if lower("`mvars'")=="cons" mat def `predictv'=(0,0,0,0,0,`predictv')
	else mat def `predictv'=(0,1,0,1,0,`predictv')
	if `defnm'==1 {
		local eqnames "nreloc1 nrlambda1 nreloc2 nrlambda2 nrweight2 `eqnames'"
		local wname="nrweight2"
	}
	else local wname=word("`eqnames'",5+wordcount("`masspoint'"))
	*only setting weight to zero for init -> more? less?
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		if strmatch("`init'","*`wname'*")==0 local init "/`wname'=0 `init'"
	}
}	
if "`nrmodel'"=="weibull" {
	global mixargs "nrwloc1 nrk1 m1 $mixargs"
	qui: sum `true' if `touse'==1 & `obs'==.
	local nrloctr=`r(min)'
	global nrlik "exp(\`nrk1')/exp(\`m1')*((\$ML_y1-`nrloctr'+exp(\`nrwloc1'))/exp(\`m1'))^(exp(\`nrk1')-1)*exp(-((\$ML_y1-`nrloctr'+exp(\`nrwloc1'))/exp(\`m1'))^exp(\`nrk1'))"
	local nrfunc "&rweibloc()"
	local nrtransf "1,1,&mexp(),1,1,&mneg(),1,1,`nrloctr',1,2,&mexp(),1,3,&mexp()"
	if lower("`mvars'")=="cons" mat def `predictv'=(0,0,0,`predictv')
	else mat def `predictv'=(0,0,1,`predictv')
	mat def `nrparv'=3
	*starting values?
	if `defnm'==1 local eqnames "nrwloc nrwshape nrlambda `eqnames'"
}
if "`nrmodel'"=="mixweibull" {
	global mixargs "nrwloc1 nrk1 m1 nrwloc2 nrk2 m2 wm"
	qui: sum `true' if `touse'==1 & `obs'==.
	local nrloctr=`r(min)'	
	global nrlik "(1-invlogit(\`wm'))*exp(\`nrk1')/exp(\`m1')*((\$ML_y1-`nrloctr'+exp(\`nrwloc1'))/exp(\`m1'))^(exp(\`nrk1')-1)*exp(-((\$ML_y1-`nrloctr'+exp(\`nrwloc1'))/exp(\`m1'))^exp(\`nrk1'))+cond(\$ML_y1-\`nrwloc2'>0,1,0)*invlogit(\`wm')*exp(\`nrk2')/exp(\`m2')*((\$ML_y1-\`nrwloc2')/exp(\`m2'))^(exp(\`nrk2')-1)*exp(-((\$ML_y1-\`nrwloc2')/exp(\`m2'))^exp(\`nrk2'))"	
	local nrfunc "&rweibloc(),&rweibloc()"
	local nrtransf "1,1,&mexp(),1,1,&mneg(),1,1,`nrloctr',1,2,&mexp(),1,3,&mexp(),2,2,&mexp(),2,3,&mexp()"
	local nrwgttrfunc "&invlogit()"
	if lower("`mvars'")=="cons" mat def `predictv'=(0,0,0,0,0,0,0,`predictv')
	else mat def `predictv'=(0,0,1,0,0,1,`predictv')
	mat def `nrparv'=(3,3)
	*only setting weight to zero for init -> more? less?
	if `defnm'==1 {
		local eqnames "nrwloc1 nrwshape1 nrlambda1 nrwloc2 nrwshape2 nrlambda2 nrweight2 `eqnames'"
		local wname="nrweight2"
	}
	else local wname=word("`eqnames'",wordcount("`eqnames'"))
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		if strmatch("`init'","*`wname'*")==0 local init "/`wname'=0 `init'"
	}
}
if "`nrmodel'"=="t" {
	global mixargs "m1 nrsigma1 nrdf1 $mixargs"
	global nrlik "exp(lngamma((exp(\`nrdf1')+2)/2))/(exp(\`nrsigma1')*sqrt((exp(\`nrdf1')+1)*_pi)*exp(lngamma((exp(\`nrdf1')+1)/2)))*(1+((\$ML_y1-\`m1')/exp(\`nrsigma1'))^2/(exp(\`nrdf1')+1))^(-(exp(\`nrdf1')+2)/2)"
	local nrfunc "&rgent()"
	local nrtransf "1,2,&mexp(),1,3,&mexp(),1,3,1"
	if lower("`mvars'")=="cons" mat def `predictv'=(0,0,0,`predictv')
	else mat def `predictv'=(1,0,0,`predictv')
	mat def `nrparv'=3
	if `defnm'==1 local eqnames "m1 nrsigma1 nrdf1 `eqnames'"
	*choosing starting values (conditional mean only)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		if "`mvars'"!="cons"{
			qui: reg `true' `mvars' if `touse'==1 & `obs'==.
		}
		else qui: reg `true' if `touse'==1 & `obs'==.
		mat def `b'=e(b)
		if `defnm'==1 local names=word("`eqnames'",1)
		else local names=word("`eqnames'",wordcount("`masspoint'")+1)
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'		
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}
if "`nrmodel'"=="mixt" {
	global mixargs "m1 nrsigma1 nrdf1 m2 nrsigma2 nrdf2 wm $mixargs"
	global nrlik "(1-invlogit(\`wm'))*(exp(lngamma((exp(\`nrdf1')+2)/2))/(exp(\`nrsigma1')*sqrt((exp(\`nrdf1')+1)*_pi)*exp(lngamma((exp(\`nrdf1')+1)/2)))*(1+((\$ML_y1-\`m1')/exp(\`nrsigma1'))^2/(exp(\`nrdf1')+1))^(-(exp(\`nrdf1')+2)/2))+invlogit(\`wm')*(exp(lngamma((exp(\`nrdf2')+2)/2))/(exp(\`nrsigma2')*sqrt((exp(\`nrdf2')+1)*_pi)*exp(lngamma((exp(\`nrdf2')+1)/2)))*(1+((\$ML_y1-\`m2')/exp(\`nrsigma2'))^2/(exp(\`nrdf2')+1))^(-(exp(\`nrdf2')+2)/2))"
	local nrfunc "&rgent(),&rgent()"
	local nrtransf "1,2,&mexp(),1,3,&mexp(),1,3,1,2,2,&mexp(),2,3,&mexp(),2,3,1"
	local nrwgttrfunc "&invlogit()"
	if lower("`mvars'")=="cons" mat def `predictv'=(0,0,0,0,0,0,0,`predictv')
	else mat def `predictv'=(1,0,0,1,0,0,0,`predictv')
	mat def `nrparv'=(3,3)
	if `defnm'==1 {
		local eqnames "m1 nrsigma1 nrdf1 m2 nrsigma2 nrdf2 nrweight2 `eqnames'"
		local wname="nrweight2"
	}
	else local wname=word("`eqnames'",7+wordcount("`masspoint'"))
	*choosing starting value (overall conditional expectation for conditional means of both components & weight=0.5)
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		if strmatch("`init'","*`wname'*")==0 local init "/`wname'=0 `init'"
		if "`mvars'"!="cons"{
			qui: reg `true' `mvars' if `touse'==1 & `obs'==.
		}
		else qui: reg `true' if `touse'==1 & `obs'==.
		mat def `b'=e(b)
		if `defnm'==1 {
			local names=word("`eqnames'",1)
			local names2=word("`eqnames'",4)
		}
		else {
			local names=word("`eqnames'",wordcount("`masspoint'")+1)
			local names2=word("`eqnames'",wordcount("`masspoint'")+4)	
		}	
		local pnames: colnames `b'
		local i=1
		tokenize `pnames'
		while `i'<=colsof(`b') {
			local j=`b'[1,`i']
			if strmatch("`init'","*`names':``i''*")==0 local init `"`names':``i''=`j' `init'"'
			if strmatch("`init'","*`names2':``i''*")==0 local init `"`names2':``i''=`j' `init'"'
			local i=`i'+1
		}
	}
}
if "`nrmodel'"=="mixweit" {
	global mixargs "m1 nrsigma1 nrdf1 m2 nrk2 nrlambda2 wm $mixargs"
	global nrlik "(1-invlogit(\`wm'))*(exp(lngamma((exp(\`nrdf1')+2)/2))/(exp(\`nrsigma1')*sqrt((exp(\`nrdf1')+1)*_pi)*exp(lngamma((exp(\`nrdf1')+1)/2)))*(1+((\$ML_y1-\`m1')/exp(\`nrsigma1'))^2/(exp(\`nrdf1')+1))^(-(exp(\`nrdf1')+2)/2))+invlogit(\`wm')*(cond(\$ML_y1-\`m2'>0,exp(\`k2')/exp(\`nrlambda2')*((\$ML_y1-\`m2')/exp(\`nrlambda2'))^(exp(\`nrk2')-1)*exp(-((\$ML_y1-\`m2')/exp(\`nrlambda2'))^exp(\`nrk2')),0))"
	local nrfunc "&rgent(),&rweibloc()"
	local nrtransf "1,2,&mexp(),1,3,&mexp(),1,3,1,2,2,&mexp(),2,3,&mexp()"
	local nrwgttrfunc "&invlogit()"
	if lower("`mvars'")=="cons" mat def `predictv'=(0,0,0,0,0,0,0,`predictv')
	else mat def `predictv'=(1,0,0,1,0,0,0,`predictv')
	mat def `nrparv'=(3,3)
	if `defnm'==1 {
		local eqnames "m1 nrsigma1 nrdf1 nrwloc2 nrwshape2 nrwlambda2 nrweight2"
		local wname="nrweight2"
	}
	else local wname=word("`eqnames'",7+wordcount("`masspoint'"))
	*only setting weight to zero for init -> more? less?
	if strmatch("`init'","*copy*")==0 & strmatch("`init'","*matrix*")==0 & "`init'"!="random" {
		if strmatch("`init'","*`wname'*")==0 local init "/`wname'=0 `init'"
	}
}
}
else if "`nrmodel'"!="" {
	di as err "Invalid argument for missing values in option model(): `nrmodel'"
	exit
}

}

*get variable numbers
local nprvar: word count `obs' `pred'
local nmvar: word count `mvars'

*set up masspoint
if "`masspoint'"=="" global mixmp="none"
else {
	if "`mpfunc'"!="" {
		if strmatch("`mpfunc'","*()")==1 local mpfunc=subinstr("`mpfunc'","()","",.)
		global mixmp "`mpfunc'(\`mp')"
	}
	else global mixmp "normal(\`mp')"
	global mixargs="mp $mixargs"
	mat def `predictv'=(1,`predictv')
	if `defnm'==1 local eqnames "mp `eqnames'"
}
global mixargs="lnf $mixargs"
}

*set model defaults if specified manually
if "`predict'"!="" mat def `predictv'=`predict'

*set up ml model
local npar=colsof(`predictv')
mat def `b'=trace(diag(`nrparv'))+colsof(`nrparv')-1

if "`eqnames'"=="" {
	foreach i of numlist 1/`npar' {
		if `i'>1 local eqnames="`eqnames' "
		local eqnames="`eqnames'eq"+string(`i')
	}
}


*mass point
tokenize "`eqnames'"
local i=1
if "`masspoint'"!="" {
	if `predictv'[1,1]==0 {
		local nmmod "/``i''"
		mat def `predictors'=1
	}
	else {
		local nmmod "(``i'': `true'=`obs' `pred')"
		mat def `predictors'=`nprvar'+1
	}
	local i=`i'+1
	mat def `b'[1,1]=`b'[1,1]+1
}
*non-response
*set up # of predictors
if `i'<=`b'[1,1] mat def `predictors'=(nullmat(`predictors'),`predictv'[1,`i'..`b'[1,1]]*`nmvar'+J(1,colsof(`predictv'[1,`i'..`b'[1,1]]),1))	
while `i'<=`b'[1,1] {
	if `predictv'[1,`i']==0 local nmmod "`nmmod' /``i''"
	else local nmmod "`nmmod' (``i'': `true'=`mvars')"
	local i=`i'+1
}
*conditional
if `i'<=`npar' mat def `predictors'=(nullmat(`predictors'),`predictv'[1,`b'[1,1]+1...]*`nprvar'+J(1,colsof(`predictv'[1,`b'[1,1]+1...]),1))
while `i'<=`npar' {
	if `predictv'[1,`i']==0 local nmmod "`nmmod' /``i''"
	else local nmmod "`nmmod' (``i'': `true'=`obs' `pred')"
	local i=`i'+1
}	



**find starting values???
if strmatch("`init'","*matrix*")==1 local init=substr("`init'",8,.)

**run ML
local conv=0
if strmatch(lower("`maxopts'"),"*nooutput*")==0 local maxopts "nooutput `maxopts'"
capture noisily {
ml model lf `likprog' `nmmod'  if `touse' [`weight' `exp'], `modelopts'
if lower("`search'")!="off" ml search `search'
if lower("`init'")!="random" ml init `init'
ml maximize, `maxopts'
local conv=e(converged)
}
if ((_rc==430 | `conv'==0) & strmatch(lower("`maxopts'"),"*dif*")==0) {
	di "Maximization did not converge, specifying 'difficult'"
	local maxopts "`maxopts' difficult"
	capture noisily {
		if _rc!=0 {
			ml model lf `likprog' `nmmod'  if `touse' [`weight' `exp'], `modelopts'
			if lower("`search'")!="off" ml search `search
			if lower("`init'")!="random" ml init `init'
		}
		ml maximize, `maxopts'
		local conv=e(converged)
	}
}
if ((_rc==430 |`conv'==0) & strmatch(lower("`modelopts'"),"*tech*")==0) {
	di "Maximization did not converge, specifying 'difficult' and switching methods"
	capture noisily {
		ml model lf `likprog' `nmmod' if `touse' [`weight' `exp'], technique(bhhh dfp bfgs nr) `modelopts'
		if lower("`search'")!="off" ml search `search
		if lower("`init'")!="random" ml init `init'
		ml maximize, `maxopts'
		local conv=e(converged)
	}
}
if _rc!=0 {
di as error "Maximization failed with error code " _rc
exit
}
if `conv'==0 {
di as error "Maximization did not converge"
exit
}
*get rid of globals
if "`macrokeep'"=="" macro drop mixargs nrlik mixobs mixlik

mat def `par'=e(b)
mat def `ao'=e(b)
mat def `v'=e(V)
mat def `vo'=e(V)
mat def `g'=e(gradient)

**fixed transformations of parameters
*transformations for nrparameters
if "`masspoint'"!="" local posp=1
else local posp=0
mat def `trf'=J(1,e(k),0)
if "`nrtransf'"!="" {
	local nrtransf2 ""
	local nrtransf=subinstr("`nrtransf'",","," ",.)
	local trl=wordcount("`nrtransf'")
	if mod(`trl',3)!=0 {
			di as err "Invalid transformation for parameters of non-response specified"
		}
	tokenize `nrtransf'
	local i=1
	while `i'<=`trl' {
		local j=`i'+1
		local k=`i'+2
		*position in `predictv'
		mat def `c'=`posp'+`nrparv'[1,1..``i'']*J(``i'',1,1)-`nrparv'[1,``i'']+max(0,colsof(`nrparv'[1,1..``i''])-2)+``j''
		if `predictv'[1,`c'[1,1]]==0 & (inlist("``k''","&mexp()","&mabs()","&mneg()")==1 | real("``k''")!=.) {		
			*position in par
			mat def `c'=`posp'*(`nprvar'+1)+(`predictv'[1,`posp'+1..`c'[1,1]]*`nmvar')*J(`c'[1,1]-`posp',1,1)+`c'[1,1]-`posp'
			*transformations
			if real("``k''")!=. {
				mat def `par'[1,`c'[1,1]]=`par'[1,`c'[1,1]]+``k''
				mat def `trf'[1,`c'[1,1]]=1
			}
			else if "``k''"=="&mexp()" {
				mat def `par'[1,`c'[1,1]]=exp(`par'[1,`c'[1,1]])
				mat def `v'[1,`c'[1,1]]=`v'[1...,`c'[1,1]]*`par'[1,`c'[1,1]]
				mat def `v'[`c'[1,1],1]=`v'[`c'[1,1],1...]*`par'[1,`c'[1,1]]
				mat def `g'[1,`c'[1,1]]=`g'[1,`c'[1,1]]/`par'[1,`c'[1,1]]
				mat def `trf'[1,`c'[1,1]]=1
			}
			else if "``k''"=="&mabs()" {
				mat def `v'[1,`c'[1,1]]=`v'[1...,`c'[1,1]]*sign(`par'[1,`c'[1,1]])
				mat def `v'[`c'[1,1],1]=`v'[`c'[1,1],1...]*sign(`par'[1,`c'[1,1]])
				mat def `g'[1,`c'[1,1]]=`g'[1,`c'[1,1]]*sign(`par'[1,`c'[1,1]])
				mat def `par'[1,`c'[1,1]]=abs(`par'[1,`c'[1,1]])
				mat def `trf'[1,`c'[1,1]]=1
			}
			else if "``k''"=="&mneg()" {
				mat def `v'[1,`c'[1,1]]=`v'[1...,`c'[1,1]]*sign(`par'[1,`c'[1,1]])*(-1)
				mat def `v'[`c'[1,1],1]=`v'[`c'[1,1],1...]*sign(`par'[1,`c'[1,1]])*(-1)
				mat def `g'[1,`c'[1,1]]=`g'[1,`c'[1,1]]*sign(`par'[1,`c'[1,1]])/(-1)
				mat def `par'[1,`c'[1,1]]=abs(`par'[1,`c'[1,1]])*(-1)
				mat def `trf'[1,`c'[1,1]]=1
			}			
		}
		*add any other functions?
		else {
			if "`nrtransf2'"!="" local nrtransf2="`nrtransf2',"
			local nrtransf2 "`nrtransf2'``i'',``j'',``k''"
		}
		local i=`i'+3
	}
	local nrtransf "`nrtransf2'"
}
*non-response weights
if "`nrwgttrfunc'"!="" {
	if colsof(`nrparv')<2 {
		di as error "Transformation for non-response weights specified, but model does not include any such weights (length of nrpar<2)"
		exit
	}
	local cons=1
	mat drop `c'
	local i=2
	local j=`nrparv'[1,1]+`posp'
	*make sure none of the weights is a function of the data
	while `i'<=colsof(`nrparv') & `cons'==1 {
		local j=`j'+`nrparv'[1,`i']+1
		if `predictv'[1,`j']==0 mat def `c'=(nullmat(`c'),`j')
		else local cons=0
		local i=`i'+1
	}
	*if weights are all constants, try to transform
	if `cons'==1 & inlist(lower("`nrwgttrfunc'"),"&invlogit()","&mexp()","&mabs()","&mneg()")==1 {
		local i=1
		while `i'<=colsof(`c') {
			*position in `par'
			mat def `c'[1,`i']=`posp'*(`nprvar'+1)+(`predictv'[1,`posp'+1..`c'[1,`i']]*`nmvar')*J(`c'[1,`i']-`posp',1,1)+`c'[1,`i']-`posp'
			*transformations
			if "`nrwgttrfunc'"=="&invlogit()" {
				mat def `par'[1,`c'[1,`i']]=invlogit(`par'[1,`c'[1,`i']])
				mat def `v'[1,`c'[1,`i']]=`v'[1...,`c'[1,`i']]*`par'[1,`c'[1,`i']]*(1-`par'[1,`c'[1,`i']])
				mat def `v'[`c'[1,`i'],1]=`v'[`c'[1,`i'],1...]*`par'[1,`c'[1,`i']]*(1-`par'[1,`c'[1,`i']])
				mat def `g'[1,`c'[1,`i']]=`g'[1,`c'[1,`i']]/`par'[1,`c'[1,`i']]*(1-`par'[1,`c'[1,`i']])
				mat def `trf'[1,`c'[1,`i']]=1
			}
			else if "`nrwgttrfunc'"=="&mexp()" {
				mat def `par'[1,`c'[1,`i']]=exp(`par'[1,`c'[1,`i']])
				mat def `v'[1,`c'[1,`i']]=`v'[1...,`c'[1,`i']]*`par'[1,`c'[1,`i']]
				mat def `v'[`c'[1,`i'],1]=`v'[`c'[1,`i'],1...]*`par'[1,`i']
				mat def `g'[1,`c'[1,`i']]=`g'[1,`c'[1,`i']]/`par'[1,`c'[1,`i']]
				mat def `trf'[1,`c'[1,`i']]=1
			}
			else if "`nrwgttrfunc'"=="&mabs()" {
				mat def `v'[1,`c'[1,`i']]=`v'[1...,`c'[1,`i']]*sign(`par'[1,`c'[1,`i']])
				mat def `v'[`c'[1,`i'],1]=`v'[`c'[1,`i'],1...]*sign(`par'[1,`c'[1,`i']])
				mat def `g'[1,`c'[1,`i']]=`g'[1,`c'[1,`i']]*sign(`par'[1,`c'[1,`i']])
				mat def `par'[1,`c'[1,`i']]=abs(`par'[1,`c'[1,`i']])
				mat def `trf'[1,`c'[1,`i']]=1
			}
			else if "`nrwgttrfunc'"=="&mneg()" {
				mat def `v'[1,`c'[1,`i']]=`v'[1...,`c'[1,`i']]*sign(`par'[1,`c'[1,`i']])*(-1)
				mat def `v'[`c'[1,`i'],1]=`v'[`c'[1,`i'],1...]*sign(`par'[1,`c'[1,`i']])*(-1)
				mat def `g'[1,`c'[1,`i']]=`g'[1,`c'[1,`i']]*sign(`par'[1,`c'[1,`i']])/(-1)
				mat def `par'[1,`c'[1,`i']]=abs(`par'[1,`c'[1,`i']])*(-1)
				mat def `trf'[1,`c'[1,`i']]=1
			}
		local i=`i'+1
		}
	local nrwgttrfunc ""
	}
}	

*transformations for mixing parameters
if "`mixtransf'"!="" {
	if wordcount("`mvars'")==0 mat def `pos'=`posp'*(`nprvar'+1)
	else mat def `pos'=`posp'*(`nprvar'+1)+(`predictv'[1,`posp'+1..`b'[1,1]]*`nmvar')*J(`b'[1,1]-`posp',1,1)+`b'[1,1]-`posp'
	local mixtransf2 ""
	local rep=0
	local mixtransf=subinstr("`mixtransf'",","," ",.)
	local trl=wordcount("`mixtransf'")	
	if mod(`trl',3)!=0 {
		di as err "Invalid transformation for parameters of mixture specified"
		exit
	}
	tokenize `mixtransf'
	local i=1
	*loop over transfer fcn
	while `i'<=`trl' {
		local j=`i'+1
		local k=`i'+2
		*position in `predictv'
		mat def `c'=`b'[1,1]+`mixparv'[1,1..``i'']*J(``i'',1,1)-`mixparv'[1,``i'']+max(0,colsof(`mixparv'[1,1..``i''])-2)+``j''
		if `predictv'[1,`c'[1,1]]==0 & (inlist("``k''","&mexp()","&mabs()","&mneg()")==1 | real("``k''")!=.) {
			*position in `par'
			mat def `c'=`pos'[1,1]+(`predictv'[1,`b'[1,1]+1..`c'[1,1]]*`nprvar')*J(`c'[1,1]-`b'[1,1],1,1)+`c'[1,1]-`b'[1,1]
			if `c'[1,1]<=e(k) {
				*transformations
				if real("``k''")!=. {
					mat def `par'[1,`c'[1,1]]=`par'[1,`c'[1,1]]+``k''
					mat def `trf'[1,`c'[1,1]]=1
				}
				if "``k''"=="&mexp()" {
					mat def `par'[1,`c'[1,1]]=exp(`par'[1,`c'[1,1]])
					mat def `v'[1,`c'[1,1]]=`v'[1...,`c'[1,1]]*`par'[1,`c'[1,1]]
					mat def `v'[`c'[1,1],1]=`v'[`c'[1,1],1...]*`par'[1,`c'[1,1]]
					mat def `g'[1,`c'[1,1]]=`g'[1,`c'[1,1]]/`par'[1,`c'[1,1]]
					mat def `trf'[1,`c'[1,1]]=1
				}
				if "``k''"=="&mabs()" {
					mat def `v'[1,`c'[1,1]]=`v'[1...,`c'[1,1]]*sign(`par'[1,`c'[1,1]])
					mat def `v'[`c'[1,1],1]=`v'[`c'[1,1],1...]*sign(`par'[1,`c'[1,1]])
					mat def `g'[1,`c'[1,1]]=`g'[1,`c'[1,1]]*sign(`par'[1,`c'[1,1]])
					mat def `par'[1,`c'[1,1]]=abs(`par'[1,`c'[1,1]])
					mat def `trf'[1,`c'[1,1]]=1
				}	
				if "``k''"=="&mneg()" {
					mat def `v'[1,`c'[1,1]]=`v'[1...,`c'[1,1]]*sign(`par'[1,`c'[1,1]])*(-1)
					mat def `v'[`c'[1,1],1]=`v'[`c'[1,1],1...]*sign(`par'[1,`c'[1,1]])*(-1)
					mat def `g'[1,`c'[1,1]]=`g'[1,`c'[1,1]]*sign(`par'[1,`c'[1,1]])/(-1)
					mat def `par'[1,`c'[1,1]]=abs(`par'[1,`c'[1,1]])*(-1)
					mat def `trf'[1,`c'[1,1]]=1
				}			
			}
		}
		*add any other functions?
		else if `rep'==0 {
			if "`mixtransf2'"!="" local mixtransf2="`mixtransf2',"
			local mixtransf2 "`mixtransf2'``i'',``j'',``k''"
		}
		local i=`i'+3
		mat def `c'=`mixparv'*J(colsof(`mixparv'),1,1)+colsof(`mixparv')-1
		if `rep'>0 mat def `c'[1,1]=`c'[1,1]+1
		mat def `d'=`predictv'[1,`b'[1,1]+1..`b'[1,1]+`c'[1,1]]*`nprvar'*J(`c'[1,1],1,1)+`c'[1,1]
		if (`i'>`trl' & e(k)>`pos'[1,1]+`d'[1,1]) {
			local i=1
			mat def `pos'=`pos'[1,1]+`d'[1,1]
			mat def `b'[1,1]=`b'[1,1]+`mixparv'*J(colsof(`mixparv'),1,1)+colsof(`mixparv')-1
			local rep=`rep'+1
		}
	}
	local mixtransf "`mixtransf2'"
}
*mixture weights
if "`wgttrfunc'"!="" {
	*reset `pos'
	if wordcount("`mvars'")==0 mat def `b'=`posp'
	else mat def `b'=`posp'+`nrparv'*J(colsof(`nrparv'),1,1)+colsof(`nrparv')-1
	if wordcount("`mvars'")==0 mat def `pos'=`posp'*(`nprvar'+1)
	else mat def `pos'=`posp'*(`nprvar'+1)+(`predictv'[1,`posp'+1..`b'[1,1]]*`nmvar')*J(`b'[1,1]-`posp',1,1)+`b'[1,1]-`posp'
	*return error if no weights
*if colsof(`nrparv')<=2 & `rep'==0 { ->why <=`nrparv'?	
	if colsof(`nrparv')<=2 & (colsof(`mixparv')<2 & `rep'==0) {
		di as error "Transformation for weights specified, but model does not seem to include weights in mixture"
		exit
	}
	local i=min(2,colsof(`mixparv'))
	local j=`b'[1,1]+`mixparv'[1,1]
	local cons=1
	mat drop `c'
	*make sure none of the weights is a function of the data
	while `cons'==1 & `j'<colsof(`predictv') {
		local j=`j'+`mixparv'[1,`i']+1
		if `predictv'[1,`j']==0 mat def `c'=(nullmat(`c'),`j')
		else local cons=0
		if `i'==colsof(`mixparv') local i=1
		else local i=`i'+1
	}
	*if weights are all constants, try to transform
	if `cons'==1 & inlist(lower("`wgttrfunc'"),"&invlogit()","&mexp()","&mabs()","&mneg()")==1 {
		local i=1
		while `i'<=colsof(`c') {
			*position in `par'
			mat def `c'[1,`i']=`pos'[1,1]+(`predictv'[1,`b'[1,1]+1..`c'[1,`i']]*`nprvar')*J(`c'[1,`i']-`b'[1,1],1,1)+`c'[1,`i']-`b'[1,1]			
			*transformations
			if "`wgttrfunc'"=="&invlogit()" {
				mat def `par'[1,`c'[1,`i']]=invlogit(`par'[1,`c'[1,`i']])
				mat def `v'[1,`c'[1,`i']]=`v'[1...,`c'[1,`i']]*`par'[1,`c'[1,`i']]*(1-`par'[1,`c'[1,`i']])
				mat def `v'[`c'[1,`i'],1]=`v'[`c'[1,`i'],1...]*`par'[1,`c'[1,`i']]*(1-`par'[1,`c'[1,`i']])
				mat def `g'[1,`c'[1,`i']]=`g'[1,`c'[1,`i']]/`par'[1,`c'[1,`i']]*(1-`par'[1,`c'[1,`i']])				
				mat def `trf'[1,`c'[1,`i']]=1
			}
			else if "`wgttrfunc'"=="&mexp()" {
				mat def `par'[1,`c'[1,`i']]=exp(`par'[1,`c'[1,`i']])
				mat def `v'[1,`c'[1,`i']]=`v'[1...,`c'[1,`i']]*`par'[1,`c'[1,`i']]
				mat def `v'[`c'[1,`i'],1]=`v'[`c'[1,`i'],1...]*`par'[1,`i']
				mat def `g'[1,`c'[1,`i']]=`g'[1,`c'[1,`i']]/`par'[1,`c'[1,`i']]
				mat def `trf'[1,`c'[1,`i']]=1
			}
			else if "`wgttrfunc'"=="&mabs()" {
				mat def `v'[1,`c'[1,`i']]=`v'[1...,`c'[1,`i']]*sign(`par'[1,`c'[1,`i']])
				mat def `v'[`c'[1,`i'],1]=`v'[`c'[1,`i'],1...]*sign(`par'[1,`c'[1,`i']])
				mat def `g'[1,`c'[1,`i']]=`g'[1,`c'[1,`i']]/sign(`par'[1,`c'[1,`i']])				
				mat def `par'[1,`c'[1,`i']]=abs(`par'[1,`c'[1,`i']])
				mat def `trf'[1,`c'[1,`i']]=1
			}
			else if "`wgttrfunc'"=="&mneg()" {
				mat def `v'[1,`c'[1,`i']]=`v'[1...,`c'[1,`i']]*sign(`par'[1,`c'[1,`i']])*(-1)
				mat def `v'[`c'[1,`i'],1]=`v'[`c'[1,`i'],1...]*sign(`par'[1,`c'[1,`i']])*(-1)
				mat def `g'[1,`c'[1,`i']]=`g'[1,`c'[1,`i']]*sign(`par'[1,`c'[1,`i']])/(-1)
				mat def `par'[1,`c'[1,`i']]=abs(`par'[1,`c'[1,`i']])*(-1)
				mat def `trf'[1,`c'[1,`i']]=1
			}

		local i=`i'+1
		}
	local wgttrfunc ""
	}
}	

*clean up and repost coefficients, variance and gradient from ml
mat drop `b' `c' `d' `pos'
ereturn repost b=`par' V=`v', properties(b V svyb svyr svyj)
ereturn matrix gradient `g'			
*display output
mat def `par'=e(b)
mat def `v'=e(V)
local neq=e(k_eq)

di in smcl as text _col(51) "Number of obs" as text _col(67) "=" as res %11.0g e(N)
di in smcl as text _col(51) "Wald chi2(" as res e(df_m) as text ")" _col(67) "=" as res %11.2f e(chi2)
di in smcl as text"Log likelihood = " as res %11.3f e(ll) as text _col(51) "Prob > chi2" _col(67) "=" as res %11.4f e(p) _newline(1)

di in smcl as text "{hline 13}{c TT}{hline 11}{hline 11}{hline 9}{hline 9}{hline 12}{hline 12}"
di in smcl as text `"`true'{col 14}{c |}      Coef.{col 26}   Std. Err.{col 37}      z{col 46}   P>|z|{col 55}    [95% Conf. Interval]"'

local names: coleq `par'
tokenize "`names'"
local names2: colnames `par'
local j=1
foreach i of numlist 1/`neq' {
di in smcl as text "{hline 13}{c +}{hline 11}{hline 11}{hline 9}{hline 9}{hline 12}{hline 12}"
di in smcl as res word("`eqnames'",`i') as text "{col 14}{text}{c |}"
local eq ``j''
while "``j''"=="`eq'" {
gettoken next names2: names2
di in smcl as text cond(`trf'[1,`j']==1,"t","") _col(2) %11s abbrev("`next'",11) _col(14) "{c |}" _col(17) as res %9.0g `par'[1,`j'] _col(28) %9.0g sqrt(`v'[`j',`j']) _col(38) %8.2f cond(`trf'[1,`j']==1,.,`par'[1,`j']/sqrt(`v'[`j',`j']))  _col(49) %4.3f cond(`trf'[1,`j']==1,.,2*(1-normal(abs(`par'[1,`j']/sqrt(`v'[`j',`j']))))) _col(58) %9.0g cond(`trf'[1,`j']==1,.,`par'[1,`j']-1.96*sqrt(`v'[`j',`j'])) _col(70) %9.0g cond(`trf'[1,`j']==1,.,`par'[1,`j']+1.96*sqrt(`v'[`j',`j']))
local j=`j'+1
}
}
*add diparam options if there are any?

di in smcl as text "{hline 13}{c BT}{hline 11}{hline 11}{hline 9}{hline 9}{hline 12}{hline 12}"

**write program
*define option write
/*just some ideas for raw structure
if lower("`write'")=="write" {
*1. write syntax of medens without options that are not requires, always the same -->from file or paste here?
*2. define parameter vector, mixfunc, mixpar,mppar, loc,mpfunc,nrfunc,nrpar,mixtransf,nrtransf,wgtrfunc from locals and matrices (& whatever else conddens will need)
*	->also check range of `obs' to avoid it being >e(max) or <e(min)
*3. copy remainder of stata code, no changes
*4. write main mata function? or add to mlib?->should always be the same
*5. write mata functions for transformations and generating random draws or add to mlib. do some capture block and list the ones that could not be added, so user can add them manually.
*	a. create mlib file (in case doesn't exist from 4.): mata mlib create lmedens
	for each function handle:
	b. check whether already in mlib (how?) or one of the standard functions (how?)
	c. if not, try to add using mata mlib add lmedens functionname()
	d. check which error this returns: built in or not in memory but working-> write m<functionname> and add?
	e. if none of the above work, make note of function and ask user to add manually
*6. write help file?-> include syntax, etc. that will always be included, list files needed, variables needed
}
*/

*test conditional mean
if `"`cmplot'"'!="" {
	if "`model'"=="" | ("`nrmodel'"=="" & `nrparv'[1,1]!=0) {
		di as err "Could not do the conditional mean plot, since it currently only works for conditional distributions specified by option model(). Sorry."
		/*see tests.do for some attempts to implement this more generally (simulate conditional mean? loop over mixture components?*/
	}
	else {
		*get equation numbers for predict
		*masspoint
		if "`masspoint'"!="" local i=1
		else local i=0
		*nr
		if "`nrmodel'"!="" {
			if "`nrmodel'"=="normal" {
				local eqno "`i'+1 "
				local i=`i'+2
				mat def `w'=1
			}	
			if "`nrmodel'"=="mixnorm" {
				local eqno "`i'+1 `i'+3 "
				local i=`i'+5
				mat def `w'=(1-[#`i']_b[_cons],[#`i']_b[_cons])
			}			
			if "`nrmodel'"=="trnorm" {
				local eqno "`i'+1 "
				local i=`i'+4
				mat def `w'=1
			}	
			if "`nrmodel'"=="mixtrnorm" {
				local eqno "`i'+1 `i'+5 "
				local i=`i'+8
				mat def `w'=(1-[#`i']_b[_cons],[#`i']_b[_cons])
			}
			if "`nrmodel'"=="ltrnorm" | "`nrmodel'"=="rtrnorm" {
				local eqno "`i'+1 "
				local i=`i'+3
				mat def `w'=1
			}	
			if "`nrmodel'"=="mixltrnorm" | "`nrmodel'"=="mixrtrnorm" {
				local eqno "`i'+1 `i'+4 "
				local i=`i'+6
				mat def `w'=(1-[#`i']_b[_cons],[#`i']_b[_cons])
			}			
			if "`nrmodel'"=="exp" {
				local eqno "`i'+2"
				local i=`i'+2
				mat def `w'=1
			}	
			if "`nrmodel'"=="mixexp" {
				local eqno "`i'+2 `i'+4 "
				local i=`i'+5
				mat def `w'=(1-[#`i']_b[_cons],[#`i']_b[_cons])
			}	
			if "`nrmodel'"=="weibull" {
				local eqno "`i'+3 "
				local i=`i'+3
				mat def `w'=1
			}
			if "`nrmodel'"=="mixweibull" {
				local eqno "`i'+3 `i'+6 "
				local i=`i'+7
				mat def `w'=(1-[#`i']_b[_cons],[#`i']_b[_cons])
			}
			if "`nrmodel'"=="t" {
				local eqno "`i'+1 "
				local i=`i'+3
				mat def `w'=1
			}
			if "`nrmodel'"=="mixt" {
				local eqno "`i'+1 `i'+4 "
				local i=`i'+7
				mat def `w'=(1-[#`i']_b[_cons],[#`i']_b[_cons])
			}
			if "`nrmodel'"=="mixweit" {
				local eqno "`i'+1 `i'+4 "
				local i=`i'+7
				mat def `w'=(1-[#`i']_b[_cons],[#`i']_b[_cons])
			}

		}
		
		*me
		if "`model'"=="normal" | "`model'"=="t"| "`model'"=="trnorm" | "`model'"=="ltrnorm" | "`model'"=="rtrnorm" {
			local eqno "`eqno'`i'+1"
			mat def `w'=(nullmat(`w'),1)
		}
		if "`model'"=="mixnorm" {
			local eqno "`eqno'`i'+1 `i'+3"
			mat def `w'=(nullmat(`w'),1-`par'[1,colsof(`par')],`par'[1,colsof(`par')])
		}
		if "`model'"=="mixtrnorm" {
			local eqno "`eqno'`i'+1 `i'+5"
			mat def `w'=(nullmat(`w'),1-`par'[1,colsof(`par')],`par'[1,colsof(`par')])
		}		
		if "`model'"=="exp" {
			local eqno "`eqno'`i'+2"
			mat def `w'=(nullmat(`w'),1)
		}
		if "`model'"=="mixexp" {
			local eqno "`eqno'`i'+2 `i'+4"
			mat def `w'=(nullmat(`w'),1-`par'[1,colsof(`par')],`par'[1,colsof(`par')])
		}
		if "`model'"=="weibull" {
			local eqno "`eqno'`i'+3"
			mat def `w'=(nullmat(`w'),1)
		}
		if "`model'"=="mixweibull" {
			local eqno "`eqno'`i'+3 `i'+6"
			mat def `w'=(nullmat(`w'),1-`par'[1,colsof(`par')],`par'[1,colsof(`par')])
		}
		if "`model'"=="mixt" | "`model'"=="mixltrnorm" |"`model'"=="mixrtrnorm" {
			local eqno "`eqno'`i'+1 `i'+4"
			mat def `w'=(nullmat(`w'),1-`par'[1,colsof(`par')],`par'[1,colsof(`par')])
		}
		if "`model'"=="mixweit" {
			local eqno "`eqno'`i'+1 `i'+4"
			mat def `w'=(nullmat(`w'),1-`par'[1,colsof(`par')],`par'[1,colsof(`par')])
		}
		*get conditional mean
		tempvar mean condmean mp
		tokenize `eqno'
		if "`masspoint'"!="" {
			qui: predict `mp' if `touse' & `obs'!=., eq(#1)
			qui: replace `mp'=$mixmp if `touse' & `obs'!=.
			qui: replace `mp'=0  if `touse' & `obs'==.
			qui: gen `condmean'=`mp'*`obs' if `touse' & `obs'!=.
			qui: replace `condmean'=0 if `touse' & `obs'==.
		}	
		else {
			qui: gen `mp'=0  if `touse'
			qui: gen `condmean'=0 if `touse'
		}
		local if "if `obs'==."
		local j=1
		while "``j''"!="" {
			local `j'=``j''
			if ``j''>=`i' local if "if `obs'!=."
			qui: predict `mean'`j' `if' & `touse', eq(#``j'')
			if (``j''<`i' & ("`nrmodel'"=="exp" | "`nrmodel'"=="mixexp")) | (``j''>`i' & ("`model'"=="exp" | "`model'"=="mixexp")) {
				local k=``j''-1
				qui: replace `condmean'=`condmean'+(1-`mp')*`w'[1,`j']*([#`k']_b[_cons]+1/`mean'`j') `if' & `touse'
			}
			else if (``j''<`i' & ("`nrmodel'"=="weibull" | "`nrmodel'"=="mixweibull")) | (``j''>`i' & ("`model'"=="weibull" | "`model'"=="mixweibull"))  {
				local k=``j''-1
				local l=``j''-2
				qui: replace `condmean'=`condmean'+(1-`mp')*`w'[1,`j']*([#`l']_b[_cons]+`mean'`j'*exp(lngamma(1+1/[#`k']_b[_cons]))) `if' & `touse'
			}	
			else if (``j''<`i' & ``j''>3 & "`nrmodel'"=="mixweit") | (``j''>`i'+3 & "`model'"=="mixweit") {
				local k=``j''+1
				local l=``j''+2
				qui: replace `condmean'=`condmean'+(1-`mp')*`w'[1,`j']*([#`l']_b[_cons]*exp(lngamma(1+1/[#`k']_b[_cons]))) `if' & `touse'
			}
			else if (``j''<`i' & ("`nrmodel'"=="trnorm" | "`nrmodel'"=="mixtrnorm")) | (``j''>`i' & ("`model'"=="trnorm" | "`model'"=="mixtrnorm"))  {
				local k=``j''+1
				local l=``j''+2
				local m=``j''+3
				qui: replace `condmean'=`condmean'+(1-`mp')*`w'[1,`j']*(`mean'`j'+([#`k']_b[_cons])^2*(normalden([#`l']_b[_cons],`mean'`j',[#`k']_b[_cons])-normalden([#`m']_b[_cons],`mean'`j',[#`k']_b[_cons]))/(normal(([#`m']_b[_cons]-`mean'`j')/[#`k']_b[_cons])-normal(([#`l']_b[_cons]-`mean'`j')/[#`k']_b[_cons]))) `if' & `touse'
			}
			else if (``j''<`i' & ("`nrmodel'"=="ltrnorm" | "`nrmodel'"=="mixltrnorm")) | (``j''>`i' & ("`model'"=="ltrnorm" | "`model'"=="mixltrnorm"))  {
				local k=``j''+1
				local l=``j''+2
				qui: replace `condmean'=`condmean'+(1-`mp')*`w'[1,`j']*(`mean'`j'+([#`k']_b[_cons])^2*normalden([#`l']_b[_cons],`mean'`j',[#`k']_b[_cons])/(1-normal(([#`l']_b[_cons]-`mean'`j')/[#`k']_b[_cons]))) `if' & `touse'
			}
			else if (``j''<`i' & ("`nrmodel'"=="rtrnorm" | "`nrmodel'"=="mixrtrnorm")) | (``j''>`i' & ("`model'"=="rtrnorm" | "`model'"=="mixrtrnorm"))  {
				local k=``j''+1
				local l=``j''+2
				qui: replace `condmean'=`condmean'+(1-`mp')*`w'[1,`j']*(`mean'`j'-([#`k']_b[_cons])^2*normalden([#`l']_b[_cons],`mean'`j',[#`k']_b[_cons])/normal(([#`l']_b[_cons]-`mean'`j')/[#`k']_b[_cons])) `if' & `touse'
			}			
			else qui: replace `condmean'=`condmean'+(1-`mp')*`w'[1,`j']*`mean'`j' `if' & `touse'
			local j=`j'+1
		}
		drop `mean'* `mp'
		matrix drop `w'
		_pctile `condmean' if `touse', p(0.2,99.8)		
		local i=r(r1)
		local j=r(r2)
		if strmatch("`weight'","fw*")==1 | strmatch("`weight'","aw*")==1 lpoly `true' `condmean' if `touse' [`weight' `exp'], degree(0) ci addplot(scatteri `i' `i' `j' `j' if `touse', recast(line)) legend(label(3 "45-Degree-Line")) xtitle(Conditional Mean) `cmpopts'
		else {
			if "`weight'"!="" di as res "lpoly only accepts fweights and aweights, performing unweighted regression"
			lpoly `true' `condmean' if `touse', degree(0) ci addplot(scatteri `i' `i' `j' `j' if `touse', recast(line)) legend(label(3 "45-Degree-Line")) xtitle(Conditional Mean) `cmpopts'
		}	
		drop `condmean'
		ereturn scalar degree=`r(degree)'
		ereturn scalar ngrid=`r(ngrid)'
		ereturn scalar bwidth=`r(bwidth)'
		ereturn scalar pwidth=`r(pwidth)'
		ereturn local kernel `r(kernel)'
	}
}

*other output
*things required for medens
ereturn local mixfunc "`mixfunc'"
ereturn local mixtransf "`mixtransf'"
ereturn local wgttrfunc "`wgttrfunc'"
ereturn local mpfunc "`mpfunc'"
ereturn local nrfunc "`nrfunc'"
ereturn local nrtransf "`nrtransf'"
ereturn local nrwgttrfunc "`nrwgttrfunc'"
ereturn local mvars "`mvars'"
ereturn local obs "`obs'"
ereturn local pred "`pred'"

ereturn matrix predictors `predictors'
ereturn matrix predict `predictv'
ereturn matrix mixpar `mixparv'
ereturn matrix nrpar `nrparv'
ereturn matrix b_o `ao'
ereturn matrix V_o `vo'

*other
sum `obs' if `touse', meanonly
ereturn scalar min=`r(min)'
ereturn scalar max=`r(max)'

*clean up
mat drop `par' `v' `trf'
if "`macrokeep'"=="" macro drop mixmp
return clear

ereturn local cmd "conddens"
end
/*
***information needed for output:
par->parameter vector
mixfunc -> function handles for mixing density, repeated to fit parameter vector-> needed if writing program for user defined fcn
mixpar-> number of parameters components of mixfunc take as inputs, repeated to fit parameter vector-> needed if writing program for user defined fcn
mppar-> 0/1 whether there is a masspoint at true=obs ->masspoint->always optional, only used with user defined fcn

loc vector to set up ml model (0 if cons, 1 if xb)-> needed for user defined fcn->`predictv'
optional: equation names->always optional, only used for user defined fcn->eqnames

*optional if there is a mp
mpfunc-> transformation that turns xb/cons of mp into probability true=obs -> needed if writing program for user defined fcn

*needed if there is nr
nrfunc->function handles for mixing of nr densities-> needed if writing program for user defined fcn
nrpar-> number of parameters for nr functions-> needed for user defined fcn

*always optional-> all only needed if writing program for user defined fcn
mixtransf->transformation of parameters of mixfunc
nrtransf->transformation of parameters of nrfunc
wgttrfunc -> transformation of parameters of mixing weights
mrwgttrfunc -> transformation of nr weights

***Notes & comments

***things to think about
*how to deal with parameters at boundary of parameter space: location parameters in exp, weibull (min(xstar)), df in t (inf & 1)
*use outer product of gradient for variance matrix?
*any other checks at beginning of program?
*specifying likelihood by option: replace `, $ in *lik by \`,\$?
*specify repeat() with ml search? allow option?
*better way to find good starting values? use rss for t and normal? Better way for mixtures than to start both at same values? Any for exp, weibull, etc?
*use markout to set sample?

**random stuff
*Add other weight or parameter transformation functions??
*think about way to add/display confidence intervals, z-value, etc when parameters are transformed (currently not displayed)
*other output required for medens?
*use mpfunc in mixmp to set up likelihood? or always use invlogit() unless user writes own program?->check if it works, need to change in help file: mpfunc is normal by default, but can be specified as, say, mpfunc(invlogit) (mpfunc(invlogit()) should also work)
*allow masspoint to be a constant (0 in `predictv')? or only w/ user defined prog?->can do this by constraints
*add diparm options to displayed table?
*conddens returns nrpar, mixpar, predict as matrices, conddens accepts strings, check compatibility
*`nrparv'[1,1]==0 -> no nr -> need to allow as real option?

***things to check/keep an eye on
**theory issues
*check transformation of variance for invlogit(). 
*want to make location parameter of weibull and exp function of the data??-> harder to make sure p=0 if x<loc.->conddens_try wloc.ado for an attempt

**things that seem to work, but should be kept in mind
*transformations only work for 2 component mixtures, need to add code that skips position of weights in `predictv', a->check if it works
*need to stop mixtr loop if `pos'[1,1] exceeds length of a (in case mixpar is repeated, but not completely)->check if it works
*need to add colsof(mixpar)-1 if ``i''>2 for weights->check if this works
*check predictors -> does it work (with "cons"?), make sense? easier way to set it up?

**stuff that may or may not work
*check whether all distributions work (particularly weibull, exp and t)
*transformations for more than 2 weights, test for all functions
*check all options, add options to define model() manually->check if they work
*figure out best way for model() and manual options to interact: see description below (can specify predict and eqnames to override model, but model overrides everything else->check if it works
*abs() vs. exp() for positive parameters -> looks like exp() works better...
*default model for nr if variables specified, but no model->only overrides manual specification if nrpar not specified->check if works and makes sense
*check defaults if model not specified->defaults to "mixnorm" if predict or mixpar are missing->check if it works and makes sense
*how to define function handles: rnormal or &rnormal()?-> change in `model' loop if former->w/o &,() seems easier, but would cause trouble with transformations->currently staying w/ &rnormal()
*allow for svy: option->check if it works
*cmp for truncated normals

***things to do
*expand on "write" part
*implement procedures to assess fit of distribution (cross validation?->least squares (how?) vs. likelihood (large influence of tails) CV)
*cmplot: think about formal test (Haerdle & Horowitz?)
*understand if statement before "model does not seem to include..." (break when transforming mixture weights
*cmplot: ignores additional legend(label) options ->change that?
*add "search" and "macrokeep" options to help file

*truncated normal:
add mixtures of truncated normals: truncation from both sides and right side doesn't work well for mixture, but is left there to use with constraints->add to help file
check whether initial values for sigmas make any sense->add to other models?


***info
default for nrmodel is normal (if missing specified, but no model)
if missing not specified, parameters in nrmodel are constants
need to specify both functions in mixpar if one has different transformations
in results table t in first col indicates that parameter has been transformed-> no z-value, ci, can get original ones by using ml display->nope, gives transformed parameters
same variables predict all parameters for cond, to exclude some, specify constraints and pass them to ml using constraints() in modelopts()
same for non-response, all variables in missing() predict all parameters. Can change as above.
model() overrides all advanced options (par,func,tr,wgttr,args,lik), but predict and eqnames override model (allows user to change which parameters are predicted w/ standard models)
model() only works if likprog=="conddens"
need at least one parameter predicted by data (otherwise ml does not know dependent variable, could pass it as global)
currently cannot use init with option copy, need to use equation:par syntax
t-distribution is constrained to df>=1->can cause boundary problems with ml
models: normal->normal w/mean as fcn of X
	normix->mix of 2 normals w/mean as fcn of X
	exp->exponential with location parameter->eloc is location parameter, constrained to be bigger `r(min)'
	expmix->mixture of exponentials with location parameter->see exp
	t->generalized t distribution with location xb1, scale lambda1 and degrees of freedom df1
	mixt->mixture of two of the above
	weibull
	mixweibull
	mixweit
nrmodels:
	normal->normal w/ mean fcn of `missing'
	normix->mixture of two normals w/ mean fcn of `missing
	exp->exponential with location parameter->see exp
	mixexp->mixture of exponentials with location parameter->see exp
	t->generalized t distribution with location xb1, scale lambda1 and degrees of freedom df1
	mixt->mixture of two of the above
	weibull
	mixweibull
	mixweit
*/
