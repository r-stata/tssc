*!IHSU 1.1.3 16 April 2014
* IHSU 1.1.2 07 January 2013 
* IHSU	1.1.0 17 November 2012
* IHSU 1.0.0. 11 July 2012
* IHSU 1.0.1 17 November 2012 
* NJC 1.1.1 16 December 1998
* NJC 1.1.0 26 October 1996
* Nonparametric density estimation for circular data: Fisher 1993 pp.24-27
* A plug-in rule for bandwidth selection in circular density estimation:
* Oliveira, M. R.M. Crujeiras, and A. Rodríguez-Casal 2012. Computation 
* Statistics and Data Analysis: 3898-3908.
* This version draws a linear or a circular graph
* Updated by IHSU & VMSQ 06 March 2021
program define cirkdevm
version 11.0
	syntax varname(numeric) [if] [in] ///
	[, H(real 30) NPoints(integer 0) NUMOdes MOdes NUAMOdes AMOdes ///
	NOGraph CIRCGph Rval(real 1) Fr(real 1) GS(real 1) GEN(str) PLOT(str asis) * ]

	marksample touse 
	qui count if `touse' 
	if r(N) == 0 error 2000
    local nd=r(N)
    preserve
	if "`gen'" != "" {
	   parse "`gen'", parse(" ")
	   confirm new variable `1'
	   confirm new variable `2'
	}


   tempvar deg d e f g cosdeg sindeg denp cosdenp sindenp
   
    qui {
        
		if `npoints'==0 {
		     if _N < 360 {
			    gen `deg' = (_n -1) / (_N-1) * 360
			    }
				else gen `deg' = _n in 1/360
				}
		else {
		     		if `npoints'< r(N) {
	     di as error "The number of points must be >= " r(N)
		 exit
		 }
			 set obs `npoints'
			 count if `touse'
			 *noi di `npoints'
			 gen `deg' = (_n -1) / (`npoints'-1) * 360
			 
		     }
		
		*local n = min(_N, 360) 
		*gen `deg' = (_n / _N) * 360
        
		local n = `nd'
		gen double `d' = .
        gen double `e' = .
        gen double `f' = .
        local klab = "(von Mises)"
		
		*label var `deg' "Angle in degrees"
        
		 if `"`:variable label `varlist''"' != "" {
                     label var `deg' `"`:variable label `varlist''"'
             }
       else label var `deg' "`varlist'"
		
		label var `f' "Density"

        if "`modes'"~="" & "`numodes'"=="" {
            di in red "you must include the 'numodes' option"
        exit
		}
        if "`amodes'"~="" & "`nuamodes'"=="" {
            di in red "you must include the 'nuamodes' option"
        exit
		}

        local i = 1
		local kappa = `h'
		i0kappa `kappa'
		local i0kappa = r(i0kappa)
		local minvm = (1/(2*_pi*`i0kappa'))*exp(`kappa'*cos(_pi))
        while `i' <= _N {
            replace `d' = abs(`deg'[`i'] - `varlist') if `touse'
            replace `e' = min(`d' , 360 - `d')
			replace `e' = `e'*_pi/180
            replace `e' = exp(`kappa'*cos(`e'))
			*noi li `e'
			*replace `e' = exp(`kappa'*cos(`e')) if `e' >= 0 | `e' < 2*_pi
            su `e', meanonly
			replace `f' = (1/(`n'*2*_pi*`i0kappa'))*r(sum) in `i'
            local i = `i' + 1
        }
   
   
   if "`nograph'"=="" {
	   if "`circgph'"=="" {
	   	if `"`subtitle'"' == "" {
              local subtitle "sub("Circular kernel `klab' density estimate, ///
			  {it:h} = `h'{&degree}", size(medium))"
		}			 
	   twoway scatter `f' `deg', `subtitle' ///
	   xla(0 "0" 90 "90" 180 "180" 270 "270" 360 "360") yla(, ang(h)) c(l) ///
	   `options' /// 
	   || `plot' 
	   }
	   else {
	        gen `cosdeg' = cos(`deg'*_pi/180)
	        gen `sindeg' = sin(`deg'*_pi/180)
			sum `f'
			gen `g' = `f'/r(max)
			gen `denp' = `rval'*(1 + _pi*`g')^.5 - `rval'
			gen `cosdenp' = `cosdeg'*(1 + `denp'*`fr')
			gen `sindenp' = `sindeg'*(1 + `denp'*`fr')
		
		 if `"`subtitle'"' == "" {
                local subtitle "sub("Circular kernel `klab' density estimate, ///
				{it:h} = `h'{&degree}", pos(6) size(medium))"
         }
         *else local subtitle `"sub(`subtitle')"'
      
			local size = 1.1 + `gs'
			scatter `cosdeg' `sindeg', ms(i) c(l) || ///
			scatter `cosdenp' `sindenp',  ms(i) aspect(1) c(l) legend(off) ///
			yline(0) xline(0) ysc(r(-`size' `size') off fill) ///
			xsc(r(-`size' `size') off fill) ylab(, nogrid) ///
			plotregion(margin(zero) style(none)) `subtitle' `options' ///
			|| `plot'
			}
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
      local title " Modes in circular von Mises KDE"
      noi di as txt "`title', nu = `nu', npoints = `n'"
      noi di as txt _dup(75) "-"
      while `i'<`numo'+1 {
         noi di as txt " Mode ( " as res %4.0f `i' as txt " ) = " ///
		 as res %12.4f `modes'[`i']
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
      local title " Antimodes in circular von Mises KDE"
      noi di as txt "`title', nu = `nu', npoints = `n' "
      noi di as txt _dup(75) "-"
      while `i'<`nuamo'+1 {
        noi di as txt " Antimode ( " as res %4.0f `i' as txt " ) = " ///
		as res %12.4f `amodes'[`i']
        local i = `i'+1
        }
   noi di as txt _dup(75) "_"
   sort `deg'
   }
	
    qui if "`gen'" != ""  {
	    restore, not
	    parse "`gen'", parse(" ")
		gen `1' = `f' if `deg' != .  
		label var `1' ///
		"Circular `klab' kernel density estimate, half-width `h'`=char(176)'"
	    gen `2' = `deg' if `deg' != . 
		label var `2' "Degrees `=char(176)'"
	} 	
}
end
