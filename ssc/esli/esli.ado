*! v 1.0.0 N.Orsini 25Nov2005

capture program drop esli 
program esli, rclass
version 8.2
syntax , p1(string) p2(string)  [ * ] 

tempname y1 x1 y2 x2 int slope

if "`p1'" == "" {
	di in red "specify y1 x1"
	exit 198
}   
else {
	tokenize "`p1'"
	confirm number `1'
	confirm number `2'

	scalar `y1' = `1'
	scalar `x1' = `2'
}

if "`p2'" == "" {
	di in red "specify y2 x2"	
	exit 198
}   
else {
	tokenize "`p2'"
	confirm number `1'
	confirm number `2'

	scalar `y2' = `1'
	scalar `x2' = `2'
}

if `y2' == `y1' & `x2' == `x1' & `y2'==`y1' {
di as err "specify two different points"
exit 198
}

// Equation straigth line 

if `y2' != `y1' & `x2' != `x1' {
scalar `slope' = (`y2'-`y1')/(`x2'-`x1')
scalar `int' = `slope'*-`x2' + `y2'
if `slope' > 0 {
			di in g "y = " `int' "+" `slope' "*x"
			local function : di  "y = " `int' "+" `slope' "*x"
}
else {
			di in g "y = " `int'   `slope' "*x"
			local function : di "y = " `int' `slope' "*x"
}
return scalar beta = `slope'
}

if `y2' == `y1'   {
scalar `int' =  `y2'
di in g "y = " `int'  
local function : di "y = " `int' 
}

if `x2' == `x1'   {
scalar `int' =  `x2'
di in g "x = " `int'  
}
return scalar alpha = `int'
return local equation  = "`function'"
return local cmd = "esli"
end

 
