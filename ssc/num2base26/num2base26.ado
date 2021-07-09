*!Version 1.0 Converts a number to a letter. Interface to mata's numtobase26() function.
*!Date: 20.07.2018
* This program is in fact older and used by before for a long time, before I decided to make it public.
program num2base26, rclass
	version 13.0 //Should also work with lower version numbers.
	syntax anything(name=num) [, LOWer DISPlay Return(string)]
	local num = `num'
	* Checking if a number was provided
	if "`num'"==""{
		disp as error "Enter a number to be converted into a letter"
		exit 198
	}
	*Excel can't deal with higher column numbers, as far as I know.
	if real("`num'")==. | real("`num'")<0 | real("`num'")>16384{
		disp as error "Enter a number between 0 and 16384"
		exit 198
	}
	
	
	mata: letter = strtoreal(st_local("num"))
	mata: col = numtobase26(letter)
	mata: st_local("letter", col)
	
	if `"`lower'"'!=""{
	local letter = strlower("`letter'")
	}
	if "`display'"!=""{
		display "The letter is: `letter'"
	}
	if "`return'"=="" local return letter
	
	return local `return'  `letter'
end
