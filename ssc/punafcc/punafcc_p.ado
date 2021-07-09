#delim ;
program define punafcc_p;
version 14.0;
/*
 Predict program for punafcc
 (warning the user that predict should not be used
 after punafcc)
*! Author: Roger Newson
*! Date: 09 April 2015
*/

syntax [newvarlist] [, *];

disp as error
 "predict should not be used after punafcc";
error 498;

end;
