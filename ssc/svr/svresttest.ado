*! svresttest v1.0.0 13sep2002 NJGW

program define svresttest, rclass
	version 7

	if "`e(cmd)'"!="svysvrest" {
		error 301
	}

	tempname b
	mat `b' = e(b)
	local x : colnames `b'
	tokenize `x'
	while "`1'"!="" {
		cap gen byte `1'=.
		if !_rc {
			local drop "`drop' `1'"
		}
		mac shift
	}
	svytest `0'

	drop `drop'

end
exit

/*
	This program is a kludge to make -svytest- (and the underlying -test-)
	work after svrest.  -svrest- names the estimates "stat1" "stat2", etc.
	-test- requires that variables of those names exist for expressions,
	such as "test stat1=stat2".

	This program creates faux variables with those names, as necessary,
	so that -test- will run

*/

