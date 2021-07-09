*! version 1.4  22Jul2009 rosa gini


program define rewrite
	version 8.2
	syntax anything(id="file source" name=filesource) using/  [, append replace HTMl TEX NAMEMACRO(string) MACRO(string) ISDROP(string) NONEWLine]
	
if "`append'"!="" & "`replace'"!=""{
	di as error "You cannot specify both -append- and -replace- options."
	error 498
	}
if "`append'"=="" & "`replace'"==""{
	di as error "You must specify one of the two options -append- or -replace-."
	error 498
	}
local appendreplace=cond("`append'"=="","`replace'","`append'")
	
if "`namemacro'"!=""{
	capture confirm names `namemacro'
	if _rc!=0 |wordcount("`namemacro'")>1{
		di as error "-namemacro- option must be a valid local macro name"
		error 498
		}
	}

if `"`namemacro'"'!=""{
	local `namemacro' `"`macro'"'
	}
tempname target
tempname source
file open `target' using `"`using'"',write `appendreplace' text
file open `source' using `"`filesource'"' ,read text
// local i=1
file read `source'  stringa
while r(eof)==0{
	if "`html'"!=""{
		tohtmlloc `"`stringa'"'
		local stringa `"`r(stringhtm)'"'
		}
	if "`tex'"!=""{
		totexloc `"`stringa'"'
		local stringa `"`r(stringtex)'"'
		}
	if "`isdrop'"!="" & upper(word(`"`stringa'"',1))=="DROP"{
		tosqlloc `"`stringa'"' "`isdrop'"
		local stringa `"`r(stringsql)'"'
		}
	if "`nonewline'"==""{
		file write `target' `"`stringa'"' _n 
		}
	else{
		file write `target' `"`stringa' "'
		}
// 	local i=`i'+1
	file read `source'  stringa
	}
file close `source'
file close `target'

end

program define totexloc,rclass
	version 8.2
	args strnotex
	*local strnotex: subinstr local strnotex "\" "$\backslash$",all
	local strnotex: subinstr local strnotex "%" "\%",all
	local strnotex: subinstr local strnotex "$" "\$",all
	local strnotex: subinstr local strnotex "_" "\_",all
	if `"`strnotex'"'==""{
		local strnotex=""
		}
	return local stringtex `"`strnotex'"'
end


program define tohtmlloc,rclass
	version 8.2
	args strnohtm
	local strnohtm: subinstr local strnohtm "�" "&Agrave;",all
	local strnohtm: subinstr local strnohtm "�" "&Egrave;",all
	local strnohtm: subinstr local strnohtm "�" "&Igrave;",all
	local strnohtm: subinstr local strnohtm "�" "&Ograve;",all
	local strnohtm: subinstr local strnohtm "�" "&Ugrave;",all
	local strnohtm: subinstr local strnohtm "�" "&agrave;",all
	local strnohtm: subinstr local strnohtm "�" "&egrave;",all
	local strnohtm: subinstr local strnohtm "�" "&igrave;",all
	local strnohtm: subinstr local strnohtm "�" "&ograve;",all
	local strnohtm: subinstr local strnohtm "�" "&ugrave;",all
	local strnohtm: subinstr local strnohtm "�" "&Agrave;",all
	local strnohtm: subinstr local strnohtm "�" "&Eacute;",all
	local strnohtm: subinstr local strnohtm "�" "&Igrave;",all
	local strnohtm: subinstr local strnohtm "�" "&Ograve;",all
	local strnohtm: subinstr local strnohtm "�" "&Ugrave;",all
	local strnohtm: subinstr local strnohtm "�" "&agrave;",all
	local strnohtm: subinstr local strnohtm "�" "&eacute;",all
	local strnohtm: subinstr local strnohtm "�" "&igrave;",all
	local strnohtm: subinstr local strnohtm "�" "&ograve;",all
	local strnohtm: subinstr local strnohtm "�" "&ugrave;",all
	local strnohtm: subinstr local strnohtm "'" "&acute;",all
	local strnohtm: subinstr local strnohtm "�" "&acute;",all
	if `"`strnohtm'"'==""{
		local strnohtm="<br><br>"
		}
	return local stringhtm `"`strnohtm'"'
end

program define tosqlloc,rclass
	version 8.2
	args strnosql vardropname
	local nometabella=subinstr(word(`"`strnosql'"',3),";","",.)
	qui count if `vardropname'=="`nometabella'"
	if r(N)==0{
		local strnosql="-- "+`"`strnosql'"'
		local strnosql=`""'
		}
	return local stringsql `"`strnosql'"'
end
