*! version 5.0 por Isaias H. Salgado-Ugarte, Makoto Shimizu
*! and Toru Taniuchi,University of Tokyo, Faculty of
*! Agriculture, Dept. of Fisheries (Fax 81-3-3812-0529)
*! version 11.0 modified by Nestor A. Mosqueda Romo 09-02-2011
*! updated by Salgado-Ugarte, I.H. & V.M. Saito-Quezada, 26/03/2020; 
*! 18/04/2020; 07/08/2020; 08/08/2020
program define warpdenm1
    version 11.0
    local varlist "req ex min(1) max(1)"
    local if "opt"
    local in "opt"
    #delimit ;
    local options "Bwidth(real 0) Mval(int 0) Kercode(int 0) STep NUMOdes MOdes NUAMOdes AMOdes NPoints Gen(string) noGraph T1title(string) MSymbol(string) Connect(string) *";
    #delimit cr
    parse "`*'"
    parse "`varlist'", parse(" ")
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
    local hv=`bwidth'
    local mv=`mval'
    local kc=`kercode'
    if `hv'==0 {
         di in red "you must provide the bandwidth"
         exit
    } /* modified */
    if `mv'==0 {
       di in red "you must provide the number of shifted histograms"
       exit
    } /* modified */
    if `kc'==0 {
       di in red "you must provide the kernel code"
       exit
    } /* modified */
    if `kc'>6 {
       di in red "invalid choice of kernel"
       exit
    } /* modified */
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
     local numbin=floor((maxval-minval)/delta)+2*(mval+1+ceil(mval/10))
     
	 if `numbin'>_N {
      set obs `numbin'
     }
     scalar start=minval-hval-delta*0.1
	 
	 scalar origin=(floor(start/delta)-0.5)*delta
	 
     *if start<0 {
     * scalar origin=(round(((start/delta)-0.5),1)-0.5)*delta
     *}
     *else {
     * scalar origin=(int(start/delta)-0.5)*delta
     *}
     
	 gen `index'=floor((`xvar'-origin)/delta)
     gen `index2'=`index'
	 
     egen `freq'=count(`xvar'), by(`index2')
     *noi l `index2' `freq'
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
       tempvar fh fh1 fh2 lfh nba
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
      
	  egen `nba'= seq(), from(0) to(`numbin')
	  replace `nba'=. if _n>`numbin'
	  gen `midval'=(0.5+`nba')*delta+origin  /* modified */
	  
    if `numbin'<_N {
       replace `fh'=. if _n>`numbin'
       replace `midval'=. if _n>`numbin'
    }
    

	gen `lfh'=`fh'[_n-(`index'[1]-mval)]

	
       replace `lfh'=0 if `lfh'==.
      *replace `midval'=(`midval'[_N-1]-`midval'[_N-2])+`midval'[_N-1] if _n==_N
    if `numbin'<_N {
       replace `lfh'=. if _n>`numbin'
    }

	tempvar inter lowcut
    if "`graph'" != "nograph"  { /* modified */
       local hvlab=string(round(`hv',.0001),"%9.4f")
    if "`t1title'" ==""{
      if "`step'"!="" { /* modified */
         local t1title "WARPing density (step)"
         local t1title "`t1title', bw = `hvlab', M = `mv', Ker = `kc'"
      }
      else {
         local t1title "WARPing density (polygon)"
         local t1title "`t1title', bw = `hvlab', M = `mv', Ker = `kc'"
      }
    }
    if "`msymbol'"=="" { /* modified */
         local msymbol "p" /* modified*/
    } /* modified */ 
   if "`connect'"=="" { /* modified */
      if "`step'"!="" { /* modified */
         local connect "J" /* modified */
      } /* modified */
      else { /* modified */
         local connect "l"
      } /* modified */
   } /* modified */
   if "`step'"!="" { /* modified */
      gen `inter'=`midval'[2]-`midval'[1]
      gen `lowcut'=`midval'-(`inter'/2)
      label variable `lfh' "Density"
      label variable `lowcut' "Lower cutoff"
      scatter `lfh' `lowcut',  `options' /* /* modified */
				*/ t1("`t1title'") /*
				*/ ms(`msymbol') c(`connect') /* modified */
   }
   else {
      label variable `lfh' "Density"
      label variable `midval' "Midpoints"
      scatter `lfh' `midval', `options' /* /* modified */
				*/ t1("`t1title'") /*
				*/ ms(`msymbol') c(`connect') /* modified */
    }
 }
    if "`numodes'"!="" { /* modified */
       tempvar difvar inmo sumo
       gen `difvar'=`lfh'[_n+1] - `lfh'[_n]
       gen `inmo' = 0
       replace `inmo'=1 if `difvar'[_n]>=0 & `difvar'[_n+1] < 0
       gen `sumo' = sum(`inmo')
       local numo= `sumo'[_N]
       noi di as text _newline " Number of modes = " as res `numo'
   }
   if "`modes'"!="" { /* modified */
      tempvar modes
      gen `modes'=.
      replace `modes'=`midval' if `inmo'[_n-1]==1
      sort `modes'
      local i = 1
      noi di as text _newline _dup(75) "_"
      local title " Modes in WARPing density estimation"
      noi di as text "`title'" as text", bw = " as res `hv' as text ", M = " as res `mv' as text ", Ker = " as res `kc'
      noi di as text _dup(75) "-"
   while `i'<`numo'+1 {
      noi di as text " Mode ( " %4.0f as res `i' as text " ) = " %12.4f as res `modes'[`i']
      local i = `i'+1
   }
   noi di as text _dup(75) "_"
   sort `midval'
   }
   
    if "`nuamodes'"~="" {
   tempvar difvar inamo suamo index
   gen `difvar'=`lfh'[_n+1] - `lfh'[_n]
   gen `inamo' = 0
   replace `inamo'=1 if `difvar'[_n]<=0 & `difvar'[_n+1] > 0
   gen `index'=_n if `lfh'!=.           /* modified */
   replace `inamo'=0 if `index'==1      /* modified */
   sum `midval'                         /* modified */
   local np=r(N)                        /* modified */
   replace `inamo'=0 if `index'==`np'-1   /* modified */
   gen `suamo' = sum(`inamo')
   local nuamo= `suamo'[_N]
   noi di as text _newline " Number of antimodes = " as res `nuamo'
   }
   
   if "`amodes'"~="" {
   tempvar amodes
   gen `amodes'=.
   replace `amodes'=`midval' if `inamo'[_n-1]==1 
   sort `amodes'
   local i = 1
   noi di as text _newline _dup(75) "_"
   local title " Antimodes in WARPing density estimation"
   noi di as text "`title'" as text ", bw = " as res `hvlab' as text ", M = " as res `mv' as text ", Ker = " as res `kc'
   noi di as text _dup(75) "-"
   while `i'<`nuamo'+1 {
      noi di as text " Antimode ( " %4.0f as res `i' as text " ) = " %12.4f as res `amodes'[`i']
      local i = `i'+1
      }
   noi di as text _dup(75) "_"
   sort `midval'
   }
   
   
   if "`npoints'"!="" { /* modified */
      summ `midval'
      local np = r(N) /* modified */
      noi di _newline " Number of estimated points = " `np'
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
