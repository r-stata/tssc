capture program drop printgph
program define printgph

	gettoken flspc 0 : 0, parse(",")
	local flspc = trim(`"`flspc'"')
	if `"`flspc'"' == "" { 
		local flspc "*.gph"
	}
	else if `"`flspc'"' == "," { /* retreat */
		local 0 ", `0'"
		local flspc "*.gph"
	}
	else if !index(`"`flspc'"',".gph") {
		local flspc `"`flspc'.gph"'
	}

	syntax [,MOre STamp THIcknes(string) noPRint DEBug]
	local dir : pwd


	if "`stamp'" ~= "" {
		local cmd `"gph open|gph text 0 0  0 -1 $S_DATE |gph text 0 6000  0 -1 @|gph text 22500 0  0 -1 `dir'|graph using "@" |gph close"'
	}
	else {
		local cmd `"graph using "@""'
	}

	if "`print'" == "" {
		local cmd `"`cmd'|gphprint , thickness("444444444") nologo"'
	}
	
	if "`debug'" ~=  "" {di `"`cmd'"'}

forfile `flspc', `more' cmd(`"`cmd'"')
end


