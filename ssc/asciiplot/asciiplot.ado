*! asciiplot version 2.0.0 09jun2015
*! asciiplot version 1.0.1 26 January 2007 
*! asciiplot version 1.0.0 26 January 2007 
*! Michael Blasnik, Svend Juul, Nick Cox           
program asciiplot 
	version 10.0 
	preserve 
	drop _all

	quietly set obs 223
	gen asciin = _n + 32
	gen x = int(asciin/10)
	gen y = mod(asciin,10)

	if c(stata_version) < 14 {
		gen ascii = char(asciin)
		local CH = "char"
	}
	else {
		gen ascii = uchar(asciin)
		local CH = "uchar"
		local ENC = "Unicode (Latin 1) encoding"
	}
	
	twoway scatter x y ,                     ///
	msymbol(i)                               ///
	mlab(ascii)                              ///
	mlabpos(0)                               ///
	mlabsize(*1.4)                           ///
	xaxis(1 2)                               ///
	xlabel(0(1)9 , nogrid notick axis(1))    ///
	xlabel(0(1)9 , nogrid notick axis(2))    ///
	xmticks(-0.5(1)9.5 , grid axis(1))       ///
	xtitle("Last digit of code" , axis(1))   ///
	xtitle("" , axis(2))                     ///
	xline(4.5) yline(5.5 10.5 15.5 20.5)     ///
	ylabel(3(1)25 , nogrid notick angle(h))  ///
	ymticks(2.5(1)25.5 , grid)               ///
	yscale(reverse)                          ///
	ytitle("First digit(s) of code")         ///
	ysize(6.5) xsize(4)                      ///
	title("ASCII character map")             ///
	subtitle("`ENC'")                        ///
	note("Use `CH'(#) function or {c #} tag to include symbols in graph text." ///
	   "In Windows: Alt + numeric keyboard. Example: Alt+0254.") ///
	plotregion(margin(zero))                 ///
	`options' 

end
