*!version 2.1 Zhiqiang Wang 20Jun2006
* version 2.0 Z.WANG  19Jan2006
* version 1.0 Z.WANG  04May2000

program define confall, nclass
version 7.0
syntax [, XFormat(string) EForm1 EForm2(str) Model Symbol(passthru) /*
	*/ YTItle(passthru) Table SHOWVar(str) /*
	*/ saving(passthru) XIS(string) /*
	*/ Level(real 95) addaic addbic SAVEFile(str) Format(str) LOckterms(varlist) * ] 
if "`e(cmd)'"=="" {
	di in r "last estimates not found"
	exit 301
}
if index(`"clogitlogisticpoissonprobitregress"', `"`e(cmd)'"')>0 {
	local cmd "`e(cmd)'"
	local yvar "`e(depvar)'"
}
if "`e(cmd)'"=="cox" {
	if "`e(cmd2)'"!="" {
		local cmd `e(cmd2)'
		local yvar
	} 
	else {
		di in gr "Please use stcox instead of cox in estimation command."
  		exit 199
	}
}
if `"`e(cmd2)'"'==`"streg"' {
	local dist `"dist(`e(cmd)')"' 
	local cmd `e(cmd2)'
	local yvar
} 
if "`cmd'"==""{
	di in w "`e(cmd)' " in gr "not supported by " in w "confall"
	di in gr _con `"Current"' in w `" z20"' in gr `" only supports "' 
	di in w  _con "logit logistic poisson stcox streg" 
	di in gr `" and"' in w " probit" in gr "."
	exit 199
}
if "`e(offset)'"!="" {
	tempvar off 
	gen `off'=`e(offset)'
	lab var `off' "`e(offset)'"
	local offset offset(`off')
}
if "`e(vcetype)'"!="" { 
	local robust r
}
if "`e(clustvar)'"!="" {
	local cluster cluster(`e(clustvar)')
}
if "`e(group)'"!=""{
	local grpclog group(`e(group)')
} 
local ops `offset' `robust' `cluster' `dist' `grpclog'
if "`xis'"==""{ 
	local xis p
}
if index(" r2 n aic civ mp bic p pr ", " `xis' ")==0  {
	di in r "X axis is not correctly specified"
	exit
}  
local zlevel=invnorm(`level'/100+(1-`level'/100)/2)
if "`eform1'"~="" & "`eform2'"~="" {
	di in red "may not specify both eform and eform()"
	exit 198
}
if "`eform1'"!="" | "`eform2'"!="" {
	local eform eform 	
	if "`eform2'"!="" {
		local elabel "`eform2'"
	}	
	else {
		local elabel "Exp(Coef.)"
	}
}
else {
	local elabel "Coef."
}
if "`ytitle'"=="" {
	local ytitle ytitle("`elabel'")
}
qui {
	tempvar smpl
	gen `smpl'=e(sample)
	mat bs=e(b) 
	local xnames : colnames(bs) 
	gettoken x xnames : xnames
	if "`lockterms'"!="" {
		_newx, xvar(`xnames') pick(`lockterms')
		local xnames `r(newlst)'
	}
	_xnam `xnames'
	local xnames `r(alln)'
	local vnum = wordcount("`xnames'")
	local factn = `r(factn)'  
	token `xnames'
	if length("`xnames'")>80 { 
		local nolab *
		noi di in b "Variable labels cannot be displayed"
	}
	else {
		local hasnum *
	}
	preserve
	keep if `smpl'
	set more off
	global T=ln(_N)
	local nsubset=int(2^`vnum')+1
	if `nsubset' > _N {
		cap set obs `nsubset'
		if _rc!=0 {
			noi di "Please set memory"
			exit
		}
	}
	tempvar b se se1 se0 b0 baicm bbicm aic bic bfull pv ncov r2 civ llv ulv orderv selectv
	gen `se1'=. 
	lab var `se1' "1/Variance"
	local order=1
	`cmd' `yvar' `x' `lockterms', `ops' 
	local aicm=-2*e(ll)+2*(e(df_m)+`factn') 
	local bicm = -2 * e(ll) + $T* (e(df_m) + `factn')
	local z=_b[`x']/_se[`x']
	if `z'>=0 {
		local p=(1-normprob(`z'))*2
	}
	else {
		local p=normprob(`z')*2
	}
	local se=_se[`x']
	if "`eform'"!=""{
		local crude=exp(_b[`x'])
		local ul=exp(_b[`x']+`zlevel'*`se')
		local ll=exp(_b[`x']-`zlevel'*`se')
	}
	else {
		local crude=_b[`x'] 
		local ul=_b[`x']+`zlevel'*`se'
		local ll=_b[`x']-`zlevel'*`se'
	}
	gen `llv'=`ll' if _n==1
	gen `ulv'=`ul' if _n==1
	lab var `llv' "[`level'% Conf."
	lab var `ulv' "Interval]"
	gen `b0' = `crude' if _n==1 
	lab var `b0' "Crude"
	gen `b' = `crude' if _n==1 
	lab var `b' "`elabel'"
	replace `se1'=1/(_se[`x']*_se[`x']) if _n==1 
	if "`xis'"=="civ" {
		gen `civ'=`ul'-`ll' if _n==1
		lab var `civ' "`level'% CI range"
	}	
	if "`xis'"=="aic" {
		gen double `aic'=`aicm' if _n==1
		lab var `aic' "AIC"
	}
	if "`xis'"=="bic" {
		gen double `bic'=`bicm' if _n==1
		lab var `bic' "BIC"
	}
	if "`xis'"=="n" {
		gen double `ncov'=0 if _n==1
		lab var `ncov' "no. of confounders"
	}		
	if "`xis'"=="r2" {
		if scalar(e(r2_a))!=. {
			gen `r2'=scalar(e(r2_a)) if _n==1
		}
		else { 
			gen `r2'=scalar(e(r2_p)) if _n==1
		}
		lab var `r2' "R squared"
	}
	if "`xis'"=="p" | "`xis'"=="pr" {
		gen double `pv'=`p' if _n==1
		lab var `pv' "P value"
	}		
	gen double `baicm'=`crude' if _n==1
	gen double `bbicm'=`crude' if _n==1
	if "`showvar'"!=""{
		gen byte `selectv'=.	
	}	
	`nolab' label define indicat 1 "Null"
	gen `orderv'=_n if _n<=`nsubset'
	noi di in b "Please wait" _con
	local vnum=wordcount("`xnames'")
	local k=1
	while `k' <= `vnum'{ 
		local lkf=-1
		while `lkf' < 1 {
			local xvec " "
			local indic " "
			mktry `vnum' `k' `lkf'	
			local i=1
			while `i' <= `vnum' {
				local li=L[1,`i']
				local i=`i'+1
				local xvec `xvec' ``li''
				local indic `indic'.`li'
			}
			local lkf = r(kf)
			if `lkf'!=1 {
				`cmd' `yvar' `x' `lockterms' `xvec', `ops'
				local z=_b[`x']/_se[`x']
				if `z'>=0 {
					local p=(1-normprob(`z'))*2
				}  
				else {
					local p=normprob(`z')*2
				}
				local est=_b[`x']
				local ul=`est'+`zlevel'*_se[`x']
				local ll=`est'-`zlevel'*_se[`x']
				if "`eform'"!=""{
					local est=exp(`est')
					local ll=exp(`ll')
					local ul=exp(`ul')
				}
				local  order=`order'+1 
				`nolab' label define indicat `order' "`xvec'", a
				`hasnum' label define indicat `order' "`indic'", a 
				local aic1=-2*e(ll)+2*(e(df_m)+`factn') 
				local bic1=-2*e(ll) + $T* (e(df_m) + `factn')
				replace `b' = `est' if _n==`order' 
				replace `se1'=1/(_se[`x']*_se[`x']) if _n==`order' 
				replace `llv'=`ll' if _n==`order'
				replace `ulv'=`ul' if _n==`order'
				if "`xis'"=="p" | "`xis'" == "pr" {
					replace `pv'=`p' if _n==`order'
				}					
				if "`xis'"=="aic" {
					replace `aic'=`aic1' if _n==`order' 
				}
				if "`xis'"=="bic" {
					replace `bic'=`aic1' if _n==`order' 
				}
				if "`xis'"=="n" {
					replace `ncov'= `k' if _n==`order'	
				}
				if "`xis'"=="civ" {
					replace `civ' = `ul'-`ll' if _n==`order'
				}		
				if "`xis'"=="r2" {
					if scalar(e(r2_a))!=. {
						replace `r2'=scalar(e(r2_a)) if _n==`order'
					}
					else { 
						replace `r2'=scalar(e(r2_p)) if _n==`order'
					}
				}
				if "`addaic'"!="" {
					if `aic1' < `aicm'{
						local aicm=`aic1'
						local mvec "`xvec'"
						cap drop `baicm'
						gen `baicm'=`est' if _n==`order'
					}
				}
				if "`addbic'"!="" {
					if `bic1' < `bicm'{
						local bicm=`bic1'
						local mvec "`xvec'"
						cap drop `bbicm'
						gen `bbicm'=`est' if _n==`order'
					}
				}				
				if "`showvar'"!=""{
					replace `selectv'=index("`xvec' ", "`showvar'")>0 if _n==`order'	
				}	
				
			}
		}
		local k=`k'+1
		noi di in b _con "."
	}
	lab var `baicm' "Min. AIC"
	lab var `bbicm' "Min. BIC"
	gen `bfull'=`est' if _n==`order'
	lab var `bfull' "Adjusted for all" 
	if "`xis'"=="pr" {
		replace `pv'=`pv'^.23137821 
		local prxlab xlab(0 .1187 ".0001" .2022 ".001" .3445 ".01" 0.5 ".05" .587 ".1" .6891 ".2" .8518 ".5" 1) xline(0.5,lpattern(dash))
	}
	if "`xis'" == "p" | "`xis'" == "pr" {
		local xforgr "`pv'"
	}
	if "`xis'" == "n" {
		local xforgr "`ncov'"
	}
	if "`xis'" == "aic" {
		local xforgr "`aic'"
	}
	if "`xis'" == "bic" {
		local xforgr "`bic'"
	}
	if "`xis'" == "r2" {
		local xforgr "`r2'"
	}
	if "`xis'" == "civ" {
		local xforgr "`civ'"
	}
	if "`showvar'"!=""{
		tempvar showvar1 
		gen `showvar1' = `b' if `selectv'==1
		lab var `showvar1' "With `showvar'"
	}	

	* graph 
	cap  format `b' `baicm' `bbicm' `b0' `bfull' `format' 
	cap  format `xforgr' `xformat' 
	if "`addaic'"=="" {
		local baicm "" 
	}
	if "`addbic'"=="" {
		local bbicm "" 
	}		

	`nolab' lab val `orderv' indicat
	keep in 1/`order'
	lab var `orderv' "Var.adj." 
}


scatter  `b' `showvar1' `baicm' `bbicm' `b0' `bfull' `xforgr', `saving' `options' `ytitle' `prxlab'

qui count if `xforgr'!=.
local rownum = `r(N)'

if "`savefile'" !=""{
	keep `orderv' `b' `llv' `ulv' `xforgr' `showvar1'
	save `savefile'
}

if "`table'"!="" {
	if "`format'"!="" {
		local format1 = "format(`format')"
	}
	if `rownum'> 3000 {
		di
		di in r "Table cannot be displayed. Please use" in w " savefile(filename) " in r "option"
	}
	else { 		
		tabdisp `orderv', cell(`b' `llv' `ulv') `format1'
	}	
}
di 
if "`lockterms'"!="" {
	di as input " `lockterms'" as text " in all models"
}
di as result `r(N)' as text " sets of confounders"  
di as text `"Outcome variale: `yvar'      Exposure: `x'"' 

end

program define mktry, rclass
	version 6.0
	args n k ind
	if `ind' < 0  {
		matrix L = J(1,`k',0)
		local i=1
		while `i' <= `k' {
			matrix L[1,`i']=`i'
			local i=`i'+1
		}
		return scalar kf=0
		exit 
	}
	if L[1,1] == `n'-`k'+1 {
		return scalar kf=1
		exit 
	}
	if  L[1,`k']<`n' {
		matrix L[1,`k']= L[1,`k']+1
		return scalar kf=0
		exit 
	}
	local i=`k'
	while `i' > 1 {
		local i = `i'-1
		if L[1,`i'] < `n'-`k'+`i'  {
			matrix L[1,`i'] =  L[1,`i']+1
			local j = `i'
			while `j' < `k'  {
				local j=`j'+1
				matrix L[1,`j']= L[1,`j'-1]+1
			}
			local i = 1    
		}
		return scalar kf=0
	}
end

program define _ab, rclass
	token `0', parse(" _")
	unab cat: _`2'*
	return local cname "_`2'*"
	token `cat'
	local i = 1
	while "``i''" != ""{
		local i = `i'+1
	}
	return scalar catdf=`i'-1
end

program define _xnam, rclass
	local factn=0
	while "`1'"!=""{  
		if "`1'" != "_cons" {
			local xlist `xlist' `1'
		}	
		else {
			local factn=`factn'+1
		}
		mac shift
	}
	token `xlist'
	local i=1 
	while "`1'"!=""{
		local f12 = substr("`1'", 1, 2)
		if "`f12'"=="_I"{
			_ab `1'
			local catdf=r(catdf)
			local xnam`i' `r(cname)'
			mac shift `catdf'
		}
		else {
			local xnam`i' `1'
			mac shift
		}
		local alln `alln' `xnam`i''
		local i=`i'+1
	}
	return local alln `alln'
	return local vnum=`i'-1
	return local factn `factn'
end  

program define _newx, rclass
	syntax [, Xvar(str) Pick(str)]  
	token `xvar'
	while "`1'" != "" {
		if  strpos(" `pick' ", " `1' ")==0 {
			local newlst "`newlst' `1'"
		}
		mac shift
	}
	return local newlst `newlst'
end
