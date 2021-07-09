program define epimodels_util
	version 16.0
	`0'
end

program define check_total_population
    version 16.0
	syntax anything
	
	if (`anything' < 1.00+`c(epsdouble)') {
		display ""
	    display as result "Warning! Total population size (`anything') is less than 1.00"
		display as result "Make sure the initial conditions at t0 represent population groups counts in persons."
	}
end

program define check_steps
    version 16.0
	syntax anything

	capture confirm integer number `anything'
	if (_rc) {
		display as error "Number of simulation steps in each simulation day must be an integer number."
		error 198
	}
	
	capture assert (`anything' > 0)
	if (_rc) {
	    display as error "Number of simulation steps in each simulation day must be 1 or more."
		error 198
	}
	
	capture assert (`anything' <= 1e4)
	if (_rc) {
	    display as error "Number of simulation steps in each simulation day must be no more than 10000."
		error 198
	}
end


program define check_days
	version 16.0
	syntax anything
	
	capture confirm integer number `anything'
	if (_rc) {
		display as error "Number of simulation steps (days) must an integer number."
		error 198
	}
	
	capture assert (`anything' > 0)
	if (_rc) {
	    display as error "Number of simulation steps (days) must be 1 or more."
		error 198
	}
end

program define check_day0_date
	version 16.0
	syntax [anything]
	
	if (`"`anything'"'!="") {
		if (date(`"`anything'"',"YMD")==.) {
			display as error "Option day0() is specified incorrectly."
			display as error "The date must be specified in the YYYY-MM-DD format, for example: 2020-02-29"
			error 111		  
		}
	}
end

program define makedatevar

	version 16.0
	syntax varname, [day0(string)] datefmt(string)
	
	if (`"`day0'"'!="") {
	  quietly replace t = t + date(`"`day0'"',"YMD")  // only affects the data, not the matrix
	  format t `datefmt'
	  label variable `varlist' "Date"
	}

end

program define ditable, rclass

    version 16.0

	syntax varname, ///
	    days(real) [day0(string)] datefmt(string) ///
	    [modeltitle(string)] mcolnames(string) ivar(string) ///
		varlabels(string) ylabel(string) [digits(real 2) comma(string) percent]

	quietly maxinfect `ivar' `varlist', ///
	  day0(`"`day0'"') datefmt("`datefmt'") `percent'
	
	local max=r(maxinfect)
	local dstar=r(d_maxinfect)
	local tstar=r(t_maxinfect)
	local ostar=r(o_maxinfect)
	local X=floor(t[`ostar'])
	local last=_N

	local title_t0 = "t0"
	local title_tX = "t`X'"
	local title_t1 = "t`days'"

	if (`"`day0'"' != "") {
	    local title_t0 = string(`varlist'[1], "`datefmt'")
		local title_tX = string(`varlist'[`=`dstar'+1'], "`datefmt'")
		local title_t1 = string(`varlist'[`last'], "`datefmt'")		
	}
	
	local twid = 17
	local cwid = 14
	local lmarg = 2
	
	forvalues i = 2/`:word count `varlabels'' {
	    local vl `"`:word `i' of `varlabels''"'
		local twid=max(strlen(`"`vl'"')+1,`twid')
	}
	
	local twidth = `twid' + 3*(`cwid'+1)
	local titlepos = `lmarg' + floor((`twidth'-strlen(`"`modeltitle'"'))/2)
	if (`titlepos' < `lmarg') local titlepos=`lmarg'	
	local titleoffset=`"_col(`=`titlepos'+1')"'
	
	display ""
    display `titleoffset' "`modeltitle'"
    tempname tab
	.`tab' = ._tab.new, col(4) lmarg(`lmarg') commas
	.`tab'.width    `twid' | `cwid' `cwid' `cwid'
	.`tab'.titlefmt .   %`cwid's   %`cwid's %`cwid's
	.`tab'.numfmt   .   %`cwid'.`digits'f`comma'  %`cwid'.`digits'f`comma' %`cwid'.`digits'f`comma'
	.`tab'.sep, top
	.`tab'.titles `"`ylabel'"' "`title_t0'" "`title_tX'" "`title_t1'"
	.`tab'.sep, mid

	local total_t0 = 0
	local total_tX = 0
	local total_t1 = 0
	
	forvalues i = 2/`:word count `varlabels'' {
	    local vl `"`:word `i' of `varlabels''"'
		local vn `:word `i' of `mcolnames''
	    .`tab'.row `"`vl'"' `=`vn'[1]' `=`vn'[`=`dstar'+1']' `=`vn'[`last']'
		local total_t0 = `total_t0' + `=`vn'[1]'
		local total_tX = `total_tX' + `=`vn'[`=`dstar'+1']'
		local total_t1 = `total_t1' + `=`vn'[`last']'
	}
	.`tab'.sep, middle
	.`tab'.row `"Total"' `total_t0' `total_tX' `total_t1'
	.`tab'.sep, bottom
	
	if (`"`day0'"'!="") {
	  local specdate `"(`=string(`=`varlist'[`ostar']',`"`datefmt'"')') "'
	  local specday =floor(t[`dstar']-t[1]+1)
	}
	else {
	  local specday =floor(t[`ostar'])
	}
	
	local maxtext `"`=string(`=`max'',"%20.4gc")'"'
	if (`"`percent'"'!="") local maxtext `"`maxtext'%"'
	display as text "The maximum size of the infected group {result:`maxtext'} is reached on day {result:`specday' `specdate'}of the simulation."
	
	if (`ostar'==`last') {
	    display as result "Warning! The peak is detected at the end of the simulation, and may change if you extend it."
	}
	display ""
	
	return scalar maxinfect= `max' 
	return scalar t_maxinfect=`tstar' 
	return scalar d_maxinfect=`dstar'
	return scalar o_maxinfect=`ostar'
end

program define maxinfect, rclass

    version 16.0
	
	syntax varlist, [day0(string) datefmt(string) percent]
	
	local ivar `"`: word 1 of `varlist''"'
	local tvar `"`: word 2 of `varlist''"'
	if (`"`datefmt'"'=="") local datefmt="%td"
	
	tempname tmax max dmax
	
	summarize `ivar' if (!missing(`ivar')), meanonly
	scalar `max' = r(max)
	
	summarize `tvar' if (abs(`ivar'-`max') < c(epsdouble)), meanonly
	scalar `tmax' = r(min) // in case of multiple identical values pick the first one
	quietly count if (`tvar' < `tmax')
    scalar `dmax' = `=r(N)'

	return scalar o_maxinfect=`dmax'+1
	return scalar t_maxinfect=`tmax'
	return scalar d_maxinfect=`dmax'
	return scalar maxinfect=`max'
end

program define pdfreport

	version 16.0
	
	syntax [varlist(default=none)], modelname(string) modelparams(string) ///
	                [modelgraph(string)] [appendixgraphs(string)] ///
					save(string)

	if (strlen(`"`modelparams'"')>40) local br `"`=char(10)'"'
	
	mata epimodels_about()

	putpdf begin
	putpdf paragraph 
	putpdf text ("EPIMODELS Report"), bold font("Helvetica",28,steelblue)
	putpdf paragraph 
	putpdf text ("This report was generated on `c(current_date)'"), font("Helvetica",16,steelblue)
	putpdf paragraph 
	putpdf text ("`modelname' model with parameters:`br'`modelparams'."), bold
	
	capture findfile "epimodels_eq_`modelname'.png"
	if !_rc {
	    // model with equations
		putpdf paragraph 
		putpdf text ("          ")	
		putpdf image "`=r(fn)'" , width(4)    // todo: instream this??
    }
	if (`"`modelgraph'"'!="") {
		putpdf paragraph 
		putpdf image `"`modelgraph'"'
	}
	
	putpdf paragraph
	putpdf text ("Generated with EPIMODELS version `epimodels_version' from `compile_date' built for Stata v`compile_version'"), font("Helvetica",12,steelblue)
	putpdf paragraph 
	putpdf text ("For more information, visit EPIMODELS' homepage: http://www.radyakin.org/stata/epimodels/"), font("Helvetica",12,steelblue)
	putpdf pagebreak
	putpdf paragraph , halign(center)
	putpdf text ("Simulation results"), font("Helvetica",28,steelblue)
	
	if (`"`varlist'"'!="") {
		putpdf table t=data(`varlist'), varnames
		putpdf table t(.,.), halign(center) valign(center) nformat(%12.0fc) font("Consolas",8)
		putpdf table t(1,.), bgcolor("aliceblue")
		putpdf paragraph
	}
	
	foreach v in `varlist' {
		putpdf text ("`v': `:variable label `v''`=char(10)'")
	}	
	
	// optional appendix
	if (`"`appendixgraphs'"'!="") {
	    putpdf sectionbreak, landscape
		local first=1
	    foreach f in `appendixgraphs' {
		    if (!`first') {
			    putpdf pagebreak
				local first=0
		    }
			putpdf paragraph 
			putpdf image `"`f'"'
		}
	}
	
	putpdf save `"`save'"' , replace

end

program define popmatrix, rclass
	
	version 16.0
	
	syntax , agevar(varname) sexvar(varname) at(numlist) ///
	         [malecode(integer 1) femalecode(integer 2)]
	
	assert !missing(`agevar')
	assert !missing(`sexvar')
	assert (`malecode'!=`femalecode')
	local cc=subinstr(`"`at'"',","," ",.)
	local NG `: word count `cc''
	
	tempvar agegrp sexgrp
	quietly egen `agegrp'=cut(`agevar'), at(`at')
	quietly recode `sexvar' (`malecode'=1) (`femalecode'=2) , generate(`sexgrp')
	
	local N=_N
	local rn ""
	tempname M
	matrix `M' = J(`=`NG'-1',2,.)
	forval i=1/`=`NG'-1' {
	  local v1 =`: word `i' of `cc''
      local v2 =`: word `=`i'+1' of `cc''-1
	  local rn `"`rn' "`v1'-`v2'""'
      forval s=1/2 {
		quietly count if `agegrp'==`v1' & `sexgrp'==`s'
		local n=r(N)
		matrix `M'[`i',`s']=`n'/`N'
	  }
	}
	matrix colnames `M' = "Males" "Females"
	matrix rownames `M' = `rn'
	return matrix F=`M'
	return local N=_N
end

// END OF FILE