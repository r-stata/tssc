#delim ;
prog logaxis, rclass;
version 10.0;
/*
  Generate regular logarithmic axis range and tick mark list
  for a list of variables and/or included constants.
*! Author: Roger Newson
*! Date: 20 April 2016
*/
syntax [ varlist(numeric default=none) ] [if] [in] [ , Base(numlist max=1 >1) Scalefactors(numlist >0) MARginfactors(numlist max=2 >=1)
  INClude(numlist >0) MAXTicks(passthru) SINgleok
  LRAnge(name local) LTIcks(name local) LRMIn(name local) LRMAx(name local) LTMIn(name local) LTMAx(name local)
  LNTick(name local) LVMIn(name local) LVMAx(name local)
  GRAnge(name) GTIcks(name) GRMIn(name) GRMAx(name) GTMIn(name) GTMAx(name)
  GNTIck(name) GVMIn(name) GVMAx(name) ];
/*
-base()- specifies the logarithmic base for the tick marks (defaulting to natural logs).
-scalefactors()- specifies a list of scale factors,
  generating tick marks with values equal to scale_i*k^base,
  where k is an integer and scale_i is a scale factor.
-marginfactors()- specifies the 2 margin factors
  defining the ratio of the minimum tick to the range minimum
  and the ratio of the range maximum to the maximum tick.
-include()- specifies a list of numeric constants
  to be included in the range spanned by the ticks.
-maxticks()- specifies the maximum number of ticks.
-singleok- specifies that the output tick list can be a single tick
  if the data range contains only a single value equal to a candidate tick position.
-lrange()- is the name of a local macro to store the range.
-lticks()- is the name of a local macro to store the ticks.
-lrmin()- is the name of a local macro to store the range minimum.
-lrmax()- is the name of a local macro to store the range maximum.
-ltmin()- is the name of a local macro to store the minimum tick.
-ltmax()- is the name of a local macro to store the maximum tick.
-lntick()- is the name of a local macro to store the number of ticks.
-lvmin()- is the name of a local macro to store the minimum value present in the -varlist- and/or the -include()- option.
-lvmax()- is the name of a local macro to store the maximum value present in the -varlist- and/or the -include()- option.
-grange()- is the name of a global macro to store the range.
-gticks()- is the name of a global macro to store the ticks.
-grmin()- is the name of a global macro to store the range minimum.
-grmax()- is the name of a global macro to store the range maximum.
-gtmin()- is the name of a global macro to store the minimum tick.
-gtmax()- is the name of a global macro to store the maximum tick.
-gntick()- is the name of a global macro to store the number of ticks.
-gvmin()- is the name of a global macro to store the minimum value present in the -varlist- and/or the -include()- option.
-gvmax()- is the name of a global macro to store the maximum value present in the -varlist- and/or the -include()- option.
*/

*
 Check for illegal option values
 and generate default option values if necessary
*;
if "`scalefactors'"=="" {;
  local scalefactors=1;
};
if "`marginfactors'"=="" {;
  local marginfactors "1 1";
};
else {;
  local nmarg: word count `marginfactors';
  if `nmarg'==1 {;
    local marginfactors "`marginfactors' `marginfactors'";
  };
};

*
  Find minimum and maximum values in data and -include()- option
*;
tempname vmin vmax vmincur vmaxcur;
scal `vmin'=.;
scal `vmax'=.;
* Variables *;
if "`varlist'"!="" {;
  marksample touse, novarlist;
  foreach X of var `varlist' {;
    qui summ `X' if `touse', meanonly;
    if r(min)<`vmin' | missing(`vmin') {;scal `vmin'=r(min);};
    if r(max)>`vmax' | missing(`vmax') {;scal `vmax'=r(max);};
  };
};
* Additional constants *;
if "`include'"!="" {;
  foreach X of numlist `include' {;
    if `X'<`vmin' | missing(`vmin') {;scal `vmin'=`X';};
    if `X'>`vmax' | missing(`vmax') {;scal `vmax'=`X';};    
  };
};
* Set to zero if all values missing *;
if missing(`vmin') {;scal `vmin'=1;};
if missing(`vmax') {;scal `vmax'=1;};
* Fail if nonpositive values present *;
if `vmin'<=0 | `vmax'<=0 {;
  error 411;
};

* Generate logged -include- list *;
local linclude "";
foreach X in `vmin' `vmax' {;
  if "`base'"!="" {;local vtemp=log(`X')/log(`base');};
  else {;local vtemp=log(`X');};
  local linclude "`linclude' `vtemp'";
};
local linclude "include(`linclude')";

* Generate logged margins *;
local lmargins "";
if "`marginfactors'"!="" {;
  tempname margcur;
  foreach X of numlist `marginfactors' {;
    scal `margcur'=log(`X');
    if "`base'"!="" {;
      scal `margcur'=`margcur'/log(`base');
    };
    local lmargcur=`margcur';
    local lmargins "`lmargins' `lmargcur'";
  };
  local lmargins "margins(`lmargins')";
};

* Generate logged scales *;
local lscales="";
if "`scalefactors'"!="" {;
  tempname scalecur;
  foreach X of numlist `scalefactors' {;
    scal `scalecur'=log(`X');
    if "`base'"!="" {;
      scal `scalecur'=`scalecur'/log(`base');
    };
    local lscalecur=`scalecur';
    local lscales "`lscales' `lscalecur'";
  };
  local lscales "phases(`lscales')";
};

* Generate logged axis and range *;
regaxis, cycle(1) `lscales' `lmargins' `linclude' `maxticks' `singleok';
tempname rmin rmax tmin tmax expcur;
local ntick=r(ntick);
foreach X in range ticks {;
  local `X'="";
  foreach Y of numlist `r(`X')' {;
    if "`base'"!="" {;scal `expcur'=`base'^`Y';};
    else {;scal `expcur'=exp(`Y');};
    local lexpcur=`expcur';
    local `X' "``X'' `lexpcur'";
  };
};
local temp1: word 1 of `range';
scal `rmin'=`temp1';
local temp1: word 2 of `range';
scal `rmax'=`temp1';
local temp1: word 1 of `ticks';
scal `tmin'=`temp1';
local temp1: word `ntick' of `ticks';
scal `tmax'=`temp1';

*
  Return results
*;
return scalar vmax=`vmax';
return scalar vmin=`vmin';
return scalar ntick=`ntick';
return scalar tmax=`tmax';
return scalar tmin=`tmin';
return scalar rmax=`rmax';
return scalar rmin=`rmin';
return local ticks "`ticks'";
return local range "`range'";

*
  Set local and global macro options
*;
foreach X in range ticks {;
  if "`l`X''"!="" {;
    c_local `l`X'' "``X''";
  };
  if "`g`X''"!="" {;
    global `g`X'' "``X''";
  };
};
foreach X in rmin rmax tmin tmax ntick vmin vmax {;
  if "`l`X''"!="" {;
    c_local `l`X''=``X'';
  };
  if "`g`X''"!="" {;
    global `g`X''=``X'';
  };
};

end;
