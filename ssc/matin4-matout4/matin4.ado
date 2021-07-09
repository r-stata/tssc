*! CFB matin4 1.0.1 16aug2004
*! WWG from file.hlp
	program define matin4
		version 7
		gettoken mname 0 : 0 
		if "`mname'" == ""  | "`mname'" == "using" {
			di as err "Usage: matin4 matrixname using filename"
			error 198
			}
		syntax using/

		tempname hdl
		file open `hdl' using `"`using'"', read binary

		file read `hdl' %14s signature
  		if "`signature'" != "matout4 1.0.1" {
  		        disp as err "file not matout4 1.0.1"
			exit 610
		}

		tempname val
		file read `hdl' %1b `val'
		local border = `val'
		file set `hdl' byteorder `border'

		file read `hdl' %2b `val'
		local r = `val'
		file read `hdl' %2b `val'
		local c = `val'

		matrix `mname' = J(`r', `c', 0)

  		file read `hdl' %4b `val'
  		local len = `val'
  		file read `hdl' %`len's names
  		matrix rownames `mname' = `names'

  		file read `hdl' %4b `val'
  		local len = `val'
  		file read `hdl' %`len's names
  		matrix colnames `mname' = `names'

		forvalues i=1(1)`r' {
			forvalues j=1(1)`c' {
				file read `hdl' %8z `val'
				matrix `mname'[`i',`j'] = `val'
			}
		}
		file close `hdl'
	end
