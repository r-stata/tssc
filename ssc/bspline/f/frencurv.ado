#delimit ;
capture program drop frencurv;
program define frencurv,rclass;
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
 to be extended on left and right if exref specified,
 and (optionally) a set of knots in knots,
 to be extended on left and right if exknot specified.
 Generate, as output, a set of splines in varlist,
 (or a set of splines prefixed by generate,
 if varlist is absent),
 with type as specified in type,
 and variable labels generated using format labfmt if present,
 or format of X-variable otherwise.
*! Author: Roger Newson
*! Date: 03 April 2020
*/

syntax [ newvarlist ] [if] [in] ,
  [
  Refpts(numlist min=2) noEXRef OMit(numlist min=1 max=1) BAse(numlist min=1 max=1)
  Xvar(varname numeric)
  Knots(numlist min=2) noEXKnot
  Power(integer 0)
  Generate(string) Type(string)
  LABfmt(string) LABPrefix(string)
  ]
  ;
/*
 refpts() specifies the reference points.
 noexref specifies that the list of reference points will not be extended.
 omit() specifies a single reference point,
  whose corresponding reference spline will be omitted,
  leaving an incomplete basis of reference splines,
  which can be completed by adding a constant vector
  equal to 1 in all observations.
 base() specifies a single reference point,
  whose corresponding reference spline will be set to zero,
  leaving an incomplete basis of reference splines
  suitable for inclusion in a Stata Version 11 design matrix,
  which can be completed by adding a constant vector
  equal to 1 in all observations.
 Other options correspond to the options of the same name for -bsspline-.
*/

*
 Set default label prefix
*;
if `"`labprefix'"'=="" {;
  local labprefix "Spline at ";
};

* Rename varlist to splist *;
local splist "`varlist'";macro drop varlist;

* Check that power is non-negative *;
if(`power'<0){;
  display in red "Negative power not allowed";
  error 498;
};

* Set type to default if necessary *;
local deftype "float";
if("`type'"==""){;local type "`deftype'";};
else if(("`type'"!="float")&("`type'"!="double")){;
  disp in green "Note: invalid type for splines - `deftype' assumed";
  local type "`deftype'";
};

* Create to-use variable *;
tempvar touse;
mark `touse' `if' `in';markout `touse' `xvar';

*
 Check that there are observations
 and initialize reference points if necessary
 and sort reference points, removing duplicates
*;
quietly summarize `xvar' if(`touse');
if((r(N)<=0)|(r(N)==.)){;error 2000;};
else if("`refpts'"==""){;
  local rmin=r(min);local rmax=r(max);local refpts "`rmin' `rmax'";
};
numlist "`refpts'", sort;
local refpts "`r(numlist)'";
local refpts: list uniq refpts;

*
 Initialize knots if absent
 and sort knots, removing duplicates
*;
if("`knots'"==""){;
  * Create knots *;
  if(mod(`power',2)){;
    * Odd power - knots initialized to reference values *;
    local knots "`refpts'";
  };
  else{;
    * Even power - knots initialized to reference value midpoints *;
    *
     Create list of reference points extended by 1 on each side
     stored in macro refp2
    *;
    nlext,inlist(`refpts') next(1);
    local refp2 "`r(numlist)'";local nrefp2:word count `refp2';
    tempname midp;
    local i1=0;local i2=1;
    while(`i2'<`nrefp2'){;local i1=`i1'+1;local i2=`i2'+1;
      local lref:word `i1' of `refp2';
      local href:word `i2' of `refp2';
      scal `midp'=(`lref'+`href')/2;
      local newk=`midp';
      if(`i1'==1){;local knots="`newk'";};
      else{;local knots "`knots' `newk'";};
    };
    macro drop refp2 nrefp2;
  };
};
numlist "`knots'", sort;
local knots "`r(numlist)'";
local knots: list uniq knots;

* Extend reference points if requested *;
if("`exref'"!="noexref"){;
  local intp2=int(`power'/2);
  nlext,inlist(`refpts') next(`intp2');
  local refpts "`r(numlist)'";
};

*
 Initialise local macros splist, nref, nknot, nspline and generate
 (if necessary)
*;
local nref:word count `refpts';
local nknot:word count `knots';
* Fill in splist if absent *;
if("`splist'"!=""){;
  * Spline list has been provided by user *;
  local nspline:word count `splist';
  * Set generate prefix (for column names of knot matrix) *;
  if("`generate'"==""){;local generate="c";};
};
else{;
  * Spline list must be generated *;
  if("`generate'"==""){;
    disp in red
     "Spline list unspecified - generate() or varlist required";
    error 498;
  };
  else{;
    *
     Number of splines to be guessed from references
    *;
    local nspline=`nref';
    if(`nspline'<=0){;local nspline=1;};
    * Generate spline list *;
    local splist "`generate'1";
    local i1=1;
    while(`i1'<`nspline'){;local i1=`i1'+1;
      local splist "`splist' `generate'`i1'";
    };
  };
};

*
 Set number of references to be used
 if there are more than enough to generate enough splines,
 or else generate extra references
 if there are too few to generate enough splines
*;
if(`nref'>`nspline'){;
  * Ignore surplus references at top of list *;
  local nref=`nspline';
  * Replace list of references with shorter version *;
  local refsn:word 1 of `refpts';
  local i1=1;
  while(`i1'<`nref'){;local i1=`i1'+1;
    local newr:word `i1' of `refpts';
    local refsn "`refsn' `newr'";
  };
  local refpts "`refsn'";macro drop refsn;
  local nref:word count `refpts';
};
else if(`nref'<`nspline'){;
  *
   Generate extra references
   (separated by the difference between the pre-existing
   ultimate and penultimate references)
  *;
  local nextref=`nspline'-`nref';
  nlext,i(`refpts') next(`nextref') right;
  local refpts "`r(numlist)'";
  local nref:word count `refpts';
};
if `nref'>c(matsize) {;
  disp as error "Too many reference points for current matsize.";
  error 908;
};


*
 Check that generated spline names are not too long
 (as they will be if the generate prefix is too long
 to prefix the required number of splines)
*;
local lastsp:word `nspline' of `splist';
confirm name `lastsp';

* Generate label format from X-variate if necessary *;
if("`labfmt'"==""){;
  local labfmt:format `xvar';
};

* Create B-spline list *;
local i1=0;
while(`i1'<`nspline'){;local i1=`i1'+1;
  tempvar b`i1';
  if(`i1'==1){;local bsplist="`b`i1''";};
  else{;local bsplist "`bsplist' `b`i1''";};
};

*
 Check that omit() is in the list of reference points
 (if it is provided),
 and store its position in macro omitpos.
*;
if "`omit'"!="" {;
  local omitpres=0;
  local i1=0;
  foreach RP of num `refpts' {;
    local i1=`i1'+1;
    if `RP'==`omit' {;
      local omitpres=1;
      local omitpos=`i1';
    };
  };
  if !`omitpres' {;
    disp as error "omit(`omit') is not present in the following list of reference points:"
      _n as error "`refpts'";
    error 498;
  };
};

*
 Check that base() is in the list of reference points
 (if it is provided),
 and store its position in macro basepos.
*;
if "`base'"!="" {;
  local basepres=0;
  local i1=0;
  foreach RP of num `refpts' {;
    local i1=`i1'+1;
    if `RP'==`base' {;
      local basepres=1;
      local basepos=`i1';
    };
  };
  if !`basepres' {;
    disp as error "base(`base') is not present in the following list of reference points:"
      _n as error "`refpts'";
    error 498;
  };
};

*
 Create temporary vector refv
 containing the reference values
*;
tempname refv;
forv i1=1(1)`nref' {;
  local refi1:word `i1' of `refpts';
  if `i1'==1 {;
    local refvv "`refi1'";
  };
  else {;
    local refvv "`refvv',`refi1'";
  };
};
capture quietly matr def `refv'=(`refvv');
if(_rc==908){;
  disp in red
    "matsize too small to create reference vector for `nref' reference values";
  error 908;
};
else if(_rc==130){;
  disp in red "Too many reference values for a Stata matrix definition";
  disp in red "The reference value list generated was:";
  disp in red "`refvv'";
  error 130;
};
else if(_rc!=0){;
  error `=_rc';
};
* Set row and column names *;
matr rownames `refv'=`xvar';
matr colnames `refv'=`splist';

*
 Create temporary dataframe
 (in which to create B-splines for reference values)
 and begin work in temporary frame (UNINDENTED).
*;
tempname tempframe;
frame create `tempframe';
frame `tempframe' {;

* Create x-variate of reference values *;
matr def `refv'=`refv'';
*
 It is important to set more off when svmat is called i9n a program
 because it prompts for more if allowed to
 (presumably it is trying to be helpful)
*;
set more off;
quietly svmat `type' `refv',names(col);
set more on;
matr def `refv'=`refv'';
format `xvar' `labfmt';

* Calculate B-splines *;
capture bspline `bsplist',xvar(`xvar') power(`power')
 knots(`knots') `exknot' type(`type') labfmt("`labfmt'");
* Check that bspline has executed successfully *;
if(_rc!=0){;
  disp in red "B-splines could not be calculated"
  " for the specified knots and reference values";
  error _rc;
};
local knots "`r(knots)'";local nknot:word count `knots';
local knot1:word 1 of `knots';local knotn:word `nknot' of `knots';
* Check that the knots surround the reference points *;
tempvar outer;
if(`power'==0){;
  quietly gene `outer'=(`xvar'<`knot1')|(`xvar'>=`knotn');
};
else{;
  quietly gene `outer'=(`xvar'<`knot1')|(`xvar'>`knotn');
};
quietly summ `xvar' if(`outer');local nouter=r(N);
if(`nouter'>0){;
  disp in red "`nouter' reference points are out of the range"
    " spanned by the knots";
  error 498;
};

* Store the B-splines in a matrix *;
tempname sptran;
quietly mkmat `bsplist',matr(`sptran');
matr rownames `sptran'=`splist';

*
 End work in temporary frame (UNINDENTED), 
 return to original data frame,
 and drop temporary frame.
*;
};
frame drop `tempframe';

*
 Check that matrix of B-splines is non-singular,
 and, if so, then invert it
*;
tempname singula;
scal `singula'=det(`sptran')==0;
if(`singula'){;
  disp in red "B-splines at the specified reference points"
  " for the specified knots";
  disp in red "cannot be inverted";
  disp in red "Knots are not compatible with reference points";
  disp in red "Final list of knots:" _newline "`knots'";
  disp in red "Final list of reference points:" _newline "`refpts'";
  error 498;
};
else{;
  matr def `sptran'=inv(`sptran');
  matr rownames `sptran'=`bsplist';matr colnames `sptran'=`splist';
};

* Create B-splines in main data set *;
bspline `bsplist' if(`touse'),xvar(`xvar') power(`power')
  knots(`knots') noexknot type(`type') labfmt("`labfmt'");
tempname xinf xsup;
scal `xinf'=r(xinf);scal `xsup'=r(xsup);
return add;

* Transform B-splines to reference value splines *;
tempname cref coefv;
local i1=0;
while(`i1'<`nspline'){;local i1=`i1'+1;
  local spline:word `i1' of `splist';
  scal `cref'=`refv'[1,`i1'];
  matr def `coefv'=`sptran'[1...,`i1']';
  matr scor `type' `spline'=`coefv';
  local fcref=string(`cref',"`labfmt'");
  if(`power'==0){;
    local incomp=(`cref'<`xinf')|(`cref'>=`xsup');
  };
  else{;
    local incomp=(`cref'<`xinf')|(`cref'>`xsup');
  };
  if(`incomp'){;
    label variable `spline' "`labprefix'`fcref' (INCOMPLETE)";
  };
  else{;
    label variable `spline' "`labprefix'`fcref'";
  };
  format `spline' %8.4f;
  char `spline'[xvalue] "`=`cref''";
  char `spline'[xvar] "`xvar'";
};

* Return results not created by bspline *;
return local labprefix `"`labprefix'"';
return local splist "`splist'";
return local refpts "`refpts'";
return matrix refv `refv';

*
 Remove omitted spline if omit() is provided
*;
if "`omit'"!="" {;
  local refdrop: word `omitpos' of `refpts';
  local spdrop: word `omitpos' of `splist';
  local splist: list splist - spdrop;
  drop `spdrop';
  return scalar nspline=`nspline'-1;
  return local splist "`splist'";
  return scalar omit=`omit';
  if(`power'==0){;
    local incomp=(`refdrop'<`xinf')|(`refdrop'>=`xsup');
  };
  else{;
    local incomp=(`refdrop'<`xinf')|(`refdrop'>`xsup');
  };
  if `incomp' {;
    disp as text "Warning: omitted spline at `refdrop' is outside the completeness region."
      _n as text "Model parameters may not be interpretable in the usual way.";
  };
};

*
 Set base spline to zero if base() is provided
*;
if "`base'"!="" {;
  local refzero: word `basepos' of `refpts';
  local spzero: word `basepos' of `splist';
  qui {;
    replace `spzero'=0 if `touse';
    compress `spzero';
  };
  return local splist "`splist'";
  return scalar base=`base';
  if(`power'==0){;
    local incomp=(`refzero'<`xinf')|(`refzero'>=`xsup');
  };
  else{;
    local incomp=(`refzero'<`xinf')|(`refzero'>`xsup');
  };
  if `incomp' {;
    disp as text "Warning: base spline at `refzero' is outside the completeness region."
      _n as text "Model parameters may not be interpretable in the usual way.";
  };
};

end;

program define nlext,rclass;
version 10.0;
*
 Take, as input, an input numlist in inlist
 and extend it to the left (if left present)
 and/or the right (if right present)
 or both ways (if neither present)
 by a number of extra values equal to next,
 separated by the distance between the ultimate and penultimate numbers
 on the appropriate side in inlist,
 and put the extended output into r(numlist)
*;

syntax,Inlist(numlist min=2) [Next(integer 1) Left Right];

* Set missing direction to both ways *;
if(("`left'"=="")&("`right'"=="")){;
  local left="left";local right="right";
};

* Extend as necessary *;
tempname cn dn;
* Extend on left if requested *;
if("`left'"!=""){;
  local cnv:word 1 of `inlist';scal `cn'=`cnv';
  local cnv:word 2 of `inlist';scal `dn'=`cnv'-`cn';
  local i1=0;
  while(`i1'<`next'){;local i1=`i1'+1;
    scal `cn'=`cn'-`dn';local cnv=`cn';
    local inlist "`cnv' `inlist'";
  };
};
* Extend on right if requested *;
if("`right'"!=""){;
  local nnum:word count `inlist';local nnumm=`nnum'-1;
  local cnv:word `nnum' of `inlist';scal `cn'=`cnv';
  local cnv:word `nnumm' of `inlist';scal `dn'=`cn'-`cnv';
  local i1=0;
  while(`i1'<`next'){;local i1=`i1'+1;
    scal `cn'=`cn'+`dn';local cnv=`cn';
    local inlist "`inlist' `cnv'";
  };
};

* Return output *;
return local numlist "`inlist'";

end;
