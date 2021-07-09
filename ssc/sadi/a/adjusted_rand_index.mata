mata:


real function ARI(real matrix D) {
/* Take a matrix D which is the body of an RxC table, and return the
   Adjusted Rand Index. \cite{vinhar:_infor_theor_measur_clust_compar}

Adjusted Rand Index:

For RxC contingency table (e.g. cluster comparison)

                     sum(combination(2,n_ij) - [ sum(combination(2, n_i+)*sum(combination(2, n_+i))]/combination(2,N)
ARI = ------------------------------------------------------------------------------------------------------------------------------------
      0.5*[ sum(combination(2, n_i+) + sum(combination(2, n_+i)) ] - [sum(combination(2, n_i+)*sum(combination(2, n_+i))]/combination(2,N)

combination(2,x) is the number of pairs of x, which is n!/2!(n-2)! = n*(n-1)/2

*/
  real matrix Dc,r,rc,c,cc
  real N, c2N, ari

  Dc = D :* (D :- 1) :/ 2

  r=rowsum(D)
  rc = r :* (r :- 1) :/ 2

  c=colsum(D)
  cc = c :* (c :- 1) :/ 2

  N = sum(D)
  c2N = N*(N-1)/2

  ari = ( sum(Dc) - (sum(rc)*sum(cc))/c2N ) / ( 0.5*(sum(rc) + sum(cc)) - (sum(rc)*sum(cc))/c2N )

  return(ari)
  }

end
