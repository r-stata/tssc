*version 1.7
*Jack Jerome
*2015.12.30
program define tabex
version 13
syntax [varlist] [if] [using/] , [reset] [cname(string)]
tokenize `varlist'

*not specifying a variable specifies all variables so use `3' here as a proxy for no variables specified
if "`3'" != "" & "`reset'" != "" {
	global count = 0
	display "tabex counter has been reset" 
		exit
}
*return error if 0 or >2 variables are specified and reset option is not included
if "`3'" != "" & "`reset'" == "" {
	di as err ///
				"{p}specify up to two variables, or use [,reset] option to reset tabex; " ///
				"{p_end}" 
				exit 198
}
*return error if a variable to sum is included but it is not numeric
if "`2'" != ""{ capture confirm numeric var `2' 
			if _rc { 
				di as err ///
				"{p}second variable is not numeric; " ///
				"cannot sum{p_end}" 
				exit 7 
			}
			}
*
*Increase global count by 1 for each use of tabex command
global count = $count + 1

*map capital letter to numbers for use in putexcel later
if $count <51 {
loc cn A C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY 
	
	loc choice = $count
	loc which : word `choice' of `cn'
	local col = "`which'"
		}
*
else
if $count >=51 {
di as err	"{p}You have reached the maximum number of tabex (50).  Use the [,reset] option to start a new set and don't forget to change or rename your output file!" ///
					"{p_end}" 
		exit 198
}
if "`cname'" == "" local cname "`col'"
*display "`col'"  //just for testing
*display `"`using'"' //just for testing
if `"`using'"' == `""' local using tabex.xlsx
*display `"`using'"' //just for testing
*display "`cname'"  //just for testing

*if a second variable is not specified, do a freq (basic tab) by `1' based on `if'
if "`2'"==""{
tempvar col_tc
quietly gen `col_tc'=1 `if' 
	tempvar tot
	by `1', sort: egen `tot'=total(`col_tc')
	tempvar gv
	by  `1', sort: gen `gv'=_n
	sort `1'
			if "`col'"=="A"{
			quietly export excel `1' `tot' using "`using'" if `gv'==1, sheetmodify cell(`col'2)
			quietly putexcel A1=("`1'") using "`using'", modify
			quietly putexcel B1=("`cname'") using "`using'", modify
			}
			else{
			quietly export excel `tot' using "`using'" if `gv'==1, sheetmodify cell(`col'2)
			quietly putexcel `col'1=("`cname'") using "`using'", modify	
			}	
	*
	}
	*
*if a second variable is specified, do a tabstat(sum) by `1' based on `if'
if "`2'" != ""{
tempvar tot
quietly by `1', sort: egen `tot'=total(`2') `if'
tempvar tot_2
quietly by `1', sort: egen `tot_2'=max(`tot')
quietly replace `tot_2'=0 if `tot_2'==.

tempvar gv
	by  `1', sort: gen `gv'=_n
	sort `1'
			if "`col'"=="A"{
			quietly export excel `1' `tot_2' using "`using'" if `gv'==1, sheetmodify cell(`col'2)
			quietly putexcel A1=("`1'") using "`using'", modify
			quietly putexcel B1=("`cname'") using "`using'", modify
			}
			else{
			quietly export excel `tot_2' using "`using'" if `gv'==1, sheetmodify cell(`col'2)
			quietly putexcel `col'1=("`cname'") using "`using'", modify	
			}	
	*
	}
	*
	*display name of file saved and the column name specified
	display ""
if "`using'"=="tabex.xlsx"{
display "tab `cname' saved to file:  `c(pwd)'\tabex.xlsx"
}
else{
display "tab `cname' saved to file:  `using'"
}

*reset global macro if reset option is selected
if "`reset'" != ""{
global count = 0
display "tabex counter has been reset"
}
end
