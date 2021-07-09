program cdfquantreg, eclass  
version 13.0
   gettoken y 0 : 0
   unab y : `y'
   ** check that y is a variable
   confirm numeric variable `y'
   syntax [varlist(default=none ts fv)] [if] [in] , cdf(string) quantile(string) ///
   [Zvarlist(varlist ts fv)] [nolog] [Robust]
   marksample touse
   
   ** allowable cdf/quantile distributions, including strange name-shifts
   if !inlist(`"`cdf'"', "asinh", "burr7", "burr8", "cauchit", "logit", "t2") {
      display as error `"Bad cdf distribution: `cdf'"'
      exit 198
      }
   if !inlist(`"`quantile'"', "asinh", "burr7", "burr8", "cauchy", "logistic", "t2") {
      display as error `"Bad quantile distribution: `quantile'"'
      exit 198
      }
   local dist `"`cdf'`quantile'"'
   ** burr7burr8 is no good
   if `"`dist'"'=="burr7burr8" {
      display as error "There is no burr7burr8 distribution"
      exit 198
      }
   ml model lf `dist' (`y' = `varlist') (`zvarlist') if `touse', vce(`robust')
   quietly ml search
   ml max, `log' 
   
      ** Specify what marginals should and should not do
   ereturn local marginsok xb stdp predict qtile default
   ereturn local marginsnotok Residuals 
   ereturn local  predict "cdfquantreg_p"
end

/*
These distributions are from the CDF-quantile family presented in 
Smithson, M. & Shou, Y. (2017). CDF-quantile distributions for modeling 
random variables on the unit interval. 
British Journal of Mathematical and Statistical Psychology, 70(3), 412-438. 
*/
