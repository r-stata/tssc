*! num2words - Stata Module to convert numeric variables to words 
**			   (including Integer, Fractional, & Ordinal numbers)
*! Eric A. Booth  <ebooth@tamu.edu>
*! v1.0.3 April 2011 fixed error dropping `varlist'2 [Apr 27, 2011]
** v1.0.2 April 2011 Updated syntax [April 25, 2011]
** v1.0.1 April 2011 Error checking for varnames improved [Apr 14, 2011]
** v1.0.0 March 2011


program define _integerconvert, rclass
syntax namelist(max=1), ARGue(str asis)
qui {
**local lists**
loc one19 "`"0"' `"zero"' `"1"' `"one"' `"2"' `"two"' `"3"' `"three"' `"4"' `"four"' `"5"' `"five"' `"6"' `"six"' `"7"' `"seven"' `"8"' `"eight"' `"9"' `"nine"' `"10"' `"ten"' `"11"' `"eleven"' `"12"' `"twelve"' `"13"' `"thirteen"' `"14"' `"fourteen"' `"15"' `"fifteen"' `"16"' `"sixteen"' `"17"' `"seventeen"' `"18"' `"eighteen"' `"19"' `"nineteen"' "
loc one9 "`"0"' `"zero"' `"1"' `"one"' `"2"' `"two"' `"3"' `"three"' `"4"' `"four"' `"5"' `"five"' `"6"' `"six"' `"7"' `"seven"' `"8"' `"eight"' `"9"' `"nine"' "
loc tens "`"2"' `"twenty"' `"3"' `"thirty"' `"4"' `"forty"' `"5"' `"fifty"' `"6"' `"sixty"' `"7"' `"seventy"' `"8"' `"eighty"' `"9"' `"ninety"' "
	loc sign = "-"
		loc i1 = `sign'2
		loc i2 = `sign'1
		loc i3 = `sign'1
		loc i4 = `sign'2
		loc i5 = `sign'3
 	tempvar begin middle end h h1 h2 h3 hlasttwo
	qui g `begin' = ""
	qui g `middle' = ""
	qui g `end' = ""
		**less than 20 (lasttwo places together)
		*fix double zeros & 20**
		qui g `hlasttwo' = ""
		qui replace `hlasttwo' = substr(_h001, `i1', 2) if mi(`hlasttwo')
		qui replace `hlasttwo' = substr(_h001, `i2', 1) if mi(`hlasttwo')		
					token `"`one19'"'
					while `"`1'"' != "" {
						 qui replace  `end' = "`2'" if `hlasttwo'=="`1'" & !mi(`hlasttwo')
						mac shift 2
						}
					qui destring `hlasttwo', replace force
					 qui replace  `hlasttwo' = . if `hlasttwo'>19

		**greater than 20 (work across all 3 places)
		g `h3' = substr(_h001, `i3', 1)
			 qui replace  `h3' = "" if `h3'=="0"		
					token `"`one9'"'
					while `"`1'"' != "" {
						 qui replace  `end' = "`2'" if `h3'=="`1'" &  mi(`end') & !mi(`h3')
						mac shift 2
						}

		g `h2' = substr(_h001, `i4', 1)
					token `"`tens'"'
					while `"`1'"' != "" {
						 qui replace  `middle' = "`2'" if `h2'=="`1'" & mi(`hlasttwo') & !mi(`h2')
						mac shift 2
						}
					 qui replace  `middle' = `middle' + "-" if !mi(`middle') & !mi(`end')
		g `h1' = substr(_h001, `i5', 1)		
			 qui replace  `h1' = "" if `h1'=="0"		
					token `"`one9'"'
					while `"`1'"' != "" {
						 qui replace  `begin' = "`2'" if `h1'=="`1'" & !mi(`h1')
						mac shift 2
						}
					qui replace  `begin' = `begin' + " hundred and " if !mi(`h1')
					qui g `namelist' = `begin' + `middle' + `end'
						**li `namelist' _h001  in 1/8
					**cleanup**
					foreach tttdr in begin middle end _h001  h1 h2 h3 hlasttwo {
						qui cap drop 	`tttdr'
							}
	}  //qui
end


program def num2words, rclass
syntax varlist(max=1) [if] [in] [,  Generate(str asis) ORDinal ROUnd ]
									**add dollars/cents later**
qui {
	**cleanup**
	foreach ddrop in __integer __integer1 __integer2 __integerx __integerxx __integer1x  __integer2x __neg __`cv'ord {
		cap confirm variable `ddrop', exact
		if !_rc {
			qui cap drop `ddrop'
				}		
			}
**check numvar**
	cap confirm numeric variable `varlist', exact
		if _rc {
			di as err `"Variable `varlist' must be numeric"'
			exit 198
			}		
**check numvar and generate don't already exist**
		if `"`generate'"' != "" {
		cap confirm variable `generate', exact
		if !_rc {
			di as err `"Variable `generate' already exists"'
			exit 198
				}
			}
		cap confirm variable `varlist'2, exact
		if !_rc & `"`generate'"' == ""  {
			di as err `"Variable `varlist'2 already exists, specify new variable in generate() option"'
			exit 198
				}		
			
**if in**
qui marksample touse, novarlist 
qui count if `touse'
if r(N) == 0 error 2000

			
**conversion**
foreach cv in `varlist' {	
	**cleanup**
	foreach ddrop in  __integer __integer1 __integer2 __integerx __integerxx __integer1x  __integer2x __neg __`cv'ord {
		cap confirm variable `ddrop', exact
		if _rc == 0 {
			qui cap drop `ddrop'
				}		
			}
	tempvar cccc
	qui g `cccc' = `cv'
	qui cap destring `cccc', replace force 
	qui gen double  __integer =  `cccc' if `touse' 
	qui format %20.6g  __integer 
	qui tostring __integer, replace u force
			**check for negatives**
			qui cap drop __neg
			qui g __neg = substr(__integer, 1, 1)
			qui replace __neg = "negative " if __neg=="-"
			qui replace __neg = "" if __neg != "negative "
			qui replace __integer = subinstr(__integer, "-", "", .)
	qui split __integer, p(".")
	qui cap format %20.6g  __integer*
	**check for more than one decimal point**
	qui ds __integer*
	cap confirm variable __integer3, exact
	if !_rc {
		noi di in r "`cv' has more than one decimal point"
		exit 198
		}
		
				
				**check that trillions or less for integer (integer1)**
				cap confirm variable __integer1, exact 
				if !_rc {	
					qui tempvar lll mlll
					qui g `lll' = length(__integer1) 
					qui egen `mlll' = max(`lll')
					if `mlll'>15 {
						noi di  as txt `"Note: Variable only interpreted up to 15 places (999 trillion)"'
						}
					qui replace __integer1 = substr(__integer1, 1, 15)
				}
				**check ordinal number does not have fractional part**
				cap confirm variable __integer2, exact
				if `"`ordinal'"' == "ordinal" & !_rc {
					noi di  as txt`"Note: Fractional Part of number will be ignored"'
					}
		
	**run for integer2 or not?**	
		**if so, get rid of decimal and leading zeros**		
	loc includethis ""
	cap confirm variable __integer2, exact
		if !_rc {
			loc includethis  "__integer2"
			**check that millionths or less for fraction (integer2)**
				qui tempvar lll mlll
				qui g `lll' = length(__integer2) 
				qui egen `mlll' = max(`lll')
				if `mlll'>6 {
					noi di as txt `"Note: Variable only interpreted up to 6 decimal places (millionths)"'
					}
				qui replace __integer2 = substr(__integer2, 1, 6)
				replace __integer2 = subinstr(__integer2, ".", "", .)	
			}
	
*--------integer (non-fractional) part		
foreach yyy in __integer1  `includethis'  {  
		 foreach mmmake in teall trall ball mall thall hall __countingplaces {
			qui cap drop `mmmake'
			}
	
		**remove leading zeros in integer2**
		if "`yyy'" == "__integer2" {
			qui cap drop __countingplaces
			qui g __countingplaces = `yyy'
			qui destring `yyy', replace force  
			qui cap format %20.6g `yyy'
			qui tostring `yyy', replace force u	
			}
			
		//integer//
		qui tostring `yyy', replace u force
		qui recast str244 `yyy'
		
		**integer or fraction pipeline**
		if `"`yyy'"'== "__integer1" loc arg "integer"
		if `"`yyy'"'== "__integer2" loc arg "fraction"
	
		**hundreds**
		loc mov "" 
		qui g _h001 = ""
		qui replace _h001= substr(`yyy', -3`mov', 3)
		qui replace  _h001 = substr(`yyy', -3`mov'+1, 2) if mi(_h001) 
		 qui replace  _h001 = substr(`yyy', -3`mov'+2, 1)  if mi(_h001)
		 _integerconvert hall  , argue(`arg')
			
		**thousands**
		loc mov = -3
		qui gen _h001= ""
		 qui replace  _h001 = substr(`yyy', -3`mov', 3)
		 qui replace  _h001 = substr(`yyy', -3`mov'+1, 2) if mi(_h001) 
		 qui replace  _h001 = substr(`yyy', -3`mov'+2, 1)  if mi(_h001)
		_integerconvert thall, argue(`arg')
		 qui replace  thall = thall + " thousand " if !mi(thall) 

		**millions**
		loc mov = -6
		qui gen _h001= ""
		 qui replace  _h001 = substr(`yyy', -3`mov', 3)
		 qui replace  _h001 = substr(`yyy', -3`mov'+1, 2) if mi(_h001) 
		 qui replace  _h001 = substr(`yyy', -3`mov'+2, 1)  if mi(_h001)
		_integerconvert mall, argue(`arg')
		 qui replace  mall = mall + " million " if !mi(mall) 
			
		**billions**
		loc mov = -9
		qui gen _h001= ""
		 qui replace  _h001 = substr(`yyy', -3`mov', 3)
		 qui replace  _h001 = substr(`yyy', -3`mov'+1, 2) if mi(_h001) 
		 qui replace  _h001 = substr(`yyy', -3`mov'+2, 1)  if mi(_h001)	
		_integerconvert ball, argue(`arg')
		 qui replace  ball = ball + " billion " if !mi(ball) 
			
		**trillion**
		loc mov = -12
		qui gen _h001= ""
		 qui replace  _h001 = substr(`yyy', -3`mov', 3)
		 qui replace  _h001 = substr(`yyy', -3`mov'+1, 2) if mi(_h001) 
		 qui replace  _h001 = substr(`yyy', -3`mov'+2, 1)  if mi(_h001)	
		_integerconvert trall, argue(`arg')
		 qui replace  trall = trall + " trillion " if !mi(trall) 
				
			*-------fractional part	(__integer2)
			if "`yyy'" == "__integer2" {	
				tempvar suffix length
				qui g `suffix' = ""
				qui g `length' = length(__countingplaces)
			loc fracts  " `"1"' `"tenths"' `"2"' `"hundredths"' `"3"' `"thousandths"' `"4"' `"ten-thousandths"' `"5"' `"hundred-thousandths"' `"6"' `"millionths"' `"7"' `"ten-millionths"' `"8"' `"hundred-millionths"' `"9"' `"billionths"' "
			token `"`fracts'"'
				while `"`1'"' != "" {
				qui replace `suffix' = " `2' " if `length' == `1' & mi(`suffix')
				mac shift 2
				}
			}
										
				**COMBINED**
                if  "`yyy'" == "__integer2"  {
					qui g str244 `yyy'x = trall + ball + mall + thall + hall + `suffix'
				}
				if "`yyy'" == "__integer1"  {
					qui g str244 `yyy'x = trall + ball + mall + thall + hall 
				}
				qui compress `yyy'x
		
			**cleanup**
			foreach dddrop in teall trall ball mall thall hall `suffix' `length' __countingplaces {
				qui cap drop `dddrop'
				}
	}  	//end convert loop for integer*		
	**combine integer1 and integer2(fractional part): integerxx**
	qui cap drop __integerxx	
	capture confirm variable __integer2x
        if !_rc {
			 if `"`round'"' == "" {
	   			 qui replace __integer1x = __integer1x + " and " if !mi(__integer1x) & !mi(__integer2x)
	 			 qui g str244 __integerxx = __integer1x  + __integer2x
	 			 }
			**Round option:  keep integer1 only
	 		if `"`round'"' == "round"  qui g str244 __integerxx = __integer1x 
                }
        else {
	  		qui g str244 __integerxx = __integer1x  
                }
        **add Negative**
    		if !mi(__neg) {    
	        	qui replace __integerxx = __neg + __integerxx
	        	}
	        	
	//ordinal//
	if `"`ordinal'"' == "ordinal"  {
			qui cap drop __`cv'ord
			qui cap drop `cccc'
			qui cap drop __endord
			qui cap drop __endordsuffix
			**
			tempvar cccc
			qui g `cccc' = abs(int(`cv'))
			format `cccc' %24.0g
			qui cap tostring `cccc', replace force u
			qui g __endord = substr(`cccc', -1, .)
			qui cap destring __endord, replace force
			qui cap destring `cccc', replace force
			format `cccc' %24.0g
			qui g __endordsuffix = ""
			**fix teens**
			 qui replace  __endordsuffix = "th" if inrange(`cccc', 10, 19)
			 qui replace  __endordsuffix = "st" if __endord ==1 & mi(__endordsuffix)
			 qui replace  __endordsuffix = "nd" if __endord ==2 & mi(__endordsuffix)
			 qui replace  __endordsuffix = "rd" if __endord ==3 & mi(__endordsuffix)
			 qui replace  __endordsuffix = "th" if inrange(__endord, 4, 9)  & mi(__endordsuffix)
			 qui replace  __endordsuffix = "th" if __endord ==0  & mi(__endordsuffix)
			**combine them**
			qui tostring `cccc', replace force u
			qui g __`cv'ord = `cccc'
			qui replace __`cv'ord  = `cccc' + __endordsuffix
			qui cap drop __endord
			qui cap drop __endordsuffix
	} //ordinal loop	

**create new var in gen**
	if `"`generate'"' != "" {
		loc lenn:length local generate
		if !mi(`lenn') & `lenn'<32 {
			if `"`ordinal'"' == ""  qui g `generate'  = __integerxx
			if `"`ordinal'"' == "ordinal"  qui g `generate'  =  __`cv'ord 

			}
		if mi(`lenn') | `lenn'>32 {
			noi di as err `"New Variable in gen() option must be <32 characters"'
			}	
		}	
			
		loc lenn2:length local cv		
	if `"`generate'"' == ""  & `lenn2' <31 & `"`ordinal'"' == "" {
			qui g `cv'2 = __integerxx
			}
	if `"`generate'"' == ""  & `lenn2' <31 & `"`ordinal'"' != "" {
			qui g `cv'2 =  __`cv'ord 
			}	
		if `"`generate'"' == ""  & `lenn2' >32 {
			noi di as err `"Specify new variable in gen() option (that is <32 characters) since variable name is too long"'
			}	
	**cleanup**
	foreach ddrop in __integer __integer1 __integer2 __integerx __integerxx __integer1x  __integer2x __neg __`cv'ord {
		qui cap drop `ddrop'
		}
	}  //varlist loop
} //qui loop
end 












/*

//EXAMPLES//

clear
set obs 10
g x = round(runiform()*100, .05)
g x2 = int(runiform()*100)
replace x = -2.5 in 1

num2words x, g(x_converted)
num2words x, g(x_rounded) round
replace x_converted = proper(x_rounded)
num2words x, g(x2_ordinal) ordinal

**graph**
egen mx = mean(x)
num2words mx, round
gr bar x  , over(x2_ordinal, sort(1)) ///
	note({bf: X for Obs 2 is `=x_rounded[2]'}) ///
	text(60 20 `"Mean = `=mx2'"',  box )
			



*/


