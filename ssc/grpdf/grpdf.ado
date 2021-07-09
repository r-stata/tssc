*! grpdf  CFBaum 21may2016
capt prog drop grpdf
prog grpdf
version 10
qui gr dir
if length("`r(list)'") == 1 {
	di as err _n "No graphs in memory."
	exit
}
loc ll `r(list)'
loc i 0
foreach w of local ll {
	gr display `w'
	qui gr export `w'.pdf, replace
	loc i=`i'+1
}
di _n "`i' graphs [`ll']  exported to PDF"
end
