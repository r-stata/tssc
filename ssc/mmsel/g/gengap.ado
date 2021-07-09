capture program drop gengap
program gengap, rclass

if `"`1'"'=="g" {
	 /* Draw wages for men */
	drawwage m m/* Draw wages for women (with men's chars) - NO womens chars mens coefs */
	drawwage f f
	drawwage f g
	
	
	* Calculate gender gap at each percentile

	use tmp/xmbm, clear
	merge using tmp/xfbf
	drop _merge
	merge using tmp/xfbg
	drop _merge
	
	pctile xfbfpc = xfbf, nq(20) 
	pctile xmbmpc = xmbm, nq(20)
	pctile xfbgpc = xfbg, nq(20) 

forval i = 1/19 {

		return scalar unexpgap`i' = xfbgpc[`i'] - xfbfpc[`i']
		return scalar ovgap`i' = xmbmpc[`i']-xfbfpc[`i']
		return scalar expgap`i' = xmbmpc[`i'] - xfbgpc[`i']
	}
}

if `"`1'"'=="p" {
	 /* Draw wages for men */
	drawwage m m/* Draw wages for women (with men's chars) - NO womens chars mens coefs */
	drawwage f f
	drawwage f p
	drawwage m p

	
	* Calculate gender gap at each percentile

	use tmp/xmbm, clear
	merge using tmp/xfbf
	drop _merge
	merge using tmp/xfbp
	drop _merge
	merge using tmp/xmbp
	drop _merge	

	pctile xfbfpc = xfbf, nq(20) 
	pctile xmbmpc = xmbm, nq(20)
	pctile xfbppc = xfbp, nq(20)
	pctile xmbppc = xmbp, nq(20)

	forval i = 1/19 {
/*
		return scalar unexpgap`i' = (xmbmpc[`i'] - xfbfpc[`i']) - (xmbppc[`i'] - xfbppc[`i'])
		return scalar ovgap`i' = xmbmpc[`i'] - xfbfpc[`i']
		return scalar expgap`i' = xmbppc[`i'] - xfbppc[`i']
*/
		return scalar unexpgap`i' = (xmbmpc[`i']-xmbppc[`i']) + (xfbppc[`i'] - xfbfpc[`i'])
		return scalar ovgap`i' = xmbmpc[`i']-xfbfpc[`i']
		return scalar expgap`i' = xmbppc[`i'] - xfbppc[`i']
	}
}

if `"`1'"'=="i" {
	 /* Draw wages for men */
	drawwage m m/* Draw wages for women (with men's chars) - NO womens chars mens coefs */
	drawwage f f
	drawwage f i
	drawwage m i

	
	* Calculate gender gap at each percentile

	use tmp/xmbm, clear
	merge using tmp/xfbf
	drop _merge
	merge using tmp/xfbi
	drop _merge
	merge using tmp/xmbi
	drop _merge	

	pctile xfbfpc = xfbf, nq(20) 
	pctile xmbmpc = xmbm, nq(20)
	pctile xfbipc = xfbi, nq(20)
	pctile xmbipc = xmbi, nq(20)

	forval i = 1/19 {

		return scalar unexpgap`i' = (xmbmpc[`i'] - xfbfpc[`i']) - (xmbipc[`i'] - xfbipc[`i'])
		return scalar ovgap`i' = xmbmpc[`i'] - xfbfpc[`i']
		return scalar expgap`i' = xmbipc[`i'] - xfbipc[`i']

	}
}
	
end /* of program gengap */
