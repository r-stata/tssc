*! v 1.0.1 PR 16jan2008
program define stepp_plot
syntax anything(name = stubname) [, vn(int 0) plot(string asis) * ]
if `vn'==0 local vn	// variable number in with(varlist) in stepp_tail or stepp_window
foreach thing in b se mean lb ub {
	confirm var `stubname'`thing'`vn'
}
graph twoway (rarea `stubname'lb`vn' `stubname'ub`vn' `stubname'mean`vn', sort pstyle(ci)) ///
 (line `stubname'b`vn' `stubname'mean`vn', sort lstyle(refline) pstyle(p2)) ///
 || `plot', legend(off) `options'
end
