program define splagvar_randper
	version 10.1
	syntax varlist
	mata: splagvar_CalcMoran("`varlist'", "`touse'")
end
