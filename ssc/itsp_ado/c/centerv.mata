version 10.1
mata:
mata set matastrict on
// centerv 1.0.0  CFBaum 11aug2008
void centerv( string scalar varlist, ///
              string scalar newvarlist,
              string scalar touse)
{
  real matrix X, Z
  st_view(X=., ., tokens(varlist), touse)
  st_view(Z=., ., tokens(newvarlist), touse)
  Z[., .] = X :- mean(X)
}
end
