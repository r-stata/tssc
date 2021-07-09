   // Jun 22 2012 15:19:40
   // Discrepancy as per Studer et al.
   
   // VARLIST is the grouping variable
   // DISTMAT is the distance matrix
   // NITER (optional) is the number of permutations to test.
   // DCG (optional) names a variable to store the distance-to-COG vector   
   
version 10.0

program define discrepancy, rclass
   syntax varlist (min=1 max=1), DISTmat(string) IDvar(varname) [NITer(integer 100) DCG(string)]
   
   tempname resmat
   tempname groupN
   tempname distvar

   // Insist on correct sort order, and that it is unique
   qui des, varlist
   local so `r(sortlist)'
   local mainsort : word 1 of `so'
   if ("`mainsort'" != "`idvar'") {
      di in red "Error: data must be sorted by same ID variable as used for defining distances"
      error 5
      }
   isid `idvar'
   
   // Get the classification and its size into matrices
   qui tab `varlist', matcell(`groupN')

   // Call the main mata function and display the key results
   mata: st_matrix("`resmat'",discgroup(st_matrix("`distmat'"), st_matrix("`groupN'"),st_data(.,("`varlist'")),`niter', "`distvar'"))
   mat colnames `resmat' = "pseudo R2" "pseudo F" "p-value"
   mat rownames `resmat' = "`varlist'"
   di _newline "Discrepancy based R2 and F, `niter' permutations for p-value"
   matlist `resmat'

   // Save the distance-to-COG vector, if requested
   if ("`dcg'" != "") {
      gen `dcg' = `distvar'
      table `varlist', c(n `dcg' min `dcg' mean `dcg' max `dcg')
      }

   // Return the three key numbers
   return scalar pseudoR2 = `resmat'[1,1]
   return scalar pseudoF  = `resmat'[1,2]
   return scalar p_perm   = `resmat'[1,3]
end
   

   mata:
   real matrix discgroup(real matrix dist, real vector groupsize,
      real vector groupvar, real scalar niter, string dgvar) {
      
      real scalar ngroups, i, low, high, SSt
      real vector cumulate, ro, dg, SS, permutations, reorder
      real matrix distg
      real scalar pseudoR2, pseudoF, pval

      
      ngroups  = rows(groupsize)
      cumulate = J(ngroups+1,1,0)
      ro       = J(rows(dist),1,.)
      dg       = J(rows(dist),1,.)
      SS       = J(ngroups,1,.)

      // SSt is discrepancy across the whole matrix
      SSt = sum(dist)*0.5*(1/rows(dist))
      
      for (i=1; i<=ngroups; i++) {
         cumulate[i+1] = cumulate[i]+groupsize[i]
         }
      // Order the distance matrix by the grouping variable
      reorder = order(groupvar,1)
      distg = dist[reorder,reorder]

      // Calculate the within-group discrepancy for each group
      for (i=1; i<=ngroups; i++) {
         low = cumulate[i]+1
         high = cumulate[i+1]
         ro[low..high] = rowsum(distg[low..high,low..high])
         SS[i] = sum(distg[low..high,low..high])*0.5*(1/(high + 1 - low))
         dg[low..high,1] = (ro[low..high] :- SS[i]) :/ (high + 1 - low)
         }

      // Give the distance-to-COG back to Stata as a variable
      // Note it has to be reordered
      idx = st_addvar("double",dgvar)
      st_view(V=.,.,idx)
      V[.,.] = (dg[invorder(reorder)])

      // Calculate the main values to return
      pseudoF  = ((SSt - sum(dg))/(ngroups - 1))/(sum(dg)/(rows(distg)-ngroups))
      pseudoR2 =  (SSt - sum(dg))/SSt

      // Permute the distance matrix to generate a distribution of pseudo-Fs under the null
      permutations = J(niter,1,.)
      for (i=1; i<=niter; i++) {
         for (j=1; j<=ngroups; j++) {
            low = cumulate[j]+1
            high = cumulate[j+1]
            distg = dist[order(uniform(rows(dist),1),1),order(uniform(rows(dist),1),1)]
            ro[low..high] = rowsum(distg[low..high,low..high])
            SS[j] = sum(distg[low..high,low..high])*0.5*(1/(high + 1 - low))
            dg[low..high,1] = (ro[low..high] :- SS[j]) :/ (high + 1 - low)
            }
         permutations[i] = ((SSt - sum(dg))/(ngroups - 1))/(sum(dg)/(rows(distg)-ngroups))
         }

      // The p-value is the proportion of permutation-based Fs that are greater
      // than the calculated F. If none are greater, return 1/niter. 
      pval = max( ( 1/niter, sum(permutations :> pseudoF)/niter ) )

      // Return the values in a vector
      return((pseudoR2,pseudoF,pval))
      }

end
