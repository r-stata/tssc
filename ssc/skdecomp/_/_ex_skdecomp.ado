cap program drop _ex_skdecomp
program define _ex_skdecomp, rclass

syntax, example(numlist)

preserve
if ( "`example'" == "1") {
	clear
	use exdata_skdecomp.dta
	skdecomp income [w=weight], by(year) varpl(lp_4usd) in(fgt0 fgt1 fgt2)
}

restore
end
