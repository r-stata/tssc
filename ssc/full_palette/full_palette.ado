*! full_palette v1.1 - NJGW
*! program to display color palettes

program full_palette
	version 8

	if `"`0'"'=="" {
		local colors blue bluishgray brown cranberry cyan dimgray dkgreen dknavy dkorange eggshell emerald ///
			forest_green gold gray green khaki lavender lime ltblue ltbluishgray ltkhaki magenta ///
			maroon midblue midgreen mint navy olive olive_teal orange orange_red pink ///
			purple red sand sandb sienna stone teal yellow ///
			ebg ebblue edkblue eltblue eltgreen emidblue erose black gs0 gs1 gs2 gs3 gs4 gs5 gs6 gs7 ///
			gs8 gs9 gs10 gs11 gs12 gs13 gs14 gs15 gs16 white
	}
	else {
		local colors `0'
	}

	local ncol : word count `colors'
	qui set obs `ncol'
	qui gen str color=""
	local i 1
	while `i'<=`ncol' {
		qui replace color = "`:word `i' of `colors''" in `i'
		local ++i
	}

	qui {
		gen str s=color
		gen str lab=""
		gen y=mod(_n-1,10)
		gen x=int((_n-1)/10)
		gen y2=y-.3
	}

	forval i=1/`=_N' {
		local color = color[`i']
		local basecolor=s[`i']
		capture findfile color-`basecolor'.style
		if _rc {
			di as err "{p 0 4 4}"
			di as err "color `basecolor' not found{break}"
			di as err "Type -graph query colorstyle-"
			di as err "for a list of colornames."
			di as err "{p_end}"
			exit 111
		}
		local fn `"`r(fn)'"'

		tempname hdl
		file open `hdl' using `"`fn'"', read text
		file read `hdl' line
		while r(eof)==0 {
			tokenize `"`line'"'
			if "`1'"=="set" & "`2'"=="rgb" {
				qui replace lab=`""`3'`basemod'""' in `i'
				file close `hdl'
				continue, break
			}
			file read `hdl' line
		}

		local cmd`i' ///
			sc y2 y x in `i', ///
			ms(S none) mcolor(`color') msize(6 6) mlcolor(black) ///
			mlabel(s lab) mlabcolor(black black) mlabgap(1 1) mlabsize(small vsmall)

		local cmdstring "`cmdstring' (`cmd`i'')"
	}

	quietly twoway `cmdstring', ///
			yscale(r(-1 10) reverse) xscale(r(-.1 6.8)) ylab(none) xlab(none) ytitle("") xtitle("") ///
			legend(nodraw) graphregion(margin(zero) fcolor(white) lcolor(white)) plotregion(lcolor(white))


end
