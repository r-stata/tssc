#delimit ;
program define polyspline, rclass;
version 16.0;
/*
 Create a basis for a polynomial or other unrestricted spline
 in an X-variable,
 with corresponding parameters equal to values of the spline
 at user-specified reference points,
 or differences between those values.
 This program is an easy-to-use front end
 for the bspline package.
*! Author: Roger Newson
*! Date: 03 April 2020
*/

syntax varname [if] [in] , Generate(passthru)
  [
  Refpts(numlist sort min=2)
  Power(numlist integer min=1 max=1)
  OMit(passthru) BAse(passthru)
  INClude(passthru)
  Type(passthru)
  LABfmt(passthru) LABPrefix(passthru)
  ];
/*
 refpts() is the list of reference points.
 power() is the power (or degree) of the spline.
 Other options are passed to flexcurv.
*/

*
 Count reference points
 and set power if necessary
*;
local refpts: list uniq refpts;
local nrefpt: word count `refpts';
if `nrefpt'==0 {;
  local nrefpt=2;
};
else if `nrefpt'==1 {;
  disp _n as error "refpts() invalid";
  error 122;
};
if "`power'"=="" {;
  local power=`nrefpt'-1;
};
if `power'>`nrefpt'-1 {;
  local power=`nrefpt'-1;
};
if `power'<1 {;
  disp _n as error "power() must be an integer >= 1";
  error 498;
};

*
 Generate splines
*;
qui flexcurv `if' `in', xvar(`varlist') refpts(`refpts') power(`power')
  krule(interpolate)
  `include' `omit' `base' `generate' `type' `labfmt' `labprefix';
local nspline=r(nspline);
return add;
disp as text "`nspline' reference splines generated of degree: " as result `power';

end;
