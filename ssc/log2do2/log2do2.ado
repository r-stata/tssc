*! log2do2.ado v1.0.1 Nicholas Winter 16oct2002
program define log2do2
	version 7

	syntax anything(id="input file") , saving(string) [ replace append ]

	tempname bin tout num num1

	file open `bin' using `anything', binary read
	file open `tout' using `"`saving'"' , text write `replace' `append'

	file read `bin' %1bu `num'
	file read `bin' %1bu `num1'

	while !r(eof) {

		if char(`num')=="." & char(`num1')==" " {
			GetLine `bin' `tout' `num' `num1' 0		/* zero means not in forX loop */

			local line `s(line)'
			if (index(`"`line'"',"forval") |			/*
			*/ index(`"`line'"',"foreach")) &			/*	check for forX, and grab until over
			*/ !index(`"`line'"',"}") {
				local nbrace 1
				while `nbrace'>0 {
					GetLine `bin' `tout' `num' `num1' `nbrace'
					local nbrace=`s(nbrace)'
				}
			}

		}
		else {
			SkipLine `bin' `num' `num1'
		}

	}
	di `"{txt}Created {res}`saving'"'

end

program define GetLine, sclass
	args bin tout num num1 nbrace

	if `nbrace'>0 {
		tempname num2
		file read `bin' %1bu `num2'
		local x = char(`num')+char(`num1')+char(`num2')
		cap confirm number `x'
		if _rc {
			scalar `num'=`num2'			/* is not a numbered line; so just transfer the next char */
		}
		else {
			file read `bin' %1bu `num' 	/* is a numbered line; so skip the period and grab next char */
			file read `bin' %1bu `num'
		}
	}
	else {	/* not in forX loop, so just get the next character */
		file read `bin' %1bu `num'
	}

	local done 0
	local line

	while !`done' {
		if !(`num'==10 | `num'==13) {
			if `num'==96 {					/* only way to output the ` character */
				file write `tout' "`"
				local line `line'`
			}
			else {
				if `num'==32 {
					local c " "			/* only way to assign " " to the local c */
					local line `"`line' "'
				}
				else {
					local c=char(`num')
					local line `line'`c'
				}
				file write `tout' `"`c'"'
			}
			file read `bin' %1bu `num'
		}
		else {	/* reached eol character */

			while `num'==10 | `num'==13 {
				file read `bin' %1bu `num'				/* slither past */
			}

			file read `bin' %1bu `num1'					/* get next character to set up num & num1 */

			if (char(`num')==">" & char(`num1')==" ") {		/* check for continuation */
				file read `bin' %1bu `num'				/*  ... if so, just keep going */
			}
			else {
				file write `tout' _n					/* ... otherwise terminate line */
				local done 1
				sreturn local line `"`line'"'
				if `nbrace'>0 {
					local line : subinstr local line "{" "{" , all count(local o)
					local line : subinstr local line "}" "}" , all count(local c)
					local nbrace = `nbrace'+`o'-`c'
					sreturn local nbrace `nbrace'
				}
			}
		}
	}

end

/*
	If there is a < for___ ... { > construct, the following lines
	begin with a number and a period, *OR*
	with the traditional ". ", if there was a blank line

	The problem is that the numbered lines are indistinguishable from
	what is produced by -list-

	So:
		check each line for -forval- or -foreach-
		if yes, count open { and close }
		take each line until {} is at zero as a command line

		each of these command lines begins with ". " OR "nnn."
		where nnn is a right-justified number

	Note that nested for___ {} constructs will be fine, because
		they are all listed together, before any output


	However, the counting of braces will be messed up if any are in comments.
	Need to think about this.

*/


program define SkipLine
	args bin num num1 win

	*current `num' and `num1' are first two characters of the line to be skipped

	local done=(`num'==10 | `num'==13)	/* we've reached the end */
	while !`done' {
		scalar `num' = `num1'
		file read `bin' %1bu `num1'
		local done=(`num'==10 | `num'==13)
	}
	while (`num'==10 | `num'==13 | `num1'==10 | `num1'==13) {	/* slither past the eol char(s) */
		scalar `num' = `num1'
		file read `bin' %1bu `num1'
	}

end

