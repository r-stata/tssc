// Nov 13 2011 14:35:03
// Exploit maketrpr to calculate dynamic Hamming


mata:

// This function is not specific to this adofile and is repeated: should be in a central location
real matrix function expandpwdist(real matrix raw, real matrix seqid, real matrix nd)
  {
  output = mm_expand(raw,nd,nd,1)
  return(output[invorder(seqid), invorder(seqid)])
  }
end


mata:

   // Setup and work through all the pairs, calculating the DH distance
real matrix function dynhamming (string vl, string sm, real scalar nstates, real scalar buzz) {
  real scalar i,j,k;
  real matrix subsmat, resmat;

  st_view(data = .,.,(tokens(vl)));
  maxwidth = cols(data);
  nobs = rows(data);
  resmat = J(nobs,nobs,0);

// (N*T) * N transition probability matrix
  subsmat = st_matrix(sm);

// add p_{ij} to p_{ji} : would  "x :+ x'" be better
      for (i = 1;i<maxwidth;i++) {
         for (j = 1;j<=nstates;j++) {
            subsmat[j + (i-1)*nstates, j] = 2*subsmat[j + (i-1)*nstates, j]; // for buzz, diagonal
            for (k = j+1;k<=nstates;k++) {
               subsmat[j + (i-1)*nstates, k] = subsmat[j + (i-1)*nstates, k] + subsmat[k + (i-1)*nstates, j];
               subsmat[k + (i-1)*nstates, j] = subsmat[j + (i-1)*nstates, k];
               }
            }
         }
      
// Get the DH distance for each pair
      for (i = 1;i <= nobs;i++) {
         for (j = i + 1;j <= nobs;j++) { // Note: explicitly leave a zero in diagonal
            resmat[i,j] = dynhammingdistance(i, j, data, subsmat, nstates, maxwidth, buzz);
            }
         if (buzz==1) {
            resmat[i,i] = dynhammingdistance(i, i, data, subsmat, nstates, maxwidth, buzz);
            }
         }
      
  resmat = resmat + resmat';
  return(resmat)

}


// Calculate the DH distance for pair of sequences
function dynhammingdistance (real scalar first,
                             real scalar second,
                             real matrix data,
                             real matrix subsmat, 
                             real scalar nstates, 
                             real scalar maxwidth, 
                             real scalar buzz) {

  real scalar hammingdistance, i, trprob;

  hammingdistance = 0;

      // for 1 to length - 1, apply the t/t+1 transition probabilities
      // The distance is \sum (2 - trprob). This is in contrast to Lesnard
      // who applies the t-1/t and t/t+1 transitions, with 4 - tr(-1) - tr(+1)
      // However, this is not necessary with smoothed transition rates.
      
  for (i = 1;i<maxwidth;i++) {
         trprob = subsmat[ data[first,i] + (i-1)*nstates, data[second,i] ];
         if ((data[first,i]!=data[second,i]) | buzz==1) { // Feb 18 2012 00:49:00: understandable but spoils the logic!
            hammingdistance = hammingdistance + (2-trprob); 
            }
         }
      
      // for the final time period, there is no transition rate: use the most recent one. 
      i = maxwidth;
      trprob = subsmat[data[first,i] + (i-2)*nstates,data[second,i]];
      if ((data[first,i]!=data[second,i]) | buzz==1) { // Feb 18 2012 00:49:00: understandable but spoils the logic!
         hammingdistance = hammingdistance + (2-trprob);
         }
      
      return(hammingdistance/maxwidth);
      
      }
end
   
   
capture program drop dynhamming
program define dynhamming
version 9
   syntax varlist , PWDist(string)  [DUps BUzz MAwindow(integer 3)]
   
   // Facility to over-ride exclusion of duplicates
   // Nov 14 2011 : there is a bug here, in that without
   // exclusion of duplicates, matches between duplicates
   // (in some cases) do not return zero. When duplicates
   // are excluded and then expanded, this doesn't seem to
   // happen.
   
   if ("`dups'"=="") {
      local dups 0
      }
   else {
      local dups 1
      }
   
   if ("`buzz'"=="") {
      local buzz 0
      }
   else {
      local buzz 1
      }

   tempname subsmat

   // Generate the dynamic transition probability matrix
   qui maketrpr `varlist', mat(`subsmat') ma(`mawindow')

   local nstates `r(nstates)'

   tempname ndups
   tempname first

   tempvar idvar

   //matrix `pwdist' = J(_N,_N,0);
   mata: st_matrix("`pwdist'", J(`=_N',`=_N',0));
   
   gen `idvar'=_n

   if (`dups'==0) {   
      preserve
      
      sort `varlist'
      //                   mkmat `idvar';
      mata: st_matrix("`idvar'", st_data(.,"`idvar'"));
      by `varlist': gen `ndups' = _N
      by `varlist': gen `first' = _n==1

      qui count if `first'
      di "`r(N)' unique observations"
      qui keep if `first'
      
      // mkmat `ndups'
      mata: st_matrix("`ndups'", st_data(.,"`ndups'"))
      }
   
   // Apply it to the data, via Mata function
   mata `pwdist' = dynhamming("`varlist'","`subsmat'",`nstates',`buzz')
   // Save the distances (duplicates unexpanded)
   mata: st_matrix("`pwdist'",`pwdist')

   // Expand the duplicates and re-save
   if (`dups'==0) {
      tempname pwdtemp
      
      capture mata mata which mm_expand()
      if _rc {
         di as error "mm_expand() from -moremata- is required; type -ssc install moremata- to obtain it"
         di as error "Alternatively, use the {cmd:dups} option to treat duplicate sequences"
         exit 499
         }
      mata: `pwdtemp'= expandpwdist(st_matrix("`pwdist'"),st_matrix("`idvar'"),st_matrix("`ndups'"))
      mata: st_matrix("`pwdist'",`pwdtemp')
      
      restore
      }
end
