#delim ;
prog def haif, rclass byable(recall);
version 11.0;
/*
  Calculate homoskedastic adjustment inflation factors (HAIFs)
  for the coefficients of a list of core predictor variables,
  caused by adjusting for a list of additional variables
  and/or weighting using sampling-probability weights.
*!Author: Roger B. Newson
*!Date: 09 May 2013
*/

syntax [ varlist(numeric fv default=none) ] [if] [in] [fweight aweight iweight] ,
  [ PWeight(string asis) Addvars(varlist numeric fv) noConstant ];
/*
  pweight() specifies the sampling-probability weight expression.
  addvars() specifies the additional variables.
  noconstant specifies that no constant term is included in the core model.
*/

*
 Mark sample to use
*;
marksample touse, zeroweight;
markout `touse' `addvars';

*
 Evaluate weights to variables
*;
tempvar ivweight spweight;
if `"`exp'"'=="" {;
  qui gene byte `ivweight'=1 if `touse';
};
else {;
  qui gene double `ivweight'`exp' if `touse';
};
if `"`pweight'"'=="" {;
  qui gene byte `spweight'=1 if `touse';
};
else {;
  qui gene double `spweight'=`pweight' if `touse';
};
markout `touse' `ivweight' `spweight';

*
 Expand varlists
*;
foreach VL in varlist addvars {;
  fvexpand ``VL'' if `touse';
  local `VL' "`r(varlist)'";
};

*
 Check that varlists are mutually exclusive
*;
local sharedvars: list varlist & addvars;
if `"`sharedvars'"'!="" {;
  disp as error "The following variables are in the core variable list"
    _n as error "and also in the added variable list:"
    _n as error "`sharedvars'";
  error 498;
};

*
 Count numbers of parameters
*;
local Naddvars: word count `addvars';
local Ncorevars: word count `varlist';
if "`constant'"!="noconstant" {;
  local Ncorevars=`Ncorevars'+1;
};
if `Ncorevars'<1 {;
  disp as error "No columns in the core design matrix";
  error 498;
};

*
 Create row vectors of variances of model parameters
 for core and full models
*;
tempname Vcore Vbread Vfill Vfull Nobs;
tempvar Y;
qui gene byte `Y'=0;
qui regress `Y' `varlist' if `touse' [iweight=`ivweight'] , mse1 `constant';
scal `Nobs'=e(N);
matr def `Vcore'=e(V);
matr def `Vcore'=vecdiag(`Vcore');
qui regress `Y' `addvars' `varlist' if `touse' [iweight=`ivweight'*`spweight'] , mse1 `constant';
matr def `Vbread'=e(V);
qui regress `Y' `addvars' `varlist' if `touse' [iweight=`ivweight'*`spweight'*`spweight'] , mse1 `constant';
matr def `Vfill'=e(V);
matr def `Vfill'=invsym(`Vfill');
matr def `Vfull'=`Vbread'*`Vfill'*`Vbread';
matr def `Vfull'=vecdiag(`Vfull');
local findex=`Naddvars'+1;
local lindex=`Naddvars'+`Ncorevars';
matr def `Vfull'=`Vfull'[1..1,`findex'..`lindex'];

*
 Create output matrix
*;
tempname haifmatrix;
mata: haif_createoutputmatrix("`Vcore'","`Vfull'","`haifmatrix'");

*
 List results
*;
disp as text "Number of observations: " as result `Nobs'
  _n as text "Homoskedastic adjustment inflation factors"
  _n "for variances and standard errors:";
matlist `haifmatrix', noheader noblank nohalf lines(none) names(all) format(%9.0g);

*
 Return results
*;
return matrix haif=`haifmatrix';
return local addvars `"`addvars'"';
return local pweight `"`pweight'"';
return scalar N=`Nobs';

end;

#delim cr
/*
  Private Mata programs
*/
mata:

void haif_createoutputmatrix(string scalar Vcorename, string scalar Vfullname, string scalar haifname)
{
/*
  Input Stata row matrices with names Vcorename and Vfullname,
  containing variances for core parameters in core and full models,
  and output a 2-column Stata matrix with name haifname,
  with 1 row per core parameter,
  and columns containing variance and standard error HAIFs, respectively.
*/

real vector Vcore, Vfull;
real matrix haif;
string matrix haifrowstripe, haifcolstripe;
/*
  Vcore contains the variances under the core model.
  Vfull contains the variances under the full model.
  haif contains the HAIFs for variances and standard errors.
  haifrowstripe and haifcolstripe contain the row and column stripes for haif.  
*/

haifcolstripe=J(2,1,""),("Variance"\"SE");
haifrowstripe=st_matrixcolstripe(Vcorename);
Vcore=st_matrix(Vcorename);
Vfull=st_matrix(Vfullname);
haif=(Vfull:/Vcore)';
haif=haif,sqrt(haif);
st_matrix(haifname,haif);
st_matrixrowstripe(haifname,haifrowstripe);
st_matrixcolstripe(haifname,haifcolstripe);

}

end
