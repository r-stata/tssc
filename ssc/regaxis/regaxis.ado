#delim ;
prog regaxis, rclass;
version 10.0;
/*
  Generate regular linear axis range and tick mark list
  for a list of variables and/or included constants.
*! Author: Roger Newson
*! Date: 12 January 2012
*/
syntax [ varlist(numeric default=none) ] [if] [in] [ , CYcle(numlist max=1 >0) PHases(numlist) MARgins(numlist max=2 >=0)
  PCRatios(numlist) MCRatios(numlist max=2 >=0) CBase(numlist max=1 >1) CPPower(numlist max=1 >0)
  INClude(numlist)  MAXTicks(numlist integer max=1 >=2 <=1600) SINgleok
  LRAnge(name local) LTIcks(name local) LRMIn(name local) LRMAx(name local) LTMIn(name local) LTMAx(name local)
  LNTick(name local) LVMIn(name local) LVMAx(name local)
  GRAnge(name) GTIcks(name) GRMIn(name) GRMAx(name) GTMIn(name) GTMAx(name)
  GNTIck(name) GVMIn(name) GVMAx(name) ];
/*
-cycle()- specifies the cycle length for the tick marks.
-phases()- specifies a list of phases,
  generating tick marks with values equal to phase_i+k*cycle,
  where k is an integer and phase_i is a phase.
-margins()- specifies the margins separating the range minimum and maximum
  from the minimum and maximum ticks.
-pcratios()- specifies a list of phase/cycle ratios used for defining the default -phases()- option
  (ignored if -phases()- is specified).
-mcratios()- specifies a list of margin/cycle ratios used for defining the default -margins()- option
  (ignored if -margins()- is specified).
-cbase()- specifies a logarithmic base used for defining the default -cycle()- option
  (ignored if -cycle()- is specified).
-cppower()- specifies the number of cycles per integer power of the -cbase()- option
  used for defining the default -cycle()- option
  (ignored if -cycle()- is specified).
-include()- specifies a list of numeric constants
  to be included in the range spanned by the ticks.
-maxticks()- specifies the maximum number of ticks.
-singleok- specifies that the output tick list can be a single tick
  if the data range contains only a single value equal to a candidate tick position.
-lrange()- is the name of a local macro to store the ramge.
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
if "`cbase'"=="" {;
  local cbase=10;
};
if "`cppower'"=="" {;
  local cppower=`cbase'+`cbase';
};
if "`maxticks'"=="" {;local maxticks=25;};

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
if missing(`vmin') {;scal `vmin'=0;};
if missing(`vmax') {;scal `vmax'=0;};

*
  Compute default -cycle()- option if absent
*;
if "`cycle'"=="" {;
  if `vmin'==`vmax' {;
    local cycle=1;
  };
  else {;
    local cycle=`cbase'^( ceil(log(`vmax'-`vmin')/log(`cbase')) ) / `cppower';
  };
};

*
  Compute default -pcratios()- and -phases()- options if absent
*;
if "`pcratios'"=="" {;
  local pcratios=0;
};
if "`phases'"=="" {;
  foreach R of num `pcratios' {;
    local phasecur=`R'*`cycle';
    local phases "`phases' `phasecur'";
  };
};

*
  Compute default -mcratios()- and -margins()- options if absent
*;
if "`mcratios'"=="" {;
  local mcratios "0 0";
};
else {;
  local nmarg: word count `mcratios';
  if `nmarg'==1 {;
    local mcratios "`mcratios' `mcratios'";
  };
};
if "`margins'"=="" {;
  foreach R of num `mcratios' {;
    local margcur=`R'*`cycle';
    local margins "`margins' `margcur'";
  };
};
else {;
  local nmarg: word count `margins';
  if `nmarg'==1 {;
    local margins "`margins' `margins'";
  };
};

*
  Generate initial phase-specific tick mark lists
  (without allowing their total to exceed the maximum Stata numlist length)
*;
local mnumlist=1600;
local nnumlist=0;
local nphase: word count `phases';
forv i1=1(1)`nphase' {;
  local phasecur:word `i1' of `phases';
  local kmin=floor((`vmin'-`phasecur')/`cycle');
  local kmax=ceil((`vmax'-`phasecur')/`cycle');
  if `kmin'==`kmax' {;
    local kmin=`kmin'-1;
    local kmax=`kmax'+1;
  };
  local nnumlist=`nnumlist'+`kmax'-`kmin'+1;
  * Fail if there are too many candidate ticks *;
  if `nnumlist'>`mnumlist' {;
    disp as error "Options require the creation of a numlist"
      _n "with over `mnumlist' values."
      _n "To reduce the size of the largest numlist required,"
      _n "increase the cycle() or base() option."
      _n;
    error 123;
  };
  local pticks`i1'="";
  forv i2=`kmin'(1)`kmax' {;
    local tickcur=`phasecur'+`cycle'*`i2';
    local pticks`i1' "`pticks`i1'' `tickcur'";
  };
};

*
  Generate first draft of tick mark list
*;
local ticks="";
forv i1=1(1)`nphase' {;local ticks "`ticks'`pticks`i1''";};
local ticks: list uniq ticks;
numlist "`ticks'", sort;
local ticks "`r(numlist)'";
local ntick: word count `ticks';
* Trim tick mark list *;
local kmin=1;
local tickcur: word 1 of `ticks';
while `tickcur'<=`vmin' {;
  local kmin=`kmin'+1;
  local tickcur: word `kmin' of `ticks';
};
local kmin=`kmin'-1;
local kmax=`ntick';
local tickcur: word `ntick' of `ticks';
while `tickcur'>=`vmax' {;
  local kmax=`kmax'-1;
  local tickcur: word `kmax' of `ticks';
};
local kmax=`kmax'+1;
if (`kmin'==`kmax') & ("`singleok'"=="") {;
  local kmin=`kmin'-1;
  local kmax=`kmax'+1;
};
local tempticks="";
forv i1=`kmin'(1)`kmax' {;
  local tickcur: word `i1' of `ticks';
  local tempticks "`tempticks' `tickcur'";
};
local ticks "`tempticks'";
macro drop tempticks;
local ntick: word count `ticks';

*
  Reduce tick mark list if it is too long
*;
local oldcycle=`cycle';
while `ntick'>`maxticks' {;
  if `maxticks'==2 {;
    * Remove middle ticks *;
    local tickmin: word 1 of `ticks';
    local tickmax: word `ntick' of `ticks';
    local ticks "`tickmin' `tickmax'";
    local ntick=2;
  };
  else {;
    *
      More than 2 ticks allowed - reduce numbers in some other way
    *;
    if `nphase'>1 {;
      * Remove last phase *;
      local nphase=`nphase'-1;
      local ticks="";
      forv i1=1(1)`nphase' {;local ticks "`ticks'`pticks`i1''";};
      local ticks: list uniq ticks;
      numlist "`ticks'", sort;
      local ticks "`r(numlist)'";
      local ntick: word count `ticks';
    };
    else {;
      * Only one phase left - increment cycle *;
      local cycle=`cycle'+`oldcycle';
      local phasecur: word 1 of `phases';
      local kmin=floor((`vmin'-`phasecur')/`cycle');
      local kmax=ceil((`vmax'-`phasecur')/`cycle');
      if `kmin'==`kmax' {;
        local kmin=`kmin'-1;
        local kmax=`kmax'+1;
      };
      local ticks="";
      forv i2=`kmin'(1)`kmax' {;
        local tickcur=`phasecur'+`cycle'*`i2';
        local ticks "`ticks' `tickcur'";
      };
      local ntick: word count `ticks';
    };
    * Trim tick mark list *;
    local kmin=1;
    local tickcur: word 1 of `ticks';
    while `tickcur'<=`vmin' {;
      local kmin=`kmin'+1;
      local tickcur: word `kmin' of `ticks';
    };
    local kmin=`kmin'-1;
    local kmax=`ntick';
    local tickcur: word `ntick' of `ticks';
    while `tickcur'>=`vmax' {;
      local kmax=`kmax'-1;
      local tickcur: word `kmax' of `ticks';
    };
    local kmax=`kmax'+1;
    if (`kmin'==`kmax') & ("`singleok'"=="") {;
      local kmin=`kmin'-1;
      local kmax=`kmax'+1;
    };
    local tempticks="";
    forv i1=`kmin'(1)`kmax' {;
      local tickcur: word `i1' of `ticks';
      local tempticks "`tempticks' `tickcur'";
    };
    local ticks "`tempticks'";
    macro drop tempticks;
    local ntick: word count `ticks';
  };
};

*
  Create axis range
*;
local lmarg: word 1 of `margins';
local umarg: word 2 of `margins';
local tmin: word 1 of `ticks';
local tmax: word `ntick' of `ticks';
local rmin=`tmin'-`lmarg';
local rmax=`tmax'+`umarg';
local range "`rmin' `rmax'";

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
