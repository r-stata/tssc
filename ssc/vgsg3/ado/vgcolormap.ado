*! Version 1.01 7/26/04, added msymbol
program vgcolormap
	syntax [, Quietly ]
	preserve
	set more off
	qui drop _all
	local lista black gs0 gs1 gs2 gs3 gs4 gs5 gs6 gs7 gs8 gs9 gs10 gs11 gs12 gs13 gs14 gs15 gs16 white blue bluishgray brown cranberry cyan dimgray dkgreen dknavy dkorange eggshell emerald forest_green gold gray green khaki lavender lime ltblue ltbluishgray ltkhaki magenta maroon midblue midgreen mint navy olive olive_teal orange orange_red pink purple red sand sandb sienna stone teal yellow ebg ebblue edkblue eltblue eltgreen emidblue erose
	local xmax = 6
	local targname mcolor
	local title "Color Map of Standard Stata Colors"
	local cmd
	qui set obs 0
	qui gen x = .
	qui gen y = .
	qui gen str10 s = ""
	local x = 0
	local y = 1
	foreach ela of local lista {
		local `targname' `ela'
		local x = `x'+1
		if `x' > `xmax' {
			local y = `y' + 1
			local x = 1
		}
		local obs = `=_N'+1 
		qui set obs `obs' 
		qui replace y = `y' in l
		qui replace x = `x' in l
		qui replace s = "`ela'" in l
		local c "sc y x in `=_N', pstyle(p1) mcolor(`mcolor') mlabel(s) mlabpos(3) msize(huge) msymbol(S)" // 7/26/04, added msymbol(S)
		local cmd "`cmd' (`c')"
	}
	* di "`cmd'"
	local topx = `xmax' + .6
	local topy = `y' + 1
	`quietly' di as text "Rendering colors, please wait" 
	capture twoway `cmd', ysca(r(0 `topy')) xsca(r(.8 `topx'))	///
		xlab(none) ylab(none) ysca(reverse)			///
		xtitle("") ytitle("") title("`title'")			///
		legend(nodraw) 
end
