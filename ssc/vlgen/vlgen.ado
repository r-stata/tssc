// 1.0.1  JRF  24 May 2010
program define vlgen
	version 8.0

	syntax anything(name=varname) =/exp [if] [in], [replace noPromote noConditionals]

	if "`replace'" == "" {
		if "`promote'" != "" {
			noi di `""Replace" not specified. "Nopromote" option ignored."'
		}
		gen `varname' = `exp' `if' `in'
	}
	else {
		replace `varname' = `exp' `if' `in', `promote'
	}

	if "`conditionals'" != "noconditionals" {
		local newlab "`exp' `if' `in'"
	}
	else {
		local newlab "`exp'"
	}
	
	local pos = strpos("`newlab'","(")
	if `pos' != 0 {
		local newlab = subinstr("`newlab'","(", "( ", .)
	}
	local pos = strpos("`newlab'",")")
	if `pos' != 0 {
		local newlab = subinstr("`newlab'",")", " )", .)
	}

	foreach op in "+" "*" "-" "/" "^" "==" "!=" "~=" "<" ">" "<=" ">=" "&" "|" "!" "~" {
		local pos = strpos("`newlab'","`op'")
		if `pos' != 0 {
			local newlab = subinstr("`newlab'","`op'", `" `op' "', .)
		}
	}
	local pos = strpos("`newlab'","  ")
	if `pos' != 0 {
		local newlab = subinstr("`newlab'", "  ", " ", .)
	}
	
	local numwords = wordcount("`newlab'")
	local varlab ""
	forv i = 1(1)`numwords' {
		local word`i' = word("`newlab'",`i')
		capture confirm variable `word`i''
		if _rc == 0 {
			local otherlab : var label `word`i''
			if trim("`otherlab'") == "" {
				local otherlab "`word`i''"
			}
		}
		else {
			local otherlab "`word`i''"
		}
		local varlab "`varlab'`otherlab' "
	}
	local varlab = trim("`varlab'")
	
	
	label var `varname' "`varlab'"
end

