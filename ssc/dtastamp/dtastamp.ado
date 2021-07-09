#delim ;
prog def dtastamp;
version 10.0;
/*
 Save current date and time in dataset characteristics.
*! Author: Roger Newson
*! Date: 29 October 2018
*/


syntax  [, DFormat(string) TFormat(string) ];
/*
dformat() specifies the format for the date.
tformat() specifies the format for the time.
*/

*
 Set default formats if necessary
 and check that the format is a %tC format
*;
if `"`dformat'"'=="" {;
  local dformat "%tddd_Mon_CCYY";
};
if `"`tformat'"'==""{;
  local tformat "%tCHH:MM:SS";
};

*
 Get current datetime as a string
*;
tempname sdt;
scalar `sdt'=c(current_date)+" "+c(current_time);

*
 Combine current date and time as a Stata datetime
*;
tempname ndt;
scalar `ndt'=Clock(`sdt',"DMYhms");

*
 Convert datetime back to strings
*;
tempname sd st;
scal `sd'=strofreal(dofC(`ndt'),`"`dformat'"');
scal `st'=strofreal(`ndt',`"`tformat'"');

*
 Assign dataset characteristics
*;
char def _dta[datestamp] `"`=`sd''"';
char def _dta[timestamp] `"`=`st''"';

end;
