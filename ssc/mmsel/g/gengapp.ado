capture program drop gengapp
program gengapp, rclass

	 /* Draw wages for men */
	drawwage m m/* Draw wages for women (with men's chars) - NO womens chars mens coefs */
	drawwage f f
	drawwage f p
	drawwage m p

	
	* Calculate gender gap at each percentile

	use xmbm, clear
	merge using xfbf
	drop _merge
	merge using xfbp
	drop _merge
	merge using xmbp
	drop _merge	

	pctile xfbfpc = xfbf, nq(20) 
	pctile xmbmpc = xmbm, nq(20)
	pctile xfbppc = xfbp, nq(20)
	pctile xmbppc = xmbp, nq(20)

forval i = 1/19 {

		return scalar unexpgap`i' = (xmbmpc[`i'] - xfbfpc[`i']) - (xmbppc[`i'] - xfbppc[`i'])
		return scalar ovgap`i' = xmbmpc[`i'] - xfbfpc[`i']
		return scalar expgap`i' = xmbppc[`i'] - xfbppc[`i']

	}

end /* of program gengap */
