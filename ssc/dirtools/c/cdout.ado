*! cdout 1.0.1 Apr2009 by roywada@hotmail.com
*! opens the current directory for your viewing pleasure

program define cdout
cap version 7.0

cap winexec cmd /c start .
*cap !start cmd /c start .

if _rc~=0 {
	* version 6 or earlier
	di `"{stata `"cdout"':cdout}"'
}
else {
	* invisible to Stata 7
	local Version7
	local Version7 `c(stata_version)'
	
	if "`Version7'"=="" {
		* it is version 7 or earlier
		di `"{stata `"cdout"':cdout}"'
	}
	else if `Version7'>=8.0 {
		version 8.0
		di `"{browse `"`c(pwd)'"'}"'
	}
}

end

/* cdout 1.0.0 Apr2009 published
cdout 1.0.1 May2009 bound with Uli's stuff
