* LEK
*! version 1.0.0  23August 23, 2006 @ 13:37:36
capture program drop grexport
program grexport , 
   version 9
   syntax [, Wide NOrestore saving(string asis) List replace ]

// Error Messages
	quietly graph dir
	if r(list)!="Graph " {
		disp as error "Program only works with one graph in memory"
      disp as error  _n "For more details, see {help grexport:on-line help for grexport}."
		error 498
		}
if (`"`list'"'=="")&(`"`saving'"'=="")&("`norestore'"!="norestore") {
    disp as error "You must specify at least one of the three options:"
    disp as error  "list, saving() and norestore."
    disp as error  _n " - If you specify list, then the values are listed."
    disp as error  " - If you specify saving(), then values are exported to a new data set."
    disp as error  " - If you specify norestore, then the new data set is created in the memory."
    disp as error  _n "For more details, see {help grexport:on-line help for grexport}."
    error 498
}

	if ("`replace'"!="") & (`"`saving'"'=="") {
		disp as error "Replace is senseless without the saving() option."
      disp as error  _n "For more details, see {help grexport:on-line help for grexport}."
    error 498
}
	
// Initialize

	if "`norestore'" == "" {
		preserve
		}

	drop _all
	tempfile grexport
	
// Collecting informations on the graph currently in use

	foreach set of numlist 0(1)10 {
		capture serset set `set'
		if _rc == 0 {
			serset use , clear
			gen set = `set'
			if `set' > 0 {
				quietly capture append using "`grexport'"
				}
			quietly save `grexport' , replace
			}
		}
	erase `grexport'

// Options
	
	if "`wide'" != "" {
		quietly by set , sort : gen n = _n
		quietly ds set n , not
		quietly reshape wide "`r(varlist)'" , i(n) j(set)
		}
	if "`list'" !="" {
		list , noobs
		}
	
		if "`saving'" != "" {
		save "`saving'" , `replace'
		}
	
		if "`norestore'" == "" {
		restore
		}
end
