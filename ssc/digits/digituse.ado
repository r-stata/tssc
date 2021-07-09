*! version 1.00 copyright Richard J. Atkins 2005

* version 1.01 now validates varlist length

program define digituse

	version 7.0
	syntax varlist(min=1 max=1) [,PLAces(integer 9)]

	tempvar asstring

	qui summ `varlist'
	local count=r(N)
	local leftplaces=int(log10(r(max)))
	local rightplaces=`places'
	local hasdp=0
	if (0<`rightplaces') { local hasdp=1 }
	local strchars = `leftplaces'+`rightplaces'+`hasdp'+1
	local useformat = "%0" + string(`strchars') + "." + string(`rightplaces') + "f"
	qui gen str`strchars' `asstring' = ""
	qui replace `asstring'=string(`varlist', "`useformat'") if(.!=`varlist')

	forvalues l2=0(1)9 {
		local linename="output`l2'"
		local `linename' = "|"
	}
	local outputtop="|"
	forvalues loop=`leftplaces'(-1)-`rightplaces' {
		if (`loop'<0) {
			local index=`leftplaces'-`loop'+2
		}
		else {
			local index=`leftplaces'-`loop'+1
		}
		local outputtop="`outputtop'" + substr("     "+string(`loop'),-4,.)
		local output=""
		forvalues l2=0(1)9 {

	
			qui tab `asstring' if(substr(`asstring',`index',1)=="`l2'")
			local linename="output`l2'"
			if (0==r(N)) {
				local `linename'= "``linename''   ." 
			}
			else {
				local `linename'= "``linename''" + substr("     "+string(r(N)/`count'*100, "%3.0f"),-4,.)
			}
		}
	}

	local outputline="{dup "+string(1+(`leftplaces'+`rightplaces'+1)*4)+":{c -}}"
	noi di in gr "{dup 7:{c -}}{c TT}`outputline'"
	noi di in gr " Digit" _col(8) "{c |} Position (10^)"
	noi di in gr _col(8) "{c |} " substr("`outputtop'",2,.)
	noi di in gr "{dup 7:{c -}}{c +}`outputline'"
	forvalues l2=0(1)9 {
		local linename="output`l2'"
		noi di in gr "   `l2'" _col(8) "{c |} " in ye substr("``linename''",2,.)
	}
	noi di in gr "{dup 7:{c -}}{c BT}`outputline'"
end

