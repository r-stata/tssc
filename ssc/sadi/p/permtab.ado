/* Copyright 2007 Brendan Halpin brendan.halpin@ul.ie
   Distribution is permitted under the terms of the GNU General Public Licence
*/
   /* Jul 9 2007 16:01:27


   Ado file to take a square table and to permute the columns to
   maximise the excess of observed over expected cases on the
   diagonal

   NB: this is a very inefficient implementation, and looks at
   every permutation of columns. As a result it is painfully slow
   for tables with more than about 8 or 9 columns

   Reports kappa_max, which is the maximum value of kappa achieved
   by the permutations, as proposed in Reilly, Wang and Rutherford
   (2005) but does not use their optimised permutation search. 

   */

   
mata:
void permute_square_table (string matrix tabmat) {
// Read stata matrix into mata
G=st_matrix(tabmat)

if (rows(G)!=cols(G)) {
_error("Table isn't square")
}

// generate permutation col-vector
perm=range(1,rows(G),1)
grandtotal=sum(G)

// initialise
permmax=perm
kmax = 0

// Setup and loop through all permutations
info=cvpermutesetup(perm)

while ((p=cvpermute(info)) != J(0,1,.)) {
         
po=trace(G[.,p])/grandtotal
pe=trace(rowsum(G[.,p])*colsum(G[.,p])/grandtotal)/grandtotal
temp = (po-pe)/(1-pe)

if (temp>kmax) {
 kmax=temp
 permmax=p
}
}

// Report max and permutation
         printf("Kappa max: %6.4f\n",kmax)
         printf("Permutation vector:\n")
permmax

         // Show permuted and original crosstab matrices
         printf("Permuted table:\n")
G[.,permmax]
         printf("Original table:\n")
G


recodestr = ""
for (i=1;i<=rows(permmax);i++) {
 recodestr = recodestr + strofreal(permmax[i]) + "=" + strofreal(i) + " "
}
   st_numscalar("kappamax", kmax)
   st_local("permtabperm",recodestr)
}   
end

program permtab, rclass
version 9.0
   syntax varlist [if] [in] [, newvar(namelist max=1) gen(namelist max=1)]
   tokenize `varlist'
   local rowvar `1'
   macro shift
   local colvar `1'
   tempname tabmat
   tempname nrows

   marksample touse
   
   di "Tabulating raw data:"
   tab `rowvar' `colvar' if `touse' ,  matcell(`tabmat')
   
   scalar `nrows' = rowsof(`tabmat')
   di "Calculating permutation:"
   if `nrows'==9 di "Will be slow: " `nrows' " by " `nrows' " table"
   if `nrows'==10 di "Will be very slow: " `nrows' " by " `nrows' " table"
   if `nrows'>=11 di "Will be infeasibly slow: " `nrows' " by " `nrows' " table"
   
   mata: permute_square_table("`tabmat'")
// Deal with newvar and gen as duplicate options, prefer gen to newvar to be idiomatic
   if "`newvar'"=="" {
     local newvar `gen'
   }
   if "`newvar'"!="" {
      gen `newvar'=`colvar'
      recode `newvar' `permtabperm'
      }
   return scalar kappa = kappamax
end
   
