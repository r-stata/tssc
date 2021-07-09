capture program drop title
program define title 
*!2.0 June 6 2000 Jan Brogger 
	version 6.0

	/* get everything thats before the comma into titles */

	gettoken part 0 : 0, parse(" ,") quotes
	while `"`part'"' ~= "," & `"`part'"' ~= "" {
		local left `"`left' `part'"'
		gettoken part 0 : 0, parse(" ,") quotes
	}

	local titles `"`left'"'
	local 0 `",`0'"'

	*di `"0 -`0'-"'
	*di `"titles -`titles'-"'

	syntax  [,ll ss xl xxl n(integer -1) bl(integer -1)]

	local lins=2
	local blanks=1
	if ("`ss'" ~= "") { 
		local lins= 1 
		local blanks=1
	}
	if ("`ll'" ~= "") { 
		local lins= 3 
		local blanks=1
	}
	if ("`xl'" ~= "") { 
		local lins= 3 
		local blanks=2
	}
	if ("`xxl'" ~= "") { 
		local lins= 5
		local blanks=3
	}
	if (`n' >0 ) {
		local lins=`n'
	}
	if (`bl' >0 ) {
		local blanks=`bl'
	}


	local lin_i = 1
	while  (`lin_i' <= `blanks' ) {
		di _newl
		local lin_i = `lin_i'+1
	}

	local lin_i = 1
	while  (`lin_i' <= `lins' ) {
		di _dup(79) "*" 
		local lin_i = `lin_i'+1
	}


	local lin_i = 1
	while  (`lin_i' <= `lins' ) {
		di _dup(5) "*" _col(75) _dup(5) "*"
		local lin_i = `lin_i'+1
	}


	tokenize `"`titles'"'

	while "`1'" ~= "" {

		local col=int((80-length(`"`1'"'))/2)
	
		di _dup(5) "*" _col(`col') "`1'" _col(75) _dup(5) "*"

		macro shift 1
	}


	local lin_i = 1
	while  (`lin_i' <= `lins' ) {
		di _dup(5) "*" _col(75) _dup(5) "*"
		local lin_i = `lin_i'+1
	}
	di _dup(5) "*" _col(50) "$S_DATE" _col(65) "$S_TIME" _col(75) _dup(5) "*"



	local lin_i = 1
	while  (`lin_i' <= `lins' ) {
		di _dup(79) "*" 
		local lin_i = `lin_i'+1
	}


	local lin_i = 1
	while  (`lin_i' <= `blanks' ) {
		di _newl
		local lin_i = `lin_i'+1
	}

end
