*! 1.1 Oct 7th Jan Brogger
capture program drop genvars
program define genvars
	version 6.0
	gettoken nhead nrest:0 , match(parens)
	_genv , pre("") headp("`nhead'") restp("`nrest'") level(0) /*verb*/
end

