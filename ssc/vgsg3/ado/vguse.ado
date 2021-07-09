*! version 3.0.0  03nov2011
program define vguse
	version 8.2
	if `"`0'"' == "" {
		error 198
	}
	local 0 `"using `0'"'
	syntax using/ [, CLEAR ]
	if c(stata_version) < 10 {
		local prefix "http://www.stata-press.com/data/vgsg/data"
	}
	else if c(stata_version) >= 10 & c(stata_version) < 12 {
		local prefix "http://www.stata-press.com/data/vgsg2/data"
	}
	else {
		local prefix "http://www.stata-press.com/data/vgsg3/data"
	}
	use `"`prefix'/`using'"', `clear'
end

exit
