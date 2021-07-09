#delim ;
prog def cprdent_1, rclass;
version 13;
/*
  Decode data* variables for entity type 1.
*!Author: Roger Newson
*!Date: 04 November 2016
*/

syntax [ , DOfile(string) ];

*
 Check that all data variables are present
*;
local Ndatafield=7;
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
  gene diabp=real(data1);
  gene sysbp=real(data2);
  compress sysbp diabp;
  lab var sysbp "Systolic blood pressure (mm Hg)";
  lab var diabp "Diastolic blood pressure (mm Hg)";
  gene double korotkoff=real(data3);
  compress korotkoff;
  lab var korotkoff "Korotkoff";
  gene double eventtime=clock(data4,"hm");
  compress eventtime;
  format eventtime %tcHH:MM;
  lab var eventtime "Event Time";
  gene double laterality=real(data5);
  compress laterality;
  cap lab val laterality lat;
  lab var laterality "Laterality";
  gene double posture=real(data6);
  compress posture;
  cap lab val posture pos;
  lab var posture "Posture";
  gene double cuff=real(data7);
  compress cuff;
  cap lab val cuff cuf;
  lab var cuff "Cuff";
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
