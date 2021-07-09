*! version 2.0 Zhiqiang WANG  19Jan2006
*  version 0.1 Zhiqiang WANG 01June2000
program define confnd, eclass
	version 7.0
	syntax [, Forward  EForm1 EForm2(str) Level(real 95) T2title(passthru) /*
	*/ noGRaph Vertic SAVing(passthru) lockterms(varlist) format(str) * ]
	local yvar "`e(depvar)'"
	if "`e(cmd)'"=="" {
		di in r "last estimates not found"
		exit 301
	} 
	if index(`"clogit logistic poisson probit regress"', `"`e(cmd)'"')>0 {
		local cmd "`e(cmd)'"
		local yvar1 yvar(`yvar')
	}    
	if "`e(cmd)'"=="cox" {
		if "`e(cmd2)'"!="" {
			local cmd `e(cmd2)'
			local yvar1
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
		local yvar1
		local yvar
	} 
	if "`cmd'"==""{
		di in w "`e(cmd)' " in gr "not supported by " in w "swaic"
		di in gr _con `"Current"' in w `" confnd"' in gr `" only supports "' 
		di in w  _con "logit logistic poisson stcox streg clogit regress" 
		di in gr `" and"' in w " probit" in gr "."
		exit 199
	}
	if "`e(offset)'"!="" {
		tempvar off 
		gen `off'=`e(offset)'
		lab var `off' "`e(offset)'"
		local offset offset(`off')
	}
	if "`e(vcetype)'"~="" { 
		local robust r
	}
	if "`e(clustvar)'"~="" {
		local cluster cluster(`e(clustvar)')
	}
	if "`e(wtype)'"!=""{
		local weight "[`e(wtype)'`e(wexp)']" 
		local wt "weight(`weight')"
	}
	if "`e(group)'"!=""{
		local grpclog group(`e(group)')
	} 
	local ops `offset' `robust' `cluster' `dist' `grpclog'

	local z=invnorm(`level'/100+(1-`level'/100)/2)

	if "`eform1'"~="" & "`eform2'"~="" {
		di in red "may not specify both eform and eform()"
		exit 198
	}
	if "`eform1'"!="" | "`eform2'"!="" {
		local eform eform
		local elabel "`eform2'"
	}

	tempvar smpl
	qui gen `smpl'=e(sample)
	mat bs=e(b) 
	local xnames : colnames(bs) 
	if "`lockterms'"!="" {
		_newx, xvar(`xnames') pick(`lockterms')
		local xnames `r(newlst)'
		local locktm lockterms(`lockterms')
	}
	
	_xnam `xnames'

	local xnames `r(alln)' 

	gettoken xvar xnames:xnames
	token `xnames'
*count variable numbers when 
*	local vnum = wordcount("`xnames'")
	local vnum=0
	foreach vinlist of local xnames {
		local vnum=`vnum'+1
	}
	di in gr "Change-in-estimate"
	di in gr "`cmd' regression. `dist'" _col(40) "Outcome:  `yvar'" 
	di in gr "number of obs = " in ye e(N) in gr _col(40) "Exposure: `xvar'" 
	if "`forward'"==""{
		qui `cmd' `yvar' `xvar' `lockterms' `xnames' `weight' if `smpl', `ops'
		local b0=_b[`xvar']
		local se0=_se[`xvar']
		local eff0=cond(`"`eform'"'==`""', `b0', exp(`b0'))  
		local estart=`eff0'
		local i=1
		local xs `xnames'
		while `i'<=`vnum'{
			local i_1=`i'-1
			_stepb, `yvar1' xvar(`xvar') `locktm' cov(`xs') cmd(`cmd') smpl(`smpl') /*
			*/ eff0(`estart') `wt' `eform' `ops' 
			local pv`i' `r(pv)'
			local b`i'=`r(bm)'
			local eff`i'=`r(effm)'
			local vlist`i' `r(mlist)'
			local se`i' = `r(sem)'
			local chg`i'=`r(chg)'
			_newx, xvar(`xs') pick(`r(pv)')
			local estart = `eff`i''
			local xs `r(newlst)'
			local i=`i'+1
		}
	}
	else {
		qui `cmd' `yvar' `xvar' `lockterms' `weight' if `smpl', `ops'
		local b0=_b[`xvar']
		local eff0=cond(`"`eform'"'==`""', `b0', exp(`b0'))  
		local se0=_se[`xvar']
		local estart=`eff0'
		local xs `xnames'
		local i=1
		while `i'<=`vnum'{ 
			local i_1=`i'-1
			_stepf, `yvar1' xvar(`xvar') `locktm' `eform' cov(`"`xs'"') /*
			*/ eff0(`estart') cmd(`cmd') smpl(`smpl') `plist' /* 
			*/ `wt'  `ops' 
			local pv`i'  `r(pv)'
			local picked `picked' `pv`i''
			local eff`i'=`r(effm)'
			local b`i'=`r(bm)'
			local se`i' = `r(sem)'
			local chg`i'=`r(chg)'
			local estart=`eff`i''
			local plist plist(`picked')
			_newx, xvar(`xs') pick(`pv`i'')
			local xs `r(newlst)'
			local i =`i'+1
		} 
	}
	*** presentation and Graph *** 
	preserve 
	clear
	local obsnum = `vnum'+1 
	qui {
		set obs `obsnum'
		tempvar eff se ll ul chg  b step stepo
		gen `b'=`b0' in 1
		gen `eff'=`eff0' in 1
		gen `se'=`se0' in 1
		gen `chg'=.
		gen `step'=_n
		gen `stepo'=`obsnum'-`step' +1
		local i=1
		if "`forward'"!=""{
			if "`lockterms'"!="" {
				lab define `step' 1 "Initial model"
				lab define `stepo' `obsnum' "Initial model"
			}
			else {
				lab define `step' 1  "Crude"
				lab define `stepo' `obsnum'  "Crude"
			}
			lab var `step' "Variables added"
			lab var `stepo'  "Variables added"
		}
		else {
			lab define `step' 1  "Adj.All"
			lab define `stepo' `obsnum'  "Adj.All"
			lab var `step' "Variables removed" 
			lab var `stepo' "Variables removed"
		}
		while `i' < `obsnum' {
			local i1=`i'+1
			local io=`obsnum'-`i'
			replace `b'=`b`i''  in `i1' 
			replace `se'=`se`i''  in `i1'
			replace `chg'=`chg`i''  in `i1'
			if "`forward'"==""{
				lab def `step' `i1' "-`pv`i''", modify
				lab def `stepo' `io' "-`pv`i''", modify
			}
			else {
				lab define `step' `i1'  "+`pv`i''", modify
				lab define `stepo' `io'  "+`pv`i''", modify
			}
			local i=`i'+1
		} 
		gen `ll'=`b'-`z'*`se' 
		gen `ul'=`b'+`z'*`se'
		if "`eform'"!=""{
			replace `b'=exp(`b')
			replace `ll'=exp(`ll')
			replace `ul'=exp(`ul')
		} 
	}
	if "`eform'"=="" & "`elabel'"=="" {
		local elabel "Coef."
	}
	if "`eform'"!="" & "`elabel'"=="" {
		local elabel "exp(Coef.)"
	}
	lab val `step' `step'
	lab val `stepo' `stepo'
	lab var `b' "`elabel'"
	lab var `ll' "[`level'% Conf."
	lab var `ul' "Interval]"
	lab var `chg' "Change, %"
	if "`format'"=="" {
		local format %9.4f
	}
	format `b' `ll' `ul' `format'
	local fmt f(`format')
	tabdisp `step', cell(`b' `ll' `ul' `chg')  `fmt' center
	if "`lockterms'"!="" {
		di as input " `lockterms'" as text " in all models"
	}

	lab var `ll' " "
	lab var `ul' " "
	if "`graph'"==""{
		if "`t2title'"==""{
			local t2title t2(`"Outcome: `yvar'                   Exposure: `xvar'"')
		} 

		if "`xlabel'"=="xlabel" { 
			local stplb
			di in b "Not use xlabel for better x label
		}  
		if "`vertic'"!="" { 
			twoway  rcap `ul' `ll' `step',  xlab(1/`obsnum', valuelabel angle(0)) leg(off) `saving' `options'   ||  scatter `b' `step'
		}
		else {
			twoway  rcap `ul' `ll' `stepo',  ylab(1/`obsnum', valuelabel angle(0)) leg(off) `saving' `options'  hor  ||  scatter `stepo' `b' 
		}
		
	}
	restore 
	qui `cmd' `yvar' `xvar' `xnames' `weight' if `smpl', `ops'
end

program define _stepb, rclass 
	syntax [, Yvar(str) Xvar(str) COV(str) EForm CMD(str) smpl(str) /*
	*/ eff0(str) weight(str) lockterms(varlist) *]
	token `cov'
	local chg = . 
	local i=1
	while "``i''"~=""{
		local i_1=`i'-1  
		_newx, xvar(`cov') pick(``i'') 
		local newx `r(newlst)'
		qui `cmd' `yvar' `xvar' `newx' `lockterms' `weight' if `smpl', `options'
		local b`i'=_b[`xvar']     
		local se`i'=_se[`xvar']
		local eff`i'=cond("`eform'"=="", `b`i'', exp(`b`i''))  
		local chg`i'=((`eff`i''-`eff0')/`eff0')*100
		if abs(`chg`i'')<`chg' {
			local pv  "``i''" 		
			local mlist `newx'
			local bm=`b`i'' 
			local effm=`eff`i''
			local sem=`se`i''
			local chg=abs(`chg`i'')
		}
		local i=`i'+1
	}
	return local pv `pv'
	return local mlist `mlist'
	return local bm=`bm'
	return local effm=`effm'
	return local sem=`sem'
	return local chg=`chg'
end

program define _stepf, rclass 
	syntax [, Yvar(str) plist(str) EForm Xvar(str) COV(str) /* 
	*/ CMD(str) smpl(str) eff0(str) lockterms(varlist) weight(str) *]
	token `cov'
	local chg=0
	local i=1
	while "``i''"~=""{
		local i_1=`i'-1  
		qui `cmd' `yvar' `xvar' `plist' ``i'' `lockterms'  `weight' if `smpl', `options'
		local b`i' = _b[`xvar']
		local eff`i'=cond(`"`eform'"'==`""', `b`i'', exp(`b`i''))  
		local se`i'=_se[`xvar']
		local chg`i'=((`eff`i''-`eff0')/`eff0')*100
		if abs(`chg`i'')>`chg' {
			local pv  "``i''" 		
			local mlist `plist'
			local bm=`b`i'' 
			local effm=`eff`i''
			local sem=`se`i''
			local chg=abs(`chg`i'')
		}
		local i=`i'+1
	}
	return local pv `pv'
	return local mlist `mlist'
	return local bm=`bm'
	return local effm=`effm'
	return local sem=`sem'
	return local chg=`chg'
end

program define _ab, rclass
	token `0', parse(" _")
	unab cat:`1'`2'`3'*
	return local cname "`1'`2'`3'*"
	token `cat'
	local i=1
	while "``i''"!=""{
		local i=`i'+1
	}
	return scalar catdf=`i'-1
end

program define _xnam, rclass
	local factn=0
	foreach var in `0' {  
		if substr("`var'", 1,5) !="_cons"{
			local xlist `xlist' `var'
		}
		else {
			local factn=`factn'+1
		}
	}
	token `xlist'
	local i=1 
	while "`1'"!=""{
		if substr("`1'", 1,2)=="_I"{
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
