/*---------------------------
1Oct2010 - version 3.0

TABLE VL6 Models for Mortality Improvement. Quinquennial Gains in Life Expectancy
At Birth According to Intial Level of Life Expectancy

Author: Liu Wei, The School of Sociology and Population Studies, Renmin University of China
E-mail: liuv@ruc.edu.cn
---------------------------*/
capture prog drop elife
prog define elife
	version 9
	cap preserve
	clear all
	syntax anything [, Savename(string)]
	tokenize `anything'

	while "`4'"=="" | "`5'"!="" {
		di as result _n "Note: " as text "You must specify " as result "four " as txt "arguments! " as txt "- {stata help elife} - "
		exit
	}
	qui cap assert abs(`1'+`2'+`3'+`4')!=. 
	if _rc {
		di as result _n "Note: " as text "input must be numeric, try again please!"
		exit
	}
	while `1'<40 | `2'<40 {
		di as result _n "Note: life1 " as txt "and " as result "life2 " as txt "must be bigger than 40! " as txt "- {stata help elife} - "
		exit
	}
	while `3'>=`4' {
		di as result _n "Note: year1 " as txt "must be smaller than " as result "year2 " as txt "- {stata help elife} - "
		exit
	}

	sysuse elife // * important
	qui d
	local n=r(N)
	local i=`4'-`3'+1
	if `i'>`n' {
		qui set obs `i'
	}
	qui count
	local n2=r(N)
	qui egen year=fill(`3'(1)`4')

	local life1=`1'
	local n3=1
	forv id=1/`n2' {
		local Start=real(substr(initial_values[`id'],1,4))
		local End=real(substr(initial_values[`id'],6,4))
		while `life1'>=`Start' & `life1'<`End' & `n3'<=`n2'{
			qui replace vfpm=`life1' in `n3'
			local life1=`life1'+veryfast_male[`id']/5
			local n3=`n3'+1
		}
	}

	local life2=`2'
	local n3=1
	forv id=1/`n2' {
		local Start=real(substr(initial_values[`id'],1,4))
		local End=real(substr(initial_values[`id'],6,4))
		while `life2'>=`Start' & `life2'<`End' & `n3'<=`n2'{
			qui replace vfpf=`life2' in `n3'
			local life2=`life2'+veryfast_female[`id']/5	
			local n3=`n3'+1
		}
	}

	local life3=`1'
	local n3=1
	forv id=1/`n2' {
		local Start=real(substr(initial_values[`id'],1,4))
		local End=real(substr(initial_values[`id'],6,4))
		while `life3'>=`Start' & `life3'<`End' & `n3'<=`n2'{
			qui replace fpm=`life3' in `n3'
			local life3=`life3'+fast_male[`id']/5	
			local n3=`n3'+1
		}
	}

	local life4=`2'
	local n3=1
	forv id=1/`n2' {
		local Start=real(substr(initial_values[`id'],1,4))
		local End=real(substr(initial_values[`id'],6,4))
		while `life4'>=`Start' & `life4'<`End' & `n3'<=`n2'{
			qui replace fpf=`life4' in `n3'
			local life4=`life4'+fast_female[`id']/5	
			local n3=`n3'+1
		}
	}

	local life5=`1'
	local n3=1
	forv id=1/`n2' {
		local Start=real(substr(initial_values[`id'],1,4))
		local End=real(substr(initial_values[`id'],6,4))
		while `life5'>=`Start' & `life5'<`End' & `n3'<=`n2'{
			qui replace mpm=`life5' in `n3'
			local life5=`life5'+medium_male[`id']/5		
			local n3=`n3'+1
		}
	}

	local life6=`2'
	local n3=1
	forv id=1/`n2' {
		local Start=real(substr(initial_values[`id'],1,4))
		local End=real(substr(initial_values[`id'],6,4))
		while `life6'>=`Start' & `life6'<`End' & `n3'<=`n2'{
			qui replace mpf=`life6' in `n3'
			local life6=`life6'+medium_female[`id']/5
			local n3=`n3'+1
		}
	}

	local life7=`1'
	local n3=1
	forv id=1/`n2' {
		local Start=real(substr(initial_values[`id'],1,4))
		local End=real(substr(initial_values[`id'],6,4))
		while `life7'>=`Start' & `life7'<`End' & `n3'<=`n2'{
			qui replace spm=`life7' in `n3'
			local life7=`life7'+slow_male[`id']/5	
			local n3=`n3'+1
		}
	}

	local life8=`2'
	local n3=1
	forv id=1/`n2' {
		local Start=real(substr(initial_values[`id'],1,4))
		local End=real(substr(initial_values[`id'],6,4))
		while `life8'>=`Start' & `life8'<`End' & `n3'<=`n2'{
			qui replace spf=`life8' in `n3'
			local life8=`life8'+slow_female[`id']/5	
			local n3=`n3'+1
		}
	}

	local life9=`1'
	local n3=1
	forv id=1/`n2' {
		local Start=real(substr(initial_values[`id'],1,4))
		local End=real(substr(initial_values[`id'],6,4))
		while `life9'>=`Start' & `life9'<`End' & `n3'<=`n2'{
			qui replace vspm=`life9' in `n3'
			local life9=`life9'+veryslow_male[`id']/5
			local n3=`n3'+1
		}
	}
	
	local life10=`2'
	local n3=1
	forv id=1/`n2' {
		local Start=real(substr(initial_values[`id'],1,4))
		local End=real(substr(initial_values[`id'],6,4))
		while `life10'>=`Start' & `life10'<`End' & `n3'<=`n2'{
			qui replace vspf=`life10' in `n3'
			local life10=`life10'+veryslow_female[`id']/5	
			local n3=`n3'+1
		}
	}
	
	qui keep vfpm - year
	qui order year
	if `i'<=`n' {
		qui keep in 1/`i'
	}
	
	di as txt _n "	 Annual increments of life expectancy (`3'-`4')"
	list, noo
	if "`savename'"!= ""{
		qui save `savename'.dta,replace
		di as result _n "    Note: " as txt "The file " as result "`savename'.dta " as txt "has been saved in current directory " as result"`c(pwd)'`c(dirsep)' " as txt "{stata erase `savename'.dta: - Delete } " as result "OR " as txt " {stata use `savename'.dta:Use it? - }"	
	}
end
