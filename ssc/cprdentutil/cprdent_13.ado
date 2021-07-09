#delim ;
prog def cprdent_13, rclass;
version 13;
/*
  Decode data* variables for entity type 13.
*!Author: Roger Newson
*!Date: 04 November 2016
*/

syntax [ , DOfile(string) ];

*
 Check that all data variables are present
*;
local Ndatafield=3;
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
  gene weight=real(data1);
  compress weight;
  lab var weight "Weight (kilos)";
  gene double weightcentile=real(data2);
  compress weightcentile;
  cap lab val weightcentile cen;
  lab var weightcentile "Weight centile";
  gene bmi=real(data3);
  compress bmi;
  lab var bmi "BMI (kilos/square metre)";
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
