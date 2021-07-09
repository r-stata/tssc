*! version 1.02 by David Roodman, Center for Global Development 7/27/04.
*! Based almost entirely on collapse version 6.0.0  14apr2003

program define collapse2
	if _caller() < 5 {
		collaps4 `0'
		exit
	}
	version 8

	syntax anything(name=clist id=clist equalok) 	///
		[if] [in] [aw fw iw pw] 		///
		[, BY(varlist) CW FAST CLABEL ]

	if ("`fast'"=="") preserve

	cap tsset
	qui if _rc == 0 {
		tempvar tvar
		gen `tvar' = `r(timevar)'
		if "`r(panelvar)'" != "" {
			tempvar ivar
			qui gen `ivar' = `r(panelvar)'
		}
		tsset `ivar' `tvar'
		local keep `ivar' `tvar'
	}		

	local n 0
	local stat = "mean"
	while `"`clist'"' != "" {
		GetOpStat stat clist : "`stat'" `"`clist'"'
		/* now we get <stuff> */
		/* is it name = ... */
		gettoken tok1 rest : clist   , parse(" =.") bind
		gettoken tok2 rest2: rest, parse(" =.") bind

		if "`tok2'" == "=" {		// newname = ...
			GetNewnameEq lhs rhs clist : `"`clist'"'
			local ++n
			tsrevar `rhs'
			local tname  `r(varlist)'
			local keep   `"`keep' `tname'"'
			local tar    `"`tar' `lhs'"'
			local old`n' `"`tname'"'
			local lab`n' `"`rhs'"'
			local fcn`n' `"`stat'"'
			local new`n' `"`lhs'"'
			local fmt`n' : format `tname'
		}
		else { 				// varname(ts) or varlist(ts)
			GetVarlist vl clist : `"`clist'"'
			local i 0
			tsrevar `vl'
			foreach el in `r(varlist)' {
				local ++n
				gettoken realname vl : vl
				local ++i
				local keep `"`keep' `el'"'
				local tar  `"`tar' `el'"'
				local old`n' `el'
				local lab`n' "`realname'"
				local fcn`n' `"`stat'"'
				Setnf new`n' fmt`n' : `realname' `el'
			}
		}
			
	}
	
	if (`n'==0) error 198

	if `"`by'"'!="" {
		bynottar `"`by'"' `"`tar'"'
	}

	if `"`weight'"' != "" {
		tempvar w
		qui gen double `w' `exp' `if' `in'
		local wgt `"[`weight'=`w']"'
	}
	tempvar touse
	mark `touse' `if' `in' `wgt'
	if `"`cw'"'!="" {
		markout `touse' `keep'
	}
	qui count if `touse'
	if r(N)==0 {
		error 2000
	}

	qui keep if `touse'
	qui keep `keep' `by' `w'

					/* check uniqueness */
/*
Table:
	old`i'	(original) name of source variable		x
	use`i'  renamed old`i'
	new`i'  target variable					x
	drp`i'  =use`i' if may be dropped, else `" "'
	fcn`i'  function to call				x
	fmt`i'	%format of original variable
*/
	local i 1
	while `i' <= `n' {

		if `"`drp`i''"'=="" {
			tempname use
			local use`i' `"`use'"'
			rename `old`i'' `use'
			local lasti `i'
		}
		local j=`i'+1
		while `j'<=`n' {
			if `"`new`i''"' == `"`new`j''"' {
				di as err "error:" _n /*
				*/ _col(8) `"`new`i'' = (`fcn`i'') `lab`i''"' /*
				*/ _n /*
				*/ _col(8) `"`new`j'' = (`fcn`j'') `lab`j''"' /*
				*/ _n "name conflict"
				exit 198
			}
			if `"`drp`i''"'=="" & `"`old`i''"' == `"`old`j''"' {
				local lasti `j'
				local use`j' `"`use'"'
				local drp`j' `" "'
			}
			local ++j 
		}
		if `"`drp`i''"'=="" {
			local drp`lasti' `"`use'"'
		}
		local ++i
	}

	quietly {
		tempvar new
		local i 1
		while `i'<=`n' {
			_`fcn`i'' `new`i'' `use`i'' `"`weight'"' `"`w'"' /*
			*/ `"`by'"'
			capture drop `drp`i''
			if "`clabel'"=="" {
				label var `new`i'' `"(`fcn`i'') `lab`i''"'
			}
			else 	label var `new`i'' `"`fcn`i'' of `lab`i''"'
			format `new`i'' `fmt`i''
			local ++i 
		}
	}
	if `"`by'"' != "" {
		sort `by'
		quietly by `by': keep if _n==_N
	}
	else	quietly keep in 1

	global S_FN
	global S_FNDATE

	if ("`fast'" == "") restore, not
end


program Setnf 
	args mname mfmt colon realname el

	if "`realname'" == "`el'" {
		c_local `mname' "`el'"
		c_local `mfmt' : format `el'
	}
	else {
		local op : tsnorm `realname' , varname
		gettoken op  var : op , parse(".")
		gettoken dot var : var, parse(".")
		c_local `mname' `op'`var'
		c_local `mfmt' : format `var'
	}
end


program GetNewnameEq
	args mlhs mrhs mrest colon rest 

	gettoken lhs   rest : rest, parse(" =")
	gettoken equal rest : rest, parse(" =")
	gettoken 0     rest : rest, parse(" ") 

	confirm name `lhs'
	c_local `mlhs' `lhs'

	syntax varname(ts)
	c_local `mrhs' `varlist'

	c_local `mrest' `rest'
end


program GetVarlist 
	args mvl mrest colon rest 

	while (1) {
		gettoken tok rest1 : rest, parse(" =") 
		local c = substr(trim(`"`rest1'"'),1,1)
		if "`c'"=="=" | "`c'"=="(" | "`c'"=="" {
			if "`c'" == "=" {
				local 0  `"`vl'"'
				c_local `mrest' `"`rest'"'
			}
			else if "`c'"=="(" {
				local 0 `vl' `tok'
				c_local `mrest' `"`rest1'"'
			}
			else {
				local 0 `vl' `tok'
				c_local `mrest'
			}
			syntax varlist(ts)
			c_local `mvl' "`varlist'"
			exit
		}
		local vl `vl' `tok'
		local rest `"`rest1'"'
	}
end
			
	

program GetOpStat 
	args mstat mrest colon stat line

	gettoken thing nline : line, parse("() ") match(parens)
	if "`parens'"=="" {
		c_local `mstat' "`stat'"
		c_local `mrest' `"`line'"'
		exit
	}

	if `:word count `thing'' == 1 {
		local 0 `", `thing'"'
		capture syntax [, mean median sd sum rawsum count max min iqr first firstnm last lastnm]
		if _rc == 0 {
			c_local `mstat' `thing'
			c_local `mrest' `"`nline'"'
			if ("`median'"!="") c_local `mstat' "p 50"
			exit
		}
		
		if "`first'`last'`firstnm'`lastnm'" == "" {
			tsset
		}

		local thing = trim("`thing'")
		if (substr("`thing'",1,1) == "p") {
			local thing = substr("`thing'",2,.)
			capture confirm integer number `thing'
			if _rc==0 { 
				if 1<=`thing' & `thing'<=99 {
					c_local `mstat' "p `thing'"
					c_local `mrest' `"`nline'"'
					exit
				}
			}
		}
	}
	di as err "(`thing') invalid statistic"
	exit 198
end



program bynottar /* `"byvars"' `"targetvars"' */
	local byvars `"`1'"'
	tokenize `"`2'"'
	local i 1
	local byv : word `i' of `byvars'
	while `"`byv'"' != "" {
		local j 1
		while `"``j''"' != "" {
			if `"`byv'"'==`"``j''"' {
				di as err /*
				*/ `"``j'' may not be both target and by()"'
				exit 198
			}
			local ++j
		}
		local ++i
		local byv : word `i' of `byvars'
	}
end


/* routines for calculating statistics */

program _mean /* newvar oldvar wtype wvar byvars */
	args y x wt w by

	if (`"`w'"'=="") local w 1

	if `"`by'"' != "" {
		sort `by'
		local by `"by `by':"'
	}

	local ty : type `x'
	if (`"`ty'"'=="double" | `"`ty'"'=="long") local ty "double"
	else	local ty 			/* erase macro */

	quietly {
		`by' gen `ty' `y' = sum(`w'*`x')/sum(cond(`x'<.,`w',0))
		`by' replace `y' = `y'[_N]
	}
end

program _sd /* newvar oldvar wtype wvar byvars */
	args y x wt w by

	if (`"`w'"'=="") local w 1
	else {
		if `"`wt'"'=="pweight" {
			di as err "sd not allowed with pweights"
			exit 135
		}
	}
	if `"`by'"' != "" {
		sort `by'
		local by `"by `by':"'
	}

	quietly {
		if `"`wt'"'=="aweight" {
			tempvar new
			remakew `x' `w' `new' `"`by'"'
			local w `"`new'"'
		}

		local ty : type `x'
		if (`"`ty'"'=="double" | `"`ty'"'=="long") local ty "double"
		else	local ty 			/* erase macro */

		tempvar m
		`by' gen double `m' = sum(`w'*`x')/sum(cond(`x'<.,`w',0))
		`by' gen `ty' `y' = sqrt( /*
				*/ sum(`w'*((`x'-`m'[_N])^2)) / /*
				*/ (sum(cond(`x'<.,`w',0))-1) /*
				*/ )
		`by' replace `y' = cond(`m'[_N]==., ., `y'[_N])
	}
end

program _sum
	args y x wt w by

	if (`"`w'"'=="") local w 1
	if `"`by'"' != "" {
		sort `by'
		local by `"by `by':"'
	}

	quietly {
		if `"`wt'"'=="aweight" {
			tempvar new
			remakew `x' `w' `new' `"`by'"'
			local w `"`new'"'
		}

		`by' gen double `y' = sum(`w'*`x')
		`by' replace `y' = `y'[_N]
	}
end

program _rawsum
	args y x wt w by

	if `"`by'"' != "" {
		sort `by'
		local by `"by `by':"'
	}

	quietly {
		`by' gen double `y' = sum(`x')
		`by' replace `y' = `y'[_N]
	}
end

program _count
	args y x wt w by

	if `"`by'"' != "" {
		sort `by'
		local by `"by `by':"'
	}

	quietly {
		if `"`wt'"'=="fweight" | `"`wt'"'=="iweight" /*
		*/ | `"`wt'"'=="pweight" {
			`by' gen double `y' = sum(cond(`x'<.,`w',0))
		}
		else	`by' gen long `y' = sum(`x'<.)
		`by' replace `y' = `y'[_N]
	}
end

program _max
	args y x wt w by

	tempvar touse
	quietly {
		local ty : type `x'
		gen byte `touse' = (`x' < .)
		sort `by' `touse' `x'
		if `"`by'"' != "" {
			by `by': gen `ty' `y' = `x'[_N]
		}
		else	gen `ty' `y' = `x'[_N]
	}
end

program _last
	args y x wt w by

	quietly {
		tsset
		local t `r(timevar)'
		local ty : type `x'
		sort `by' `t'
		if `"`by'"' != "" {
			by `by': gen `ty' `y' = `x'[_N]
		}
		else	gen `ty' `y' = `x'[_N]
	}
end

program _lastnm
	args y x wt w by

	tempvar touse
	quietly {
		tsset
		local t `r(timevar)'
		local ty : type `x'
		gen byte `touse' = (`x' < .)
		sort `by' `touse' `t'
		if `"`by'"' != "" {
			by `by': gen `ty' `y' = `x'[_N]
		}
		else	gen `ty' `y' = `x'[_N]
	}
end

program _first
	args y x wt w by

	quietly {
		tsset
		local t `r(timevar)'
		local ty : type `x'
		gsort `by' -`t'
		if `"`by'"' != "" {
			by `by': gen `ty' `y' = `x'[_N]
		}
		else	gen `ty' `y' = `x'[_N]
	}
end

program _firstnm
	args y x wt w by

	tempvar touse
	quietly {
		tsset
		local t `r(timevar)'
		local ty : type `x'
		gen byte `touse' = (`x' < .)
		gsort `by' `touse' -`t', mfirst
		if `"`by'"' != "" {
			by `by': gen `ty' `y' = `x'[_N]
		}
		else	gen `ty' `y' = `x'[_N]
	}
end

program _min
	args y x wt w by

	tempvar touse revx
	quietly {
		local ty : type `x'
		gen byte `touse' = (`x'<.)
		gen double `revx' = -`x'
		sort `by' `touse' `revx'
		if `"`by'"' != "" {
			by `by': gen `ty' `y' = `x'[_N]
		}
		else	gen `ty' `y' = `x'[_N]
	}
end

program _p
	args p y x wt w by

	tempvar touse i n g
	local ty : type `x'
	if (`"`ty'"'=="double" | `"`ty'"'=="long") local ty "double"
	else	local ty 				/* erase macro */

	quietly {
		gen byte `touse' = `x'<.
		sort `by' `touse' `x'

		if `"`w'"'=="" {
			local w 1
		}
		else {
			tempvar new
			if `"`by'"' != "" {
				remakew `x' `w' `new' `"by `by':"'
			}
			else	remakew `x' `w' `new'
			local w `"`new'"'
		}

		by `by' `touse': gen double `n' = sum(`w') if `touse'
		by `by' `touse': /*
			*/ gen double `g' = `n'*`p'/100 if `touse' & _n==_N
		gen long `i' = .
		by `by' `touse': /*
			*/ replace `i'=cond(`i'[_n-1]<.,`i'[_n-1], /*
			*/ 	cond(`n'-`g'[_N]>.01,_n,.)) if `touse'
		by `by' `touse': /*
			*/ gen `ty' `y' = cond(`g'- `n'[`i'-1] >.01, /*
			*/	`x'[`i'], (`x'[`i'-1]+`x'[`i'])/2) /*
			*/	if `touse' & _n==_N

		if `"`by'"' != "" {
			by `by': replace `y' = `y'[_N]
		}
		else	replace `y' = `y'[_N]
	}
end

program _iqr
	args y x wt w by

	tempvar p75 p25
	_p 75 `p75' `x' `"`wt'"' `"`w'"' `"`by'"'
	_p 25 `p25' `x' `"`wt'"' `"`w'"' `"`by'"'
	local ty : type `p75'
	quietly gen `ty' `y' = `p75' - `p25'
end

/* utilities used by _* routines */

program remakew /* xvar oldw neww by-prefix */
	args x w new by
			/* by is either "" or "by vn vn ...:"	*/
	tempvar sum obs
	`by' gen long `obs' = sum(`x'<.)
	`by' gen double `sum' = sum(cond(`x'<.,`w',0))
	`by' gen double `new' = cond(`x'<., `w'*`obs'[_N]/`sum'[_N], .)
end
exit


/*


<clist> :=
		<stat> <stuff> [<clist>]
		<stuff> [<clist>]


<stat> :=
		(<statword>)

<statword> :=
		mean | sd | sum | rawsum | count | max | min | iqr | first | last
		p#			(1 <= # <= 99, # an int)

<stuff> :=
		varname <stuff>
		varlist <stuff>

		name[ ]=[ ]<varname> <stuff>
		name[ ]=[ ]<op.varname> <stuff>

		op.varname
		op.(varname [varname ...])
		op(numlist).varname
		op(numlist).(varname [varname...])

-------------------------------------------------------------------------
*/
