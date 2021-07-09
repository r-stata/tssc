program predictms_stdparse, rclass
	args corevar i Ntrans
	
	local include = 0
	//see if _trans`i' is in it
	local intrans = regexm("`corevar'","_trans`i'")
	if `intrans' {
	
		local strlength = strlen("_trans`i'")
		local strlength2 = strlen("`corevar'")
		local corevarstub = substr("`corevar'",1,`=`strlength2'-`strlength'')
																
		//need to check that each var matches with *_trans`i', others not included in trans specific design matrix
		local extracttrans = substr("`corevar'",`=`strlength2'-`strlength'+1',.)
		if "`extracttrans'"=="_trans`i'" local include = 1
										
	}
	else {
		//could still be ?_transj
		local hastransj = 0
		forvalues j=1/`Ntrans' {
			if `i'!=`j' {
				if regexm("`corevar'","_trans`j'") {
					local hastransj = 1
				}
			}
		}
		if !`hastransj' {
			local include = 1
			local corevarstub `corevar'
		}
	}
	return local stdvar `corevarstub'
	return scalar include = `include'
	
end

