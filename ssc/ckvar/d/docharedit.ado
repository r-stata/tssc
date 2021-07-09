*! version 1.0.0 July 22, 2006 @ 16:11:01
*! edits characteristics which can be attached to variables
program define docharedit
version 9
	/* 1.0.0 - Trying to make working with attached dochars easier */
	local myname "editdochar"
	
	syntax anything

	capture local theChar : char `anything'
	if _rc {
		display as error "`myname': could not use " as input `"`anything'"' as error " as varname[char] format!"
		error _rc
		}
	
	/* getting a tempfile to work with for editing */
	tempname localdo
	tempfile localdofile
	file open `localdo' using "`localdofile'", write text

	tokenize `"`macval(theChar)'"', parse(";")
	local cnt 1
	while `"``cnt''"'!="" {
		if `"``cnt''"'!=";" {
			file write `localdo' `"`macval(`cnt')'"' _n
			}
		local ++cnt
		}
	file close `localdo'
	/* doing the editing */
	doedit `localdofile'
	local oldmore `c(more)'
	set more on
	more
	set more `oldmore'
	/* putting the commands back into a characteristic */
	file open `localdo' using "`localdofile'", read text
	while 1 {
		file read `localdo' line
		if r(eof)==1 {
			continue, break
			}
		local newChar `"`macval(newChar)'`macval(line)';"'
	}
	char `anything' `"`macval(newChar)'"'
end
