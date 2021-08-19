*===============================================================================
* Program: readwind.ado
* Purpose: Reading data download from the wind into stata in a cleaning format
* Version: 3.0 (2021/05/19)
* Author:  Hongbing Zhu
* Website: http://www.github.com/zhbsis/readWind
*===============================================================================


capture program drop readwind
program define readwind
	version 14.0
	syntax namelist(min=1), key(str) timeType(str) t0(str) tn(str) [type(str) sheet(integer 1) encoding(str) tostring]	

	//1 readfile
	local n=wordcount("`namelist'")
	readfile, key(`key') type(`type') sheet(`sheet') encoding(`encoding') `tostring'
	
	//2 tokenize
	local var ""
	foreach tempVar of varlist _all{
		local var "`var' `tempVar'"         // 
	}
	tokenize `var'                          // 
	local first `1' `2'                     // 
	macro shift 2                           // 
	local rest `*'                          // 

	/*rename stkcd comp*/
	rename (`first') (stkcd comp)

	local i=1
	foreach var in `rest'{
		rename `var' x`i'
		local i=`i'+1
	}

	
	fpe long x, i(stkcd) j(time)   // fpe is developed by Michael Droste, and we are very grateful for this fundamental work.
			
	//3 if function
	gen date=.
	gen var=.

	if("`timeType'"=="y"){
		local t0=`t0'
		local tn=`tn'
		local dif = `tn'-`t0'+1
	}
	if("`timeType'"=="q"){
		local t0=q(`t0')
		local tn=q(`tn')
		local dif = `tn'-`t0'+1	
	}
	if("`timeType'"=="m"){
		local t0=m(`t0')
		local tn=m(`tn')
		local dif = `tn'-`t0'+1	
	}	
	if("`timeType'"=="d"){
		local t0=date("`t0'","YMD")
		local tn=date("`tn'","YMD")
		local dif = `tn'-`t0'+1
	}
	
	//4 main function
	forvalues i=1(1)`n'{
		local low = 1+(`i'-1)*`dif'
		local up  = `dif'+(`i'-1)*`dif'
		
		local j=`i'-1
		qui bys stkcd: replace date = `t0' + _n - 1 - `j'*`dif' if time <= `up' & time >= `low'
		qui replace var=`i'  if time <= `up' & time >= `low'	
	}
	
	//5 format time index
	if("`timeType'"=="q"){
		format date %tq
	}
	if("`timeType'"=="m"){
		format date %tm
	}
	if("`timeType'"=="d"){
		format date %td
	}
	
	//6 reshape and cleaning
	qui drop if stkcd=="" | stkcd=="数据来源：Wind"
	qui gen stkcd_date=stkcd+"_"+string(date)
	qui fpe wide x, i(stkcd_date) j(var)
	qui drop time stkcd_date
	qui order stkcd comp date
	
	//7 rename
	local i=1
	foreach var in `namelist'{
		qui rename x`i' `var'
		local i=`i'+1
		qui label var `var' ""
	}
end	