*! 1.2.0 NJC 21 Sept 2016 
* 1.1.0 NJC 16 August 2012 
* 1.0.0 NJC 5 May 2003 
program myticks 
	version 8 
	syntax anything(name=values),  Local(str) [MYscale(str asis)] 

	capture numlist "`values'" 
	if _rc == 0 local values "`r(numlist)'" 

	if `"`myscale'"' == "" local myscale "@" 
	else if !index(`"`myscale'"',"@") { 
		di as err "myscale() does not contain @"
		exit 198 
	} 	
	
	foreach v of local values { 
		local val : subinstr local myscale "@" "(`v')", all 
		local val : di %18.0g `val' 
		local myticks "`myticks' `val'" 
	} 

	di as res "{p}`myticks'" 
	c_local `local' "`myticks'" 
end 	
		
