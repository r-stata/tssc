/*
ado\mahascore.ado  1-2-2008
David Kantor

Based on earlier mahascore.ado, dated 2-9-2006.

This is to compute a (squared) Mahalanobis distance measure.
Properly, one would want the unsquared value, but our default is to
leave it squared.  But in most usages, the results are used in comparisons
(or sortings); the proportional magnitude is not significant.  So the squared
values are just as good.

We do have an -unsquared- option, for those who prefer the unsquared result.

In Dec. 2007, I was informed that mahascore had a problem in that it
does a (squared) Normalized Euclidean measure -- not a true Mahalanobis
measure (squared or not).  The Normalized Euclidean measure assumes no
correlation between coviariates; equivalently, it assumes that the ellipsoids
are oriented parallel to the axes.  I am now attempting to correct that --
to yield a true (squared) Mahalanobis measure.

2011dec16: changed from use of -word- function to -word- macro extended function; this corrected
a truncation problem that arose with lengthy varlists.

2012feb8: enhanced handling of errors from covariancemat.


*/


*! version 1.0.7 2012feb8
/* prior:
1.0.6 2011dec16
*/

prog def mahascore
version 8.2

/*
A new variable will be computed that reflects the distance between each
observation and one of these:
 a reference observation (the refobs option);
 a tuple of values passed in via the refvals option;
 the means of all the variables (the refmeans option)

`refobs' is an index to the reference observation.


We have a -treated- option; it is used in limiting the covariance and means
calculations to the treated cases.


ALSO: This could be made to have an -in- and an -if-.  (But you might want to
assure that the refobs is in the set defined by those qualifiers.)



This allows a pre-calculated inverse covariance matrix (invcovarmat) to be
passed in as an option.  This facilitates prevention of recalculating the
(same) covariances in repeated calls.

There is another very good reason to have this option.
There are times when you want to run this on a subset of the data, by doing
a drop or keep operation -- but where you want variances calculated on a
larger set.  This happens, in particular, when this is called by mahapick
using the -sliceby- option.


`display' tells some things to display: covar, invcov, means.


invcovarmat is optional; we are not using a reserved name such as "none" to
indicate to compute the covariances (as was done analogously in mahascore).
Instead, the user must put in the COMPUTE_invcovarmat option.

The user must specify one of invcovarmat or compute_invcovarmat .

We allow weights; this applies only to the computation of the covarmat and the
means.

The result, if not unsquared, ought to be >=0; this should be true if the
invcovariance matrix is truly an inverse covariance matrix, but may not be
in general if an arbitrary matrix is presented.  (Negative resluts are
meaningless and will yield missing under the -unsquared- option.)

The matrix product that we compute to get the result is expected to be >=0 if
invcovariance matrix is truly an inverse covariance matrix.  This is based on
a theorem that asserts that a covariance matrix (and it inverse) are
positive semi-definite.


*/


syntax varlist [aw fw iw pw] , gen(name) ///
 [ refobs(numlist integer min=1 max=1 >=1 <= `=_N') ///
 treated(varname numeric) INVCOVarmat(name) COMPUTE_invcovarmat DISPlay(string) ///
 UNSQuared EUCLidean refvals(name) refmeans VERBose float ///
 noCOVTRLIMitation noMEANTRLIMitation ]

/*
refobs is given as a numlist rather than an integer -- so it can be optional
without having to give a default value (which you can't distinguish from
explicitly entering the value).
numlist also enables us to specify the range limits in the syntax instead
of having to test it later.
*/

local progname "mahascore"


if "`verbose'" ~= "" {
 if "`refvals'" ~= "" {
  local refvals_disp "refvals(`refvals')"
 }
 if "`refobs'" ~= "" {
  local refobs_disp "refobs(`refobs')"
 }
 if "`invcovarmat'" ~= "" {
  local invcovarmat_disp "invcovarmat(`invcovarmat')"
 }
 disp as text "`progname' called; `refmeans' `refvals_disp' `refobs_disp' `invcovarmat_disp' `compute_invcovarmat'"
 /* -- we can't display every option. */
}


capture confirm new var `gen'
if _rc ~=0 {
 disp as error "`progname': gen (`gen') must be a new variable"
 exit 198
}

if "`treated'" ~= "" {
 if "`covtrlimitation'" =="" {
  local iftreated_for_cov "if `treated'"
 }
 if "`meantrlimitation'" =="" {
  local iftreated_for_mean "if `treated'"
 }
}


if "`unsquared'" ~= "" {
 local sqrt "sqrt"
}


local nvars : word count `varlist'


if "`refmeans'" ~= "" {
 if "`refvals'" ~= "" {
  disp as err "`progname': refvals will be ignored, since refmeans was specified"
 }
 if "`refobs'" ~= "" {
  disp as err "`progname': refobs will be ignored, since refmeans was specified"
 }
 /* create our own set of refvals -- the means of `varlist' */
 tempname refvals
 matrix `refvals' = J(`nvars', 1, .)
 matrix rownames `refvals' = `varlist'
 foreach v of local varlist {
  local rownum = rownumb(matrix(`refvals'), "`v'")
  summ `v' `iftreated_for_mean' [`weight' `exp'] , meanonly
  matrix `refvals'[`rownum', 1] = r(mean)
 }
 if index("`display'", "means") {
  disp _new as text "means vector:"
  mat list `refvals'
 }
}
else {
 /* `refmeans' absent */
 if "`refvals'" ~= "" {
  if "`refobs'" ~= "" {
   disp as err "`progname': refobs will be ignored, since refvals was specified"
  }

  capture confirm matrix `refvals'
  if _rc ~=0 {
   disp as error "`progname': refvals must be a matrix"
   exit 198
  }

  local r_nrows = rowsof(`refvals')
  local r_ncols = colsof(`refvals')
  if `r_nrows' ~= `nvars' {
   disp as err "`progname': refvals (`refvals') must have as many rows as vars in varlist"
   exit 198
  }
  if `r_ncols' ~= 1 {
   disp as err "`progname': refvals (`refvals') must have 1 column"
   exit 198
  }

  local r_rows : rownames(`refvals')

  forvalues j = 1/`nvars' {
   if "`:word `j' of `r_rows''" ~= "`:word `j' of `varlist''" {
    disp as err "`progname': rownames of refvals must correspond to varlist"
    exit 198
   }
  }
 }
 else {
 /* `refvals' absent */
  if "`refobs'" == "" {
   disp as err "`progname': must specify refobs, refvals, or refmeans"
   exit 198
  }
 }
}




if "`compute_invcovarmat'" ~= "" {
 if "`invcovarmat'" ~= "" {
  disp as err "`progname': note: both compute_invcovarmat and invcovarmat were specified; ignoring invcovarmat"
 }
 /* covariancemat is an ado by d.k. */
	tempname cov invcov
	capture covariancemat `varlist' `iftreated_for_cov' [`weight' `exp'], covarmat(`cov')
	if _rc {
		disp as err "error from covariancemat"
		error _rc
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

 if "`weight'" ~= "" {
  disp as err "`progname': weight will be ignored, since compute_invcovarmat was not specified"
 }
 if "`treated'" ~= "" {
  disp as err "`progname': treated will be ignored, since compute_invcovarmat was not specified"
 }
 if "`euclidean'" ~= "" {
  disp as err "`progname': euclidean will be ignored, since compute_invcovarmat was not specified"
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




if "`refvals'" ~= "" {
 /*
 Note: at this point, `refvals' could be from the refvals option, or computed
 via the refmeans option.
 Create macros for delayed expansion.
 */
 local vjref "`refvals'[\`j',1]"
 local vkref "`refvals'[\`k',1]"
 local vref "`refvals'[\`rownum',1]"
}
else {
 /* `refvals' absent; `refobs' must be filled-in. */
 local vjref "\`vj'[\`refobs']"
 local vkref "\`vk'[\`refobs']"
 local vref "\`v'[\`refobs']"
}


/*---->
This is a computation of the score based directly on a matrix expression.
Unfortunately, it needs to loop through the obs, and is relatively slow.
Below is the alternative; much faster.
Thus, the latter is to be used.
(Testing showed the reuslts to be equal or very close -- differences of
about 4e-14.)
----
quietly gen double `gen' = .
tempname X Y /* Xt */

forvalues obsno = 1/`=_N' {
 matrix `X' = J(`nvars', 1, .)
 matrix rownames `X' = `varlist'

 foreach v of local varlist {
  local rownum = rownumb(matrix(`X'), "`v'")
  matrix `X'[`rownum', 1] = `v'[`obsno'] - `vref'
 /* last term should be  `v'[`refobs'] or `refvals'[`rownum',1]
 */
 }

 /*
 disp "obsno=`obsno', ---- listing X:"
 mat list `X'

 matrix `Xt' = `X''
 disp "obsno=`obsno', ---- listing Xt:"
 mat list `Xt'
 */

 matrix `Y' = `X'' * `invcov' * `X'  // `Y' is 1x1
 /*
 disp "listing Y"
 mat list `Y'
 */
 quietly replace `gen' = `sqrt'(scalar(`Y'[1,1])) in `obsno'
}
<-----*/

/* The preferred alternative, following the method in _Dif_mbase in psmatch2 by
Leuven & Sianesi.
Calculate the equivalent matrix expression -- as a dataset variable.
(They also do a trick based on the matrix being symmetrical; we don't do that
here; we assume a generic matrix at this point.
They also use a trick based on tokenizing a varlist. We don't do that here.)
*/
quietly gen double `gen' = 0
forvalues j = 1 / `icrows' {
 forvalues k = 1 / `icrows' {  /* or iccols -- the same */
  local vj : word `j' of `rows'
  local vk : word `k' of `rows' /* or cols -- should be the same */
  quietly replace `gen' = `gen' + ///
   `invcov'[`j,', `k'] * (`vj' - `vjref') * (`vk' - `vkref')
 }
}

if "`unsquared'" ~= "" {
 quietly replace `gen' = sqrt(`gen')
 /* Note that this sqrt goes with the "alternative" computation -- not the
 matrix-expression computation, as that has `sqrt' built into it.
 */
}


if "`float'" ~= "" {
 quietly recast float `gen', force
}
/* Note: for the float option, this -recast- at the end is more accurate than
declaring `gen' to be float in the first place; that would introduce rounding
at each stage of adding up many terms.
*/



end  // mahascore

