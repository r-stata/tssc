*! 1.0.1 Ariel Linden 19feb2020 // fixed error message when no trees are found 
*! 1.0.0 Ariel Linden 01jan2020 

capture program drop cta
program define cta, rclass
        version 11.0
 
		syntax anything [if] [in] , 					///
			PATHCta(string)  							/// location of cta64.exe (or ct32.exe)
			[											/// optionals start from here
			ITER(real 1000)				 				/// mcarlo iterations
			CUToff(real 0.05)							/// cutoff level for mc permuations
			STOP(real 99.9)								/// stopping rule for mc permuations
			VERSion(string)								/// cta64 (default) or cta32
			STOre(string)								/// location to save files generated
			CAT(string)			 						/// attributes that are categorical
			LOO											/// leave-one-out
			LOO2(string asis)							/// leave-one-out with options
			WT(varname numeric)							/// weight
			MISSing(numlist max=1 integer)				/// representing missing values
			DIRection(string)							/// directional hypothesis
			NOPRIORS									/// turn priors off; default is on
			NAME(string)								/// let user name all output produced; default is attribute name
			ENUMerate									/// enumerate model
			FORCEnode(string)							/// force variable into specific node
			SKIPnode(numlist max=1 integer)				/// specifies that the node node will be empty of any attribute in the solution tree
			MAXlevel(numlist max=1 integer)				/// deepest level allowed in the solution tree
			USEFisher									/// specifies that all probability calculations for categorical variable will be determined by Fisher’s exact test
			PRUNE(numlist max=1)						/// prune branches
			MINDenom(numlist max=1 integer)				/// minimum denominator
			]

		qui {			
			preserve
			gettoken class attr : anything, parse(" ,")

			if "`wt'" != "" & length("`wt'") > 8 {
				di as err " `wt' must have less than 9 characters in its name" 
				exit 198
			}

			if "`wt'" != "" & ("`loo'" != "" | "`loo2'" != "") & "`cat'" != "" {
				di as err " weighted categorical LOO is not available" 
				exit 198
			}

			marksample touse 
			count if `touse' 
			if r(N) == 0 error 2000
			keep if `touse'
			
			tab `class'
*			local levels = r(r)
			if r(r) > 2 {
				di as err " The class variable must be binary" 
				exit 420 
			}
			
			* directional hypothesis
			if "`direction'" != "" & ! (inlist(substr("`direction'", 1, 2), "< ", "> ") | inlist(substr("`direction'", 1, 3), "lt ", "gt ")) {
				di as err " direction() must start with one of the following: <, >, lt, gt, followed by a space" 
				exit 198
			}
			if "`direction'" != "" {
				local right = substr("`direction'",strpos("`direction'"," ") + 1,.)
				local rightlevs: list sort right
				levelsof `class', miss local(classlevs)
					if "`classlevs'" != "`rightlevs'" {
						di as err " direction() must contain all of the same values as `class' " 
						exit 198
					}
			}
			
			* ensure variables are not doubly specified
    		if "`wt'" != "" {
				local wttest : list wt in attr
				if `wttest' == 1 {
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
				local cat = regexr("`cat'","-"," to ")
			*local cat `attr'
			}
			
			* ensure prune is specified with enumerate
			if "`enumerate'" != "" & "`prune'" == "" {
					di as err " 'prune()' must be specified with the 'enumerate' option" 
					exit 198
			}

			* where to store output
			if "`store'" != "" {
				local cwd `store'
			}
			else local cwd `c(pwd)'
			
			if "`c(os)'" == "Windows" local cwd : subinstr local cwd "\" "/" , all

			
			* reduce file to export
			keep `class' `attr' `wt'
			order `class', first
			order `attr', after(`class')
		
			local attr = regexr("`attr'","-"," to ")

			
			* export data without variable names
			if "`name'" == "" {
				local name `class' 
			}
			export delimited using "`cwd'/`name'.csv" , novarnames nolabel replace
			

			* write script to send to CTA
			tempname cmdr
			file open   `cmdr'  using "`cwd'/`name'_script.txt",  write text replace all   
			file write  `cmdr'  "open "
			file write  `cmdr' 	`"`cwd'/`name'.csv;"' _n 
			file write  `cmdr'  "output " 
			file write  `cmdr' `"`cwd'/`name'.out;"' _n
			file write  `cmdr' "vars "
			file write  `cmdr' `"`class' "'
			
			if "`wt'" != ""  {
				file write  `cmdr' `"`attr' "'
				file write  `cmdr' `"`wt';"' _n
			}
			else file write  `cmdr' `"`attr';"' _n
			
			file write  `cmdr' "class "
			file write  `cmdr' `"`class';"' _n
			file write  `cmdr' "attr "
			file write  `cmdr' `"`attr';"' _n
			
			if "`iter'" != "" file write  `cmdr' "mcarlo iter "
			if "`iter'" != "" file write  `cmdr' `"`iter' "'
			
			if "`cutoff'" != "" file write  `cmdr' "cutoff "
			if "`cutoff'" != "" file write  `cmdr' `"`cutoff' "'
			
			if "`stop'" != "" file write  `cmdr' "stop "
			if "`stop'" != "" file write  `cmdr' `"`stop';"' _n
			
			if "`enumerate'" != "" file write  `cmdr' "enumerate;" _n
			
			if "`usefisher'" != "" file write  `cmdr' "usefisher;" _n
			
			if "`prune'" != "" file write  `cmdr' "prune "
			if "`prune'" != "" file write  `cmdr' `"`prune';"' _n
			
			if "`cat'" != "" file write  `cmdr' "cat "
			if "`cat'" != "" file write  `cmdr' `"`cat';"' _n
			
			if "`loo'" != "" file write  `cmdr' "loo;" _n
			
			if "`loo2'" != "" file write  `cmdr' "loo "
			if "`loo2'" != "" file write  `cmdr' `"`loo2';"' _n
			
			if "`wt'" != "" file write  `cmdr' "weight "
			if "`wt'" != "" file write  `cmdr' `"`wt';"' _n
			
			if "`missing'" != "" file write  `cmdr' "missing all "
			if "`missing'" != "" file write  `cmdr' `"(`missing');"' _n
			
			if "`direction'" != "" file write  `cmdr' "direction "
			if "`direction'" != "" file write  `cmdr' `"`direction';"' _n
			
			if "`maxlevel'" != "" file write  `cmdr' "maxlevel "
			if "`maxlevel'" != "" file write  `cmdr' `"`maxlevel';"' _n
			
			if "`forcenode'" != "" file write  `cmdr' "forcenode "
			if "`forcenode'" != "" file write  `cmdr' `"`forcenode';"' _n

			if "`skipnode'" != "" file write  `cmdr' "skipnode "
			if "`skipnode'" != "" file write  `cmdr' `"`skipnode';"' _n
			
			if "`mindenom'" != "" file write  `cmdr' "mindenom "
			if "`mindenom'" != "" file write  `cmdr' `"`mindenom';"' _n
			if "`nopriors'" != "" file write  `cmdr' "priors off;" _n

			file write  `cmdr' "go;"
			file close  `cmdr'
	
			* run cta32 or cta64 (default)
			if "`version'" == "cta32" {
				shell "`pathcta'cta32" "`cwd'/`name'_script.txt"	
			} 
			else {
				shell "`pathcta'cta64" "`cwd'/`name'_script.txt"	
			}
		
			* clear data to allow import
			clear
			* import .txt file of ODA output
			* this will generate a single variable named v1
			import delimited "`cwd'/`name'.out"
			format %-9s v1

			* tempvars
			tempvar obsn v10 v11 v12
			
			* gen obs# to find/display strings of output
			gen long `obsn' = _n 
			count
			local N = r(N)
			
			* display error message from CTA
			su `obsn' if strpos( v1 , "No tree found.") | strpos( v1 , "No solution found for this problem") | strpos( v1 , "Error")
			if r(N) > 0 {
				local unpruned0 = `obsn'[`r(min)']
				noisily di _n
				noisily list v1 in `unpruned0', noobs clean noheader 
				exit
			}
			else if r(N) == 0 {
				su `obsn' if strpos( v1 , "Unpruned Tree Results ")
				local unpruned0 = `obsn'[`r(min)']
			}	
		} // end qui		
	
			* display unpruned tree results
			else {
				qui {
					gen `v10' =.
					su `obsn' if strpos( v1 , " | ")
					local unpruned1 = `obsn'[`r(min)']
					replace `v10' = 1 if _n >= `unpruned0' & _n < (`unpruned1' - 3)
					if "`wt'" != "" {
						su `obsn' if strpos( v1 , "WEIGHTED ESS=")
					}
					else su `obsn' if strpos( v1 , "OVERALL ESS=") 
					local unprunedESS = `obsn'[`r(min)']
				} // end quietly
				di _n
				list v1 if `v10' == 1, noobs clean noheader
				di _n
				list v1 in `unprunedESS', noobs clean noheader

				local unprunedESS =  substr(v1,  strpos( v1 , "%")  - 7, 7) in `unprunedESS'
				return scalar ess_unpruned = `unprunedESS' 
			} // end unpruned  
			
			* display pruned tree results if prune() is specified
			if "`prune'" != "" {
				qui {
					gen `v11' =.
					su `obsn' if strpos( v1 , "Pruned Tree Results")
					local pruned0 = `obsn'[`r(min)']
				
					su `obsn' if strpos( v1 , " | ") & `obsn' > `pruned0'
					local pruned1 = `obsn'[`r(min)']
					replace `v11' = 1 if _n >= `pruned0' & _n < (`pruned1' - 3)
				
					if "`wt'" != "" {
						su `obsn' if strpos( v1 , "WEIGHTED ESS=") & `obsn' > `pruned0'
					}
					else su `obsn' if strpos( v1 , "OVERALL ESS=") & `obsn' > `pruned0'
					local prunedESS = `obsn'[`r(min)']
				} // end qui
			
				di _n
				list v1 if `v11' == 1, noobs clean noheader
				di _n
				list v1 in `prunedESS', noobs clean noheader

				local prunedESS =  substr(v1,  strpos( v1 , "%")  - 7, 7) in `prunedESS'
				return scalar ess_pruned = `prunedESS' 	
			} // end prune

			* display enumerated tree results if enumerated is specified
			if "`enumerate'" != "" {
				qui {
					gen `v12' =.
					su `obsn' if strpos( v1 , "Enumerated Tree Results")
					local enumerate0 = `obsn'[`r(min)']
				
					su `obsn' if strpos( v1 , " | ") & `obsn' > `enumerate0'
					local enumerate1 = `obsn'[`r(min)']
					replace `v12' = 1 if _n >= `enumerate0' & _n < (`enumerate1' - 3)
			
					if "`wt'" != "" {
						su `obsn' if strpos( v1 , "WEIGHTED ESS=") & `obsn' > `enumerate0'
					}
					else su `obsn' if strpos( v1 , "OVERALL ESS=") & `obsn' > `enumerate0'
					local enumerateESS = `obsn'[`r(min)']
				} // end qui
				di _n
				list v1 if `v12' == 1, noobs clean noheader
				di _n
				list v1 in `enumerateESS', noobs clean noheader

				local enumerateESS =  substr(v1,  strpos( v1 , "%")  - 7, 7) in `enumerateESS'
				return scalar ess_enumerate = `enumerateESS' 
			} // end enumerate

			
end
