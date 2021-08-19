*! IHSU 1.1.0 04 July 2012. Based on the program by:
* NJC 1.1.1 16 December 1998
* NJC 1.1.0 26 October 1996
* nonparametric density estimation for circular data: Fisher 1993 pp.24-27
* Modified 12 May 2011 by Isaias Hazarmabeth Salgado-Ugarte
* Revised 04 July 2012 by Isaias Hazarmabeth Salgado-Ugarte
* This program calculates kernel density estimator of a series of 
* values according to the weight functions coded as follows:
*  1 = Uniform
*  2 = Triangle 
*  3 = Epanechnikov
*  4 = Quartic (Biweight)
*  5 = Triweight
*  6 = Gaussian
*  7 = Cosinus
program define circkde
    version 5.0
    local varlist "max(1)"
    local if "opt"
    local in "opt"
    local options "H(real 30) Kc(integer 6) NUMOdes MOdes NUAMOdes AMOdes noGraph * GENPDF(str) GENDEG(str)"
    parse "`*'"
    tempvar touse deg d e f
    qui {
        mark `touse' `if' `in'
        markout `touse' `varlist'
        count if `touse'
        local n = _result(1)

        gen `deg' = (_n / _N) * 360
        gen `d' = .
        gen `e' = .
        gen `f' = .
        label var `deg' "Angle in degrees"
        label var `f' "Density"
        if "`modes'"~="" & "`numodes'"=="" {
            di in red "you must include the 'numodes' option"
        exit}
        if "`amodes'"~="" & "`nuamodes'"=="" {
            di in red "you must include the 'nuamodes' option"
        exit}
        local i = 1
        while `i' <= _N {
            replace `d' = abs(`deg'[`i'] - `varlist') if `touse'
            replace `e' = min(`d' , 360 - `d')

			if `kc'==1 {
             replace `e'= cond(`e' >= `h', 0, 0.5)
         }
         else if `kc'==2 {
             replace `e'= cond(`e' >= `h', 0, (1-abs(`e'/`h')))
         }
         else if `kc'==3 {
             replace `e'= cond(`e' >=`h', 0, ((3/4)*(1-`e'^2/`h'^2)))
         }
         else if `kc'==4 {
             replace `e'= cond(`e' >=`h',0, (15/16)*((1-`e'^2/`h'^2))^2)
         }
         else if `kc'==5 {
             replace `e'=cond(`e' >=`h',0,((35/32)*(1-`e'^2/`h'^2)^3))
         }
         else if `kc'==6 {
             replace `e'=(1/(sqrt(2*_pi)))*exp(-0.5*`e'^2/`h'^2)
         }
         else {
             replace `e'=cond(`e' >=`h',0,(_pi/4)*cos((_pi/2)*`e'/`h'))
         }
		    *replace `e' = cond(`e' >= `h', 0, (1 - `e'^2 / `h'^2)^2)
            su `e', meanonly
            replace `f' = _result(18) / (`n' * `h') in `i'
            local i = `i' + 1
        }
    if "`graph'" ~= "nograph"  {
       if "`t1title'" ==""{
             local t1title "Circular Kernel Density Estimation"
             local t1title "`t1title', bw = `h', k = `kc'"
             }
	   graph `f' `deg', `options' t1("`t1title'")
	}
    if "`genpdf'" != "" {
        confirm new variable `genpdf'
        gen `genpdf' = `f'
    }
   if "`numodes'"~="" {
   tempvar difvar inmo sumo
   gen `difvar'=`f'[_n+1] - `f'[_n]
   gen `inmo' = 0
   replace `inmo'=1 if `difvar'[_n]>=0 & `difvar'[_n+1] < 0
   gen `sumo' = sum(`inmo')
   local numo= `sumo'[_N]
   noi di as txt _newline " Number of modes = " as res `numo'
   }
   if "`modes'"~="" {
   tempvar modes
   gen `modes'=.
   replace `modes'=`deg' if `inmo'[_n-1]==1 
   sort `modes'
   local i = 1
   noi di as txt _newline _dup(75) "_"
   local title " Modes in circular KDE"
   noi di as txt "`title', bw = `h', Ker = `kc', npoints = `n'"
   noi di as txt _dup(75) "-"
   while `i'<`numo'+1 {
      noi di as txt " Mode ( " as res %4.0f `i' as txt " ) = " as res %12.4f `modes'[`i']
      local i = `i'+1
      }
   noi di as txt _dup(75) "_"
   sort `deg'
   }
   if "`nuamodes'"~="" {
   tempvar difvar inamo suamo
   gen `difvar'=`f'[_n+1] - `f'[_n]
   gen `inamo' = 0
   replace `inamo'=1 if `difvar'[_n]<=0 & `difvar'[_n+1] > 0
   gen `suamo' = sum(`inamo')
   local nuamo= `suamo'[_N]
   noi di as txt _newline " Number of antimodes = " as res `nuamo'
   }
   if "`amodes'"~="" {
   tempvar amodes
   gen `amodes'=.
   replace `amodes'=`deg' if `inamo'[_n-1]==1
   sort `amodes'
   local i = 1
   noi di as txt _newline _dup(75) "_"
   local title " Antimodes in circular density estimation"
   noi di as txt "`title', bw = `hv', M = `mv', Ker = `kc'"
   noi di as txt _dup(75) "-"
   while `i'<`nuamo'+1 {
     noi di as txt " Antimode ( " as res %4.0f `i' as txt " ) = " as res %12.4f `amodes'[`i']
     local i = `i'+1
     }
noi di as txt _dup(75) "_"
sort `deg'
}
   }
	if "`gendeg'" != "" {
        confirm new variable `gendeg'
        gen `gendeg' = `deg'
    }
end
