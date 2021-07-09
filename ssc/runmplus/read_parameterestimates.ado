* Read in Mplus output file and load parameter estimtes

* 4/4/2007 - this version of the file is only ready to read
*            irt model results 

version 9

capture program drop read_parameterestimates
program define read_parameterestimates , rclass


syntax , out(string) 

*preserve

set more off

qui infix str line 1-85 ///
      str name 1-19 ///
      str value 20-67 ///
      using `out' , clear
format line %85s


qui {
		  * IDENTIFY START AND END OF Parameter estimates
		  gen linenum=_n
		  gen x1=_n if (trim(line)=="MODEL RESULTS")|(trim(line)=="QUALITY OF NUMERICAL RESULTS")
		  summarize x1
		  keep if inrange(linenum,r(min)+1,r(max)-1)
		  drop if trim(line)==""
		  drop x1
		  drop linenum
		  gen linenum = _n

		  list linenum line , clean

		  * identify start and end of loadings
		  gen x1=linenum if (trim(line)=="F        BY")
		  su x1
		  local start_of_loadings = r(min)+1
		  drop x1
		  gen x1=linenum if trim(line)=="Thresholds"
		  su x1
		  local end_of_loadings = r(max)-1
		  drop x1

		  * identify start and end of thresholds
		  gen x1=linenum if (trim(line)=="Thresholds")
		  su x1
		  local start_of_thresholds = r(min)+1
		  drop x1
		  gen x1=linenum if trim(line)=="Variances"
		  su x1
		  local end_of_thresholds = r(min)-1
		  drop x1
		  
		  * identify variance lines
		  gen x1=linenum if (trim(line)=="Variances")
		  su x1
		  local first_variance = r(min)+1
		  local second_variance = r(max)+1
		  drop x1

		  * identify start and end of discriminations
		  gen x1=linenum if (trim(line)=="Item Discriminations")
		  su x1
		  local start_of_as = r(min)+2
		  drop x1
		  gen x1=linenum if trim(line)=="Item Difficulties"
		  su x1
		  local end_of_as = r(max)-1
		  drop x1

		  * identify start and end of difficulties
		  gen x1=linenum if (trim(line)=="Item Difficulties")
		  su x1
		  local start_of_bs = r(min)+1
		  drop x1
		  local end_of_bs = `second_variance'-2


		  * identify start and end of rsquared
		  gen x1=linenum if (trim(line)=="R-SQUARE")
		  su x1
		  local start_of_r2 = r(min)+3
		  drop x1
		  local end_of_r2 = r(N)

		  strgen type="blank"
		  foreach x in loadings thresholds as bs r2 {
			  replace type = "`x'" if inrange(linenum,`start_of_`x'',`end_of_`x'') 
		  }

		  keep if inrange(linenum,`start_of_loadings',`end_of_loadings') | ///
					 inrange(linenum,`start_of_thresholds',`end_of_thresholds') | ///
					 inrange(linenum,`start_of_as',`end_of_as') | /// 
					 inrange(linenum,`start_of_bs',`end_of_bs') | ///        
					 inrange(linenum,`start_of_r2',`end_of_r2') | ///        
					 linenum==`first_variance' | linenum==`second_variance'

		  replace type = "variance" if linenum==`first_variance'
		  replace type = "variance_irt" if linenum==`second_variance'

		  keep type line

		  replace line = lower(line)

		  strparse line , g(est)

		  rename est1 parameter
		  rename est2 estimate
		  rename est3 se
		  rename est4 z
		  rename est5 pvalue

}

qui {

		  replace parameter = subinstr(parameter,"$1","",.)

		  * added 4707
		  gen linenum=_n
		  sort type linenum
		  by type: gen itemnum=_n
		  su itemnum
		  return local nitems = r(max)
		  

		  while _N>0 {
			  local type = type
			  local inum = itemnum
			  if substr(trim(type),1,8)=="variance" {
			     return local parameter = parameter
			     return local `type' = estimate 
  			     return local `type'_se = se
			     return local `type'_z = z
			  }
			  if substr(trim(type),1,8)~="variance" {
			     return local parameter_`inum' = parameter
			     return local `type'_`inum' = estimate 
  			     return local `type'_`inum'_se = se
			     return local `type'_`inum'_z = z
			  }
			  qui drop if _n==1
		  }

}

end

