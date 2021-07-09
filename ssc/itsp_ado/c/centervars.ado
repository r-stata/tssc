
*! centervars 1.0.0  CFBaum 11aug2008
program centervars, rclass
   version 10.1
   syntax varlist(numeric) [if] [in], GENerate(string) [DOUBLE]
   marksample touse
   quietly count if `touse'
   if `r(N)' == 0  error 2000
   foreach v of local varlist {
       confirm new var `generate'`v'
   }
   foreach v of local varlist {
       qui generate `double' `generate'`v' = .
       local newvars "`newvars' `generate'`v'"
   }
   mata: centerv( "`varlist'", "`newvars'", "`touse'" )
end
