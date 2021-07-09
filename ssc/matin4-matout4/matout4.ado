*! CFB matout4 1.0.1  16aug2004
*! WWG from file.hlp
		program define matout4
		version 7
		gettoken mname 0 : 0
		if "`mname'" == "" | "`mname'" == "using" {
			di as err "Usage: matout4 matrixname using filename"
			error 198
			}
		capt mat list `mname'
		if _rc == 111 {
			di as err "Error: matrix `mname' does not exist."
			error 198
			}
		syntax using/ [, replace]

		local r = rowsof(`mname')
		local c = colsof(`mname')

		tempname hdl

		file open `hdl' using `"`using'"', `replace' write binary

  		file write `hdl' %14s "matout4 1.0.1"
                file write `hdl' %1b (byteorder())
		file write `hdl' %2b (`r') %2b (`c')

  		local names : rownames `mname'
  		local len : length local names
  		file write `hdl' %4b (`len') %`len's `"`names'"'

  		local names : colnames `mname'
  		local len : length local names
  		file write `hdl' %4b (`len') %`len's `"`names'"'

		forvalues i=1(1)`r' {
			forvalues j=1(1)`c' {
				file write `hdl' %8z (`mname'[`i',`j'])
			}
		}
		file close `hdl'
	end
