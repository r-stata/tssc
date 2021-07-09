/* Copyright 2007-2012 Brendan Halpin brendan.halpin@ul.ie
   Distribution is permitted under the terms of the GNU General Public Licence
*/
#delimit ;

capture program drop elzspelladd;
capture program drop combinadd;
program elzspelladd, plugin;


program define combinadd;
version 9;
   syntax varlist [if] [in] [using/] ,
    NSPells(string) NSTates(real) PWSim(string) [RType(string) WORkspace MAXTuples(integer 40000)];
   marksample touse;
   tempvar idvar;
   tempvar lengthvar;
   gen `lengthvar' = `nspells';
/*    replace `lengthvar' = `maxlength' if `lengthvar' > `maxlength'; */

   gen `idvar'=_n;

   if ("`workspace'" == "") {;
      local workspace 0;
        };
   else {;
      local workspace 1;
        };
   local restype 1;
   if ("`rtype'" == "s") {;
     local restype 1;
   };
   if ("`rtype'" == "d") {;
     local restype 2;
   };
   if ("`rtype'" == "r") {;
     local restype 3;
   };

   local maxcases = _N;
   
   //matrix `pwsim' = J(_N,_N,0);
   mata: st_matrix("`pwsim'",  J(`=_N',`=_N',0));

     /* Arguments hardcoded into elzspelladd
     0: result matrix name
     1: n-states
     */

   di "Running spell-wise Elzinga sequence comparisons";
   plugin call elzspelladd `idvar' `lengthvar' `varlist',
     `pwsim' `nstates' `workspace' `restype'
     `maxcases' `maxtuples'; // Pass maxcases and maxtuples to plugin also
end;


