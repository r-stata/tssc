capture prog drop mgbe_cdf

prog define mgbe_cdf
args a b p q x

if "$S_dist" == "gb2" | "$S_dist" == "dagum"| "$S_dist" == "sm" |"$S_dist" == "loglog" ///
| "$S_dist" == "beta2" {
qui gen double cdf = ibeta(`p',`q',(`x'/`b')^`a'/(1+(`x'/`b')^`a'))
}

if "$S_dist" == "gg" | "$S_dist" == "gamma" | "$S_dist" == "wei" {
qui gen double cdf = gammap(`p', (`x'/`b')^`a')
}

if "$S_dist" == "ln" {
qui gen double cdf = normal((ln(`x') - `b')/`p')
}

if "$S_dist" == "pareto2" {
qui gen double cdf = 1 - (`b' / (`x'+`b'))^`q'
}

qui replace cdf = 0 if `x' == 0
qui replace cdf = 1 if `x' ==.

end	
