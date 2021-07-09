/* Copyright 2007 Brendan Halpin brendan.halpin@ul.ie
   Distribution is permitted under the terms of the GNU General Public Licence
*/
#delimit ;
mata:;

function hamming (string vl, string sm, string rh, real scalar norm) {
subsmat=st_matrix(sm);
st_view(data=.,.,(tokens(vl)));
maxwidth=cols(data);
nobs = rows(data);
resmat = J(nobs,nobs,0);


for (i=1;i<=nobs;i++) {
  for (j=i;j<=nobs;j++) {
    resmat[i,j]=hammingdistance(i,j,data,subsmat,maxwidth,norm);
  }
}

resmat = resmat + resmat';
st_matrix(rh,resmat);

}

function hammingdistance (real scalar first, real scalar second, real matrix data, real matrix subsmat, real scalar maxwidth, real scalar norm) {
  real scalar hammingdistance, i;
  hammingdistance=0;
  for (i=1;i<=maxwidth;i++) {
    hammingdistance=hammingdistance+subsmat[data[first,i],data[second,i]];
  }
  if (norm==1) {
    return(hammingdistance/maxwidth);
  } else {
    return(hammingdistance);
  }
}

end

program define hamming;
version 9;
syntax varlist , SUBSmat(string) PWDist(string) [STAndard(string)];
   local norm 1;
   if ("`standard'"=="longer") {;
      local norm 1;
   };
   else if (inlist("`standard'","none")) {;
         local norm 0;
   };
   else {;
         di "Normalising distances with respect to length";
   };
   

mata hamming("`varlist'","`subsmat'","`pwdist'", `norm');
end;
