*! version 0.4 Juni 12, 2014 @ 07:24:09
*! Clickable list of .ado and .sthlp files

* 0.1 Initial version
* 0.2 Editing ado-files did not work. Fixed
* 0.3 Allow to overwrite global adodir
* 0.4 User string is search pattern
* 0.5 Make setting of own editor easier for Unix

program lado, rclass
version 10.0

syntax [anything] [, Erase]

	if "$MYEDITOR" == "" local open doedit
	else {								
		local open $MYEDITOR
		if c(os)=="Unix" local back ">& /dev/null &"
	}

gettoken wd namelist:anything, parse(".")

local ADODIR = ///
  `"`=cond(`"`wd'"'==`"."',`"."',cond(`"$ADODEVELOPMENT"'==`""',`"."',`"$ADODEVELOPMENT"'))'"'
if `"`wd'"' != `"."' local namelist `anything'

local names: dir `"`ADODIR'"' files "*`namelist'*.ado"
local names: list sort names
local cleannames: subinstr local names `".ado"' `""', all

foreach name of local cleannames {
	if "`erase'" != "" 					/// 
	  local eitem `"[{stata `"erase "`ADODIR'/`name'.ado""':{err}erase}]"'
	capture confirm file `ADODIR'/`name'.sthlp
	if !_rc local helpfile `name'.sthlp
	else {
		capture confirm file `ADODIR'/`name'.hlp
		if !_rc local helpfile `name'.hlp
		else local helpfile `""'
	}
	
	
	if `"`helpfile'"' == `""' {
		local helpline ----
		local edhlpline -----
	}
	else {
		local helpline `"{stata `"help "`name'""':help}"'
		local edhlpline `"{stata `"`open'"`ADODIR'/`helpfile'" `back'"':edhlp}"'
	}

	display 							///  
	  `"{txt}`eitem'"' 	///  
	  `" [{stata `"view "`ADODIR'/`name'.ado""':view}]"'   ///
	  `" [{stata `"`open' "`ADODIR'/`name'.ado" `back'"':edit}]"' ///
	  `" [`helpline']"'   ///
	  `" [`edhlpline']"' ///
	  `" {res} `name'.ado "'
}

display _n `"{txt}Click [{stata `"ldir"':here}] for other links"'

return local files `"`names'"'


end

exit

Author: Ulrich Kohler
	Tel +49 (0)30 25491 361
	Fax +49 (0)30 25491 360
	Email kohler@wzb.eu


