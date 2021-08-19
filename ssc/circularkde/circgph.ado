*!IHSU 1.0.3 03 January 2013 
* Program to draw a circular kernel density estimation based on Fisher 1989, 
* Fisher 1993, pp.24-27 and the programs from N. Cox (circnpde, 1998 and
* circkdensity, 2004).
* It uses two variables, one with the angular points and another with the 
* densities, make the corresponding calculations and draws the graph
program circgph 
	version 11.0
	syntax varlist(min=2 max=2) [if] [in] ///
	[ , Rval(real 1) Fr(real 1) GS(real 1) plot(str asis) * ]
	
	*syntax varname(numeric) [if] [in] ///
	*[, H(real 30) Kc(integer 4) NPoints(integer 0) NUMOdes MOdes NUAMOdes AMOdes ///
	*NOGraph CIRCGph Rval(real 1) Fr(real 1) GS(real 1) GEN(str) PLOT(str asis) * ]
	
	marksample touse 
	qui count if `touse' 
	if r(N) == 0 error 2000
	
	tempvar cosdeg sindeg f g denp cosdenp sindenp
	
	qui {
	tokenize `varlist' 
    args y x
	gen `cosdeg' = cos(`x'*_pi/180)
	gen `sindeg' = sin(`x'*_pi/180)
	sum `y'
	gen `g' = `y'/r(max)
	gen `denp' = `rval'*(1 + _pi*`g')^.5 - `rval'
	gen `cosdenp' = `cosdeg'*(1 + `denp'*`fr')
	gen `sindenp' = `sindeg'*(1 + `denp'*`fr')
			
	*label var `cosdenp' ///
	*	"Circular kernel `klab' density estimate, h = `h'`=char(176)'"
		
	*	 if `"`subtitle'"' == "" {
    *                local subtitle "sub("Circular kernel `klab' density estimate, h = `h'`=char(176)'", pos(6) size(medium))"
    *   }
    *  else local subtitle `"sub(`subtitle')"'
      
	local size = 1.1 + `gs'
	scatter `cosdeg' `sindeg', ms(i) c(l) || ///
	scatter `cosdenp' `sindenp',  ms(i) aspect(1) c(l) legend(off) yline(0) ///
	xline(0) ysc(r(-`size' `size') off fill) xsc(r(-`size' `size') off fill) ylab(, nogrid) plotregion(margin(zero) style(none)) ///
	`options' ///
	|| `plot'
   }
   end
