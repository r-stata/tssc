/* Copyright 2007 Brendan Halpin brendan.halpin@ul.ie
   Distribution is permitted under the terms of the GNU General Public Licence
*/
#delimit ;

capture program drop omav;
capture program drop omamatv3;
program omamatv3, plugin;

   mata:;
   real matrix function expandpwdist(real matrix raw, real matrix seqid, real matrix nd)
     {
     output = mm_expand(raw,nd,nd,1)
     return(output[invorder(seqid), invorder(seqid)])
     }
     end;
   
program define omav;
version 9;
   syntax varlist [if] [in] [using/] ,
     SUBSmat(string)
     INDel(real)
     PWDist(string)
     LENgth(string)
     [FACexp(real 0.5)
     REFstr(integer 0) WORkspace DUps STAndard(string)] ;

   local norm 1;
   if ("`standard'"=="longer") {;
      local norm 1;
      };
   else if (inlist("`standard'","longer","none")) {;
         local norm 0;
         };
      else {;
         di "Normalising distances with respect to length";
         };
   
   if ("`dups'"=="") {;
     local dups 0;
     };
     else {;
     local dups 1;
     };


   marksample touse, novarlist; // novarlist mean keep cases with missing vars
   preserve;
   keep if `touse';
   tempvar idvar;
   tempvar lengthvar;
   gen `lengthvar' = `length';
   tempname indelcost;
   scalar `indelcost' = `indel';

   local printworkspace 0;
   if "`workspace'" ~= "" {;
      local printworkspace 1;
      };

   local adjdur 1;

   tempname ndups;
   tempname first;
   
   gen `idvar'=_n;

   if (`dups'==0) {;


   sort `varlist';
   //                   mkmat `idvar';
   mata: st_matrix("`idvar'", st_data(.,"`idvar'"));

   by `varlist': gen `ndups' = _N;
   by `varlist': gen `first' = _n==1;

   qui count if `first';
   di "`r(N)' unique observations";
   qui keep if `first';

   // mkmat `ndups';
   mata: st_matrix("`ndups'", st_data(.,"`ndups'"));
      };
   
   local ncols `refstr';
   if `ncols' == 0 {;
     local ncols = _N;
     };

  
   //matrix `pwdist' = J(_N,`ncols',0);
   mata: st_matrix("`pwdist'", J(`=_N',`ncols',0));
   
     /* Arguments hardcoded into omamatv3:
     0: substitution matrix name
     1: indel cost
     2: output matrix
     3: dimensions of subsmatrix
     4: adjust for duration?
     5: show workspace?
     6: exponent
     */
   /* Checks?
   1: is subsmat a matrix, a square matrix, with dimension >= n-states
   2: is indel an integer? relate to max subscost?
   3: let pwdist be a name only
*/

   scalar subsrows = rowsof(`subsmat');
   scalar subscols = colsof(`subsmat');
   if subsrows!=subscols {;
      di "Error: non square substitution matrix";
      exit;
      };

   plugin call omamatv3 `idvar' `lengthvar' `varlist',
                        `subsmat' `indelcost' subsrows `pwdist' `adjdur' `printworkspace' `facexp' 1 1 0 `refstr' 1 1 `norm';

   if (`dups'==0) {;
      capture mata mata which mm_expand();
      if _rc {;                                                                              
         di as error "mm_expand() from -moremata- is required; type -ssc install moremata- to obtain it";
         di as error "Alternatively, use the {cmd:dups} option to treat duplicate sequences";
         exit 499;           
      };

      mata: `pwdist'= expandpwdist(st_matrix("`pwdist'"),st_matrix("`idvar'"),st_matrix("`ndups'"));
      mata: st_matrix("`pwdist'",`pwdist');
      mata: mata drop `pwdist'; // Drop the mata copy of the PWdist matrix, no longer needed & potentially large
                  
      };
   restore;

end;
