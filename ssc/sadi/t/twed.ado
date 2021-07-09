/* Copyright 2007 Brendan Halpin brendan.halpin@ul.ie
   Distribution is permitted under the terms of the GNU General Public Licence

   Jul 19 2008 08:23:29
   copy of timewarp.ado

   $Id: twed.ado,v 1.13 2015/02/14 11:25:23 brendan Exp $
   $Log: twed.ado,v $
   Revision 1.13  2015/02/14 11:25:23  brendan
   Summary: Bypass Stata matrix to lift 11k limit, add DUPS option

   Revision 1.12  2014/03/30 21:43:09  brendan
   Summary: Regularised duplicates message

   Revision 1.11  2012/06/28 23:10:27  brendan
   Made version string optional, fixed numeric/string issue with
   normalisation parameter

   Revision 1.10  2012/06/21 20:28:19  brendan
   Standardising message shouldn't be a warning

   Revision 1.9  2012/06/20 14:58:48  brendan
   Included mm_expand check/hint

   Revision 1.8  2012/06/16 22:49:16  brendan
   Correcting "standard not recognised" message

   Revision 1.7  2012/06/15 23:43:00  brendan
   Normalisation

   Revision 1.6  2012/06/15 21:42:10  brendan
   Added normalisation and proper handling of `touse'

   Revision 1.5  2011/11/01 21:13:04  brendan
   Removed unneeded save of "hold" matrix, copy of pwdist

   Revision 1.4  2011/10/03 22:08:10  brendan
   Check \$id\$


*/
#delimit ;

capture program drop twed;
capture program drop omamatv3;
program omamatv3, plugin;

   mata:;
   real matrix function expandpwdist(real matrix raw, real matrix seqid, real matrix nd)
     {
     output = mm_expand(raw,nd,nd,1)
     return(output[invorder(seqid), invorder(seqid)])
     }
     end;
   

program define twed;
version 9;
   syntax varlist [if] [in] [using/] ,
     SUBSmat(string)
     LAMbda(real)
     NU(real)
     PWDist(string)
     LENgth(string)
     [REFstr(integer 0) WORkspace DUps STAndard(string) VERsion] ;

   if ("`version'" != "") {;
   di "TWED version: \$Id: twed.ado,v 1.13 2015/02/14 11:25:23 brendan Exp $";
      };
      
   
   local norm 1;
   if ("`standard'"=="longer") {;
      local norm 1;
      };
   else if (inlist("`standard'","longer","none")) {;
      local norm 0;
      };
   if (`norm'==1) {;
      di "Normalising distances with respect to length";
      };
   else {;
      di "Not normalising distances with respect to length";
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

   tempname twtype;
   local twtype 3;    
   
   tempvar idvar;
   tempvar lengthvar;
   gen `lengthvar' = `length';
   tempname indelcost;
   scalar `indelcost' = 0;

   local printworkspace 0;
   if "`workspace'" ~= "" {;
      local printworkspace 1;
      };
     
   local adjdur 1;
   local facexp 1;

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
     `subsmat' `indelcost' subsrows `pwdist' `adjdur' `printworkspace' `facexp'
     `twtype' `lambda' `nu' `refstr' 1 1 `norm';

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
