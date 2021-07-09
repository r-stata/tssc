*! version 1.0.1 August 22, 2007 @ 11:40:15
*! for moving char values to dlg fields
program define _char2dlg
version 9
   /* 1.0.1 -- need to allow invalid vars for incomplete editing */
	capture syntax [varlist], char(str) dialog(str) control(str)
	local rc = _rc
	if `rc' {
		if `rc'==111 {
			syntax anything, char(str) dialog(str) control(str)
			}
		else {
			error `rc'
			}
		}
	local numVars: word count `varlist'
	if `numVars'>1 {
		/* never really gets in the way, even if varlist is empty */
		display as error "How did you select more than one variable?"
		exit 666
		}
	local obj ".`dialog'_dlg.`control'"
	local type "`.`obj'.classname'"

	if `numVars'==1 {
		local theChar: char `varlist'[`char']
		}

	if "`type'"=="d_checkbox" {
		if `"`theChar'"'=="" {
			`obj'.setoff
			}
		else {
			if `"`theChar'"'=="1" | strpos("yes",lower(`"`theChar'"')) | strpos("true",lower(`"`theChar'"')) {
				`obj'.seton
				}
			else {
				`obj'.setoff
				}
			}
		}
	else {
		`obj'.setvalue `"`macval(theChar)'"'
		`obj'.setdefault `"`macval(theChar)'"'
		}
end
