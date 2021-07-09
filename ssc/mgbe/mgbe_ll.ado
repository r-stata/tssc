capture prog drop mgbe_ll
program define mgbe_ll
if "$S_dist" == "gg" | "$S_dist" == "gamma" | "$S_dist" == "wei" {
args lnf a b p
local q = .
}
else if "$S_dist" == "ln" {
args lnf b p
local a = .
local q = .
}
else if "$S_dist" == "pareto2" {
args lnf b q
local a = .
local p = .
}
else {
args lnf a b p q
}

mgbe_cdf `a' `b' `p' `q' $S_mlz2 "$S_dist"
rename cdf cdf_max
mgbe_cdf `a' `b' `p' `q' $S_mlz1 "$S_dist"
rename cdf cdf_min
qui replace `lnf' = $S_mln * ln(cdf_max - cdf_min)
qui drop cdf_min cdf_max

end
