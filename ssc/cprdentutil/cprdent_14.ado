#delim ;
prog def cprdent_14, rclass;
version 13;
/*
  Decode data* variables for entity type 14.
*!Author: Roger Newson
*!Date: 04 November 2016
*/

syntax [ , DOfile(string) ];

*
 Check that all data variables are present
*;
local Ndatafield=2;
local datavars "";
forv i1=1(1)`Ndatafield' {;
  local datavars "`datavars' data`i1'";
};
local datavars: list retokenize datavars;
confirm string var `datavars';

*
 Input value labels if present
*;
if `"`dofile'"'!="" {;
  run `"`dofile'"';
};

*
 Decode data variables to new variables
*;
unab oldvars: *;
qui {;
gene height=real(data1);
compress height;
lab var height "Height (metres)";
gene double heightcentile=real(data2);
compress heightcentile;
cap lab val heightcentile cen;
lab var heightcentile "Height centile";
};
unab newvars: *;
local newvars: list newvars - oldvars;

*
 Remove non-existent value labels for new variables
*;
foreach X of var `newvars' {;
  local Xvallab: val lab `X';
  if "`Xvallab'"!="" {;
    mata: st_local("labpres",strofreal(st_vlexists("`Xvallab'")));
    if !`labpres' lab val `X';
  };
};

*
 Describe new variables
*;
desc `newvars', fu;

*
 Return results
*;
return clear;
return local newvars "`newvars'";
return local datavars "`datavars'";

end;
