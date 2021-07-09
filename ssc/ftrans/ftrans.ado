/*---------------------------
28Jan2010 - version 2.0

Batch File Format Converter

Author: Liu Wei, The School of Sociology and Population Studies, Renmin University of China
E-mail: liuv@ruc.edu.cn
---------------------------*/
capture prog drop ftrans
prog define ftrans
	version 10.0
	syntax anything(name=clist)
	token `clist'
/*---------------------------------
Control the user's input -- begin 
----------------------------------*/
	while "`1'"=="`2'" {
		di as result _n "Note: " as text "You must specify two different arguments! " as txt "- {stata help ftrans} - "
		exit
	}
/*---------------------------------
Control the user's input -- end 
---------------------------------*/
	_dirlist "`r(cmd)'"*."`2'"
	local filenum1=r(nfiles)
	local filetime1=r(ftimes)
	local list: dir "`r(cmd)'" files"*.`1'"
	foreach x of local list {
		qui cd "`r(cmd)'"
		local y=subinstr("`x'",".`1'",".`2'", .)
		qui _stcmd "`x'" "`y'" "`3'" "`4'" "`5'" "`6'" "`7'" "`8'" "`9'" "`10'" "`11'" "`12'"
	}
	_dirlist "`r(cmd)'"*."`2'"
	local filenum2=r(nfiles)
	local filetime2=r(ftimes)
	local filenum=`filenum2'-`filenum1'
	foreach z of local filetime1 {
		if "`filenum1'"!="0" & strpos("`filetime2'","`z'")==0 {
		local filenum=`filenum'+1
	}
	}
	if `filenum'>0 {
		di as txt _n "A total of " as result "`filenum' " as txt "files were converted from " as result "`1' " as txt "format to " as result "`2' " as txt "format in current directory " as result"`c(pwd)'`c(dirsep)'"
	}
	else if `filenum'<=0 & `filenum2'==0 {
		di as result _n "No files converted! " as txt "There's no " as result "`1' " as txt "format files in current directory, or " as result "`2' " as txt "is not a supported file format "
	}
	else {
		di as result _n "No files converted! " as txt "Or files were converted less than 60 seconds before "
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

/*------------------------------------------
 *ripped from Roger Newson's stcmd
 Date: 2008-08-06
------------------------------------------*/
cap prog drop _stcmd
prog def _stcmd
	version 9.0
	local stpath `"$StatTransfer_path"'
	if `"`stpath'"'=="" {
		local stpath "st"
	}
	local stcommand `""`stpath'" `0'"'
	disp as text "Stat/Transfer command submitted:" _n as result `"`stcommand'"'
	shell `stcommand' 
end
