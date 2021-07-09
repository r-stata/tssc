program define detangle
version 9.2
args target tname rhs separator
if "`separator'"=="" {
	local separator ","
}
unab rhs:`rhs'
local nx: word count `rhs'
forvalues j=1/`nx' {
	local n`j': word `j' of `rhs'
}
tokenize "`target'", parse("`separator'")
local ncl 0
while "`1'"!="" {
	if "`1'"=="`separator'" {
		mac shift
	}
	local ncl=`ncl'+1
	local clust`ncl' "`1'"
	mac shift
}
if "`clust`ncl''"=="" {
	local --ncl
}
if `ncl'>`nx' {
	noi di as err "too many `tname'() values specified"
	exit 198
}
forvalues i=1/`ncl' {
	tokenize "`clust`i''", parse(":")
	if "`2'"!=":" {
		if `i'>1 {
			noi di as err "invalid `clust`i'' in `tname'() (syntax error)"
			exit 198
		}
		local 2 ":"
		local 3 `1'
		local 1
		forvalues j=1/`nx' {
			local 1 `1' `n`j''
		}
	}
	local arg3 `3'
	unab arg1:`1'
	tokenize `arg1'
	while "`1'"!="" {
		ChkIn `1' "`rhs'"
		local v`s(k)' `arg3'
		mac shift
	}
}
forvalues j=1/`nx' {
	if "`v`j''"!="" {
		global S_`j' `v`j''
	}
	else global S_`j'
}
end
