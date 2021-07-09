*******************************
**         IF IN ADO         **
**        Version 1.0        **
**     by Ari Friedman       **
**   abfriedman@gmail.com    **
**      Jan. 27, 2008        **
*******************************

*! Version 1.0.0

/*-------------------------------------------------------------------------------------------------
This ado file generates an if statement containing all the terms in the local.
-------------------------------------------------------------------------------------------------*/

* andor should be either "&" or "|" depending on what you want
**defaults to |

* Returns list as s(ifin)

cap program drop ifin
program define ifin, sclass
version 9
syntax anything, variable(string) [and] [omitif] [quote]

if "`and'" == "" {
	local andor "|"
}
else if "`and'" == "and" {
	local andor "&"
}

//Check varlist is only one variable long
local wc: word count `variable'
if `wc' != 1 {
	di in red "variable option should only include one variable"
	error
}

//Quote values if specified
if "`quote'" == "quote" {
	local q = `"""'
}

foreach val of local anything {
	local iflist `"`iflist' `andor' `variable' == `q'`val'`q'"'
}
local iflist = substr(`"`iflist'"',3,.)  //chomp the first |

if "`omitif'" != "omitif" {
	local iflist `"if `iflist'"'
}

sreturn local ifin `iflist'

end


