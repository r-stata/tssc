*! c v2.0.1 Nicholas Winter 29oct2002
program define c
	version 7.0

	args a b

	local x : sysdir PERSONAL
	local file `"`x'directoryfile.txt"'
	tempname hdl

	cap confirm file `"`file'"'
	if !_rc {	/* file exists -- read in the database */
		capture file open `hdl' using `"`file'"' , text read
		if _rc==199 {
			di as error "Your Stata does not recognize the {cmd:file} command,"
			di as error "probably because it is not up to date.  Please"
			di as error "{help update} your copy of Stata and try again."
			exit 198
		}
		else if _rc {
			error _rc
		}
		file read `hdl' line
		local i 0
		while !r(eof) {
			local i=`i'+1
			tokenize `"`line'"', parse("*")
			local key`i' `1'
			local dir`i' `"`3'"'
			file read `hdl' line
		}
		file close `hdl'
	}
	else {	/* file not there */
		if !("`a'"=="cur" & `"`b'"'!="") {
			di as error `"no database - type "c cur {it:code}" to add the current directory"'
			exit
		}
		local i 0
	}

	if `"`a'"'!="" & `"`b'"'=="" {				/* just a code */
		local j 1
		while `"`key`j''"'!=`"`a'"' & `j'<=`i' {
			local j=`j'+1
		}
		if `"`key`j''"'==`"`a'"' {
			cd `"`dir`j''"'
			exit
		}
		else {
			di as error `"`a' is not in database"'
			di
							/* will skip to end and display the database */
			local a
			local b
		}
	}

	if `"`a'"'=="cur" {
		if `"`b'"'=="" {
			di as error "must specify code to add the current directory to the database"
			exit 198
		}
		forval j=1/`i' {
			if `"`key`j''"'==`"`b'"' {
				di as error `"`b' is already a code in the database"'
				di as error `"use "c drop `b'" to drop it"'
				exit 198
			}
		}
		local i=`i'+1
		local newdir : pwd
		local key`i' `b'
		local dir`i' `"`newdir'"'
		forval j=1/`i' {
			local list1 "`list1' `key`j''"
			local list2 `"`list2' "`dir`j''""'
		}
		SortEm , list1(`list1') list2(`list2') stub1(key) stub2(dir)

		file open `hdl' using `"`file'"', text write replace
		forval j=1/`i' {
			file write `hdl' `"`key`j''*`dir`j''"' _n
		}
		file close `hdl'
		di `"{res}{ralign 20:`b'}{txt}: `newdir'"'
		exit
	}

	if `"`a'"'=="drop" {
		if `"`b'"'=="" {
			di as error "must specify code to drop"
			exit 198
		}
		file open `hdl' using `"`file'"', text write replace
		forval j=1/`i' {
			if `"`key`j''"'!=`"`b'"' {
				file write `hdl' `"`key`j''*`dir`j''"' _n
			}
		}
		file close `hdl'
		exit
	}


*	if `"`a'"'=="sort" {
*		forval j=1/`i' {
*			local list1 "`list1' `key`j''"
*			local list2 `"`list2' "`dir`j''""'
*		}
*		SortEm , list1(`list1') list2(`list2') stub1(key) stub2(dir)
*
*		file open `hdl' using `"`file'"', text write replace
*		forval j=1/`i' {
*			local space = 19-length(`"`key`j''"')
*			di `"{p 0 23}{space `space'}{stata c `key`j'':`key`j''} {txt}`dir`j''{p_end}"'
*			file write `hdl' `"`key`j''*`dir`j''"' _n
*		}
*		file close `hdl'
*		SInst
*		exit
*	}

	if `"`a'"'=="" & `"`b'"'=="" {
		forval j=1/`i' {
			local space = 19-length(`"`key`j''"')
			di `"{p 0 23}{space `space'}{stata c `key`j'':`key`j''} {txt}`dir`j''{p_end}"'
		}
		SInst
	}


end program


program define SInst
	di
	di in y "  c {it:code}          " in g "to change directories"
	di in y "  c cur  {it:code}     " in g "to add current directory to database"
	di in y "  c drop {it:code}     " in g "to drop entry"
end



program define SortEm
	version 7

	syntax , list1(string) list2(string asis) stub1(string) stub2(string)

	local n : word count `list1'
	local n0 : word count `list2'
	if `n0' ~= `n' {
		di in re "number of words in lists 1 and `m' differ"
		exit 198
	}


	local direct "<"

	forval i=1/`n' {
		local key`i' "`i'"
	}

	* define macros 1..n from list1
	tokenize `"`list1'"'

	* non-recursive quicksort (Wirth 1976: 80, with modification p 82)
	local s 1
	local stl_1 1                       /* stack[s].l == stl_s */
	local str_1 `n'                     /* stack[s].r == str_s */

	while `s' > 0 {                     /* take top request from stack */
		local l `"`stl_`s''"'
		local r `"`str_`s''"'
		local s = `s'-1

		while `l' < `r' {           /* split key[l] ... key[r] */
			local i `l'
			local j `r'
			local ix = int((`l'+`r')/2)
			local x `"``key`ix'''"'

			while `i' <= `j' {

				while `"``key`i'''"' `direct' `"`x'"' { local i = `i'+1 }
				while `"`x'"' `direct' `"``key`j'''"' { local j = `j'-1 }

				if `i' <= `j' {         /* swap keys for elements i and j */
					local tmp    `"`key`i''"'
					local key`i' `"`key`j''"'
					local key`j' `"`tmp'"'
					local i = `i'+1
					local j = `j'-1
				}
			}

			* stack request to sort either left or right partition
			if `j'-`l' < `r'-`i' {
				if `i' < `r' {        /* sort right partition */
					local s = `s'+1
					local stl_`s' `i'
					local str_`s' `r'
				}
				local r `j'
			}
			else {
				if `l' < `j' {       /* sort left partition */
					local s = `s'+1
					local stl_`s' `l'
					local str_`s' `j'
				}
				local l `i'
			}
		} /* while l < r */
	}

	* apply sort ordering, leaving results in caller's locals
	forval i=1/`n' {
		c_local `stub1'`i' "``key`i'''"
	}
	tokenize `"`list2'"'
	forval i=1/`n' {
		c_local `stub2'`i' "``key`i'''"
	}

end

*end&

