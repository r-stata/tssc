*! xtmod v0.9 - DS - 20 Feb 2009 - analyze and display interactions based on time-series data

program define xtmod, nclass

	version 9

	syntax varlist(min=3 max=4) [if] [in] [, Controlvariables(varlist) Regopts(string asis) ARROWOFFset(real 0.2) ARROWXLENgth(real 0.1) ARROWYLENgth(real 0.5) PRECision(real 0.0001) GLS NOCONStant MAX Tests]

	/* Optional: insert "permanent" parameters for plotting graphs such as schemes */

	local graphopts = "scheme(dsModeration)"

	set more off

	marksample touse

	tokenize `varlist'

	if "`4'" == "" {
		local interaction = "2way"
		local y `1'
		local x `2'
		local z `3'
	}
	else {
		local interaction = "3way"
		local y `1'
		local x `2'
		local w `3'
		local z `4'
	
		capture confirm variable `x'`w'
		if _rc != 0 {
			generate `x'`w'  = `x' * `w'
		}

		capture confirm variable `w'`z'
		if _rc != 0 {
			generate `w'`z'  = `z' * `w'
		}

		capture confirm variable `x'`w'`z'
		if _rc != 0 {
			generate `x'`w'`z'  = `x' * `w' * `z'
		}
	}

	capture confirm variable `x'`z'
	if _rc != 0 {
		generate `x'`z'  = `x' * `z'
	}
	
	if "`tests'" == "tests" {
		local pre = ""
	}
	else {
		local pre = "quietly"
	}

	if "`noconstant'" == "noconstant" {
		local const = "0"
	}
	else {
		local const = "_cons"
	}

	if "`gls'" == "gls" {
		local regresscommand = "xtgls"
	}
	else {
		local regresscommand = "xtreg"
	}

	if "`interaction'" == "2way" {
		`regresscommand' `y' `x' `z' `x'`z' `controlvariables' if `touse', `regopts' `noconstant'
	}
	else {
		`regresscommand' `y' `x' `w' `z' `x'`w' `x'`z' `w'`z' `x'`w'`z' `controlvariables' if `touse', `regopts' `noconstant'
	}

	qui sum `x' if `touse' 
	global lo=r(min)
	global hi=r(max)
	global Ax = r(mean)

	qui sum `z' if `touse' 
	if "`max'" == "max" {
		global Lz=r(min)
		global Hz=r(max)
		local legend1 = "Min"
		local legend2 = "Max"
	} 
	else {
		global Lz=r(mean) - r(sd)
		global Hz=r(mean) + r(sd)
		local legend1 = "Low"
		local legend2 = "High"
	}

	if "`interaction'" == "2way" {
		global slope1 "`x' + $Lz * `x'`z'" 
		global slope2 "`x' + $Hz * `x'`z'" 

		global intercept1 "`const' + $Ax * `x' + $Lz * `z' + $Lz * $Ax * `x'`z'"
		global intercept2 "`const' + $Ax * `x' + $Hz * `z' + $Hz * $Ax * `x'`z'"
	}
	else {
		qui sum `w' if `touse' 
		if "`max'" == "max" {
			global Lw=r(min)
			global Hw=r(max)
		} 
		else {
			global Lw=r(mean) - r(sd)
			global Hw=r(mean) + r(sd)
		}
		global slope1 "`x' + $Lz * `x'`z' + $Lw * `x'`w' + $Lz * $Lw * `x'`w'`z'"
		global slope2 "`x' + $Lz * `x'`z' + $Hw * `x'`w' + $Lz * $Hw * `x'`w'`z'"
		global slope3 "`x' + $Hz * `x'`z' + $Lw * `x'`w' + $Hz * $Lw * `x'`w'`z'"
		global slope4 "`x' + $Hz * `x'`z' + $Hw * `x'`w' + $Hz * $Hw * `x'`w'`z'"

		global intercept1 "`const' + $Lz * `z' + $Lw * `w' + $Lz * $Lw * `w'`z'"
		global intercept2 "`const' + $Lz * `z' + $Hw * `w' + $Lz * $Hw * `w'`z'"
		global intercept3 "`const' + $Hz * `z' + $Lw * `w' + $Hz * $Lw * `w'`z'"
		global intercept4 "`const' + $Hz * `z' + $Hw * `w' + $Hz * $Hw * `w'`z'"
	} 


	/* simple slopes */

	`pre' lincom $slope1
	global b1 = r(estimate)

	`pre' lincom $slope2
	global b2 = r(estimate)

	if "`interaction'" == "3way" {
		`pre' lincom $slope3
		global b3 = r(estimate)

		`pre' lincom $slope4
		global b4 = r(estimate)
	}
	
	/* intercepts */

	qui lincom $intercept1
	global c1 = r(estimate)

	qui lincom $intercept2
	global c2 = r(estimate)

	if "`interaction'" == "3way" {
		qui lincom $intercept3
		global c3 = r(estimate)
	
		qui lincom $intercept4
		global c4 = r(estimate)
	}

	/* differences in simple slopes */
		
	`pre' lincom $slope2 - $slope1

	if "`interaction'" == "3way" {
		`pre' lincom $slope4 - $slope3
		`pre' lincom $slope3 - $slope1
		`pre' lincom $slope4 - $slope2
	}

	generatecoordinates $b1 $b2 $c1 $c2 $lo $hi `precision' `arrowoffset' `arrowxlength' `arrowylength'

	if "`interaction'" == "2way" {
		twoway  (pci `r(line1y1)' $lo `r(line1y2)' $hi, recast(pccapsym) msymbol(X))    ///
			(pci `r(line2y1)' $lo `r(line2y2)' $hi, recast(pccapsym) msymbol(sh)) ///
			(scatteri `r(line1y1)' $lo "`r(line1y1)'", msymbol(+)) ///
			(scatteri `r(line1y2)' $hi "`r(line1y2)'", msymbol(+)) ///
			(scatteri `r(line2y1)' $lo "`r(line2y1)'", msymbol(x)) ///
			(scatteri `r(line2y2)' $hi "`r(line2y2)'", msymbol(x)) ///
			(pcarrowi `r(arrow1y2)' `r(arrow1x2)' `r(arrow1y1)' `r(arrow1x1)' "Low `w': Y = `r(slope1)' * X + `r(intercept1)'")   ///
			(pcarrowi `r(arrow2y2)' `r(arrow2x2)' `r(arrow2y1)' `r(arrow2x1)' "High `w': Y = `r(slope2)' * X + `r(intercept2)'"), ///
			legend(off) xtitle("`x'") ytitle("`y'") `graphopts'

	}
	else {
		twoway  (pci `r(line1y1)' $lo `r(line1y2)' $hi, recast(pccapsym) msymbol(X))    ///
			(pci `r(line2y1)' $lo `r(line2y2)' $hi, recast(pccapsym) msymbol(sh)) ///
			(scatteri `r(line1y1)' $lo "`r(line1y1)'", msymbol(+)) ///
			(scatteri `r(line1y2)' $hi "`r(line1y2)'", msymbol(+)) ///
			(scatteri `r(line2y1)' $lo "`r(line2y1)'", msymbol(x)) ///
			(scatteri `r(line2y2)' $hi "`r(line2y2)'", msymbol(x)) ///
			(pcarrowi `r(arrow1y2)' `r(arrow1x2)' `r(arrow1y1)' `r(arrow1x1)' "Low `w': Y = `r(slope1)' * X + `r(intercept1)'")   ///
			(pcarrowi `r(arrow2y2)' `r(arrow2x2)' `r(arrow2y1)' `r(arrow2x1)' "High `w': Y = `r(slope2)' * X + `r(intercept2)'"), ///
			legend(off) xtitle("`x'") ytitle("`y'") `graphopts' ///
			title("Low `z'") name(__temp__low, replace) nodraw
			
		generatecoordinates $b3 $b4 $c3 $c4 $lo $hi `precision' `arrowoffset' `arrowxlength' `arrowylength'

		twoway  (pci `r(line1y1)' $lo `r(line1y2)' $hi, recast(pccapsym) msymbol(X))    ///
			(pci `r(line2y1)' $lo `r(line2y2)' $hi, recast(pccapsym) msymbol(sh)) ///
			(scatteri `r(line1y1)' $lo "`r(line1y1)'", msymbol(+)) ///
			(scatteri `r(line1y2)' $hi "`r(line1y2)'", msymbol(+)) ///
			(scatteri `r(line2y1)' $lo "`r(line2y1)'", msymbol(x)) ///
			(scatteri `r(line2y2)' $hi "`r(line2y2)'", msymbol(x)) ///
			(pcarrowi `r(arrow1y2)' `r(arrow1x2)' `r(arrow1y1)' `r(arrow1x1)' "Low `w': Y = `r(slope1)' * X + `r(intercept1)'")   ///
			(pcarrowi `r(arrow2y2)' `r(arrow2x2)' `r(arrow2y1)' `r(arrow2x1)' "High `w': Y = `r(slope2)' * X + `r(intercept2)'"), ///
			legend(off) xtitle("`x'") ytitle("`y'") `graphopts' ///
			title("High `z'") name(__temp__high, replace) nodraw

		graph combine __temp__low __temp__high, ycommon `graphopts'
	}

	set more on

end

program define generatecoordinates, rclass

	syntax [anything]

	tokenize `anything'

	local sl1 = `1'
	local sl2 = `2'
	local ic1 = `3'
	local ic2 = `4'
	local lowx = `5'
	local hix = `6'
	local prec = `7'
	local ao = `8'
	local axl = `9'
	local ayl = `10'

	return scalar slope1 = round(`sl1', `prec')
	return scalar slope2 = round(`sl2', `prec')
	return scalar intercept1 = round(`ic1', `prec')
	return scalar intercept2 = round(`ic2', `prec')

	// Low W line
	local _line1y1 = round(`ic1' + `sl1' * `lowx', `prec')
	return scalar line1y1 = `_line1y1'
	return scalar line1y2 = round(`ic1' + `sl1' * `hix', `prec')

	// High W line
	local _line2y1 = round(`ic2' + `sl2' * `lowx', `prec')
	return scalar line2y1 = `_line2y1'
	return scalar line2y2 = round(`ic2' + `sl2' * `hix', `prec')

	// Low W line, arrow head
	local _arrow1x1 = `lowx' + (`hix' + abs(`lowx')) * `ao'
	return scalar arrow1x1 = `_arrow1x1'
	local _arrow1y1 = `ic1' + `sl1' * `_arrow1x1'
	return scalar arrow1y1 = `_arrow1y1'

	// Low W line, arrow tail (where the text is)
	// there is still a bug here when lines cross over 0
	return scalar arrow1x2 = `_arrow1x1' + (`hix' + abs(`lowx')) * `axl'
	if (`_arrow1y1' > 0 & `_line1y1' > 0) | (`_arrow1y1' < 0 & `_line1y1' < 0) {
		return scalar arrow1y2 = `_arrow1y1' + (`_line1y1' - `_arrow1y1') * `ayl'
	}
	else {
		if `_line1y1' > `_arrow1y1' {
			return scalar arrow1y2 = `_arrow1y1' + abs((`_line1y1' + `_arrow1y1') * `ayl')
		}
		else {
			return scalar arrow1y2 = `_arrow1y1' - abs((`_line1y1' + `_arrow1y1') * `ayl')
		}
	}

	// High W line, arrow head
	local _arrow2x1 = `lowx' + (`hix' + abs(`lowx')) * `ao'
	return scalar arrow2x1 = `_arrow2x1'
	local _arrow2y1 = `ic2' + `sl2' * `_arrow2x1'
	return scalar arrow2y1 = `_arrow2y1'

	// High W line, arrow tail (where the text is)
	return scalar arrow2x2 = `_arrow2x1' + (`hix' + abs(`lowx')) * `axl'
	if (`_arrow2y1' > 0 & `_line2y1' > 0) | (`_arrow2y1' < 0 & `_line2y1' < 0) {
		return scalar arrow2y2 = `_arrow2y1' + (`_line2y1' - `_arrow2y1') * `ayl'
	}
	else {
		if `_line2y1' > `_arrow2y1' {
			return scalar arrow2y2 = `_arrow2y1' + abs((`_line2y1' + `_arrow2y1') * `ayl')
		}
		else {
			return scalar arrow2y2 = `_arrow2y1' - abs((`_line2y1' + `_arrow2y1') * `ayl')
		}
	}

end


