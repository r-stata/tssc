*! version 0.3 Januar 31, 2013 @ 10:25:26 UK
*! Clickable list of .dta files

* 0.1 Initial version
* 0.2 Allow filename stub, rclass type
* 0.3 User string is search pattern
program lall, rclass
version 10.0

syntax [name] [, Erase]


display _n `"{txt}{title:Data files}"' _n
ldta `namelist', `erase'
return local dtafiles `"`r(files)'"'

display _n `"{txt}{title:Do-files}"' _n
ldo `namelist', `erase' 
return local dofiles `"`r(files)'"'

display _n `"{txt}{title:Graphs}"' _n
lgph `namelist', `erase'
return local gphfiles `"`r(files)'"'

display _n `"{txt}{title:SMCL-files}"' _n
lsmcl `namelist', `erase'
return local smclfiles `"`r(files)'"'

end

exit

Author: Ulrich Kohler
	Tel +49 (0)30 25491 361
	Fax +49 (0)30 25491 360
	Email kohler@wzb.eu



