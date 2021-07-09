*! version 2.1.1   18may2001
/* QAP.ADO -- Run QAP simulations */
program define qap, rclass
        version 6.0

/* MODIFICATION LOG:
        9/10/1999 -- Added EXTRAKY and CAPTURE
        7/13/2000 -- Allow triangular and full matrices, test for validity
        1/9/2001 -- Drop EXTRAKY -- Add TIMEVAR for panel data
                    Add GROUPVR for groups
*/

/* -----------------------------------------------------------------------
   CALL:  qap progname varlist [, Reps(int 500)
                SAving(str) DOUBle EVery(passthru) REPLACE LEAVE
                NOIsily Dots COUnt DEBUG noTABle noDISP
                ARgs(str) CMD(passthru) STats(passthru) CAPture
                TImevar(varlist) GRoupvr(varlist)]
   	PROGNAME is the program to call at every iteration
	VARLIST contains a list of variables that will be in the
		permuted portion of the data set.  The first two
		variables MUST be the row and column identifiers.
        Options are the same as for -bstrap-, except
           COUNT, which prints the iteration count at every step
           DEBUG -- Print debugging output
           NOTABLE -- Does not print the QAP distribution, only prints
                the percentile of the actual value in the distribution
           TIMEVAR -- list of within-matrix time (sequence) variables for panel data
           GROUPVR -- list of grouping variables -- matrix size and permutations
                are different for each group
           Any variables specified in TIMEVAR and GROUPVR are kept in both halves
                of the split file and used as merge keys
           CMD -- command option to pass to program
           STATS -- stats option to pass to program
           CAPTURE -- Continue if PROGNAME fails to produce an estimate
-------------------------------------------------------------------------*/

/*------------------------------------------------------------------------
   Parse.
	The first parsing step splits the options off and leaves
	  them in 0.  ONLY the comma is a parsing character.
	  Everything except the options (program name and variable
	  list) goes into `first'.
	Next, the -syntax- command is used to check the options list,
	  and consistency of options is checked for EVERY and REPLACE.
	Next, the first part is tokenized to make sure there are
	  at least 4 arguments (program name, row var, column var,
	  and at least one other variable for permuting.  Note that
	  these variables don't have to exist in the data set at
	  this point because the user may load the data set in the
	  first call, so -syntax- is not used yet.  Program name
	  is loaded into a named macro `prog'.
    The variable list is not parsed until after the first call to `prog',
      because the user may load the data file on the initialization call
      to `prog'.
-------------------------------------------------------------------------*/

	gettoken first 0: 0, parse(",")

    syntax [, Reps(int 500) Dots SAving(str) /*
                */ DOUBle EVery(passthru) REPLACE LEAVE NOIsily COUnt /*
                */ ARgs(str) CMD(passthru) STats(passthru) DEBUG noTABle noDISP /*
                */ TImevar(string) GRoupvr(string) CAPture]

	tokenize `first'
    local reqargs = 4
    if `"``reqargs''"'=="" {
            di in red "At least `reqargs' arguments required:"
            di in red "   Program name,"
            di in red "   row and column variables,"
            di in red "   and at least one analysis variable"
            exit 198
	}
	gettoken prog vlist: first , parse(" ")
    *di "PROG = `prog'"
    *di "VLIST = `vlist'"
      /* If SAVING is not specified, generate a temporary file and give
	     it the same macro name.  Also check that options EVERY and REPLACE
	     are only used with the SAVING option
           `dots', `count', and `debug' use a trick from the -bstrap- program.  If
             they are not specified, they are replaced by an asterisk, which
	     will create a comment statement.  If they are specified, they are
	     replaced by "noisily", which will execute and print the statement.
	*/

	local dots = cond("`dots'"=="", "*", "noisily")
	local count = cond("`count'"=="", "*", "noisily")
    local dbgcmd = cond("`debug'"=="", "*", "noisily")

	if `"`saving'"'=="" {
		tempfile saving
		local filetmp "yes"
        if "`every'"!="" {
                di in red "every() can only be specified when " /*
                */ "using saving() option"
                exit 198
        	}
        	if "`replace'"!="" {
                di in red "replace can only be specified when " /*
                */ "using saving() option"
                exit 198
        	}
	}

/*------------------------------------------------------------------------
   	USER INITIALIZATION:
	User program is called before preserve in case initializer
   	   wants to load some data set.
 	The first call to the user program has first parameter "?"
       The program must return the variable list to be kept in global $S_1
	Note -- macro variable `toprog' contains a snippet of text to display
	At the end of this section, macro `vl' contains the list of variable names
	   that will be used in the post file.
	Also, at this point the variable list in the original call can be checked.
        Macro variables `row', `col', will be generated containing the
                variable names for row, column.
-------------------------------------------------------------------------*/
/* NOTE  The user-supplied program `prog' is called here.  This means that
   if the user-supplied program loads a data set, the data set will be
   loaded prior to syntax checking the variable names in the argument
   list.  If the program is _qap, it is not called until later.
   Syntax checking of variables is done prior to the call,
   because _qap does not load data. */
        global S_1
		local toprog `""to " in yellow "`prog' ""'
        quietly `noisily' di _n in green "Call " `toprog' /*
        */ in gr "with ? query to initialize variable names" _n
        if ("`prog'" ~= "_qap") {
        capture `noisily' `prog' ? `args' , `cmd' `stats' `debug'
        if _rc {
            if _rc==199 {
                di in red `"program `prog' not found or"'
                di in red `""`prog' ?""' /*
                */ `" attempted to execute an unrecognized"' /*
                */ `" command"'
                exit 199
            }
            di in red `""`prog' ?" returned:"'
            error _rc
        }
        if `"$S_1"'=="" {
            di in red `""`prog' ?" did not set \$S_1"'
            exit 198
        }
        local vl `"$S_1"'
        }

        /* Syntax check variable list and set `anvars' to analysis variables */
        capture {
          confirm variable `vlist'
          gettoken row rest: vlist
          gettoken col anvars: rest
          confirm numeric variable `row'
          confirm numeric variable `col'
          if ("`timevar'" ~= "") {
            confirm variable `timevar'
            local timeopt "timevar(`timevar')"
          }
          if ("`groupvr'" ~= "") {
            confirm variable `groupvr'
            local groupop "groupvr(`groupvr')"
          }
        }
        if (_rc~=0) {
            di in red "A VARIABLE DOES NOT EXIST IN YOUR DATA SET OR IS THE WRONG TYPE"
            di in red "VARIABLES REQUIRED ARE `vlist' `timevar' `groupvr'"
            error _rc
        }
        capture _qapchek `row' `col' , `timeopt' `groupop'
        if (_rc~=0) {
            di in red "ROW AND COLUMN VARIABLES DO NOT DEFINE A SQUARE MATRIX."
            di in red "MATRIX MUST BE FULL SQUARE OR UPPER/LOWER TRIANGULAR."
            di in red "ROW VARIABLE IS `row',  COLUMN VARIABLE IS `col'."
            exit(999)
        }

        /* If using internal _qap program, error messages are displayed by the program */
        if ("`prog'" == "_qap") {
            quietly `noisily' `prog' ? `args' , `cmd' `stats' `debug'
            local vl `"$S_1"'
        }

/*------------------------------------------------------------------------
	At this point, all the syntax checks have been passed.
	QAP INITIALIZATION:
	Preserve the data set.
	Initialize the postfile.
		Note that double, every, and replace are options for postfile
		that are passed as is from the original call to qap.
	Then, split the file into the part that will be permuted (`permfil')
	   and the part that will stay unchanged (`stayfil').  The permuted
	   file contains the variables specified in the varlist of the qap call.
	Also, generate:
	 	`permvec' -- a temporary file name for the permutation vector.
		`maxsub' -- the highest subscript number for `col'
		`key' -- temporary variable to hold key in permutation file
		`perm' -- temp variable to hold permuted key in permutation file
-------------------------------------------------------------------------*/

	preserve

	tempname postnam
    quietly `noisily' display "CREATING POSTFILE NAME `postnam' SAVING `saving'"
    quietly `noisily' display "VARIABLE LIST `vl'   OPTIONS  `double' `every' `replace'"
    postfile `postnam' `vl' using `"`saving'"', `double' `every' `replace'

	tempfile permfil
	tempfile stayfil
	tempfile permvec
    tempfile sizefil
    tempvar key
	tempvar perm
    tempvar sizevar

    /* Split the file into permuted and stationary portions */
    quietly {
    sort `groupvr' `row' `col' `timevar'
    keep  `groupvr' `row' `col' `timevar' `anvars'
    save `permfil'
    restore, preserve
    drop `anvars'
    sort `groupvr' `row' `col' `timevar'
    save `stayfil'
    restore, preserve
    }

   /* Create file of sizes for `permvec' */
    quietly {
    if ($QAPMTYP==3) {
        local countvr `col'
    }
    else {
        local countvr `row'
    }
    keep `groupvr' `countvr'
    if ("`groupvr'" ~= "") {
        local bygroup "by `groupvr':"
        local groupop "groupvr(`groupvr')"
    }
    sort `groupvr' `countvr'
    `bygroup' keep if _n==_N
    rename `countvr' `sizevar'
    save `sizefil'
    restore, preserve
    }

/*------------------------------------------------------------------------
	QAP LOOP:
	The first call uses the original data set.  This becomes the first
	   observation of the postfile, but later will be stripped off and
	   the values will be set as characteristics of the variables.
	The remaining calls use a QAP permutation of the data set.
-------------------------------------------------------------------------*/

        quietly {
		/* First call -- use original data set */
		`noisily' di _n in gr "First call " `toprog' in gr "with dataset as is:" _n
        `noisily' di "CALLING `prog' with POSTFILE `postnam'"
        `noisily' `prog' `postnam' `args'  , `cmd' `stats' `debug'

		`noisily' di _n in ye "`reps'" in gr " calls " `toprog' in gr "with QAP samples:" _n

		/* Loop for `reps' samples */
		local i 1
		while `i' <= `reps' {
			`dots' di in gr "." _c
			`count' di in gr "ITERATION `i'"

            /* Generate QAP sample.  Call -qapvec- and -qapperm- */
            `dbgcmd' di "ARGS FOR QAPVEC `permvec' `key' `perm' `maxsub'  `debug'"
            _qapvec `key' `perm' `sizevar' using `permvec', sizefil(`sizefil') replace  `debug' `groupop'
            use `permfil', clear
            _qapperm `row' `col' using `permvec' , keyvar(`key') permvar(`perm') mtype($QAPMTYP) `groupop'
            /* `dbgcmd' di "PERMUTED FILE"
            `dbgcmd' list */
            sort `groupvr' `row' `col' `timevar'
            merge `groupvr' `row' `col' `timevar' using `stayfil'
            `dbgcmd' tab _merge
            assert _merge == 3
            drop _merge

            `noisily' di "CALLING `prog' with POSTFILE `postnam'"
            `noisily' `prog' `postnam' `args' , `cmd' `stats' `capture'
			local i = `i' + 1
		}
		`dots' di
		postclose `postnam'

/*------------------------------------------------------------------------
	PROCESSING POST FILE:
	Load the post file.
	Take the values from the first observation (using the original data)
	   and load the values as characteristics of each variable.
	Then delete the observation so it won't contaminate the
	   simulated data.
	If the LEAVE option is specified, leave the simulation data set in
	   memory.  If not, Stata will automatically restore the data set
	   to the state after the -preserve-.
-------------------------------------------------------------------------*/

		capture use `"`saving'"', clear
		if _rc {
			if _rc >= 900 & _rc <= 903 {
				di in red "insufficient memory to load " /*
				*/ "file with bootstrap results"
			}
			error _rc
		}

		label data "QAP Bootstrap Sample"

		tokenize `"`vl'"'
		local i 1
		while `"``i''"'!="" {
			local x = ``i''[1]
			char ``i''[QAP] `x'
                        if `"$S_QAPlab"'~="" {
                                local varlab : word `i' of $S_QAPlab
				label variable ``i'' `"`varlab'"'
                        }
                        local i = `i' + 1
		}
		drop in 1

		if `"`filetmp'"'=="" { quietly save `"`saving'"', replace }

        }               /* end of quietly block */

        /* Print statistics */
        _qapstat _all, `table' `disp'

        if "`leave'"!="" {
            global S_FN
            restore, not
        }


/*------------------------------------------------------------------------
   End of qap program -- return results from qapstat and exit
------------------------------------------------------------------------*/
    return add
end



program define _qap
	version 6.0

/*------------------------------------------------------------------------
   _qap -- Program user can specify to call by QAP
------------------------------------------------------------------------*/


/*------------------------------------------------------------------------
   Parse.
	The first parsing step splits the options off and leaves
	  them in 0.  ONLY the comma is a parsing character.
	  Everything except the options (program name and variable
	  list) goes into `first'.
        Then `first' is tokenized to set up macro variables `1' etc.
-------------------------------------------------------------------------*/

        gettoken first 0: 0, parse(",")
	tokenize `first'
        syntax , cmd(str) stats(str) [ debug noisily capture]
        `noisily' di "CMD string is |`cmd'|"
        `noisily' di  "STATS string is |`stats'|"

/*------------------------------------------------------------------------
   First call processing (when first parameter is ?):
        1) Run the command to see if it generates an error
        2) Parse the `stats' list and create:
           `vl' and $S_1 with the variable list (qap1, qap2, etc.)
           `lab' and $S_QAPlab with a list of variable labels (original
                specifications of the statistics, e.g. _b[varname])
           `stats' and $S_QAPst with the list of statistics (statistics
                surrounded by parentheses)
        The list parsing was adapted from bs.ado
-------------------------------------------------------------------------*/

        if "`1'" == "?" {
                capture `cmd'
                if _rc {
                        di in red `"error when command executed on original dataset"'
                        di in red  `"COMMAND: `cmd'"'
                        error _rc
                }

                tokenize `stats'
                local stats /* erase macro -- individual items are in `1' etc */
                local i 1
                while `"``i''"'!=`""' {
                        local vl     `"`vl' qap`i'"'
                        local labs   `"`labs' ``i''"'
                        local stats  `"`stats' (``i'')"'

                        local i = `i' + 1
                }
                global S_QAPlab `labs'
                global S_QAPst `stats'
                global S_1 `vl'
                capture di $S_QAPst
                if _rc {
                        di in red  `"error in statistics list: `labs'"'
                        error _rc
                }
        exit
	}

/*------------------------------------------------------------------------
   All other calls:
        1) Run the command on the data set in memory
        2) Post the results using the `stats' list
   Note that the capture processing is a little tricky.
   If the estimates do not exist, then:
   -capture post postfile estimates- will fail and will return
   a non-zero _rc, but the postfile will be deleted.  To test that
   the estimates exist, we use -capture display- instead.  If any
   estimate does not exist, then the statistics list is parsed and
   each statistic checked.  Any that don't exist are replaced with
   missing values.
-------------------------------------------------------------------------*/

        args postnam
        `cmd'
        local qapstat `"$S_QAPst"'
        if "`capture'" ~= "" {
                capture di `qapstat'
                if _rc ~= 0 {
                        di in red "PARAMETER ESTIMATES NOT FOUND, _rc " _rc
                        di in red "SOME ESTIMATES WILL BE MISSING IN THE QAP FILE"
                        tokenize `qapstat', parse(" ")
                        local qapstat
                        local i 1
                        while `"``i''"'!=`""' {
                            capture di ``i''
                            if _rc~=0  {
                                local `i' .
                            }
                            local qapstat `"`qapstat' ``i''"'
                            local i = `i' + 1
                        }
                }
        }
        post `postnam' `qapstat'
end

/* _QAPCHEK -- Test input for valid matrix or set of matrices */
program define _qapchek
version 6.0
/* NEW VERSION WITH TIMEVAR AND GROUPVR */
/* Testing row and column numbers for valid matrix */
/* If valid, returns $QAPMTYP
	1 = square
    2 = lower triangle
    3 = upper triangle
   Also returns $QAPDIAG
    0 = without diagonal
    1 = with diagonal
   If not valid, returns an error code and $QAPMTYP=0
   If this is called by another ado file, it should be surrounded
     by -capture- in order to prevent the outer ado from failing,
     and should issue an appropriate error message
*/
syntax varlist(min=2 max=2) [,timevar(varlist) groupvr(varlist)]
local i : word 1 of `varlist'
local j : word 2 of `varlist'
global QAPMTYP = 0
quietly {
preserve
keep `i' `j' `timevar' `groupvr'
assert `i' ~= .
assert `j' ~= .
/* Get statistics on i and j -- used to categorize
   type of matrix */
quietly summarize `i'
local maxrow = r(max)
local minrow = r(min)
local meanrow = r(mean)
quietly summarize `j'
local maxcol = r(max)
local mincol = r(min)
local meancol = r(mean)
sort `groupvr' `timevar' `i' `j'
tempfile ijfile
save `ijfile'

/* Categorize the type of matrix.  This code should work correctly for any
   valid type of matrix, including those with groups.  This should work even
   though the means have finite precision, because exactly the same set of
   integer values are being used if the matrix is actually square */
/* Local variables set up:
    minrtst -- required minimum value for row number in every group/panel
        (2 if lower triangle and no diagonal, 1 otherwise)
    minctst -- required minimum value for column number in every group/panel
        (2 if upper triangle and no diagonal, 1 otherwise)
    maxdif -- required value for maximum row number - maximum column number
        (0 if diagonal is present, +1 if lower triangle, -1 if upper)
*/

if (`meanrow' > `meancol') {
    local mtype 2
}
else if (`meanrow' < `meancol') {
        local mtype 3
}
else {
    local mtype 1
}

if (`minrow' == `mincol') {
    local mdiag 1
    local minrtst 1
    local minctst 1
    local maxdif 0
}
else {   /* Triangle without the diagonal */
    local mdiag 0
    if (`mtype'==2) {
    local minrtst 2
    local minctst 1
    local maxdif 1
    }
    else if (`mtype'==3) {
    local minrtst 1
    local minctst 2
    local maxdif -1
    }
}

/* Set up local variables with various BY statements and options for combinations of
   group and panel variables */

if ("`groupvr'`timevar'") ~= "" {
    local byvars "by `groupvr' `timevar':"
    local byopt "by(`groupvr' `timevar')"
}

if ("`groupvr'" ~= "") {
    local bygroup "by `groupvr':"
}

tempvar vmaxrow vmaxcol   /* Used to hold maximum row and column numbers for each group/panel */

/* If there are time variables, make sure the maximum limits are the same on each panel.
   The maximum values can be different in each group.  The minimum values are tested later */
if "`timevar'" ~= "" {
  collapse (max) `vmaxrow'=`i' `vmaxcol'=`j' , `byopt' fast
  `bygroup' assert `vmaxrow' == `vmaxrow'[1]
  `bygroup' assert `vmaxcol' == `vmaxcol'[1]
  use `ijfile' , clear
  }


/* Tests with the data sorted by row, then column, within group/panel */
/* For all forms of matrices
    1) the first observation in the group must have the correct minimum row and column numbers
    2) the last observation must have the correct relationship between maximum row and column numbers
    2) j must be sequential within i
*/
`byvars' assert `i' == `minrtst' if _n == 1
`byvars' assert `j' == `minctst' if _n == 1
`byvars' assert (`i'-`j') == `maxdif' if _n == _N
by `groupvr' `timevar' `i': assert `j' == (`j'[_n-1]+1) if _n ~= 1

/* Tests with the data sorted by column, then row, within group/panel */
/* For all forms of matrices
    1) the first observation in the group must have the correct minimum row and column numbers
    2) the last observation must have the correct relationship between maximum row and column numbers
    2) i must be sequential within j
*/

sort `groupvr' `timevar' `j' `i'
`byvars' assert `i' == `minrtst' if _n == 1
`byvars' assert `j' == `minctst' if _n == 1
`byvars' assert (`i'-`j') == `maxdif' if _n == _N
by `groupvr' `timevar' `j': assert `i' == (`i'[_n-1]+1) if _n ~= 1

sort `groupvr' `timevar' `i' `j'

egen `vmaxrow' = max(`i') , `byopt'
egen `vmaxcol' = max(`j') , `byopt'
sort `groupvr' `timevar' `i' `j'
save `ijfile' , replace

/* For all forms that include the diagonal, the following must be true:
    Row numbers must be sequential starting with 1
    Column numbers for the first column must equal 1 or the row number
*/
if (`mdiag' == 1) {
  by `groupvr' `timevar' `i': keep if _n==1
  `byvars'  assert `i' == _n
  /* Test the details of each case */
  if (`mtype' ~= 3) {    /* Square or lower triangle */
    by `groupvr' `timevar' `i': assert `j'==1
    }
  else {                       /* upper triangle */
    by `groupvr' `timevar' `i': assert `j'==`i'
    }
  use `ijfile', clear
  by `groupvr' `timevar' `i': keep if _n==_N
  if (`mtype' ~= 2) {    /* Square or upper triangle */
    by `groupvr' `timevar' `i': assert `j'==`vmaxcol'
    }
  else {                       /* lower triangle */
    by `groupvr' `timevar' `i': assert `j'==`i'
    }
  restore
  global QAPMTYP = `mtype'
  global QAPDIAG = `mdiag'
  exit(0)            /* Succeeds */
  }
 else if (`mtype'==2) {   /* lower triangle with no diagonal */
   by `groupvr' `timevar' `i': keep if _n==1
   `byvars'  assert `i' == (_n+1)
   by `groupvr' `timevar' `i': assert `j'==1
   use `ijfile',clear
   by `groupvr' `timevar' `i': keep if _n==_N
   by `groupvr' `timevar' `i': assert `j' == (`i'-1)
   global QAPMTYP = 2
   global QAPDIAG = 0
   restore
   exit(0)
 }
 else {    /* upper triangle with no diagonal */
   by `groupvr' `timevar' `i': keep if _n==1
   `byvars' assert `i' == _n
   by `groupvr' `timevar' `i': assert `j'==(`i'+1)
   use `ijfile',clear
   by `groupvr' `timevar' `i': keep if _n==_N
   by `groupvr' `timevar' `i': assert `j' == `vmaxcol'
   global QAPMTYP = 3
   global QAPDIAG = 0
   restore
   exit(0)
 }
}
end

/*  _QAPVEC -- Generate a permutation vector */
/*  Arguments:
        When _QAPVEC is called, there must be a data set containing size(s) of
            vectors to generate.  It must contain a variable `sizevar', and
            optional grouping variables `groupvr'.
        subscrp newsub using , sizevar(varname) [groupvr(varlist) debug replace ]
        USING must be a valid filename (existing or new)
        SIZEVAR is the name of the variable containing size(s) of vector(s) to generate
        SUBSCRP and NEWSUB must be valid names for Stata variables
        GROUPVR, if present, specifies a list of grouping variables
        DEBUG will print the permutation vector
        REPLACE must be specified if the file is to be replaced
    Result is a file containing permutation vector(s) with original index and new index
        If GROUPVR is non-blank, there will be different vectors for each group
    NOTE -- For use by QAPPERM with default options ,
            SUBSCRP should be "key", NEWSUB be "perm"
*/

program define _qapvec
	version 6.0
    syntax newvarlist(min=3 max=3) using/, sizefil(string) [groupvr(varlist) debug replace]
    tokenize `varlist'
    preserve
    use `sizefil', clear
    local subscrp `1'
    local newsub `2'
    local sizevar `3'
    expand `sizevar'
    if "`groupvr'" ~= "" {
        local bygroup "by `groupvr':"
        sort `groupvr'
    }
    tempvar random
	gen `random' = uniform()
    `bygroup' gen int `newsub' = _n
    sort `groupvr' `random'
	drop `random'
    `bygroup' gen int `subscrp' = _n
    order `groupvr' `subscrp'
    sort `groupvr' `subscrp'    /* Already sorted, but have to sort so Stata knows */
    drop `sizevar'
    save `using',`replace'
    if ("`debug'" ~= "") & ("`debug'" ~= "*") {
            noisily display "PERMUTATION VECTOR"
            list
    }
    restore
end

/* _QAPPERM -- Permutes subscripts on dataset */
/* Call:  _qapperm  rowvar colvar using/, keyvar(varname) permvar(varname)
   Assumes the -using- file contains two variables, -key- and -perm- if
	keyvar and/or permvar are not specified
 MODIFICATION LOG:
    1/10/2001 -- Added GROUPVR option
*/
program define _qapperm
	version 6.0
    syntax varlist(min=2 max=2) using , mtype(integer) [groupvr(varname) keyvar(string) permvar(string)]
	local 0 `varlist'
	args row col
	if "`keyvar'" == "" {
		local keyvar key
	}
	if "`permvar'" == "" {
		local permvar perm
	}

	rename `row' `keyvar'
    sort `groupvr' `keyvar'
    merge `groupvr' `keyvar' `using', nokeep
	assert _merge == 3
	rename `permvar' `row'
	drop `keyvar' _merge

	rename `col' `keyvar'
    sort `groupvr' `keyvar'
    merge `groupvr' `keyvar' `using', nokeep
	assert _merge == 3
	rename `permvar' `col'
	drop `keyvar' _merge

    /* Row and column numbers have been permuted.  If the original
       matrix was lower/upper triangular, it may no longer be.
       Swap subscripts as necessary */

    if (`mtype'~=1) {
        tempvar swap
        tempvar hold
        if (`mtype'==2) {
            mark `swap' if `row' < `col'
        }
        else {
        mark `swap' if `row' > `col'
        }
        gen `hold' = `row' if `swap'
        replace `row' = `col' if `swap'
        replace `col' = `hold' if `swap'
        drop `swap' `hold'
    }
    sort `groupvr' `row' `col'

end

/* _QAPSTAT.ADO -- Print QAP statistics given simulation file */
program define _qapstat, rclass
        version 6.0
        syntax varlist[, noTABle noDISP]
        if ("`table'" == "") {
                di _n _n "QAP empirical distributions of all estimates"
                di "Assuming null hypothesis"
                summ _all, detail
        }
        tokenize `varlist'
        if ("`disp'" == "") {
            di _n "Percentiles of actual estimates in null distributions:"
        }
        tempname obsrved
        local i 1
        while ("``i''" ~= "") {
                local statnam : variable label ``i''
                local statval : char ``i''[QAP]
                *di "STATNAM `statnam'   STATVAL `statval'"
                capture scalar `obsrved' = `statval'
                if _rc {
                        di in red `"estimates of observed "' /*
                        */ `"statistic for ``i'' not found"'
                        exit 111
                }
                _qap1st ``i'' `statnam' `statval' `disp'
                local i = `i' + 1
        }
        return add
end

program define _qap1st, rclass
        version 6.0
        args varname statnam statval disp
        tempvar count
        tempname pctile roundob
        gen `count' = (`statval' > `varname') if `varname' ~= .
        quietly summ `count'
        scalar `pctile' = round(100*r(sum)/(r(N)),.01)
        scalar `roundob' = round(`statval',.0001)
        if ("`disp'" == "") {
            di _n in yellow "   Statistic " in white "`statnam'" in yellow  /*
              */ " observed value was " in white `roundob'
            di "   This has percentile " in white `pctile' in yellow /*
            */ " of the QAP simulated statistics" _n
        }
        return scalar pctile = `pctile'
        return scalar statval = `statval'
end

