#delim ;
prog def outputst;
version 13.0;
/*
  Output a non-Stata data set using Stat/Transfer
 (with parameters and switches supplied by the user)
 from the Stata data set in the memory.
*!Author: Roger Newson
*!Date: 17 February 2013
*/

tempfile tmpdta;
disp as text "Outputting data to temporary datafile: " as result `"`tmpdta'"';
qui save `"`tmpdta'"', replace;
cap confirm file `"`tmpdta'"';
if _rc!=0 {;
  disp as error "Temporary datafile not created: " as result `"`tmpdta'"';
  error _rc;
};
disp as text "Temporary datafile created: " as result `"`tmpdta'"';
stcmd stata "`tmpdta'" `0';

end;
