*! Part of package matrixtools v. 0.24
*! Support: Niels Henrik Bruun, nhbr@ph.au.dk
program define strofnum
	version 12.1
	syntax varlist [, keep]
	
	quietly {
		foreach var of varlist `varlist' {
			mata: tostring("`var'", "__new_var")
			if `__new_var' {
				order `var', before(__`var')
				if "`keep'" == "" drop __`var'
			}
			else noisily display "{error:String version of `var' is not converted}"
			macro drop __new_var
		}
	}
end

mata:
	function tostring(string scalar varname, lclname)
	{
		real scalar vnbr
		string scalar vlbl
		real colvector x
		string colvector str_x
	
		if ( st_isnumvar(varname) ) {
			st_view(x, ., varname)
			if ( (vlbl=st_varvaluelabel(varname)) != "" ) {
				str_x = st_vlmap(vlbl, x)
			} else {
				str_x = strofreal(x, st_varformat(varname))
			}
			st_varrename(varname, "__" + varname)
			vnbr = stataversion() > 1300 ? st_addvar("strL", varname) : st_addvar("str244", varname)
			st_varlabel(varname, st_varlabel("__" + varname))
			st_sstore(., varname, str_x)
			st_varformat(varname, sprintf("%%-%fs", colmax(strlen(str_x))))
			st_local(lclname, "1")
		} else {
			st_local(lclname, "0")
		}
	}
end
