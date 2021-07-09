// 1.0.0  JRF & AHF  09 Nov 2009
// Write STATA data in a format that WinBUGS understands.

version 11.0
program define bugwrite

syntax varlist [if] [in] [, Columns(integer 0) Space(integer 1) ///
							Width(integer 88) File(string) ///
							Leftpad(integer 0) Rightpad(integer 0)]

preserve
	if "`if'" + "`in'" != "" {
		qui keep `if' `in'
	}
	local N = _N

	local space = max(`space',0)
	
	local nvars : word count `varlist'
	local varcount = 0
	
	local colset = ( `columns' != 0 )
	
	if `"`file'"' != "" {
		local filename = trim(`"`file'"')
		local commapos = strpos("`filename'", ",")
		if `commapos' != 0 {
			local namestop = `commapos' - 1
			local optionstart = `commapos' + 1
			local option = substr("`filename'", `optionstart', length("`filename'"))
			local option = trim("`option'")
			local filename = substr("`filename'", 1, `namestop')
		}
		if "`option'" != "" & "`option'" != "replace" & "`option'" != "append" {
			noi di _newline _skip(4) as error "Cannot understand your file suboption, `option'."
			exit
		}
		local printtofile = 1
	}
	capture confirm file "`filename'"
	local rc = _rc
	if `rc' == 0 & "`option'" == "" {
		noi di as error _newline _skip(4) "The file `filename' already exists." 
		noi di as error _skip(4) "Please choose suboption replace or append, or specify another file."
		exit
	}
	local printtofile = ("`printtofile'" == "1")
	
	if `printtofile' == 1 {
		file open bugsdata using "`filename'", write `option'
	}
	
	if `printtofile' == 0 {
		noi di _newline(2)
	}
	
	foreach y of varlist `varlist' {
		local varcount = `varcount' + 1
		
		local cwidth = 0
		forv i = 1(1)`N' {
			local cwidth = max(length(string(`y'[`i'])) + `space',`cwidth')
		}
		local lcwidth = `cwidth' - `space'
		local width = max(`width',`cwidth')
		local indent = length("`y' = c(")
		
		if `colset' == 0 {
			local leftoverwidth = `width' - `indent' - `leftpad' - `lcwidth' - 1
			local columns = floor((`leftoverwidth') / (`cwidth' + 1)) + 1
		}
		if `printtofile' == 1 {
			file write bugsdata "`y' = c("
		}
		else {
			noi di "`y' = c(" _continue
		}
		
		local nrows = ceil( `N' / `columns' )
		forv i = 1(1)`nrows' {
			if `i' != 1 {
				if `printtofile' == 1 {
					file write bugsdata _skip(`indent')
				}
				else {
					noi di _skip(`indent') _continue
				}
			}
			local i1 = `columns' * (`i' - 1) + 1
			local i2 = min(`columns' * `i',`N')
			forv j = `i1'(1)`i2' {
				if `y'[`j'] == . { 
					local ys = "NA"
					local pad = int(max(`cwidth' - 2,0))
				}
				else {
					local ys = string(`y'[`j'])
					local pad = int(max(`cwidth' - length("`ys'"),0))
				}
				if `j' == `i1' {
					local pad = `pad' - `space' + `leftpad'
				}
				if `j' < `N' {
					if `j' != `i2' {
						if `printtofile' == 1 {
							file write bugsdata _skip(`pad') "`ys',"
						}
						else {
							noi di _skip(`pad'),, "`ys'," _continue
						}
					}
					else {
						if `printtofile' == 1 {
							file write bugsdata _skip(`pad') "`ys'," _newline
						}
						else {
							noi di _skip(`pad'),, "`ys',"
						}
					}
				}
				else {
					if `varcount' != `nvars' {
						if `printtofile' == 1 {
							file write bugsdata _skip(`pad') "`ys'" _skip(`rightpad') ")," _newline
						}
						else {
							noi di _skip(`pad'),, "`ys'",, _skip(`rightpad') "),"
						}
					}
					else {
						if `printtofile' == 1 {
							file write bugsdata _skip(`pad') "`ys'" _skip(`rightpad') ")" _newline
						}
						else {
							noi di _skip(`pad'),, "`ys'",, _skip(`rightpad') ")"
						}
					}
				}
			}
		}
		if `printtofile' == 1 {
			file write bugsdata _newline
		}
		else {
			noi di _newline
		}
	}
	if `printtofile' == 0 {
		noi di _newline
	}
restore	
if `printtofile' == 1 {
	file close bugsdata
}
end
