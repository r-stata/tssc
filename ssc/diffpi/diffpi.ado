*! 1.0 N.Orsini 19 Jan 2005

program diffpi, rclass
version 8
syntax anything [, Format(string)  ]

return clear

tempname x

scalar `x' = abs( (`2'-`1')/(`1'/100))

if "`format'" == "" {
local format = "%3.2f"
}   
else {
local format = "`format'"
}


if `1' > `2' {
		 di _col(5) as res "-" `format' `x' "%"
	  	 local r = - `x'
	}

if `1' < `2' {
		 di _col(5)  as res "+"  `format' `x' "%"
	  	 local r =  `x'
		}
		
if `1' == `2' {
	  	 local r =  0
		 di _col(5)  as res `format' `r' "%"
		}

return scalar rdiff = `r'
return local cmd = "diffpi"
end





