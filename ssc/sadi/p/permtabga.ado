   /* Copyright 2010 Brendan Halpin brendan.halpin@ul.ie
   Distribution is permitted under the terms of the GNU General Public Licence
*/
   /*

   $Id: permtabga.ado,v 1.4 2014/03/30 17:12:04 brendan Exp $

   Dec  6 2010 20:57:22
   
   Version of permtab.ado to implement Genetic Algorithm search for best permutation

   Adapted code from ~/work/mlmmarks/mathssem/ga3.do

   With GA plus permtab_mutate_pv() seems to turn up fairly stable results


   */

   mata:
   
   real permtab_kappa(real matrix D, real gtot) {
      real po, pe, ktmp
      po=trace(D)/gtot
      pe=trace(rowsum(D)*colsum(D)/gtot)/gtot
      ktmp = (po-pe)/(1-pe)
      
      return(ktmp)
      }

   real permtab_permute_all(real matrix perm,real matrix D, real gtot) {
      real matrix info, p
      real kmax
      info=cvpermutesetup(perm)
      kmax = 0
      
      while ((p=cvpermute(info)) != J(0,1,.)) {
         temp = permtab_kappa(D[.,p],gtot)
         
         if (temp>kmax) {
            kmax=temp
            perm=p
            }
         }
      return(kmax)
      }

   real function permtab_hillclimb_mutate(real matrix pv, real matrix table) {
      real converged, index, niter, tabtot
      real matrix newpv
      converged = 0
      niter = 20

      tabtot = sum(table)
      
      for (index = 1; index <= niter & !converged; index++) {
         newpv = permtab_mutate_pv(pv, table, 1)
         /* printf("New score: %7.4f\n",permtab_kappa(table[,newpv],tabtot)) */
         if (permtab_kappa(table[,newpv],tabtot) > permtab_kappa(table[,pv],tabtot)) {
            pv = newpv
            } else {
            converged = 1
            }
         }
      return(pv)
      }

   real permtabga_evolve(real matrix pv, real matrix D, real gtot) {
      real genepoolsize, nsurv, nmate_die, nnewblood, niter
      real matrix survivors, offspring, maters, scoreboard
      real scalar noffspring, nmaters, Dtot, i, j, k, l, index, dim, meanscore
      
      genepoolsize = 8000
      nsurv = 2000
      nmate_die = 2000
      nnewblood = 2000
      
      niter = 250
      
      nmaters = nsurv + nmate_die + nnewblood
      noffspring = genepoolsize - nsurv
      
      dim = rows(D)
      Dtot = sum(D)
      /* Initialise genepool with random values */
      genepool = uniform(genepoolsize,dim)
      
      scoreboard = J(genepoolsize,1,0)
      
      /* For each being, get its score */
      for (i=1; i<=genepoolsize; i++) {
         
         /* Permutation order is based on the random values in each row */
         pv = order(genepool[i,]',1)
         
         /* The score for the being is based on the permuted D */
         scoreboard[i,1] = permtab_kappa(D[.,pv],Dtot)
         
         }
      printf("          Max   Mean(top)  Mean(low)     Var(top)\n")
      printf("%5.0f: %7.4f   %7.4f     %7.4f     %8.6f\n",
         0,
         scoreboard[nsurv],
         mean(scoreboard[1..nsurv]),
         mean(scoreboard[nsurv+1..genepoolsize]),
         variance(scoreboard[1..nsurv]))
      displayflush()
      
      converged = 0
      
      for (index = 1; index<=niter & !converged; index++) {
         
         /* sort genepool in ascending order of fitness */
         genepool = genepool[order(scoreboard,1)',]
         
         /* Mate random pairs
         All of nsurv plus the next nmate_die plus nnewblood mate
         indiscriminately, providing noffspring offspring. 
*/
         survivors = genepool[(genepoolsize-nsurv+1)..genepoolsize,.]
         
         maters = survivors\genepool[(genepoolsize-nsurv-nmate_die+1)..genepoolsize-nsurv,.]\uniform(nnewblood,dim)
         
         offspring = J(noffspring,dim,.)
         
         
         for (i=1;i<=noffspring;i++) {
            j = round(0.5+uniform(1,1)*nmaters)
            k = round(0.5+uniform(1,1)*nmaters)
            l = round(0.5+uniform(1,1)*(dim-1))
            
            /* printf("%5.0f%5.0f%5.0f%5.0f\n",i,j,k,l) */
            /* displayflush() */
            
            offspring[i,1..l] = maters[j,1..l]
            offspring[i,l+1..dim] = maters[k,l+1..dim]
            
            }
         
         genepool = survivors \ offspring
         
         /* Implicit:
         genepool[newblood+noffpring+1 .. genepoolsize,] = survivors
*/
         
         for (i=1; i<=genepoolsize; i++) {
            pv = order(genepool[i,]',1)
            scoreboard[i,1] = permtab_kappa(D[.,pv],Dtot)
            }
         
         meanscore = mean(scoreboard[1..nsurv])
         
         if (mod(index,10)==0) {
            printf("%5.0f: %7.4f   %7.4f     %7.4f     %8.6f\n",
               index,
               scoreboard[nsurv],
               meanscore,
               mean(scoreboard[nsurv+1..genepoolsize]),
               variance(scoreboard[1..nsurv]))
            displayflush()
            }
         
         converged = scoreboard[nsurv] == meanscore
         
         }
      pv = order(genepool[nsurv,]',1)
      kmax = permtab_kappa(D[,pv],Dtot)
      return(pv)
      }
   
   real matrix function permtab_mutate_pv ( real matrix pv, real matrix table, real step) {
      /* Function to apply all consecutive pairwise swaps to PV, printing
      score.
      
      Use on a high quality solution to see if minor local "mutations"
      improve the fitness.
      
      Iterate by hand.
      
*/
      /* printf("Mutate step: %5.0f\n",step) */
      displayflush()
      real dim, i, basescore, mutscore, twiddle, tabtot
      real vector pv2, pvmax
      
      twiddle = 0
      dim = length(pv)
      tabtot = sum(table)
      basescore = permtab_kappa(table[,pv],tabtot)
      pvmax = pv
      
      for (i=1; i<=dim; i++) {
         pv2 = pv
         pv2[i]=pv[1+mod(i+step,dim)]
         pv2[1+mod(i+step,dim)]=pv[i]
         mutscore =  permtab_kappa(table[,pv2],tabtot)
         if (mutscore>basescore) {
            /* printf("%5.0f: %15.1f\n", i,  mutscore) */
            basescore = mutscore
            pvmax = pv2
            twiddle = i
            }
         }
      
      if ((step<=dim-2) & (permtab_kappa(table[,pv],tabtot) >= permtab_kappa(table[,pvmax],tabtot))) {
         /* printf("Recurse: %5.0f\n",step) */
         pvmax = permtab_mutate_pv (pvmax, table, step+1)
         }
       return(pvmax)
      }
   
   void permute_square_table_ga (string matrix tabmat) {
      real which, grandtotal
      real matrix permmax
      which = 2
      // Read stata matrix into mata
      G=st_matrix(tabmat)
      
      if (rows(G)!=cols(G)) {
         _error("Table isn't square")
         }
      
      grandtotal=sum(G)
      permmax=range(1,rows(G),1)
      
      if (which==1) {
         // initialise permutation col-vector
         
         // Setup and loop through all permutations
         kmax = permtab_permute_all(permmax,G,grandtotal)
         } else {
         // do it evolve-style
         permmax = permtabga_evolve(permmax,G,grandtotal)
         printf("GA high score: %7.4f\n",permtab_kappa(G[,permmax],grandtotal))
         displayflush()
         permmax = permtab_hillclimb_mutate(permmax,G)
         printf("Hillclimb high score: %7.4f\n",permtab_kappa(G[,permmax],grandtotal))
         displayflush()

         kmax = permtab_kappa(G[,permmax],grandtotal)
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
      
      st_local("permtabperm",recodestr)
      }   
end

/* capture program drop permtabga */
program permtabga
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
   tab `rowvar' `colvar' if `touse',  matcell(`tabmat')

   ari `rowvar' `colvar'
   
   scalar `nrows' = rowsof(`tabmat')
   di "Calculating permutation:"
   
   mata: permute_square_table_ga("`tabmat'")
   if "`newvar'"=="" {
     local newvar `gen'
   }
   if "`newvar'"!="" {
      gen `newvar'=`colvar'
      recode `newvar' `permtabperm'
      }
   
end
   
