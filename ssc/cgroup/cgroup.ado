#delim ;
prog def cgroup;
version 10.0;
/*
 Generate a variable
 with values corresponding to contiguous groups of observations
 with identical values of a varlist.
*!Author: Roger Newson
*!Date: 30 November 2009
*/

syntax varlist , Generate(name);
/*
 generate() specifies the name of a new variable to be generated,
   with values corresponding to contiguous groups of observations
   with identical values of the varlist.
 */
 
 cap confirm new var `generate';
 if _rc!=0 {;
   disp as error "generate() must specify a new variable";
   error 498;
 };
 qui gene long `generate'=_n==1;
 foreach X of var `varlist' {;
   qui replace `generate'=1 if `X'!=`X'[_n-1];
 };
 qui replace `generate'=sum(`generate');
 qui compress `generate';
 lab var `generate' "cgroup(`varlist')";
 
 end;
 