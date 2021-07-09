*! version 2.1.0 22jul2016 daniel klein

pr vorter // , rclass
	vers 11.2
	
	m : st_rclear()
	
	/*
		expected is
			[+|-] <...>
		
		we set local 
			<sign> := 1 if + or nothing
			<sign> := -1 if - is typed
	*/
	
	gettoken sign 0 : 0 , p("+-")
	if (!inlist(`"`sign'"', "+", "-")) {
		loc 0 `sign' `0'
		loc sign +
	}
	loc sign = (0 `sign' 1)
	
	/*
		expected is one of
			(1) (<stat> [ , missing]) <...>
			(2) <varlist> <...>
	*/
	
	gettoken stat : 0 , m(par)
	if mi("`par'") {
		/* is (1) */
		loc stat // reset empty
	}
	else {
		/* is (2) */
		gettoken stat 0 : 0 , m(par)
		vorter_set_stat `stat'
			
			/*
				set [c_]locals
					<stat> 		:= specified <stat>
					<missing> 	:= "missing" or ""
			*/
			
			if ("`stat'" != "random") {
				loc numeric numeric
			}
	}
	
	syntax varlist(`numeric' min = 2) [if] [in] ///
		[ , NOT Return * ]
	
	if mi("`stat'") {
		cap conf numeric v `varlist'
		loc isstr = _rc
		if (`isstr') {
			cap n conf str v `varlist'
			if (_rc) {
				e 109
			}
		}
	}
	else {
		loc isstr 0
	}
	
	if ("`options'" != "") {
		vorter_parse_options , `options'
		
		/*
			puts in local <options>
			the options for -order- 
		*/
	}
	
	if ("`stat'" != "random") {
		if !(c(N)) {
			err 2000
		}
		
		if mi("`stat'") {
			if mi(`"`if'`in'"') {
				loc in in 1/1
			}
			else {
				qui cou `if' `in'
				if (r(N) != 1) {
					di as err "too many observations"
					e 498
				}
			}
		}
	}
	
	tempname touse
	mark `touse' `if' `in'
	
	m : vorter_ado( ///
		`sign', 	///
		"varlist", 	///
		"`touse'", 	///
		`isstr', 	///
		"stat", 	///
		"missing")
	
	if mi("`not'`return'") {
		if (`"`macval(options)'"' != "") {
			loc options , `options'
		}
		order `r(varlist)' `options'
	}
end

pr vorter_set_stat
	vers 11.2
	
	syntax anything(id = "stat") [ , Missing ]
	
	gettoken stat anything : anything
	if (`"`macval(anything)'"' != "") {
		err 198
	}
	
	loc 0 , `stat'
	syntax ///
	[ , ///
		Mean 		///
		COUnt 		///
		N 			/// not documented
		MAx 		///
		MIn 		///
		SUm 		///
		SD 			///
		Variance 	///
		RANDom 		///
		* ///
	]
	
	if ("`count'`n'`sd'`variance'`random'" != "") {
		if ("`missing'" != "") {
			di as err "option missing not allowed"
			e 198
		}
	}
	
	loc stat `mean' `count' `n' ///
	`max' `min' `sum' `sd' `variance' `random'
	
	if mi("`stat'") {
		di as err `"`macval(options)' unknown {it:stat}"'
		e 198
	}
	
	c_local stat 		: copy loc stat
	c_local missing 	: copy loc missing
end

pr vorter_parse_options
	vers 11.2
	
	syntax ///
	[ , ///
		FIRST 				///
		LAST 				///
		Before(passthru) 	///
		After(passthru) 	///
		ALPHAbetic 			/// ignored
		SEQuential 			/// ignored
	]
	
	foreach opt in alphabetic sequential {
		if ("``opt''" != "") {
			di as txt "(note: option `opt' ignored)"
		}
	}
	
	c_local options `first' `last' `before' `after'
end

vers 11.2

loc SS string scalar
loc SR string rowvector
loc RS real scalar
loc RM real matrix
loc TS transmorphic scalar
loc TR transmorphic rowvector
loc TM transmorphic matrix

loc VS	vorter_struct_def
loc VSS struct `VS' scalar

m :

struct `VS' {
	`RS' sign
	`SR' vars
	`SS' touse
	`RS' isstr
	`SS' stat
	`RS' miss
	
	`TM' data
	`TR' indx
}

void vorter_ado(`RS' sign,
				`SS' vars,
				`SS' touse,
				`RS' isstr,
				`SS' stat,
				`SS' miss)
{
	`VSS' v
	
	v.sign 	= sign
	v.vars 	= tokens(st_local(vars))
	v.touse = touse
	v.isstr = isstr
	v.stat 	= st_local(stat)
	v.miss 	= (st_local(miss) != "")
	
	vorter_ado_get_data(v)	
	
	if (!anyof(("", "random"), v.stat)) {
		vorter_ado_get_stat(v)
	}
	
	vorter_ado_vorter(v)
	
	vorter_ado_return(v)
}

void vorter_ado_get_data(`VSS' v)
{
	`SS' allword
	
	if (v.isstr) {
		v.data = st_sdata(., v.vars, v.touse)
		v.indx = strofreal(st_varindex(v.vars))
	}
	else {
		if (v.stat == "random") {
			v.data = runiform(1, cols(v.vars))
		}
		else {
			v.data = st_data(., v.vars, v.touse)
		}
		v.indx = st_varindex(v.vars)
	}
	
	if (missing(v.data) | !rows(v.data)) {
		if (!rows(v.data)) {
			allword = "all "
		}
		printf("{txt}(note: %s", allword)
		printf("missing values encountered)\n")
	}
}

void vorter_ado_get_stat(`VSS' v)
{
	`RM' x
	
	if (v.isstr) {
		assert(0)
			/* internal error */
	}
	
	x = v.data
	
	if (v.stat == "mean") {
		x = (colsum(x, v.miss) :/ colnonmissing(x))
	}
	else if (anyof(("count", "n"), v.stat)) {
		x = colnonmissing(x)
	}
	else if (anyof(("max", "min"), v.stat)) {
		x = colminmax(x, v.miss)
		if (v.stat == "max") {
			x = x[2, .]
		}
		else if (v.stat == "min") {
			x = x[1, .]
		}
		else {
			assert(0)
				/* internal error */
		}
	}
	else if (v.stat == "sum") {
		x = colsum(x, v.miss)
	}
	else if (anyof(("sd", "variance"), v.stat)) {
		x = diagonal(variance(x))'
		if (v.stat == "sd") {
			x = sqrt(x)
		}
	}
	else {
		assert(0)
			/* internal error */
	}
	
	v.data = x
}

void vorter_ado_vorter(`VSS' v)
{
	`TM' sx
	
	sx = (v.data\ v.indx)'
	_sort(sx, v.sign)
	
	v.indx = sx[., 2]'
	v.data = sx[., 1]'
}

void vorter_ado_return(`VSS' v)
{
	`SS' oorder, corder
	
	if (v.isstr) {
		v.indx = strtoreal(v.indx)
	}
	
	v.vars = invtokens(st_varname(v.indx))
	oorder = invtokens(st_varname(sort(v.indx', 1)'))
	corder = st_varname((1..st_nvar()))
	corder = invtokens(select(corder, (corder :!= v.touse)))
	
	st_rclear()
	st_global("r(corder)", corder)
	st_global("r(oorder)", oorder)
	st_global("r(varlist)", v.vars)
	
	if (v.stat != "") {
		st_matrix("r(" + v.stat + ")", v.data)
		st_matrixrowstripe("r(" + v.stat + ")", ("", v.stat))
		st_matrixcolstripe("r(" + v.stat + ")", ///
			(J(cols(tokens(v.vars)), 1, ""), tokens(v.vars)'))
	}
}

end
e

2.1.0	22jul2016	fix bug with in qualifier
					if qualifier now allowed w/o stat
2.0.0	24feb2016 	add new -stat- -random-
					new option -not- does not change order
					option -not- is a synonym for -return-
					option -return- remains non-documented
					parse -order- options here
					option -alphabetic- ignored
					option -sequential- ignored
					return complete varlist in original order
					return stats in additional matrix
					clear r() when called (imitate rclass)
					no longer clear Mata
1.4.0	13aug2015 	add -sd- and -variance- as statistics
(1.3.1)				new suboption missing for stat
					support in #/# with statistics
					support if qualifier
					warning message for missing values
					completely revised code
1.3.0	13aug2015	sort on statistic (posted on Statalist)
1.2.0	22dec2012	string varlist allowed (never released)
1.1.0	18dec2012	return r(varlist) and r(oorder)
					option return added
					change check of -in- qualifier
					version 11.2 (might work with 10)
					sent to SSC
1.0.0	17dec2012	sent to Statalist
