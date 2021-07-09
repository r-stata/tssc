#delim ;
program define punaf_p;
version 14.0;
/*
 Predict program for punaf
 (warning the user that predict should not be used
 after punaf)
*! Author: Roger Newson
*! Date: 11 September 2013
*/

syntax [newvarlist] [, *];

disp as error
 "predict should not be used after punaf";
error 498;

end;
