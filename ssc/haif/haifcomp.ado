#delim ;
prog def haifcomp, rclass byable(recall);
version 11.0;
/*
  Calculate ratios between homoskedastic adjustment inflation factor (HAIFs)
  for the coefficients of a list of core predictor variables,
  caused by adjusting for 2 alternative list of additional variables,
  the numerator list and the denominator list,
  and/or by 2 alternative sampling-probability weights,
  the numerator weights and the denominator weights.
*!Author: Roger B. Newson
*!Date: 09 May 2013
*/

syntax [ varlist(numeric fv default=none) ] [if] [in] [fweight aweight iweight] ,
  [ DPWeight(string asis) NPWeight(string asis)
  DAddvars(varlist numeric fv) NAddvars(varlist numeric fv) noConstant ];
/*
  dpweight() specifies the denominator pweight expression.
  npweight() specifies the numerator pweight expression.
  daddvars() specifies the denominator list of additional variables.
  naddvars() specifies the numerator list of additional variables.
  noconstant specifies that no constant term is included in the core model.
*/

*
 Mark sample to use
*;
marksample touse, zeroweight;
markout `touse' `daddvars';
markout `touse' `naddvars';

*
 Evaluate weights to variables
*;
tempvar ivweight dspweight nspweight;
if `"`exp'"'=="" {;
  qui gene byte `ivweight'=1 if `touse';
};
else {;
  qui gene double `ivweight'`exp' if `touse';
};
if `"`dpweight'"'=="" {;
  qui gene byte `dspweight'=1 if `touse';
};
else {;
  qui gene double `dspweight'=`dpweight' if `touse';
};
if `"`npweight'"'=="" {;
  qui gene byte `nspweight'=1 if `touse';
};
else {;
  qui gene double `nspweight'=`npweight' if `touse';
};
markout `touse' `ivweight' `dspweight' `nspweight';

*
 Expand varlists
*;
foreach VL in varlist daddvars naddvars {;
  fvexpand ``VL'' if `touse';
  local `VL' "`r(varlist)'";
};

*
 Create matrices of HAIFs
 for the 2 alternative lists of additional variables
 and/or sampling-probability weights
*;
tempname Nobs dhaif nhaif;
qui haif `varlist' if `touse' [iweight=`ivweight'], pweight(`dspweight') add(`daddvars') `constant';
scal `Nobs'=e(N);
matr def `dhaif'=r(haif);
qui haif `varlist' if `touse' [iweight=`ivweight'], pweight(`nspweight') add(`naddvars') `constant';
matr def `nhaif'=r(haif);

*
 Create output matrix
*;
tempname haifmatrix;
mata: haifcomp_createoutputmatrix("`dhaif'","`nhaif'","`haifmatrix'");

*
 List results
*;
disp as text "Number of observations: " as result `Nobs'
  _n as text "Homoskedastic adjustment inflation factor ratios"
  _n "for variances and standard errors:";
matlist `haifmatrix', noheader noblank nohalf lines(none) names(all) format(%10.0g);

*
 Return results
*;
return matrix haif=`haifmatrix';
return local naddvars `"`naddvars'"';
return local daddvars `"`daddvars'"';
return local npweight `"`npweight'"';
return local dpweight `"`dpweight'"';
return scalar N=`Nobs';

end;

#delim cr
/*
  Private Mata programs
*/
mata:

void haifcomp_createoutputmatrix(string scalar dhaifname, string scalar nhaifname, string scalar haifname)
{
/*
  Input Stata matrices with names dhaifname and nhaifname,
  containing HAIFs for numerator and denominator varlists,
  and output a 2-column Stata matrix with name haifname,
  with 1 row per core parameter,
  and columns containing variance and standard error HAIF ratios, respectively.
*/

real matrix dhaif, nhaif;
real matrix haif;
string matrix haifrowstripe, haifcolstripe;
/*
  dhaif contains the denominator HAIFs.
  nhaif contains the numerator HAIFs.
  haif contains the HAIF ratios.
  haifrowstripe and haifcolstripe contain the row and column stripes for haif.  
*/

haifcolstripe=st_matrixcolstripe(dhaifname);
haifrowstripe=st_matrixrowstripe(dhaifname);
dhaif=st_matrix(dhaifname);
nhaif=st_matrix(nhaifname);
haif=(nhaif:/dhaif);
st_matrix(haifname,haif);
st_matrixrowstripe(haifname,haifrowstripe);
st_matrixcolstripe(haifname,haifcolstripe);

}

end
