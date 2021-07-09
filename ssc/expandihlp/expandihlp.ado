*!expandihlp Version 1.0 Date: 20.12.2018
*!Inserts .ihlp-files into .sthlp-files

capture program drop expandihlp
program define expandihlp, rclass
	syntax , File(string) [ REName NOTest SUFfix(string) ]
	*Issue warning if unsupported version Stata is used
	local version = _caller()
	if `version' < 14.2{
	version `version'
	disp as err "Tested only for Stata version 14.2 and higher."
	disp as err "Your Stata version `version' is not officially supported."
	}
	else{
		version 14.2
		}
	
	tempname fhin fhout
	*Find the help file in standard search paths in case not the full path was provided.
	capture confirm file `"`file'"'
	if _rc{
		local helpfile `"`file'"'
		gettoken word rest : helpfile, parse(".")
		if "`rest'"!=".sthlp"{ // Add missing extension
			local helpfile `helpfile'.sthlp 
		}
		capture findfile `helpfile'
		if _rc{
				disp as err " `file' is an incorrect filename."
				disp as err "Provide a correct filename which looks like program.sthlp or provide the correct path to file `file'."
				exit 198
		}
		local helpfile `r(fn)'
	}
	else{
		local helpfile `"`file'"'
	}

	*Test whether any include directives exist
	if "`notest'"==""{
		includeTest using `helpfile'
		local inccnt `r(inccnt)'
		if `r(inccnt)'==0{
			disp as err "No include directives found. Nothing to include into `helpfile'."
			exit
		}
	}
	
	*Get file name to create a new parsed file
	if "`suffix'"=="" local suffix _expanded
	local fileout  = usubinstr("`helpfile'",".","`suffix'.",1) 
	
	file open `fhin' using `helpfile', read 
	file open `fhout' using `"`fileout'"', write replace
	file read `fhin' line
	local linenumber 1
	while r(eof)==0{
		local inccnt 0

		 local incfound 0 // Set a trigger to exclude a line with the INCLUDE
		 if regexm(`"`line'"',"^(INCLUDE)"){
		 local ++inccnt
		 local incfound 1
		 local arg = word("`line'",3)
			tempname fh2
			*Extended file search
			capture findfile `arg'.ihlp
			if !_rc{
				local ihelpfile `r(fn)'
			}
			else{
				disp as error "File `arg'.ihlp in line `linenumber' not found. Nothing to expand here."
				continue
			}

			file open `fh2' using `ihelpfile', read
			file read `fh2' line2
			while r(eof)==0{
				if regexm(`"`line2'"',"^{\* ") continue // Ignore comments in the ihlp-file
				file write `fhout' `"`line2'"' _n
				file read `fh2' line2
			}
			file close `fh2'
			local incfiles "`incfiles' `arg'.ihlp"

		 }
		 if `incfound'==0 file write `fhout' `"`line'"' _n
		 file read `fhin' line
		 local ++linenumber
	}
	file close `fhin'
	file close `fhout'
	
	disp as txt "File `helpfile' expanded to file `fileout'. "
	if "`notest'"=="" disp "`inccnt' .ihlp-files integrated." _n "`incfiles' integrated."
	 
	
	if "`rename'"!=""{ 
		copy `helpfile' `word'_old.sthlp, replace
		copy `fileout' `helpfile', replace
		disp "`helpfile' renamed to `word'_old.sthlp." _n "`fileout' renamed to `helpfile'." 
		
	}
	
	*Saved results
	return local inccnt  `inccnt'
	return local incfiles `incfiles'
	return local origfile `helpfile'
	return local expfile `fileout'
end


program define includeTest, rclass
*Test for the existence of INCLUDE directives
	syntax using/
	tempname fhtest
	local inccnt 0
	file open `fhtest' using `"`using'"', read 
	file read `fhtest' line
	while r(eof)==0{
		if regexm(`"`line'"',"^(INCLUDE)"){
			local ++inccnt
		}
		file read `fhtest' line
	}
	file close `fhtest'
	return local inccnt `inccnt'
end



