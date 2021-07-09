
cap program drop clustersampsim

program clustersampsim, rclass
		version 12
		syntax, mdes(real) rho(real) [noplot] [clusters(numlist missingok >0)] [clustersizes(numlist missingok >0)] [base_correl(real 0)] [alpha(real .05)] [beta(real .8)] [savesims(string)] [mdes2(numlist missingok max=1)] [rho2(numlist missingok max=1)] [base_correl2(numlist missingok max=1)] [alpha2(numlist missingok max=1)] [beta2(numlist missingok max=1)]
		
***Ensure that the clustersampsi command is installed 
	qui: cap findfile clustersampsi.ado

	if "`r(fn)'" == "" {
	         di as txt "user-written package clustersampsi is not installed;"
	         di as txt "Click {help clustersampsi} to find and install the package"
	         exit 498
	}


***Check to make sure arguments are OK and whether it is a single or double 

	if "`clusters'" != "" & "`clustersizes'" != "" { 

		display as error "Only clusters or clustersizes may be specified"
		
		exit
			
	}

	if "`clusters'" == "" & "`clustersizes'" == "" { 

		display as error "clusters or clustersizes must be specified"
	
		exit

	}

	if "`plot'" != "" & "`savesims'" == "" { 

		display as error "Specify a file to write results or allow plotting"

		exit

	}


***Check if the simulation will be with one or two sets of assumptions and set undefined secondary assumptions to original
	if "`mdes2'" != "" | "`rho2'" != "" | "`base_correl2'" != "" | "`alpha2'" != "" | "`beta2'" != "" {

		local double = 1

		if "`mdes2'" != "" {
			local mdes2 = `mdes2'
			} 
			else {
				local mdes2 = `mdes'
			}

		if "`rho2'" != "" {
			local rho2 = `rho2'
			} 
			else {
				local rho2 = `rho'
			}

		if "`base_correl2'" != "" {
			local base_correl2 = `base_correl2'
			} 
			else { 
				local base_correl2 = `base_correl'
			}
		if "`alpha2'" != "" {
			local alpha2 = `alpha2'
			} 
			else {
				local alpha2 = `alpha'
			}

		if "`beta2'" != "" {
			local beta2 = `beta2'
			} 
			else {
				local beta2 = `beta'
			}				
	}

	else {

		local double = 0 
	}

	*Calculate required clustersizes for a given number of clusters
	if "`clusters'" != "" {

		display as result "Calculating clustersizes for clusters: `clusters'"

		preserve
			
		clear all 
		
		*Single set of assumptions		
		if `double' == 0 {

			*Check if there might be a situation with no solution and report an error if so			
				*Run a loop to get the min and max cluster size for the list				
				local min : word 1 of `clusters'
				
				local max : word 1 of `clusters'

				forval j = 2/`: word count `clusters'' {
				    local min = min(`min', `: word `j' of `clusters'')
	 			    local max = max(`max', `: word `j' of `clusters'')
				} 

				*Check if the largest n of clusters has a solution, and terminate if none solution exists 
				qui: cap clustersampsi, mu1(`mdes') mu2(0) base_correl(`base_correl') alpha(`alpha') beta(`beta') rho(`rho') k(`max')

				local allmissing = r(min_k)

				if "`allmissing'" != "." {

					display as error "No solutions are possible with the given range of numbers of clusters." 
					display as error "Try relaxing some parameters or increase the possible number of clusters."

					exit 
				
				}

				*Check if the smallest n of clusters has a solution and report an error if not 
				qui: cap clustersampsi, mu1(`mdes') mu2(0) base_correl(`base_correl') alpha(`alpha') beta(`beta') rho(`rho') k(`min')

				local somemissing = r(min_k)

				if "`somemissing'" != "." {

					display as error "One or more cluster solutions could not be solved for. Try setting the minimum number of clusters above `min'"
				
				}

			*Extract the total number of elements and create a matrix of the correct dimensions
			local length: word count `clusters'

			matrix define results = J(`length',3,.)

			matrix colnames results = clusters npercluster totalsamplesize
			
			*Run the clustersampsi command to get the results and put them in the matrix		
			local row = 1
			
			foreach x in `clusters' {
			
				qui: cap clustersampsi, mu1(`mdes') mu2(0) base_correl(`base_correl') alpha(`alpha') beta(`beta') rho(`rho') k(`x')

				local clustersizes = r(m)

				matrix results[`row',1] = `x'

				matrix results[`row',2] = `clustersizes'
				
				matrix results[`row',3] = `clustersizes' * `x'
				
				local ++row

			}
			
			*Create the results
			qui: svmat results, names(col)

			la var npercluster "Required sample per cluster"
			la var clusters "Numbers of clusters (per arm)"
			la var totalsamplesize "Total sample size required"

			*Plot if noplot option is not selected
			if "`plot'" == "" { 

				graph twoway (connected npercluster cluster), ///
						note("MDES=`mdes'; ICC=`rho'; Baseline correlation=`rho'; Power=`beta'; Alpha = `alpha'")

				}

			*Save results if option is enabled
			if "`savesims'" != ""	{ 
			
				save "`savesims'", replace
			
				}

			*Return the matrix
			return matrix results = results

		}

		*Two sets of assumptions		
		if `double' == 1 {

			*Check if there might be a situation with no solution and report an error if so			
				*Run a loop to get the min and max cluster size for the list				
				local min : word 1 of `clusters'
				
				local max : word 1 of `clusters'

				forval j = 2/`: word count `clusters'' {
				    local min = min(`min', `: word `j' of `clusters'')
	 			    local max = max(`max', `: word `j' of `clusters'')
				} 

				*Check the largest n of clusters, and terminate the program if no solution exists 
				qui: cap clustersampsi, mu1(`mdes') mu2(0) base_correl(`base_correl') alpha(`alpha') beta(`beta') rho(`rho') k(`max')

				local allmissing1 = r(min_k)

				qui: cap clustersampsi, mu1(`mdes2') mu2(0) base_correl(`base_correl2') alpha(`alpha2') beta(`beta2') rho(`rho2') k(`max')

				local allmissing2 = r(min_k)

				if "`allmissing1'" != "." | "`allmissing2'" != "." {

					display as error "For at least one set of assumptions, no solutions are possible with the given range of numbers of clusters." 
					display as error "Try relaxing some parameters or increase the possible number of clusters."

					exit 
				
				}			

				*Check if the smallest n of clusters has a solution and report an error if not 
				qui: cap clustersampsi, mu1(`mdes') mu2(0) base_correl(`base_correl') alpha(`alpha') beta(`beta') rho(`rho') k(`min')

				local somemissing1 = r(min_k)

				qui: cap clustersampsi, mu1(`mdes2') mu2(0) base_correl(`base_correl2') alpha(`alpha2') beta(`beta2') rho(`rho2') k(`min')

				local somemissing2 = r(min_k)

				if "`somemissing1'" != "." |  "`somemissing2'" != "." {

					display as error "One or more cluster solutions could not be solved for. Try setting the minimum number of clusters above `min'"
				
				}

			*Extract the total number of elements and create a matrix of the correct dimensions
			local length: word count `clusters'

			matrix define results = J(`length',5,.)

			matrix colnames results = clusters npercluster1 totalsamplesize1 npercluster2 totalsamplesize2
			
			*Run the clustersampsi command to get the results and put them in the matrix
			local row = 1
			
			foreach x in `clusters' {

				matrix results[`row',1] = `x'
			
				*First set of assumptions
				qui: cap clustersampsi, mu1(`mdes') mu2(0) base_correl(`base_correl') alpha(`alpha') beta(`beta') rho(`rho') k(`x')

				local clustersizes1 = r(m)

				matrix results[`row',2] = `clustersizes1'

				matrix results[`row',3] = `clustersizes1' * `x'

				*Second set of assumptions
				qui: cap clustersampsi, mu1(`mdes2') mu2(0) base_correl(`base_correl2') alpha(`alpha2') beta(`beta2') rho(`rho2') k(`x')

				local clustersizes2 = r(m)

				matrix results[`row',4] = `clustersizes2'
				
				matrix results[`row',5] = `clustersizes2' * `x'
				
				local ++row

			}
			
			*Create the results
			qui: svmat results, names(col)

			la var clusters "Numbers of clusters (per arm)"
			la var npercluster1 "Sample per cluster (MDES=`mdes'; ICC=`rho'; Base. corr.=`base_correl'; Power=`beta'; Alpha = `alpha')"
			la var totalsamplesize1 "Total sample size (MDES=`mdes'; ICC=`rho'; Base. corr.=`base_correl'=`rho'; Power=`beta'; Alpha = `alpha')"
			la var npercluster2 "Sample per cluster (MDES=`mdes2'; ICC=`rho2';  Base. corr.=`base_correl2'; Power=`beta2'; Alpha = `alpha2')"
			la var totalsamplesize2 "Total sample size (MDES=`mdes2'; ICC=`rho2';  Base. corr.=`base_correl2'; Power=`beta2'; Alpha = `alpha2')"

			*Plot if noplot option is not selected
			if "`plot'" == "" { 

				graph twoway (connected npercluster1 clusters) (connected npercluster2 cluster), ///
					ytitle("Required sample size per cluster") legend(position(bottom))

			}

			*Save results if option is enabled
			if "`savesims'" != ""	{ 
			
				save "`savesims'", replace
			
			}

			*Return the matrix
			return matrix results = results				
		
		}		
				
		restore		
		
		exit

	}

	*Calculate required clusters for a given number of clustersizess
		if "`clustersizes'" != "" {
		
			display as result "Calculating clusters for clustersizes: `clustersizes' and double is `double'"
			
			*Calculate required clusters for a given number of clustersizes
			preserve
			
			clear all 

			*Single set of assumptions
			if `double' == 0 {		

				*Extract the total number of elements and create a matrix of the correct dimensions
				local length: word count `clustersizes'

				matrix define results = J(`length',3,.)

				matrix colnames results = npercluster cluster totalsamplesize
				
				*Run the clustersampsi command to get the results and put them in the matrix
				local row = 1

				foreach x in `clustersizes' {

					qui: cap clustersampsi, mu1(`mdes') mu2(0) base_correl(`base_correl') alpha(`alpha') beta(`beta') rho(`rho') m(`x')

					local cluster = r(k)

					matrix results[`row',1] = `x'

					matrix results[`row',2] = `cluster'
					
					matrix results[`row',3] = `cluster' * `x'

					local ++row

				}
				
				*Create the results
				qui: svmat results, names(col)

				la var npercluster "Sample size per cluster"
				la var cluster "Required numbers of clusters (per arm)"
				la var totalsamplesize "Total sample size required"

				*Plot if noplot option is not selected
				if "`plot'" == "" { 
	
				graph twoway (connected cluster npercluster), ///
					note("Minimum Detectable Effect Size: `mdes'; Intra-class correlation: `rho'; Power: `beta'; Error rate: `alpha'")
				
				}

				*Save results if option is enabled
				if "`savesims'" != ""	{ 
				
					save "`savesims'", replace
				
				}

				*Return the matrix
				return matrix results = results

			}
				
			*Two sets of assumptions		
			if `double' == 1 {

				*Extract the total number of elements and create a matrix of the correct dimensions
				local length: word count `clustersizes'

				matrix define results = J(`length',5,.)

				matrix colnames results = npercluster clusters1 totalsamplesize1 clusters2 totalsamplesize2
				
				*Run the clustersampsi command to get the results and put them in the matrix
				local row = 1
				
				foreach x in `clustersizes' {

					matrix results[`row',1] = `x'
				
					*First set of assumptions
					qui: cap clustersampsi, mu1(`mdes') mu2(0) base_correl(`base_correl') alpha(`alpha') beta(`beta') rho(`rho') m(`x')

					local clusters1 = r(k)

					matrix results[`row',2] = `clusters1'

					matrix results[`row',3] = `clusters1' * `x'

					*Second set of assumptions
					qui: cap clustersampsi, mu1(`mdes2') mu2(0) base_correl(`base_correl2') alpha(`alpha2') beta(`beta2') rho(`rho2') m(`x')

					local clusters2 = r(k)

					matrix results[`row',4] = `clusters2'
					
					matrix results[`row',5] = `clusters2' * `x'
					
					local ++row

				}
				
				*Create the results and plot
				qui: svmat results, names(col)

				la var npercluster"Sample per cluster"
				la var clusters1 "Clusters per arm (MDES=`mdes'; ICC=`rho'; Base. corr.=`base_correl'; Power=`beta'; Alpha = `alpha')"
				la var totalsamplesize1 "Total sample size (MDES=`mdes'; ICC=`rho'; Base. corr.=`base_correl'=`rho'; Power=`beta'; Alpha = `alpha')"
				la var clusters2 "Clusters per arm (MDES=`mdes2'; ICC=`rho2';  Base. corr.=`base_correl2'; Power=`beta2'; Alpha = `alpha2')"
				la var totalsamplesize2 "Total sample size (MDES=`mdes2'; ICC=`rho2';  Base. corr.=`base_correl2'; Power=`beta2'; Alpha = `alpha2')"

				*Plot if noplot option is not selected
				if "`plot'" == "" { 
	
				graph twoway (connected npercluster clusters1) (connected npercluster clusters2), ///
					ytitle("Required sample size per cluster") legend(position(bottom))

					 scatter npercluster clusters1

					}

				*Save results if option is enabled
				if "`savesims'" != ""	 { 				
				
					save "`savesims'", replace
				
					}

				*Return the matrix
				return matrix results = results
				
			}		

				restore

				exit
						
				}
			}

end

