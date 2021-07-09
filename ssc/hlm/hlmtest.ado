/*----------------------------------------------------
  this program parses the test option 
  in the hlm2 and hlm3 commands
----------------------------------------------------*/

capture program drop hlmtest
program define hlmtest
version 8.2
	local test "`0'"

local test:subinstr local test " " "", all
local test:subinstr local test "][" " ", all
local test:subinstr local test "]" "", all
local test:subinstr local test "[" "", all

local g=1
while "`test'"~="" {
	gettoken test`g' test: test
	local test`g':subinstr local test`g' "," " ", all
	local c=1
	while "`test`g''"~="" {
		gettoken test`g'c`c' test`g': test`g'
		local test`g'c`c':subinstr local test`g'c`c' "=" " ", all
		local test`g'cnum:word count `test`g'c`c'' 
		if `test`g'cnum' > 2 {
			local n=`c'
			local test`g'ctemp = "`test`g'c`c''"
			gettoken left test`g'ctemp: test`g'ctemp
			while "`test`g'ctemp'"~="" {
				gettoken right test`g'ctemp: test`g'ctemp
				local test`g'c`n' = "`left'=`right'"
				local n = `n' + 1
			}
			local c = `n' - 1 
		}
		else if `test`g'cnum' == 2 {
			local test`g'c`c':subinstr local test`g'c`c' " " "=", all
		}
		local c = `c' + 1
	}
	local g = `g'+1
}
local g = `g' - 1
local numtest = `g'

*now we have `g' tests, each with multiple contrasts.  
*contrast C of test G is contained in the local macro testGcC
*now, for each contrast, we need to determine the coefficients associated with each 
*position in the vector of variables/interactions

local g=1
while "`test`g'c1'" ~= "" {
	local c=1
	while "`test`g'c`c''" ~= "" {
		local test`g'c`c':subinstr local test`g'c`c' "=" " ", all
		gettoken leftt`g'c`c' rightt`g'c`c': test`g'c`c'
		local rightt`g'c`c':subinstr local rightt`g'c`c' " " "", all
		local leftt`g'c`c' "#`leftt`g'c`c''"
		local l1 : piece 1 2 of "`leftt`g'c`c''"
		if "`l1'" ~= "#-" {
			  local leftt`g'c`c' "+`leftt`g'c`c''"
		}
		local rightt`g'c`c' "#`rightt`g'c`c''"
		local r1 : piece 1 2 of "`rightt`g'c`c''"
		if "`r1'" ~= "#-" {
			  local rightt`g'c`c' "+`rightt`g'c`c''"
		}
		local leftt`g'c`c':subinstr local leftt`g'c`c' "+" " +", all
		local leftt`g'c`c':subinstr local leftt`g'c`c' "-" " -", all
		local rightt`g'c`c':subinstr local rightt`g'c`c' "+" "#$%", all
		local rightt`g'c`c':subinstr local rightt`g'c`c' "-" " +", all
		local rightt`g'c`c':subinstr local rightt`g'c`c' "#$%" " -", all
		local test`g'c`c' "`leftt`g'c`c'' `rightt`g'c`c''"
		local test`g'c`c':subinstr local test`g'c`c' "# " "", all
		local test`g'c`c':subinstr local test`g'c`c' "#" "", all

*now take each term of each `test`g'c`c'' and put a 1 or -1 in front if needed
		local test`g'c`c':subinstr local test`g'c`c' "-" "-1*", all
		local test`g'c`c':subinstr local test`g'c`c' "+" "+1*", all

*now test`g'c`c' is a string of coefficients*variables, 
*each with the right sign on it for the contrast. 

		local t=1
		while "`test`g'c`c''" ~= "" {
			gettoken test`g'c`c't`t' test`g'c`c': test`g'c`c'
			if "`test`g'c`c't`t''" ~= "-1*0" & "`test`g'c`c't`t''" ~= "+1*0" { 
				local test`g'c`c't`t': subinstr local test`g'c`c't`t' "*" " ", all 
				gettoken sign`g'c`c't`t' test`g'c`c't`t': test`g'c`c't`t'
				gettoken a`g'c`c't`t' abvars`g'c`c't`t': test`g'c`c't`t'
				capture confirm number `a`g'c`c't`t'' 
				if _rc==0 {
					local cons`g'c`c't`t' = `sign`g'c`c't`t'' * `a`g'c`c't`t''
					local errtest: subinstr local abvars`g'c`c't`t' " " "", all
					if "`errtest'" == "" & `a`g'c`c't`t''~=0 {
						di in re "non-zero constant term in test option"
						error 197
					}
				}
				else {
					local cons`g'c`c't`t' = `sign`g'c`c't`t''
					local abvars`g'c`c't`t' "`test`g'c`c't`t''"
				}
			
				local intest: subinstr local abvars`g'c`c't`t' " " "", all
				if "`intest'" == "int" 	local vars`g'c`c't`t' "int"
				else {
					while "`abvars`g'c`c't`t''" ~= "" {
						gettoken var`g'c`c't`t' abvars`g'c`c't`t': abvars`g'c`c't`t'
						unab var`g'c`c't`t': `var`g'c`c't`t''
						if "`vars`g'c`c't`t''" == "" {
							local vars`g'c`c't`t' "`var`g'c`c't`t''"
						}
						else {
							local vars`g'c`c't`t' "`vars`g'c`c't`t''*`var`g'c`c't`t''"
						}
					}
				}
				local t = `t' + 1
			}
		}
		local c = `c' + 1
	}
	local g = `g' + 1
}

*now `cons`g'c`c't`t'' holds the constant term for variable/interaction `vars`g'c`c't`t''
*now simply need to identify the location in the model of term `vars`g'c`c't`t''

macro drop testcmd*
local g=1
while "`vars`g'c1t1'" ~= "" {
	local c=1
	while "`vars`g'c`c't1'" ~= "" {
		global testcmd`g'c`c' "gamma`g':"
		local n=1
		while `n' <= $nterms {
			local coef`g'c`c't`n'=0
			local t=1
			while "`vars`g'c`c't`t''" ~= "" {
				if "`vars`g'c`c't`t''" == "${var`n'}" {
					local coef`g'c`c't`n'=`coef`g'c`c't`n'' + `cons`g'c`c't`t''
				}
				local t = `t' + 1			
			}
			if `n'<$nterms global testcmd`g'c`c' "${testcmd`g'c`c'}`coef`g'c`c't`n'',"
			else global testcmd`g'c`c' "${testcmd`g'c`c'}`coef`g'c`c't`n''"
			local n = `n' + 1
		}
		local c = `c' + 1
	}
	local g = `g' + 1
}

end
