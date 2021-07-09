*! rflsetmenu.ado version 3.6, 29 Nov 2005, Dankwart Plattner,  dankwart.plattner@web.de

program rflsetmenu
version 8.2

args recentno rewritemenu dtanum mi1 mi2 mi3 mi4 mi5 mi6 mi7 mi8 mi9 mi10 mi11 mi12 mi13 mi14 mi15 mi16 mi17 mi18 mi19 mi20 mi21 mi22 mi23 mi24 mi25 mi26 mi27 mi28 mi29 mi30

local calledfromcomwindow = missing("`recentno'") & missing("`dtanum'") & missing("`rewritemenu'")
if `calledfromcomwindow' == 1 {
	// if rflsetmenu is called from the command window, and $rfl_SETMENU is not missing, a second rfl item will be placed in the User menu
	quietly capture confirm file `"`:sysdir PERSONAL'rfl.log"'
	if _rc ~= 0 {
		capture window stopbox stop "rfl.log not found. At least one dataset should have been opened with rfl for rflsetmenu to work as desired. Type rfl into the command window."
		exit
	}
	tempname rfllog
	file open `rfllog' using `"`:sysdir PERSONAL'rfl.log"', read text
	forvalues i = 1(1)2 {
		file read `rfllog' line
	}
	local hidemenu `line'
	file read `rfllog' line
	local rewritemenu `line'
	file read `rfllog' line
	local recentno `line'
	forvalues i = 5(1)16 {
		file read `rfllog' line
	}
	forvalues i = 1(1)`recentno' {
		if r(eof) == 0 {
			local dtanum = `dtanum' + 1
			forvalues j = 2(1)3 {
				file read `rfllog' line
			}
			local mi`dtanum' `line'
			forvalues j = 4(1)16 {
				file read `rfllog' line
			}
		}
	}
	file close `rfllog'
}

if `rewritemenu' == 1 {
	global rfl_SETMENU 1
	window menu clear
}

if `calledfromcomwindow' == 1 {
	if missing("$rfl_SETMENU") {
		global rfl_SETMENU 1
	}
	else {
		if $rfl_SETMENU == 0 {
			global rfl_SETMENU 1
		}
		else if $rfl_SETMENU ~= 1 {
			// Most probably, rfl's menu has already been added to the User menu
			disp "rfl's menu cannot presently be added to the Stata's User menu. Please delete any User menu items and set the global macro rfl_SETMENU to 1."
		}
	}
}

if $rfl_SETMENU == 1 {
	window menu append separator "stUser"
	window menu append submenu "stUser" "&rfl..."
	window menu append item "rfl..." "&rfl (dialog)" "rfl"
	window menu append separator "rfl..."
	global rfl_SETMENU_no = min(`recentno', `dtanum')
	forvalues i=1(1)$rfl_SETMENU_no {
		if ~ missing(`"`mi`i''"') {
			window menu append item "rfl..." `"&`i' `mi`i''"' `"rfluse `mi`i'', from(rfl.menu)"'
		}
	}
	if $rfl_SETMENU_no > 0 & `rewritemenu' == 0 {
		window menu append separator "rfl..."
	}
	window menu refresh
	if ~ missing("`hidemenu'") {
		if `hidemenu' == 1 {
			global rfl_SETMENU 0
		}
		else {
			global rfl_SETMENU 2
		}
	}
	else {
		global rfl_SETMENU 2
	}
}

end

