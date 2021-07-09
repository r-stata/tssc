*! grtext version 1.0  09jun2015
*! Svend Juul
program define grtext , rclass
	version 14
	syntax name(name=B16 local id="Hexadecimal number")

	local B16 = upper("`B16'")
	if substr("`B16'",1,2) == "0X" | substr("`B16'",1,2) == "U+" {
		local B16  = substr("`B16'",3,.)
	}
	local L = length("`B16'") 
	
	local B10 = 0
	forvalues I = 1/`L' { 
		local C = substr("`B16'",`I',1)
		if "`C'" < "0" | ("`C'" > "9" & "`C'" < "A") | "`C'" > "F" {
			display as err `"grtext:  Illegal character "`C'"."'
			display as err "Valid characters: 0-9, a-f, and A-F."
			exit 198
		}
		else if "`C'" > "9" {
			local C = strpos("ABCDEF","`C'") + 9
		}
		local B10 = `B10' + 16^(`L'-`I')*`C'
	}

	local B10 : display %04.0f `B10'
	display as res "Hex: `B16'       Dec: `B10'       uchar(`B10') = " uchar(`B10')
	return scalar b10 = `B10'
	return local char `=uchar(`B10')'

end
