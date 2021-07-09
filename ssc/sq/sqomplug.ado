/* Copyright 2007 Brendan Halpin brendan.halpin@ul.ie
   Distribution is permitted under the terms of the GNU General Public Licence
*/
#delimit ;

capture program drop sqomplug;
capture program drop omafast;
program omafast, plugin;


program define sqomplug;
version 9;
   syntax varlist, SUBSmat(string) INDel(real) PWDist(string);

   tempvar idvar;
   tempvar lengthvar;
   tempname indelcost;
   scalar `indelcost' = `indel';

   /* Deal with rawcost and subcost as number
     Rawcost: sorry, can't do now
     Subcost as number: generate matrix
     */


   /* subcost:

   1: it's a number
   2: if it has been set to zero use SQsubcost  matrix
   3: it's "rawdistance"
   4: it's other, invalid
*/
   capture confirm number `subsmat';
   if !_rc & "`subsmat'"!="0" {; /* It is a number, implicitly greater than zero given processing in sqom.ado */
      di "Fixed substitution cost: `subsmat'";
      
      /* Create a substitution matrix with subsmat on all off-diagonal cells */
      tempname dimsubs;
      scalar `dimsubs' = colsof(levels);
      matrix SQsubcost = J(`dimsubs',`dimsubs',`subsmat') - diag(J(`dimsubs',1,`subsmat'));

      };
   else {;
      if "`subsmat'" == "0" {;
         di "Using matrix SQsubcost for substitution costs";
         };
      else {;
         /* It's not a number > 0 */
         if "`subsmat'" == "rawdistance" {;
            noi di as error "Value -rawdistance- for SQOM option subcost() not accepted with -plug-";
            exit 198;
         };
         else {;
            noi di as error 
              "SQOM subcost() invalid: specify number or matrix for -plug-";
            exit 198;
         };
      };
   };
      
      
   
   
   /* generate length variable */

   local length 0;
   gen `lengthvar' = 0;
   foreach x of varlist `varlist' {;
      qui replace `lengthvar' = `length' if missing(`x') & `lengthvar'==0;
      local length = `length'+1;
      };
   qui replace `lengthvar' = `length' if `lengthvar'==0;

   local adjdur 0;

   gen `idvar'=_n;

   local N = _N ;
	mata: `pwdist' = SQdist=J(`N',`N',0) ;
	mata: st_matrix("SQdist",(makesymmetric(`pwdist'))) ;
   
     /* Arguments hardcoded into omafast:
     0: substitution matrix name
     1: indel cost
     2: output matrix
     3: adjust for duration?
     4: show workspace?
     5: exponent
     */
   /* Checks?
   1: is subsmat a matrix, a square matrix, with dimension >= n-states
   2: is indel an integer? relate to max subscost?
   3: let pwdist be a name only
*/

   scalar subsrows = rowsof(SQsubcost);
   scalar subscols = colsof(SQsubcost);
   if subsrows!=subscols {;
      di "Error: non square substitution matrix";
      exit;
      };
   plugin call omafast `idvar' `lengthvar' `varlist',
                        SQsubcost `indelcost' `pwdist' `adjdur' 0 0;
   
end;
   

