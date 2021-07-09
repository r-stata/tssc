#delim ;
prog def cprdent_5, rclass;
version 13;
/*
  Decode data* variables for entity type 5.
*!Author: Roger Newson
*!Date: 04 November 2016
*/

syntax [ , DOfile(string) ];

*
 Check that all data variables are present
*;
local Ndatafield=4;
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
  gene double alcoholstatus=real(data1);
  compress alcoholstatus;
  cap lab val alcoholstatus ynd;
  lab var alcoholstatus "Alcohol consumption status";
  gene double unitsperweek=real(data2);
  compress unitsperweek;
  lab var unitsperweek "Units per week";
  gene double startdate=date(data3,"DMY");
  compress startdate;
  format startdate %tdCCYY/NN/DD;
  lab var startdate "Date started drinking alcohol";
  gene double stopdate=date(data4,"DMY");
  compress stopdate;
  format stopdate %tdCCYY/NN/DD;
  lab var stopdate "Date stopped drinking alcohol";
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
