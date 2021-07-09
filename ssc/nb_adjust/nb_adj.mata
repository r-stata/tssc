// Adjust or remove outliers of neg-bin distributed variable
// Used in -nb_adjust-
// Version 2.01  23-Feb-2015, Dirk Enzmann

version 12.1
mata:
  mata clear
  mata set matastrict on
  void nb_adj(string scalar vname,   ///
             string scalar newvname, ///
             string scalar selvar,   ///
             real scalar thout,      ///
             real scalar small,      ///
             real scalar low,        ///
             real scalar n,          ///
             real scalar mu,         ///
             real scalar size,       ///
             real scalar replicates, ///
             string scalar remove,   ///
             string scalar censor) {

    real scalar prob
    real matrix x
    real scalar counts
    real scalar nmiss
    real matrix nbdat
    real scalar nout
    real scalar pmisfit
    real scalar nadj
    real matrix xnew
    real matrix xnewmat
    real vector varind
    real scalar i
    real scalar j

    if (size > 1e+6 & size < .) size = 1e+6
    prob = size/(size+mu)
    x = st_data(., vname, selvar)
    x = x, (1::rows(x))
    counts = 0::max(x[.,1])
    nmiss = rows(x)-n
    if (thout == 0) {
      nbdat = round(n * nbinomialp(size,counts,prob))
      thout = counts[max(mm_which(nbdat:>0)),1]
      st_numscalar(st_local("thout"),thout)
    }
    if (thout < low) {
      low = max((small, thout))
      st_numscalar(st_local("low"),low)
      st_local("notify","(Note:")
    }
    nout = rows(mm_which(x[.,1] :> thout))-nmiss
    pmisfit = 100*nout/n
    if (thout < small) {
      nadj = rows(mm_which(x[.,1] :> small))-nmiss
    }
    else {
      nadj = nout
    }
    st_numscalar(st_local("nout"),nout)
    st_numscalar(st_local("pmisfit"),pmisfit)
    st_numscalar(st_local("nadj"),nadj)
    xnew = J(nadj,1,.)
    xnewmat = J(nadj,replicates+1,.)
    if (remove == "" & censor == "") {
      for (j = 1; j <= replicates+1; j++) {
        for (i = 1; i <= nadj; i++) {
          do {
            xnew[i,1] = rnbinom(1,1,size,mu)
          } while (xnew[i,1] < low)
        }
        xnewmat[,j] = sort(xnew,-1)
      }
      xnew = sort(round(rowsum(xnewmat):/(replicates+1)),-1)
    }
    x = sort(x,-1)
    for (i = nmiss+1; i <= (nmiss+nadj); i++) {
      if ((x[i,1] > xnew[i-nmiss,1]) & (remove == "" & censor == "")) {
        x[i,1] = xnew[i-nmiss,1]
      }
      else if (censor == "censor") {
        x[i,1] = thout
      }
      else if (remove == "remove") {
        x[i,1] = .o
      }
    }
    x = sort(x,2)
    varind = st_addvar("float", newvname)
    st_store(., newvname, selvar, x[.,1])
  }
  mata mosave nb_adj(), replace
end
