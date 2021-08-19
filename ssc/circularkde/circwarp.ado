*! Based on warpdenm.ado
*! version 5.0 by Isaias H. Salgado-Ugarte, Makoto Shimizu
*! and Toru Taniuchi,University of Tokyo, Faculty of
*! Agriculture, Dept. of Fisheries (Fax 81-3-3812-0529)
*! version 11.0 modified by Nestor A. Mosqueda Romo 09-02-2011
*! version 11.1 modified by IHSU for circular data 22-03-2016
*! version 11.2 modified by IHSU 17/09/2017
*! version 11.3 modified by IHSU 29/09/2017
*! version 11.3a modified by IHSU & Verónica Mitsui Saito Quezada 05/03/2021
program define circwarp
    version 11.0
    
	syntax varname(numeric) [if] [in] ///
	[, Hwidth(real 30) Mval(int 10) Kercode(integer 4) NUMOdes MOdes NUAMOdes AMOdes ///
	NPoints NOGraph GType(int 1) Rval(real 1) Fr(real 1) GS(real 1) GEN(str) PLOT(str asis) * ]
	
	quietly {
    preserve
    if "`gen'"!="" { /* modified */
       tempfile _data
       save `_data'
    }
    tempvar xvar
    gen `xvar'=`1' `if' `in'
    drop if `xvar'==.
    if `xvar'[1]==. {
       di in red "no observations"
       exit
    } /* modified */
    keep `xvar'
    local hv=`hwidth'
    local mv=`mval'
    local kc=`kercode'
	
	local gt= `gtype'
	
    if `hv'==0 {
         di in red "invalid bandwidth value"
         exit
    } /* modified */
    if `mv'==0 {
       di in red "you must use at least 1 histogram"
       exit
    } /* modified */
    if `kc'==0 {
       di in red "you must provide a valid kernel code"
       exit
    } /* modified */
    
	if `kc'>6 {
       di in red "invalid choice of kernel"
       exit
    } /* modified */
	if `gtype' > 3 {
	    di in red "invalid choice of graph type; must be 1,2 or 3"
		exit
		}
    if "`modes'"!="" & "`numodes'"=="" {
       di in red "you must include the 'numodes' option"
       exit
    } /* modified */
      tempvar midval index freq
     summ `xvar'
     scalar nuobs= r(N) /* modified */
     scalar maxval= r(max) /* modified */
     scalar minval= r(min) /* modified */
     tempvar index2
     if `kc'==6 {
          scalar hval=`hv'*4
     }
      else {
          scalar hval=`hv'
      }
     scalar mval=`mv'
     scalar delta=hval/mval

	 local numbin=int((maxval-minval)/delta)+2*(mval+1+round((mval/10)+0.5),1)
     if `numbin'>_N {
      set obs `numbin'
     }

	 scalar start=  (minval-hval)-delta*.1 
     if start<0 {
      scalar origin=(round(((start/delta)-0.5),1)-0.5)*delta
	  }
     else {
	 scalar origin=(int(start/delta)-0.5)*delta
	 }
	 
	 gen `index'=int((`xvar' - origin)/delta)
	 
	 tempvar g cosdeg sindeg denp cosdenp sindenp
	 
     gen `index2'=`index'
     egen `freq'=count(`xvar'), by(`index2')
     sort `xvar'
     replace `freq'=. if `index2'[_n-1]==`index2'[_n]
     replace `index'=. if `index2'[_n-1]==`index2'[_n]
     tempfile resu1 resu2
     save `resu1'
     keep `index' `freq'
     drop if `freq'==.
     tempvar freqc indexc
     rename `index' `indexc'
     rename `freq' `freqc'
     save `resu2'
     use `resu1', clear
     merge using `resu2'
     drop `index' `freq' _merge `index2'
     rename `indexc' `index'
     rename `freqc' `freq'
     tempvar cm wm wm2 count
     if `kc'==1 {
       gen `cm'=mval/((2*mval-1)*(nuobs*hval))
       gen `wm'=`cm'
     }
    else if `kc'==2 {
       gen `cm'=1/(nuobs*hval)
       gen `wm'=`cm'*(1-(_n-1)/mval)
    }
    else if `kc'==3 {
       gen `cm'=3*mval^2/((4*mval^2-1)*(nuobs*hval))
       gen `wm'=`cm'*(1-((_n-1)/mval)^2)
    }
    else if `kc'==4 {
       gen `cm'=0.9375/((1-0.0625/mval^4)*(nuobs*hval))
       gen `wm'=`cm'*(1-((_n-1)/mval)^2)^2
    }
    else if `kc'==5 {
       tempvar part1 part2
       gen `part1'= 1+0.14583333/mval^4
       gen `part2'= 0.05208333/mval^6
       gen `cm'=1.09375/((`part1'-`part2')*(nuobs*hval))
       gen `wm'=`cm'*(1-((_n-1)/mval)^2)^3
    }
    else {
       gen `cm'=0.3989*4/(nuobs*hval)
       gen `wm'=`cm'*exp(-8*((_n-1)/mval)^2)
    }
       replace `wm'=0 if _n>mval
       gen `wm2'=`wm'[_n-(mval-1)]
       replace `wm2'=`wm'[(mval+1)-_n] if _n<mval
       tempvar fh fh1 fh2 lfh
       summ `freq'

	   scalar binum= r(N) /* modified */
       gen `fh'=0
       gen `fh1'=0
       gen `fh2'=0
       gen `count'=1
    while `count' <= binum {
       replace `fh1'=`wm2'*`freq'[`count'] if _n<mval*2
       replace `fh2'=`fh1'[_n-(`index'[`count']-mval)]
       replace `fh2'=0 if `fh2'==.
       replace `fh'=`fh'+`fh2'
       replace `fh2'=0
       replace `fh1'=0
       replace `count'=`count'+1
    }
       local nmval= 360/delta

	   if `nmval' > _N {
	        local nmval = int(`nmval')+ 1
	        set obs `nmval'
	   	}

	   gen `midval'=((0.5+(_n-1))*delta)+origin /* in 1/`numbin' */


    if `numbin'<_N {
       replace `fh'=0 if _n>`numbin'

    }

	   gen `lfh'=`fh'[_n-(`index'[1]-mval)]
       replace `lfh'=0 if `lfh'==.
	   
       replace `midval'=(`midval'[_N-1]-`midval'[_N-2])+`midval'[_N-1] if _n==_N

	if `numbin'<_N {
       replace `lfh'=. if _n>`numbin'
    }

	  label variable `lfh' "Density"
      label variable `midval' "Midpoints"
	  
	  tempvar ene
	  if _N > `nmval' {
	       drop if `lfh'==.
		   }
 
	  replace `midval' = `midval'[_n] + 360 - mod(360,delta) if `midval' < 0 
	  replace `midval' = `midval' - 360 + mod(360,delta) if `midval' > 360 

	  sort `midval' 
	  replace `midval' = round(`midval',.1)
	  replace `lfh' = 0 if `lfh'==.
			  
	  replace `lfh' = `lfh'[_n+1]+`lfh'[_n] if `midval'[_n+1] == `midval'[_n]
	  
	  replace `lfh' = `lfh'[_n]+`lfh'[`numbin'] if (_n==1 & `lfh'!=0)
	  
	  replace `lfh' = `lfh'[1] if `midval'==360
	  
	  drop if `midval'>360

	  replace `lfh' = . if `midval'[_n] == `midval'[_n-1]

	  drop if `lfh'==. & `midval'[_n] == `midval'[_n-1]

	  replace `lfh'=0 if `lfh' ==.
	
	local ene=_N+1
	set obs `ene'

	replace `midval' = 360 in `ene'
	replace `lfh'= `lfh'[1] in `ene'
	tempvar inter lowcut
	   
    if "`graph'" == "`nograph'"  { /* modified */
       local hvlab=string(round(`hv',.01),"%9.2f")
	   
	     if `gtype'== 1 {
	
	     local t1title "Circular WARP density (polygon)"
         local t1title "`t1title', {it:h} = `hvlab', {it:M} = `mv', {it:k} = `kc'"
		 local connect "l"

		      scatter `lfh' `midval', sort `options' ///
			  xla(0 "0" 90 "90" 180 "180" 270 "270" 360 "360")  /* /* modified */
		 	   
		        */ t1("`t1title'") /*
				*/ ms(`msymbol') c(`connect') /* modified */
         
		 }
	
	     else if `gtype' == 2  { /* modified */
      
	       local t1title "Circular WARP density (step)"
           local t1title "`t1title', {it:h} = `hvlab', {it:M} = `mv', {it:k} = `kc'"
	       local connect "J"
		   local msymbol "i"
	       gen `inter'=`midval'[2]-`midval'[1]
           gen `lowcut'=`midval'-(`inter'/2)
           label variable `lfh' "Density"
           label variable `lowcut' "Lower cutoff"
      
	       scatter `lfh' `lowcut',  `options' /// 
		   xla(0 "0" 90 "90" 180 "180" 270 "270" 360 "360") /* /* modified */
			     	 */ t1("`t1title'") /*
				     */ ms(`msymbol') c(`connect') /* modified */
         }
	
	     else if `gtype' == 3 {
		 
		    gen `cosdeg' = cos(`midval'*_pi/180)
	        gen `sindeg' = sin(`midval'*_pi/180)
			sum `lfh'
			gen `g' = `lfh'/r(max)
			gen `denp' = `rval'*(1 + _pi*`g')^.5 - `rval'
			gen `cosdenp' = `cosdeg'*(1 + `denp'*`fr')
			gen `sindenp' = `sindeg'*(1 + `denp'*`fr')
			
		    if `"`subtitle'"' == "" {
                     local subtitle "sub("Circular WARP density, ///
					 {it:h} = `hvlab'{&degree}, {it:M} = `mv', /// 
					 {it:k} = `kc'", pos(6) size(medium))"
            }
         else local subtitle `"sub(`subtitle')"'
      
			local size = 1.1 + `gs'
			scatter `cosdeg' `sindeg', ms(i) c(l) || ///
			scatter `cosdenp' `sindenp',  ms(i) aspect(1) c(l) legend(off) /// 
			yline(0) xline(0) ysc(r(-`size' `size') off fill) /// 
			xsc(r(-`size' `size') off fill) ylab(, nogrid) /// 
			plotregion(margin(zero) style(none)) `subtitle' `options' ///
			|| `plot'
			}
	
    }
 
   if "`numodes'"!="" { /* modified */
       tempvar difvar inmo sumo
       gen `difvar'=`lfh'[_n+1] - `lfh'[_n]
       gen `inmo' = 0
       replace `inmo'=1 if `difvar'[_n]>=0 & `difvar'[_n+1] < 0
       gen `sumo' = sum(`inmo')
       local numo= `sumo'[_N]
       noi di _newline " Number of modes = " `numo'
   }
   if "`modes'"!="" { /* modified */
      tempvar modes
      gen `modes'=.
      replace `modes'=`midval' if `inmo'[_n-1]==1
      sort `modes'
      local i = 1
      noi di as txt _newline _dup(75) "_"
      local title " Modes in Circular WARP density estimation"
      noi di as txt "`title', h = " as res `hv' as txt ", M = " as res `mv' as txt ", Ker = " as res `kc'
      noi di as txt _dup(75) "-"
   while `i'<`numo'+1 {
      noi di as txt " Mode ( " as res %4.0f `i' as txt " ) = " as res %12.4f `modes'[`i']
      local i = `i'+1
   }
   noi di as txt _dup(75) "_"
   sort `midval'
   }
   
   if "`nuamodes'"!="" {
      tempvar difvar inamo suamo
      gen `difvar'=`lfh'[_n+1] - `lfh'[_n] /* if `deg' != . */
      gen `inamo' = 0 /* if `deg' != . */
      replace `inamo'=1 if `difvar'[_n]<=0 & `difvar'[_n+1] > 0
      gen `suamo' = sum(`inamo')
      local nuamo= `suamo'[_N]
      noi di as txt _newline " Number of antimodes = " as res `nuamo'
   }
   if "`amodes'"!="" {
      tempvar amodes
      gen `amodes'=.
      replace `amodes'=`midval' if `inamo'[_n-1]==1
      sort `amodes'
      local i = 1
      noi di as txt _newline _dup(75) "_"
      local title " Antimodes in circular `klab' KDE"
      count if `midval' !=. 
	  noi di as txt "`title', h = " as res `hv'  as txt ", M = " as res `mv' as txt ", Ker = " as res `kc' 

      noi di as txt _dup(75) "-"
      while `i'<`nuamo'+1 {
        noi di as txt " Antimode ( " as res %4.0f `i' as txt " ) = " as res %12.4f `amodes'[`i']
        local i = `i'+1
        }
   noi di as txt _dup(75) "_"

   }
   
   if "`npoints'"!="" { /* modified */
      summ `midval'
      local np = r(N) /* modified */
      noi di _newline as txt " Number of estimated points = " as res `np'
      }
   if "`gen'"!="" { /* modified */
      restore, not
      merge using `_data'
      drop _merge
      parse "`gen'", parse(" ")
      gen `1'=`lfh'
      gen `2'=`midval'
      }
   }
end
