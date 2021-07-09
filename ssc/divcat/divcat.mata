*! version 1.3.1  21january2015  Dirk Enzmann
version 11.2
mata:
  mata clear
  mata set matastrict on
  void divsump()
  {
    real matrix ftab
    real matrix ptab
    real scalar i
    ftab = st_matrix(st_local("ftab"))
    ptab = ftab:/colsum(ftab)
    for (i=1; i<=rows(ptab); i++) {
      if (ptab[i]==0) ptab[i]=1
    }
    st_numscalar(st_local("GV"),colsum(ptab:^2))
    st_numscalar(st_local("H"),colsum(ptab:*ln(ptab)))
    st_numscalar(st_local("RQ"),colsum((((.5:-ptab):/.5):^2):*ptab))
  }
  mata mosave divsump(), replace
end
