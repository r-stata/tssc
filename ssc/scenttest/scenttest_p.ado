#delim ;
program define scenttest_p;
version 14.0;
/*
 Predict program for scenttest
 (warning the user that predict should not be used
 after scenttest)
*!Author: Roger Newson
*!Date: 09 April 2015
*/

syntax [newvarlist] [, *];

disp as error
 "predict should not be used after scenttest";
error 498;

end;
