program define formatline, rclass
version 9.2
syntax, N(string) Maxlen(int) [ Format(string) Leading(int 1) Separator(string) ]
if `leading'<0 {
	noi di as err "invalid leading()"
	exit 198
}
if "`separator'"!="" {
	tokenize "`n'", parse("`separator'")
}
else tokenize "`n'"
local n 0
while "`1'"!="" {
	if "`1'"!="`separator'" {
		local ++n
		local n`n' `1'
	}
	macro shift
}
local j 0
local length 0
forvalues i=1/`n' {
	if "`format'"!="" {
		capture local out: display `format' `n`i''
		if _rc {
			noi di as err "invalid format attempted for: " `"`n`i''"'
			exit 198
		}
	}
	else local out `n`i''
	if `leading'>0 {
		local out " `out'"
	}
	local l1=length("`out'")
	local l2=`length'+`l1'
	if `l2'>`maxlen' {
		local ++j
		return local line`j'="`line'"
		local line "`out'"
		local length `l1'
	}
	else {
		local length `l2'
		local line "`line'`out'"
	}
}
local ++j
return local line`j'="`line'"
return scalar lines=`j'
end
