
*! varextrema v1.0.0  CFBaum 11aug2008
program varextrema, rclass
   version 10.1
   syntax varname(numeric) [if] [in]
   marksample touse
   mata: calcextrema( "`varlist'", "`touse'" )
   display as txt " min ( `varlist' ) = " as res r(min)
   display as txt " max ( `varlist' ) = " as res r(max)   
   return scalar min = r(min)
   return scalar max = r(max)
end
