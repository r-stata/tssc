/*
mahascore2.ado began 2012feb3
Based on mahascore.ado; then dated 2011dec16.
David Kantor

This is to compute a (squared) Mahalanobis distance measure between either...
a, the means of two populations;
b, two vectors of "points" in variable-space.
Actually, it is between two points; either point may be specified in either way.

We will report the squared and unsquared values; will return the squared value.

Note: dk has old files named mahascore2.ado_save01 and .ado_save02. Those are not
antecedents of the present program, but rather, early versions of what became
mahascores.ado. mahascore2.ado_save03 IS a saved older version of the present 
program.

*/


*! version 1.0.1 2012mar2
/* prior:
1.0.0 2012feb17
*/

prog def mahascore2, rclass
version 8.2
/* changed from 10.1 on 2012mar2 -- to be consistent with other maha... programs.
*/


/*

This allows a pre-calculated inverse covariance matrix (invcovarmat) to be
passed in as an option.  This facilitates prevention of recalculating the
(same) covariances in repeated calls.


`display' tells some things to display: covar, invcov, points.
(points corresponds to means in mahascore and mahascores)

invcovarmat is optional; we are not using a reserved name such as "none" to
indicate to compute the covariances (as was done analogously in mahascore).
Instead, the user must put in the COMPUTE_invcovarmat option.

The user must specify one of invcovarmat or compute_invcovarmat .

We allow weights; this applies only to the computation of the covarmat and the
means.

The result, if not unsquared, ought to be >=0; this should be true if the
invcovariance matrix is truly an inverse covariance matrix, but may not be
in general if an arbitrary matrix is presented.  (Negative resluts are
meaningless.)

The matrix product that we compute to get the result is expected to be >=0 if
invcovariance matrix is truly an inverse covariance matrix.  This is based on
a theorem that asserts that a covariance matrix (and it inverse) are
positive semi-definite.


*/

#delimit ;

syntax varlist [aw fw iw pw] ,
	[
	point1(name)
	point2(name)
	pop1(varname numeric)
	pop2(varname numeric)
	covarpop(varname numeric)
	INVCOVarmat(name) COMPUTE_invcovarmat DISPlay(string)
	EUCLidean
	union
	]
;

#delimit cr



local progname "mahascore2"



local nvars : word count `varlist'



forvalues jj = 1/2 {
	if "`pop`jj''" ~= "" {
		if "`point`jj''" ~= "" {
			disp as err "`progname': point`jj' will be ignored, since pop`jj' was specified"
		}
		/* Create our own set of point`jj' -- the means of `varlist' limited to pop`jj'. */
		tempname point`jj'
		matrix `point`jj'' = J(`nvars', 1, .)
		matrix rownames `point`jj'' = `varlist'
		foreach v of local varlist {
			local rownum = rownumb(matrix(`point`jj''), "`v'")
			summ `v' if `pop`jj'' [`weight' `exp'] , meanonly
			matrix `point`jj''[`rownum', 1] = r(mean)
		}
		local pointlabel`jj' " (means of pop`jj')"
	}
	else {
		/* `pop`jj'' absent */
		if "`point`jj''" ~= "" {
			capture confirm matrix `point`jj''
			if _rc ~=0 {
				disp as error "`progname': point`jj' must be a matrix"
				exit 198
			}

			local r_nrows = rowsof(`point`jj'')
			local r_ncols = colsof(`point`jj'')
			if `r_nrows' ~= `nvars' {
				disp as err "`progname': point`jj' (`point`jj'') must have as many rows as vars in varlist"
				exit 198
			}
			if `r_ncols' ~= 1 {
				disp as err "`progname': point`jj' (`point`jj'') must have 1 column"
				exit 198
			}

			local r_rows : rownames(`point`jj'')

			forvalues j = 1/`nvars' {
				if "`:word `j' of `r_rows''" ~= "`:word `j' of `varlist''" {
					disp as err "`progname': rownames of point`jj' must correspond to varlist"
					exit 198
				}
			}
		}
		else {
			/* `point`jj'' absent */
			disp as err "`progname': you must specify either point`jj' or pop`jj'"
			exit 198
		}
	}
	if index("`display'", "points") {
		disp _new as text "point `jj'`pointlabel`jj'':"
		mat list `point`jj''
	}
}

local covarpop_as_specified "`covarpop'"

if "`covarpop'" == "" {
	if "`pop1'" ~= "" {
		if "`pop2'" ~= "" {
			local covarpop "(`pop1' | `pop2')"
		}
		else {
			local covarpop "`pop1'"
		}
	}
	else {
		if "`pop2'" ~= "" {
			local covarpop "`pop2'"
		}
		else {
			disp as err "`progname': you must specify covarpop if both pop1 and pop2 are absent"
			exit 198
		}
	}
}

/* if covarpop was specified, it trumps pop1 and pop2;
else, the covariance population is the union of pop1 & pop2.
*/

if "`compute_invcovarmat'" ~= "" {
	if "`invcovarmat'" ~= "" {
		disp as err "`progname': note: both compute_invcovarmat and invcovarmat were specified; ignoring invcovarmat"
	}
	tempname cov
	/* covariancemat is an ado by d.k. */
	if ("`pop1'" ~= "") & ("`pop2'" ~= "") & ("`union'" == "") {
		tempname cov1 cov2
		capture covariancemat `varlist' if `pop1' [`weight' `exp'], covarmat(`cov1')
		if _rc {
			disp as err "(1) error from covariancemat"
			error _rc
		}
		if index("`display'", "covar") {
			disp _new as text "covariance matrix cov1:"
			mat list `cov1'
		}

		capture covariancemat `varlist' if `pop2' [`weight' `exp'], covarmat(`cov2')
		if _rc {
			disp as err "(2) error from covariancemat"
			error _rc
		}
		if index("`display'", "covar") {
			disp _new as text "covariance matrix cov2:"
			mat list `cov2'
		}

		tempname one w1 w2 wsum
		gen byte `one' = 1
		summ `one' [`weight' `exp'] if `pop1', meanonly
		scalar `w1' = r(sum)
		summ `one' [`weight' `exp'] if `pop2', meanonly
		scalar `w2' = r(sum)
		scalar `wsum' = `w1' + `w2'
		/* weighted avg matrix */
		mat `cov' = (`w1'/`wsum') * `cov1' + (`w2'/`wsum') * `cov2'
	}
	else {
		tempname cov
		capture covariancemat `varlist' if `covarpop' [`weight' `exp'], covarmat(`cov')
		if _rc {
			disp as err "(3) error from covariancemat"
			error _rc
		}
	}

	if index("`display'", "covar") {
		disp _new as text "covariance matrix:"
		mat list `cov'
	}



	if "`euclidean'" ~= "" {
		/* -euclidean- option means to zero the off-diagonal elements.  It should
		be equivalent to the behavior of the old mahascore; see notes at top.
		This can only apply under the compute_invcovarmat option, as it needs to be
		done BEFORE the inverting.
		The resulting inverted matrix should be just the reciprocals in the diagonal.
		*/
		
		local crows = rowsof(`cov')
		// local ccols = colsof(`cov') -- should equal crows
		forvalues j = 2 / `crows' {
			forvalues k = 1 / `=`j'-1' {
				mat `cov'[`j', `k'] = 0
				mat `cov'[`k', `j'] = 0
			}
		}

		if index("`display'", "covar") {
			disp _new as text "covariance matrix, after euclidean operation:"
			mat list `cov'
		}

	}

	tempname invcov
	/* disp "begin inv(cov)" */
	mat `invcov' = inv(`cov')
	/* -- you may be able to do invsym(`cov')
	But there are pitfalls, if `cov' is not positive-definite.
	(It ought to be at least positive-semidefinite.)
	But we are most correct to use inv().
	*/
	/* disp "end inv(cov)" */
}
else {
	/* compute_invcovarmat not specified */

	if "`invcovarmat'" == "" {
		disp as err "`progname': you must specify compute_invcovarmat or invcovarmat"
		exit 198
	}
	else {
		capture confirm matrix `invcovarmat'
		if _rc ~=0 {
			disp as error "`progname': invcovarmat must be a matrix (inverse covariance)"
			exit 198
		}
	}

	if "`covarpop_as_specified'" ~= "" {
		disp as err "`progname': covarpop will be ignored, since compute_invcovarmat was not specified"
	}
	if "`euclidean'" ~= "" {
		disp as err "`progname': euclidean will be ignored, since compute_invcovarmat was not specified"
	}
	if "`union'" ~= "" {
		disp as err "`progname': union will be ignored, since compute_invcovarmat was not specified"
	}

	local invcov "`invcovarmat'"
}

local rows : rownames `invcov'
local cols : colnames `invcov'

local icrows = rowsof(`invcov')
local iccols = colsof(`invcov')

/*
Equivalently,
 local icrows : word count `rows'
 local iccols : word count `cols'
*/

if `icrows' ~= `iccols' {
	disp as err "`progname': invcovarmat (`invcov') must be square"
	exit 198
}

if `icrows' ~= `nvars' {
	disp as err "`progname': invcovarmat (`invcov') must by kXk where k=num vars in varlist"
	exit 198
}

/* At this point, `iccols' == `nvars', implicitly. */


if index("`display'", "invcov") {
	disp _new as text "invcovariance matrix:"
	mat list `invcov'
}




forvalues j = 1/`nvars' {
	if "`:word `j' of `rows''" ~= "`:word `j' of `varlist''" {
 		disp as err "`progname': rownames of invcovarmat must correspond to varlist"
		exit 198
	}
	if "`:word `j' of `cols''" ~= "`:word `j' of `varlist''" {
		disp as err "`progname': colnames of invcovarmat must correspond to varlist"
		exit 198
	}
}



/*
Computate the score based directly on a matrix expression.
-mahascore- speled this out, but avoided using it for efficency reasons.
But here, it is apropriate.
*/

tempname X Y

matrix `X' = J(`nvars', 1, .)
matrix rownames `X' = `varlist'

foreach v of local varlist {
	local rownum = rownumb(matrix(`X'), "`v'")
	matrix `X'[`rownum', 1] = `point2'[`rownum',1] - `point1'[`rownum',1]
}


if index("`display'", "diff") {
	disp _new as text "difference vector:"
	mat list `X'
}


matrix `Y' = `X'' * `invcov' * `X'  // `Y' is 1x1

/*
disp "listing Y"
mat list `Y'
*/

disp as res "distance result: "
disp "   squared: " `Y'[1,1]
disp " unsquared: " sqrt(`Y'[1,1])

return scalar mahascore_sq = `Y'[1,1]
end  // mahascore2
