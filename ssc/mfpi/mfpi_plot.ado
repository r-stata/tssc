*! v 2.0.0 PR 19apr2012
program define mfpi_plot
version 11.0
syntax varlist(min=1 max=2 numeric) [if] [in], ///
 [ STUBname(string) vn(int 1) LEVel(int 1) plot(string asis) * ]
if "`stubname'" == "" local stubname : char _dta[gendiff]
if "`stubname'" == "" {
	di as err "cannot identify saved variable for treatment-effect plot"
	di as err "please specify stubname(), or re-run -mfpi- using gendiff(stubname)"
	error 198
}
local treat : char _dta[treatment]
if "`treat'" == "" {
	di as err "cannot identify treatment variable"
	exit 198
}
qui levelsof `treat', local(levels)
local lplus1 = `level' + 1
local level_plot : word `lplus1' of `levels'
local level_0 : word 1 of `levels'
di as txt "[using variables created by gendiff(`stubname')]"
foreach thing in "" s lb ub {
	confirm var `stubname'`vn'`thing'_`level'
}
local te `stubname'`vn'_`level'	// treatment effect
local lb `stubname'`vn'lb_`level'	// lower CL
local ub `stubname'`vn'ub_`level'	// upper CL
gettoken x1 x : varlist
if ("`x'" != "") confirm var `x'
else local x `x1'
graph twoway (rarea `lb' `ub' `x' `if' `in', sort pstyle(ci)) ///
 (line `te' `x' `if' `in', sort lstyle(refline) pstyle(p2)) ///
 || `plot', legend(off) ytitle("Treatment effect") ///
 title("Level `level' (`level_plot') of `treat' vs level 0 (`level_0')") `options'
end
