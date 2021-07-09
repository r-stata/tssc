*! 1.2.0 Ariel Linden 30jan2020 // fixed bug in "if strpos( v1 , "IF ")"
								// added error checking of "store" pathname for spaces
								// added Sidak adjustment option
								// added return scalars for P values for permutation and LOO
								// fixed error checking in "direction"

*! 1.0.0 Ariel Linden 29nov2019 

capture program drop oda
program define oda, rclass
        version 11.0
 
		syntax varlist(min=2 max=2 numeric) [if] [in] , ///
			PATHOda(string) [ 							/// location of megaODA.exe (or ODA.exe)
			VERSion(string)								/// NOT DOCUMENTED // megaODA (default) or ODA
			STOre(string)								/// location to save files generated
			ITER(string) 								/// mcarlo iterations
			SIDAK(numlist max=1 integer)				/// provide Sidak adjustment for P-values (permutation and LOO)
			CAT					 						/// attribute is categorical
			LOO 										/// leave-one-out
			WT(varname numeric)							/// weight
			MISSing(numlist max=1 integer)				/// representing missing values
			DEGen										/// allow degenerate cutpoints; default is off
			DIRection(string)							/// directional hypothesis
			PRImary(string)								/// primary criterion for choosing among multiple optimal solutions
			SECondary(string)							/// secondary criterion for choosing among multiple optimal solutions
			NOPRIORS									/// turn priors off; default is on
			SEED(string)								/// set seed for reproducibility
			NAME(string)								/// let user name all output produced; default is attribute name
			GEN(varname numeric)						/// group variable for -by-
			]

		qui {			
			preserve
			tokenize `varlist'
			local class `1'
			local attr `2'
			
			* check length of variables used
			if length("`class'") > 8 {
				di as err " `class' must have less than 9 characters in its name" 
				exit 198
			}
			if length("`attr'") > 8 {
				di as err " `attr' must have less than 9 characters in its name" 
				exit 198
			}
			if "`wt'" != "" & length("`wt'") > 8 {
				di as err " `wt' must have less than 9 characters in its name" 
				exit 198
			}
			if "`wt'" != "" & "`loo'" != "" & "`cat'" != "" {
				di as err " weighted categorical LOO is not available" 
				exit 198
			}
			if "`store'" != "" & length("`store'") > 132 {
				di as err " `store' must have less than 132 characters in its name" 
				exit 198
			}
			if "`store'" != "" & regexm("`store'", " ") == 1 {
				di as err " the store() option cannot have spaces in its name" 
				exit 198
			}
			if "`sidak'" != "" & "`iter'" == "" {
				di as err " iter() must be specified with the sidak() option" 
				exit 198
			}
			
			marksample touse 
			count if `touse' 
			if r(N) == 0 error 2000
			keep if `touse'
			
			tab `class'
			local levels = r(r)
			
			/* Error management */
			* primary
			if "`primary'" != "" & !inlist("`primary'", "maxsens", "meansens", "samplerep", "balanced", "distance", "random", "genmean", "default") {					
				di as err " `primary' is an invalid primary criterion" 
					exit 198
			}
			* primary
			if "`secondary'" != "" & !inlist("`secondary'", "maxsens", "meansens", "samplerep", "balanced", "distance", "random", "genmean", "default") {					
				di as err " `secondary' is an invalid secondary criterion" 
					exit 198
			}
			* directional hypothesis
			if "`direction'" != "" & ! (inlist(substr("`direction'", 1, 2), "< ", "> ") | inlist(substr("`direction'", 1, 3), "lt ", "gt ")) {
				di as err " direction() must start with one of the following: <, >, lt, gt, followed by a space" 
				exit 198
			}
			if "`direction'" != "" {
				local rightlevs = substr("`direction'",strpos("`direction'"," ") + 1,.)
				local rightcnt: list sizeof rightlevs
				levelsof `class', miss local(classlevs)
				local classcnt: list sizeof classlevs
				if "`rightcnt'" != "`classcnt'" {
						di as err " direction() must contain all of the same values as `class' " 
						exit 198
				}
				local directest : list rightlevs in classlevs
				if `directest' == 0 {
					di as err " direction() must contain all of the same values as `class' " 
					exit 198
				}
			}
			* ensure variables are not doubly specified
			if "`gen'" != "" {
				if "`gen'" == "`class'" | "`gen'" == "`attr'" {
					di as err " `gen' cannot be specified in both the syntax and 'gen()' option" 
					exit 198
				}
			}
			if "`wt'" != "" {
				if "`wt'" == "`class'" | "`wt'" == "`attr'" {
					di as err " `wt' cannot be specified in both the syntax and 'wt()' option" 
					exit 198
				}
			}
			* ensure that there are no zero weights
			if "`wt'" != "" {
				sum `wt', meanonly
				if r(min) == 0 {
					replace `wt' = 0.00001 if `wt' == 0 
				}
			}	
			* have CAT link to attribute
			if "`cat'" != "" {
				local cat `attr'
			}	
			* where to store output
			if "`store'" != "" {
				local cwd `store'
			}
			else local cwd `c(pwd)'
			
			if "`c(os)'" == "Windows" local cwd : subinstr local cwd "\" "/" , all

			
			* reduce file to export
			keep `class' `attr' `gen' `wt'
			order `class', first
			order `attr', after(`class')
			

			if "`gen'" != "" {
				tab `gen' 
				local gencnt = r(r) // get count for output later
				order `gen', after(`attr')
			}
			

			* export data without variable names
			if "`name'" == "" {
				local name `attr' 
			}
			export delimited using "`cwd'/`name'.csv" , novarnames nolabel replace
			

			* write script to send to ODA
			tempname cmdr
			file open   `cmdr'  using "`cwd'/`name'_script.txt",  write text replace all   
			file write  `cmdr'  "open "
			file write  `cmdr' 	`"`cwd'/`name'.csv;"' _n
			file write  `cmdr'  "output " 
			file write  `cmdr' `"`cwd'/`name'.out;"' _n
			file write  `cmdr' "vars "
			file write  `cmdr' `"`class' "'
			
			if "`gen'" != "" & "`wt'" == "" {
				file write  `cmdr' `"`attr' "' 
				file write  `cmdr' `"`gen';"' _n
			}
			
			else if "`wt'" != "" & "`gen'" != "" {
				file write  `cmdr' `"`attr' "'
				file write  `cmdr' `"`gen' "'
				file write  `cmdr' `"`wt';"' _n
			}
			else if "`wt'" != "" & "`gen'" == "" {
				file write  `cmdr' `"`attr' "'
				file write  `cmdr' `"`wt';"' _n
			}
			else if "`gen'" == "" & "`wt'" == "" file write  `cmdr' `"`attr';"' _n
			
			file write  `cmdr' "class "
			file write  `cmdr' `"`class';"' _n
			file write  `cmdr' "attr "
			file write  `cmdr' `"`attr';"' _n
			if "`iter'" != "" file write  `cmdr' "mcarlo iter "
			if "`iter'" != "" file write  `cmdr' `"`iter';"' _n
			if "`cat'" != "" file write  `cmdr' "cat "
			if "`cat'" != "" file write  `cmdr' `"`cat';"' _n
			if "`loo'" != "" file write  `cmdr' "loo;" _n
			if "`wt'" != "" file write  `cmdr' "weight "
			if "`wt'" != "" file write  `cmdr' `"`wt';"' _n
			if "`missing'" != "" file write  `cmdr' "missing all "
			if "`missing'" != "" file write  `cmdr' `"(`missing');"' _n
			if "`degen'" != "" file write  `cmdr' `"`degen';"' _n
			if "`direction'" != "" file write  `cmdr' "direction "
			if "`direction'" != "" file write  `cmdr' `"`direction';"' _n
			if "`primary'" != "" file write  `cmdr' "primary "
			if "`primary'" != "" file write  `cmdr' `"`primary';"' _n
			if "`secondary'" != "" file write  `cmdr' "secondary "
			if "`secondary'" != "" file write  `cmdr' `"`secondary';"' _n
			if "`nopriors'" != "" file write  `cmdr' "priors off;" _n
			if "`seed'" != "" file write  `cmdr' "seed "
			if "`seed'" != "" file write  `cmdr' `"`seed';"' _n
			if "`gen'" != "" file write  `cmdr' "gen "
			if "`gen'" != "" file write  `cmdr' `"`gen';"' _n
			file write  `cmdr' "go;"
			file close  `cmdr'

	
			* run ODA or megaODA (default)
			if "`version'" == "oda" {
				shell "`pathoda'ODA" "`cwd'/`name'_script.txt"	
			} 
			else {
				shell "`pathoda'MegaODA" "`cwd'/`name'_script.txt"	
			}
		
			* clear data to allow import
			clear
			* import .txt file of ODA output
			* this will generate a single variable named v1
			import delimited "`cwd'/`name'.out"
			format %-9s v1

			* tempvars
			tempvar obsn v2 v3 v4 v5 vlow vgenMC vhigh vgenLOO ess_train ess_loo estP estLOO
			
			* gen obs# to find/display strings of output
			gen long `obsn' = _n 
			count
			local N = r(N)
			
			* code for displaying ODA model or error message from ODA
			su `obsn' if strpos( v1 , "ODA model:")
			capture	local odamod = `obsn'[`r(min)']
			if _rc!=0 {
				noisily di _n
				noisily list v1 if strpos( v1 , "No solution found for this problem") | strpos( v1 , "Error"), noobs clean noheader 
				exit
			}	
			else {
				gen `v2' = 1 if _n >= `odamod' & _n < (`odamod' + 2)
			}
		} // end qui 				
			di _n
			list v1 if `v2' == 1, noobs clean noheader
			list v1 if strpos( v1 , "IF "), noobs clean noheader
			
		qui {	
			* code for displaying summary table
			su `obsn' if strpos( v1 , "Summary for Class")
			local sumtab = `obsn'[`r(min)']
			gen `v3' = 1 if _n >= `sumtab' & _n < `N'

			* code for displaying Monte Carlo stats
			if "`iter'" != "" &  "`gen'" == "" {
				su `obsn' if strpos( v1 , "Monte Carlo summary")
				local mcstat = `obsn'[`r(min)']
				gen `v4' = 1 if _n >= `mcstat' & _n < (`mcstat' + 4)
			}
			* code for displaying LOO stats
			if "`loo'" != "" &  "`gen'" == "" {
				su `obsn' if strpos( v1 , "Results of leave-one-out analysis")
				local loostat = `obsn'[`r(min)']

				if `levels' <= 2 {  
					gen `v5' = 1 if _n >= `loostat' & _n < (`loostat' + 5)
				}
				else if `levels' > 2 {
					gen `v5' = 1 if _n >= `loostat' & _n < (`loostat' + 3)
				}
			} // end if loo
			
			* code for displaying Monte Carlo stats when the gen option is invoked
			if  "`iter'" != "" & "`gen'" != "" {
				gen `vlow' = lower(v1)
				gen `vgenMC' = .
				forvalues i = 1/`gencnt' {
					su `obsn' if strpos( `vlow' , "results for group `gen'=`i'")
					local grstat = `obsn'[`r(min)']
					replace `vgenMC' = `i' if _n >= `grstat' & _n < (`grstat' + 8)
				}
			} // end if gen MC
			
			* code for displaying LOO stats when the gen option is invoked
			if "`gen'" != "" & "`loo'" != "" {
				gen `vhigh' = lower(v1)
				gen `vgenLOO' = .
				forvalues i = 1/`gencnt' {
					su `obsn' if strpos( `vlow' , "results for group `gen'=`i'")
					local grstat = `obsn'[`r(max)']
					replace `vgenLOO' = `i' if _n >= `grstat' & _n < (`grstat' + 6)
				}
			} // end if gen LOO

			
		} // end quietly
			
			******** display ********
			di _n
			* list summary table
			list v1 if `v3' == 1, noobs clean noheader
		
			* list Monte Carlo stats
			if "`iter'" != "" &  "`gen'" == "" {
				di _n
				list v1 if `v4' == 1, noobs clean noheader
				* get P value for r()
				qui {
					gen `estP' =  substr(v1, 13, 10) if strpos( v1 , "Estimated p: ")
					destring `estP', replace
					format %10.0g `estP'
					sum `estP', meanonly format
					local est_P = r(min)
				}
			}
			
			* Sidak adjustment permutations
			if "`iter'" != "" &  "`sidak'" != "" & "`gen'" == "" {
				local est_adjP = 1-(1-`est_P')^`sidak'
				di as result "    Sidak Adjusted (`sidak') p:" as result %10.0g `est_adjP'
			}
						
			* list LOO stats
			if "`loo'" != "" &  "`gen'" == "" {
				di _n
				list v1 if `v5' == 1, noobs clean noheader
				* get P value for r()
				qui {
					gen `estLOO' =  substr(v1, 60, 10) if strpos( v1 , "Fisher's exact test (directional) classification table  p ")
					destring `estLOO', replace
					format %10.0g `estLOO'
					sum `estLOO',  format
					local est_LOO = r(min)
				}
				if `levels' > 2 { 
					di as result "    ({it:P}-values are computed for binary class variables only)" 
				}
			}
			* Sidak adjustment LOO
			if "`loo'" != "" &  "`sidak'" != "" & "`gen'" == "" & `levels' < 3 {
				local est_adjLOO = 1-(1-`est_LOO')^`sidak'
				di as result "    Sidak Adjusted (`sidak') p for LOO:" as result %10.0g `est_adjLOO'
			}
			
			* list Monte Carlo stats when gen is invoked
			if "`gen'" != "" & "`iter'" != "" {
				forvalues i = 1/`gencnt' {
				di _n
				list v1 if `vgenMC' == `i', noobs clean noheader
				} 
			} // end if gen
			
			* list LOO stats when gen is invoked and classvar < 3
			if "`gen'" != "" & "`loo'" != "" & `levels' < 3 {
				forvalues i = 1/`gencnt' {
				di _n
				list v1 if `vgenLOO' == `i', noobs clean noheader
				} 
			} // end if gen LOO
			
			
			* stored results
		qui {
			if "`wt'" == "" {
				if "`loo'" != "" {
					gen `ess_loo' =  substr(v1, 35, 7) if strpos( v1 , "Effect Strength PAC")
					destring `ess_loo', replace
					sum `ess_loo', meanonly
					return scalar ess_loo = r(min)
				}
				gen `ess_train' =  substr(v1, 28, 6) if strpos( v1 , "Effect Strength PAC")
				destring `ess_train', replace
				sum `ess_train', meanonly
				return scalar ess_train = r(min)
			} // end wt == ""
			else if "`wt'" != "" {
				if "`loo'" != "" {
					gen `ess_loo' =  substr(v1, 35, 7) if strpos( v1 , "Effect Strength Wtd PAC")
					destring `ess_loo', replace
					sum `ess_loo', meanonly
					return scalar ess_loo = r(min)
				}
				gen `ess_train' =  substr(v1, 28, 6) if strpos( v1 , "Effect Strength Wtd PAC")
				destring `ess_train', replace
				sum `ess_train', meanonly
				return scalar ess_train = r(min)
			} // end wt != ""
			if "`loo'" != "" &  "`gen'" == "" & "`sidak'" != "" & `levels' < 3 {
				return scalar est_adjP_LOO = `est_adjLOO'
			} // end adjusted P value for LOO	
			if "`loo'" != "" &  "`gen'" == "" {
				return scalar est_P_LOO = `est_LOO'
			} // end estimated P for LOO
			if "`iter'" != "" &  "`gen'" == "" & "`sidak'" != "" {
				return scalar est_adjP = `est_adjP'
			} // end adjusted P value
			if "`iter'" != "" &  "`gen'" == "" {
				return scalar est_P = `est_P'
			} // end estimated P	

		} // end quietly


end