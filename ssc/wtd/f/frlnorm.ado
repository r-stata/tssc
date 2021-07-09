* LogNormal forward recurrence density
* Henrik Støvring, 3. december 1999

program define frlnorm
	syntax varlist(min = 2 max = 2) [if/] [in], [gparm(string) gpvars(varlist)]
	tokenize `varlist'
	local x `1'
	local fval `2'

if "`gparm'" ~= "" {
  tempname mu lnsigma
  scalar `mu' = `gparm'[1, 1]
  scalar `lnsigma' = `gparm'[1, 2]
}
if "`gpvars'" ~= "" {
  tokenize "`gpvars'"
  local mu `1'
  local lnsigma `2'
}
if "`gparm'" == "" & "`gpvars'" == "" {
  di in red "You must specify either gparm or gpvars"
  exit
}

	if "`if'" == "" {
		local if = "1 == 1"
		}
	qui replace `fval' = normprob(-(ln(`x') - `mu')/exp(`lnsigma')) /*
                        */ / exp(`mu' + exp(2 * `lnsigma')/2) /*
			*/ if `if' & `x' > 0 `in'

	qui replace `fval' = 1 / exp(`mu' + exp(2 * `lnsigma')/2) /*
			*/ if `if' & `x' == 0 `in'
end

