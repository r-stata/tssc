*! version 1.1.0 - Mike Lacy 28sep2010
// Many helpful modifications from Richard Williams
// //// ***************************************************************
//  Sept. 2010. Changed method of getting # of response categories, kcat
//  Changed to modern comment style. Changed items in return list.
//               
//  April 2006:  Changed display of results so as to scale them
//  by 1/N. They are thus analogous to variances rather than sums of squares
//  and match what is reported in the article.
//
// July 2007: Make sum of squares analogue available in return lists.
//
// No standard Stata help file is available yet.
// See Comments and "Usage" below.
// ***************************************************************
//
capture program drop  r2o
program define r2o, rclass
   version 7
// This program calculates the ordinal r2o measure and its adjusted
// version as described in:
// Lacy, Michael G. 2006.  "An Explained Variation Measure for
// Ordinal Response Models with Comparisons to Other Ordinal R2
// Measures." Sociological Methods and Research 32,4.
//
// The program below presumes that a categorical response model (ologit
// mlogit oprobit gologit2) that can yield predicted probabiliites
// via -predict- has just been run and that its e() list is still
// intact.
//
// The "trustme" option can be used to force the program to run even if
// the user has not just executed one of the preceding response model programs.
// This option would be relevant for the user who has some other response model
// program that works with -predict-.
//
// Returns: The regular r2o and its bias adjusted version in
// r(r2o) and r(ur2o)
//
// Begin program
// Detect whether an appropriate categorical response estimation command has been run
   syntax [, TRustme] [NOMarg]
   tempname ok
   scalar `ok' = 0
   local clist = "ologit mlogit oprobit gologit2"
   foreach c of local clist {
      if !`ok' & e(cmd)== "`c'" {
      scalar `ok' = 1
      }
   }
// User can force the program to work with his or her command
   if "`trustme'"!="" {
      scalar `ok' = 1
   }
   if  !`ok' {
      display as error "Preceding estimation command must be able to generate predicted probabilities."
      display as error "Command -r2o- not executed"
      exit
   }
// Else, we've got a response model that gives  predicted probs., so we can go ahead.
// First capture stuff from the response model just run.
// This will be used to yield the predicted Prob(Y), given the X vector
   tempvar touse
	mark `touse' if e(sample)        // mark the cases used to yield the prediction 
   local depvar = "`e(depvar)'"     // name of dependent variable 
   qui levelsof `depvar' if `touse'
   local kcat = wordcount(r(levels)) //# response categories 
   tempname numcovar N
   scalar `numcovar' = e(df_m)      // number of covariates 
   scalar `N' = e(N)                // Sample size from  model just run 
//
// Get the weighting information, if any
// Need to change pweights to aweights so tabulate & sum can handle them
   if "`e(wtype)'"=="pweight"{
      local wgt "[aweight`e(wexp)']"
   }
   else if "`e(wtype)'"!="" {
      local wgt "[`e(wtype)'`e(wexp)']"
   }

// Or, if you just want to kill support for weights altogether, uncomment these lines.
// if "`e(wtype)'"!=""{
//     display as error "Weights are not supported"
//     exit
// }

//
// Obtain total variation of the ordinal response variable from its marginal distribution.
// The marginal distribution comes from a simple tabulation, and then
// the ordinal variation measure is calculated on this distribution.
   di " "
   tempname F  // to eventually hold a vector of predicted cumulative probabilities
   if ("`nomarg'" == "") {  // user wants to see the marginals
      display as text "Marginal distribution for cases in the estimation sample."
      tabulate `depvar' if `touse' `wgt', matcell(`F')
   }
   else {
      qui tabulate `depvar' if `touse' `wgt', matcell(`F')
   }
// Marginal frequencies are now in the vector F, ordered from 1 to r(r).
// Convert them to cumulative relative frequencies
//
   matrix `F'[1,1] = `F'[1,1]/`N'
   forvalues ir = 2/`r(r)' {
   matrix `F'[`ir',1] = (`F'[`ir'-1, 1]) + `F'[`ir', 1]/`N'
   }
//
// Now calculate the marginal variation, SY, by applying ordinal
// variation function, Sum (F_j(1-F_j), j = 1..k to the marginal
// cum F distribution.
// The sum actually needs only to go to `r(r)' -1 but since F_r(r) = 1,
// there is no harm in running up to r(r).
   tempname SY
   scalar `SY' = 0
   forvalues ir = 1/`r(r)' {
      scalar `SY' = `SY' + ( `F'[`ir',1] * ( 1.0 - `F'[`ir',1]))
    }
   scalar `SY' = `SY'
   matrix drop `F'   // avoid confusion later with another F 
//
//
// Start on conditional variation SYX, i.e., the variation of Y given X .
// Create list of temporary variables, `F1'... to hold predicted
// probabilities for each case as created by the response model
// the user just executed.
   local Flist = ""
   forvalues i = 1/`kcat' {
      tempvar F`i'
      local Flist = "`Flist'`F`i'' "     // `F1' `F2' ... 
   }
   quietly predict `Flist' if `touse'    // predicted prob for each case into F1, ... 
// Cumulate the predicted probabilities for each case
   tempvar prev
   qui gen `prev' = `F1'
   forvalues i = 2/`kcat' {
      quietly replace `F`i'' = `prev'  + `F`i''
      quietly replace `prev' = `F`i''
   }
// The sum actually needs only to go to `kcat'-1, but since F_kcat = 1,
// there is no harm in running up to kcat.
   tempvar iSYX
   gen `iSYX' = 0      // individual cases contribution to the variation of Y given X
   forvalues i = 1/`kcat' {
      quietly replace `iSYX' = `iSYX' + `F`i'' * (1.0 - `F`i'')
   }
//
// Mean of iSYX across all cases is the SYX
   sum `iSYX' if `touse' `wgt', meanonly
   tempname SYX
   scalar `SYX' = r(mean)
   tempname r2o ur2o
   scalar `r2o' = 1.0 - `SYX'/`SY'       // the basic ordinal R^2 measure 
   return scalar r2o = `r2o'
   return scalar vtot = `SY'                // total variation 
	return scalar verr = `SYX'               // error variation 
	return scalar vmodel = (`SY' - `SYX')   // explained  variation 
	
//
//
// Now do the bias corrected version of r2o, calculated like
// the adjusted version of a conventional R^2.  `numcovar' denotes the
// number of covariates used in the response model
   scalar `ur2o' = 1.0 - (`SYX'/`SY') * ((`N'-1)/(`N'- `numcovar' -1))
   return scalar ur2o = `ur2o'
//
   display  ""
   display as text ///
   "Total       Model       Error       Lacy        Bias Adj."  _newline ///
   "Variation   Variation   Variation   r2o         r2o"       _newline ///
   _dup(58) char(175) _newline ///
   as result ///
   %-12.6f `SY' %-12.6f (`SY' - `SYX') %-12.6f `SYX' %-12.5f `r2o'  %-12.5f `ur2o'
//
end



