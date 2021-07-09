*! version 1.0.5    04mar2019
*! Robert Picard    picard@netbox.com
*! Clyde Schechter  clyde.schechter@einstein.yu.edu
program define runby

	version 11
	
	syntax name(name=progname id=program_name)  ///
		,                     ///
		BY(varlist)           ///
		[                     ///
		Verbose               ///
		Allocate(integer 0)   ///
		Useappend             ///
		Status                ///
		Timer(integer 91)     /// left undocumented, used for status reports
		]
		
	if _N == 0 error 2000
	
	if !inrange(`timer', 1,100) {
		dis as err "timer value must be between 1 and 100"
		exit 198
	}
	
	// order data by groups; use stable sort based on initial order
	tempvar obs
	gen long `obs' = _n
	sort `by' `obs'
	drop `obs'
	

	if "`useappend'" != "" {
		runby_useappend `0'
		exit
	}

	
	// need a single numeric variable to identify by-groups
	cap confirm numeric var `by'
	if !_rc & (`: word count `by'' == 1) local bygroup `by'
	else {
		tempvar one bygroup
		by `by': gen byte `one' = _n == 1
		gen long `bygroup' = sum(`one')
		drop `one'
		local vtemp `bygroup'
	}


	local caller = _caller()
	mata: runby_main("`progname'", "`bygroup'", "`vtemp'", "`verbose'", ///
		`allocate', "`caller'", "`status'", `timer')
		
end


program define runby_useappend

	version 11
	
	syntax name(name=progname id=program_name)  ///
		,                     ///
		BY(varlist)           ///
		[                     ///
		Verbose               ///
		Allocate(integer 0)   ///  ignored!
		Useappend             ///
		Status                ///
		Timer(integer 91)     ///
		]


	// data is already sorted by `by' groups
	tempfile hold
	qui save "`hold'"


	// the number of observations per group
	tempvar groupN
	by `by': gen long `groupN' = _N
	
	
	// scan for start and end of each group
	local group 0
	local next 1
	local more 1
	while `more' {
	
		local ++group
		local g1_`group' = `next'
		local gN_`group' = `next' + `groupN'[`next'] - 1
		
		local next = `next' + `groupN'[`next']
		
		if `next' > _N local more 0
		
	}
	
	
	local break_event 0
	local mobs = _N		// initial observations in memory
	local robs = 0		// number of saved obs (results from program's run)
	local gerrors = 0	// number of groups where program ends with an error
	local gnodata = 0	// number of groups with no data when program ends
	if "`status'" == "status" ///
		mata: sinfo = status_report_init(`timer', `group')
	
	
	// loop over each group and run the user's program
	local res 0
	if "`verbose'" != "" local noi noi
	
	forvalues i = 1/`group' {
		qui use in `g1_`i''/`gN_`i'' using "`hold'", clear
		
		cap `noi' `progname'
		
		if _rc == 1 {
			local break_event 1
			noi dis _n(3) as err "{dup 15:*} BREAK {dup 15:*}" as txt
			continue, break
		}
		
		if _rc local ++gerrors
		else if `c(N)' & `c(k)' {
			local ++res
			tempfile f`res'
			qui save "`f`res''"
			local robs = `robs' + _N
		}
		else local ++gnodata
		
		if "`status'" == "status" ///
			mata: status_report(sinfo, `i', `gerrors', `gnodata', `mobs', `gN_`i'', `robs')
	}


	if "`status'" == "status" {
		timer off `timer'
		timer clear `timer'
	}
	
	
	mata: final_report(`group', `gerrors', `gnodata', `mobs', `robs')


	// combine results and leave them in memory
	clear
	if `res' > 0 {
		dis
		dis "appending saved observations from " as res `res' ///
			as txt " by-groups ..."
		qui use "`f1'"
		forvalues i = 2/`res' {
			qui append using "`f`i''", force
		}
	}
	
	if `break_event' error 1

end



version 11
mata:
mata set matastrict on


/*
-------------------------------------------------------------------------------

struct vardata
==============

A structure to store a variable's data. 

-------------------------------------------------------------------------------
*/

struct vardata {

	transmorphic colvector d  // data points
	string scalar name        // variable name
	string scalar type        // variable type
	string scalar label       // variable label
	string scalar vallab      // value label
	string scalar format      // display format
	real   scalar is_str      // true if variable is string
	
}


/*
-------------------------------------------------------------------------------

struct dataset
==============

A structure to store a dataset

-------------------------------------------------------------------------------
*/


struct dataset {

	real   scalar  nvar          // number of variables
	real   scalar  nobs          // number of observations
	struct vardata rowvector v   // variable data
	string scalar  dlabel        // dataset label
	string matrix  chars         // dataset characteristics
	
}


/*
-------------------------------------------------------------------------------

struct dynamic_resize
=====================

We make no assumption with respect to the data left in memory when the user's
program terminates. 

Since the number of observations to accumulate is unknown, we implement a
strategy of dynamically resizing each variable's colvector using an algorithm
that tries to minimize the number of times the colvector has to be expanded.
-dynamic_resize- holds information needed to track and resize these arrays.

-------------------------------------------------------------------------------
*/

struct dynamic_resize {

	real scalar    curdim    // current size of colvectors
	real scalar    dta_nobs  // initial dta: number of observations
	real colvector cum_gobs  // initial dta: cumulative sum of obs per group

}


/*
-------------------------------------------------------------------------------

struct name_lookup
==================

Since the number of variables (and the order of variables) is unknown, we use an
associative array to map variable names to indices of -vardata-. 

-------------------------------------------------------------------------------
*/

struct name_lookup {

	transmorphic vindex        // associative array to store variable index
	string rowvector prev_vars // previous by-group variable names
	real   rowvector jv        // indices to -vardata- structure

}


/*
-------------------------------------------------------------------------------

struct status_info
==================

Holds information used in the progress status reports and final report. The
frequency of status reports decreases as time goes by. There are 5 levels,
from every 1 second (first 5 seconds) to every 5 minutes (after 1 hour).

-------------------------------------------------------------------------------
*/

struct status_info {

	real scalar timer_id   // which timer to use
	real scalar last_time  // time of previous report
	real scalar level      // the current level of reporting
	real matrix levels     // levels of reporting  
	real scalar ngroups    // number of by-groups

}


/*
-------------------------------------------------------------------------------

runby_main()
============

-------------------------------------------------------------------------------
*/

void runby_main (

	string scalar pname,    // user-defined program name
	string scalar byvar,    // by-group identifier variable name
	string scalar gtemp,    // name of tempvar created to identify groups
	string scalar verbose,  // program option
	real   scalar usersize, // program option
	string scalar vcaller,  // version set by the caller
	string scalar status,   // program option
	real   scalar timer     // program option

)
{

	struct dataset scalar ///
		m,   // initial data in memory
		r    // accumulated results
		
	struct dynamic_resize scalar z
	
	struct name_lookup scalar a
			
	struct status_info scalar sinfo

	real matrix gindices
	
	real rowvector ///
		vnames,
		vtypes,
		by

	real scalar g, g1, gN, rc, gerrors, gnodata, break_event
	

	// find first and last obs in each by-group
	by = st_data(., byvar)
	gindices = panelsetup(by, 1)
	
	// drop by-group var if it was created by us and return memory
	if (gtemp != "") st_dropvar(byvar)
	by = .
	
	// move data in memory to a -dataset- structure
	m = stata2mata()
	vnames = dataset_names(m)
	vtypes = dataset_types(m)
	
	// new -dataset- to hold accumulated results
	r = dataset()
	r.nvar = 0
	r.nobs = 0
	
	// copy over the data label and characteristics
	r.dlabel = m.dlabel
	r.chars = m.chars
	
	// initialize dynamic array resizing variables
	z = dynamic_resize()
	if (usersize > 0) z.curdim = usersize
	else z.curdim = rows(gindices)
	z.cum_gobs = gindices[.,2]	
	z.dta_nobs = m.nobs

	// initialize variable name lookup variables
	a = name_lookup()
	a.vindex = asarray_create()
	
	// initialize status report data
	if (status == "status") sinfo = status_report_init(timer, rows(gindices))
	
	// number of groups where user's program terminates with error or no data
	gerrors = gnodata = 0


	break_event = 0
	for (g=1; g<=rows(gindices); g++) {
	
		st_dropvar(.)
		
		g1 = gindices[g,1]
		gN = gindices[g,2]
		st_addobs(gN - g1 + 1, 1)
		
		(void) st_addvar(vtypes, vnames, 1)
		
		mata2stata_range(m, g1, gN)

		rc = _stata("version " + vcaller + ":" + pname, (verbose!="verbose"))
		
		if (rc == 1) {
			break_event = 1
			printf("\n\n\n{err}{dup 15:*} BREAK {dup 16:*}{txt}\n", )
			break
		}
		
		if (rc) gerrors++
		else if (st_nvar() & st_nobs()) store_data(g, r, z, a)
		else gnodata++
	
		if (status == "status") 
			status_report(sinfo, g, gerrors, gnodata, m.nobs, gN, r.nobs)
		
	}


	if (status == "status") {
		timer_off(timer)
		timer_clear(timer)
	}
	final_report(rows(gindices), gerrors, gnodata, m.nobs, r.nobs)


	// reinitialize to free-up memory
	m = dataset()

	// pad or truncate colvectors to match the number of observations
	adjust_array_size(r)

	// move results to Stata
	mata2stata(r)
	
	if (break_event) exit(error(1))

}


/*
-------------------------------------------------------------------------------

store_data()
============

Stores what's left in Stata's data in memory after the user's program
terminates.

-------------------------------------------------------------------------------
*/

void store_data(

	real scalar g,
	struct dataset        scalar r,
	struct dynamic_resize scalar z,
	struct name_lookup    scalar a

)
{

	real scalar j, nvar, nobs, i1, iN, newrows, projected, jj
	
	string rowvector names
	
	struct vardata scalar v1
	

	nvar = st_nvar()
	nobs = st_nobs()
	names = st_varname((1..nvar))
	
	/*
	Rebuild indices to stored colvectors. Because associative array
	lookups are computationally costly as compared to the task of
	moving the relevant data, we reuse the index vector if the
	variable names have not changed. 
	*/
	if (a.prev_vars != names) {
	
		a.jv = J(1, nvar, .)
		for (j = 1; j <= nvar; j++) {
		
			if (!asarray_contains(a.vindex, names[j])) {
				r.nvar  = r.nvar + 1
				a.jv[j] = r.nvar
				asarray(a.vindex, names[j], r.nvar)
				v1 = vardata()
				v1.name   = names[j]
				v1.type   = st_vartype(j)
				v1.label   = st_varlabel(j)
				v1.vallab   = st_varvaluelabel(j)
				v1.format   = st_varformat(j)
				v1.is_str = st_isstrvar(j)
				if (v1.is_str) v1.d = ""
				else v1.d = .
				r.v = r.v , v1
			}
			else {
				a.jv[j] = asarray(a.vindex, names[j])
			}
			
		}	
		a.prev_vars = names
	
	}
	
	
	// indices of where to store results
	i1 = r.nobs + 1
	iN = r.nobs + nobs
	
	/*
	Check if we need to grow the colvectors. If so, and if we are
	still processing the first few groups (10), grow only as needed.
	If the pattern after that is that the user's program does not
	change the number of observations, grow to the number of obs in
	the initial data. Otherwise, project based on the ratio of
	cumulative initial observations so far over the total to process.
	The user can specify the -allocate()- option to delay when
	resizing is needed or to avoid it altogether if the dimension
	of the accumulated data is known in advance.
	*/
	if (iN > z.curdim) {
	
		if (g < 10) {	
			newrows = iN - z.curdim
		}
		else {
			if (z.cum_gobs[g] == iN) {
				newrows = z.dta_nobs - z.curdim
			}
			else {
				projected = ceil((iN/z.cum_gobs[g]) * z.dta_nobs)
				newrows = projected - z.curdim
			}
		}
		
		z.curdim = z.curdim + newrows
		
	}


	for (j = 1; j <= nvar; j++) {
	
		// the index to the colvector that matches the variable name
		jj = a.jv[j]
		
		if (r.v[jj].is_str) {
			
			// grow the colvector if needed
			if (rows(r.v[jj].d) < z.curdim)
				r.v[jj].d = r.v[jj].d \ J(z.curdim-rows(r.v[jj].d), 1, "")

			r.v[jj].d[|i1\iN|] = st_sdata(.,j)
		}
		else {
		
			// grow the colvector if needed
			if (rows(r.v[jj].d) < z.curdim)
				r.v[jj].d = r.v[jj].d \ J(z.curdim-rows(r.v[jj].d), 1, .)

			r.v[jj].d[|i1\iN|] = st_data(.,j)
		}
		
		promote_type(r.v[jj], st_vartype(j), st_varformat(j))

	}

	r.nobs = r.nobs + st_nobs()

}


/*
-------------------------------------------------------------------------------

dataset_names()
===============

Creates a rowvector of variable names in a -dataset-

-------------------------------------------------------------------------------
*/

string rowvector dataset_names ( struct dataset scalar dta )
{
	string rowvector n
	real scalar j
	
	n = J(1, dta.nvar, "")
	for (j = 1; j <= dta.nvar; j++) {
		n[j] = dta.v[j].name
	}
	
	return(n)
}


/*
-------------------------------------------------------------------------------

dataset_types()
===============

Creates a rowvector of variable types in a -dataset-

-------------------------------------------------------------------------------
*/

string rowvector dataset_types ( struct dataset scalar dta )
{
	string rowvector t
	real scalar j
	
	t = J(1, dta.nvar, "")
	for (j = 1; j <= dta.nvar; j++) {
		t[j] = dta.v[j].type
	}
	
	return(t)
}


/*
-------------------------------------------------------------------------------

mata2stata_range()
==================

Replace Stata's data in memory with observations in range from a -dataset-.

-------------------------------------------------------------------------------
*/

void mata2stata_range ( 

	struct dataset scalar m,
	real scalar i1, iN 

)
{

	real matrix j
	
	for (j = 1; j <= m.nvar; j++) {
	
		if (m.v[j].is_str) {
			st_sstore(., j, m.v[j].d[|i1\iN|])
		}
		else {
			 st_store(., j, m.v[j].d[|i1\iN|])
		}
		
		if (m.v[j].label  != "") st_varlabel(j, m.v[j].label)
		if (m.v[j].vallab != "") st_varvaluelabel(j, m.v[j].vallab)
		st_varformat(j, m.v[j].format)
	}

}


/*
-------------------------------------------------------------------------------

stata2mata()
============

Move Stata's data in memory to a -dataset-. Variables are moved one at a time.

-------------------------------------------------------------------------------
*/

struct dataset scalar stata2mata ()
{

	struct dataset scalar dta
	real scalar j
	string rowvector names
	
	dta = dataset()
	
	dta.nvar = st_nvar()
	dta.nobs = st_nobs()
	
	dta.dlabel = st_macroexpand("`" + ": data label" + "'")
	
	dta.chars = char2mat()
	
	names = st_varname((1..dta.nvar))
	
	dta.v = vardata(dta.nvar)
	
	for (j = 1; j <= dta.nvar; j++) {
	
		dta.v[j].name   = names[j]
		dta.v[j].type   = st_vartype(1)
		dta.v[j].label  = st_varlabel(1)
		dta.v[j].vallab = st_varvaluelabel(1)
		dta.v[j].format = st_varformat(1)
		
		if (st_isstrvar(1)) {
			dta.v[j].is_str = 1
			dta.v[j].d      = st_sdata(.,1)
		}
		else {
			dta.v[j].is_str = 0
			dta.v[j].d      = st_data(.,1)
		}
		
		st_dropvar(1)
	}

	
	return(dta)
	
}


/*
-------------------------------------------------------------------------------

adjust_array_size()
===================

Since we use a dynamic array approach, the colvector size may exceed the
number of observation in the -dataset-. The colvector may also be short
if there the variable did not appear in the last by-group.

-------------------------------------------------------------------------------
*/

void adjust_array_size ( struct dataset scalar dta )
{

	real scalar j, n
	
	for (j = 1; j <= dta.nvar; j++) {
	
		n = rows(dta.v[j].d)
		
		if (n < dta.nobs) {
			if (dta.v[j].is_str) {
				dta.v[j].d = dta.v[j].d \ J(dta.nobs-n, 1, "")
			}
			else {
				dta.v[j].d = dta.v[j].d \ J(dta.nobs-n, 1, .)
			}
		}
		else if (n > dta.nobs) {	
			dta.v[j].d = dta.v[j].d[|1 \ dta.nobs|]
		}
		
	}

}


/*
-------------------------------------------------------------------------------

char2mat()
==========

Copies all char from dataset in memory to a matrix

-------------------------------------------------------------------------------
*/

string matrix char2mat ()
{

	string matrix c
	real scalar j, k, n, buffer
	string rowvector vname
	string colvector cname
	
	// we do not know how many chars we will find, use a buffer to accumulate
	n = 0
	buffer = 100
	c = J(0, 3, "")
	
	// chars are associated with the dataset using a pseudo variable  "_dta"
	vname = "_dta"
	if (st_nvar()) vname = vname , st_varname((1..st_nvar()))
	
	for (j = 1; j <= cols(vname); j++) {
	
		// get the list of all char names for this variable
		cname = st_dir("char", vname[j], "*")
		
		for (k = 1; k <= rows(cname); k++) {
			
			// expand buffer if needed
			n++
			
			if (n > rows(c)) c = c \ J(buffer, 3, "")
			
			// store the char content
			c[n,1] = vname[j]
			c[n,2] = cname[k]
			c[n,3] = st_global(vname[j] + "[" + cname[k] + "]")
			
		}
		
	}
	
	if (n) c = c[|1,1 \ n,3|]
	return(c)

}


/*
-------------------------------------------------------------------------------

mat2char()
==========

Copies matrix that stores chars to the dataset in memory

-------------------------------------------------------------------------------
*/

void mat2char (string matrix c)
{

	real scalar k
	
	for (k = 1; k <= rows(c); k++) {

		if ( missing(_st_varindex(c[k,1])) ) {
			if ( c[k,1] != "_dta" ) continue
		}
		
		st_global(c[k,1] + "[" + c[k,2] + "]", c[k,3])
		
	}
		

}


/*
-------------------------------------------------------------------------------

promote_type()
==============

When storing data from a new by-group, we may need to promote the variable type
and format if the new type can accomodate larger values or offers more
precision. We follow the model used by -append-.

-------------------------------------------------------------------------------
*/

void promote_type (

	struct vardata scalar v, 
	string scalar new_type,
	string scalar new_fmt
	
)
{
		
	if (v.type == new_type) return
	
	if (v.is_str) {
		
		// already the largest type
		if (v.type == "strL") return
		
		// no change if string to numeric conflict
		if (strpos(new_type, "str") != 1) return
		
		if (new_type == "strL") {
			v.type     = "strL"
			v.format = new_fmt
			return
		}
		
		if ( strtoreal(substr(v.type, 4)) < strtoreal(substr(new_type, 4)) ) {
			v.type   = new_type
			v.format = new_fmt	
		}
		
	}
	else {
	
		
		// already the largest type
		if (v.type == "double") return
	
		// no change if numeric to string conflict
		if (strpos(new_type, "str")) return

		// all types are promoted to double
		if (new_type == "double") {
			v.type   = new_type
			v.format = new_fmt	
			return
		}
		
		// floats stay floats unless new type is long (same with -append-)
		if (v.type == "float") {
			if (new_type == "long") {
				v.type   = "double"
				// stick with the format used with the float
			}
			return
		}
		
		// integer types
		if (v.type == "byte") {
			v.type   = new_type
			v.format = new_fmt	
		}
		else if (v.type == "int" & (new_type == "long" | new_type == "float")) {
			v.type   = new_type
			v.format = new_fmt	
		}
		else if (v.type == "long" & new_type == "float") {
			v.type   = "double"
			v.format = new_fmt	
		}
		
	}
	
}



/*
-------------------------------------------------------------------------------

mata2stata()
============

Replaces Stata's data in memory with the contents of a -dataset-. 

For string variables, we ignore the stored variable type and use a type that
is just wide enough to accomodate the longest string to store.

-------------------------------------------------------------------------------
*/

void mata2stata ( struct dataset scalar dta )
{

	real scalar j

	st_dropvar(.)
	st_addobs(dta.nobs, 1)

	for (j = 1; j <= dta.nvar; j++) {
	
		(void) st_addvar(dta.v[j].type, dta.v[j].name, 1)
		
		if (dta.v[j].is_str) {
			st_sstore(., j, dta.v[j].d)
			dta.v[j].d = ""			
		}
		else {	
			st_store(., j, dta.v[j].d)
			dta.v[j].d = .			
		}
		
		if (dta.v[j].label  != "") st_varlabel(j, dta.v[j].label)
		if (dta.v[j].vallab != "") st_varvaluelabel(j, dta.v[j].vallab)
		st_varformat(j, dta.v[j].format)
		
	}
	
	if (st_nvar()) {
	
		mat2char(dta.chars)
		stata("label data " + `"""' + dta.dlabel + `"""', 0)
		
	}

}


/*
-------------------------------------------------------------------------------

status_report_init()
====================


-------------------------------------------------------------------------------
*/

struct status_info scalar status_report_init (

	real scalar timer,
	real scalar last_group
	
)
{

	struct status_info scalar s
	
	s = status_info()
	s.timer_id    = timer
	timer_on(timer)
	
	s.level = 1
	s.last_time = 0
	
	// report every 1 second for first 5 seconds
	// then, report every 5 second up to end of first minute
	// then, report every 15 second up to end of 10 minutes
	// then, report every 60 second up to end of 1 hour
	// then, report every 5 minutes after that
	s.levels = (5,1 \ 60,5 \ 600, 15 \ 3600, 60 \ ., 300)
	
	// so that we can print the status for the last by-group
	s.ngroups = last_group

	return(s)
}


/*
-------------------------------------------------------------------------------

print_status_header()
=====================


-------------------------------------------------------------------------------
*/

void print_status_header()
{

	printf("{txt}\n")
	printf("  elapsed")
	printf("{col 11}{hline 11} by-groups {hline 10}")
	printf("{col 47}{hline 7} observations {hline 6}")
	printf("{col 76}     time\n")
	printf("     time")
	printf("{col 11}     count")
	printf("{col 22}    errors")
	printf("{col 33}   no-data")
	printf("{col 47}    processed")
	printf("{col 61}        saved")
	printf("{col 76}remaining\n")
	printf("{hline 84}\n")
	displayflush()

}


/*
-------------------------------------------------------------------------------

status_report()
===============

-------------------------------------------------------------------------------
*/

void status_report(

	struct status_info scalar s, // 
	real scalar g,
	real scalar gerrors,
	real scalar gnodata,
	real scalar mN,
	real scalar gN,
	real scalar rN

)
{

	real scalar now
	
	 
	timer_off(s.timer_id)
	now = timer_value(s.timer_id)
	timer_on(s.timer_id)
	
	if (now[1,1] > s.levels[s.level,1] & s.level < rows(s.levels)) {
		s.level = s.level + 1
		printf("(now reporting every %s seconds)\n", strofreal(s.levels[s.level,2]))
		displayflush()
	}
	
	if (now[1,1] - s.last_time > s.levels[s.level,2] | g == s.ngroups) {
		if (s.last_time == 0) print_status_header()
		printf("{res}")
		printf("%9s", sec2hhmmss(now[1,1]))
		printf("{col 11}%10.0fc",g)
		if (gerrors) printf("{col 22}{err}%10.0fc{res}", gerrors)
		else printf("{col 22}%10.0fc", 0)
		printf("{col 33}%10.0fc", gnodata)
		printf("{col 47}%13.0fc", gN)
		printf("{col 61}%13.0fc", rN)
		printf("{col 76}%9s\n", sec2hhmmss(now[1,1]/gN * mN - now[1,1]))
		printf("{txt}")
		displayflush()
		s.last_time = now[1,1]
	}
	
}


/*
-------------------------------------------------------------------------------

final_report()
==============

-------------------------------------------------------------------------------
*/

void final_report(

	real scalar g,
	real scalar gerrors,
	real scalar gnodata,
	real scalar mN,
	real scalar rN

)
{

	printf("\n{hline 38}\n")
	printf("Number of by-groups    = {res}%13.0fc{txt}\n", g)
	printf("by-groups with errors  = ")
	if (gerrors) printf("{err}%13.0fc{txt}\n", gerrors)
	else printf("{res}%13.0fc{txt}\n", 0)
	printf("by-groups with no data = {res}%13.0fc{txt}\n", gnodata)
	printf("Observations processed = {res}%13.0fc{txt}\n", mN)
	printf("Observations saved     = {res}%13.0fc{txt}\n", rN)
	printf("{hline 38}\n")
	displayflush()
	
}


string scalar sec2hhmmss(real scalar n)
{
	real scalar hh, mm, ss
	
	hh = trunc(n / 3600)
	mm = trunc(mod(n,3600) / 60)
	ss = round(mod(n,60))
	
	return(sprintf("%02.0f:%02.0f:%02.0f",hh,mm,ss))

}



end







