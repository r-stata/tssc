#delim ;
prog def cprdent_175, rclass;
version 13;
/*
  Decode data* variables for entity type 175.
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
  gene double operator=real(data1);
  compress operator;
  cap lab val operator opr;
  lab var operator "Operator";
  gene value=real(data2);
  compress value;
  lab var value "High-density lipoprotein cholesterol value";
  gene double unitofmeasure=real(data3);
  compress unitofmeasure;
  cap lab val unitofmeasure sum;
  lab var unitofmeasure "Unit of measure";
  gene double qualifier=real(data4);
  compress qualifier;
  cap lab val qualifier tqu;
  lab var qualifier "Qualifier";
  gene normalrangefrom=real(data5);
  compress normalrangefrom;
  lab var normalrangefrom "Normal range from";
  gene normalrangeto=real(data6);
  compress normalrangeto;
  lab var normalrangeto "Normal range to";
  gene double normalrangebasis=real(data7);
  compress normalrangebasis;
  cap lab val normalrangebasis pop;
  lab var normalrangebasis "Normal range basis";
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
