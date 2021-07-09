*! v.1.0.2 N.Orsini 25sep2006

capture program drop xb2pi
program xb2pi, rclass
version 8.2

syntax anything  [,   Format(string)  ]

if "`format'" == "" {
local format = "%3.0f"
}   
else {
local format = "`format'"
}

local wc : word count `anything' 
 
tokenize "`anything'"
tempname xb
scalar `xb' = `1'

local numb = "" 

foreach v of local anything {
local step : display `format' (exp(`v')/(1+exp(`v')))*100
local numb = "`numb' `step' "
}

di _n  as text "`numb'"

return scalar xb =  `1' 
return scalar p = exp(`xb')/(1+exp(`xb'))
return local cmd = "xb2pi"
return local lprob = "`numb'"
return local lxb = "`anything'"
end
