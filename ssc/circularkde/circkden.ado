*!IHSU 1.0.3 03 January 2013 
* IHSU 1.0.2 26 December 2012 
* IHSU 1.0.1 17 November 2012
* NJC 2.0.1 2 April 2004 
* NJC 2.0.0 21 January 2004 
* NJC 1.1.1 16 December 1998
* NJC 1.1.0 26 October 1996
* nonparametric density estimation for circular data: Fisher 1993 pp.24-27
* Modified initially 17 November 2012 by Isaias Hazarmabeth Salgado-Ugarte
* This program calculates kernel density estimator of a series of values
* on a circular scale according to the weight functions coded as follows:
*  1 = Uniform
*  2 = Triangle 
*  3 = Epanechnikov
*  4 = Quartic (Biweight)
*  5 = Triweight
*  6 = Gaussian
*  7 = Cosinus
* This version counts and estimates modes and antimodes
* and draws a linear or a circular graph
* Updated by IHSU & VMSQ 07 March 2021 
program circkden 
	version 11.0
	syntax varname(numeric) [if] [in] ///
	[, H(real 30) Kc(integer 4) NPoints(integer 0) NUMOdes MOdes NUAMOdes AMOdes ///
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
				*noi li `deg'
				
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
	   *noi li `deg'
       if `"`:variable label `varlist''"' != "" {
                     label var `deg' `"`:variable label `varlist''"'
             }
       else label var `deg' "`varlist'"
		
		
		*local n = min(_N, 360) 
		local n = `nd'
		gen `d' = .
		gen `e' = .
		gen `f' = .
  	    
		if `kc' == 1 {
				local klab = "(Uniform)"
		}
		else if `kc' == 2 {
		        local klab = "(Triangular)"
		}
		else if `kc' == 3 {
		        local klab = "(Epanechnikov)"
		}
		else if `kc' == 4 {
		        local klab = "(Biweight)"
		}
		else if `kc' == 5 {
		        local klab = "(Triweight)"
		}
		else if `kc' == 6 {
		        local klab = "(Gaussian)"
		}
		else if `kc' == 7 {
		        local klab = "(Cosine)"
		}

		local hlab=string(round(`h',.0001),"%8.2f")
		label var `f' ///
		"Density"

		if "`modes'"~="" & "`numodes'"=="" {
            di in red "you must include the 'numodes' option"
        exit
		}
        if "`amodes'"~="" & "`nuamodes'"=="" {
            di in red "you must include the 'nuamodes' option"
        exit
		}
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
            else if `kc'==7{
              replace `e'=cond(`e' >=`h',0,(_pi/4)*cos((_pi/2)*`e'/`h'))
              }
			else {
			  di as error "The kernel code must be an integer from 1 to 7"
			  exit
			  }
			su `e', meanonly
			replace `f' = r(sum) / (`n' * `h') in `i'
	    	local i = `i' + 1
			replace `f' = . if `deg' == .
		}
	
	
	
	if "`nograph'"=="" {
	   if "`circgph'"=="" {
	   
	   		 if `"`subtitle'"' == "" {
                 local subtitle "sub("Circular kernel `klab' density estimate, ///
				 {it:h} = `h'{&degree}", size(medium))"
             }
	   twoway scatter `f' `deg', ///
	   xla(0 "0" 90 "90" 180 "180" 270 "270" 360 "360") yla(, ang(h)) c(l) ///
	   `subtitle' `options' /// 
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
         else local subtitle `"sub(`subtitle')"'
      
			local size = 1.1 + `gs'
			scatter `cosdeg' `sindeg', ms(i) c(l) || ///
			scatter `cosdenp' `sindenp',  ms(i) aspect(1) c(l) legend(off) yline(0) ///
			xline(0) ysc(r(-`size' `size') off fill) xsc(r(-`size' `size') off fill) ylab(, nogrid) plotregion(margin(zero) style(none)) ///
			`subtitle' `options' ///
			|| `plot'
			}
  }
  if "`numodes'"~="" {
      tempvar difvar inmo sumo
      gen `difvar'=`f'[_n+1] - `f'[_n] if `deg' != .
      gen `inmo' = 0 if `deg' != .
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
      count if `deg' !=. 
	  noi di as txt "`title', bw = " as res `h'  as txt ", Ker = " as res `kc' as txt ", deg points = " as res r(N) 
	  *noi di as txt "`title', bw = `h', Ker = `kc', npoints = `n'"
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
      gen `difvar'=`f'[_n+1] - `f'[_n] if `deg' != .
      gen `inamo' = 0 if `deg' != .
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
      local title " Antimodes in circular KDE"
      count if `deg' !=. 
	  noi di as txt "`title', bw = " as res `h'  as txt ", Ker = " as res `kc' as txt ", deg points = " as res r(N)
	  *noi di as txt "`title', bw = `hv', M = `mv', Ker = `kc'"
      noi di as txt _dup(75) "-"
      while `i'<`nuamo'+1 {
        noi di as txt " Antimode ( " as res %4.0f `i' as txt " ) = " as res %12.4f `amodes'[`i']
        local i = `i'+1
        }
   noi di as txt _dup(75) "_"
   sort `deg'
   }
   }	
	
	qui if "`gen'" != ""  {
	    restore, not
	    parse "`gen'", parse(" ")
		gen `1' = `f' if `deg' != .  
		label var `1' ///
		"Circular `klab' kernel density estimate, half-width `hlab'`=char(176)'"
	    gen `2' = `deg' if `deg' != . 
		label var `2' "Degrees `=char(176)'"
	} 	

end
