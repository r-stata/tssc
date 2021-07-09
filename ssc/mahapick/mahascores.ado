/*
mahascores.ado
David Kantor
Began 2-19-2008

This will call mahascore repeatedly to form the full set of Mahalanobis
distances between every pair of observations (possibly limited if -treated()-
is specified).

See mahascore.ado for more background.

There are 3 ways to get the results:
 varprefix()
 genmat()
 genfile()


Changes made around 21mar2008:
 idvar is optional; for defaults, you get...
  obs1, ons2, etc. as row & col names;
  `varprefix'1, `varprefix'2, etc. as varnames;
  values 1, 2 (numeric) in the genfile.

 Changed prime_id to name1; added name2. Defaults depend on whether idvar is
 present.

 Added an option for transposing the matrix.

 Using a tempname for the genfile handle; improves break behavior.


2012feb8: enhanced handling of errors from covariancemat.

*/


*! version 1.0.7 2012feb8
/* prior:
1.0.6 31mar2008 (or apr 1)
*/

prog def mahascores
version 8.2


/*
A set of new variables will be computed that reflects the distance between each
observation and the other observations.

Alternatively, a matrix is generated.
Or a file is written.

We have a -treated- option; it is used in limiting the covariance calculations
to the treated cases.  It also limits the vars (or matrix rows) generated,
unless -all- is specified.

*/

#delimit ;

syntax varlist [aw fw iw pw] ,
 [
 idvar(varname)

 varprefix(string)
 genmat(name)
 genfile(string) name1(name) name2(name) scorevar(name) replace full 

 treated(varname numeric) INVCOVarmat(name) COMPUTE_invcovarmat
 DISPlay(string)

 UNSQuared EUCLidean VERBose float all TRANSpose
 noCOVTRLIMitation
 ]
 ;
#delimit cr

local progname "mahascores"
local maxint = 32740
local maxbyte = 100


if "`varprefix'" == "" & "`genmat'" == "" & "`genfile'" == "" {
 disp as err "`progname': varprefix, genmat, or genfile must be specified"
 exit 198
}



/* Some code adapted from mahapick */
if "`genfile'" ~= "" {

 if "`name1'" == "" {
  if "`idvar'" == "" {
   local name1 "_refobs"
  }
  else {
   local name1 "_refid"
  }
 }

 if "`name2'" == "" {
  if "`idvar'" == "" {
   local name2 "_obs"
  }
  else {
   local name2 "`idvar'"
  }
 }



 if "`scorevar'" == "" {
  local scorevar "_score"
 }

 assert_distinct name1 scorevar `name1' `scorevar' `progname'
 assert_distinct name2 scorevar `name2' `scorevar' `progname'
 assert_distinct name1 name2 `name1' `name2' `progname'


 if "`replace'" == "" {
  confirm new file `genfile'
 }
 else {
  capture confirm new file `genfile'
   local rc1 = _rc
  capture confirm file `genfile'
   local rc2 = _rc
  if `rc1' & `rc2' {
    disp as error "`progname': filespec for genfile invalid: `genfile'"
    exit 198
  }
 }
}
else { // no genfile
 local genfile_options "name1 name2 replace scorevar"
 local x_without_genfile 0

 foreach opt of local genfile_options {
  if "``opt''" ~= "" {
   disp as error "`progname': `opt' invalid without genfile"
   local x_without_genfile 1
  }
 }

 if `x_without_genfile' {
  exit 198
 }

}



/*
Note that we checked that the genfile_options were specified only if genfile
was also specified.  There are certain other options that apply under other
conditions, but we don't bother checking.


It is the user's responsibility to assure that `idvar', if present, has unique
values; and no nulls or embedded blanks.
This is more or less important, depending on which output option is used.


This allows a pre-calculated inverse covariance matrix (invcovarmat) to be
passed in as an option.  The purpose is just to allow the user the option.
See mahascore.ado for other reasons -- though there is a different
emphasis there -- to eliminate repeated calculations.  (And HERE we use that
facility.)

*/

/* Borrow code from mahasore; we need to replicate some of it because of
the INVCOVarmat(name) and COMPUTE_invcovarmat options.
*/

local treated_orig "`treated'"

if "`treated'" ~= "" {
 if "`covtrlimitation'" =="" {
  local iftreated_for_cov "if `treated'"
 }
}
else {
 tempvar treated
 gen byte `treated' = 1
 /* -- needed in loop */
}
/* Note that now, `treated' is certainly non-empty. But `treated_orig' retains
the original value, and may be empty.
*/

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
 But the most general choice is inv().
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
 if "`euclidean'" ~= "" {
  disp as err "`progname': euclidean will be ignored, since compute_invcovarmat was not specified"
 }

 local invcov "`invcovarmat'"
}

if index("`display'", "invcov") {
 disp _new as text "invcovariance matrix:"
 mat list `invcov'
}



local all = "`all'" ~= ""
local full = "`full'" ~= ""

if "`genmat'" ~= "" {


 if "`treated_orig'" == "" | `all' {
  local Nj = _N
 }
 else {
  qui count if `treated'
  local Nj = r(N)
 }

 if "`treated_orig'" == "" | `all' | `full' {
  local Nk = _N
 }
 else {
  qui count if ~`treated'
  local Nk = r(N)
 }

 matrix `genmat' = J(`Nj', `Nk', .)

 forvalues j0 = 1/`=_N' {
  if "`treated_orig'" == "" | `all' | `treated'[`j0'] {
   if "`idvar'" =="" {
    local rownames "`rownames' obs`j0'"
   }
   else {
    local rownames "`rownames' `=`idvar'[`j0']'"
   }
  }
  if "`treated_orig'" == "" | `all' | `full' | ~`treated'[`j0'] {
   if "`idvar'" =="" {
    local colnames "`colnames' obs`j0'"
   }
   else {
    local colnames "`colnames' `=`idvar'[`j0']'"
   }
  }
 }

 matrix colnames `genmat' = `colnames'
 matrix rownames `genmat' = `rownames'
}


if "`genfile'" ~= "" {
 local scoretype "double"
 if "`float'" ~= "" {
  local scoretype "float"
 }



 if "`idvar'" ~= "" {
  local typ1: type `idvar'
  local typ2: type `idvar'
 }
 else {
  tempvar n // to optimize typ1 & typ2
  local max_var1 = _N
  local max_var2 = _N

  if ~("`treated_orig'" == "" | `all') {
   gen long `n' = _n
   summ `n' if `treated', meanonly
   local max_var1 = r(max)
  }

  if ~("`treated_orig'" == "" | `all' | `full') {
   summ `n' if ~`treated', meanonly
   local max_var2 = r(max)
  }
  /* Note that the -summ `n'...- operation is valid in all cases. It is just
  more efficient to use _N when appropriate.  Also note that if `n' is
  needed in the second -summ-, it has already been generated in the first --
  because of the order and because the condition
   ~("`treated_orig'" == "" | `all') 
  is more inclusive than
   ~("`treated_orig'" == "" | `all' | `full')
  */
  /* disp "max_var1= `max_var1'" */
  /* disp "max_var2= `max_var2'" */

  #delimit ;
  local typ1 =
  cond(`max_var1' <= `maxbyte', "byte",
  cond(`max_var1' <= `maxint',  "int",
  "long"));

  local typ2 =
  cond(`max_var2' <= `maxbyte', "byte",
  cond(`max_var2' <= `maxint',  "int",
  "long"));

  #delimit cr

 }

 /* disp "typ1= `typ1'" */
 /* disp "typ2= `typ2'" */

 tempname genfile_handle

 postfile `genfile_handle' `typ1' (`name1') `typ2' (`name2') `scoretype' (`scorevar') using `genfile', `replace'
 disp as text "file `genfile' opened for posting"
}


/* End of preparation */


/* Begin generating results */

local j1 = 1
forvalues j0 = 1/`=_N' {
 if `all' | `treated'[`j0'] {

  if "`varprefix'" == "" {
   tempvar newvar
  }
  else {
   if "`idvar'" == "" {
    local newvar "`varprefix'`j0'"
   }
   else {
    local newvar "`varprefix'`=`idvar'[`j0']'"
   }
  }
  /* actually, "`varprefix'`=`idvar'[`j0']'" works out okay if `idvar' is
  empty, but it's not quite proper to do it that way.
  */


  #delimit ;
  mahascore `varlist' ,
   gen(`newvar')
   invcovarmat(`invcov')
   refobs(`j0')
   `unsquared' `verbose' `float'
  ;
  #delimit cr


  if "`genmat'" ~= "" | "`genfile'" ~= "" {
   local k1 = 1
   forvalues k0 = 1/`=_N' {
    if "`treated_orig'" == "" |  `all' | `full' | ~`treated'[`k0'] {

     if "`genmat'" ~= "" {
      matrix `genmat'[`j1', `k1'] = `newvar'[`k0']
      local ++k1
     }

     if "`genfile'" ~= "" {
      if "`idvar'" == "" {
       post `genfile_handle'  (`j0') (`k0') (`newvar'[`k0'])
      }
      else {
       post `genfile_handle'  (`idvar'[`j0']) (`idvar'[`k0']) (`newvar'[`k0'])
      }
     }
    }
   }
  }

  if "`varprefix'" == "" {
   drop `newvar'
  }

  local ++j1
 }
}


if "`genfile'" ~= "" {
 postclose `genfile_handle'
 disp as text "file `genfile' closed"
}

if "`genmat'" ~= "" & "`transpose'" ~= "" {
 matrix `genmat' = `genmat''
}


/* Note that [`weight' `exp'] is not included in the call to mahascore
not appropriate with invcovarmat(`invcov').

Also, it does not use the compute_invcovarmat option; that would defeat the
purpose of it having the invcovarmat() option -- to eliminate repeated (lengthy)
computations of the same values.

*/

end // mahascores



prog def assert_distinct // borrowed from mahapick
args name1 name2 c1 c2 progname
/*
`name1' and `name2' are allegedly the names of macros.
`c1' and `c2' are supposed to be the corresponding contents.
We need to pass names and contents separately, because they are local to the
calling context.
*/
if "`c1'" == "`c2'" {
 disp as error "`progname': `name1' and `name2' must be distinct"
 exit 198
}
end  // assert_distinct
