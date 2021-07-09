*! clickout 1.0.0 14May2009 roywada@hotmail.com with kohler@wzb.eu
*! produces a list of clickable files for your clicking pleasure

prog define clickout

version 8.0

syntax [anything] [using/]

if `"`anything'"'=="" {
	local anything "*"
}

if `"`using'"'~="" {
	local name: dir `"`using'"' files "*.`anything'"	
}
else {
	local name: dir `"`c(pwd)'"' files "*.`anything'"
}

tokenize `"`name'"'
local num 1
while `"``num''"'~="" {
	local cl_text `"{browse `"``num''"'}"'
	noi di as txt `"`cl_text'"'
	local num=`num'+1
}
end
