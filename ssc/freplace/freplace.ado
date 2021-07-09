/*---------------------------
28Jan2010 - version 2.0

Batch Convert ASCII text or binary patterns in files

Author: Liu Wei, The School of Sociology and Population Studies, Renmin University of China
E-mail: liuv@ruc.edu.cn
---------------------------*/
capture prog drop freplace
prog define freplace, rclass
	version 9
	syntax anything(name=clist), From(string) [To(string)]
	token `clist'
/*---------------------------------
Control the user's input -- begin 
----------------------------------*/
	while `"`2'"' !="" {
		di as result _n "Note: " as text "You can only specify one argument! " as txt "- {stata help freplace} - "
		exit 198
	}
/*---------------------------------
Control the user's input -- end 
---------------------------------*/
	_dirlist "`r(cmd)'"*."`clist'"
	local filenum1=r(nfiles)
	local filetime1=r(ftimes)
	local occurrences=0
	local bytes_from=0
	local bytes_to=0
	local biao=0
	local list: dir "`r(cmd)'" files"*.`clist'"
	foreach x of local list {
		qui cd "`r(cmd)'"
		capture mkdir tempfre
		local y1="tempfre\"+"`x'"
		capture copy "`x'" "`y1'", replace
		capture erase "`x'"
		if _rc!=608 {
			cap qui filefilter "`y1'" "`x'", from("`from'") to("`to'") replace
			while _rc==0 | _rc==602 {
				local occurrences=r(occurrences)+`occurrences'
				local bytes_from=r(bytes_from)
				local bytes_to=r(bytes_to)
				capture erase "`y1'"
				capture rmdir tempfre
			}
			while _rc==198 {
				local filenum1=`filenum1'-1
				capture copy "`y1'" "`x'", replace
				capture erase "`y1'"
				capture rmdir tempfre
				local biao=1
			}
		}
		else {
			local filenum1=`filenum1'-1
			capture erase "`y1'"
			capture rmdir tempfre
			di as result _n "Note: " as txt "File " as result "`x'" as txt "is read-only; cannot be modified or erased"
		}
	}		 
	_dirlist "`r(cmd)'"*."`clist'"
	local filetime2=r(ftimes)
	local filenum=0
	foreach z of local filetime1 {
		if "`filenum1'"!="0" & strpos("`filetime2'","`z'")==0 {
			local filenum=`filenum'+1
		}
	}
	return local occurrences `occurrences'
	return local bytes_from `bytes_from'
	return local bytes_to `bytes_to'
	if `occurrences'!=0 & `filenum'!=0 {
		di as txt _n "Totally " as result "`occurrences' " as txt "number of oldpattern has been found"
		di as txt "A total of " as result "`filenum' " as txt "files were replaced from " as result "`from' " as txt "to " as result "`to' " as txt "in current directory " as result"`c(pwd)'`c(dirsep)'"
	}
	else if `occurrences'!=0 & `filenum'==0 {
		di as txt _n "Totally " as result "`occurrences' " as txt "number of oldpattern has been found"
		di as txt "A total of " as result "`filenum1' " as txt "files were replaced from " as result "`from' " as txt "to " as result "`to' " as txt "in current directory " as result"`c(pwd)'`c(dirsep)'"
	}
	else if `occurrences'==0 & `biao'==1 {
		di as erro _n "Syntax erro: " as txt "Unresolved backslash escape sequence. Please use '\BS' to represent a backslash character. "
		di as result _n "No files replaced! "
	}
	else {
		di as result _n "No files replaced! " as txt "The oldpattern " as result "`from' "	as txt "or " as result "`clist' " as txt "format files has not been found, or " as result "`clist' " as txt "is not a supported file format"
	}
end

/*------------------------------------------
 *ripped from Morten Andersen's dirlist
 version 1.3.1
 Date: 2005-04-04
------------------------------------------*/
capture prog drop _dirlist
prog define _dirlist, rclass
	version 8
	syntax anything	
	tempfile dirlist
	if "`c(os)'" == "Windows" {	
		local shellcmd `"dir `anything' > `dirlist'"'
	}	
	if "`c(os)'" == "MacOSX" {	
		local anything = subinstr(`"`anything'"', `"""', "", .)	
		local shellcmd `"ls -lT `anything' > `dirlist'"'
	}		
	if "`c(os)'" == "Unix" {	
		local anything = subinstr(`"`anything'"', `"""', "", .)	
		local shellcmd `"ls -l --time-style='+%Y-%m-%d %H:%M:%S'"'
		local shellcmd `"`shellcmd' `anything' > `dirlist'"'		
	}
	quietly shell `shellcmd'
	* read directory data from temporary file	
	tempname fh	
	file open `fh' using "`dirlist'", text read
	file read `fh' line	
	local nfiles = 0
	local curdate = date("`c(current_date)'","dmy")
	local curyear = substr("`c(current_date)'",-4,4)	
	while r(eof)==0	{	
		if `"`line'"' ~= "" & substr(`"`line'"',1,1) ~= " " {
			* read name and data for each file
			if "`c(os)'" == "MacOSX" {				
				local fsize : word 5 of `line'
				local fda	 : word 6 of `line'
				local fmo	 : word 7 of `line'
				local ftime : word 8 of `line'
				local fyr	 : word 9 of `line'
				local fname : word 10 of `line'
				local fdate =	///
					string(date("`fmo' `fda' `fyr'","mdy"),"%dCY-N-D")								
			}
			if "`c(os)'" == "Unix" {				
				local fsize : word 5 of `line'
				local fdate : word 6 of `line'
				local ftime : word 7 of `line'
				local fname : word 8 of `line'							
			}
			if "`c(os)'" == "Windows" {			
				local fdate : word 1 of `line'
				local ftime : word 2 of `line'
				local word3 : word 3 of `line'				
				if upper("`word3'")=="AM" | upper("`word3'")=="PM" {
					local ftime "`ftime'-`word3'"
					local fsize : word 4 of `line'
					local fname : word 5 of `line'
				}
				else {
					local fsize : word 3 of `line'
					local fname : word 4 of `line'
				}	
			}
			local fnames "`fnames' `fname'"
			local fdates "`fdates' `fdate'"
			local ftimes "`ftimes' `ftime'"
			local fsizes "`fsizes' `fsize'"
			local nfiles = `nfiles' + 1
		}
		file read `fh' line	
	}	
	file close `fh'	
	return local fnames `fnames'
	return local fdates `fdates'
	return local ftimes `ftimes'
	return local fsizes `fsizes'
	return local nfiles `nfiles'	
end
