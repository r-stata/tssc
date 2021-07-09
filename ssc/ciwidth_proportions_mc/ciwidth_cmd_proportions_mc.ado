*! version 1.0  2019-10-31 Mark Chatfield

program ciwidth_cmd_proportions_mc, rclass
*program name cannot be any longer than this
version 16.0

syntax , ///
p1(numlist max=1 >0 <1)  ///  proportion in control group
[p2(numlist max=1 >0 <1)] /// 
[effecttype(numlist integer max=1 >0 <=3)] ///  called effect  in . help power twoproportions
[trueeffectsize(numlist max=1 >-1)] ///  called delta in . help power twoproportions
[PROBWidth(numlist max=1 >0 <1)] ///
[Width(numlist max=1 >-1)]       ///  Stata constrains width > 0
[HALFWidth(numlist max=1 >-0.5)] /// 
[n(integer 0)] [n2(integer 0)] [n1(integer 0)] [NRATio(real 1)]  /// 
[level(cilevel)]  ///
[lbgt(numlist max=1 >-1)] ///
[ublt(numlist max=1 >-1)] ///
[CLEAR]

*alpha option? forget.


if "`effecttype'" == "" local effecttype = 1



local nspecify = 0
foreach opt of any probwidth width halfwidth lbgt ublt {
	if "``opt''" != "" local nspecify = `nspecify' + 1
}
if "`nspecify'" != "1" {
	di as err "specify exactly one of probwidth(), width(), halfwidth(), lbgt(), ublt()"
	exit 198
}



if "`p2'" != "" & "`trueeffectsize'" != "" {
	di as err "specify exactly one of p2(), trueeffectsize()"
	exit 198
}

if "`trueeffectsize'" != "" {
	if "`effecttype'" == "1" local p2 = `p1' + `trueeffectsize'
	if "`effecttype'" == "2" local p2 = `p1' * `trueeffectsize'
	if "`effecttype'" == "3" local p2 = 1 - 1/(1 + (`p1'/(1-`p1') * `trueeffectsize'))
}

if `p2' <= 0 | `p2' >= 1 {
	di as err "p1() & effecttype() imply p2 does not lie in (0,1)"
	exit 198
}



if "`level'" !="" local alphadiv2 = (1 - `level'/100)/2
else local alphadiv2 = 0.025


*add more tempname?
tempname theta 
scalar `theta' = `nratio' 

        if "`n'" != "0" & "`n2'" != "0" {
                local n1 = `n' - `n2'
                local nratio = `n1'/`n2'
        }
        if "`n'" != "0" & "`n1'" != "0" {
                local n2 = `n' - `n1'
                local nratio = `n1'/`n2'
        }
        if "`n2'" != "0" & "`n1'" != "0" {
                local n = `n2' + `n1'
                local nratio = `n1'/`n2'
        }
        if "`n'" != "0" & "`n2'" == "0" & "`n1'" == "0" {
                local n2 = `n' / (1+`theta')
                local n2 = ceil(`n2')
                local n1 = `n' - `n2'
        }
        if "`n'" == "0" & "`n2'" != "0" & "`n1'" == "0" {
                local n1 = `theta'*`n2'
                local n1 = ceil(`n1')
                local n = `n2' + `n1'   
        }
        if "`n'" == "0" & "`n2'" == "0" & "`n1'" != "0" {
                local n2 = `n1'/`theta'
                local n2 = ceil(`n2')   
                local n = `n2' + `n1'   
        } 

qui {
	preserve
	clear
	set obs `=`n2'+1'
	gen c2 = _n -1
	gen double probc2 = binomialp(`n2',c2,`p2')
	expand `=`n1'+1'
	bysort c2: gen c1 = _n -1
	gen double probc1 = binomialp(`n1',c1,`p1')
	gen double probc2c1 = probc2*probc1
	gen obs_p1 = c1/`n1'
	gen obs_p2 = c2/`n2'
	
	*risk difference 
	if "`effecttype'" == "1" {
		local trueeffectsize = `p2' - `p1'
		gen rd = c2/`n2' - c1/`n1'
		gen rd_se = sqrt(c2*(`n2'-c2)/`n2'^3 + c1*(`n1'-c1)/`n1'^3)  // formula taken from -csi-
		*no missing data
		gen rd_halfwidth = -1*rd_se*invnorm(`alphadiv2'), after(rd)		
		gen rd_width = 2*rd_halfwidth, after(rd_halfwidth)
		gen rd_ub = rd + rd_halfwidth, after(rd_halfwidth)		
		gen rd_lb = rd - rd_halfwidth, after(rd_halfwidth)
		
		if "`probwidth'" !="" {
			_pctile rd_width [aw=probc2c1], p(`=100*`probwidth'')
			local width = r(r1)
			local halfwidth = `width'/2
		}
		else if "`lbgt'" == "" & "`ublt'" == "" {
			if "`width'"=="" local width = 2*`halfwidth'
			if "`halfwidth'"=="" local halfwidth = `width'/2
			gen widthsmaller = (rd_width < `width') 
			su widthsmaller [aw=probc2c1]	
			local probwidth = r(mean)
		}
		else if "`lbgt'" != "" { 
			gen lb_gt_ = (rd_lb > `lbgt') 
			su lb_gt_ [aw=probc2c1]	
			local power = r(mean)
		}	
		else if "`ublt'" != "" { 
			gen ub_lt_ = (rd_ub < `ublt') 
			su ub_lt_ [aw=probc2c1]	
			local power = r(mean)	
		}	
	}

	*risk ratio 
	if "`effecttype'" == "2" {
		local trueeffectsize = `p2' / `p1'
		gen rr = (c2/`n2') / (c1/`n1')
		gen logrr = log(rr)
		gen logrr_se = sqrt((`n2'-c2)/c2/`n2' + (`n1'-c1)/c1/`n1')	// formula taken from -csi-
		*missing data if c1 = 0 or c2 = 0
		local se1miss = binomialp(`n1',0,`p1')
		local se2miss = binomialp(`n2',0,`p2')
		gen logrr_halfwidth = -1*logrr_se*invnorm(`alphadiv2'), after(logrr)			
		gen logrr_width = 2*logrr_halfwidth, after(logrr_halfwidth)
		gen logrr_ub = logrr + logrr_halfwidth, after(logrr_halfwidth)		
		gen logrr_lb = logrr - logrr_halfwidth, after(logrr_halfwidth)
		foreach v of any  rr_width rr_ub rr_lb rr_halfwidth   {
			gen `v' = exp(log`v'), after(rr)
		}
	
		if "`probwidth'" !="" {
			_pctile logrr_width [aw=probc2c1], p(`=100*`probwidth'')
			*missing data ignored
			local width = exp(r(r1))
			local halfwidth = sqrt(`width')
		}
		else if "`lbgt'" == "" & "`ublt'" == "" {
			if "`width'"=="" local width = `halfwidth'^2
			if "`halfwidth'"=="" local halfwidth = sqrt(`width')
			gen widthsmaller = (exp(logrr_width) < `width') if logrr_width !=.
			su widthsmaller [aw=probc2c1]		
			local probwidth = r(mean)
		}
		else if "`lbgt'" != "" {
			gen lb_gt_ = (rr_lb > `lbgt') if rr_lb !=.
			su lb_gt_ [aw=probc2c1]		
			local power = r(mean)	
		}	
		else if "`ublt'" != "" {
			gen ub_lt_ = (rr_ub < `ublt') if rr_ub !=.
			su ub_lt_ [aw=probc2c1]		
			local power = r(mean)	
		}	
	}

	*odds ratio 
	if "`effecttype'" == "3" {
		local trueeffectsize = `p2'*(1-`p1')/`p1'/(1-`p2')
		gen or = c2*(`n1'-c1)/c1/(`n2'-c2)
		gen logor = log(or)		
		gen logor_se = sqrt(1/(`n2'-c2) + 1/c2 + 1/(`n1'-c1) + 1/c1)  // formula taken from -csi (woolf)-
		*missing data if c1 = 0 or c2 = 0 or c1 = n1 or c2 = n2
		local se1miss = binomialp(`n1',0,`p1') + binomialp(`n1',`n1',`p1')
		local se2miss = binomialp(`n2',0,`p2') + binomialp(`n2',`n2',`p2')		
		gen logor_halfwidth = -1*logor_se*invnorm(`alphadiv2'), after(logor)			
		gen logor_width = 2*logor_halfwidth, after(logor_halfwidth)
		gen logor_ub = logor + logor_halfwidth, after(logor_halfwidth)		
		gen logor_lb = logor - logor_halfwidth, after(logor_halfwidth)
		foreach v of any  or_width or_ub or_lb or_halfwidth   {
			gen `v' = exp(log`v'), after(or)
		}		
		
		if "`probwidth'" !="" {
			*su logor_width [aw=probc2c1],d
			_pctile logor_width [aw=probc2c1], p(`=100*`probwidth'')
			*missing data ignored
			local width = exp(r(r1))
			local halfwidth = sqrt(`width')			
		}
		else if "`lbgt'" == "" & "`ublt'" == "" {
			if "`width'"=="" local width = `halfwidth'^2
			if "`halfwidth'"=="" local halfwidth = sqrt(`width')
			gen widthsmaller = (exp(logor_width) < `width') if logor_width !=.
			su widthsmaller [aw=probc2c1]		
			local probwidth = r(mean)
		}
		else if "`lbgt'" != "" {
			gen lb_gt_ = (or_lb > `lbgt') if or_lb !=.
			su lb_gt_ [aw=probc2c1]		
			local power = r(mean)	
		}	
		else if "`ublt'" != "" {
			gen ub_lt_ = (or_ub < `ublt') if or_ub !=.
			su ub_lt_ [aw=probc2c1]		
			local power = r(mean)	
		}		
	}
	if "`clear'" != ""  restore, not
	else restore
}




/* store results */
if "`effecttype'" == "1" return scalar Pr_noCI = 0
else return scalar Pr_noCI = `se1miss' + `se2miss' - `se1miss'*`se2miss'


if "`lbgt'" != "" | "`ublt'" != "" {
	local width = .
	local halfwidth = .
	local probwidth = .
	return scalar power = `power'
}	

if "`lbgt'" != "" return scalar lbgt = `lbgt'
if "`ublt'" != "" return scalar ublt = `ublt'


return scalar width = `width'
*if "`halfwidth'"=="" local halfwidth = .
return scalar halfwidth = `halfwidth'
return scalar Pr_width = `probwidth'
return scalar level = `level'
return scalar alpha = `alphadiv2' * 2
return scalar N = `n'
return scalar nratio = `nratio'
return scalar N2 = `n2'
return scalar N1 = `n1'
return scalar p2 = `p2'
return scalar p1 = `p1'
return scalar true_ES = `trueeffectsize'
return scalar ES_type = `effecttype'

end
