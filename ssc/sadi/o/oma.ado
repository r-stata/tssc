/* Copyright 2007 Brendan Halpin brendan.halpin@ul.ie
   Distribution is permitted under the terms of the GNU General Public Licence

   $Id: oma.ado,v 1.16 2015/02/14 11:21:40 brendan Exp $

   $Log: oma.ado,v $
   Revision 1.16  2015/02/14 11:21:40  brendan
   Summary: Bypass Stata matrix to lift 11k limit

   Revision 1.15  2012/06/28 10:55:21  brendan
   Made version message optional

   Revision 1.14  2012/06/28 10:54:02  brendan
   Corrected normalisation message

   Revision 1.13  2012/06/20 14:57:19  brendan
   Included mm_expand check/hint

   Revision 1.12  2012/06/16 22:48:34  brendan
   Correcting "standard not recognised" message

   Revision 1.11  2012/06/15 23:40:43  brendan
   Corrections

   Revision 1.10  2012/06/15 21:42:44  brendan
   Added normalisation

   Revision 1.9  2012/06/11 21:07:05  brendan
   Added novarlist option to marksample so as to allow missing values in
   sequence variables where length is less than max.

   Revision 1.8  2012/05/26 16:19:51  brendan
   Think if/in is now working

   Revision 1.7  2012/04/19 22:44:56  brendan
   New option to ignore duplicates and calculate all distances

   Revision 1.6  2011/10/04 09:47:35  brendan
   Added display of RCS version string

   Revision 1.5  2011/09/21 17:17:42  brendan
   Added Id and Log to comment at top


*/
#delimit ;

capture program drop oma;
capture program drop omamatv3;
program omamatv3, plugin;

   mata:;
   real matrix function expandpwdist(real matrix raw, real matrix seqid, real matrix nd)
     {
     output = mm_expand(raw,nd,nd,1)
     return(output[invorder(seqid), invorder(seqid)])
     }
     end;
   
program define oma;
version 9;
   syntax varlist [if] [in] [using/] ,
     SUBSmat(string)
     INDel(real)
     PWDist(string)
     LENgth(string)
     [REFstr(integer 0)
       WORkspace DUps STAndard(string) VERsion];
      
   if ("`version'" != "") {;
      di "OMA version: \$Id: oma.ado,v 1.16 2015/02/14 11:21:40 brendan Exp $";
      };
      
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
     
   local adjdur 0;
   local exponent 0; /* Unnecessary, C code checks if present */

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
   
   //this setting needs to be here since _N has changed
   local ncols `refstr';
   if `ncols' == 0 {;
     local ncols = _N;
     };

   
   //matrix `pwdist' = J(_N,`ncols',0);
   mata: st_matrix("`pwdist'",  J(`=_N',`ncols',0));
   
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
                        `subsmat' `indelcost' subsrows `pwdist' `adjdur' `printworkspace' `exponent' 1 0 0 `refstr' 1 1 `norm';

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
