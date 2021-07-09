#delimit ;
capture program drop flexcurv;
program define flexcurv, rclass;
version 16.0;
/*
 Create a set of splines of specified power
 corresponding to a specified X-variable
 and a specified set of reference points in refpts,
 such that, if the splines are the design matrix,
 then the regression coefficients for the splines
 are the values of the spline at the reference points.
 Take, as input, X-variable name in xvar, power in power,
 and an ascending sequence of reference points in refpts,
 to be extended on left and right if exref specified.
 Generate, as output, a set of splines in varlist,
 (or a set of splines prefixed by generate,
 if varlist is absent),
 with type as specified in type,
 and variable labels generated using format labfmt if present,
 or format of X-variable otherwise.
*! Author: Roger Newson
*! Date: 03 April 2020
*/

syntax [ newvarlist ] [if] [in]
  , Xvar(varname numeric) 
  [
  Refpts(numlist min=2)
  Power(integer 0)
  INClude(numlist) KRUle(name)
  OMit(passthru) BAse(passthru) Generate(passthru) Type(passthru) LABfmt(passthru) LABPrefix(passthru)
  ];
/*
 xvar() is the X-variable.
 refpts() is the list of reference points.
 power() is the power (or degree) of the spline.
 include() is a list of additional numers to be included in the completeness range.
 Other options are passed to frencurv.
*/

*
 set krule() option if absent
*;
if "`krule'"=="" {;
  local krule "regular";
};
if index("regular","`krule'")==1 {;
  local krule "regular";
};
else if index("interpolate","`krule'")==1 {;
  local krule "interpolate";
};
else {;
  disp as error "`invalid krule(`krule')";
  error 498;
};

* Create to-use variable *;
tempvar touse;
mark `touse' `if' `in';markout `touse' `xvar';

*
 Check that there are observations
 and calculate minimum and maximum of completeness range
 from the x-variable, reference points, and additional included numbers,
 and calculate default reference points, if not given,
 and sort reference points, removing duplicates..
*;
quietly summarize `xvar' if(`touse'), meanonly;
if((r(N)<=0)|(r(N)==.)){;error 2000;};
local xmin=r(min);local xmax=r(max);
local allnums "`xmin' `xmax' `include' `refpts'";
numlist "`allnums'", sort;
local allnums "`r(numlist)'";
local allnums: list uniq allnums;
local nallnums: word count `allnums';
local xmin: word 1 of `allnums';
local xmax: word `nallnums' of `allnums';
if `xmin'==`xmax' {;
  disp as error "Completeness range of spline has zero width";
  error 498;
};
if "`refpts'"=="" {;
  local refpts "`xmin' `xmax'";
};
numlist "`refpts'", sort;
local refpts "`r(numlist)'";
local refpts: list uniq refpts;
if `power'==0 {;
  cap assert `xvar'<`xmax' if `touse';
  if _rc {;
    disp as error "X-values out of completeness range for right-continuous spline of degree zero";
    error 498;
  };
};

*
 Create default knots
*;
local nrefpt: word count `refpts';
local nknot=`nrefpt'-`power'+1;
if `nknot'<2 {;
  disp _n as error "`nrefpt' reference points is not sufficient for a spline of degree `power'";
  error 498;
};
local knots "";
if "`krule'"=="regular" {;
  * Regular spacing of knots *;
  forv i1=1(1)`nknot' {;
    local knotcur = `xmax'*((`i1'-1)/(`nknot'-1)) + `xmin'*((`nknot'-`i1')/(`nknot'-1));
    local knots "`knots' `knotcur'";
  };
};
else if "`krule'"=="interpolate" {;
  * Knots interpolated between reference points *;
  tempname rhoi sigmai;
  local knots "`knots' `=`xmin''";
  local nknotm=`nknot'-1;
  local nrefptm=`nrefpt'-1;
  forv i1=2(1)`nknotm' {;
    if `power'==0 {;
      local knotcur: word `i1' of `refpts';
    };
    else {;
      scal `sigmai' = 1 + (`i1'-1)*(`nrefptm'/`nknotm');
      local pii=int(`sigmai');
      local piip=`pii'+1;
      scal `rhoi'=`sigmai'-`pii';
      local refleft: word `pii' of `refpts';
      local refright: word `piip' of `refpts';
      local knotcur = `refleft'*(1-`rhoi') + `refright'*`rhoi';
    };
    local knots "`knots' `knotcur'";
  };
  local knots "`knots' `=`xmax''";
};

*
 Generate splines
*;
frencurv `varlist' if `touse', xvar(`xvar') refpts(`refpts') noexref knots(`knots') power(`power')
  `omit' `base' `generate' `type' `labfmt' `labprefix';
return add;

end;
