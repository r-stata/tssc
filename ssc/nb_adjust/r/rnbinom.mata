// Create neg-bin distributed random numbers
// Used in -nb_adjust- and mata function -nb_adj()-
// Version 2.01  23-Feb-2013, Dirk Enzmann

version 12.1
mata:
  real matrix rnbinom(real scalar r, ///
                      real scalar c, ///
                      real scalar size, ///
                      real scalar mu) {
    real scalar prob
    real scalar scale
    real matrix xg
    real matrix small

    prob = size/(size+mu)
    scale = (1-prob)/prob
    xg = rgamma(r,c,size,scale)
    small = mm_which( (xg\1) :< 1e-6)
    xg[small,.] = J(length(small),c,1e-6)
    return(rpoisson(1,c,xg))
  }
  mata mosave rnbinom(), replace
end
