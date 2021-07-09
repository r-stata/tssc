*! version 1.1.0 21nov2009
program sortl
version 9.0
if (length("`e(r_class)'") == 0) {
  dis as err "rotation results not found, use -rotate- first"
  error 301
}
mata: sortloadings()
local cs ""
forvalues i = 1/`e(r_f)' {
  if (`i'== 1) local cs = "`cs'%8.4f"
  else local cs = "`cs'&%8.4f"
}
local rs ""
local nrows = rowsof(e(r_Ls))-1
forvalues i = 1/`nrows' {
  if (`i'== 1) local rs = "`rs'&"
  else local rs = "`rs'&"
}
if ("`e(title)'" == "Factor analysis") local titleout = "Rotated factor loadings (pattern matrix) and unique variances sorted"
if ("`e(title)'" == "Principal components") local titleout = "Rotated components sorted"
matlist (e(r_Ls), e(Psis)'), title("`titleout'") cspec(o4&%12s|`cs'|%11.4fo1&) rspec(--`rs'-) row("Variable")
end
mata:
void sortloadings()
{
  ld=st_matrix("e(r_L)")
  rNames=st_matrixrowstripe("e(r_L)")
  cNames=st_matrixcolstripe("e(r_L)")
  Psi=st_matrix("e(Psi)")
  rNamesPsi=st_matrixrowstripe("e(Psi)")
  cNamesPsi=st_matrixcolstripe("e(Psi)")
  f=cols(ld)
  vars = rows(ld)
  loadmax = abs(ld):==rowmaxabs(ld)
  ldorig = ld
  ld = ld, (1::vars)
  for (i=1; i<=f; i++) {
    if (i==1) ldsorted = sort(select(abs(ld),loadmax[,i]),-i)
    else ldsorted = ldsorted \ sort(select(abs(ld),loadmax[,i]),-i)
  }
  sortindex = ldsorted[,f+1]
  ldsorted = ldorig[sortindex,]
  rNames = rNames[sortindex,]
  Psi = Psi[,sortindex]
  cNamesPsi = cNamesPsi[sortindex,]
  st_matrix("e(r_Ls)",ldsorted)
  st_matrixcolstripe("e(r_Ls)",cNames)
  st_matrixrowstripe("e(r_Ls)",rNames)
  st_matrix("e(Psis)",Psi)
  st_matrixcolstripe("e(Psis)",cNamesPsi)
  st_matrixrowstripe("e(Psis)",rNamesPsi)
}
end
