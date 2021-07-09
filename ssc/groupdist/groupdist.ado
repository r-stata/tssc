*! 1.0 VERSION OF GROUPDIST
program define groupdist
version 8.2
syntax, x(string) y(string) group(string) [inkm]

tempfile dist_merge

di "x is equal to `x'"
di "y is equal to `y'"
di "group is equal to `group'"
di "min/max is specified as `min'"

*Generating maximum number of individuals in a group
bysort `group': g group_num_count = _n
bysort `group': egen max_num_count = max(group_num_count)
egen maxadd = max(max_num_count)
global max = maxadd in 1
drop group_num_count max_num_count maxadd


preserve
keep `group' `x' `y'
bysort `group': g num = _n
reshape wide `x' `y', i(`group') j(num) 


forvalues j = 2(1)$max {

	vincenty `y'1 `x'1 `y'`j' `x'`j', v(v`j') `inkm'
	replace v`j' = 0 if (`y'1 == `y'`j') & (`x'1==`x'`j')
	}

egen maxdist = rowmax(v2-v$max)
egen mindist = rowmin(v2-v$max)
collapse(min) mindist (max)maxdist, by(`group')
keep `group' mindist maxdist
sort `group'
save `dist_merge', replace

restore
sort `group'
merge `group' using `dist_merge'
drop _merge


end

*END OF FILE

