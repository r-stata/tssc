*! Version 1.0  18sep2010 ama

*FPREF: Adds a prefix or suffix, or both, to file names by batch 
*Arnelyn Abdon

capture prog drop fpref
prog define fpref
	version 10
	syntax anything(name=fileext id="{it: file_extension}")[, PREFix(string) SUFFix(string)]
	if "`c(os)'" == "Windows" {	
		loc cmd !rename
		}
		else {
			loc cmd !mv
		}
	if strpos("`prefix'"," ")~=0{
		display as error "{it: prefix} or {it: suffix} cannot have blank spaces" 
		exit
	}
	if strpos("`suffix'"," ")~=0{
		display as error "{it: prefix} or {it: suffix} cannot have blank spaces" 
		exit
	}	
	if "`prefix'"==""{
		if "`suffix'"==""{
			display as error "{it: prefix()} or {it:suffix()} is required"
			exit
		}
	}

	local filelist: dir "" files "*.`fileext'"
	if "`prefix'"~=""{
		if "`suffix'"~=""{
			foreach i of local filelist {
				local newname = "`prefix'" + subinstr("`i'",".`fileext'","`suffix'.`fileext'",1)
				`cmd' `i' `newname'
				display as text "`i'" "  --->  " "`newname'"
			}
		}
	}
	if "`prefix'"==""{
		foreach i of local filelist {
			local newname = subinstr("`i'",".`fileext'","`suffix'.`fileext'",1)
			`cmd' `i' `newname'	
			display as text "`i'" "  --->  " "`newname'"
		}
	}
	if "`suffix'"==""{
		foreach i of local filelist {
			local newname = "`prefix'" + "`i'"
			`cmd' `i' `newname'
			display as text "`i'" "  --->  " "`newname'"
		}
	}
end


