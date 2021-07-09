#delim ;
prog def rtfsect;
version 11.0;
/*
 Start a new section in an open RTF file.
*|Author: Roger Newson
*!Date: 06 March 2012
*/

syntax name [ , DEfault PAper(string) LAndscape MArgins(numlist >=0 integer min=4 max=4) ];
/*
  default specifies that section settings will be reset to the document default.
  paper() specifies paper width and height (in twips or as a keyword).
  landscape specifies that orientation is landscape.
  margins() specifies the margins (in twips: left, right, top, bottom).
*/

*
 Set default paper dimensions and margins
 and extract local dimension macros
*;
* Set paper orientation *;
if "`landscape'"!="" {;
  local landscp "\lndscpsxn";
};
* Set paper dimensions *;
local paper=lower(trim(`"`paper'"'));
if `"`paper'"'=="us" {;
  local paper "12240 15840";
};
else if `"`paper'"'=="usland" {;
  local paper "15840 12240";
};
else if `"`paper'"'=="a4" {;
  local paper "11909 16834";
};
else if `"`paper'"'=="a4land" {;
  local paper "16834 11909";
};
* Set paper dimensions and margins parameters *;
papermargins, paper(`paper') margins(`margins');
foreach LM in paperw paperh margl margr margt margb {;
  local `LM'="`r(`LM')'";
};

*
 Fill in RTF commands
*;
file write `namelist' _n "\sect" _n;
if "`default'"!="" {;
  file write `namelist' "\sectd" _n;
};
if `"`paper'"'!="" {;
  file write `namelist'  "\pghsxn`paperh'\pgwsxn`paperw'" _n;
};
if `"`landscp'"'!="" {;
  file write `namelist' "`landscp'" _n;
};
if `"`margins'"'!="" {;
  file write `namelist'
    "\marglsxn`margl'\margrsxn`margr'\margtsxn`margt'\margbsxn`margb'" _n;
};

end;

prog def papermargins, rclass;
version 11.0;
/*
 Extract paper dimensions and margins from the provided options
*/
syntax , [ PAper(numlist >0 integer min=2 max=2) MArgins(numlist >=0 integer min=4 max=4) ];
/*
  paper() specifies paper width and height (in twips).
  margins specifies paper margins (in twips: left, right, top, bottom). 
*/

local paperw: word 1 of `paper';
local paperh: word 2 of `paper';
local margl: word 1 of `margins';
local margr: word 2 of `margins';
local margt: word 3 of `margins';
local margb: word 4 of `margins';

retu local margb="`margb'";
retu local margt="`margt'";
retu local margr="`margr'";
retu local margl="`margl'";
retu local paperw="`paperw'";
retu local paperh="`paperh'";

end;
