#delim ;
prog def cprdent_4, rclass;
version 13;
/*
  Decode data* variables for entity type 4.
*!Author: Roger Newson
*!Date: 04 November 2016
*/

syntax [ , DOfile(string) ];

*
 Check that all data variables are present
*;
local Ndatafield=6;
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
  gene double smokingstatus=real(data1);
  compress smokingstatus;
  lab val smokingstatus ynd;
  lab var smokingstatus "Smoking status";
  gene double cigsperday=real(data2);
  compress cigsperday;
  lab var cigsperday "Cigarettes per day";
  gene double cigarsperday=real(data3);
  compress cigarsperday;
  lab var cigarsperday "Cigars per day";
  gene double tobaccoperday=real(data4);
  compress tobaccoperday;
  lab var tobaccoperday "Tobacco per day (ounces)";
  gene double startdate=date(data5,"DMY");
  compress startdate;
  format startdate %tdCCYY/NN/DD;
  lab var startdate "Date started smoking";
  gene double stopdate=date(data6,"DMY");
  compress stopdate;
  format stopdate %tdCCYY/NN/DD;
  lab var stopdate "Date stopped smoking";
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
