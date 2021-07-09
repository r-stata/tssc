use http://www.stata-press.com/data/r14/nhanes2.dta, clear
levelsof region
foreach r in `r(levels)' {
	export delim using nhanes_reg`r' if region == `r'
}
