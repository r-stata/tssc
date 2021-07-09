*! version 1.0.0  20nov1996 STB-34 gr20
program define gphdt
	version 5.0

	chksave
			/* clear point vpoint vpoly arc	*/
			/* line vline box text vtext	*/
	local cmd "`1'"  
	mac shift

	GetCmd `cmd'
	local cmd "$S_1" 
	`cmd' `*'
end

program define point
	local y "`1'"
	local x "`2'"
	local size "`3'"
	local symbol "`4'"

	if "`size'" == "" {
		local size 275
	}
	if "`symbol'" == "" {
		local symbol 0
	}
	ChkNum `y' 
	ChkNum `x' 
	ChkNum `size' 0 20000 integer
	ChkNum `symbol' 0 6 integer
	
	local mapy = ($GPH_ay)*`y' + ($GPH_by)
	local mapx = ($GPH_ax)*`x' + ($GPH_bx)

	gph point `mapy' `mapx' `size' `symbol'
end

program define vpoint
	local varlist	"req ex min(2) max(4)"	
	local if	"opt"
	local in	"opt"
	local options	"SYmbol(integer 4) SIze(integer 275)"
	parse "`*'"

	parse "`varlist'", parse(" ")
	local y "`1'"
	local x "`2'"
	local si "`3'"
	local sy "`4'"

	ChkNumv , args(`y')
	ChkNumv , args(`x')
	if "`si'" != ""   { 
		ChkNumv `if' `in', args(`si' 0 .)
	}
	else {
		ChkNum `size' 0 .    
		local args "size(`size')"
	}
	if "`sy'" != "" { 
		ChkNumv `if' `in', args(`sy' 0 6 integer)
	}
	else {
		ChkNum `symbol' 0 6 integer
		local args "`args' symbol(`symbol')"
	}

	tempvar mapy mapx
	gen int `mapy' = ($GPH_ay)*`y' + ($GPH_by)
	gen int `mapx' = ($GPH_ax)*`x' + ($GPH_bx)

	gph vpoint `mapy' `mapx' `si' `sy' `if' `in' , `args'
end

program define vpoly
	local varlist	"req ex min(4)"	
	local if	"opt"
	local in	"opt"
	parse "`*'"

	local n : word count  `varlist'
	local i = int(`n'/2)*2

	if `i' != `n' { gpherr "Must be an even number of variables in vpoly"}

	local i = int(`n'/2)

	tempvar mapy1 mapx1 mapy2 mapx2

	local inarg: word 1 of `varlist'
	gen int `mapy1'=($GPH_ay)*`inarg' + ($GPH_by)
	local inarg: word 2 of `varlist'
	gen int `mapx1'=($GPH_ax)*`inarg' + ($GPH_bx)

	gen int `mapy2'=0
	gen int `mapx2'=0

	local k=3
	local j = 1
	while `j' < `i' {

		if `j' > 1 {
			replace `mapy1'=`mapy2'
			replace `mapx1'=`mapx2'
		}

		local inarg: word `k' of `varlist'
		local k=`k'+1
		replace `mapy2'=($GPH_ay)*`inarg' + ($GPH_by)
		local inarg: word `k' of `varlist'
		local k=`k'+1
		replace `mapx2'=($GPH_ax)*`inarg' + ($GPH_bx)

		gph vpoly `mapy1' `mapx1' `mapy2' `mapx2' `if' `in'

		local j=`j'+1

	}

end

program define arc
	
	local y "`1'"
	local x "`2'"
	local rad "`3'"
	local ang1 "`4'"
	local ang2 "`5'"
	local shade "`6'"

	ChkNum `y' 
	ChkNum `x' 
	ChkNum `rad'
	ChkNum `ang1'
	ChkNum `ang2'
	ChkNum `shade' 0 4 integer

	local mapy=($GPH_ay)*`y' +($GPH_by)
	local mapx=($GPH_ax)*`x' +($GPH_bx)
	local rad=($GPH_ax)*`rad'
	local ang1=mod(`ang1',360)
	if `ang1' < 0 { local ang1=360+`ang1' }
	local ang1=32767*`ang1'/360
	local ang2=mod(`ang2',360)
	if `ang2' < 0 { local ang2=360+`ang2' }
	local ang2=32767*`ang2'/360

	gph arc `mapy' `mapx' `rad' `ang1' `ang2' `shade'

end

program define line
	local y1 "`1'"
	local x1 "`2'"
	local y2 "`3'"
	local x2 "`4'"

	ChkNum `y1' 
	ChkNum `x1' 
	ChkNum `y2' 
	ChkNum `x2' 

	local mapy1 = ($GPH_ay)*`y1' + ($GPH_by)
	local mapx1 = ($GPH_ax)*`x1' + ($GPH_bx)
	local mapy2 = ($GPH_ay)*`y2' + ($GPH_by)
	local mapx2 = ($GPH_ax)*`x2' + ($GPH_bx)

	gph line `mapy1' `mapx1' `mapy2' `mapx2'
end

program define vline
	local varlist	"req ex min(2) max(2)"	
	local if	"opt"
	local in	"opt"
	parse "`*'"

	parse "`varlist'", parse(" ")
	local y "`1'"
	local x "`2'"

	ChkNumv , args(`y')
	ChkNumv , args(`x')

	tempvar mapy mapx
	gen int `mapy' = ($GPH_ay)*`y' + ($GPH_by)
	gen int `mapx' = ($GPH_ax)*`x' + ($GPH_bx)

	gph vline `mapy' `mapx' `if' `in'
end


program define box
	local y1 "`1'"
	local x1 "`2'"
	local y2 "`3'"
	local x2 "`4'"
	local shade "`5'"

	if "`shade'" == "" {
		local shade 4
	}
	ChkNum `y1' 
	ChkNum `x1' 
	ChkNum `y2' 
	ChkNum `x2' 

	ChkNum `shade' 0 5 integer
	

	local mapy1 = ($GPH_ay)*`y1' + ($GPH_by)
	local mapx1 = ($GPH_ax)*`x1' + ($GPH_bx)
	local mapy2 = ($GPH_ay)*`y2' + ($GPH_by)
	local mapx2 = ($GPH_ax)*`x2' + ($GPH_bx)

	if `shade'==5 {
		gph line `mapy1' `mapx1' `mapy2' `mapx1'
		gph line `mapy2' `mapx1' `mapy2' `mapx2'
		gph line `mapy2' `mapx2' `mapy1' `mapx2'
		gph line `mapy1' `mapx2' `mapy1' `mapx1'
	}
	else{
		gph box `mapy1' `mapx1' `mapy2' `mapx2' `shade'
	}

end

program define clear
	local y1 "`1'"
	local x1 "`2'"
	local y2 "`3'"
	local x2 "`4'"

	ChkNum `y1' 
	ChkNum `x1' 
	ChkNum `y2' 
	ChkNum `x2' 

	local mapy1 = ($GPH_ay)*`y1' + ($GPH_by)
	local mapx1 = ($GPH_ax)*`x1' + ($GPH_bx)
	local mapy2 = ($GPH_ay)*`y2' + ($GPH_by)
	local mapx2 = ($GPH_ax)*`x2' + ($GPH_bx)

	gph clear `mapy1' `mapx1' `mapy2' `mapx2'

end

program define text
	local y "`1'"
	local x "`2'"
	local rot "`3'"
	local align "`4'"

	local i 5
	while "``i''" != "" {
		local txt "`txt' ``i''"
		local i = `i'+1
	}

	if "`rot'" == "" {
		local rot = 0
	}
	if "`align'" == "" {
		local align = 0
	}
	ChkNum `y' 
	ChkNum `x' 
	ChkNum `rot' 0 1 integer
	ChkNum `align' -1 1 integer
	
	local mapy = ($GPH_ay)*`y' + ($GPH_by)
	local mapx = ($GPH_ax)*`x' + ($GPH_bx)

	gph text `mapy' `mapx' `rot' `align' `txt'
end

program define vtext
	local varlist	"req ex min(3) max(3)"	
	local if	"opt"
	local in	"opt"
	parse "`*'"

	parse "`varlist'", parse(" ")
	local y "`1'"
	local x "`2'"
	local txt "`3'"

	ChkNumv , args(`y')
	ChkNumv , args(`x')
	ChkNumv , args(`txt')

	tempvar mapy mapx
	gen int `mapy' = ($GPH_ay)*`y' + ($GPH_by)
	gen int `mapx' = ($GPH_ax)*`x' + ($GPH_bx)

	gph vtext `mapy' `mapx' `txt' `if' `in'
end

program define GetCmd
			/* Point VPOInt VPOLy Arc	*/
			/* Line VLine Box Text VText	*/
	local cmd "`1'"

	local l = length("`cmd'")

	if "`cmd'" == substr("point",1,max(`l',1))       { global S_1 "point" }
	else if "`cmd'" == substr("vpoint",1,max(`l',4)) { global S_1 "vpoint"}
	else if "`cmd'" == substr("clear",1,max(`l',1))  { global S_1 "clear"}
	else if "`cmd'" == substr("vpoly",1,max(`l',4))  { global S_1 "vpoly" }
	else if "`cmd'" == substr("arc",1,max(`l',1))    { global S_1 "arc"   }
	else if "`cmd'" == substr("line",1,max(`l',1))   { global S_1 "line"  }
	else if "`cmd'" == substr("vline",1,max(`l',2))  { global S_1 "vline" }
	else if "`cmd'" == substr("box",1,max(`l',1))    { global S_1 "box"   }
	else if "`cmd'" == substr("text",1,max(`l',1))   { global S_1 "text"  }
	else if "`cmd'" == substr("vtext",1,max(`l',2))  { global S_1 "vtext" }
	else {
		capture gph close
		noi di in red "unknown gphdt command: `cmd'"
		exit 198
	}
end
	
	
program define chksave
	capture {
		confirm number $GPH_ax
		confirm number $GPH_bx
		confirm number $GPH_ay
		confirm number $GPH_by
	}
	if _rc {
		capture gph close
		noi di in red "graphics conversion parameters were not saved"
		exit 198
	}
end

program define ChkNum
	local num "`1'"
	local min "`2'"
	local max "`3'"
	local typ "`4'"

	capture confirm number `num'
	if _rc { gpherr "argument was not a number" }

	if "`min'" != "" {
		if `num' < `min' | `num' > `max' {
			gpherr "argument out of range"
		}
	}

	if "`typ'" != "" {
		capture confirm `typ' number `num'
		if _rc { gpherr "argument `num' should be of type `typ'" }
	}
end

program define ChkNumv
	local if	"opt"
	local in	"opt"
	local options	"args(string)"
	parse "`*'"

	local num : word 1 of `args'
	local min : word 2 of `args'
	local max : word 3 of `args'
	local typ : word 4 of `args'

	capture confirm variable `num'
	if _rc { gpherr "argument `num' was not a numeric variable" }

	if "`min'" != "" {
		summ `num' `if' `in'
		if _result(5) < `min' | _result(6) > `max' {
			gpherr "argument `num' has values out of range"
		}
	}

	if "`typ'" != "" {
		tempvar r
		gen `r' = int(`num') `if' `in'
		capture assert `num'==`r' `if' `in'
		if _rc { gpherr "argument `num' should have `typ' values" }
	}
end

program define gpherr
	local mesg "`1'"
	capture gph close
	noi di in red "`mesg'"
	exit 198
end
