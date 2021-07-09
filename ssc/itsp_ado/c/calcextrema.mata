version 10.1
mata:
mata set matastrict on
void calcextrema(string scalar varname, ///
                 string scalar touse)
{
  real colvector x, cmm
  st_view(x, ., varname, touse)
  cmm = colminmax(x)
  st_numscalar("r(min)", cmm[1])
  st_numscalar("r(max)", cmm[2])
}
end
