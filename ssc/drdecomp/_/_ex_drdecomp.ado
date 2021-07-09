cap program drop _ex_drdecomp
program define _ex_drdecomp, rclass

syntax, example(numlist)

preserve
if ( "`example'" == "1") {
	use exdata_drdecomp, clear
	drdecomp income [w=weight], by(year) varpl(lp_4usd_ppp) in(fgt0 fgt1 fgt2)
}
restore

end
