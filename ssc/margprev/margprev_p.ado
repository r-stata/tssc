#delim ;
program define margprev_p;
version 14.0;
/*
 Predict program for margprev
 (warning the user that predict should not be used
 after margprev)
*! Author: Roger Newson
*! Date: 25 September 2013
*/

syntax [newvarlist] [, *];

disp as error
 "predict should not be used after margprev";
error 498;

end;
